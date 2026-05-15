#!/usr/bin/env python3
"""Lightweight structural health check for llm-wiki.

Checks are intentionally deterministic and local-only:
- required files exist
- wiki pages have YAML frontmatter
- index links point to existing files
- wiki files are referenced by index
- empty files
- obvious sensitive tokens
- raw references in frontmatter point to existing raw files when present
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
WIKI = ROOT / "wiki"
INDEX = WIKI / "index.md"
LOG = WIKI / "log.md"
OVERVIEW = WIKI / "overview.md"

SENSITIVE_PATTERNS = [
    r"(?i)password\s*[:=]",
    r"(?i)passwd\s*[:=]",
    r"(?i)api[_-]?key\s*[:=]",
    r"(?i)secret\s*[:=]",
    r"(?i)token\s*[:=]",
    r"BEGIN .*PRIVATE KEY",
    r"ssh-rsa\s+",
]

LINK_RE = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")
RAW_FRONTMATTER_RE = re.compile(r"(?ms)^---\n(.*?)\n---")
RAW_FIELD_RE = re.compile(r"(?m)^raw:\s*\[(.*?)\]")


def rel(path: Path) -> str:
    try:
        return str(path.relative_to(ROOT)).replace("\\", "/")
    except ValueError:
        return str(path).replace("\\", "/")


def has_frontmatter(text: str) -> bool:
    return text.startswith("---\n") and "\n---" in text[4:]


def parse_index_links() -> set[str]:
    if not INDEX.exists():
        return set()
    links: set[str] = set()
    for _, href in LINK_RE.findall(INDEX.read_text(encoding="utf-8")):
        if href.startswith("http") or href.startswith("#"):
            continue
        links.add(str((WIKI / href).resolve()))
    return links


def extract_raw_refs(text: str) -> list[str]:
    m = RAW_FRONTMATTER_RE.search(text)
    if not m:
        return []
    fm = m.group(1)
    raw_m = RAW_FIELD_RE.search(fm)
    if not raw_m:
        return []
    inner = raw_m.group(1).strip()
    if not inner:
        return []
    return [x.strip().strip('"\'') for x in inner.split(",") if x.strip()]


def run_health() -> dict[str, Any]:
    issues: list[dict[str, str]] = []
    warnings: list[dict[str, str]] = []

    required = [INDEX, LOG, OVERVIEW]
    for path in required:
        if not path.exists():
            issues.append({"severity": "fatal", "type": "missing_required", "path": rel(path)})

    wiki_files = sorted(p for p in WIKI.rglob("*.md") if p.is_file()) if WIKI.exists() else []
    index_links = parse_index_links()

    for path in wiki_files:
        text = path.read_text(encoding="utf-8")
        if not text.strip():
            issues.append({"severity": "fatal", "type": "empty_file", "path": rel(path)})
        if path.name not in {"index.md", "log.md"} and not has_frontmatter(text):
            warnings.append({"severity": "warning", "type": "missing_frontmatter", "path": rel(path)})
        for pattern in SENSITIVE_PATTERNS:
            if re.search(pattern, text):
                issues.append({"severity": "fatal", "type": "possible_secret", "path": rel(path)})
        for raw_ref in extract_raw_refs(text):
            raw_path = (path.parent / raw_ref).resolve() if not raw_ref.startswith("raw/") else (ROOT / raw_ref).resolve()
            if not raw_path.exists():
                warnings.append({"severity": "warning", "type": "missing_raw_ref", "path": rel(path), "ref": raw_ref})

    for path in wiki_files:
        if path.name in {"index.md", "log.md"}:
            continue
        if str(path.resolve()) not in index_links:
            warnings.append({"severity": "warning", "type": "not_in_index", "path": rel(path)})

    if INDEX.exists():
        for _, href in LINK_RE.findall(INDEX.read_text(encoding="utf-8")):
            if href.startswith("http") or href.startswith("#"):
                continue
            target = WIKI / href
            if not target.exists():
                issues.append({"severity": "fatal", "type": "broken_index_link", "path": rel(target)})

    status = "ok" if not issues else "fatal"
    return {
        "status": status,
        "root": str(ROOT),
        "wiki_file_count": len(wiki_files),
        "fatal_count": len(issues),
        "warning_count": len(warnings),
        "issues": issues,
        "warnings": warnings,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", action="store_true", help="print JSON output")
    parser.add_argument("--save", action="store_true", help="save markdown report to wiki/health-report.md")
    args = parser.parse_args()

    result = run_health()
    if args.save:
        report = WIKI / "health-report.md"
        lines = [
            "# Wiki Health Report",
            "",
            f"Status: {result['status']}",
            f"Fatal: {result['fatal_count']}",
            f"Warnings: {result['warning_count']}",
            "",
            "## Fatal Issues",
        ]
        lines.extend(f"- {i}" for i in result["issues"])
        lines.append("\n## Warnings")
        lines.extend(f"- {w}" for w in result["warnings"])
        report.write_text("\n".join(lines) + "\n", encoding="utf-8")

    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print(f"status={result['status']} fatal={result['fatal_count']} warnings={result['warning_count']}")
        for item in result["issues"][:20]:
            print("FATAL", item)
        for item in result["warnings"][:20]:
            print("WARN", item)

    return 0 if result["status"] == "ok" else 1


if __name__ == "__main__":
    raise SystemExit(main())
