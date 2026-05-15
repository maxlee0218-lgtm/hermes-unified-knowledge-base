# Run Summary

## 1. 本轮目标

推进 `Issue #6`：

1. 验证 `with_attr_value` 在 `attr1 / manuf_line_name` 上的 scene 闭环
2. 不把 `with_attr_value` 当成事实链去臆造
3. 只收敛：
   - scene
   - join key
   - coverage
   - missing mapping
   - 对 `combined_candidate / combined_local` 的阻塞程度

## 2. 检查了哪些文件

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
- `sql/inspect/ads_sc_xl_13/inspect_with_attr_value.sql`
- `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`
- `lineage/ads_sc_xl_13/defined_manuf_line_name_execution_result.md`
- `audit/ads_sc_xl_13/runs/20260426_121549/00_run_summary.md`

## 3. 新增 / 修改了哪些文件

新增：

- `lineage/ads_sc_xl_13/supporting/with_attr_value_attr1_manuf_line_name_closure.md`
- `sql/inspect/ads_sc_xl_13/inspect_with_attr_value_attr1_manuf_line_name.sql`
- `sql/recon/ads_sc_xl_13/recon_with_attr_value_attr1_manuf_line_name.sql`
- `audit/ads_sc_xl_13/runs/20260426_132217/00_run_summary.md`

更新：

- `lineage/ads_sc_xl_13/05_missing_links.md`
- `lineage/ads_sc_xl_13/06_next_rebuild_order.md`

## 4. SQL 是否实际执行

- `pending_execution`

## 5. `with_attr_value attr1/manuf_line_name` 当前结论

- 当前状态：`partial`
- 但执行状态：`pending_execution`

已知事实：

- `with_attr_value` 是配置 / 映射表，不是事实表
- `manuf_line_name / defined_manuf_line_name` 的主映射高度依赖：
  - `BI-SC-KC-013-DEFINED-TYPE-*`
- `plate_type / rk` 的后续映射依赖：
  - `BI-SC-KC-013-DEFINED-PLATE-*`

未知但不能猜的部分：

- `attr1` 是否完全由 `with_attr_value` scene 提供
- 还是部分由业务规则 `CASE WHEN` 派生

## 6. 是否可以进入 `combined_candidate`

- **Yes**
- 原因：
  - 可以进入候选评估层
  - 但只能基于当前 `partial + pending_execution` 结果继续

## 7. 是否可以进入完整 `combined_local`

- **No**
- 原因：
  - `with_attr_value` 仍未闭合
  - `with_result_confirm` 仍未闭合
  - `ads_sc_xl_01` 仍未闭合
  - 合计 / 总计后置行仍未闭合

## 8. 当前最大阻塞点

- `with_attr_value`

## 9. 下一轮建议

- 优先建议：`with_attr_value 仓库/单据类型 scene`
- 不建议直接跳到完整 `combined_local`
