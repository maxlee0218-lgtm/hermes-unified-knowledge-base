# Data Warehouse Self-Check Workbench Notes

## Product Direction

A monitoring page should help developers locate problems, not merely decorate status numbers.

Useful pages:

- Overview: failures, running tasks, latest exceptions, open alerts.
- DataX tasks: job status, reader table, primary key, increment field, executor params.
- Dolphin schedules: workflow instances, task instances, log path, retries, host, duration.
- Lineage search: table name to DataX, Dolphin task, governance stage, asset snapshot.
- Governance alerts: severity, pipeline, stage, anomaly type.
- Asset health: row count, delay, zero-row checks, duplicates, nulls, reconciliation.
- Certificate/IHR: business-specific operational view when it belongs in the same monitoring service.

## Backend Design

- Keep health checks unauthenticated if external probes need them.
- Protect pages and APIs with Basic Auth or stronger internal auth.
- Cache expensive status data; do not let the frontend hit production databases every 30 seconds.
- Store recent executions and alerts in SQLite for quick UI reads.
- Add alert fingerprinting to avoid duplicate alert spam.
- Keep retention policies explicit.

## Frontend Design

- Split pages by diagnosis workflow, not by backend table.
- Use right-side drawers for task details so filters are not lost.
- Show raw task parameters and SQL only after authentication.
- Design for empty/offline states; monitoring should still explain what is unavailable.

