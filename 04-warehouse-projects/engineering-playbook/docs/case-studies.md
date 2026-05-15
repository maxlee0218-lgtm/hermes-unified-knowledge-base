# Sanitized Case Studies

## Case 1: Report Bucket Merge Created Duplicate Rows

Symptom:

- A report showed two `1.01以上` rows under the same product.

Root cause:

- The visible label was merged, but historical ADS snapshot rows still differed by hidden rank fields.

Fix:

- Validate the exact display grain.
- Back up affected rows.
- Remove only the confirmed historical duplicate residual rows.

Lesson:

- After label merging, always check duplicate rows at the display grain.

## Case 2: Totals Included Hidden Columns

Symptom:

- Visible columns did not add up to the subtotal.

Root cause:

- The total column still included hidden thickness values after the report display was narrowed.

Fix:

- Recompute totals from visible thickness columns only.
- Validate total closure for each affected source table.

Lesson:

- Business users read what is visible. Hidden dimensions must not silently affect displayed subtotals.

## Case 3: Slow Monthly Refresh

Symptom:

- A monthly metric refresh was slow and appeared blocked.

Root cause candidates:

- Full-table updates.
- Missing indexes on date and join grain.
- Large joins from ODS/DWD without staging.

Safer approach:

- Add targeted indexes on refresh window and join keys.
- Refresh only the rolling window if business allows.
- Stage aggregates before updating the combined ADS table.

Lesson:

- Do not start by changing logic. First remove avoidable scans and lock-heavy writes.

## Case 4: Dolphin Task Fails Repeatedly

Symptom:

- A workflow failed almost every hour.

Root cause candidates:

- Non-idempotent insert.
- Primary-key conflict on rerun.
- Collation mismatch across joined tables.
- One-to-many join expansion.

Safer approach:

- Delete refresh-window keys before insert.
- Join by stable IDs instead of names.
- Normalize collation only where needed.
- Deduplicate source dimensions before joining.

Lesson:

- Hourly tasks must be idempotent. If a second run can corrupt or fail, the task is not production-safe.

