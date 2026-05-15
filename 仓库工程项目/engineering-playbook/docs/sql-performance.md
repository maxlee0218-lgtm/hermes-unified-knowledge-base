# SQL Performance and Indexing Notes

## First Questions

- Is the query slow because it scans too much, joins too widely, sorts too much, or waits on locks?
- Is the business logic wrong, or only the execution plan?
- Can the refresh window be narrowed without changing business口径?
- Can a repeated `UPDATE` be replaced by insert-into-temp plus targeted update?

## Index Design Rules

- Start composite indexes with equality filters, then range filters, then join/group fields.
- Avoid adding many broad indexes to hot ODS tables without proof.
- Index temporary or staging tables when they participate in joins.
- For `DELETE WHERE data_date >= ...`, index the date field.
- For report updates, index the exact join grain used between source and target.

## Anti-Patterns Seen Often

- `UPDATE target SET metric = 0` without a date/window filter.
- `DELETE FROM target` for hourly refreshes.
- Joining by display names when stable IDs exist.
- `CASE WHEN target.attr IS NULL THEN 1=1 ELSE target.attr = source.attr END`, which weakens index usage.
- Aggregating at one grain and updating a target table at another grain.
- Hidden dimensions in `GROUP BY` that later cause duplicate report rows.

## Lock-Safe DDL

When supported:

```sql
ALTER TABLE some_table
    ADD INDEX idx_name (col1, col2, col3),
    ALGORITHM=INPLACE,
    LOCK=NONE;
```

Set a short lock wait timeout during emergency index work:

```sql
SET SESSION lock_wait_timeout = 10;
```

If DDL cannot acquire metadata lock quickly, stop and check running sessions instead of repeatedly retrying.

