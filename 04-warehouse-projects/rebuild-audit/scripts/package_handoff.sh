#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p handoff
rm -f handoff/ads_sc_xl_13_handoff_latest.zip
zip -r handoff/ads_sc_xl_13_handoff_latest.zip \
  README.md \
  docs \
  lineage \
  sql \
  audit \
  scripts \
  .github >/dev/null
echo "$ROOT/handoff/ads_sc_xl_13_handoff_latest.zip"
