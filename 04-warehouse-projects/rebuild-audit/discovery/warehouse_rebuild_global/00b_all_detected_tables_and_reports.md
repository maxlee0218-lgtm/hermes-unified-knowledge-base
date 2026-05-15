# All Detected Tables And Reports

## Counting rule

- Counted objects:
  - warehouse domains
  - named report / table layers
  - named support / upstream tables explicitly evidenced in repo files
  - named pending local reconstruction targets
- Total detected table/report/domain assets:
  - `36`

## Global result

- Only `ADS_SC_XL_13` assets were found in the repository scope inspected.
- Was `ADS_SC_XL_13` the only detected active domain:
  - Yes
- What non-`ADS_SC_XL_13` domains were detected:
  - `not_found`

## Domain and main-chain assets

| Name | Category | Path | Asset type | Reconstruction status | Inspect | Recon | Rebuild | Audit | Linked issue | State flags |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `ADS_SC_XL_13` | domain/report | `lineage/ads_sc_xl_13/` | lineage | active case study; full rebuild not closed | Yes | Yes | Yes | Yes | Yes (`#1-#3`, `#6-#12`) | `active`, `partial`, `pending_execution`, `blocked_for_complete_combined_local` |
| `dwd_mes_mm_task_group_output` | table | `lineage/ads_sc_xl_13/01_main_chain.md` | lineage | source anchored; downstream blueprint available | No | No | No | Yes | Yes (`#1-#3`) | `known_source`, `not_closed` |
| `ads_sc_xl_13_process1` | table | `sql/rebuild/ads_sc_xl_13/01_process1.sql` | rebuild SQL | blueprint ready; execution pending | Yes | Yes | Yes | Yes | Yes (`#3`) | `pending_execution` |
| `ads_sc_xl_13_defined` | table | `sql/rebuild/ads_sc_xl_13/02_defined.sql` | rebuild SQL | zero-fill blueprint ready; execution pending | Yes | Yes | Yes | Yes | Yes (`#2`, `#3`) | `pending_execution` |
| `ads_sc_xl_13_defined_manuf_line_name` | table | `sql/rebuild/ads_sc_xl_13/03_defined_manuf_line_name.sql` | rebuild SQL | aggregation validation prepared; execution pending | Yes | Yes | Yes | Yes | Yes (repo run summaries cite `#4/#5`) | `pending_execution` |
| `ads_sc_xl_13_defined_manuf_line_name_combined` | table | `sql/rebuild/ads_sc_xl_13/04_combined.sql` | rebuild SQL | core blocker layer; partial only | Yes | Yes | Yes | Yes | Yes (`#9`, `#12`) | `partial`, `pending_execution`, `blocked_for_complete_combined_local` |
| `ads_sc_xl_13_defined_manuf_line_name_combined_001` | report table | `sql/rebuild/ads_sc_xl_13/05_combined_001.sql` | rebuild SQL | downstream shell archived; depends on combined closure | No | Yes | Yes | Yes | Yes (`#12`) | `pending_execution`, `upstream_blocked` |
| `ads_sc_xl_13_defined_manuf_line_name_combined_002` | report table | `sql/rebuild/ads_sc_xl_13/06_combined_002.sql` | rebuild SQL | terminal projection archived; upstream dependent | Yes | Yes | Yes | Yes | Yes (`#12`) | `pending_execution`, `upstream_blocked` |

## Support and upstream assets

| Name | Category | Path | Asset type | Reconstruction status | Inspect | Recon | Rebuild | Audit | Linked issue | State flags |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `with_attr_value` | support/config table | `lineage/ads_sc_xl_13/02_supporting_chains.md` | lineage | scene-family evidence only; not globally closed | Yes | Yes | No | Yes | Yes (`#1`, `#6`, `#7`) | `partial`, `pending_execution`, `needs_business_clarification`, `blocks_complete_combined_local` |
| `with_result_confirm` | support/confirm table | `lineage/ads_sc_xl_13/supporting/with_result_confirm_local_closure.md` | lineage | structural closure known; not executed | Yes | Yes | No | Yes | Yes (`#9`) | `partial`, `pending_execution`, `needs_business_clarification`, `blocks_complete_combined_local` |
| `dim_date_info` | support/date spine table | `lineage/ads_sc_xl_13/supporting/dim_date_info_rebuild_plan.md` | lineage | rebuildable; execution pending | Yes | Yes | Yes | Yes | Yes (`#1`, `#2`) | `pending_execution` |
| `ads_sc_xl_01` | support/inbound table | `lineage/ads_sc_xl_13/supporting/ads_sc_xl_01_local_join_skeleton.md` | lineage | join skeleton ready; not executed | Yes | Yes | No | Yes | Yes (`#7`, `#8`) | `partial`, `pending_execution`, `blocks_complete_combined_local` |
| `dwd_silicon_steel_surface_info` | support dimension table | `lineage/ads_sc_xl_13/02_supporting_chains.md` | lineage | source chain anchored; no local rebuild package | No | No | No | Yes | Yes (`#1`, `#6`, `#7`) | `known_source`, `not_closed` |
| `dwd_mes_wms_wh_enter_item` | upstream fact table | `sql/source/ads_sc_xl_13/08_enter_item_source_snapshot.sql` | source SQL | source snapshot only | Yes | Yes | No | Yes | Yes (`#7`, `#8`) | `source_anchor` |
| `dwd_task_prod_actual` | upstream fact table | `sql/source/ads_sc_xl_13/07_prod_actual_source_snapshot.sql` | source SQL | source snapshot only | No | No | No | Yes | Yes (repo evidence) | `source_anchor` |
| `ods_mes_mm_task_group_output` | upstream ODS table | `sql/source/ads_sc_xl_13/00_group_output_source_snapshot.sql` | source SQL | source snapshot only | No | No | No | Yes | Yes (repo evidence) | `source_anchor` |
| `ods_mes_mm_task_prod_actual` | upstream ODS table | `lineage/ads_sc_xl_13/01_main_chain.md` | lineage | source anchor only | No | No | No | Yes | Yes (repo evidence) | `source_anchor` |
| `ods_mes_sys_attr_value` | upstream ODS table | `sql/source/ads_sc_xl_13/10_surface_info_source_snapshot.sql` | source SQL | indirect config source only | No | No | No | Yes | Yes (`#1`, `#6`) | `partial_source_anchor` |
| `ods_mes_ums_tenant` | upstream ODS table | `lineage/ads_sc_xl_13/02_supporting_chains.md` | lineage | tenant-chain anchor only | No | No | No | Yes | Yes (repo evidence) | `known_source`, `not_closed` |
| `ods_fair_ums_tenant` | upstream ODS table | `lineage/ads_sc_xl_13/02_supporting_chains.md` | lineage | tenant-chain anchor only | No | No | No | Yes | Yes (repo evidence) | `known_source`, `not_closed` |
| `ods_mes_mdm_tenant` | upstream bridge table | `lineage/ads_sc_xl_13/02_supporting_chains.md` | lineage | physical-table anchor only | No | No | No | Yes | Yes (repo evidence) | `known_source`, `tenant_chain_gap` |
| `dim_ums_tenant` | support dimension table | `lineage/ads_sc_xl_13/02_supporting_chains.md` | lineage | physical-table anchor only | No | No | No | Yes | Yes (repo evidence) | `known_source`, `tenant_chain_gap` |

## Diagnostic and report evidence assets

| Name | Category | Path | Asset type | Reconstruction status | Inspect | Recon | Rebuild | Audit | Linked issue | State flags |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `dwd_ads_sc_xl_13_day_weight_baseline_di` | diagnostic table/report | `sql/source/ads_sc_xl_13/dwd_ads_sc_xl_13_day_weight_baseline_di.sql` | source SQL | reference evidence only | No | No | No | Yes | Yes (repo evidence) | `reference_only` |
| `dwd_ads_sc_xl_13_day_weight_reconciliation_di` | diagnostic table/report | `sql/source/ads_sc_xl_13/dwd_ads_sc_xl_13_day_weight_reconciliation_di.sql` | source SQL | reference evidence only | No | No | No | Yes | Yes (repo evidence) | `reference_only` |
| `dwd_ads_sc_xl_13_day_weight_source_di` | diagnostic table/report | `sql/source/ads_sc_xl_13/dwd_ads_sc_xl_13_day_weight_source_di.sql` | source SQL | reference evidence only | No | No | No | Yes | Yes (repo evidence) | `reference_only` |
| `dws_ads_sc_xl_13_day_weight_reconciliation_day` | diagnostic report table | `sql/source/ads_sc_xl_13/dws_ads_sc_xl_13_day_weight_reconciliation_day.sql` | source SQL | reference evidence only | No | No | No | Yes | Yes (repo evidence) | `reference_only` |

## Pending local reconstruction targets

| Name | Category | Path | Asset type | Reconstruction status | Inspect | Recon | Rebuild | Audit | Linked issue | State flags |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `dim_date_info_local` | local target | `sql/rebuild/ads_sc_xl_13/00_dim_date_info_local.sql` | rebuild SQL | designed; not executed | Yes | Yes | Yes | Yes | Yes (`#2`) | `pending_execution` |
| `ads_sc_xl_13_process1_local` | local target | `sql/rebuild/ads_sc_xl_13/01_process1.sql` | rebuild SQL | designed; not executed | Yes | Yes | Yes | Yes | Yes (`#3`) | `pending_execution` |
| `ads_sc_xl_13_defined_local` | local target | `sql/rebuild/ads_sc_xl_13/02_defined.sql` | rebuild SQL | designed; not executed | Yes | Yes | Yes | Yes | Yes (`#2`, `#3`) | `pending_execution` |
| `ads_sc_xl_13_defined_manuf_line_name_local` | local target | `sql/rebuild/ads_sc_xl_13/03_defined_manuf_line_name.sql` | rebuild SQL | designed; not executed | Yes | Yes | Yes | Yes | Yes (repo run summaries cite `#4/#5`) | `pending_execution` |
| `with_attr_value_local` | local target | `lineage/ads_sc_xl_13/supporting/with_attr_value_scene_matrix.md` | lineage | conceptually segmentable only | Yes | Yes | No | Yes | Yes (`#1`, `#6`, `#7`) | `partial`, `pending_execution`, `needs_business_clarification` |
| `ads_sc_xl_01_local` | local target | `lineage/ads_sc_xl_13/supporting/ads_sc_xl_01_local_join_skeleton.md` | lineage | skeleton ready; not executed | Yes | Yes | No | Yes | Yes (`#8`) | `partial`, `pending_execution` |
| `with_result_confirm_local` | local target | `lineage/ads_sc_xl_13/supporting/with_result_confirm_local_closure.md` | lineage | structural closure known; not executed | Yes | Yes | No | Yes | Yes (`#9`) | `partial`, `pending_execution`, `needs_business_clarification` |
| `total_rows_postprocess_local` | local target | `lineage/ads_sc_xl_13/supporting/total_rows_postprocess_local_plan.md` | lineage | design exists; not executed | Yes | Yes | No | Yes | Yes (`#9`, `#12`) | `partial`, `pending_execution`, `needs_business_clarification` |
| `ads_sc_xl_13_defined_manuf_line_name_combined_local` | local target | `sql/rebuild/ads_sc_xl_13/04_combined.sql` | rebuild SQL | core target exists; execution forbidden until gates clear | Yes | Yes | Yes | Yes | Yes (`#9`, `#12`) | `partial`, `pending_execution`, `blocked_for_complete_combined_local` |
| `combined_candidate` | candidate target | `lineage/ads_sc_xl_13/combined_candidate_blueprint.md` | lineage | `ready_for_candidate_blueprint`; not executed | Yes | Yes | No | Yes | Yes (`#9`, `#12`) | `ready`, `pending_execution`, `not_complete_combined_local` |
