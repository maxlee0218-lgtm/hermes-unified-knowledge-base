# readonly execution dry-run runbook

## 1. dry-run 目标

在不写生产库的前提下：

- 顺序执行 inspect / recon SQL
- 收集 P1 支撑链 evidence
- 判断是否具备进入下一阶段的 go/no-go 条件

## 2. 允许 SQL 类型

- `SELECT`
- `SHOW`
- `DESC`
- `EXPLAIN`

## 3. 禁止 SQL 类型

- `DROP`
- `DELETE`
- `UPDATE`
- `INSERT`
- `TRUNCATE`
- `INSERT OVERWRITE`
- `CTAS`
- `CREATE TABLE`

## 4. inspect SQL 执行顺序

1. `inspect_with_attr_value.sql`
2. `inspect_with_attr_value_warehouse_doc_type.sql`
3. `inspect_ads_sc_xl_01_local.sql`
4. `inspect_with_result_confirm_local.sql`
5. `inspect_total_rows_postprocess.sql`
6. `inspect_combined_candidate_inputs.sql`

## 5. recon SQL 执行顺序

1. `recon_with_attr_value_mapping.sql`
2. `recon_with_attr_value_warehouse_doc_type.sql`
3. `recon_ads_sc_xl_01_local_join.sql`
4. `recon_with_result_confirm_local.sql`
5. `recon_total_rows_postprocess.sql`
6. `recon_combined_candidate_blueprint.sql`
7. `recon_candidate_execution_validation_plan.sql`
8. `recon_readonly_execution_dry_run.sql`

## 6. P1 evidence 采集顺序

1. `with_attr_value attr1/manuf_line_name`
2. `with_attr_value warehouse/doc_type`
3. `ads_sc_xl_01_local`
4. `with_result_confirm_local`
5. `total_rows_postprocess_local`

## 7. candidate input coverage 检查

- 主链 key 分布
- 配置链 scene 覆盖
- 入库链 join skeleton coverage
- 人工确认链 key/metric coverage

## 8. total_rows_postprocess 检查

- `attr1='合计'` 是否存在
- `manuf_line_name='总计'` 是否存在
- 是否能从非 summary 行重算

## 9. pass/fail 判断

- `Pass`
  - key/metric/coverage 结果可解释
- `Fail`
  - 大量 source-only / baseline-only / unmapped 且不可解释
- `Blocked`
  - 无数据库只读执行权限
  - 关键表不存在
  - 需业务澄清

## 10. go/no-go gate

- `go_for_evidence_collection`
  - dry-run 包已具备，可进入证据采集
- `blocked_for_complete_combined_local`
  - 任一 P1 支撑链无 actual evidence

## 11. `pending_execution` 处理

- 没有执行环境时标记 `pending_execution`
- 不编造结果
- 仍回填计划和下一步

## 12. 回写格式

- 回写 issue 评论
- 回写 evidence ledger
- 回写 run summary
