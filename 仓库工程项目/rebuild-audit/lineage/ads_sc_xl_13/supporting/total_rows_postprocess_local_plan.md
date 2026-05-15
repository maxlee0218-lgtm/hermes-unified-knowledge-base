# total_rows_postprocess_local plan

## 1. 本节点目标

把 `合计 / 总计` 后置聚合分支收成：

- candidate 可接入的本地设计层

## 2. 与 Issue #9 `total_rows_postprocess_impact` 的关系

- `total_rows_postprocess_impact` 解释的是“为什么它存在、为什么不能写死”
- 本文件收的是“如果要本地接入，应如何设计”

## 3. 为什么 `合计 / 总计` 属于后置聚合 / union 分支

- Dolphin 稳定链明确先生成主 `combined`
- 然后再执行：
  - `增加硅钢合计字段`
  - `增加硅钢板块总计字段`
- 所以它们不是原始事实源行

## 4. 输入明细层候选

- `ads_sc_xl_13_defined_manuf_line_name_combined`
- 过滤条件：
  - 非 `attr1='合计'`
  - 非 `manuf_line_name='总计'`

## 5. 输出行候选

- `attr1='合计'`
- `manuf_line_name='总计'`

## 6. group by key 候选

### 对 `attr1='合计'`

- `tenant_id`
- `plate_type`
- `group_manuf_line_name`
- `manuf_line_name`
- `data_date`
- `month`
- `year`
- `rk`
- `rk1`

### 对 `manuf_line_name='总计'`

- `tenant_id`
- `plate_type`
- `data_date`
- `month`
- `year`
- `rk`
- `rk1`

## 7. metric aggregation 候选

- `SUM(day_weight)`
- `SUM(day_quantity)`
- `AVG(day_average_thickness)`
- `SUM(day_lower_weight)`
- `SUM(day_lower_quantity)`
- `SUM(day_breakdown_frequency)`
- `SUM(day_planned_downtime)`
- `SUM(day_unplanned_downtime)`
- `SUM(day_manufacturing_finished_output_tons)`
- `SUM(day_manufacturing_finished_product)`
- 同理月字段继续累计

## 8. `attr1='合计'` 生成规则候选

- 保留原 `manuf_line_name`
- 将 `attr1` 改为 `合计`
- 对同一 `tenant_id + plate_type + group_manuf_line_name + manuf_line_name + data_date`
  下的明细做汇总

## 9. `manuf_line_name='总计'` 生成规则候选

- 清空 `group_manuf_line_name`
- 将 `manuf_line_name` 改为 `总计`
- 将 `attr1` 置空
- 对同一 `tenant_id + plate_type + data_date`
  下的明细做汇总

## 10. 与 `combined_candidate` 的接入点

- 候选层必须把它显式当作后置 union / postprocess branch
- 不能把它与主事实行混成同一来源层

## 11. 与 complete `combined_local` 的关系

- 是完整 `combined_local` 必须补齐的一环
- 但当前仍处于 blueprint / pending_execution

## 12. 不允许写死的原因

- 它依赖主 `combined` 的真实明细结果
- 包含 sum / avg 混合聚合
- 还受 `with_result_confirm` 和入库量支撑影响

## 13. recon 验证口径

- 合计行是否可从明细重算
- 总计行是否可从明细重算
- summary rows 的 source-only / baseline-only 差异

## 14. 当前状态

- `partial`
- `pending_execution`

## 15. 下一步建议

- `candidate execution validation plan`
