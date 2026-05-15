#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DAG = ROOT / "lineage" / "ads_sc_xl_13" / "03_dependency_dag.csv"


def main() -> None:
    rows = list(csv.DictReader(DAG.open("r", encoding="utf-8-sig")))
    by_target: dict[str, list[dict]] = {}
    for row in rows:
        by_target.setdefault(row["target_table"], []).append(row)
    print(json.dumps(by_target, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
