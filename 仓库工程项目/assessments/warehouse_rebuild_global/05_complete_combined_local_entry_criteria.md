# Complete Combined Local Entry Criteria

## Rule summary

1. `combined_candidate_blueprint != complete combined_local readiness`
2. `partial + pending_execution` cannot be treated as `closed`
3. unclear business semantics cannot be hard-coded into SQL
4. `合计 / 总计` postprocess rows are Dolphin post-aggregation outputs, not original fact-source rows

## Gate table

| GATE | Required evidence | Current status | Missing evidence | Source files | Source issues | Can bypass? | Why |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `GATE-001 main-chain upstream proof` | executed proof for `process1 -> defined -> defined_manuf_line_name` | `pending_execution` | actual read-only execution result set and reconciliation outcome | `01_main_chain.md`, `process1_defined_validation_plan.md`, `defined_manuf_line_name_execution_result.md` | `#2`, `#3`, repo evidence for `#4/#5` | No | the full combined layer inherits these upstream keys and measures |
| `GATE-002 dim_date_info closure` | executed `dim_date_info_local` and zero-fill validation | `pending_execution` | run output for `inspect_dim_date_info.sql` and `recon_dim_date_zero_fill.sql` | `dim_date_info_rebuild_plan.md`, `00_dim_date_info_local.sql` | `#1`, `#2` | No | date spine controls baseline-only zero rows |
| `GATE-003 with_attr_value attr1/manuf_line_name` | executed scene-local coverage plus no unresolved unsafe assumptions | `partial + pending_execution` | executed coverage evidence and/or exact business clarification answers | `with_attr_value_attr1_manuf_line_name_closure.md`, inspect/recon SQL | `#6` | No | config mapping semantics affect major report keys |
| `GATE-004 with_attr_value warehouse/doc_type` | executed warehouse/doc-type scene validation | `partial + pending_execution` | executed slot coverage or clarified scene-local slot meaning | `with_attr_value_warehouse_doc_type_closure.md`, inspect/recon SQL | `#7` | No | `ads_sc_xl_01_local` depends on this mapping family |
| `GATE-005 ads_sc_xl_01_local` | executed join validation with bounded source/baseline differences | `partial + pending_execution` | executed candidate join results | `ads_sc_xl_01_local_join_skeleton.md`, inspect/recon SQL | `#8` | No | inbound quantity fields remain support-chain blockers until validated |
| `GATE-006 with_result_confirm_local` | executed validation for `report_id 237 / 239 / 543` override coverage | `partial + pending_execution` | actual read-only validation output and any required business clarification | `with_result_confirm_local_closure.md`, inspect/recon SQL | `#9` | No | downtime and remark fields cannot be closed without it |
| `GATE-007 total_rows_postprocess_local` | executed reproduction or bounded validation for `合计 / 总计` rows | `partial + pending_execution` | executed summary-row validation and clarified generation rules if needed | `total_rows_postprocess_impact.md`, `total_rows_postprocess_local_plan.md`, inspect/recon SQL | `#9`, `#12` | No | terminal `_001/_002` completeness depends on this branch |
| `GATE-008 combined_candidate execution validation` | executed candidate input/key/metric coverage review | `ready + pending_execution` | actual candidate-level validation results | `combined_candidate_readiness.md`, `combined_candidate_blueprint.md` | `#9`, `#12` | No | blueprint readiness is insufficient for opening full combined work |
| `GATE-009 unresolved clarification queue` | no remaining P1 semantic gaps that would force invented SQL | `open` | answers for `with_result_confirm`, scene-local slot semantics, summary-row rules | `clarifications/ads_sc_xl_13/business_clarification_queue.md` | `#10`, repo evidence | No | unclear semantics must not be guessed |
| `GATE-010 governance acceptance refresh` | governance docs refreshed against latest executed evidence | `stale_relative_to_live` | updated gate summary after new execution receipts | `combined_local_readiness_gate.md`, `track_c_summary.md` | `#10` | Yes, temporarily | governance lag does not block technical execution, but it blocks clean acceptance |

## Hard entry criteria

The minimum hard entry criteria for `complete combined_local` are:

1. Every P1 support chain must be at least `executed` or explicitly `answered` by business clarification.
2. No P1 chain may remain `partial`, `pending_execution`, `blocked`, or `needs_business_clarification`.
3. `combined_candidate` must move from blueprint readiness to executed validation readiness.
4. `合计 / 总计` postprocess logic must be treated as post-aggregation logic, not guessed source facts.
5. Governance wording must not contradict live executed evidence.

## Current entry decision

- Can enter `complete combined_local` now:
  - No
- Why:
  - `GATE-003` through `GATE-009` are still open enough to make any full-closure claim unsafe.

## Lowest-risk next step

- Do not start full `combined_local`.
- Convert the existing P1 support-chain packages from blueprint to executed read-only evidence first.
