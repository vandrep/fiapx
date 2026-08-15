#!/usr/bin/env python3
"""Registra o agente instrumentado sem substituir agentes ACP existentes."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import shutil
import tempfile
from typing import Any


AGENT_NAME = "Codex FIAPX (métricas)"


def desired_agent(repo_root: Path, metrics_path: Path) -> dict[str, Any]:
    return {
        "command": str((repo_root / "tools/codex-telemetry/telemetry_proxy.py").resolve()),
        "args": ["acp"],
        "env": {"FIAPX_AGENT_METRICS_PATH": str(metrics_path.resolve())},
    }


def merged_configuration(current: dict[str, Any], agent: dict[str, Any]) -> dict[str, Any]:
    merged = dict(current)
    merged.setdefault("default_mcp_settings", {})
    servers = merged.get("agent_servers")
    if servers is None:
        servers = {}
    if not isinstance(servers, dict):
        raise ValueError("agent_servers deve ser um objeto JSON")
    merged["agent_servers"] = {**servers, AGENT_NAME: agent}
    return merged


def read_configuration(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError("a configuração ACP deve ser um objeto JSON")
    return value


def write_configuration(path: Path, configuration: dict[str, Any]) -> Path | None:
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    os.chmod(path.parent, 0o700)
    previous = path.read_bytes() if path.exists() else None
    payload = (json.dumps(configuration, indent=2, ensure_ascii=False, sort_keys=True) + "\n").encode("utf-8")
    if previous == payload:
        os.chmod(path, 0o600)
        return None

    backup = None
    if previous is not None:
        suffix = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        backup = path.with_name(f"{path.name}.bak-{suffix}")
        shutil.copy2(path, backup)
        os.chmod(backup, 0o600)

    descriptor, temporary_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "wb") as stream:
            stream.write(payload)
            stream.flush()
            os.fsync(stream.fileno())
            os.fchmod(stream.fileno(), 0o600)
        os.replace(temporary_name, path)
    finally:
        if os.path.exists(temporary_name):
            os.unlink(temporary_name)
    return backup


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, default=Path.home() / ".jetbrains" / "acp.json")
    parser.add_argument(
        "--metrics",
        type=Path,
        default=Path.home() / ".local" / "state" / "fiapx" / "codex-agent-metrics.jsonl",
    )
    parser.add_argument("--check", action="store_true", help="valida e mostra a entrada sem alterar o arquivo")
    return parser


def main() -> int:
    args = build_parser().parse_args()
    repo_root = Path(__file__).resolve().parents[2]
    agent = desired_agent(repo_root, args.metrics.expanduser())
    configuration = merged_configuration(read_configuration(args.config.expanduser()), agent)
    if args.check:
        print(json.dumps({"agent": AGENT_NAME, "configuration": configuration}, ensure_ascii=False, sort_keys=True))
        return 0
    backup = write_configuration(args.config.expanduser(), configuration)
    backup_text = str(backup) if backup else "não necessário"
    print(f"Agente '{AGENT_NAME}' configurado; backup: {backup_text}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
