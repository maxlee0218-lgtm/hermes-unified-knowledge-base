# DolphinScheduler and DataX Runbook

## Finding The Real Task

Use metadata search instead of guessing from task names:

- Search `t_ds_task_definition.task_params` for table names.
- Join process-task relations to locate workflow definitions.
- Check schedules and release states.
- Check recent task instances for failures, retries, and long-running jobs.

Useful query patterns are stored in the root SQL files of this repository.

## Common Failure Modes

- Task SQL is not idempotent and reruns hit primary-key conflicts.
- Two schedules or manual runs overlap and one clears a table while another is inserting.
- Collation mismatch causes join failures.
- A downstream ADS task starts before upstream DataX/DWD is complete.
- Full-table `UPDATE` or `DELETE` causes locks and slow dashboards.
- Dolphin SQL was updated but old historical snapshots were not refreshed.

## Safer Refresh Pattern

Prefer:

```sql
START TRANSACTION;

DELETE FROM target_table
WHERE business_date >= CURRENT_DATE - INTERVAL 7 DAY;

INSERT INTO target_table (...)
SELECT ...
WHERE business_date >= CURRENT_DATE - INTERVAL 7 DAY;

COMMIT;
```

For append-only identifiers, delete by source keys for the refresh window before insert.

## Task Update Checklist

- Back up the current Dolphin SQL text.
- Validate SQL manually on a small date window.
- Release the new task version.
- Run once manually.
- Check process/task instance status.
- Re-run once if idempotency is part of the fix.
- Compare row counts and totals against baseline.

