# Run Summary

## 1. 本轮目标

只验证两个支撑对象：

1. `dim_date_info`
2. `with_attr_value`

并明确是否允许进入 `process1/defined` 重构，以及是否允许直接进入完整 `combined_local` 重构。

## 2. 检查了哪些文件

- `lineage/ads_sc_xl_13/02_supporting_chains.md`
- `lineage/ads_sc_xl_13/05_missing_links.md`
- `lineage/ads_sc_xl_13/06_next_rebuild_order.md`
- `sql/inspect/ads_sc_xl_13/inspect_tables.sql`
- 既有链路证据与支撑对象说明文件

## 3. 新增了哪些文件

- `lineage/ads_sc_xl_13/supporting/dim_date_info_rebuild_plan.md`
- `lineage/ads_sc_xl_13/supporting/with_attr_value_scene_matrix.md`
- `sql/inspect/ads_sc_xl_13/inspect_dim_date_info.sql`
- `sql/inspect/ads_sc_xl_13/inspect_with_attr_value.sql`
- `sql/recon/ads_sc_xl_13/recon_dim_date_zero_fill.sql`
- `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`

## 4. `dim_date_info` 当前结论

- 已明确在 `ads_sc_xl_13_defined` 层引入
- 已明确负责补零行
- 当前 `baseline_only` 零行主要来自它
- 35 天日期骨架 + 350 天历史组合全集的模式已清楚
- 当前判断：
  - **可复刻**
  - **状态应为可执行待验证**

## 5. `with_attr_value` 当前结论

- 已明确它不是简单 ODS 镜像
- 已明确它至少承担：
  - `attr1` 映射
  - `manuf_line_name` 映射
  - 仓库映射
  - 单据类型映射
  - 产线映射
  - 牌号/表面分类映射
- 当前判断：
  - **可分段复刻**
  - **但未整体闭合**

## 6. 是否可以进入 `process1/defined` 重构

可以。

原因：

- `dim_date_info` 已经足够明确
- `process1` 与 `defined` 主逻辑已明确
- 可以先推进主链前半段复刻

## 7. 是否可以进入 `combined` 重构

现在还**不允许直接进入完整 `combined_local` 重构**。

原因：

- `with_attr_value` 还没整体闭合
- `ads_sc_xl_01` 依赖的仓库/单据类型映射还没闭合
- `with_result_confirm` 也还没结构化复刻

## 8. 当前最大阻塞点

`with_attr_value` 仍是最大阻塞点，尤其是：

- `GAP-005A attr1/manuf_line_name 映射`
- `GAP-005B 仓库/单据类型映射`
- `GAP-005C ads_sc_xl_01 依赖映射`
- `GAP-005D combined 依赖映射`

## 9. 下一轮建议

1. 先把 `dim_date_info_local` 做出来
2. 再做 `with_attr_value` scene 矩阵核对
3. 再做 `ads_sc_xl_01_local`
4. 最后才允许推进完整 `combined_local`
