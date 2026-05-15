# process1 -> defined Validation Plan

## 1. `process1` 到 `defined` 的目标

这一步的目标不是生成最终展示结果，而是验证：

- `ads_sc_xl_13_process1` 是否能稳定提供业务组合集合
- `dim_date_info` 是否能稳定提供 35 天日期骨架
- `ads_sc_xl_13_defined` 的零填充是否可解释

也就是把：

`process1 + date_spine + left join + coalesce(0)`

这条补零链路先吃透。

## 2. 输入表和输出表

输入表：

- `ads_sc_xl_13_process1`
- `dim_date_info`

输出表：

- `ads_sc_xl_13_defined`

本轮本地蓝图输出：

- `defined_zero_fill_validation`

## 3. `process1` 必须具备的字段

至少需要：

- `data_date`
- `tenant_id`
- `plate_type`
- `surface`
- `attr1`
- `steel_grade_series`
- `group_manuf_line_name`
- `manuf_line_name`
- `weight`
- `quantity`
- `lower_weight`
- `lower_quantity`
- `manufacturing_finished_output_length`
- `lower_manufacturing_finished_output_length`

## 4. `defined` 补零后必须保留的字段

补零后必须保留：

- `data_date`
- `tenant_id`
- `plate_type`
- `surface`
- `attr1`
- `steel_grade_series`
- `group_manuf_line_name`
- `manuf_line_name`

以及零填充指标字段：

- `weight`
- `quantity`
- `lower_weight`
- `lower_quantity`
- `manufacturing_finished_output_length`
- `lower_manufacturing_finished_output_length`

## 5. date spine 规则

当前稳定链规则：

- 取 `CURRENT_DATE - INTERVAL 35 DAY` 到 `CURRENT_DATE`

所以本地 date spine 也应保持同样窗口。

## 6. combo seed 规则

当前稳定链规则：

- 从 `ads_sc_xl_13_process1`
- 取最近 `350` 天内的 distinct 业务组合

组合字段至少包括：

- `tenant_id`
- `plate_type`
- `surface`
- `attr1`
- `steel_grade_series`
- `group_manuf_line_name`
- `manuf_line_name`

## 7. filled grid 规则

`filled_grid` = `date_spine x combo_seed`

也就是：

- 每一天
- 每一个历史有效业务组合

都应该先生成一行理论记录，再回连业务值。

## 8. left join 规则

left join 回 `process1` 时，键必须包含：

- `data_date`
- `tenant_id`
- `plate_type`
- `surface`
- `attr1`
- `steel_grade_series`
- `group_manuf_line_name`
- `manuf_line_name`

其中 `attr1` 应使用 null-safe 逻辑。

## 9. `coalesce(metric, 0)` 指标清单

本轮至少需要补零：

- `weight`
- `quantity`
- `lower_weight`
- `lower_quantity`
- `manufacturing_finished_output_length`
- `lower_manufacturing_finished_output_length`

## 10. 需要对账的 key

对账 key 先固定成：

- `data_date`
- `tenant_id`
- `plate_type`
- `surface`
- `attr1`
- `steel_grade_series`
- `group_manuf_line_name`
- `manuf_line_name`

## 11. 已知风险

- `process1` 的 tenant 特殊过滤规则若丢失，会导致 combo seed 本身偏差
- `attr1` 如果没有 null-safe 处理，会造成伪缺口
- 35 天 / 350 天窗口若写错，会放大或缩小补零行

## 12. 本轮验收标准

本轮通过至少满足：

1. `process1` 字段结构满足补零需要
2. `date_spine` 和 `combo_seed` 可以独立表达
3. 理论 `filled_grid` 可计算
4. `defined` 零行可解释
5. `baseline_only` 零行主要能归因到补零逻辑

## 13. 是否允许推进 `defined -> defined_manuf_line_name`

- **Yes**

条件是：

- 本轮 zero-fill 对账蓝图足够稳定
- `defined` 层 key 和补零逻辑没有明显黑箱

## 14. 是否允许进入完整 `combined_local`

- **No**

原因：

- `with_attr_value`
- `with_result_confirm`
- `ads_sc_xl_01`
- `合计 / 总计`

这几条支撑链还没闭合。
