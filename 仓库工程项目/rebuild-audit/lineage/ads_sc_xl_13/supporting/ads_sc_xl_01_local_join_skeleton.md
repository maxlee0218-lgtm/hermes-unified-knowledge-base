# ads_sc_xl_01_local join skeleton

## 1. 本轮目标

本轮只验证：

- `ads_sc_xl_01_local` 的 join skeleton
- `ads_sc_xl_01_local` 的 candidate join

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
- `sql/inspect/ads_sc_xl_13/inspect_with_attr_value.sql`
- `sql/inspect/ads_sc_xl_13/inspect_with_attr_value_warehouse_doc_type.sql`
- `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`
- `sql/recon/ads_sc_xl_13/recon_with_attr_value_warehouse_doc_type.sql`
- `audit/ads_sc_xl_13/runs/20260426_152046/00_run_summary.md`

额外证据：

- `sql/source/ads_sc_xl_13/09_ads_sc_xl_01_source_snapshot.sql`
- `audit/ads_sc_xl_13/runs/20260426_090204/source_docs/dolphin-process-chain-18340742659072.md`

## 3. 已知用户业务口径

- `with_attr_value` = 配置 / 映射表，不是事实源表
- `scene` = 业务报表场景 / 报表口径
- `attr*` / `attribute*` = 通用维度槽位
- `attribute*` 含义 = `scene + join/match 字段` 决定
- 仓库 / 单据类型 scene = 数仓事实 / 聚合表通过配置映射转成报表需要的仓库口径 / 单据类型口径

禁止泛化：

- 不能把 `ads_sc_xl_01` 当作已验证事实表
- 不能把 `with_attr_value` 当事实链
- 不能把某个 `attribute*` 槽位写成跨 scene 的固定业务含义

## 4. `ads_sc_xl_01` 在 ADS_SC_XL_13 支撑链中的角色

当前已经锚定：

- workflow `18340742659072` `入库单`
- task `18340742659074` `ads_sc_xl_01(入库量)`

它在 `ADS_SC_XL_13` 中承担的是：

- 生产入库量支撑
- 成品入库量支撑
- `combined` 层的入库侧补充事实

它不是最终交付表，但它会直接影响：

- `ads_sc_xl_13_defined_manuf_line_name_combined`
- `_001 / _002` 的部分入库量相关字段

## 5. `ads_sc_xl_01` 与 `with_attr_value` 仓库 scene 的关系

已知 scene family：

- `BI-SC-KC-013-WH-CODE-*`

已知影响：

- 决定哪些仓库记录进入 `ads_sc_xl_01`
- 决定仓库记录如何被映射到报表需要的仓库/产线口径

当前只能安全收成候选 join：

- `tenant_id`
- `wh_code`
- `dept_code`
- `machine_code`
- `other_machine_code`

不能直接写死：

- `attribute1 = wh_code`
- `attribute2 = dept_code`

这类关系只能保留为 candidate join。

## 6. `ads_sc_xl_01` 与 `with_attr_value` 单据类型 scene 的关系

已知 scene family：

- `BI-SC-KC-013-RD-FINISHED-*`

已知影响：

- 决定哪些 `rd_style / rd_style_name` 纳入成品入库统计

当前只能安全收成候选 join：

- `tenant_id`
- `rd_style`
- `rd_style_name`
- `bill_type`

不能直接写死：

- `attribute1 = rd_style`
- `attribute1 = rd_style_name`

## 7. `ads_sc_xl_01` 可能参与的下游节点

- `生产入库量`
- `成品入库量`
- `ads_sc_xl_13_defined_manuf_line_name_combined`
- `ads_sc_xl_13_defined_manuf_line_name_combined_001`
- `ads_sc_xl_13_defined_manuf_line_name_combined_002`

## 8. 输入表候选

事实侧候选：

- `dwd_mes_wms_wh_enter_item`
- `ads_sc_xl_01`

配置侧候选：

- `with_attr_value`

关联维表候选：

- `dim_ums_tenant`
- `dwd_silicon_steel_surface_info`

## 9. 输出字段候选

当前稳定证据已明确的输出字段候选：

- `products_category`
- `plate_type`
- `products_type`
- `tenant_id`
- `sku_code`
- `sku_name`
- `wh_code`
- `wh_name`
- `dept_code`
- `dept_name`
- `machine_code`
- `machine_name`
- `other_machine_code`
- `other_machine_name`
- `rd_style`
- `rd_style_name`
- `top_cat_name`
- `steel_grade_series`
- `steel_grade`
- `surface`
- `surface_thickness`
- `surface_number`
- `surface_middle_part`
- `grade`
- `spec`
- `weight`
- `quantity`
- `roll_length`
- `iron_loss`
- `data_date`
- `month`
- `year`
- `bill_type`
- `is_production_out`

## 10. 数仓侧 join/match 字段候选

- `tenant_id`
- `wh_code`
- `dept_code`
- `machine_code`
- `other_machine_code`
- `rd_style`
- `rd_style_name`
- `sku_code`
- `steel_grade`
- `surface`
- `grade`
- `data_date`
- `bill_type`

## 11. config 侧 join/match 字段候选

- `tenant_id`
- `scene`
- `attribute1`
- `attribute2`
- `attribute3`
- `attribute4`
- `attribute5`
- `attribute6`
- `attribute7`
- `list_order`

## 12. join skeleton 候选

### Skeleton A: 仓库 scene

```sql
ads_sc_xl_01 a
left join with_attr_value av_wh
  on a.tenant_id = av_wh.tenant_id
 and av_wh.scene like 'BI-SC-KC-013-WH-CODE-%'
 and (
      av_wh.attribute1 = a.wh_code
   or av_wh.attribute2 = a.wh_code
   or av_wh.attribute2 = a.dept_code
   or av_wh.attribute3 = a.machine_code
   or av_wh.attribute4 = a.other_machine_code
 )
```

### Skeleton B: 单据类型 scene

```sql
ads_sc_xl_01 a
left join with_attr_value av_rd
  on a.tenant_id = av_rd.tenant_id
 and av_rd.scene like 'BI-SC-KC-013-RD-FINISHED-%'
 and (
      av_rd.attribute1 = a.rd_style
   or av_rd.attribute1 = a.rd_style_name
   or av_rd.attribute2 = a.rd_style
   or av_rd.attribute2 = a.rd_style_name
 )
```

### Skeleton C: 下游 combined candidate

```sql
ads_sc_xl_01_local x
join combined_candidate c
  on x.tenant_id = c.tenant_id
 and x.data_date = c.data_date
 and coalesce(x.machine_code, '') = coalesce(c.manuf_line_name, '')
```

说明：

- Skeleton C 只是候选评估蓝图
- 当前没有足够证据证明 `machine_code -> manuf_line_name` 是稳定一一映射

## 13. filter 条件候选

当前稳定证据已明确：

- `verify_status = '2'`
- `bill_type in (1, 2)`
- `data_date >= current_date - interval 35 day`
- `(dept_code = '160502005' and machine_code = 'CS02' and parent_batch_code not like '%-RD') or ...`

当前仍不应补写：

- 任何未见证据的 `deleted / enabled / status` 过滤

## 14. 租户字段 / 删除字段 / 启用字段候选

已知候选：

- `tenant_id`
- `data_date`
- `bill_type`

当前未在稳定快照中直接确认：

- `deleted`
- `enabled`

这些字段如果在实际表结构里存在，后续 inspect SQL 再补；当前只能标：

- `pending_execution`

## 15. `attribute*` 槽位在本节点的 scene-local 含义

### 对 `BI-SC-KC-013-WH-CODE-*`

当前只能说它们承载：

- 仓库
- 部门
- 设备
- 辅助设备

的某种报表映射槽位。

但不能跨 scene 直接宣称：

- `attribute1 = wh_code`
- `attribute2 = dept_code`

### 对 `BI-SC-KC-013-RD-FINISHED-*`

当前只能说它们承载：

- `rd_style`
- `rd_style_name`

相关的报表映射槽位。

但不能直接写死：

- 哪个 `attribute*` 就是哪个业务字段

当前语义状态：

- `needs_business_clarification`

## 16. 是否能复刻为 local CTE

- **Yes, partial**

原因：

- `ads_sc_xl_01` 稳定输入 / 输出 / 过滤条件已定位
- `with_attr_value` 的 scene family 已定位
- 可以先复刻 candidate join skeleton

限制：

- 只能先做 `local blueprint / candidate join`
- 不能把 candidate probe 直接升级成闭合业务结论

## 17. 是否阻塞 `combined_candidate`

- **No, not fully**

原因：

- `combined_candidate` 可以继续候选评估
- `ads_sc_xl_01_local` skeleton 已足够支持下游候选 join 设计

但当前仍会影响：

- 入库量相关字段是否可稳定对账

## 18. 是否阻塞完整 `combined_local`

- **Yes**

原因：

- `ads_sc_xl_01_local` 仍是 `partial + pending_execution`
- `with_result_confirm_local` 仍未闭合
- `合计 / 总计` 后置行未闭合

## 19. 当前状态

- `partial`
- `pending_execution`

## 20. 需要问用户的精确业务问题

当前不需要中途询问才能继续落蓝图。

如果后续需要业务澄清，问题应精确到：

- 在 `BI-SC-KC-013-WH-CODE-*` scene 中，`attribute1..attribute6` 各自映射哪类事实字段？
- 在 `BI-SC-KC-013-RD-FINISHED-*` scene 中，`rd_style` 与 `rd_style_name` 分别对应哪个 `attribute*`？

## 21. 下一步建议

- `with_result_confirm_local`

原因：

- `ads_sc_xl_01_local` 的 skeleton 已经足够进入下一层支撑链闭环
- 相比直接跳 `combined_candidate`，继续补 `with_result_confirm_local` 更能缩小完整 `combined_local` 的核心阻塞面
