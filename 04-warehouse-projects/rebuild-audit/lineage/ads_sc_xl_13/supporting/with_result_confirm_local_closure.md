# with_result_confirm_local closure

## 1. 本轮目标

本轮只验证：

- `with_result_confirm_local` 的闭环方案
- 它对 `combined_candidate` 的影响
- 它为什么仍然阻塞完整 `combined_local`

本轮不推进：

- 完整 `combined_local`
- 生产写表 SQL
- 任何生产库写操作

## 2. 已读取的依据文件

- `README.md`
- `docs/01_current_status.md`
- `docs/08_automation_registry.md`
- `docs/09_execution_wip_policy.md`
- `docs/10_executor_no_midpoint_prompt_policy.md`
- `lineage/ads_sc_xl_13/01_main_chain.md`
- `lineage/ads_sc_xl_13/02_supporting_chains.md`
- `lineage/ads_sc_xl_13/05_missing_links.md`
- `lineage/ads_sc_xl_13/06_next_rebuild_order.md`
- `lineage/ads_sc_xl_13/supporting/with_attr_value_scene_matrix.md`
- `lineage/ads_sc_xl_13/supporting/with_attr_value_attr1_manuf_line_name_closure.md`
- `lineage/ads_sc_xl_13/supporting/with_attr_value_warehouse_doc_type_closure.md`
- `lineage/ads_sc_xl_13/supporting/ads_sc_xl_01_local_join_skeleton.md`
- `sql/inspect/ads_sc_xl_13/inspect_supporting_chains.sql`
- `audit/ads_sc_xl_13/runs/20260426_090204/source_docs/dolphin-process-chain-18333852605952.md`
- `audit/ads_sc_xl_13/runs/20260426_090204/source_json/xl13-chain-evidence.json`
- `audit/ads_sc_xl_13/runs/20260426_153809/00_run_summary.md`

## 3. `with_result_confirm` 在 ADS_SC_XL_13 中的角色

`with_result_confirm` 是：

- 人工确认结果表
- 停机时间覆盖逻辑入口
- 备注覆盖逻辑入口

它不是原始事实链，而是对报表结果做后置业务覆盖。

## 4. 使用位置

当前已明确的使用位置：

- `ads_sc_xl_13_defined_manuf_line_name_combined`
- `bi_sc_xl_013_defined`
- `bi_sc_xl_013_defined_manuf_line_name_month`
- `with_result_confirm` 自身月累计字段回写

在稳定 Dolphin 链里已明确看到：

- task `18333852605967` `更新硅钢停机时间`

## 5. 输入表候选

- `with_result_confirm`
- `ads_sc_xl_13_defined_manuf_line_name_combined`
- `bi_sc_xl_013_defined`
- `bi_sc_xl_013_defined_manuf_line_name_month`

## 6. 输出字段候选

已明确的输出覆盖字段：

- `day_breakdown_frequency`
- `day_planned_downtime`
- `day_unplanned_downtime`
- `month_breakdown_frequency`
- `month_planned_downtime`
- `month_unplanned_downtime`
- `remark`

候选来源字段：

- `attribute9`
- `attribute10`
- `attribute11`
- `attribute12`
- `attribute13`
- `attribute23`
- `attribute24`
- `attribute25`
- `attribute26`

## 7. 数仓侧 join/match 字段候选

- `tenant_id`
- `data_date`
- `manuf_line_name`
- `attr1`
- `plate_type`
- `month`

## 8. config / confirm 侧 join/match 字段候选

- `tenant_id`
- `report_id`
- `result_cat`
- `status`
- `attribute1`
- `attribute2`
- `attribute3`
- `attribute9`
- `attribute10`
- `attribute11`
- `attribute12`
- `attribute13`
- `attribute23`
- `period`

## 9. filter 条件候选

当前稳定证据已明确：

- `status = '1'`
- `result_cat = 'REPORT_BUSINESS_DATA'`
- `report_id in ('237', '239', '543')`

## 10. 租户字段 / 删除字段 / 启用字段候选

已知候选：

- `tenant_id`
- `status`
- `report_id`
- `result_cat`

当前没有稳定证据证明存在：

- `deleted`
- `enabled`

所以这两项只能标：

- `pending_execution`

## 11. 与 `ads_sc_xl_01_local` 的关系

- 没有看到稳定证据表明 `with_result_confirm` 直接 join `ads_sc_xl_01`
- 两者关系更像：
  - `ads_sc_xl_01_local` 提供入库量支撑
  - `with_result_confirm_local` 提供停机与备注覆盖
  - 最终都在 `combined` 层汇合

## 12. 与 `with_attr_value` 的关系

- 两者都不是原始事实链
- `with_attr_value` 决定配置 / 口径映射
- `with_result_confirm` 决定人工确认覆盖
- 它们共同影响 `combined`，但作用类型不同

## 13. 与 `defined_manuf_line_name` 的关系

- 当前明确关系更强的是：
  - `with_result_confirm` 更新 `combined`
  - 以及更新 `bi_sc_xl_013_defined`
- 它不会替代 `defined_manuf_line_name` 主聚合
- 但会覆盖 `defined` / `combined` 的停机与备注类字段

## 14. 对 `combined_candidate` 的影响

- **高影响**

原因：

- 候选层可以继续设计 join skeleton
- 但如果没有把 `with_result_confirm_local` 纳入考虑，就无法正确覆盖停机与备注口径

## 15. 对完整 `combined_local` 的影响

- **核心阻塞**

原因：

- `combined_local` 如果不纳入 `with_result_confirm`，停机类字段会系统性失真
- `remark` 字段也无法闭合

## 16. 是否能复刻为 local CTE

- **Yes, partial**

原因：

- `report_id / result_cat / attribute*` 结构已经定位
- 覆盖目标字段和 join key 已基本定位

限制：

- 仍未执行实际 SQL
- `attribute9..26` 的业务含义虽然已有较强证据，但仍应保留为执行待验证

## 17. 当前状态

- `partial`
- `pending_execution`

## 18. 需要问用户的精确业务问题

当前不需要中途询问才能继续落蓝图。

如果后续需要业务澄清，问题应精确到：

- `report_id = 237 / 239 / 543` 是否分别对应不同板块的停机确认？
- `attribute23` 是否稳定表示 `attr1` 维度？

## 19. 下一步建议

- `combined_candidate_blueprint`

原因：

- `with_result_confirm_local` 的结构性闭环已经足够进入 candidate readiness 判断
- 但仍然不能直接进入完整 `combined_local`
