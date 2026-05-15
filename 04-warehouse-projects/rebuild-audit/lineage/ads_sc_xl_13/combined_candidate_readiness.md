# combined_candidate readiness

## 1. 本轮目标

判断当前仓库状态是否已经足够进入：

- `combined_candidate_blueprint`

并明确：

- 为什么仍然不能进入完整 `combined_local`

## 2. 当前已具备的输入链路

- `dim_date_info`：可执行待验证
- `process1 -> defined`：蓝图已建立
- `defined -> defined_manuf_line_name`：蓝图已建立
- `with_attr_value attr1/manuf_line_name`：`partial`
- `with_attr_value warehouse/doc_type`：`partial`
- `ads_sc_xl_01_local`：skeleton / candidate join 已落蓝图

## 3. 当前 partial / pending_execution 的输入链路

- `with_attr_value`
- `ads_sc_xl_01_local`
- `with_result_confirm_local`
- `合计 / 总计` 后置行

## 4. `defined_manuf_line_name` 当前状态

- `pending_execution`
- 主聚合逻辑已定位
- 仍未做实际 SQL 执行验证

## 5. `with_attr_value` 当前状态

- `partial`
- `pending_execution`
- config mapping 已可按 scene family 分段建模

## 6. `ads_sc_xl_01_local` 当前状态

- `partial`
- `pending_execution`
- join skeleton 已建立
- 不能当作闭合事实层

## 7. `with_result_confirm_local` 当前状态

- `partial`
- `pending_execution`
- 结构性覆盖逻辑已定位
- 仍缺执行验证

## 8. 合计 / 总计后置行当前状态

- `partial`
- `pending_execution`
- 已知是 Dolphin 后置 SQL 叠加
- 尚未本地复刻

## 9. 可以进入 candidate 的最小条件

当前已经具备：

- 主链 key skeleton
- 支撑链 skeleton
- 配置链 skeleton
- 人工确认链 skeleton

因此可以进入：

- `ready_for_candidate_blueprint`

## 10. 不能进入 complete `combined_local` 的原因

- `with_attr_value` 仍未执行验证
- `ads_sc_xl_01_local` 仍未执行验证
- `with_result_confirm_local` 仍未执行验证
- `合计 / 总计` 后置行仍未执行验证

## 11. candidate 层允许做什么

- 写 join skeleton
- 写 inspect / recon SQL
- 写 key / metric coverage 设计
- 写 blocker gate
- 写 source-only / baseline-only 风险分析

## 12. candidate 层禁止做什么

- 声称结果已对齐
- 生成完整 `combined_local`
- 生成生产写表 SQL
- 把 `partial` 链路宣称为 `closed`

## 13. candidate recon key 候选

- `tenant_id`
- `data_date`
- `plate_type`
- `manuf_line_name`
- `attr1`
- `group_manuf_line_name`

## 14. candidate metric 对账候选

- `day_weight`
- `day_quantity`
- `day_average_thickness`
- `day_breakdown_frequency`
- `day_planned_downtime`
- `day_unplanned_downtime`
- `day_manufacturing_finished_output_tons`
- `day_manufacturing_finished_product`

## 15. source-only / baseline-only 风险

- `with_attr_value` scene 覆盖未闭合
- `ads_sc_xl_01_local` 仓库/单据类型映射未执行验证
- `with_result_confirm_local` 停机/备注覆盖未执行验证
- `合计 / 总计` 后置行未复刻

## 16. 当前结论

- `ready_for_candidate_blueprint`

说明：

- 可以进入 candidate blueprint
- 不等于可以进入完整 `combined_local`

## 17. 下一步建议

- `total_rows_postprocess_local`

原因：

- 进入完整 `combined_local` 前，后置 `合计 / 总计` 逻辑必须和 `with_result_confirm_local` 一起收口
