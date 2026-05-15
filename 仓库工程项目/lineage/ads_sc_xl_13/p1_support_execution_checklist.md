# P1 support execution checklist

## `with_attr_value attr1/manuf_line_name`

- Required evidence:
  - `with_attr_value_attr1_manuf_line_name_closure.md`
- SQL files to run:
  - `sql/inspect/ads_sc_xl_13/inspect_with_attr_value_attr1_manuf_line_name.sql`
  - `sql/recon/ads_sc_xl_13/recon_with_attr_value_attr1_manuf_line_name.sql`
- Expected result shape:
  - scene coverage / machine_code mapping coverage
- Pass condition:
  - scene family 可解释且 coverage 可解释
- Fail condition:
  - 大量 unmapped machine_code 且不可解释
- Blocked condition:
  - 关键列或物理表不存在
- Business clarification required?
  - Yes, if `attribute*` 语义无法确认
- Can proceed without this? No/Yes
  - No

## `with_attr_value warehouse/doc_type`

- Required evidence:
  - `with_attr_value_warehouse_doc_type_closure.md`
- SQL files to run:
  - `sql/inspect/ads_sc_xl_13/inspect_with_attr_value_warehouse_doc_type.sql`
  - `sql/recon/ads_sc_xl_13/recon_with_attr_value_warehouse_doc_type.sql`
- Expected result shape:
  - 仓库 scene 与单据类型 scene coverage
- Pass condition:
  - 关键 scene family 覆盖可解释
- Fail condition:
  - source-only / unmapped rows 大量不可解释
- Blocked condition:
  - 无法读取 `with_attr_value` 或 `ads_sc_xl_01`
- Business clarification required?
  - Yes, if `attribute*` 槽位含义无法确认
- Can proceed without this? No/Yes
  - No

## `ads_sc_xl_01_local`

- Required evidence:
  - `ads_sc_xl_01_local_join_skeleton.md`
- SQL files to run:
  - `sql/inspect/ads_sc_xl_13/inspect_ads_sc_xl_01_local.sql`
  - `sql/recon/ads_sc_xl_13/recon_ads_sc_xl_01_local_join.sql`
- Expected result shape:
  - join skeleton 覆盖与 key summary
- Pass condition:
  - candidate join 可解释
- Fail condition:
  - key coverage 严重缺口
- Blocked condition:
  - `ads_sc_xl_01` 或依赖表不存在
- Business clarification required?
  - Yes, if scene-local `attribute*` 语义不清
- Can proceed without this? No/Yes
  - No

## `with_result_confirm_local`

- Required evidence:
  - `with_result_confirm_local_closure.md`
- SQL files to run:
  - `sql/inspect/ads_sc_xl_13/inspect_with_result_confirm_local.sql`
  - `sql/recon/ads_sc_xl_13/recon_with_result_confirm_local.sql`
- Expected result shape:
  - report_id / downtime / remark coverage
- Pass condition:
  - `237/239/543` 结果可解释
- Fail condition:
  - remark / downtime 覆盖大量缺口
- Blocked condition:
  - `with_result_confirm` 表或关键列不存在
- Business clarification required?
  - Yes, if report meaning is unclear
- Can proceed without this? No/Yes
  - No

## `total_rows_postprocess_local`

- Required evidence:
  - `total_rows_postprocess_impact.md`
  - `total_rows_postprocess_local_plan.md`
- SQL files to run:
  - `sql/inspect/ads_sc_xl_13/inspect_total_rows_postprocess.sql`
  - `sql/recon/ads_sc_xl_13/recon_total_rows_postprocess.sql`
- Expected result shape:
  - `合计 / 总计` 行分布与聚合可还原性
- Pass condition:
  - summary rows 可由明细聚合解释
- Fail condition:
  - baseline summary rows 无法由明细解释
- Blocked condition:
  - 关键层不存在
- Business clarification required?
  - Yes, if summary rules are ambiguous
- Can proceed without this? No/Yes
  - No

## `combined_candidate_blueprint`

- Required evidence:
  - `combined_candidate_blueprint.md`
  - `complete_combined_local_readiness_gate.md`
- SQL files to run:
  - `sql/inspect/ads_sc_xl_13/inspect_combined_candidate_inputs.sql`
  - `sql/recon/ads_sc_xl_13/recon_combined_candidate_blueprint.sql`
  - `sql/recon/ads_sc_xl_13/recon_candidate_execution_validation_plan.sql`
- Expected result shape:
  - candidate input readiness / key coverage / blocker summary
- Pass condition:
  - candidate layer is execution-ready
- Fail condition:
  - candidate input blockers remain unexplained
- Blocked condition:
  - 任一 P1 前提表无法读取
- Business clarification required?
  - Depends on upstream semantic blockers
- Can proceed without this? No/Yes
  - No
