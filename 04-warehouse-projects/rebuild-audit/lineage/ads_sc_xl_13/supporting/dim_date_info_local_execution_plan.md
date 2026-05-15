# dim_date_info_local Execution Plan

## 1. 为什么 `dim_date_info` 可以先复刻

`dim_date_info` 当前不是未知黑盒。

已经明确：

- 它在 `ads_sc_xl_13_defined` 层引入
- 它负责补零行
- 当前 `baseline_only` 的零重量行主要由它产生
- 当前稳定链使用：
  - `35` 天 date spine
  - `350` 天 combo seed

所以它已经具备先行复刻的条件，不需要等待 `with_attr_value` 或 `combined_local` 完全闭合。

## 2. `dim_date_info_local` 的目标

本地复刻目标不是“复制一张日期表”这么简单，而是为 `defined_local` 提供：

- 连续日期骨架
- 可解释的补零行来源
- 与 `process1_local` 组合之后的理论网格

最终服务对象：

- `ads_sc_xl_13_defined_local`

## 3. 日期字段候选

当前优先候选字段：

1. `date_id`
2. `work_date`
3. `dt`

当前环境已明确存在：

- `date_id`

当前环境未明确存在：

- `work_date`
- `dt`

所以本轮本地蓝图默认使用：

- `date_id`

## 4. 日期范围策略

当前采用双窗口：

- date spine：
  - `CURRENT_DATE - INTERVAL 35 DAY` 到 `CURRENT_DATE`
- combo seed：
  - `CURRENT_DATE - INTERVAL 350 DAY`

解释：

- `35` 天用于当前补零窗口
- `350` 天用于收齐历史业务组合

## 5. 与 `ads_sc_xl_13_process1` 的关系

`dim_date_info` 不直接产出业务数据。

它与 `ads_sc_xl_13_process1` 的关系是：

1. `process1` 提供有值业务组合
2. `dim_date_info` 提供连续日期
3. 两者组合生成理论 `filled_grid`
4. 再 left join 回 `process1`

## 6. `date x business_combo` 的生成方式

建议步骤：

1. `date_spine`
2. `combo_seed`
3. `filled_grid`
4. `process1_enriched`

其中：

- `date_spine`：只保留 35 天日期
- `combo_seed`：只保留 350 天历史业务组合
- `filled_grid`：`cross join`
- `process1_enriched`：`left join process1`

## 7. 补零字段清单

当前应补零的字段至少包括：

- `weight`
- `quantity`
- `lower_weight`
- `lower_quantity`
- `manufacturing_finished_output_length`
- `lower_manufacturing_finished_output_length`

后续进入 `defined_manuf_line_name_local` 与 `combined_local` 时，再扩展成：

- `day_weight`
- `day_quantity`
- `month_weight`
- `month_quantity`

## 8. 不确定字段和待数据库验证点

当前仍待确认：

- `dim_date_info` 是否还有其他业务口径字段
- 历史 `process1` 组合集合是否还依赖更长时间窗
- 某些租户是否存在特殊日期切分

这些不阻塞先做蓝图，但会影响后续精确对账。

## 9. 本轮验收标准

本轮只验证三件事：

1. `dim_date_info_local` 的日期骨架是否足够表达 35 天窗口
2. `date x business_combo` 的理论网格能否成立
3. `baseline_only = 0` 的零行能否用该补零逻辑解释

## 10. 是否允许推进 `process1 -> defined`

结论：

- **Yes**

原因：

- `dim_date_info` 当前已经达到“可执行待验证”
- 可以进入 `process1_local -> defined_local` 的补零蓝图验证
- 但这不等于允许直接跳到 `combined_local`
