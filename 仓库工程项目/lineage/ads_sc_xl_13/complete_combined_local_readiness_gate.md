# complete_combined_local readiness gate

## Gate Table

| Gate ID | Gate name | Required evidence | Current status | Source issue/file | Blocking severity | Can bypass | Next action |
|---|---|---|---|---|---|---|---|
| `GATE-001` | main chain skeleton | `process1 -> defined -> defined_manuf_line_name` 蓝图已建立 | `partial` | `lineage/ads_sc_xl_13/01_main_chain.md` | `P1` | `No` | 继续候选层蓝图 |
| `GATE-002` | dim_date_info / zero-fill | `dim_date_info` 已进入可执行待验证 | `partial` | `lineage/ads_sc_xl_13/supporting/dim_date_info_rebuild_plan.md` | `P1` | `No` | 继续执行验证 |
| `GATE-003` | defined_manuf_line_name | 主聚合已定位，待执行验证 | `partial` | `lineage/ads_sc_xl_13/defined_manuf_line_name_validation_plan.md` | `P1` | `No` | 进入 candidate blueprint |
| `GATE-004` | with_attr_value attr1/manuf_line_name | scene family 已定位，未执行验证 | `partial` | `lineage/ads_sc_xl_13/supporting/with_attr_value_attr1_manuf_line_name_closure.md` | `P1` | `No` | 保持 partial，待执行验证 |
| `GATE-005` | with_attr_value warehouse/doc_type | scene family 已定位，未执行验证 | `partial` | `lineage/ads_sc_xl_13/supporting/with_attr_value_warehouse_doc_type_closure.md` | `P1` | `No` | 保持 partial，待执行验证 |
| `GATE-006` | ads_sc_xl_01_local | skeleton 已建立，未执行验证 | `partial` | `lineage/ads_sc_xl_13/supporting/ads_sc_xl_01_local_join_skeleton.md` | `P1` | `No` | 进入 candidate blueprint |
| `GATE-007` | with_result_confirm_local | 结构性闭环已明确，未执行验证 | `partial` | `lineage/ads_sc_xl_13/supporting/with_result_confirm_local_closure.md` | `P1` | `No` | 进入 candidate blueprint |
| `GATE-008` | combined_candidate_blueprint | 候选层蓝图可进入 | `ready` | `lineage/ads_sc_xl_13/combined_candidate_blueprint.md` | `P2` | `N/A` | 继续 candidate execution validation |
| `GATE-009` | total_rows_postprocess_local | 后置聚合分支已定位，未执行验证 | `partial` | `lineage/ads_sc_xl_13/supporting/total_rows_postprocess_impact.md` | `P1` | `No` | 进入 postprocess local plan |
| `GATE-010` | complete combined_local execution readiness | 全部 P1 gate 需 closed / executed | `blocked` | `lineage/ads_sc_xl_13/combined_candidate_readiness.md` | `P0` | `No` | 禁止进入完整 `combined_local` |

## Rule

- 如果任何 `P1` gate 是 `partial / pending_execution / needs_business_clarification / blocked`，则 `complete combined_local = blocked`
- `combined_candidate_blueprint` 通过，不等于 `complete combined_local` 通过
