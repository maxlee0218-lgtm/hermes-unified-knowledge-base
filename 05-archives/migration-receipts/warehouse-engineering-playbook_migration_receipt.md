# warehouse-engineering-playbook Migration Receipt

```yaml
source_repo: maxlee0218-lgtm/warehouse-engineering-playbook
source_default_branch: main
source_last_commit: 62b25f59f4adf1e1b2b74210bb70b16caa66a15a
source_last_message: Add templates/runbook.md
source_size_kb: 32
target_path: 05-archives/source-repos/warehouse-engineering-playbook/
migrated_files: 21
skipped_files: 0
total_files: 21
migrated_dirs: 4
```

## Migrated Paths

```
.gitignore
README.md
SECURITY.md
docs/case-studies.md
docs/dolphin-datax.md
docs/monitoring-workbench.md
docs/playbook.md
docs/report-validation.md
docs/security-redaction.md
docs/sql-performance.md
sql/README.md
sql/xs18/README.md
sql/xs18/find_dolphin_online_schedules_xs18_blockers.sql
sql/xs18/find_dolphin_recent_xs18_blockers.sql
sql/xs18/find_dolphin_xs18_blockers.sql
sql/xs18/validate_xs18_march.sql
sql/xs18/validate_xs18_march_fast.sql
sql/xs18/validate_xs18_march_only_fast.sql
sql/xs18/xs18_index_only.sql
sql/xs18/xs_18_final.sql
... and 1 more
```

## Skipped Paths

None

## Skip Reason

```text
Skipped files matching:
- .git/ directories
- node_modules/
- venv/
- __pycache__/
- .env files
- Files containing 'token', 'secret', 'key', 'password', 'credential'
- Binary files (.pyc, .pyo, .so, .dll, .exe)
```

## Sensitive Files Excluded

```text
None detected
```

## Verification Method

```text
1. File count matches between source and target
2. File tree structure preserved
3. No sensitive files in target
```

## Verification Result

```text
Status: PENDING
Files to migrate: 21
Files skipped: 0
Directories: 4
```

## Can Delete

```yaml
can_delete: pending
reason: Migration not yet verified by GPT
```

## Notes

```text
- This is a raw archive, no curation performed
- Original directory structure preserved
- Content not modified
- Duplicate files not merged
```
