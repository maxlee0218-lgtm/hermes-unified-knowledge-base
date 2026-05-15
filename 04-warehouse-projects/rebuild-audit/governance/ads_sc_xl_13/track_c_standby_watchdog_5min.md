# Track C Governance / Acceptance 执行线 Standby Watchdog

- line_name: `Track C governance / acceptance 执行线`
- repo: `maxlee0218-lgtm/warehouse-rebuild`
- issue: `#10 completed; current active task: none`
- heartbeat_frequency: `5 minutes`
- running_label: `track-c-running`
- done_label: `track-c-done`
- blocked_label: `track-c-blocked`
- stop_condition: `only Coordinator explicit stop command; not task completion; not no-task state; not one execution cycle ending`
- created_by_this_line_only: `true`
- do_not_modify_other_lines: `true`
- automation_id: `standby-watchdog-track-c-governance-acceptance-5min`
- automation_supported: `available`
- next_heartbeat_at: `2026-04-26T09:17:22Z`

## Current queue ownership

- watches only Track C governance / acceptance queue in `maxlee0218-lgtm/warehouse-rebuild`
- task identity signals:
  - `track-c-task`
  - `governance`
  - `acceptance`
  - `track-c-ready`
  - `track-c-running`
  - `track-c-blocked`

## Current observed queue state

- issue `#10` exists and is already `track-c-done`
- no open Track C `ready` task found
- no open Track C `running` task found
- no open Track C `blocked` task found
- current executor state: `idle / standby`

## Heartbeat comment format

```text
Heartbeat status:

Line name:
- Track C governance / acceptance 执行线

Repo:
- maxlee0218-lgtm/warehouse-rebuild

Issue / task:
- <current Issue / task / none>

Current task status:
- running / completed / blocked / idle / standby / unknown

Task heartbeat:
- active / inactive / not applicable

Standby watchdog:
- active / inactive / recreated / blocked

Standby watchdog frequency:
- 5 minutes

Heartbeat automation:
- available / not available / manual only

Heartbeat configured in client:
- Yes / No / unknown

Last heartbeat/report time:
- <time or unknown>

Next heartbeat/report time:
- <time or unknown>

Stop condition for task heartbeat:
- current task running label removed
- or current task done label added
- or current task blocked label added

Stop condition for standby watchdog:
- only Coordinator explicit stop command
- not task completion
- not no-task state
- not one execution cycle ending

Scope isolation:
- watches only this line: Yes
- watches only own task queue: Yes
- controls other lines: No
- modifies other heartbeat timers: No
- stops other automations: No

Heartbeat reasonableness check:
- standby frequency appropriate: Yes
- reason: 5 minutes is the required floor for idle/no-task polling
- conflict with other lines: No
- risk of being too frequent: medium
- risk of being too slow: low

If no task:
- must check again within 5 minutes: Yes
- standby watchdog remains active: Yes

If task completed:
- task heartbeat should stop: Yes
- standby watchdog should remain active: Yes
- next standby check within 5 minutes: Yes

Heartbeat compliance:
- included: Yes
- self-identified: Yes
- scope-isolated: Yes
- standby watchdog preserved: Yes
```

## Scope isolation rules

1. watches only this line
2. does not control other lines
3. does not modify other heartbeat timers
4. does not stop other automations
5. does not reuse other lines' automation ids
6. does not stop because the current task is completed
7. remains active while idle

## Standby behavior

1. if a Track C `ready` task appears, immediately take or report it
2. if a Track C `running` task exists, continue that task and do not claim new work
3. if no Track C task needs action, stay `idle / standby`
4. if the watchdog is missing, recreate it immediately
