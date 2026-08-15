#!/usr/bin/env python3
"""Smoke ACP conciso; use --live para incluir um turno real do modelo."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import selectors
import subprocess
import time
from typing import Any


class JsonlReader:
    def __init__(self, stream: Any) -> None:
        self.stream = stream
        self.selector = selectors.DefaultSelector()
        self.selector.register(stream, selectors.EVENT_READ)
        self.buffer = bytearray()

    def next(self, timeout: float) -> dict[str, Any]:
        deadline = time.monotonic() + timeout
        while True:
            newline = self.buffer.find(b"\n")
            if newline >= 0:
                line = bytes(self.buffer[:newline])
                del self.buffer[: newline + 1]
                value = json.loads(line)
                if isinstance(value, dict):
                    return value
                continue
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                raise TimeoutError("mensagem JSONL não chegou no prazo")
            if not self.selector.select(timeout=min(remaining, 1)):
                continue
            chunk = os.read(self.stream.fileno(), 65_536)
            if not chunk:
                raise EOFError("agente ACP encerrou a saída")
            self.buffer.extend(chunk)


def send(process: subprocess.Popen[bytes], message: dict[str, Any]) -> None:
    assert process.stdin is not None
    process.stdin.write((json.dumps(message, separators=(",", ":")) + "\n").encode("utf-8"))
    process.stdin.flush()


def wait_response(
    process: subprocess.Popen[bytes],
    reader: JsonlReader,
    request_id: int,
    timeout: float,
) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    deadline = time.monotonic() + timeout
    events: list[dict[str, Any]] = []
    while time.monotonic() < deadline:
        message = reader.next(deadline - time.monotonic())
        events.append(message)
        if message.get("id") == request_id and ("result" in message or "error" in message):
            return message, events
        if "id" in message and "method" in message:
            send(
                process,
                {
                    "jsonrpc": "2.0",
                    "id": message["id"],
                    "error": {"code": -32000, "message": "smoke não autoriza ferramentas"},
                },
            )
    raise TimeoutError(f"resposta {request_id} não chegou")


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    result.add_argument("--live", action="store_true", help="cria sessão e executa um prompt mínimo")
    result.add_argument("--timeout", type=float, default=60)
    result.add_argument("--cwd", type=Path, default=Path(__file__).resolve().parents[2])
    return result


def receipt_summary(record: dict[str, Any]) -> dict[str, Any]:
    usage = record.get("token_usage")
    return {
        "duration_ms": record.get("duration_ms"),
        "root_turn_count": record.get("root_turn_count"),
        "token_completeness": record.get("token_completeness"),
        "token_usage": usage if isinstance(usage, dict) else None,
    }


def last_receipt() -> dict[str, Any]:
    configured = os.environ.get("FIAPX_AGENT_METRICS_PATH")
    path = Path(configured).expanduser() if configured else Path.home() / ".local/state/fiapx/codex-agent-metrics.jsonl"
    return json.loads(path.read_text(encoding="utf-8").splitlines()[-1])


def main() -> int:
    args = parser().parse_args()
    proxy = Path(__file__).with_name("telemetry_proxy.py").resolve()
    environment = os.environ.copy()
    environment["INITIAL_AGENT_MODE"] = "read-only"
    process = subprocess.Popen(
        [str(proxy), "acp"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=environment,
        bufsize=0,
    )
    assert process.stdout is not None
    reader = JsonlReader(process.stdout)
    summary: dict[str, Any] = {"initialize": "pending"}
    try:
        send(
            process,
            {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "protocolVersion": 1,
                    "clientCapabilities": {},
                    "clientInfo": {"name": "fiapx-telemetry-smoke", "version": "1.0"},
                },
            },
        )
        initialize, _ = wait_response(process, reader, 1, 15)
        summary["initialize"] = "ok" if "result" in initialize else "error"
        if args.live:
            send(
                process,
                {
                    "jsonrpc": "2.0",
                    "id": 2,
                    "method": "session/new",
                    "params": {"cwd": str(args.cwd.resolve()), "mcpServers": [], "additionalDirectories": []},
                },
            )
            session, _ = wait_response(process, reader, 2, 30)
            session_id = session["result"]["sessionId"]
            send(
                process,
                {
                    "jsonrpc": "2.0",
                    "id": 3,
                    "method": "session/prompt",
                    "params": {
                        "sessionId": session_id,
                        "prompt": [{"type": "text", "text": "Responda somente OK. Não use ferramentas."}],
                    },
                },
            )
            terminal, events = wait_response(process, reader, 3, args.timeout)
            footer_count = sum(
                event.get("method") == "session/update"
                and "Métricas da execução (runtime)" in json.dumps(event, ensure_ascii=False)
                for event in events
            )
            summary.update(
                {
                    "session_new": "ok",
                    "prompt_stop_reason": terminal.get("result", {}).get("stopReason"),
                    "footer_count": footer_count,
                    "receipt": receipt_summary(last_receipt()),
                }
            )
            if footer_count != 1:
                raise RuntimeError(f"esperado um rodapé, observado {footer_count}")
        print(json.dumps(summary, separators=(",", ":")))
        return 0
    finally:
        if process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()


if __name__ == "__main__":
    raise SystemExit(main())
