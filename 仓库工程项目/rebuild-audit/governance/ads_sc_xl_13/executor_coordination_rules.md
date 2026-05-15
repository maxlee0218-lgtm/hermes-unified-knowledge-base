# ADS_SC_XL_13 Executor Coordination Rules

## Purpose

This file defines the separation of duties for Track A, Track B, and Track C so that parallel automation does not collide on labels, file families, or issue ownership.

## Track ownership

1. Track A only accepts warehouse execution tasks labeled for `ads-sc-xl-13 + codex-ready`.
2. Track B only accepts infra / Hermes Gateway tasks in `openclaw-v2-infra`.
3. Track C only accepts governance / clarification / acceptance tasks.
4. Track C does not use `codex-ready`, so Track A cannot accidentally claim Track C work.

## Track C label state machine

- `track-c-ready`
- `track-c-running`
- `track-c-done`
- `track-c-blocked`

## Coordination rules

1. Track A only handles warehouse rebuild execution, inspect/recon SQL, and audit evidence.
2. Track B only handles infra-stage, readonly-tools, and Hermes Gateway contract work.
3. Track C only handles governance, clarification, acceptance, readiness, and decision logging.
4. Track C must never switch an issue into `codex-ready`, `codex-running`, or `codex-done`.
5. Each track is serial within itself, even when different tracks operate in parallel.
6. The same issue must never be processed by more than one executor at the same time.
7. Executors must not ask whether to continue mid-task once the issue is accepted inside the safety boundary.
8. If business semantics are unclear, record an exact question in the clarification queue instead of guessing.
9. Every execution result must be written back to the issue as a receipt or blocker comment.
10. Any change outside the issue's write boundary is an overreach and must be reverted before completion.

## Safety consequences

- Track C must not edit:
  - `lineage/ads_sc_xl_13` main chain files
  - `sql/`
  - `audit/` files created by Track A
  - handoff packages
  - `openclaw-v2-infra`
- If GitHub label write fails, retry conservatively and document the exact failure.
- If a dependent issue is still running, mark the dependent governance node as `in_progress` and stop short of inference.
