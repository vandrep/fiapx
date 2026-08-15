#!/usr/bin/env python3
"""Proxy transparente ACP/App Server com recibos pós-execução mínimos."""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import threading
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Callable, Iterable


SCHEMA_VERSION = 1
ADAPTER_VERSION = "1.3.0"
CODEX_VERSION = "0.147.0"
TOKEN_FIELDS = {
    "totalTokens": "total_tokens",
    "inputTokens": "input_tokens",
    "cachedInputTokens": "cached_input_tokens",
    "cacheWriteInputTokens": "cache_write_input_tokens",
    "outputTokens": "output_tokens",
    "reasoningOutputTokens": "reasoning_output_tokens",
}
PERSISTENCE_FORBIDDEN_KEYS = {
    "content",
    "message",
    "prompt",
    "response",
    "text",
    "tool",
    "tool_output",
}
ROOT_METHODS = {"thread/start", "thread/resume", "thread/fork"}
TERMINAL_METHOD = "turn/completed"


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")


def hash_id(value: Any) -> str:
    serialized = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    return hashlib.sha256(serialized.encode("utf-8")).hexdigest()[:24]


def request_key(value: Any) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def parse_json_line(line: bytes) -> dict[str, Any] | None:
    try:
        value = json.loads(line)
    except (UnicodeDecodeError, json.JSONDecodeError):
        return None
    return value if isinstance(value, dict) else None


def normalize_token_usage(value: Any) -> dict[str, int] | None:
    if not isinstance(value, dict):
        return None
    normalized: dict[str, int] = {}
    for source, target in TOKEN_FIELDS.items():
        amount = value.get(source)
        if not isinstance(amount, int) or isinstance(amount, bool) or amount < 0:
            return None
        normalized[target] = amount
    return normalized


def aggregate_token_usage(receipts: Iterable[dict[str, Any]]) -> dict[str, int] | None:
    aggregated = {target: 0 for target in TOKEN_FIELDS.values()}
    count = 0
    for receipt in receipts:
        usage = receipt.get("token_usage")
        if not isinstance(usage, dict) or any(not isinstance(usage.get(field), int) for field in aggregated):
            return None
        for field in aggregated:
            aggregated[field] += usage[field]
        count += 1
    return aggregated if count else None


def assert_persistable(record: Any) -> None:
    if isinstance(record, dict):
        forbidden = PERSISTENCE_FORBIDDEN_KEYS.intersection(record)
        if forbidden:
            raise ValueError(f"campos sensíveis proibidos no recibo: {', '.join(sorted(forbidden))}")
        for value in record.values():
            assert_persistable(value)
    elif isinstance(record, list):
        for value in record:
            assert_persistable(value)


def secure_append_json(path: Path, record: dict[str, Any]) -> None:
    assert_persistable(record)
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    os.chmod(path.parent, 0o700)
    payload = (json.dumps(record, sort_keys=True, separators=(",", ":")) + "\n").encode("utf-8")
    descriptor = os.open(path, os.O_APPEND | os.O_CREAT | os.O_WRONLY, 0o600)
    try:
        os.fchmod(descriptor, 0o600)
        os.write(descriptor, payload)
    finally:
        os.close(descriptor)


def default_metrics_path() -> Path:
    configured = os.environ.get("FIAPX_AGENT_METRICS_PATH")
    if configured:
        return Path(configured).expanduser()
    state_home = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local" / "state"))
    return state_home / "fiapx" / "codex-agent-metrics.jsonl"


def spool_path(metrics_path: Path, session_hash: str) -> Path:
    return metrics_path.parent / "codex-agent-metrics-spool" / f"{session_hash}.jsonl"


def thread_from_response(message: dict[str, Any]) -> str | None:
    result = message.get("result")
    if not isinstance(result, dict):
        return None
    thread = result.get("thread")
    if isinstance(thread, dict) and isinstance(thread.get("id"), str):
        return thread["id"]
    return result.get("threadId") if isinstance(result.get("threadId"), str) else None


class AppServerTracker:
    """Observa eventos do App Server e grava somente turnos raiz terminais."""

    def __init__(
        self,
        metrics_path: Path,
        append_record: Callable[[Path, dict[str, Any]], None] = secure_append_json,
        monotonic_ns: Callable[[], int] = time.monotonic_ns,
        utc_clock: Callable[[], str] = utc_now,
    ) -> None:
        self.metrics_path = metrics_path
        self.append_record = append_record
        self.monotonic_ns = monotonic_ns
        self.utc_clock = utc_clock
        self.pending_requests: dict[str, str] = {}
        self.root_threads: set[str] = set()
        self.turns: dict[str, dict[str, Any]] = {}
        self.persisted_turns: set[str] = set()
        self.lock = threading.Lock()

    def observe_client_message(self, message: dict[str, Any]) -> None:
        method = message.get("method")
        if method in ROOT_METHODS and "id" in message:
            with self.lock:
                self.pending_requests[request_key(message["id"])] = method

    def observe_server_message(self, message: dict[str, Any]) -> None:
        if "id" in message and "method" not in message:
            key = request_key(message["id"])
            with self.lock:
                method = self.pending_requests.pop(key, None)
                thread_id = thread_from_response(message) if method in ROOT_METHODS else None
                if thread_id:
                    self.root_threads.add(thread_id)
            return

        method = message.get("method")
        params = message.get("params")
        if not isinstance(params, dict):
            return
        if method == "turn/started":
            self._turn_started(params)
        elif method == "thread/tokenUsage/updated":
            self._token_usage_updated(params)
        elif method == TERMINAL_METHOD:
            self._turn_completed(params)

    def _turn_started(self, params: dict[str, Any]) -> None:
        turn = params.get("turn")
        if not isinstance(turn, dict) or not isinstance(turn.get("id"), str):
            return
        turn_id = turn["id"]
        thread_id = params.get("threadId")
        with self.lock:
            current = self.turns.setdefault(turn_id, {})
            current.update(
                {
                    "thread_id": thread_id if isinstance(thread_id, str) else None,
                    "started_monotonic_ns": self.monotonic_ns(),
                    "started_at": self.utc_clock(),
                }
            )

    def _token_usage_updated(self, params: dict[str, Any]) -> None:
        turn_id = params.get("turnId")
        token_usage = params.get("tokenUsage")
        if not isinstance(turn_id, str) or not isinstance(token_usage, dict):
            return
        usage = normalize_token_usage(token_usage.get("last"))
        with self.lock:
            self.turns.setdefault(turn_id, {})["token_usage"] = usage

    def _turn_completed(self, params: dict[str, Any]) -> None:
        turn = params.get("turn")
        if not isinstance(turn, dict) or not isinstance(turn.get("id"), str):
            return
        turn_id = turn["id"]
        thread_id = params.get("threadId")
        if not isinstance(thread_id, str):
            return

        with self.lock:
            if turn_id in self.persisted_turns or thread_id not in self.root_threads:
                return
            self.persisted_turns.add(turn_id)
            observed = self.turns.pop(turn_id, {})

        completed_ns = self.monotonic_ns()
        started_ns = observed.get("started_monotonic_ns")
        duration_ms = max(0, (completed_ns - started_ns) // 1_000_000) if isinstance(started_ns, int) else None
        receipt = {
            "schema_version": SCHEMA_VERSION,
            "kind": "turn",
            "source": "codex_app_server",
            "adapter_version": ADAPTER_VERSION,
            "codex_version": CODEX_VERSION,
            "classification": "root",
            "session_hash": hash_id(thread_id),
            "turn_hash": hash_id(turn_id),
            "started_at": observed.get("started_at"),
            "completed_at": self.utc_clock(),
            "started_monotonic_ns": started_ns,
            "completed_monotonic_ns": completed_ns,
            "duration_ms": duration_ms,
            "terminal_status": turn.get("status", "unknown"),
            "token_usage": observed.get("token_usage"),
            "token_completeness": "exact" if observed.get("token_usage") is not None else "unavailable",
        }
        try:
            self.append_record(spool_path(self.metrics_path, receipt["session_hash"]), receipt)
        except (OSError, ValueError) as error:
            print(f"codex-telemetry: não foi possível persistir recibo de turno: {error}", file=sys.stderr)


@dataclass
class PromptObservation:
    session_id: str
    started_at: str
    started_monotonic_ns: int


class AcpTracker:
    """Correlaciona prompts ACP e injeta o recibo depois da resposta do modelo."""

    def __init__(
        self,
        metrics_path: Path,
        append_record: Callable[[Path, dict[str, Any]], None] = secure_append_json,
        monotonic_ns: Callable[[], int] = time.monotonic_ns,
        utc_clock: Callable[[], str] = utc_now,
    ) -> None:
        self.metrics_path = metrics_path
        self.append_record = append_record
        self.monotonic_ns = monotonic_ns
        self.utc_clock = utc_clock
        self.prompts: dict[str, PromptObservation] = {}
        self.lock = threading.Lock()

    def observe_client_message(self, message: dict[str, Any]) -> None:
        if message.get("method") != "session/prompt" or "id" not in message:
            return
        params = message.get("params")
        session_id = params.get("sessionId") if isinstance(params, dict) else None
        if not isinstance(session_id, str):
            return
        observation = PromptObservation(session_id, self.utc_clock(), self.monotonic_ns())
        with self.lock:
            self.prompts[request_key(message["id"])] = observation

    def transform_server_line(self, line: bytes) -> list[bytes]:
        message = parse_json_line(line)
        if message is None or "id" not in message or "method" in message:
            return [line]
        with self.lock:
            observation = self.prompts.pop(request_key(message["id"]), None)
        if observation is None:
            return [line]
        footer = self._finish_prompt(message, observation)
        serialized = (json.dumps(footer, separators=(",", ":"), ensure_ascii=False) + "\n").encode("utf-8")
        return [serialized, line]

    def _load_receipts(self, observation: PromptObservation, completed_ns: int) -> list[dict[str, Any]]:
        path = spool_path(self.metrics_path, hash_id(observation.session_id))
        if not path.exists():
            return []
        receipts: list[dict[str, Any]] = []
        try:
            with path.open("r", encoding="utf-8") as stream:
                for line in stream:
                    try:
                        value = json.loads(line)
                    except json.JSONDecodeError:
                        continue
                    terminal_ns = value.get("completed_monotonic_ns") if isinstance(value, dict) else None
                    if (
                        isinstance(value, dict)
                        and value.get("kind") == "turn"
                        and value.get("classification") == "root"
                        and value.get("session_hash") == hash_id(observation.session_id)
                        and isinstance(terminal_ns, int)
                        and observation.started_monotonic_ns <= terminal_ns <= completed_ns
                    ):
                        receipts.append(value)
        except OSError as error:
            print(f"codex-telemetry: não foi possível ler recibos de turno: {error}", file=sys.stderr)
        unique = {receipt.get("turn_hash"): receipt for receipt in receipts if receipt.get("turn_hash")}
        return sorted(unique.values(), key=lambda receipt: receipt["completed_monotonic_ns"])

    def _finish_prompt(self, response: dict[str, Any], observation: PromptObservation) -> dict[str, Any]:
        completed_ns = self.monotonic_ns()
        receipts = self._load_receipts(observation, completed_ns)
        usage = aggregate_token_usage(receipts)
        terminal_status = "error" if "error" in response else "unknown"
        result = response.get("result")
        if isinstance(result, dict) and isinstance(result.get("stopReason"), str):
            terminal_status = result["stopReason"]

        execution = {
            "schema_version": SCHEMA_VERSION,
            "kind": "execution",
            "source": "codex_app_server",
            "adapter_version": ADAPTER_VERSION,
            "codex_version": CODEX_VERSION,
            "session_hash": hash_id(observation.session_id),
            "request_hash": hash_id(response.get("id")),
            "started_at": observation.started_at,
            "completed_at": self.utc_clock(),
            "duration_ms": max(0, (completed_ns - observation.started_monotonic_ns) // 1_000_000),
            "terminal_status": terminal_status,
            "root_turn_count": len(receipts),
            "root_turn_hashes": [receipt["turn_hash"] for receipt in receipts],
            "token_usage": usage,
            "token_completeness": "exact" if usage is not None else "unavailable",
        }
        persisted = True
        try:
            self.append_record(self.metrics_path, execution)
        except (OSError, ValueError) as error:
            persisted = False
            print(f"codex-telemetry: não foi possível persistir recibo de execução: {error}", file=sys.stderr)

        footer = format_footer(execution, persisted)
        return {
            "jsonrpc": "2.0",
            "method": "session/update",
            "params": {
                "sessionId": observation.session_id,
                "update": {
                    "sessionUpdate": "agent_message_chunk",
                    "content": {"type": "text", "text": footer},
                    "_meta": {
                        "fiapx": {
                            "schema_version": SCHEMA_VERSION,
                            "source": "codex_app_server",
                            "token_completeness": execution["token_completeness"],
                            "persisted": persisted,
                        }
                    },
                },
            },
        }


def format_footer(execution: dict[str, Any], persisted: bool) -> str:
    duration = execution["duration_ms"]
    turns = execution["root_turn_count"]
    persistence = "recibo persistido" if persisted else "persistência falhou"
    usage = execution.get("token_usage")
    if not isinstance(usage, dict):
        tokens = "tokens indisponíveis"
    else:
        tokens = (
            f"tokens entrada {usage['input_tokens']} "
            f"(cache {usage['cached_input_tokens']}; escrita cache {usage['cache_write_input_tokens']}), "
            f"saída {usage['output_tokens']}, raciocínio {usage['reasoning_output_tokens']}, "
            f"total {usage['total_tokens']}"
        )
    return f"\n\nMétricas da execução (runtime): {duration} ms; {tokens}; turnos raiz {turns}; {persistence}."


def forward_input(
    source: Any,
    destination: Any,
    observer: Callable[[dict[str, Any]], None],
) -> None:
    try:
        for line in iter(source.readline, b""):
            message = parse_json_line(line)
            if message is not None:
                observer(message)
            destination.write(line)
            destination.flush()
    except (BrokenPipeError, OSError):
        pass
    finally:
        try:
            destination.close()
        except OSError:
            pass


def unbuffered_stdin() -> Any:
    """Evita que uma thread daemon retenha o BufferedReader global no teardown."""
    return os.fdopen(os.dup(sys.stdin.fileno()), "rb", buffering=0)


def stop_child(process: subprocess.Popen[bytes]) -> None:
    if process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=2)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait()


def run_app_server_proxy(command: list[str], metrics_path: Path) -> int:
    process = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=None, bufsize=0)
    assert process.stdin is not None and process.stdout is not None
    tracker = AppServerTracker(metrics_path)
    writer = threading.Thread(
        target=forward_input,
        args=(unbuffered_stdin(), process.stdin, tracker.observe_client_message),
        daemon=True,
    )
    writer.start()
    try:
        for line in iter(process.stdout.readline, b""):
            message = parse_json_line(line)
            if message is not None:
                tracker.observe_server_message(message)
            sys.stdout.buffer.write(line)
            sys.stdout.buffer.flush()
    except (BrokenPipeError, OSError):
        stop_child(process)
    except KeyboardInterrupt:
        stop_child(process)
        return 130
    return process.wait()


def run_acp_proxy(command: list[str], metrics_path: Path, proxy_path: Path) -> int:
    environment = os.environ.copy()
    environment["CODEX_PATH"] = str(proxy_path)
    process = subprocess.Popen(
        command,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=None,
        env=environment,
        bufsize=0,
    )
    assert process.stdin is not None and process.stdout is not None
    tracker = AcpTracker(metrics_path)
    writer = threading.Thread(
        target=forward_input,
        args=(unbuffered_stdin(), process.stdin, tracker.observe_client_message),
        daemon=True,
    )
    writer.start()
    try:
        for line in iter(process.stdout.readline, b""):
            for transformed in tracker.transform_server_line(line):
                sys.stdout.buffer.write(transformed)
                sys.stdout.buffer.flush()
    except (BrokenPipeError, OSError):
        stop_child(process)
    except KeyboardInterrupt:
        stop_child(process)
        return 130
    return process.wait()


def resolve_runtime() -> tuple[str, Path, Path]:
    root = Path(__file__).resolve().parent
    node = shutil.which("node")
    acp_entry = root / "node_modules" / "@agentclientprotocol" / "codex-acp" / "dist" / "index.js"
    codex_entry = root / "node_modules" / "@openai" / "codex" / "bin" / "codex.js"
    missing = [str(path) for path in (acp_entry, codex_entry) if not path.is_file()]
    if node is None or missing:
        details = "node ausente" if node is None else f"dependências ausentes: {', '.join(missing)}"
        raise RuntimeError(f"{details}; execute npm ci em {root}")
    return node, acp_entry, codex_entry


def self_check() -> int:
    node, acp_entry, codex_entry = resolve_runtime()
    print(
        json.dumps(
            {
                "status": "ok",
                "schema_version": SCHEMA_VERSION,
                "node": node,
                "adapter": str(acp_entry),
                "codex": str(codex_entry),
            },
            separators=(",", ":"),
        )
    )
    return 0


def main(argv: list[str]) -> int:
    if argv == ["self-check"]:
        return self_check()
    node, acp_entry, codex_entry = resolve_runtime()
    proxy_path = Path(__file__).resolve()
    metrics_path = default_metrics_path()
    if argv and argv[0] == "acp":
        return run_acp_proxy([node, str(acp_entry), *argv[1:]], metrics_path, proxy_path)
    if argv and argv[0] == "app-server":
        return run_app_server_proxy([node, str(codex_entry), *argv], metrics_path)
    os.execv(node, [node, str(codex_entry), *argv])
    return 1


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except RuntimeError as error:
        print(f"codex-telemetry: {error}", file=sys.stderr)
        raise SystemExit(2) from error
