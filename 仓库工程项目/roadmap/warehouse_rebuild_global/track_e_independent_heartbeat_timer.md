# Track E Independent Heartbeat Timer

- line_name: `全仓摸底诊断线`
- repo: `maxlee0218-lgtm/warehouse-rebuild`
- issue: `warehouse-rebuild#13`
- heartbeat_frequency: `30 minutes`
- running_label: `track-e-running`
- done_label: `track-e-done`
- blocked_label: `track-e-blocked`
- allowed_write_directory: `roadmap/warehouse_rebuild_global/`
- current_issue_state: `completed`
- current_issue_labels:
  - `track-e-task`
  - `discovery`
  - `diagnosis`
  - `roadmap`
  - `track-e-done`

## Stop condition

- `track-e-running` removed
- or `track-e-done` added
- or `track-e-blocked` added

Current stop-condition match:

- `track-e-done` already present
- result: `heartbeat will not be started again`

## Heartbeat comment format

```text
全仓摸底诊断线 heartbeat.

Issue:
- warehouse-rebuild#13

Current status:
- running / blocked / completed

Current phase:
- repository inventory / asset index / issue matrix / lineage map / blocker diagnosis / roadmap / final summary

Progress since last heartbeat:
- <what changed>

Current blocker:
- <none or exact blocker>

Heartbeat frequency:
- 30 minutes

Heartbeat automation:
- available / not available / manual only

Next 30-minute target:
- <next target>
```

## Scope isolation rules

1. Watch only `warehouse-rebuild#13`.
2. Only use Track E labels:
   - `track-e-running`
   - `track-e-done`
   - `track-e-blocked`
3. Do not read, modify, stop, overwrite, or reuse any other line's heartbeat timer or automation.
4. Do not modify other line labels.
5. Do not stop other automations.
6. Do not reuse another line's automation id.
7. Do not let another line's done/blocked/running state affect this line.

## Timer ownership

- created_by_this_line_only: `true`
- do_not_modify_other_lines: `true`

## Automation state

- automation_supported: `available`
- automation_id: `track-e-issue-13-independent-heartbeat`
- automation_runtime_state: `PAUSED`
- why_no_running_heartbeat:
  - issue already has `track-e-done`
  - this is a completed-state independent timer record
  - automation is intentionally visible but paused
  - per stop condition, heartbeat is not restarted after completion

## Next heartbeat state

- next_heartbeat_at: `none`
- completion_note:
  - task already completed
  - independent heartbeat record created
  - heartbeat not started
