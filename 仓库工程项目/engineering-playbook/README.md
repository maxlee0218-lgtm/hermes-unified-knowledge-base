# Warehouse Engineering Playbook

This repository stores reusable lessons, runbooks, and SQL investigation patterns from real data warehouse work.

The goal is not to archive secrets or one-off chat history. The goal is to turn hard-won operational experience into safe, repeatable engineering practice.

## What Is Inside

- `docs/playbook.md`: core operating principles for data warehouse debugging and delivery.
- `docs/dolphin-datax.md`: DolphinScheduler and DataX investigation workflow.
- `docs/sql-performance.md`: SQL performance and indexing checklist.
- `docs/report-validation.md`: report data validation and archive comparison workflow.
- `docs/monitoring-workbench.md`: design notes for a data warehouse self-check workbench.
- `docs/case-studies.md`: sanitized case studies from recent work.
- `docs/security-redaction.md`: rules for keeping credentials and sensitive data out of Git.
- `templates/runbook.md`: template for future incidents and changes.

## Safety Rules

- Never commit database passwords, server passwords, tokens, cookies, SSH private keys, or connection strings.
- Prefer private repositories for business table names, report names, and operational SQL.
- Treat historical archive tables as evidence first. Do not repair archive data unless explicitly required.
- Back up affected rows before any destructive data fix.
- Validate both totals and row grain. A total can be correct while the report still has duplicate display rows.

## Working Style

The default workflow is:

1. Reproduce the symptom from the report or task.
2. Locate the physical source tables and task SQL.
3. Compare current output against historical archive or accepted baseline.
4. Identify whether the issue is data, task logic, scheduling, index, or display configuration.
5. Back up the minimal affected scope.
6. Apply the smallest safe fix.
7. Validate row counts, totals, duplicates, labels, and rerun stability.

