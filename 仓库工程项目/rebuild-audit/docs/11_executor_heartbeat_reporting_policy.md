# Executor Heartbeat Reporting Policy

## Purpose

This policy is the shared rule for all warehouse-rebuild executors. Executors must read and follow this file when they claim, run, report, block, or complete any task.

The coordinator must not infer heartbeat configuration from GitHub labels or comments. Each executor must self-report its heartbeat/timer configuration in every report.

## Mandatory rule

Every executor report must include a `Heartbeat status` block.

This applies to:

- automation started reports
- heartbeat reports
- status reports
- blocked reports
- correction reports
- handoff reports
- completion receipts

If the `Heartbeat status` block is missing, the report is incomplete and must be reissued.

## Self-identification rule

Executors must infer their own identity from the current issue title, labels, repository, current task scope, and allowed write paths.

Executors must not ask the user to replace variables.
Executors must not ask the user to resend line names, issue numbers, labels, or heartbeat frequency.
Executors must not use Track A/B/C/D/E/F as the primary identity. Use line names.

## Line identity mapping

Use these line names:

- 数仓重构执行线
- Hermes 执行通道线
- 治理验收线
- 进度看板线
- 全仓摸底诊断线
- GitHub 授权中枢线 / Coordinator Gateway 线

## Recommended heartbeat frequencies

| Line name | Recommended frequency | Notes |
|---|---:|---|
| 数仓重构执行线 | 10 minutes | If the task is only long document generation, 15 minutes is acceptable. If completed, use none. |
| 进度看板线 | 15 minutes | Static dashboard/control-room work should not be too noisy. If completed, use none. |
| 全仓摸底诊断线 | 30 minutes | Large discovery/report task. If completed, use none. |
| GitHub 授权中枢线 / Coordinator Gateway 线 | 20 minutes | If it enters real deployment validation, 10 minutes is acceptable. If completed, use none. |
| 治理验收线 | 30 minutes | If completed, use none. |
| Hermes 执行通道线 | 15–20 minutes | Only when a connector/validation task is actively running. If no running task, do not start a standalone heartbeat. |

## Mandatory Heartbeat status block

Every report must include this block exactly as a section.

```text
Heartbeat status:

Line name:
- <executor inferred line name>

Repo:
- <current repository>

Issue / task:
- <current issue or task>

Current task status:
- running / completed / blocked / pending_execution / unknown

Heartbeat frequency:
- <10 minutes / 15 minutes / 20 minutes / 30 minutes / none because completed / other with reason>

Heartbeat automation:
- available / not available / manual only

Heartbeat configured in client:
- Yes / No / unknown

Last heartbeat/report time:
- <time or unknown>

Next heartbeat/report time:
- <time or none because completed / unknown>

Stop condition:
- <this line's running label removed>
- or <this line's done label added>
- or <this line's blocked label added>

Scope isolation:
- watches only this line: Yes / No
- watches only this issue/task: Yes / No
- controls other lines: No
- modifies other heartbeat timers: No
- stops other automations: No

Heartbeat reasonableness check:
- frequency appropriate: Yes / No
- reason: <why this frequency is appropriate or not>
- conflict with other lines: Yes / No / unknown
- risk of being too frequent: low / medium / high
- risk of being too slow: low / medium / high

If completed:
- heartbeat should stop: Yes
- next heartbeat/report time: none
- timer file should remain as record: Yes

If blocked:
- heartbeat should continue: Yes / No
- reason: <explain>

Heartbeat compliance:
- included: Yes
- self-identified: Yes
- scope-isolated: Yes / No
```

## Isolation rules

1. A heartbeat belongs only to the line that created it.
2. A heartbeat must only watch its own issue/task.
3. Do not read other line timers as stop conditions.
4. Do not stop your heartbeat because another line is done, blocked, or running.
5. Do not delete, overwrite, or reuse another line's timer file.
6. Do not modify another line's issue labels.
7. Do not stop another line's automation.
8. Automation IDs must include the line name and issue/task number.
9. Completed tasks must report `Heartbeat frequency: none because completed`.
10. Blocked tasks must explicitly say whether heartbeat continues.

## Report validity

A report is valid only when it contains:

- task result or progress
- blockers, if any
- next action
- Heartbeat status block

A report that only says `automation started`, `completed`, or `heartbeat available` is incomplete.

## Coordinator usage

The coordinator will evaluate heartbeat reasonableness from the executor's own report, not from hidden client-side timer configuration.

Executors must surface the client-side timer configuration through the mandatory `Heartbeat status` block.
