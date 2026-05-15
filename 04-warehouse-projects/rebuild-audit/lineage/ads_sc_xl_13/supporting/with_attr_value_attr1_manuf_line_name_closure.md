# with_attr_value attr1 / manuf_line_name Closure

## 1. 本轮目标

本轮只验证：

- `with_attr_value` 在 `ADS_SC_XL_13` 中与 `attr1`
- `with_attr_value` 在 `ADS_SC_XL_13` 中与 `manuf_line_name`

相关的 scene 闭环。

目标不是把 `with_attr_value` 当作完整事实生产链重建，而是确认：

- 哪些 report scenes 被使用
- 哪些仓库事实字段与配置表连接
- 哪些配置映射是必须的
- 哪些映射已知、缺失、还是待执行验证

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
- `sql/inspect/ads_sc_xl_13/inspect_with_attr_value.sql`
- `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`
- `lineage/ads_sc_xl_13/defined_manuf_line_name_execution_result.md`
- `audit/ads_sc_xl_13/runs/20260426_121549/00_run_summary.md`
- `warehouse-platform/docs/support-anchor-tables.json`
- `warehouse-platform/docs/xl13-chain-evidence.json`

## 3. `with_attr_value` 当前已知结构

已知事实：

- 它是 `da_dw` 里的物理表
- 不是单一 ODS 镜像
- 它被多个工作流读取，也被部分工作流写入
- 它承载的是：
  - 配置
  - 业务映射
  - 报表口径 scene

## 4. `attr1` scene 使用位置

当前从仓库证据可明确看到：

- `dwd_mes_mm_task_group_output`
- `ads_sc_xl_13_process1`
- `combined`

都会使用 `attr1`

但是当前**不能直接下结论**说：

- `attr1` 一定完全来自 `with_attr_value`

当前已知主链证据更强的是：

- `manuf_line_name / defined_manuf_line_name` 与 `with_attr_value` 有直接 join
- `attr1` 在部分稳定 SQL 中还存在显式 `CASE WHEN` 派生逻辑

## 5. `manuf_line_name` scene 使用位置

当前已知直接依赖更明确：

- `dwd_mes_mm_task_group_output`
- `ads_sc_xl_13_defined_manuf_line_name`
- `ads_sc_xl_13_defined_manuf_line_name_combined`

这里的核心 scene 候选是：

- `BI-SC-KC-013-DEFINED-TYPE-LZ`
- `BI-SC-KC-013-DEFINED-TYPE-JJG`
- `BI-SC-KC-013-DEFINED-TYPE-GG`

以及后续排序/板型相关：

- `BI-SC-KC-013-DEFINED-PLATE-LZ`
- `BI-SC-KC-013-DEFINED-PLATE-JJG`
- `BI-SC-KC-013-DEFINED-PLATE-GG`

## 6. `defined` / `defined_manuf_line_name` 中哪些字段依赖这些映射

当前已知依赖字段：

- `defined_manuf_line_name`
- `manuf_line_name`
- `group_manuf_line_name`
- `plate_type`
- `rk`

对 `attr1`：

- 当前只确认它在主链中被保留和参与 key
- 但还不能确认 `attr1` 是否完全由 `with_attr_value` 映射得出

## 7. 生产表候选

按当前证据，`with_attr_value` 对 `ADS_SC_XL_13` 的上游生产/消费候选主要是：

- `dwd_mes_mm_task_group_output`
- `ads_sc_xl_13_process1`
- `ads_sc_xl_13_defined`
- `ads_sc_xl_13_defined_manuf_line_name`
- `ads_sc_xl_13_defined_manuf_line_name_combined`
- `ads_sc_xl_01`

## 8. 来源字段候选

当前已知 join 候选字段包括：

- `machine_code`
- `tenant_id`
- `wh_code`
- `dept_code`
- `rd_style_name`
- `surface`
- `steel_grade`
- `sku_code`
- `other_machine_code`

## 9. join key 候选

### 对 `manuf_line_name / defined_manuf_line_name`

- `tenant_id`
- `attribute2 = machine_code`

### 对 `plate_type / 排序`

- `tenant_id`
- `attribute4 = manuf_line_name`

### 对仓库 / 单据类型扩展

- `tenant_id`
- `attribute1`
- `attribute2`
- `attribute3`
- `attribute4`
- `attribute5`
- `attribute6`

## 10. filter 条件候选

主链相关 scene 候选：

- `BI-SC-KC-013-DEFINED-TYPE-*`
- `BI-SC-KC-013-DEFINED-PLATE-*`

入库量相关 scene 候选：

- `BI-SC-KC-013-WH-CODE-*`
- `BI-SC-KC-013-RD-FINISHED-*`

## 11. 租户字段 / 删除字段 / 启用字段候选

当前仓库证据明确存在：

- `tenant_id`
- `scene`
- `created_time`
- `modified_time`

当前仓库证据未明确存在：

- `deleted`
- `enabled`
- `attr_code`
- `attr_name`
- `attr_value`
- `attr_value_code`
- `type`

所以这些字段当前只能标为：

- `pending_execution`

## 12. 是否依赖 `ods_mes_sys_attr_value`

### 已知事实

- `with_attr_value` 不是 `ods_mes_sys_attr_value` 的简单镜像
- 但 `dwd_silicon_steel_surface_info` 明确来自 `ods_mes_sys_attr_value`
- 部分依赖 `surface / 牌号 / 表面分类` 的 scene 会间接经过：
  - `ods_mes_sys_attr_value`
  - `dwd_silicon_steel_surface_info`

### 当前结论

- `with_attr_value attr1/manuf_line_name` 闭环对 `ods_mes_sys_attr_value` 是：
  - `indirect / partial`

## 13. 是否依赖 `dwd_silicon_steel_surface_info`

### 已知事实

- `manuf_line_name / defined_manuf_line_name` 主映射更强依赖 `BI-SC-KC-013-DEFINED-TYPE-*`
- `surface` 分类和硅钢产品类别相关 scene 会依赖 `dwd_silicon_steel_surface_info`

### 当前结论

- `with_attr_value attr1/manuf_line_name` 对 `dwd_silicon_steel_surface_info` 的依赖：
  - `partial`

## 14. 是否能复刻为 local CTE

### `manuf_line_name` 主映射

- `partial yes`

原因：

- join key
- scene family
- 关键候选字段

已经比较清楚

### `attr1`

- `pending_execution`

原因：

- 当前证据不足以证明 `attr1` 完全由 `with_attr_value` 提供
- 仓库中同时存在 `CASE WHEN` 派生痕迹

## 15. 是否阻塞 `combined_candidate`

- `partial`

解释：

- 如果只是进入 `combined_candidate` 的候选评估，可以继续
- 因为当前已经知道主场景、join key 候选和关键阻塞位置

## 16. 是否阻塞完整 `combined_local`

- `blocked`

原因：

- `with_attr_value` 还没有整体闭合
- `attr1` 语义仍有不确定项
- 仓库 / 单据类型 scene 还没闭合

## 17. 当前结论

- `partial`

## Known from repository

- `with_attr_value` 是配置 / 映射表，不是事实表
- `scene` 是业务 / 报表口径场景
- `manuf_line_name / defined_manuf_line_name` 的主映射高度依赖 `BI-SC-KC-013-DEFINED-TYPE-*`
- `plate_type / rk` 的后续映射依赖 `BI-SC-KC-013-DEFINED-PLATE-*`
- `ads_sc_xl_01` 相关链依赖 `WH-CODE-*` 与 `RD-FINISHED-*` scenes

## Known from user clarification

- `with_attr_value` 应视为配置 / 映射表
- `scene` 应视为业务 / 报表场景
- 这轮不是去重建 `with_attr_value` 的完整生产链
- 本轮重点是：
  - 哪些 scene 被 ADS_SC_XL_13 使用
  - 哪些仓库字段 join 到配置表
  - 哪些映射是必须的

## Unknown / needs_business_clarification

- `attr1` 在 ADS_SC_XL_13 中，是否应被视为：
  - 完全由 `with_attr_value` 配置得出
  - 还是部分由业务规则 / `CASE WHEN` 派生，`with_attr_value` 只参与部分场景
- `BI-SC-KC-013-DEFINED-TYPE-*` scenes 中：
  - `attribute1`
  - `attribute2`
 这两个字段在业务上是否是唯一且权威的：
  - `manuf_line_name`
  - `machine_code`
  映射关系
- `group_manuf_line_name` 在这条链里是：
  - 等于 `manuf_line_name`
  - 还是上层业务分组名
  当前仓库里没有足够证据直接定性

## 18. 下一步建议

下一步优先建议：

- `with_attr_value` 的仓库 / 单据类型 scene 验证

原因：

- 它会直接影响 `ads_sc_xl_01`
- 而 `ads_sc_xl_01` 又是 `combined` 的明确支撑链
