# Track E Repository Inventory

## Scope verdict

- Repository inspected: `maxlee0218-lgtm/warehouse-rebuild`
- Inspection mode: repository-wide file-tree read + live GitHub issue/PR fact read
- Required paths checked:
  - `README.md`
  - `docs/`
  - `lineage/`
  - `sql/inspect/`
  - `sql/recon/`
  - `sql/rebuild/`
  - `audit/`
  - `handoff/`
  - `governance/`
  - `reviews/`
  - `clarifications/`
  - `docs/progress_dashboard/`
  - `discovery/`
  - `assessments/`
  - `roadmap/`
- Did Track E inspect the whole repository:
  - Yes

## Global registration result

- Only `ADS_SC_XL_13` assets were found in the repository scope inspected.
- Other warehouse domains are `not_found / not_yet_registered`.
- No second warehouse domain is registered under:
  - `lineage/`
  - `sql/inspect/`
  - `sql/recon/`
  - `sql/rebuild/`
  - `audit/`
  - `governance/`
  - `reviews/`
  - `clarifications/`
  - `decision_log/`

## Top-level tree snapshot

| Path | Status | Notes |
| --- | --- | --- |
| `README.md` | exists | repo summary still focused on `ADS_SC_XL_13` |
| `docs/` | exists | 12 repo docs + 1 external project register |
| `docs/progress_dashboard/` | not_found at inspection start | Track D issue exists, but repo outputs are not present yet |
| `lineage/` | exists | only `ads_sc_xl_13/` registered |
| `sql/inspect/` | exists | only `ads_sc_xl_13/` registered |
| `sql/recon/` | exists | only `ads_sc_xl_13/` registered |
| `sql/rebuild/` | exists | only `ads_sc_xl_13/` registered |
| `sql/source/` | exists | source/reference snapshots for `ads_sc_xl_13` only |
| `audit/` | exists | only `ads_sc_xl_13/runs/` registered |
| `handoff/` | exists | single latest handoff zip |
| `governance/` | exists | only `ads_sc_xl_13/` registered |
| `reviews/` | exists | only `ads_sc_xl_13/` registered |
| `clarifications/` | exists | only `ads_sc_xl_13/` registered |
| `decision_log/` | exists | only `ads_sc_xl_13/` registered |
| `discovery/` | not_found at inspection start | created by Track E |
| `assessments/` | not_found at inspection start | created by Track E |
| `roadmap/` | not_found at inspection start | created by Track E |
| `.github/workflows/` | exists | inspected for scope only; untouched by Track E |

## Core asset family counts

| Family | Count | Registration result |
| --- | --- | --- |
| lineage files | 27 | all under `lineage/ads_sc_xl_13/` |
| inspect SQL | 13 | all under `sql/inspect/ads_sc_xl_13/` |
| recon SQL | 14 | all under `sql/recon/ads_sc_xl_13/` |
| rebuild SQL | 9 | all under `sql/rebuild/ads_sc_xl_13/` |
| source/reference SQL | 21 | all under `sql/source/ads_sc_xl_13/` |
| audit files | 32 | all under `audit/ads_sc_xl_13/runs/` |
| handoff packages | 1 | `handoff/ads_sc_xl_13_handoff_latest.zip` |
| governance files | 4 | all under `governance/ads_sc_xl_13/` |
| review files | 1 | `reviews/ads_sc_xl_13/issue_result_matrix.md` |
| clarification files | 1 | `clarifications/ads_sc_xl_13/business_clarification_queue.md` |
| decision log files | 1 | `decision_log/ads_sc_xl_13/decision_log.md` |
| repo docs | 12 | plus 1 external project register |

## ADS_SC_XL_13 file asset snapshot

### Registered lineage cluster

- `lineage/ads_sc_xl_13/00_manifest.md`
- `lineage/ads_sc_xl_13/01_main_chain.md`
- `lineage/ads_sc_xl_13/02_supporting_chains.md`
- `lineage/ads_sc_xl_13/03_dependency_dag.csv`
- `lineage/ads_sc_xl_13/04_dependency_dag.md`
- `lineage/ads_sc_xl_13/05_missing_links.md`
- `lineage/ads_sc_xl_13/06_next_rebuild_order.md`
- `lineage/ads_sc_xl_13/07_acceptance_criteria.md`
- `lineage/ads_sc_xl_13/combined_candidate_readiness.md`
- `lineage/ads_sc_xl_13/combined_candidate_blueprint.md`
- `lineage/ads_sc_xl_13/complete_combined_local_readiness_gate.md`
- `lineage/ads_sc_xl_13/defined_manuf_line_name_validation_plan.md`
- `lineage/ads_sc_xl_13/defined_manuf_line_name_execution_result.md`
- `lineage/ads_sc_xl_13/process1_defined_validation_plan.md`
- `lineage/ads_sc_xl_13/supporting/*.md`
- `lineage/ads_sc_xl_13/diagrams/*.mmd`

### Registered inspect SQL

- `inspect_tables.sql`
- `inspect_supporting_chains.sql`
- `inspect_dim_date_info.sql`
- `inspect_process1_defined_inputs.sql`
- `inspect_defined_manuf_line_name_inputs.sql`
- `inspect_with_attr_value.sql`
- `inspect_with_attr_value_attr1_manuf_line_name.sql`
- `inspect_with_attr_value_warehouse_doc_type.sql`
- `inspect_ads_sc_xl_01_local.sql`
- `inspect_with_result_confirm_local.sql`
- `inspect_total_rows_postprocess.sql`
- `inspect_combined_candidate_inputs.sql`
- `inspect_combined_002.sql`

### Registered recon SQL

- `recon_dim_date_zero_fill.sql`
- `recon_process1_defined_zero_fill.sql`
- `recon_defined_manuf_line_name_aggregation.sql`
- `recon_with_attr_value_mapping.sql`
- `recon_with_attr_value_attr1_manuf_line_name.sql`
- `recon_with_attr_value_warehouse_doc_type.sql`
- `recon_ads_sc_xl_01_local_join.sql`
- `recon_with_result_confirm_local.sql`
- `recon_total_rows_postprocess.sql`
- `recon_combined_candidate_readiness.sql`
- `recon_combined_candidate_blueprint.sql`
- `recon_combined_002.sql`
- `recon_day_weight.sql`
- `recon_missing_rows.sql`

### Registered rebuild SQL

- `00_dim_date_info_local.sql`
- `00_rebuild_order.sql`
- `01_process1.sql`
- `02_defined.sql`
- `02_defined_zero_fill_blueprint.sql`
- `03_defined_manuf_line_name.sql`
- `04_combined.sql`
- `05_combined_001.sql`
- `06_combined_002.sql`

### Registered source/reference SQL

- `00_group_output_source_snapshot.sql`
- `01_process1_source_snapshot.sql`
- `02_defined_source_snapshot.sql`
- `03_defined_manuf_line_name_source_snapshot.sql`
- `04_combined_source_snapshot.sql`
- `05_combined_001_source_snapshot.sql`
- `06_combined_002_source_snapshot.sql`
- `07_prod_actual_source_snapshot.sql`
- `08_enter_item_source_snapshot.sql`
- `09_ads_sc_xl_01_source_snapshot.sql`
- `10_surface_info_source_snapshot.sql`
- day-weight diagnostic/reference files
- `stg_dw__*` snapshot files

## Audit run inventory

| Run ID | Status in repo | Main role |
| --- | --- | --- |
| `20260426_090204` | exists | initial read-only audit, keyword/sql/table inventory, source docs/json |
| `20260426_100453` | exists | issue `#1` support-chain evidence |
| `20260426_104215` | exists | issue `#2/#3` zero-fill evidence |
| `20260426_114418` | exists | issue `#4` aggregation validation plan |
| `20260426_121549` | exists | issue `#5` execution-result template |
| `20260426_132217` | exists | issue `#6` `with_attr_value attr1/manuf_line_name` |
| `20260426_152046` | exists | issue `#7` warehouse/doc-type scene family |
| `20260426_153809` | exists | issue `#8` `ads_sc_xl_01_local` skeleton |
| `20260426_155703` | exists | issue `#9` `with_result_confirm_local` + candidate readiness |
| `20260426_161811` | exists | issue `#12` candidate blueprint + readiness gate |

## Handoff inventory

- `handoff/ads_sc_xl_13_handoff_latest.zip`

## Governance / review / clarification inventory

- Governance:
  - `governance/ads_sc_xl_13/00_governance_overview.md`
  - `governance/ads_sc_xl_13/combined_local_readiness_gate.md`
  - `governance/ads_sc_xl_13/executor_coordination_rules.md`
  - `governance/ads_sc_xl_13/track_c_summary.md`
- Review:
  - `reviews/ads_sc_xl_13/issue_result_matrix.md`
- Clarification:
  - `clarifications/ads_sc_xl_13/business_clarification_queue.md`
- Decision log:
  - `decision_log/ads_sc_xl_13/decision_log.md`

## External-reference inventory

- `docs/external_projects/openclaw-v2-infra-stage07_6.md`
  - repo file exists
  - current content is stale relative to live Stage 8 issue/PR facts read from GitHub
  - Track E records it as evidence, not as current truth source

## Missing directories / missing files

### Directories not found at inspection start

- `docs/progress_dashboard/`
- `discovery/`
- `assessments/`
- `roadmap/`

### Domain registrations not found

- non-`ads_sc_xl_13` folders under `lineage/`
- non-`ads_sc_xl_13` folders under `sql/inspect/`
- non-`ads_sc_xl_13` folders under `sql/recon/`
- non-`ads_sc_xl_13` folders under `sql/rebuild/`
- non-`ads_sc_xl_13` folders under `audit/`
- non-`ads_sc_xl_13` folders under `governance/`
- non-`ads_sc_xl_13` folders under `reviews/`
- non-`ads_sc_xl_13` folders under `clarifications/`

## Duplicate / stale / attention-required items

1. `governance/ads_sc_xl_13/00_governance_overview.md`, `combined_local_readiness_gate.md`, and `track_c_summary.md` were written while issue `#9` was still running; live GitHub now shows `#9` and `#12` already `codex-done`.
2. `reviews/ads_sc_xl_13/issue_result_matrix.md` still records issue `#9` as `in_progress`; live GitHub now shows a completion receipt.
3. `docs/external_projects/openclaw-v2-infra-stage07_6.md` is still a Stage 7.6 register, while live infra facts already include Stage 8 issue `#15` and PR `#17` via receipt on `openclaw-v2-infra#15`.
4. Track D watcher comment points to `docs/progress_dashboard/track_d_30min_heartbeat_timer.md`, but the entire `docs/progress_dashboard/` tree is still `not_found` in the repository.
5. Several recent git commits are generic `Sync Issue #9 artifacts` / `Sync Issue #12 artifacts`; they are valid history, but not strong semantic commit titles for cross-track discovery.

## Current information completeness score

- Score: `medium`
- Why not `low`:
  - the file tree is small and was fully inspected
  - live issue/PR receipts exist for all required fact sources
- Why not `high`:
  - the repository only registers one active warehouse domain
  - many critical support chains remain `partial + pending_execution`
  - some business semantics are intentionally unresolved and must remain `needs_business_clarification`
