# warehouse-rebuild Migration Receipt

```yaml
source_repo: maxlee0218-lgtm/warehouse-rebuild
source_default_branch: main
source_last_commit: da281b3de068f6a4887725b66f2cab700e567098
source_last_message: add task status file
source_size_kb: 1652
target_path: 05-archives/source-repos/warehouse-rebuild/
migrated_files: 186
skipped_files: 1
total_files: 187
migrated_dirs: 58
```

## Migrated Paths

```
.github/README.md
.github/workflows/codex_issue_runner.yml
README.md
assessments/warehouse_rebuild_global/03_blocker_diagnosis.md
assessments/warehouse_rebuild_global/05_complete_combined_local_entry_criteria.md
assessments/warehouse_rebuild_global/07_global_diagnosis_summary.md
audit/ads_sc_xl_13/execution_evidence_template.md
audit/ads_sc_xl_13/p1_execution_result_fill_in_template.md
audit/ads_sc_xl_13/p1_support_chain_execution_evidence_matrix.md
audit/ads_sc_xl_13/readonly_execution_evidence_ledger.md
audit/ads_sc_xl_13/runs/20260426_090204/00_run_summary.md
audit/ads_sc_xl_13/runs/20260426_090204/02_found_sql_files.md
audit/ads_sc_xl_13/runs/20260426_090204/03_table_inventory.csv
audit/ads_sc_xl_13/runs/20260426_090204/04_recon_summary.md
audit/ads_sc_xl_13/runs/20260426_090204/05_errors.md
audit/ads_sc_xl_13/runs/20260426_090204/source_docs/dolphin-process-chain-18333852605952.md
audit/ads_sc_xl_13/runs/20260426_090204/source_docs/dolphin-process-chain-18334034498304.md
audit/ads_sc_xl_13/runs/20260426_090204/source_docs/dolphin-process-chain-18340742659072.md
audit/ads_sc_xl_13/runs/20260426_090204/source_docs/dolphin-process-chain-18341376834048.md
audit/ads_sc_xl_13/runs/20260426_090204/source_json/dim_ums_tenant_read.json
... and 166 more
```

## Skipped Paths

```
audit/ads_sc_xl_13/runs/20260426_090204/01_keyword_hits.md
```

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
audit/ads_sc_xl_13/runs/20260426_090204/01_keyword_hits.md
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
Files to migrate: 186
Files skipped: 1
Directories: 58
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
