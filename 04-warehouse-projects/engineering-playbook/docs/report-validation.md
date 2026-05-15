# Report Validation Playbook

## Report Debugging Rule

A report issue is not fixed when the SQL runs. It is fixed when the rendered report matches the expected business meaning.

Validate both:

- numeric correctness
- display grain correctness

## Archive Comparison Pattern

Use archive tables as read-only evidence unless the business explicitly asks to repair archives.

Recommended flow:

1. Find latest approved archive batch for the report and period.
2. Reconstruct the proposed new口径 from archive rows.
3. Compare visible columns and totals.
4. Compare row grain after label merging.
5. Use differences to validate current ADS/task logic.

## Merged Bucket Example

For iron-loss reports, when multiple numeric iron loss values should display as one bucket:

- normalize numeric `iron_loss >= 1.01` to `1.01以上`
- group all measures by the display grain
- recompute totals from visible thickness columns only
- check that no numeric `iron_loss >= 1.01` remains
- check that display grain has no duplicates

## Duplicate Grain Check

For any report table, build a duplicate check at the exact display grain:

```sql
SELECT business_date, product_name, display_bucket, COUNT(*) AS row_count
FROM report_source
GROUP BY business_date, product_name, display_bucket
HAVING COUNT(*) > 1;
```

If duplicates appear, inspect hidden columns such as rank, subtype, period, attr, source flag, or task version.

## Total Closure Check

When reports hide some dimensions, totals must be recomputed from visible columns:

```sql
SELECT *
FROM report_source
WHERE ABS(total - (COALESCE(col_a, 0) + COALESCE(col_b, 0) + COALESCE(col_c, 0))) > 0.0001;
```

