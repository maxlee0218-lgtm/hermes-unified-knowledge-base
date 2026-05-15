# Execution WIP Policy

## Purpose

This document defines how work-in-progress is controlled for `warehouse-rebuild`.

## Core rule

Only one issue may be actively executed at a time.

## Label state machine

- `codex-ready`
  - eligible to start
- `codex-running`
  - actively being executed
- `codex-done`
  - completed
- `codex-blocked`
  - blocked, needs follow-up

## WIP constraints

1. If any open issue is labeled `codex-running`, do not start another issue.
2. Do not parallelize issue execution.
3. Do not re-trigger a running issue.
4. Finish, block, or explicitly hand off the current issue before moving on.

## Repository safety

- No production database writes
- No hidden changes outside tracked files
- All conclusions must land in repository files
- Every issue run should leave a run summary in:
  - `audit/ads_sc_xl_13/runs/YYYYMMDD_HHMMSS/00_run_summary.md`

## Handoff requirement

Every completed issue must refresh:

- `handoff/ads_sc_xl_13_handoff_latest.zip`

so the next executor can continue from repository state alone.
