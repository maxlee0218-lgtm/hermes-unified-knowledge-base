# All Detected Assets Index

## Index rules

- Scope: repository assets only
- Domain registration result:
  - only `ads_sc_xl_13` is registered in warehouse asset families
- External repository facts:
  - tracked separately in `01_issue_result_matrix.md`
- Dashboard assets:
  - `docs/progress_dashboard/` is `not_found` at inspection time

## Docs

```text
README.md
docs/00_project_goal.md
docs/01_current_status.md
docs/02_architecture.md
docs/03_rebuild_principles.md
docs/04_codex_cli_handoff.md
docs/05_multi_agent_coordination.md
docs/06_default_github_operating_mandate.md
docs/07_two_track_execution_plan.md
docs/08_automation_registry.md
docs/09_execution_wip_policy.md
docs/10_executor_no_midpoint_prompt_policy.md
docs/external_projects/openclaw-v2-infra-stage07_6.md
```

## Lineage

```text
lineage/ads_sc_xl_13/00_manifest.md
lineage/ads_sc_xl_13/01_main_chain.md
lineage/ads_sc_xl_13/02_supporting_chains.md
lineage/ads_sc_xl_13/03_dependency_dag.csv
lineage/ads_sc_xl_13/04_dependency_dag.md
lineage/ads_sc_xl_13/05_missing_links.md
lineage/ads_sc_xl_13/06_next_rebuild_order.md
lineage/ads_sc_xl_13/07_acceptance_criteria.md
lineage/ads_sc_xl_13/combined_candidate_blueprint.md
lineage/ads_sc_xl_13/combined_candidate_readiness.md
lineage/ads_sc_xl_13/complete_combined_local_readiness_gate.md
lineage/ads_sc_xl_13/defined_manuf_line_name_execution_result.md
lineage/ads_sc_xl_13/defined_manuf_line_name_validation_plan.md
lineage/ads_sc_xl_13/process1_defined_validation_plan.md
lineage/ads_sc_xl_13/diagrams/ads_sc_xl_13_full_dependency.mmd
lineage/ads_sc_xl_13/diagrams/ads_sc_xl_13_main_chain.mmd
lineage/ads_sc_xl_13/diagrams/ads_sc_xl_13_supporting_chains.mmd
lineage/ads_sc_xl_13/diagrams/generated_from_csv.mmd
lineage/ads_sc_xl_13/supporting/ads_sc_xl_01_local_join_skeleton.md
lineage/ads_sc_xl_13/supporting/dim_date_info_local_execution_plan.md
lineage/ads_sc_xl_13/supporting/dim_date_info_rebuild_plan.md
lineage/ads_sc_xl_13/supporting/total_rows_postprocess_impact.md
lineage/ads_sc_xl_13/supporting/total_rows_postprocess_local_plan.md
lineage/ads_sc_xl_13/supporting/with_attr_value_attr1_manuf_line_name_closure.md
lineage/ads_sc_xl_13/supporting/with_attr_value_scene_matrix.md
lineage/ads_sc_xl_13/supporting/with_attr_value_warehouse_doc_type_closure.md
lineage/ads_sc_xl_13/supporting/with_result_confirm_local_closure.md
```

## Inspect SQL

```text
sql/inspect/ads_sc_xl_13/inspect_ads_sc_xl_01_local.sql
sql/inspect/ads_sc_xl_13/inspect_combined_002.sql
sql/inspect/ads_sc_xl_13/inspect_combined_candidate_inputs.sql
sql/inspect/ads_sc_xl_13/inspect_defined_manuf_line_name_inputs.sql
sql/inspect/ads_sc_xl_13/inspect_dim_date_info.sql
sql/inspect/ads_sc_xl_13/inspect_process1_defined_inputs.sql
sql/inspect/ads_sc_xl_13/inspect_supporting_chains.sql
sql/inspect/ads_sc_xl_13/inspect_tables.sql
sql/inspect/ads_sc_xl_13/inspect_total_rows_postprocess.sql
sql/inspect/ads_sc_xl_13/inspect_with_attr_value.sql
sql/inspect/ads_sc_xl_13/inspect_with_attr_value_attr1_manuf_line_name.sql
sql/inspect/ads_sc_xl_13/inspect_with_attr_value_warehouse_doc_type.sql
sql/inspect/ads_sc_xl_13/inspect_with_result_confirm_local.sql
```

## Recon SQL

```text
sql/recon/ads_sc_xl_13/recon_ads_sc_xl_01_local_join.sql
sql/recon/ads_sc_xl_13/recon_combined_002.sql
sql/recon/ads_sc_xl_13/recon_combined_candidate_blueprint.sql
sql/recon/ads_sc_xl_13/recon_combined_candidate_readiness.sql
sql/recon/ads_sc_xl_13/recon_day_weight.sql
sql/recon/ads_sc_xl_13/recon_defined_manuf_line_name_aggregation.sql
sql/recon/ads_sc_xl_13/recon_dim_date_zero_fill.sql
sql/recon/ads_sc_xl_13/recon_missing_rows.sql
sql/recon/ads_sc_xl_13/recon_process1_defined_zero_fill.sql
sql/recon/ads_sc_xl_13/recon_total_rows_postprocess.sql
sql/recon/ads_sc_xl_13/recon_with_attr_value_attr1_manuf_line_name.sql
sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql
sql/recon/ads_sc_xl_13/recon_with_attr_value_warehouse_doc_type.sql
sql/recon/ads_sc_xl_13/recon_with_result_confirm_local.sql
```

## Rebuild SQL

```text
sql/rebuild/ads_sc_xl_13/00_dim_date_info_local.sql
sql/rebuild/ads_sc_xl_13/00_rebuild_order.sql
sql/rebuild/ads_sc_xl_13/01_process1.sql
sql/rebuild/ads_sc_xl_13/02_defined.sql
sql/rebuild/ads_sc_xl_13/02_defined_zero_fill_blueprint.sql
sql/rebuild/ads_sc_xl_13/03_defined_manuf_line_name.sql
sql/rebuild/ads_sc_xl_13/04_combined.sql
sql/rebuild/ads_sc_xl_13/05_combined_001.sql
sql/rebuild/ads_sc_xl_13/06_combined_002.sql
```

## Source / Reference SQL

```text
sql/source/ads_sc_xl_13/00_group_output_source_snapshot.sql
sql/source/ads_sc_xl_13/01_process1_source_snapshot.sql
sql/source/ads_sc_xl_13/02_defined_source_snapshot.sql
sql/source/ads_sc_xl_13/03_defined_manuf_line_name_source_snapshot.sql
sql/source/ads_sc_xl_13/04_combined_source_snapshot.sql
sql/source/ads_sc_xl_13/05_combined_001_source_snapshot.sql
sql/source/ads_sc_xl_13/06_combined_002_source_snapshot.sql
sql/source/ads_sc_xl_13/07_prod_actual_source_snapshot.sql
sql/source/ads_sc_xl_13/08_enter_item_source_snapshot.sql
sql/source/ads_sc_xl_13/09_ads_sc_xl_01_source_snapshot.sql
sql/source/ads_sc_xl_13/10_surface_info_source_snapshot.sql
sql/source/ads_sc_xl_13/ads_sc_xl_13_defined_manuf_line_name_combined_002_local.sql
sql/source/ads_sc_xl_13/dwd_ads_sc_xl_13_day_weight_baseline_di.sql
sql/source/ads_sc_xl_13/dwd_ads_sc_xl_13_day_weight_reconciliation_di.sql
sql/source/ads_sc_xl_13/dwd_ads_sc_xl_13_day_weight_source_di.sql
sql/source/ads_sc_xl_13/dws_ads_sc_xl_13_day_weight_reconciliation_day.sql
sql/source/ads_sc_xl_13/prod-actual-reference-model.sql
sql/source/ads_sc_xl_13/stg_dw__ads_sc_xl_13_defined_manuf_line_name_combined.sql
sql/source/ads_sc_xl_13/stg_dw__ads_sc_xl_13_defined_manuf_line_name_combined_001.sql
sql/source/ads_sc_xl_13/stg_dw__ads_sc_xl_13_defined_manuf_line_name_combined_002.sql
sql/source/ads_sc_xl_13/stg_dw__dwd_mes_mm_task_group_output_xl13.sql
```

## Audit

```text
audit/ads_sc_xl_13/runs/20260426_090204/00_run_summary.md
audit/ads_sc_xl_13/runs/20260426_090204/01_keyword_hits.md
audit/ads_sc_xl_13/runs/20260426_090204/02_found_sql_files.md
audit/ads_sc_xl_13/runs/20260426_090204/03_table_inventory.csv
audit/ads_sc_xl_13/runs/20260426_090204/04_recon_summary.md
audit/ads_sc_xl_13/runs/20260426_090204/05_errors.md
audit/ads_sc_xl_13/runs/20260426_090204/source_docs/dolphin-process-chain-18333852605952.md
audit/ads_sc_xl_13/runs/20260426_090204/source_docs/dolphin-process-chain-18334034498304.md
audit/ads_sc_xl_13/runs/20260426_090204/source_docs/dolphin-process-chain-18340742659072.md
audit/ads_sc_xl_13/runs/20260426_090204/source_docs/dolphin-process-chain-18341376834048.md
audit/ads_sc_xl_13/runs/20260426_090204/source_json/dim_ums_tenant_read.json
audit/ads_sc_xl_13/runs/20260426_090204/source_json/dim_ums_tenant_write.json
audit/ads_sc_xl_13/runs/20260426_090204/source_json/mdm_tenant_read.json
audit/ads_sc_xl_13/runs/20260426_090204/source_json/mdm_tenant_write.json
audit/ads_sc_xl_13/runs/20260426_090204/source_json/ods_fair_ums_tenant_read.json
audit/ads_sc_xl_13/runs/20260426_090204/source_json/ods_fair_ums_tenant_write.json
audit/ads_sc_xl_13/runs/20260426_090204/source_json/ods_mes_ums_tenant_read.json
audit/ads_sc_xl_13/runs/20260426_090204/source_json/ods_mes_ums_tenant_write.json
audit/ads_sc_xl_13/runs/20260426_090204/source_json/surface_info_read.json
audit/ads_sc_xl_13/runs/20260426_090204/source_json/surface_info_write.json
audit/ads_sc_xl_13/runs/20260426_090204/source_json/support-anchor-tables.json
audit/ads_sc_xl_13/runs/20260426_090204/source_json/xl13-chain-evidence.json
audit/ads_sc_xl_13/runs/20260426_090204/source_json/xl13-related-datax-jobs.json
audit/ads_sc_xl_13/runs/20260426_100453/00_run_summary.md
audit/ads_sc_xl_13/runs/20260426_104215/00_run_summary.md
audit/ads_sc_xl_13/runs/20260426_114418/00_run_summary.md
audit/ads_sc_xl_13/runs/20260426_121549/00_run_summary.md
audit/ads_sc_xl_13/runs/20260426_132217/00_run_summary.md
audit/ads_sc_xl_13/runs/20260426_152046/00_run_summary.md
audit/ads_sc_xl_13/runs/20260426_153809/00_run_summary.md
audit/ads_sc_xl_13/runs/20260426_155703/00_run_summary.md
audit/ads_sc_xl_13/runs/20260426_161811/00_run_summary.md
```

## Handoff

```text
handoff/ads_sc_xl_13_handoff_latest.zip
```

## Governance / review / clarification / decision log

```text
governance/ads_sc_xl_13/00_governance_overview.md
governance/ads_sc_xl_13/combined_local_readiness_gate.md
governance/ads_sc_xl_13/executor_coordination_rules.md
governance/ads_sc_xl_13/track_c_summary.md
reviews/ads_sc_xl_13/issue_result_matrix.md
clarifications/ads_sc_xl_13/business_clarification_queue.md
decision_log/ads_sc_xl_13/decision_log.md
```

## Missing asset families

```text
docs/progress_dashboard/ -> not_found
discovery/ -> not_found at inspection start
assessments/ -> not_found at inspection start
roadmap/ -> not_found at inspection start
non-ADS_SC_XL_13 warehouse domain folders -> not_found
```
