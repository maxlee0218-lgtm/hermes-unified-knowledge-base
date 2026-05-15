# Track E 30-Minute Heartbeat Timer

- interval: `30 minutes`
- issue: `warehouse-rebuild#13`
- track: `Track E`
- status labels:
  - `track-e-running`
  - `track-e-done`
  - `track-e-blocked`

## Automatic heartbeat support

- supported in this executor: `Yes`
- active automation id:
  - `track-e-warehouse-rebuild-13-heartbeat`
- schedule contract:
  - while `track-e-running` remains present and neither `track-e-done` nor `track-e-blocked` is present, the executor may post heartbeat comments every 30 minutes

## Heartbeat message format

```text
Track E heartbeat.

Status:
- running / blocked / completed

Current phase:
- repository inventory / issue matrix / lineage map / blocker diagnosis / roadmap / final summary

Progress since last heartbeat:
- <what changed>

Current blocker:
- <none or exact blocker>

Next 30-minute target:
- <next target>
```

## What to check every 30 minutes

1. Does issue `#13` still have label `track-e-running`?
2. Has `track-e-done` or `track-e-blocked` been added?
3. What phase is Track E currently in?
4. What changed since the prior heartbeat?
5. Is there an exact blocker, or is the work still moving?
6. What is the next 30-minute target?

## When to stop heartbeats

Stop immediately when any of these is true:

1. `track-e-running` is removed
2. `track-e-done` is added
3. `track-e-blocked` is added

## How to report blocked status

1. remove `track-e-running`
2. add `track-e-blocked`
3. post a GitHub issue comment with the exact blocker
4. stop heartbeat comments

## How to report completed status

1. remove `track-e-running`
2. add `track-e-done`
3. post the Track E completion receipt
4. stop heartbeat comments

## Fallback if automatic heartbeat is unavailable

- fallback mode:
  - coordinator/manual follow-up every 30 minutes using the same heartbeat format
- no workaround allowed:
  - no GitHub Actions
  - no external service
  - no background daemon

## Current Track E interpretation

- heartbeat automation is available in this executor
- this file is still the source-of-truth schedule contract for Track E coordination
