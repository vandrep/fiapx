from __future__ import annotations

import json
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import unittest
from contextlib import redirect_stderr
from io import StringIO
import os


TOOL_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from configure_jetbrains import AGENT_NAME, desired_agent, merged_configuration  # noqa: E402
from telemetry_proxy import (  # noqa: E402
    AcpTracker,
    AppServerTracker,
    aggregate_token_usage,
    assert_persistable,
    hash_id,
    normalize_token_usage,
    parse_json_line,
    secure_append_json,
    spool_path,
)
from smoke_test import JsonlReader, receipt_summary  # noqa: E402


class FakeClock:
    def __init__(self, nanoseconds: int = 1_000_000_000) -> None:
        self.nanoseconds = nanoseconds

    def monotonic_ns(self) -> int:
        return self.nanoseconds

    def utc(self) -> str:
        return f"2026-08-15T00:00:{self.nanoseconds // 1_000_000_000:02d}.000Z"

    def advance_ms(self, milliseconds: int) -> None:
        self.nanoseconds += milliseconds * 1_000_000


def native_usage(seed: int = 1) -> dict[str, int]:
    return {
        "totalTokens": 100 * seed,
        "inputTokens": 70 * seed,
        "cachedInputTokens": 30 * seed,
        "cacheWriteInputTokens": 5 * seed,
        "outputTokens": 20 * seed,
        "reasoningOutputTokens": 10 * seed,
    }


def turn_receipt(session_id: str, turn: str, completed_ns: int, seed: int = 1) -> dict[str, object]:
    return {
        "schema_version": 1,
        "kind": "turn",
        "source": "codex_app_server",
        "adapter_version": "1.3.0",
        "codex_version": "0.147.0",
        "classification": "root",
        "session_hash": hash_id(session_id),
        "turn_hash": hash_id(turn),
        "started_at": "2026-08-15T00:00:01.000Z",
        "completed_at": "2026-08-15T00:00:02.000Z",
        "started_monotonic_ns": completed_ns - 1_000_000,
        "completed_monotonic_ns": completed_ns,
        "duration_ms": 1,
        "terminal_status": "completed",
        "token_usage": normalize_token_usage(native_usage(seed)),
        "token_completeness": "exact",
    }


class AppServerTrackerTest(unittest.TestCase):
    def test_persists_exact_root_turn_once(self) -> None:
        clock = FakeClock()
        stored: list[dict[str, object]] = []
        tracker = AppServerTracker(
            Path("metrics.jsonl"),
            append_record=lambda _path, record: stored.append(record),
            monotonic_ns=clock.monotonic_ns,
            utc_clock=clock.utc,
        )
        tracker.observe_client_message({"id": 1, "method": "thread/start", "params": {}})
        tracker.observe_server_message({"id": 1, "result": {"thread": {"id": "root-session"}}})
        tracker.observe_server_message(
            {"method": "turn/started", "params": {"threadId": "root-session", "turn": {"id": "turn-1"}}}
        )
        clock.advance_ms(125)
        tracker.observe_server_message(
            {
                "method": "thread/tokenUsage/updated",
                "params": {"threadId": "root-session", "turnId": "turn-1", "tokenUsage": {"last": native_usage()}},
            }
        )
        terminal = {
            "method": "turn/completed",
            "params": {"threadId": "root-session", "turn": {"id": "turn-1", "status": "completed"}},
        }
        tracker.observe_server_message(terminal)
        tracker.observe_server_message(terminal)

        self.assertEqual(1, len(stored))
        self.assertEqual("root", stored[0]["classification"])
        self.assertEqual("exact", stored[0]["token_completeness"])
        self.assertEqual(125, stored[0]["duration_ms"])
        self.assertEqual(100, stored[0]["token_usage"]["total_tokens"])

    def test_excludes_child_thread_and_keeps_interruption(self) -> None:
        stored: list[dict[str, object]] = []
        tracker = AppServerTracker(Path("metrics.jsonl"), append_record=lambda _path, record: stored.append(record))
        tracker.observe_server_message(
            {"method": "turn/started", "params": {"threadId": "child", "turn": {"id": "child-turn"}}}
        )
        tracker.observe_server_message(
            {"method": "turn/completed", "params": {"threadId": "child", "turn": {"id": "child-turn", "status": "completed"}}}
        )
        tracker.observe_client_message({"id": "resume", "method": "thread/resume", "params": {}})
        tracker.observe_server_message({"id": "resume", "result": {"thread": {"id": "root"}}})
        tracker.observe_server_message(
            {"method": "turn/started", "params": {"threadId": "root", "turn": {"id": "root-turn"}}}
        )
        tracker.observe_server_message(
            {"method": "turn/completed", "params": {"threadId": "root", "turn": {"id": "root-turn", "status": "interrupted"}}}
        )

        self.assertEqual(1, len(stored))
        self.assertEqual("interrupted", stored[0]["terminal_status"])
        self.assertEqual("unavailable", stored[0]["token_completeness"])


class AcpTrackerTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.metrics_path = Path(self.temporary.name) / "metrics.jsonl"
        self.clock = FakeClock()

    def tracker(self, append_record=secure_append_json) -> AcpTracker:
        return AcpTracker(
            self.metrics_path,
            append_record=append_record,
            monotonic_ns=self.clock.monotonic_ns,
            utc_clock=self.clock.utc,
        )

    def observe_prompt(self, tracker: AcpTracker, prompt: object = "SEGREDO-NAO-PERSISTIR") -> None:
        tracker.observe_client_message(
            {"jsonrpc": "2.0", "id": 7, "method": "session/prompt", "params": {"sessionId": "session-1", "prompt": prompt}}
        )

    def test_aggregates_multiple_root_turns_and_orders_footer_before_response(self) -> None:
        tracker = self.tracker()
        self.observe_prompt(tracker)
        self.clock.advance_ms(10)
        path = spool_path(self.metrics_path, hash_id("session-1"))
        secure_append_json(path, turn_receipt("session-1", "turn-1", self.clock.nanoseconds, 1))
        self.clock.advance_ms(10)
        secure_append_json(path, turn_receipt("session-1", "turn-2", self.clock.nanoseconds, 2))
        self.clock.advance_ms(10)
        response = b'{"jsonrpc":"2.0","id":7,"result":{"stopReason":"end_turn","usage":{"totalTokens":999}}}\n'

        transformed = tracker.transform_server_line(response)

        self.assertEqual(2, len(transformed))
        footer = json.loads(transformed[0])
        self.assertEqual("session/update", footer["method"])
        self.assertIn("total 300", footer["params"]["update"]["content"]["text"])
        self.assertIn("turnos raiz 2", footer["params"]["update"]["content"]["text"])
        self.assertEqual(response, transformed[1])
        persisted = self.metrics_path.read_text(encoding="utf-8")
        self.assertNotIn("SEGREDO-NAO-PERSISTIR", persisted)
        receipt = json.loads(persisted)
        self.assertEqual(300, receipt["token_usage"]["total_tokens"])
        self.assertEqual("exact", receipt["token_completeness"])

    def test_missing_authoritative_receipt_is_not_replaced_by_acp_usage(self) -> None:
        stored: list[dict[str, object]] = []
        tracker = self.tracker(append_record=lambda _path, record: stored.append(record))
        self.observe_prompt(tracker)
        self.clock.advance_ms(5)
        response = b'{"jsonrpc":"2.0","id":7,"result":{"stopReason":"end_turn","usage":{"totalTokens":999}}}\n'

        transformed = tracker.transform_server_line(response)
        footer = json.loads(transformed[0])["params"]["update"]["content"]["text"]

        self.assertIn("tokens indisponíveis", footer)
        self.assertNotIn("999", footer)
        self.assertIsNone(stored[0]["token_usage"])

    def test_persistence_failure_does_not_drop_response(self) -> None:
        def fail_append(_path: Path, _record: dict[str, object]) -> None:
            raise OSError("read only")

        tracker = self.tracker(append_record=fail_append)
        self.observe_prompt(tracker)
        response = b'{"jsonrpc":"2.0","id":7,"result":{"stopReason":"cancelled"}}\n'

        with redirect_stderr(StringIO()):
            transformed = tracker.transform_server_line(response)

        self.assertIn("persistência falhou", json.loads(transformed[0])["params"]["update"]["content"]["text"])
        self.assertEqual(response, transformed[1])

    def test_duplicate_response_and_malformed_line_are_passed_without_duplicate_footer(self) -> None:
        tracker = self.tracker(append_record=lambda _path, _record: None)
        malformed = b"not-json\n"
        self.assertEqual([malformed], tracker.transform_server_line(malformed))
        self.observe_prompt(tracker)
        response = b'{"id":7,"result":{"stopReason":"end_turn"}}\n'
        self.assertEqual(2, len(tracker.transform_server_line(response)))
        self.assertEqual([response], tracker.transform_server_line(response))


class ContractTest(unittest.TestCase):
    def test_token_schema_requires_the_complete_breakdown(self) -> None:
        self.assertIsNotNone(normalize_token_usage(native_usage()))
        incomplete = native_usage()
        del incomplete["reasoningOutputTokens"]
        self.assertIsNone(normalize_token_usage(incomplete))
        self.assertIsNone(aggregate_token_usage([{"token_usage": None}]))

    def test_sensitive_fields_are_rejected_recursively(self) -> None:
        with self.assertRaises(ValueError):
            assert_persistable({"safe": {"prompt": "secret"}})

    def test_json_parser_does_not_change_malformed_input(self) -> None:
        self.assertIsNone(parse_json_line(b"not-json\n"))
        self.assertEqual({"id": 1}, parse_json_line(b'{"id":1}\n'))

    def test_smoke_reader_drains_lines_already_buffered_in_user_space(self) -> None:
        read_fd, write_fd = os.pipe()
        with os.fdopen(read_fd, "rb", buffering=0) as reader_stream, os.fdopen(write_fd, "wb", buffering=0) as writer:
            reader = JsonlReader(reader_stream)
            writer.write(b'{"id":1}\n{"id":2}\n')
            self.assertEqual(1, reader.next(1)["id"])
            self.assertEqual(2, reader.next(0.01)["id"])

    def test_smoke_summary_copies_the_authoritative_receipt(self) -> None:
        record = {
            "duration_ms": 6434,
            "root_turn_count": 1,
            "token_completeness": "exact",
            "token_usage": {"total_tokens": 17165, "cached_input_tokens": 6912},
            "prompt": "ignored by summary",
        }
        self.assertEqual(
            {
                "duration_ms": 6434,
                "root_turn_count": 1,
                "token_completeness": "exact",
                "token_usage": {"total_tokens": 17165, "cached_input_tokens": 6912},
            },
            receipt_summary(record),
        )

    def test_jetbrains_merge_preserves_existing_agents(self) -> None:
        current = {
            "default_mcp_settings": {"use_idea_mcp": True},
            "agent_servers": {"Existing": {"command": "/bin/existing"}},
        }
        agent = desired_agent(Path("/repo"), Path("/state/metrics.jsonl"))
        merged = merged_configuration(current, agent)
        self.assertIn("Existing", merged["agent_servers"])
        self.assertEqual(agent, merged["agent_servers"][AGENT_NAME])
        self.assertEqual({"use_idea_mcp": True}, merged["default_mcp_settings"])

    @unittest.skipUnless((TOOL_ROOT / "node_modules/@agentclientprotocol/codex-acp/dist/index.js").is_file(), "npm ci não executado")
    def test_sigint_terminates_proxy_without_fatal_teardown(self) -> None:
        process = subprocess.Popen(
            [sys.executable, str(TOOL_ROOT / "telemetry_proxy.py"), "acp"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        try:
            time.sleep(0.3)
            process.send_signal(signal.SIGINT)
            _stdout, stderr = process.communicate(timeout=5)
        finally:
            if process.poll() is None:
                process.kill()
                process.wait()
        self.assertEqual(130, process.returncode)
        self.assertNotIn(b"Fatal Python error", stderr)
        self.assertNotIn(b"Traceback", stderr)


if __name__ == "__main__":
    unittest.main()
