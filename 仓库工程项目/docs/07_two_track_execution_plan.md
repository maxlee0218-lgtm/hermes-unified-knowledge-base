# Two-Track Multi-Agent Execution Plan

## Purpose

This document defines the current two-track execution model for the warehouse rebuild program.

The goal is to keep the data rebuild track and the multi-agent infrastructure track moving in parallel without mixing responsibilities or blocking each other.

## Fact Sources

Primary data rebuild repository:

```text
maxlee0218-lgtm/warehouse-rebuild
```

External infrastructure / agent runtime repository:

```text
maxlee0218-lgtm/openclaw-v2-infra
```

## Current Strategy

We will proceed with two coordinated tracks:

```text
Track A: ADS_SC_XL_13 warehouse lineage / SQL / recon
Track B: OpenClaw multi-agent runtime / Model Gateway / readonly database tools
```

Track A continues the business data rebuild.
Track B builds the execution substrate that will later support safer database-readonly tools and agent orchestration.

Neither track should block the other unless a cross-track safety boundary is violated.

## Automation Cadence

The Codex automation cadence has been updated to:

```text
Every 5 minutes
```

Operational implications:

- New `codex-ready` issues should be picked up faster.
- Executors must respect the label state machine to avoid duplicate work.
- A task should move from `codex-ready` to `codex-running` before any material work starts.
- Completed tasks must remove `codex-running` and add `codex-done`.
- Blocked tasks must remove `codex-running` and add `codex-blocked`.
- The coordinator should not create another issue that depends on a still-running issue unless the dependency is explicitly non-blocking.

## Track A: Warehouse Rebuild

Repository:

```text
maxlee0218-lgtm/warehouse-rebuild
```

Current ADS_SC_XL_13 status:

- Main chain identified.
- `combined_002` shell is no longer the main issue.
- `dim_date_info` is now reproducible / executable pending validation.
- `defined` zero-fill blueprint exists.
- `process1 -> defined` can proceed.
- `combined_local` is still blocked.

Current blockers:

```text
with_attr_value
with_result_confirm
ads_sc_xl_01
combined total / subtotal rows
```

Current next task:

```text
Issue #3: ADS_SC_XL_13 第 3 轮任务：验证 process1 -> defined 补零链路并收敛 zero-fill 对账
```

Track A must preserve the current SQL safety boundary:

```text
Allowed SQL:
- SELECT
- SHOW
- DESC
- EXPLAIN

Forbidden against production:
- DROP
- DELETE
- UPDATE
- INSERT
- TRUNCATE
- INSERT OVERWRITE
- CREATE TABLE AS
```

## Track B: Multi-Agent Infrastructure

Repository:

```text
maxlee0218-lgtm/openclaw-v2-infra
```

Current status:

```text
Stage 7.6: Align Model Gateway with OpenAI-compatible proxy
PR: maxlee0218-lgtm/openclaw-v2-infra#2
Branch: stage/07_6-model-gateway-proxy-alignment
Commit: 623591e341a19c5f33b6e3bb095c560b6e24736c
Status: open, mergeable, ready for architecture review
```

Stage 7.6 established:

```text
Agent Role Package
-> Model Gateway
-> OpenAI-compatible proxy / relay API
-> Real model provider
```

Track B next task:

```text
Architecture review for Stage 7.6, then Stage 8 database readonly tools.
```

Stage 8 must not introduce write-capable database paths.

## Cross-Track Boundaries

Track A may consume Track B only as infrastructure context.
Track A must not wait for Stage 8 to continue read-only lineage and SQL blueprint work.

Track B must not modify ADS_SC_XL_13 SQL or lineage files unless an issue in `warehouse-rebuild` explicitly requests it.

Shared safety principles:

1. No production database writes.
2. No secret leakage.
3. No direct model credentials in agents.
4. No database tools as side channels for model credentials.
5. No bypass of Model Gateway for model access.
6. No bypass of Tool Gateway for database access.

## Multi-Agent Roles

### Coordinator Agent

Runs from this ChatGPT project.

Responsibilities:

- Maintain cross-repo plan.
- Create GitHub issues.
- Review Codex output.
- Keep durable coordination documents updated.
- Decide whether a stage may advance.

### Warehouse Codex Executor

Runs against `warehouse-rebuild` issues.

Responsibilities:

- Process `codex-task` / `codex-ready` ADS_SC_XL_13 issues.
- Produce lineage docs, inspect SQL, recon SQL, audit summaries, and handoff zip.
- Reply to issues with commit / PR and next suggested node.

### Infrastructure Codex Executor

Runs against `openclaw-v2-infra` issues / PRs.

Responsibilities:

- Advance Model Gateway, agent runtime, and readonly tool architecture.
- Keep infrastructure stages reviewable by PR.
- Preserve model and database safety boundaries.

## Issue Label Protocol

Warehouse issues use:

```text
ads-sc-xl-13
codex-task
codex-ready
codex-running
codex-done
codex-blocked
review-needed
```

Infrastructure issues use:

```text
infra-stage
architecture-review
stage-8
readonly-tools
codex-task
codex-ready
codex-done
codex-blocked
```

## Current Execution Decision

Proceed with both tracks:

```text
Track A: Issue #3 in warehouse-rebuild for process1 -> defined zero-fill validation.
Track B: Architecture review on openclaw-v2-infra#2 and prepare Stage 8 readonly database tools issue after review.
```

## Stop Conditions

Pause automatic advancement if any of the following occur:

1. A task proposes production writes.
2. A task introduces real secrets into GitHub.
3. A task tries to enter `combined_local` before `with_attr_value`, `with_result_confirm`, and `ads_sc_xl_01` are sufficiently closed.
4. Stage 8 proposes write-capable database tooling.
5. OpenClaw runtime changes conflict with the Model Gateway boundary.
