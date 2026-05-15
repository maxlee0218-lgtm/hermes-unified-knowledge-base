#!/usr/bin/env python3
"""Placeholder ingest checker.

Current phase: verify candidate raw/wiki paths before ingest.
"""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
print(f"ingest_check: repository={root}")
print("ingest_check: placeholder; use KNOWLEDGE_BASE_RULES.md and wiki/log.md for phase 1")
