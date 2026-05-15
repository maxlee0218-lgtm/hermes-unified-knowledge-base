# defined_manuf_line_name Execution Result

## 1. 本轮验证目标

验证：

`ads_sc_xl_13_defined`
-> `ads_sc_xl_13_defined_manuf_line_name`

重点不是生成下游结果，而是把：

- 聚合粒度
- 指标守恒
- 零行保留
- `attr1 / manuf_line_name / group_manuf_line_name`

这些关键信号固化成一套可执行的只读验收脚本。

## 2. 已读取的依据文件

- `README.md`
- `docs/01_current_status.md`
- `docs/07_two_track_execution_plan.md`
- `docs/08_automation_registry.md`
- `docs/09_execution_wip_policy.md`
- `docs/10_executor_no_midpoint_prompt_policy.md`
- `lineage/ads_sc_xl_13/01_main_chain.md`
- `lineage/ads_sc_xl_13/02_supporting_chains.md`
- `lineage/ads_sc_xl_13/05_missing_links.md`
- `lineage/ads_sc_xl_13/06_next_rebuild_order.md`
- `lineage/ads_sc_xl_13/process1_defined_validation_plan.md`
- `lineage/ads_sc_xl_13/defined_manuf_line_name_validation_plan.md`
- `sql/inspect/ads_sc_xl_13/inspect_defined_manuf_line_name_inputs.sql`
- `sql/recon/ads_sc_xl_13/recon_defined_manuf_line_name_aggregation.sql`
- `audit/ads_sc_xl_13/runs/20260426_114418/00_run_summary.md`

## 3. 实际执行状态

- `pending_execution`

## 4. 为什么没有实际执行 SQL

本轮没有直接产出数据库实际结果，原因是：

- 当前仓库阶段以只读审计和文件固化为主
- 任务要求允许在没有实际执行权限或没有实际结果时，明确标记为 `pending_execution`
- 当前最安全的做法是把 SQL、预期字段和验收口径固化好，供数据库执行者后续直接运行

## 5. 哪些 SQL 已经准备好

- `sql/inspect/ads_sc_xl_13/inspect_defined_manuf_line_name_inputs.sql`
- `sql/recon/ads_sc_xl_13/recon_defined_manuf_line_name_aggregation.sql`

## 6. 每段 SQL 预期返回什么字段

### `inspect_defined_manuf_line_name_inputs.sql`

预期输出包括：

- `ads_sc_xl_13_defined` / `ads_sc_xl_13_defined_manuf_line_name` 的：
  - `SHOW CREATE TABLE`
  - `DESC`
  - `COUNT(*)`
  - `MIN/MAX(data_date)`
- 维度分布：
  - `manuf_line_name`
  - `group_manuf_line_name`
  - `attr1`
  - `steel_grade_series`
- 指标分布：
  - `sum_weight`
  - `sum_quantity`
  - `sum_lower_weight`
  - `sum_lower_quantity`
  - `zero_weight_rows`
  - `null_weight_rows`
- 聚合粒度：
  - `defined_key_cnt`
  - `defined_manuf_line_name_key_cnt`

### `recon_defined_manuf_line_name_aggregation.sql`

预期输出包括：

- `SECTION 01: row_count_check`
  - `defined_row_cnt`
  - `defined_manuf_line_name_row_cnt`
- `SECTION 02: date_range_check`
  - `min/max data_date`
- `SECTION 03: group_key_distinct_check`
  - distinct key 数量
- `SECTION 04: metric_conservation_check`
  - `sum_weight`
  - `sum_quantity`
  - `sum_lower_weight`
  - `sum_lower_quantity`
  - `sum_output_len`
- `SECTION 05: zero_row_retention_check`
  - 聚合前后零行数量
- `SECTION 06: manuf_line_name_missing_check`
  - 缺失行明细
- `SECTION 07: group_vs_manuf_line_name_mismatch_check`
  - 分组名与机组名不一致明细
- `SECTION 08: attr1_retention_check`
  - `attr1` 分布
- `SECTION 09: material_or_steel_grade_change_check`
  - 目前优先看 `steel_grade_series`
- `SECTION 10: source_only_rows_blueprint`
  - source-only key
- `SECTION 11: baseline_only_rows_blueprint`
  - baseline-only key
- `SECTION 12: final_pass_fail_summary_blueprint`
  - 用守恒与缺口统计做最终人工判定

## 7. `defined` 原始行数检查结论

- 当前状态：`pending_execution`
- 已有结论：
  - 检查 SQL 已准备好
  - 能输出 `defined_row_cnt`

## 8. `defined_manuf_line_name` 目标行数检查结论

- 当前状态：`pending_execution`
- 已有结论：
  - 检查 SQL 已准备好
  - 能输出 `defined_manuf_line_name_row_cnt`

## 9. 聚合 key distinct 数量结论

- 当前状态：`pending_execution`
- 已有结论：
  - 已固定 key 候选：
    - `data_date`
    - `tenant_id`
    - `plate_type`
    - `group_manuf_line_name`
    - `manuf_line_name`
    - `attr1`

## 10. 指标总量守恒结论

- 当前状态：`pending_execution`
- 已有结论：
  - 守恒 SQL 已准备好
  - 核心关注：
    - `weight`
    - `quantity`
    - `lower_weight`
    - `lower_quantity`
    - `manufacturing_finished_output_length`
    - `lower_manufacturing_finished_output_length`

## 11. `manuf_line_name` 缺失结论

- 当前状态：`pending_execution`
- 已有结论：
  - 缺失检查 SQL 已准备好

## 12. `group_manuf_line_name` 与 `manuf_line_name` 不一致结论

- 当前状态：`pending_execution`
- 已有结论：
  - 不一致检查 SQL 已准备好
  - 这一步会影响后续 `combined` 展示分组语义

## 13. `attr1` 保留结论

- 当前状态：`pending_execution`
- 已有结论：
  - `attr1` 在本层应保留
  - 不应在本层主动生成 `合计 / 总计`

## 14. `material_name / steel_grade_series` 维度变化结论

- 当前状态：`pending_execution`
- 已有结论：
  - 当前环境未确认稳定的 `material_name` 单列
  - 本轮优先看 `steel_grade_series`

## 15. zero-row 保留结论

- 当前状态：`pending_execution`
- 已有结论：
  - 零行保留检查 SQL 已准备好
  - 这是本层是否吞零行的关键判据

## 16. source-only / baseline-only rows 归因结论

- 当前状态：`pending_execution`
- 已有结论：
  - 两类蓝图 SQL 已准备好
  - 运行后可判断是 key 丢失还是聚合差异

## 17. 是否允许进入 `defined_manuf_line_name -> combined_candidate`

- `Yes`

原因：

- 本层验证蓝图已经完整
- 可以在不进入完整 `combined_local` 的前提下，推进到下一层候选评估

## 18. 是否允许进入完整 `combined_local`

- `No`

原因：

- `with_attr_value`
- `with_result_confirm`
- `ads_sc_xl_01`
- `合计 / 总计`

仍然是阻塞项。

## 19. 当前最大阻塞点

- `with_attr_value`

## 20. 下一轮建议

优先建议：

- 进入 `defined_manuf_line_name -> combined_candidate` 候选评估

前提：

- 仍然不直接写完整 `combined_local`
- 继续保持只读验证策略
