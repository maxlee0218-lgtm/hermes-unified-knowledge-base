#!/usr/bin/env python3
"""Process Multica runtime command files.

This is a deliberately small, auditable gateway. It defaults to dry-run. A
real issue can only be created in approved mode with an explicit confirmation
marker. It renders selected `multica issue ...` commands and never runs
arbitrary shell commands.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import time
from pathlib import Path
from typing import Any


SUPPORTED_TYPES = {"create_issue", "update_issue_status", "add_issue_comment"}
VALID_MODES = {"dry_run", "approved"}
APPROVAL_MARKER = "APPROVED_CREATE_ISSUE"
FORBIDDEN_TYPES = {
    "modify_production_db",
    "modify_dolphin",
    "modify_datax",
    "delete_files",
    "force_push",
    "expose_secrets",
}
SAFE_ID_RE = re.compile(r"^[A-Za-z0-9_.-]+$")
SECRET_PATTERNS = [
    (re.compile(r"sk-[A-Za-z0-9_-]{12,}"), "***"),
    (re.compile(r"(?i)((token|secret|password|passwd|api[_-]?key)\s*[:=]\s*)[^\s,;]+"), r"\1***"),
    (re.compile(r"(?i)(postgres|mysql|mongodb|redis)://[^\s]+"), "***"),
]


def decode_process_output(data: bytes | str | None) -> str:
    if data is None:
        return ""
    if isinstance(data, str):
        return data
    return data.decode("utf-8", errors="replace")


def timestamp() -> str:
    return time.strftime("%Y-%m-%d %H:%M:%S")


def redact(value: Any) -> Any:
    if isinstance(value, str):
        out = value
        for pattern, repl in SECRET_PATTERNS:
            out = pattern.sub(repl, out)
        return out
    if isinstance(value, list):
        return [redact(item) for item in value]
    if isinstance(value, dict):
        return {key: redact(item) for key, item in value.items()}
    return value


def parse_scalar(raw: str) -> Any:
    raw = raw.strip()
    if raw == "":
        return ""
    if raw in {"true", "false"}:
        return raw == "true"
    if (raw.startswith('"') and raw.endswith('"')) or (raw.startswith("'") and raw.endswith("'")):
        return raw[1:-1]
    return raw


def parse_simple_yaml(text: str) -> dict[str, Any]:
    """Parse the narrow YAML shape used by command files.

    PyYAML is used when available. This fallback keeps the gateway runnable on
    minimal hosts and supports top-level scalars, lists, and literal blocks.
    """

    lines = text.splitlines()
    data: dict[str, Any] = {}
    i = 0
    while i < len(lines):
        line = lines[i]
        i += 1
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if line.startswith((" ", "\t")):
            raise ValueError(f"unexpected indented line outside a block: {line!r}")
        if ":" not in line:
            raise ValueError(f"invalid YAML line: {line!r}")

        key, raw = line.split(":", 1)
        key = key.strip()
        raw = raw.strip()
        if not key:
            raise ValueError(f"empty key in line: {line!r}")

        if raw == "|":
            block: list[str] = []
            while i < len(lines):
                nxt = lines[i]
                if nxt and not nxt.startswith((" ", "\t")):
                    break
                block.append(nxt[2:] if nxt.startswith("  ") else nxt.lstrip("\t"))
                i += 1
            data[key] = "\n".join(block).rstrip() + ("\n" if block else "")
            continue

        if raw == "":
            values: list[Any] = []
            while i < len(lines):
                nxt = lines[i]
                stripped = nxt.strip()
                if not stripped:
                    i += 1
                    continue
                if not nxt.startswith((" ", "\t")):
                    break
                if not stripped.startswith("- "):
                    raise ValueError(f"expected list item under {key!r}: {nxt!r}")
                values.append(parse_scalar(stripped[2:]))
                i += 1
            data[key] = values
            continue

        data[key] = parse_scalar(raw)

    return data


def load_command(path: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8")
    try:
        import yaml  # type: ignore

        loaded = yaml.safe_load(text)
        if not isinstance(loaded, dict):
            raise ValueError("YAML root must be a mapping")
        return loaded
    except ModuleNotFoundError:
        return parse_simple_yaml(text)


def ensure_dirs(root: Path) -> dict[str, Path]:
    dirs = {
        "pending": root / "pending",
        "running": root / "running",
        "done": root / "done",
        "failed": root / "failed",
    }
    for path in dirs.values():
        path.mkdir(parents=True, exist_ok=True)
    return dirs


def resolve_multica_bin() -> str | None:
    env_bin = os.environ.get("MULTICA_BIN")
    if env_bin:
        return env_bin
    candidates = [
        shutil.which("multica"),
        str(Path.home() / ".multica" / "bin" / "multica.exe"),
        r"C:\Users\39169\.multica\bin\multica.exe",
        r"C:\Users\hermes\.multica\bin\multica.exe",
    ]
    for candidate in candidates:
        if candidate and Path(candidate).exists():
            return candidate
    return "multica"


def run_multica_help(multica_bin: str | None) -> tuple[str, str | None]:
    if not multica_bin:
        return "", "multica CLI not found; set MULTICA_BIN or add multica to PATH"
    if not shutil.which(multica_bin) and not Path(multica_bin).exists():
        return "", f"multica CLI not runnable at {multica_bin!r}; rendering with generic flags"
    cp = subprocess.run(
        [multica_bin, "issue", "create", "--help"],
        capture_output=True,
        timeout=30,
        check=False,
    )
    help_text = decode_process_output(cp.stdout) + decode_process_output(cp.stderr)
    if cp.returncode != 0:
        return help_text, f"multica issue create --help exited with {cp.returncode}"
    return help_text, None


def help_supports(help_text: str, flag: str) -> bool:
    return bool(help_text and re.search(rf"(^|\s){re.escape(flag)}([\s,=]|$)", help_text))


def command_id_for(data: dict[str, Any], source: Path) -> str:
    command_id = str(data.get("command_id") or source.stem).strip()
    if not command_id:
        raise ValueError("command_id is required")
    if not SAFE_ID_RE.match(command_id):
        raise ValueError(f"unsafe command_id: {command_id!r}")
    return command_id


def validate(data: dict[str, Any]) -> tuple[str, str, list[str]]:
    mode = str(data.get("mode") or "dry_run").strip()
    if mode not in VALID_MODES:
        raise ValueError(f"invalid mode: {mode}; expected one of {sorted(VALID_MODES)}")

    command_type = str(data.get("type") or "").strip()
    if command_type in FORBIDDEN_TYPES:
        raise ValueError(f"production command type is forbidden: {command_type}")
    if command_type not in SUPPORTED_TYPES:
        raise ValueError(f"unsupported command type: {command_type}")

    warnings: list[str] = []
    workspace = str(data.get("workspace") or "default").strip()
    if workspace not in {"default", "lee"}:
        raise ValueError(f"workspace is not allowlisted for this gateway: {workspace}")

    if mode == "approved":
        if command_type != "create_issue":
            raise ValueError("mode=approved is currently allowlisted only for type=create_issue")
        approval = str(data.get("approval") or data.get("confirm") or "").strip()
        approved_by = str(data.get("approved_by") or "").strip()
        if approval != APPROVAL_MARKER:
            raise ValueError(
                f"mode=approved requires approval: {APPROVAL_MARKER}"
            )
        if not approved_by:
            raise ValueError("mode=approved requires approved_by")

    forbidden_actions = set(data.get("forbidden_actions") or [])
    matched = sorted(forbidden_actions & FORBIDDEN_TYPES)
    if matched:
        warnings.append(
            "forbidden_actions records safety boundaries and is not executed: "
            + ", ".join(matched)
        )

    return mode, command_type, warnings


def build_create_issue_command(
    data: dict[str, Any], help_text: str, multica_bin: str
) -> tuple[list[str], str | None, list[str]]:
    warnings: list[str] = []
    stdin_text: str | None = None
    title = str(data.get("title") or "").strip()
    if not title:
        raise ValueError("title is required for create_issue")

    argv = [multica_bin, "issue", "create", "--title", title]

    body = str(data.get("body") or "")
    if body:
        if help_supports(help_text, "--description-stdin"):
            argv.append("--description-stdin")
            stdin_text = body
        elif help_supports(help_text, "--description"):
            argv.extend(["--description", body])
        elif not help_text:
            argv.extend(["--description", body])
        else:
            warnings.append("body omitted because CLI help did not advertise description flags")

    assignee = data.get("assignee")
    if assignee:
        if not help_text or help_supports(help_text, "--assignee"):
            argv.extend(["--assignee", str(assignee)])
        else:
            warnings.append("assignee omitted because CLI help did not advertise --assignee")

    assignee_id = data.get("assignee_id")
    if assignee_id:
        if assignee:
            raise ValueError("assignee and assignee_id are mutually exclusive")
        if not help_text or help_supports(help_text, "--assignee-id"):
            argv.extend(["--assignee-id", str(assignee_id)])
        else:
            warnings.append("assignee_id omitted because CLI help did not advertise --assignee-id")

    project = data.get("project") or data.get("project_id")
    if project:
        if not help_text or help_supports(help_text, "--project"):
            argv.extend(["--project", str(project)])
        else:
            warnings.append("project omitted because CLI help did not advertise --project")

    priority = data.get("priority")
    if priority:
        if not help_text or help_supports(help_text, "--priority"):
            argv.extend(["--priority", str(priority)])
        else:
            warnings.append("priority omitted because CLI help did not advertise --priority")

    status = data.get("status")
    if status:
        if not help_text or help_supports(help_text, "--status"):
            argv.extend(["--status", str(status)])
        else:
            warnings.append("status omitted because CLI help did not advertise --status")

    labels = data.get("labels") or []
    if labels:
        warnings.append("labels retained in audit JSON only; multica issue create help has no label flag")

    if not help_text or help_supports(help_text, "--output"):
        argv.extend(["--output", "json"])

    return argv, stdin_text, warnings


def build_update_issue_status_command(data: dict[str, Any], multica_bin: str) -> tuple[list[str], None, list[str]]:
    warnings: list[str] = []
    issue = str(data.get("issue") or data.get("issue_id") or data.get("identifier") or "").strip()
    target_status = str(data.get("target_status") or data.get("status") or "").strip()
    if not issue:
        raise ValueError("issue is required for update_issue_status")
    if not target_status:
        raise ValueError("target_status is required for update_issue_status")
    argv = [multica_bin, "issue", "update", issue, "--status", target_status, "--output", "json"]
    if data.get("reason"):
        warnings.append("reason retained in audit JSON only; status command has no reason flag")
    return argv, None, warnings


def build_add_issue_comment_command(data: dict[str, Any], multica_bin: str) -> tuple[list[str], str | None, list[str]]:
    issue = str(data.get("issue") or data.get("issue_id") or data.get("identifier") or "").strip()
    content = str(data.get("content") or data.get("comment") or data.get("body") or "").strip()
    if not issue:
        raise ValueError("issue is required for add_issue_comment")
    if not content:
        raise ValueError("content/comment is required for add_issue_comment")
    argv = [multica_bin, "issue", "comment", "add", issue, "--content-stdin", "--output", "json"]
    return argv, content, []


def build_command(
    command_type: str, data: dict[str, Any], help_text: str, multica_bin: str
) -> tuple[list[str], str | None, list[str]]:
    if command_type == "create_issue":
        return build_create_issue_command(data, help_text, multica_bin)
    if command_type == "update_issue_status":
        return build_update_issue_status_command(data, multica_bin)
    if command_type == "add_issue_comment":
        return build_add_issue_comment_command(data, multica_bin)
    raise ValueError(f"unsupported command type: {command_type}")


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.write_text(json.dumps(redact(payload), ensure_ascii=False, indent=2), encoding="utf-8")


def load_existing_result(path: Path) -> dict[str, Any] | None:
    if not path.exists():
        return None
    try:
        loaded = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None
    return loaded if isinstance(loaded, dict) else None


def execute_command(argv: list[str], stdin_text: str | None) -> tuple[int, str, str]:
    stdin_bytes = stdin_text.encode("utf-8") if stdin_text is not None else None
    cp = subprocess.run(
        argv,
        input=stdin_bytes,
        capture_output=True,
        timeout=60,
        check=False,
    )
    return cp.returncode, decode_process_output(cp.stdout), decode_process_output(cp.stderr)


def find_existing_issue_by_title(multica_bin: str, title: str) -> dict[str, Any] | None:
    rc, stdout, _stderr = execute_command(
        [multica_bin, "issue", "list", "--limit", "100", "--output", "json"],
        None,
    )
    if rc != 0:
        return None
    try:
        payload = json.loads(stdout)
    except json.JSONDecodeError:
        return None
    issues = payload.get("issues") if isinstance(payload, dict) else payload
    if not isinstance(issues, list):
        return None
    for issue in issues:
        if isinstance(issue, dict) and issue.get("title") == title:
            return issue
    return None


def process_one(path: Path, dirs: dict[str, Path], multica_bin: str | None, help_text: str) -> dict[str, Any]:
    data = load_command(path)
    command_id = command_id_for(data, path)
    mode, command_type, warnings = validate(data)
    out = dirs["done"] / f"{command_id}.json"
    existing = load_existing_result(out)
    if existing:
        return {
            "command_id": command_id,
            "source": str(path),
            "status": "already_processed",
            "created_issue": existing.get("created_issue", False),
            "executed": existing.get("executed", False),
            "result_path": str(out),
        }

    running_copy = dirs["running"] / path.name
    if not running_copy.exists():
        shutil.copy2(path, running_copy)

    if not multica_bin:
        raise ValueError("multica CLI not found; cannot render a target-specific command")

    argv, stdin_text, command_warnings = build_command(command_type, data, help_text, multica_bin)
    warnings.extend(command_warnings)
    rendered = " ".join(shlex.quote(part) for part in argv)

    result: dict[str, Any] = {
        "command_id": command_id,
        "source": str(path),
        "mode": mode,
        "type": command_type,
        "status": "dry_run_rendered" if mode == "dry_run" else "approved_pending_execution",
        "created_issue": False,
        "executed": False,
        "rendered_command": rendered,
        "argv": argv,
        "stdin_preview": stdin_text,
        "issue": data.get("issue") or data.get("issue_id") or data.get("identifier"),
        "target_status": data.get("target_status") or data.get("status"),
        "comment_preview": data.get("content") or data.get("comment"),
        "labels": data.get("labels") or [],
        "warnings": warnings,
        "timestamp": timestamp(),
    }

    if mode == "approved":
        if command_type == "create_issue":
            title = str(data.get("title") or "").strip()
            existing_issue = find_existing_issue_by_title(multica_bin, title)
            if existing_issue:
                result["status"] = "issue_already_exists"
                result["created_issue"] = False
                result["executed"] = False
                result["existing_issue"] = existing_issue
                result["warnings"].append(
                    "matching issue title already exists; skipped create to preserve idempotency"
                )
                write_json(out, result)
                return result | {"result_path": str(out)}

        rc, stdout, stderr = execute_command(argv, stdin_text)
        result["executed"] = True
        result["returncode"] = rc
        result["stdout"] = stdout
        result["stderr"] = stderr
        if rc != 0:
            result["status"] = "failed"
            failed_out = dirs["failed"] / f"{command_id}.json"
            write_json(failed_out, result)
            raise ValueError(f"multica command failed with exit code {rc}")
        result["status"] = "issue_created" if command_type == "create_issue" else "command_executed"
        result["created_issue"] = command_type == "create_issue"
        try:
            result["command_result_json"] = json.loads(stdout)
        except json.JSONDecodeError:
            result["command_result_json"] = None

    write_json(out, result)
    return result | {"result_path": str(out)}


def process_all(root: Path) -> int:
    dirs = ensure_dirs(root)
    multica_bin = resolve_multica_bin()
    help_text, help_error = run_multica_help(multica_bin)
    rc = 0

    pending_files = [
        path
        for path in sorted(dirs["pending"].glob("*.yaml"))
        if not path.name.startswith(".") and not path.name.startswith("._")
    ]

    for path in pending_files:
        try:
            result = process_one(path, dirs, multica_bin, help_text)
            if help_error:
                print(f"{path.name}: dry_run_rendered with warning -> {help_error}")
            else:
                print(f"{path.name}: {result['status']} -> {result['result_path']}")
        except Exception as exc:
            rc = 1
            error_payload = {
                "command_id": path.stem,
                "source": str(path),
                "status": "failed",
                "error": str(exc),
                "timestamp": timestamp(),
            }
            out = dirs["failed"] / f"{path.stem}.json"
            write_json(out, error_payload)
            print(f"{path.name}: failed -> {exc}", file=sys.stderr)

    return rc


def default_root() -> Path:
    return Path(__file__).resolve().parent


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except AttributeError:
        pass
    parser = argparse.ArgumentParser(description="Process Multica runtime command files")
    parser.add_argument("--root", type=Path, default=default_root(), help="runtime-commands root")
    args = parser.parse_args()
    return process_all(args.root)


if __name__ == "__main__":
    raise SystemExit(main())
