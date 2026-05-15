# candidate execution validation plan

## 1. 本轮目标

本轮只推进：

- `candidate execution validation plan`
- P1 支撑链执行验证准备
- total_rows 后置聚合执行验证准备

本轮不推进：

- 完整 `combined_local`
- 生产写表 SQL
- 任何生产库写操作

## 2. 已读取依据文件

- `README.md`
- `docs/01_current_status.md`
- `docs/08_automation_registry.md`
- `docs/09_execution_wip_policy.md`
- `docs/10_executor_no_midpoint_prompt_policy.md`
- `lineage/ads_sc_xl_13/01_main_chain.md`
- `lineage/ads_sc_xl_13/02_supporting_chains.md`
- `lineage/ads_sc_xl_13/05_missing_links.md`
- `lineage/ads_sc_xl_13/06_next_rebuild_order.md`
- `lineage/ads_sc_xl_13/combined_candidate_readiness.md`
- `lineage/ads_sc_xl_13/combined_candidate_blueprint.md`
- `lineage/ads_sc_xl_13/complete_combined_local_readiness_gate.md`
- `lineage/ads_sc_xl_13/supporting/with_attr_value_attr1_manuf_line_name_closure.md`
- `lineage/ads_sc_xl_13/supporting/with_attr_value_warehouse_doc_type_closure.md`
- `lineage/ads_sc_xl_13/supporting/ads_sc_xl_01_local_join_skeleton.md`
- `lineage/ads_sc_xl_13/supporting/with_result_confirm_local_closure.md`
- `lineage/ads_sc_xl_13/supporting/total_rows_postprocess_impact.md`
- `lineage/ads_sc_xl_13/supporting/total_rows_postprocess_local_plan.md`
- `sql/inspect/ads_sc_xl_13/inspect_combined_candidate_inputs.sql`
- `sql/recon/ads_sc_xl_13/recon_combined_candidate_blueprint.sql`
- `audit/ads_sc_xl_13/runs/20260426_161811/00_run_summary.md`

## 3. candidate execution validation 的定位

它是：

- 在真实只读执行环境里，按顺序运行 inspect/recon SQL 的执行方案
- 用来收集 evidence、判断 P1 支撑链是否从 blueprint 进入 executed/closed

它不是：

- 完整 `combined_local` 执行
- 生产写表方案

## 4. candidate blueprint 与 execution validation 的区别

### blueprint

- 解决“怎么设计”
- 输出 skeleton、gate、recon 蓝图

### execution validation

- 解决“在只读执行环境里怎么验证”
- 输出执行顺序、证据留痕、pass/fail 规则

## 5. 本轮允许验证什么

- inspect SQL 执行顺序
- recon SQL 执行顺序
- evidence 模板
- pass/fail gate
- blocker 分类

## 6. 本轮禁止验证什么

- 直接执行写表 SQL
- 直接生成完整 `combined_local`
- 把 partial/pending_execution 宣称为 closed

## 7. 输入链路清单

- `defined_manuf_line_name`
- `with_attr_value`
- `ads_sc_xl_01_local`
- `with_result_confirm_local`
- `total_rows_postprocess_local`

## 8. 输入链路执行前置条件

- 具备只读 SQL 执行权限
- 能读取相关物理表
- 能回收 row count / distinct key / coverage / diff 结果

## 9. P1 支撑链验证顺序

1. `with_attr_value attr1/manuf_line_name`
2. `with_attr_value warehouse/doc_type`
3. `ads_sc_xl_01_local`
4. `with_result_confirm_local`
5. `total_rows_postprocess_local`

## 10. candidate SQL 执行顺序建议

1. `inspect_combined_candidate_inputs.sql`
2. `recon_with_attr_value_mapping.sql`
3. `recon_with_attr_value_warehouse_doc_type.sql`
4. `recon_ads_sc_xl_01_local_join.sql`
5. `recon_with_result_confirm_local.sql`
6. `recon_total_rows_postprocess.sql`
7. `recon_combined_candidate_blueprint.sql`
8. `recon_candidate_execution_validation_plan.sql`

## 11. inspect SQL 执行顺序建议

1. `inspect_with_attr_value.sql`
2. `inspect_with_attr_value_warehouse_doc_type.sql`
3. `inspect_ads_sc_xl_01_local.sql`
4. `inspect_with_result_confirm_local.sql`
5. `inspect_total_rows_postprocess.sql`
6. `inspect_combined_candidate_inputs.sql`

## 12. recon SQL 执行顺序建议

1. 配置链 recon
2. 入库链 recon
3. 人工确认链 recon
4. 后置聚合 recon
5. candidate 综合 recon
6. execution validation 总结 recon

## 13. pass/fail gate

- `Pass`
  - 关键 key coverage 可解释
  - source-only / baseline-only 可解释
  - metric diff 处于可解释范围
- `Fail`
  - 关键 key coverage 严重缺口
  - 未映射行不可解释
  - metric diff 大面积不可解释
- `Blocked`
  - 没有数据库只读权限
  - 关键物理表不存在
  - 需要业务澄清而无法继续

## 14. evidence 采集要求

- 保留 SQL 文件名
- 保留执行时间
- 保留 row count / distinct key / coverage / diff
- 保留 blocker / clarification

## 15. 结果回填要求

- 回写 `audit/ads_sc_xl_13/execution_evidence_template.md`
- 回写对应 issue 评论
- 不得只留在终端输出

## 16. 如果无数据库执行权限的处理方式

- 标记 `pending_execution`
- 仍然提交执行计划、runbook、evidence 模板
- 不强行编造执行结果

## 17. 当前状态

- `ready_for_execution_validation_plan`
- `pending_execution`

## 18. 下一步建议

- `readonly execution dry-run package`
