# Track E Standby Watchdog 5min

Heartbeat status:

Line name:
- `全仓摸底诊断线`

Repo:
- `maxlee0218-lgtm/warehouse-rebuild`

Issue / task:
- `warehouse-rebuild#13` completed
- current active running task: `none`

Current task status:
- `standby`

Task heartbeat:
- `inactive`

Standby watchdog:
- `recreated`

Standby watchdog frequency:
- `5 minutes`

Heartbeat automation:
- `available`

Heartbeat configured in client:
- `Yes`

Last heartbeat/report time:
- `2026-04-26T09:11:53Z`

Next heartbeat/report time:
- `2026-04-26T09:16:53Z`

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
- watches only this line: `Yes`
- watches only own task queue: `Yes`
- controls other lines: `No`
- modifies other heartbeat timers: `No`
- stops other automations: `No`

Heartbeat reasonableness check:
- standby frequency appropriate: `Yes`
- reason: `5 minutes is the required floor for idle/no-task polling`
- conflict with other lines: `No`
- risk of being too frequent: `medium`
- risk of being too slow: `low`

If no task:
- must check again within 5 minutes: `Yes`
- standby watchdog remains active: `Yes`

If task completed:
- task heartbeat should stop: `Yes`
- standby watchdog should remain active: `Yes`
- next standby check within 5 minutes: `Yes`

Heartbeat compliance:
- included: `Yes`
- self-identified: `Yes`
- scope-isolated: `Yes`
- standby watchdog preserved: `Yes`

## Standby identity

- line_name: `全仓摸底诊断线`
- repo: `maxlee0218-lgtm/warehouse-rebuild`
- task_queue_labels:
  - `track-e-task`
  - `discovery`
  - `diagnosis`
  - `roadmap`
- task_state_labels:
  - `track-e-running`
  - `track-e-done`
  - `track-e-blocked`
  - `track-e-ready` if later created for this line

## Standby watchdog automation

- automation_id: `standby-watchdog-quancang-modi-zhenduanxian-5min`
- automation_type: `standby_watchdog`
- automation_supported: `available`
- automation_runtime_state: `ACTIVE`
- created_by_this_line_only: `true`
- do_not_modify_other_lines: `true`

## Standby duty

1. Check whether this line has any new Track E ready/running/blocked/correction work.
2. Check whether Coordinator posted new instructions relevant only to this line.
3. If there is a running task for this line, report `running` and do not take a second task.
4. If there is a ready task for this line, report `ready` and do not treat the standby watchdog itself as the task deliverer.
5. If there is no task, remain idle/standby and keep this watchdog active.
6. Never delete this standby watchdog because a task finished.

## Standby vs execution distinction

1. This watchdog is a queue-check mechanism only.
2. A heartbeat status block is status proof, not task deliverable.
3. When the current context is a standby/watchdog/heartbeat巡检 task, this line must not pretend that queue reporting equals task completion.
4. An active execution issue exists only when the issue itself has explicit deliverables such as required outputs, file paths, allowed write directories, completion receipt requirements, or running-state execution instructions.
5. If a future Track E execution issue is opened, that execution issue must produce files / commit / PR / blocked receipt on its own context; the standby watchdog only reports queue state.

## Queue isolation rules

1. Watch only Track E work for `maxlee0218-lgtm/warehouse-rebuild`.
2. Do not manage Track A, Track C, Track D, Track F, or infra queues.
3. Do not delete or pause other lines' heartbeat timers.
4. Do not reuse another line's automation id.
5. Do not let another line's done/blocked/running state stop this watchdog.

## Current interpretation

- previous task heartbeat for `warehouse-rebuild#13` is completed-state only
- standby watchdog is restored as the persistent idle polling mechanism
- task completion does not remove standby watchdog
- current context classification: `standby_watchdog`, not `active_execution_issue`
