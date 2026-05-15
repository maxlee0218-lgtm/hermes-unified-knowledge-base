# defined -> defined_manuf_line_name Validation Plan

## 1. `defined -> defined_manuf_line_name` 的目标

本轮目标是验证：

- `ads_sc_xl_13_defined` 是否已经具备稳定聚合条件
- `ads_sc_xl_13_defined_manuf_line_name` 是否只是对 `defined` 的按业务维度聚合
- 聚合后是否存在指标守恒问题

也就是说，本轮只验证：

`defined -> defined_manuf_line_name`

不进入：

- `combined`
- `_001`
- `_002`
- `combined_local`

## 2. 输入表和输出表

输入表：

- `ads_sc_xl_13_defined`

输出表：

- `ads_sc_xl_13_defined_manuf_line_name`

## 3. 需要继承的字段

至少需要从 `defined` 继承：

- `data_date`
- `tenant_id`
- `plate_type`
- `group_manuf_line_name`
- `manuf_line_name`
- `attr1`
- `month`
- `year`

## 4. 需要聚合的字段

本层至少需要聚合：

- `weight`
- `quantity`
- `lower_weight`
- `lower_quantity`
- `manufacturing_finished_output_length`
- `lower_manufacturing_finished_output_length`

## 5. `manuf_line_name` 的来源判断

当前判断：

- `manuf_line_name` 已经在 `defined` 层就存在
- 本层不是从 `with_attr_value` 新映射出来
- 本层更多是按已有 `manuf_line_name` 聚合

## 6. `group_manuf_line_name` 与 `manuf_line_name` 的关系

当前链路里这两个字段会同时保留：

- `group_manuf_line_name`
  - 用于更上层分组/展示
- `manuf_line_name`
  - 用于行级聚合与最终展示

本层验证重点：

- 两者是否同时存在
- 聚合时是否都需要保留在 key 中

## 7. `attr1` 的保留 / 改写规则

当前判断：

- `attr1` 在本层应保留
- 本层不应该主动生成：
  - `合计`
  - `总计`
- 这些后置行属于后续 `combined` 支线逻辑，不属于本层

## 8. `material_name` 或 `steel_grade_series` 的处理规则

当前稳定 SQL 中，本层没有固定的 `material_name` 单列。

已确认：

- `steel_grade_series` 是上游重要业务维度
- 如果后续本地复刻需要 `material_name`，应先确认它是否只是展示字段，还是由其他字段派生

当前本轮优先保留：

- `steel_grade_series`

## 9. `work_date` / `data_date` 日期字段规则

当前本层沿用：

- `data_date`

如果后续需要统一到 `work_date`，应在本地模型层做别名，不在当前链路审计中改名。

## 10. 需要对账的 key

当前建议 key：

- `data_date`
- `tenant_id`
- `plate_type`
- `group_manuf_line_name`
- `manuf_line_name`
- `attr1`

## 11. group by 字段候选

候选应至少包括：

- `tenant_id`
- `plate_type`
- `manuf_line_name`
- `attr1`
- `data_date`

视实际字段保留情况，再补：

- `group_manuf_line_name`
- `month`
- `year`

## 12. sum / max / min / any_value 字段候选

建议聚合函数：

- `SUM`
  - `weight`
  - `quantity`
  - `lower_weight`
  - `lower_quantity`
  - `manufacturing_finished_output_length`
  - `lower_manufacturing_finished_output_length`
- `ANY_VALUE` 或直接保留维度
  - `group_manuf_line_name`
  - `month`
  - `year`
- 当前不建议本层用 `MAX/MIN` 改写业务指标

## 13. 已知风险

- 如果 `group_manuf_line_name` 没有正确保留，后续 `combined` 可能失去分组语义
- 如果 `attr1` 被提前改写，会和后续 `合计` / `总计` 逻辑混淆
- 如果 `defined` 的补零行被错误聚合，可能造成零行被吞掉或错误合并

## 14. 本轮验收标准

本轮通过至少满足：

1. `defined` 与 `defined_manuf_line_name` 的 key 粒度明确
2. 聚合前后核心指标总量可解释
3. `manuf_line_name` 不出现大面积缺失
4. 零行不会被错误吞掉

## 15. 是否允许推进 `defined_manuf_line_name -> combined`

- **Yes, but only as validation candidate**

原因：

- 本层验证完成后，可以评估进入下一层 `defined_manuf_line_name -> combined`
- 但那只是“候选推进”，不等于允许直接做完整 `combined_local`

## 16. 是否允许进入完整 `combined_local`

- **No**

原因：

- `with_attr_value`
- `with_result_confirm`
- `ads_sc_xl_01`
- `合计 / 总计`

这些阻塞仍然存在。
