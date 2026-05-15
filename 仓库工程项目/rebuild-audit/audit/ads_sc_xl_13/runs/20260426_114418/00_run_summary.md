# Run Summary

## 1. 本轮目标

推进 `Issue #4`：

1. 生成 `defined -> defined_manuf_line_name` 验证计划
2. 生成只读 `inspect_defined_manuf_line_name_inputs.sql`
3. 生成 `recon_defined_manuf_line_name_aggregation.sql`
4. 更新缺口和重构顺序
5. 明确是否允许推进 `defined_manuf_line_name -> combined`
6. 明确是否仍禁止直接进入完整 `combined_local`

## 2. 检查了哪些文件

- `README.md`
- `docs/01_current_status.md`
- `docs/07_two_track_execution_plan.md`
- `docs/08_automation_registry.md`
- `docs/09_execution_wip_policy.md`
- `lineage/ads_sc_xl_13/01_main_chain.md`
- `lineage/ads_sc_xl_13/02_supporting_chains.md`
- `lineage/ads_sc_xl_13/05_missing_links.md`
- `lineage/ads_sc_xl_13/06_next_rebuild_order.md`
- `lineage/ads_sc_xl_13/process1_defined_validation_plan.md`
- `sql/inspect/ads_sc_xl_13/inspect_process1_defined_inputs.sql`
- `sql/recon/ads_sc_xl_13/recon_process1_defined_zero_fill.sql`
- `audit/ads_sc_xl_13/runs/20260426_104215/00_run_summary.md`

## 3. 新增 / 修改了哪些文件

新增：

- `lineage/ads_sc_xl_13/defined_manuf_line_name_validation_plan.md`
- `sql/inspect/ads_sc_xl_13/inspect_defined_manuf_line_name_inputs.sql`
- `sql/recon/ads_sc_xl_13/recon_defined_manuf_line_name_aggregation.sql`
- `audit/ads_sc_xl_13/runs/20260426_114418/00_run_summary.md`

更新：

- `lineage/ads_sc_xl_13/05_missing_links.md`
- `lineage/ads_sc_xl_13/06_next_rebuild_order.md`

## 4. `defined -> defined_manuf_line_name` 当前结论

- 当前可以作为主线验证节点继续推进
- `manuf_line_name` 在这一层更像继承后聚合，而不是重新映射
- `group_manuf_line_name` 与 `manuf_line_name` 的保留关系需要在本层验证清楚

## 5. 聚合守恒对账当前结论

- 本轮已经补齐：
  - 行数检查
  - distinct key 检查
  - 聚合前后指标总量守恒检查
  - `manuf_line_name` 缺失检查
  - `group_manuf_line_name` 与 `manuf_line_name` 不一致检查
  - `attr1` 保留检查
  - zero-row 保留检查
- 当前状态：
  - **可执行待验证**

## 6. 是否可以推进 `defined -> defined_manuf_line_name`

- **Yes**
- 原因：
  - 当前聚合验证蓝图已具备
  - 本层还不依赖 `with_result_confirm`
  - 本层也还不需要完整 `combined_local`

## 7. 是否可以进入完整 `combined_local`

- **No**
- 原因：
  - `with_attr_value`
  - `with_result_confirm`
  - `ads_sc_xl_01`
  - `attr1='合计' / manuf_line_name='总计'`

这些仍然是后续阻塞项。

## 8. 当前最大阻塞点

当前最大阻塞点仍然是：

- `with_attr_value`

其次是：

- `ads_sc_xl_01`
- `with_result_confirm`
- 合计 / 总计后置行

## 9. 下一轮建议

1. 先执行 `defined -> defined_manuf_line_name` 的实际只读聚合验证
2. 如果守恒和 key 粒度稳定，再进入 `defined_manuf_line_name -> combined` 候选评估
3. 但仍然不要直接写完整 `combined_local`
