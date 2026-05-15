# combined_candidate blueprint

## 1. 本轮目标

本轮只推进：

- `combined_candidate_blueprint`
- candidate recon key / metric 蓝图
- complete readiness gate 前的结构化判断

本轮不推进：

- 完整 `combined_local`
- 生产写表 SQL
- 任何生产库写操作

## 2. 已读取依据文件

- `README.md`
- `docs/01_current_status.md`
- `docs/08_automation_registry.md`
- `docs/09_execution_wip_policy.md`
- `docs/10_executor_no_midpoint_prompt_policy.md`
- `lineage/ads_sc_xl_13/01_main_chain.md`
- `lineage/ads_sc_xl_13/02_supporting_chains.md`
- `lineage/ads_sc_xl_13/05_missing_links.md`
- `lineage/ads_sc_xl_13/06_next_rebuild_order.md`
- `lineage/ads_sc_xl_13/combined_candidate_readiness.md`
- `lineage/ads_sc_xl_13/supporting/with_attr_value_scene_matrix.md`
- `lineage/ads_sc_xl_13/supporting/with_attr_value_attr1_manuf_line_name_closure.md`
- `lineage/ads_sc_xl_13/supporting/with_attr_value_warehouse_doc_type_closure.md`
- `lineage/ads_sc_xl_13/supporting/ads_sc_xl_01_local_join_skeleton.md`
- `lineage/ads_sc_xl_13/supporting/with_result_confirm_local_closure.md`
- `lineage/ads_sc_xl_13/supporting/total_rows_postprocess_impact.md`
- `sql/inspect/ads_sc_xl_13/inspect_with_attr_value.sql`
- `sql/inspect/ads_sc_xl_13/inspect_with_attr_value_warehouse_doc_type.sql`
- `sql/inspect/ads_sc_xl_13/inspect_ads_sc_xl_01_local.sql`
- `sql/inspect/ads_sc_xl_13/inspect_with_result_confirm_local.sql`
- `sql/inspect/ads_sc_xl_13/inspect_total_rows_postprocess.sql`
- `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`
- `sql/recon/ads_sc_xl_13/recon_with_attr_value_warehouse_doc_type.sql`
- `sql/recon/ads_sc_xl_13/recon_ads_sc_xl_01_local_join.sql`
- `sql/recon/ads_sc_xl_13/recon_with_result_confirm_local.sql`
- `sql/recon/ads_sc_xl_13/recon_combined_candidate_readiness.sql`
- `sql/recon/ads_sc_xl_13/recon_total_rows_postprocess.sql`
- `audit/ads_sc_xl_13/runs/20260426_155703/00_run_summary.md`

## 3. `combined_candidate` 的定位

`combined_candidate` 是：

- 主链 + 支撑链的候选拼装层
- 面向 key / metric / blocker 的蓝图层
- 进入完整 `combined_local` 之前的结构化设计层

它不是：

- 已执行且对齐的结果层
- 可直接交付 `_001 / _002` 的最终层

## 4. `combined_candidate` 与 complete `combined_local` 的区别

### `combined_candidate`

- 允许：
  - join skeleton
  - inspect / recon SQL
  - source-only / baseline-only 风险设计
  - key / metric 覆盖设计
- 不允许：
  - 宣称已闭合
  - 宣称已对齐
  - 生成完整写表逻辑

### complete `combined_local`

- 必须：
  - 所有 P1 支撑链都至少达到 executed / closed
  - 后置 `合计 / 总计` 逻辑也进入本地复刻
- 当前：
  - **blocked**

## 5. 当前允许进入 candidate 的原因

- `defined_manuf_line_name` 主链已定位
- `with_attr_value` 的两类主要 scene family 已定位
- `ads_sc_xl_01_local` skeleton 已定位
- `with_result_confirm_local` skeleton 已定位
- `合计 / 总计` 的 Dolphin 后置聚合分支已定位

## 6. 当前禁止进入 complete `combined_local` 的原因

- `with_attr_value` 仍是 `partial + pending_execution`
- `ads_sc_xl_01_local` 仍是 `partial + pending_execution`
- `with_result_confirm_local` 仍是 `partial + pending_execution`
- `total_rows_postprocess_local` 仍是 `partial + pending_execution`

## 7. candidate 输入链路清单

- `ads_sc_xl_13_defined_manuf_line_name`
- `with_attr_value`
- `ads_sc_xl_01_local`
- `with_result_confirm_local`
- `total_rows_postprocess_local`

## 8. candidate 输入链路状态表

| Input | Current status | Note |
|---|---|---|
| `defined_manuf_line_name` | `pending_execution` | 主链逻辑已定位 |
| `with_attr_value` | `partial` | scene family 已定位 |
| `ads_sc_xl_01_local` | `partial` | join skeleton 已建立 |
| `with_result_confirm_local` | `partial` | 结构性闭环已明确 |
| `total_rows_postprocess_local` | `partial` | 后置聚合分支已定位 |

## 9. 主链输入：`defined_manuf_line_name / combined` 上游候选

- `tenant_id`
- `data_date`
- `plate_type`
- `group_manuf_line_name`
- `manuf_line_name`
- `attr1`
- 主度量：
  - `day_weight`
  - `day_quantity`
  - `day_average_thickness`

## 10. 配置链输入：`with_attr_value` scene family

- `BI-SC-KC-013-DEFINED-TYPE-*`
- `BI-SC-KC-013-DEFINED-PLATE-*`
- `BI-SC-KC-013-WH-CODE-*`
- `BI-SC-KC-013-RD-FINISHED-*`

## 11. 入库 / 单据类型输入：`ads_sc_xl_01_local`

- `tenant_id`
- `data_date`
- `wh_code`
- `dept_code`
- `machine_code`
- `other_machine_code`
- `rd_style`
- `rd_style_name`
- `bill_type`

## 12. 人工确认输入：`with_result_confirm_local`

- `tenant_id`
- `report_id`
- `attribute1` -> `manuf_line_name` candidate
- `attribute2` -> `data_date` candidate
- `attribute23` -> `attr1` candidate
- `attribute9..13` -> 停机与备注候选

## 13. 后置聚合输入：`total_rows_postprocess_local`

- `attr1='合计'`
- `manuf_line_name='总计'`
- 这些不是事实原始行，而是后置聚合分支

## 14. join key 候选

- `tenant_id`
- `data_date`
- `plate_type`
- `manuf_line_name`
- `attr1`

## 15. metric 候选

- `day_weight`
- `day_quantity`
- `day_average_thickness`
- `day_breakdown_frequency`
- `day_planned_downtime`
- `day_unplanned_downtime`
- `day_manufacturing_finished_output_tons`
- `day_manufacturing_finished_product`
- `month_weight`
- `month_quantity`

## 16. source-only / baseline-only 风险

- `with_attr_value` 映射未执行验证
- `ads_sc_xl_01_local` candidate join 未执行验证
- `with_result_confirm_local` 人工确认层未执行验证
- `合计 / 总计` 后置聚合未执行验证

## 17. candidate CTE skeleton

```sql
with main_chain as (
  select ...
  from ads_sc_xl_13_defined_manuf_line_name
),
config_mapping as (
  select ...
  from with_attr_value
),
inventory_support as (
  select ...
  from ads_sc_xl_01
),
confirm_support as (
  select ...
  from with_result_confirm
),
summary_rows as (
  select ...
)
select ...
from main_chain
left join config_mapping ...
left join inventory_support ...
left join confirm_support ...
left join summary_rows ...
```

## 18. candidate validation plan

- inspect 候选输入分布
- 验证 key coverage
- 验证 metric coverage
- 验证 source-only / baseline-only 蓝图
- 验证 blocker gate

## 19. 当前状态

- `ready_for_candidate_blueprint`
- `pending_execution`

## 20. 下一步建议

- `candidate execution validation plan`
