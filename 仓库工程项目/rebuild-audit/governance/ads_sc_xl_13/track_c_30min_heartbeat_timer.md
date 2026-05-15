# Track C Governance / Acceptance 执行线 Independent Heartbeat Timer

- line_name: `Track C governance / acceptance 执行线`
- repo: `maxlee0218-lgtm/warehouse-rebuild`
- issue: `#10`
- issue_ref: `warehouse-rebuild#10`
- heartbeat_frequency: `30 minutes`
- running_label: `track-c-running`
- done_label: `track-c-done`
- blocked_label: `track-c-blocked`
- automation_id: `none`
- automation_supported: `available`
- next_heartbeat_at: `stopped`
- created_by_this_line_only: `true`
- do_not_modify_other_lines: `true`
- current_state: `completed`

## Allowed write directories for this line

- `governance/ads_sc_xl_13/`
- `reviews/ads_sc_xl_13/`
- `decision_log/ads_sc_xl_13/`
- `clarifications/ads_sc_xl_13/`

## Stop condition

Stop this line's heartbeat when:

1. `track-c-running` is removed
2. or `track-c-done` is added
3. or `track-c-blocked` is added

Current observed label state:

- labels on issue `#10`:
  - `track-c-task`
  - `governance`
  - `acceptance`
  - `track-c-done`
- `track-c-running` is absent
- this line is already completed, so heartbeat must not be started again

## Heartbeat comment format

```text
Track C governance / acceptance 执行线 heartbeat.

Status:
- running / blocked / completed

Heartbeat frequency:
- 30 minutes

Automation support:
- available / not available / manual only

Current phase:
- governance overview / business clarification queue / combined_local readiness gate / issue result matrix / decision log / executor coordination rules / final summary

Progress since last heartbeat:
- <what changed>

Current blocker:
- <none or exact blocker>

Next 30-minute target:
- <next target>
```

## Scope isolation rules

1. watches only `warehouse-rebuild#10`
2. does not control other lines
3. does not modify other heartbeat timers
4. does not stop other automations
5. does not reuse other lines' automation ids
6. does not write other lines' stop conditions into this timer
7. only stops when this line's own stop condition is met

## Completed-state rule for this task

Because issue `#10` already has `track-c-done`, this file is a completed-state timer record only.

That means:

1. do not re-add `track-c-running`
2. do not create a new running heartbeat loop
3. do not post recurring running heartbeats
4. only record that this line's independent heartbeat has been recognized and is already stopped by label state

## Automatic heartbeat support in this executor

- automation capability exists in this executor
- no active task-heartbeat automation is configured for this completed task
- this line now uses a separate standby watchdog record:
  - `governance/ads_sc_xl_13/track_c_standby_watchdog_5min.md`
- if this issue were still `track-c-running`, this line could use a dedicated task-heartbeat automation id containing the line name and issue number

## Fallback if automatic heartbeat is unavailable

- manual/coordinator follow-up required
- same frequency: `30 minutes`
- only while `track-c-running` is present
