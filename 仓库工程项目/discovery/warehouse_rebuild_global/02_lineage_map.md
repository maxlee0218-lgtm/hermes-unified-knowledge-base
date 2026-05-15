# Global Lineage Map

## Reading boundary

- This map covers the whole repository.
- Repository-wide registration result:
  - only `ADS_SC_XL_13` is represented in warehouse lineage files
  - no other warehouse domain lineage tree is registered
- External execution channel facts from `openclaw-v2-infra` are included only for dependency analysis.

## Chain map

| Chain | Current status | Evidence files | Evidence issues | Partial? | Pending execution? | Needs business clarification? | Blocks combined_candidate? | Blocks complete combined_local? | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| main chain | upstream chain is structurally mapped through `process1 -> defined -> defined_manuf_line_name -> combined -> _001/_002`; no executed closure package exists | `lineage/ads_sc_xl_13/01_main_chain.md`, `sql/rebuild/ads_sc_xl_13/01_process1.sql`, `02_defined.sql`, `03_defined_manuf_line_name.sql`, `04_combined.sql` | `#2`, `#3`, repo run summaries for `#4/#5`, `#12` | Yes | Yes | No | No | Yes | execute existing inspect/recon chain in read-only environment |
| `dim_date_info / zero-fill` chain | rebuildable and blueprint-ready; still not executed | `lineage/ads_sc_xl_13/supporting/dim_date_info_rebuild_plan.md`, `dim_date_info_local_execution_plan.md`, `sql/inspect/ads_sc_xl_13/inspect_dim_date_info.sql`, `sql/recon/ads_sc_xl_13/recon_dim_date_zero_fill.sql` | `#1`, `#2`, `#3` | No | Yes | No | No | Yes | run `inspect_dim_date_info.sql` and `recon_dim_date_zero_fill.sql` |
| `with_attr_value` configuration chain | scene families are anchored, but slot semantics remain scene-local and partly unresolved | `lineage/ads_sc_xl_13/supporting/with_attr_value_scene_matrix.md`, `with_attr_value_attr1_manuf_line_name_closure.md`, `with_attr_value_warehouse_doc_type_closure.md`, inspect/recon SQL for both branches | `#1`, `#6`, `#7` | Yes | Yes | Yes | Partly | Yes | execute scene-family validation and preserve unresolved semantics as clarification items |
| `ads_sc_xl_01` inbound/doc-type chain | join skeleton exists; still only blueprint-level evidence | `lineage/ads_sc_xl_13/supporting/ads_sc_xl_01_local_join_skeleton.md`, `sql/inspect/ads_sc_xl_13/inspect_ads_sc_xl_01_local.sql`, `sql/recon/ads_sc_xl_13/recon_ads_sc_xl_01_local_join.sql` | `#7`, `#8` | Yes | Yes | Yes | Partly | Yes | run candidate join validation against actual read-only data |
| `with_result_confirm` manual-confirm chain | structural closure known; override fields and joins are still not executed | `lineage/ads_sc_xl_13/supporting/with_result_confirm_local_closure.md`, `sql/inspect/ads_sc_xl_13/inspect_with_result_confirm_local.sql`, `sql/recon/ads_sc_xl_13/recon_with_result_confirm_local.sql` | `#9` | Yes | Yes | Yes | No | Yes | execute read-only validation for `report_id 237/239/543` coverage |
| `defined_manuf_line_name / manuf_line_name` aggregation chain | validation plan and result template exist; executed proof still missing | `lineage/ads_sc_xl_13/defined_manuf_line_name_validation_plan.md`, `defined_manuf_line_name_execution_result.md`, `sql/recon/ads_sc_xl_13/recon_defined_manuf_line_name_aggregation.sql` | repo evidence for `#4/#5` | No | Yes | Partly (`group_manuf_line_name`) | No | Yes | run aggregation conservation checks and fill execution result template |
| `combined_candidate` chain | `ready_for_candidate_blueprint`; blueprint exists; no executed candidate validation yet | `lineage/ads_sc_xl_13/combined_candidate_readiness.md`, `combined_candidate_blueprint.md`, `sql/inspect/ads_sc_xl_13/inspect_combined_candidate_inputs.sql`, `sql/recon/ads_sc_xl_13/recon_combined_candidate_blueprint.sql` | `#9`, `#12` | Yes | Yes | Partly (depends on support-chain clarifications) | No | Yes | run candidate input distribution and key/metric coverage validation |
| `合计 / 总计` postprocess chain | explicitly identified as Dolphin post-aggregation branch; design exists only | `lineage/ads_sc_xl_13/supporting/total_rows_postprocess_impact.md`, `total_rows_postprocess_local_plan.md`, `sql/inspect/ads_sc_xl_13/inspect_total_rows_postprocess.sql`, `sql/recon/ads_sc_xl_13/recon_total_rows_postprocess.sql` | `#9`, `#12` | Yes | Yes | Yes | No | Yes | validate summary-row generation order and aggregation behavior |
| governance / readiness chain | governance package exists, but some repo-state conclusions are already behind live issue receipts | `governance/ads_sc_xl_13/00_governance_overview.md`, `combined_local_readiness_gate.md`, `track_c_summary.md`, `reviews/ads_sc_xl_13/issue_result_matrix.md` | `#10` | Partly | No | No | No | Indirectly | refresh only after new executed evidence if coordinator wants repo docs aligned |
| Hermes execution channel chain | dry-run gateway contract exists; connector readiness docs exist; direct ChatGPT call remains blocked | `openclaw-v2-infra#11`, `#13`, `#15`, `PR #12`, `PR #14` | infra `#11`, `#13`, `#15`, PR `#12`, PR `#14` | Yes | Yes | No | No | No for blueprint work; Yes for direct-call automation | review connector registration path and run local `pwsh` validation |

## Chain-by-chain interpretation

### Main chain

- Current state:
  - structurally mapped
  - not execution-closed
- Strong evidence:
  - main chain lineage file
  - source snapshots for `process1`, `defined`, `combined`, `_001`, `_002`
- Current decision:
  - enough to support discovery and candidate-level planning
  - not enough to declare `complete combined_local`

### `dim_date_info / zero-fill`

- Current state:
  - closest thing to a non-blocked support chain
  - still `pending_execution`
- Why it matters:
  - explains `baseline_only = 0` rows
  - required before treating `defined` as closed

### `with_attr_value`

- Current state:
  - biggest semantic support-chain surface in the repo
  - confirmed to be configuration/mapping, not fact production
- What is settled:
  - scene-family anchors exist
  - `attr*` meaning is scene-local
- What is not settled:
  - exact slot-to-business-field mapping per scene family

### `ads_sc_xl_01`

- Current state:
  - join skeleton only
  - still downstream of unresolved warehouse/doc-type scene validation
- Practical meaning:
  - can inform candidate planning
  - cannot be treated as a closed support fact yet

### `with_result_confirm`

- Current state:
  - structurally clearer after issue `#9`
  - still not validated by executed SQL
- Practical meaning:
  - full `combined_local` remains unsafe without it

### `合计 / 总计`

- Current state:
  - explicitly modeled as postprocess, not source fact rows
- Practical meaning:
  - this is a real closure gate for full `combined_local`
  - it is not a reason to stop all discovery/candidate work

## Global lineage result

1. The repository has one detailed lineage system, not a multi-domain warehouse map.
2. The lineage map is deep enough to separate:
   - true structural knowledge
   - `pending_execution`
   - `needs_business_clarification`
3. The dominant blocker is not “unknown main chain,” but “known support chains that still lack executed validation.”
