# Data Warehouse Engineering Playbook

## Core Principles

- Check data before changing logic. Screenshots are symptoms; source tables are evidence.
- Do not change business logic casually. Optimize shape, indexes, idempotency, and refresh scope first.
- Fix the smallest confirmed scope. Avoid full-history changes unless the defect is proven historical and systematic.
- Archive tables are baselines by default. Use them to compare口径; do not mutate them unless the business asks for archive repair.
- Back up rows before destructive fixes. A tiny backup table is cheap; a bad production delete is expensive.
- Validate row grain as well as totals. Duplicate display rows can survive even when totals are mathematically closed.

## Standard Investigation Flow

1. Capture the symptom: report name, date, filters, screenshot, expected result, actual result.
2. Find the report SQL and physical ADS tables.
3. Query the same scope directly from ADS.
4. Trace upstream Dolphin/DataX tasks and source ODS/DWD tables.
5. Compare with historical archive or a known-good date.
6. Classify the issue:
   - source data missing or duplicated
   - task SQL logic
   - task scheduling overlap
   - non-idempotent refresh
   - index/lock/performance
   - display-layer grouping/order
7. Choose the smallest safe fix.
8. Validate with counts, sums, duplicates, labels, and rerun behavior.

## Production Change Guardrails

- Always know the affected rows before `DELETE` or `UPDATE`.
- Prefer `CREATE TABLE backup AS SELECT ...` for surgical data repair.
- In Dolphin SQL, prefer idempotent window refresh over blind full-table delete.
- For long-running updates, check locks and indexes before retrying.
- If a task is hourly, make sure manual repair will not be overwritten by the next run.

## Validation Checklist

- Total row count before and after.
- Grouped count by tenant/base/product/date/status.
- Sum of key measures before and after.
- Duplicate checks at report display grain.
- Label checks for merged buckets.
- Null/empty checks on dimensions used by joins.
- Sample rows for the exact user-reported case.

