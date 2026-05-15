# total rows postprocess impact

## 1. `attr1='合计'` 的可能来源

当前稳定证据明确表明：

- 不是事实表原始行
- 来自 Dolphin task `18333852605970` `增加硅钢合计字段`
- 在 `ads_sc_xl_13_defined_manuf_line_name_combined` 上执行后置插入

## 2. `manuf_line_name='总计'` 的可能来源

当前稳定证据明确表明：

- 不是事实表原始行
- 来自 Dolphin task `18333852605971` `增加硅钢板块总计字段`
- 在 `ads_sc_xl_13_defined_manuf_line_name_combined` 上执行后置插入

## 3. 是否属于事实表原始行

- 否

## 4. 是否属于后置聚合 / union 行

- 是

更准确地说：

- 是主 `combined` 结果生成后，再按规则 delete + insert 的后置聚合行

## 5. 影响哪些输出层

- `ads_sc_xl_13_defined_manuf_line_name_combined`
- `ads_sc_xl_13_defined_manuf_line_name_combined_001`
- `ads_sc_xl_13_defined_manuf_line_name_combined_002`

## 6. 与 `combined_candidate` 的关系

- candidate 层必须知道这些行是后置逻辑
- candidate 层可以设计：
  - 如何从非合计 / 非总计明细行汇总生成
  - 应该使用哪些 key / metric
- candidate 层不能直接宣称已闭合

## 7. 与完整 `combined_local` 的关系

- 这是完整 `combined_local` 的必经支撑链
- 如果不复刻这两条后置逻辑：
  - baseline_only 正值行会持续存在
  - 终端 `_001 / _002` 会缺展示口径

## 8. 需要哪些 key 汇总

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

## 9. 需要哪些 metric 汇总

- `day_weight`
- `day_quantity`
- `day_average_thickness`
- `day_lower_weight`
- `day_lower_quantity`
- `day_breakdown_frequency`
- `day_planned_downtime`
- `day_unplanned_downtime`
- `day_manufacturing_finished_output_tons`
- `day_manufacturing_finished_output_quantity`
- `day_manufacturing_finished_output_length`
- `day_lower_manufacturing_finished_output_length`
- `day_manufacturing_finished_product`
- `day_manufacturing_finished_product_quantity`
- `month_weight`
- `month_quantity`
- `month_average_thickness`
- `month_lower_weight`
- `month_lower_quantity`
- `month_breakdown_frequency`
- `month_planned_downtime`
- `month_unplanned_downtime`
- `month_manufacturing_finished_output_tons`
- `month_manufacturing_finished_output_quantity`
- `month_manufacturing_finished_output_length`
- `month_lower_manufacturing_finished_output_length`
- `month_manufacturing_finished_product`
- `month_manufacturing_finished_product_quantity`

## 10. 不允许直接写死的原因

- 这些行依赖上游明细和支撑链实际结果
- 包含求和与平均两类不同聚合
- 和 `with_result_confirm` 停机字段、`ads_sc_xl_01` 入库字段相互作用
- 如果直接写死，后续对账无法解释 source-only / baseline-only 差异

## 11. inspect SQL 验证点

- 哪些层已经存在 `attr1='合计'`
- 哪些层已经存在 `manuf_line_name='总计'`
- 它们的 key 分布
- 它们的 metric 分布

## 12. recon SQL 验证点

- 是否能从非合计 / 非总计明细聚合还原
- baseline 是否存在额外合计 / 总计行
- source-only / baseline-only 的合计 / 总计差异
- 关键指标差异蓝图

## 13. 当前状态

- `partial`
- `pending_execution`

## 14. 需要问用户的精确问题

当前不需要中途询问才能继续写蓝图。

如果后续需要业务澄清，问题应精确到：

- `合计` 是否始终按 `manuf_line_name` 维度汇总？
- `总计` 是否始终清空 `group_manuf_line_name` 与 `attr1`？

## 15. 下一步建议

- `combined_candidate_blueprint`

原因：

- 已经可以把后置行当作 candidate 层的一部分显式建模
- 但仍然不能进入完整 `combined_local`
