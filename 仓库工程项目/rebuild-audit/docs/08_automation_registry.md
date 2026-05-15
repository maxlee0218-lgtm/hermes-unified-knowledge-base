# Automation Registry

## Purpose

This document records the active automation names, owning tracks, cadences, and collision-avoidance rules.

The operating model is:

```text
User talks to Coordinator only.
Coordinator writes GitHub Issues.
Executors process Issues to completion without midpoint prompts.
Track A and Track B may run in parallel.
Each track remains serial internally.
```

## Active Automations

### Track A Automation

```text
Name: 数仓重构
Repository: maxlee0218-lgtm/warehouse-rebuild
Cadence: every 5 minutes
Role: ADS_SC_XL_13 warehouse lineage / SQL / recon / audit executor
```

Processes issues with labels:

```text
ads-sc-xl-13
codex-task
codex-ready
```

Current label state machine:

```text
codex-ready -> codex-running -> codex-done
codex-ready -> codex-running -> codex-blocked
```

### Track B Automation

```text
Name: 多 Agent 协同
Repository: maxlee0218-lgtm/openclaw-v2-infra
Cadence: every 7 minutes
Role: OpenClaw multi-agent runtime / Model Gateway / readonly database tools executor
```

Processes infrastructure issues / PR tasks with labels:

```text
infra-stage
architecture-review
stage-8
readonly-tools
codex-task
codex-ready
```

Current label state machine:

```text
codex-ready -> codex-running -> codex-done
codex-ready -> codex-running -> codex-blocked
```

## Cadence Staggering Decision

Track A runs every 5 minutes.
Track B runs every 7 minutes.

Reason:

```text
Avoid synchronized polling collisions between the two automations.
Reduce simultaneous GitHub label/comment mutations.
Keep the two tracks independent while preserving per-track serial execution.
```

## Execution Principles

- Track A and Track B may both be active at the same time.
- Track A may have at most one `codex-running` task.
- Track B may have at most one `codex-running` task.
- The same Issue / PR must not be processed by multiple executors.
- Executors must not ask the user whether to continue mid-Issue.
- Executors must complete the current Issue to receipt, or mark it `codex-blocked` with a precise blocker.

## Current State

```text
Track A: connected and active via 数仓重构
Track B: connected and active via 多 Agent 协同, cadence every 7 minutes
```

## Coordinator Rule

The coordinator should not create a next dependent Issue within the same track until the current Issue is `codex-done` or `codex-blocked`.

The coordinator may maintain one active Issue per track if the tracks operate on separate repositories and separate file families.
