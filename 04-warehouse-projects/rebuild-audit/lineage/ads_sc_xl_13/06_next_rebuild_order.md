# ADS_SC_XL_13 Next Rebuild Order

## 1. 确认 `dim_date_info` 本地可用

- 输入表：`dim_date_info`
- 输出表：`dim_date_info_local`
- 依赖 SQL：`sql/inspect/ads_sc_xl_13/inspect_supporting_chains.sql`
- 验收 SQL：`sql/inspect/ads_sc_xl_13/inspect_tables.sql`
- 当前是否可执行：是
- 阻塞点：无

## 1A. 验证 `dim_date_info` 的日期骨架补零行为

- 输入表：`dim_date_info`, `ads_sc_xl_13_process1`
- 输出表：`defined_date_spine_validation`
- 依赖 SQL：`sql/recon/ads_sc_xl_13/recon_dim_date_zero_fill.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_dim_date_zero_fill.sql`
- 当前是否可执行：是
- 阻塞点：无

## 1A. 验证 `dim_date_info` 的日期骨架补零行为

- 输入表：`dim_date_info`, `ads_sc_xl_13_process1`
- 输出表：`defined_date_spine_validation`
- 依赖 SQL：`sql/recon/ads_sc_xl_13/recon_dim_date_zero_fill.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_dim_date_zero_fill.sql`
- 当前是否可执行：是
- 阻塞点：无

## 2. 复刻 `ods_mes_sys_attr_value -> dwd_silicon_steel_surface_info -> with_attr_value`

- 输入表：`ods_mes_sys_attr_value`, `dwd_silicon_steel_surface_info`, `with_attr_value`
- 输出表：`dwd_silicon_steel_surface_info_local`, `with_attr_value_local`
- 依赖 SQL：`sql/source/ads_sc_xl_13/10_surface_info_source_snapshot.sql`
- 验收 SQL：`sql/inspect/ads_sc_xl_13/inspect_supporting_chains.sql`
- 当前是否可执行：部分可执行
- 阻塞点：`with_attr_value` 全量来源仍未完全闭合

## 2A. 先做 `with_attr_value` scene 矩阵验证

- 输入表：`with_attr_value`
- 输出表：`with_attr_value_scene_matrix_local`
- 依赖 SQL：`sql/inspect/ads_sc_xl_13/inspect_with_attr_value.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`
- 当前是否可执行：是
- 阻塞点：无

## 2B. 验证 `with_attr_value` 的仓库 / 单据类型 scene

- 输入表：`with_attr_value`, `dwd_mes_wms_wh_enter_item`, `ads_sc_xl_01`
- 输出表：`with_attr_value_warehouse_doc_type_validation`
- 依赖 SQL：`sql/inspect/ads_sc_xl_13/inspect_with_attr_value_warehouse_doc_type.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_with_attr_value_warehouse_doc_type.sql`
- 当前是否可执行：是
- 阻塞点：`attribute*` 槽位语义不能跨 scene 直接写死；不明确处需标 `needs_business_clarification`

## 3. 复刻 `with_result_confirm`

- 输入表：`with_result_confirm`
- 输出表：`with_result_confirm_local`
- 依赖 SQL：`lineage/ads_sc_xl_13/02_supporting_chains.md`
- 验收 SQL：`sql/inspect/ads_sc_xl_13/inspect_supporting_chains.sql`
- 当前是否可执行：部分可执行
- 阻塞点：字段含义需按 `report_id 237/239/543` 拆清

## 3A. 验证 `with_result_confirm_local` 闭环

- 输入表：`with_result_confirm`, `ads_sc_xl_13_defined_manuf_line_name_combined`
- 输出表：`with_result_confirm_local_closure`
- 依赖 SQL：`sql/inspect/ads_sc_xl_13/inspect_with_result_confirm_local.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_with_result_confirm_local.sql`
- 当前是否可执行：是
- 阻塞点：`attribute9..26` 的最终业务含义仍需执行验证

## 4. 复刻 `ads_sc_xl_01` 入库量链

- 输入表：`dwd_mes_wms_wh_enter_item`, `ads_sc_xl_01`
- 输出表：`ads_sc_xl_01_local`
- 依赖 SQL：`sql/source/ads_sc_xl_13/09_ads_sc_xl_01_source_snapshot.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_missing_rows.sql`
- 当前是否可执行：是（蓝图可执行，结果验证待执行）
- 阻塞点：`with_attr_value` 仓库/单据类型 scene 仍需执行验证

## 4A. 验证 `ads_sc_xl_01_local` join skeleton / candidate join

- 输入表：`ads_sc_xl_01`, `with_attr_value`
- 输出表：`ads_sc_xl_01_local_join_skeleton`
- 依赖 SQL：`sql/inspect/ads_sc_xl_13/inspect_ads_sc_xl_01_local.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_ads_sc_xl_01_local_join.sql`
- 当前是否可执行：是
- 阻塞点：`attribute*` 槽位语义仍需 scene-local 验证，不能跨 scene 写死

说明：

- 在 `with_attr_value` 的仓库 / 单据类型映射未闭合前，不允许直接跳到完整 `combined_local`。

说明：

- 在 `with_attr_value` 的仓库 / 单据类型映射未闭合前，不允许直接跳到完整 `combined_local`。

## 5. 复刻 `dwd_mes_mm_task_group_output -> ads_sc_xl_13_process1`

- 输入表：`dwd_mes_mm_task_group_output`
- 输出表：`ads_sc_xl_13_process1_local`
- 依赖 SQL：`sql/rebuild/ads_sc_xl_13/01_process1.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_day_weight.sql`
- 当前是否可执行：是
- 阻塞点：租户差异过滤规则需完整带入

## 6. 复刻 `ads_sc_xl_13_process1 -> ads_sc_xl_13_defined`

- 输入表：`ads_sc_xl_13_process1_local`, `dim_date_info_local`
- 输出表：`ads_sc_xl_13_defined_local`
- 依赖 SQL：`sql/rebuild/ads_sc_xl_13/02_defined.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_missing_rows.sql`
- 当前是否可执行：是
- 阻塞点：补零集合与历史组合全集

## 7. 复刻 `ads_sc_xl_13_defined -> ads_sc_xl_13_defined_manuf_line_name`

- 输入表：`ads_sc_xl_13_defined_local`
- 输出表：`ads_sc_xl_13_defined_manuf_line_name_local`
- 依赖 SQL：`sql/rebuild/ads_sc_xl_13/03_defined_manuf_line_name.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_day_weight.sql`
- 当前是否可执行：是
- 阻塞点：无

说明：

- 当前这一层已经成为主线验证节点
- 当前状态：`pending_execution`
- 如果本轮聚合验证结果充分，下一步可以评估 `defined_manuf_line_name -> combined_candidate`
- 但仍然不能直接进入完整 `combined_local`

## 8. 复刻 `ads_sc_xl_13_defined_manuf_line_name -> combined`

- 输入表：`ads_sc_xl_13_defined_manuf_line_name_local`, `with_attr_value_local`, `with_result_confirm_local`, `ads_sc_xl_01_local`
- 输出表：`ads_sc_xl_13_defined_manuf_line_name_combined_local`
- 依赖 SQL：`sql/rebuild/ads_sc_xl_13/04_combined.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_combined_002.sql`
- 当前是否可执行：部分可执行
- 阻塞点：这是当前主阻塞点，所有支线都回写这里

明确限制：

- 在 `with_attr_value` 场景矩阵未闭合前，不允许直接写完整 `combined_local`
- 只能先按支撑链逐段验证

下一轮三选一建议：

- A. `combined_candidate_blueprint`
  - 理由：当前主链和主要支撑链已足够进入候选层蓝图
- B. `total_rows_postprocess_local`
  - 理由：后置 `合计 / 总计` 是完整 `combined_local` 的核心 blocker
- C. `complete combined_local readiness gate`
  - 理由：仅适合在全部 P1 支撑链进入 closed/executed 后做最终门禁判断

当前推荐：

- A. `combined_candidate_blueprint`

补充说明：

- `with_attr_value attr1/manuf_line_name scene` 已达到 `partial`
- `with_attr_value warehouse/doc_type scene` 已完成证据层收口，但执行状态仍为 `pending_execution`
- `ads_sc_xl_01_local` 的 join skeleton / candidate join 也已经具备蓝图
- `with_result_confirm_local` 的闭环方案也已经具备蓝图
- `合计 / 总计` 后置行影响也已经被显式拉出
- 所以当前已经适合进入 `combined_candidate_blueprint`

明确限制：

- 在 `with_attr_value`、`ads_sc_xl_01_local`、`with_result_confirm_local`、`total_rows_postprocess_local`
  仍为 `partial/pending_execution` 前，不允许直接写完整 `combined_local`

## 8C. 验证 `candidate execution validation plan`

- 输入表：主链、P1 支撑链、candidate blueprint
- 输出表：`candidate_execution_validation_plan`
- 依赖 SQL：`sql/recon/ads_sc_xl_13/recon_candidate_execution_validation_plan.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_candidate_execution_validation_plan.sql`
- 当前是否可执行：是
- 阻塞点：仍缺真实只读执行环境 evidence

## 8D. 准备 `readonly execution dry-run package`

- 输入表：主链、P1 支撑链、candidate execution validation artifacts
- 输出表：`readonly_execution_dry_run_package`
- 依赖 SQL：`sql/recon/ads_sc_xl_13/recon_candidate_execution_validation_plan.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_candidate_execution_validation_plan.sql`
- 当前是否可执行：是
- 阻塞点：仍缺真实只读执行环境 evidence

## 8E. 验证 `readonly execution dry-run package`

- 输入表：P1 支撑链、candidate validation artifacts、dry-run artifacts
- 输出表：`readonly_execution_dry_run_package`
- 依赖 SQL：`sql/recon/ads_sc_xl_13/recon_readonly_execution_dry_run.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_readonly_execution_dry_run.sql`
- 当前是否可执行：是
- 阻塞点：仍缺真实只读执行环境 evidence

## 8F. 准备 `P1 support chain execution evidence collection`

- 输入表：P1 支撑链、dry-run artifacts、actual evidence gate
- 输出表：`p1_support_chain_execution_evidence_collection`
- 依赖 SQL：`sql/recon/ads_sc_xl_13/recon_readonly_execution_dry_run.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_readonly_execution_dry_run.sql`
- 当前是否可执行：是
- 阻塞点：仍缺真实只读执行环境 evidence

下一轮建议：

- A. `actual readonly execution / evidence collection`
  - 理由：P1 evidence matrix、actual evidence gate、fill-in template 已齐备
- B. `total_rows_postprocess execution validation`
  - 理由：后置 `合计 / 总计` 仍是完整 `combined_local` 的核心 blocker
- C. `business clarification closure`
  - 理由：若执行结果暴露语义缺口，需要优先闭合

当前推荐：

- A. `actual readonly execution / evidence collection`

## 9. 复刻 `combined -> combined_001 / combined_002`

- 输入表：`ads_sc_xl_13_defined_manuf_line_name_combined_local`
- 输出表：`..._001_local`, `..._002_local`
- 依赖 SQL：`sql/rebuild/ads_sc_xl_13/05_combined_001.sql`, `sql/rebuild/ads_sc_xl_13/06_combined_002.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_combined_002.sql`
- 当前是否可执行：是
- 阻塞点：前置 `combined_local` 必须先对齐

## 10. 复刻 `attr1 = '合计'` 和 `manuf_line_name = '总计'`

- 输入表：`ads_sc_xl_13_defined_manuf_line_name_combined_local`
- 输出表：带 `合计/总计` 的 `combined_local`
- 依赖 SQL：`sql/rebuild/ads_sc_xl_13/04_combined.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_missing_rows.sql`
- 当前是否可执行：部分可执行
- 阻塞点：需要先复刻主 combined

## 10A. 验证 `合计 / 总计` 后置行影响

- 输入表：`ads_sc_xl_13_defined_manuf_line_name_combined`
- 输出表：`total_rows_postprocess_local`
- 依赖 SQL：`sql/inspect/ads_sc_xl_13/inspect_total_rows_postprocess.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_total_rows_postprocess.sql`
- 当前是否可执行：是
- 阻塞点：需要 candidate 层明确 key 和 metric 汇总方式

## 11. 做 `day_weight` 对账

- 输入表：`combined_local`, `combined_002`
- 输出表：对账结果表 / 视图
- 依赖 SQL：`sql/recon/ads_sc_xl_13/recon_day_weight.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_day_weight.sql`
- 当前是否可执行：是
- 阻塞点：`combined_local` 未完全复刻

## 12. 做入库量字段对账

- 输入表：`combined_local`, `ads_sc_xl_01_local`
- 输出表：入库量对账结果
- 依赖 SQL：`sql/recon/ads_sc_xl_13/recon_combined_002.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_combined_002.sql`
- 当前是否可执行：部分可执行
- 阻塞点：`ads_sc_xl_01_local`

## 13. 做停机时间字段对账

- 输入表：`combined_local`, `with_result_confirm_local`
- 输出表：停机对账结果
- 依赖 SQL：`sql/recon/ads_sc_xl_13/recon_combined_002.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_combined_002.sql`
- 当前是否可执行：部分可执行
- 阻塞点：人工确认链未完全复刻

## 14. 做备注字段对账

- 输入表：`combined_local`, `with_result_confirm_local`
- 输出表：备注对账结果
- 依赖 SQL：`sql/recon/ads_sc_xl_13/recon_combined_002.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_combined_002.sql`
- 当前是否可执行：部分可执行
- 阻塞点：人工确认链未完全复刻

## 15. 做全字段 row-level diff

- 输入表：`combined_001_local`, `combined_002_local`, 稳定基线 `001/002`
- 输出表：row-level diff 结果
- 依赖 SQL：`sql/recon/ads_sc_xl_13/recon_missing_rows.sql`
- 验收 SQL：`sql/recon/ads_sc_xl_13/recon_missing_rows.sql`
- 当前是否可执行：部分可执行
- 阻塞点：支撑链和 `combined_local` 仍未完全闭合
