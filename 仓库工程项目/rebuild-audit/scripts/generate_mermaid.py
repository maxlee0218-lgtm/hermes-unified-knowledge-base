#!/usr/bin/env python3
from __future__ import annotations

import csv
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DAG = ROOT / "lineage" / "ads_sc_xl_13" / "03_dependency_dag.csv"
OUT = ROOT / "lineage" / "ads_sc_xl_13" / "diagrams" / "generated_from_csv.mmd"


def main() -> None:
    rows = list(csv.DictReader(DAG.open("r", encoding="utf-8-sig")))
    lines = ["flowchart TD"]
    for row in rows:
      source = row["source_table_or_cte"].replace('"', "'")
      target = row["target_table"].replace('"', "'")
      lines.append(f'  "{source}" --> "{target}"')
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(OUT)


if __name__ == "__main__":
    main()
