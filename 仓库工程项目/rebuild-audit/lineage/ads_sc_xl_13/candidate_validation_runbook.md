# candidate validation runbook

## 1. 如何按顺序运行 inspect SQL

1. `inspect_with_attr_value.sql`
2. `inspect_with_attr_value_warehouse_doc_type.sql`
3. `inspect_ads_sc_xl_01_local.sql`
4. `inspect_with_result_confirm_local.sql`
5. `inspect_total_rows_postprocess.sql`
6. `inspect_combined_candidate_inputs.sql`

## 2. 如何按顺序运行 recon SQL

1. `recon_with_attr_value_mapping.sql`
2. `recon_with_attr_value_warehouse_doc_type.sql`
3. `recon_ads_sc_xl_01_local_join.sql`
4. `recon_with_result_confirm_local.sql`
5. `recon_total_rows_postprocess.sql`
6. `recon_combined_candidate_blueprint.sql`
7. `recon_candidate_execution_validation_plan.sql`

## 3. 如何记录 evidence

- 使用 `audit/ads_sc_xl_13/execution_evidence_template.md`
- 一次执行一份证据

## 4. 如何判断 pass/fail

- Pass:
  - key / metric / coverage 可解释
- Fail:
  - 缺口不可解释

## 5. 如何处理 `pending_execution`

- 标记原因
- 不编造结果

## 6. 如何处理 source-only / baseline-only

- 记录 key 集合
- 判断是配置缺口还是后置聚合缺口

## 7. 如何处理 metric diff

- 先判定影响链
- 再回溯到具体支撑链

## 8. 如何处理 `合计 / 总计` 后置行

- 先验证它是否可从明细重算
- 再判断是否属于 summary-only 逻辑

## 9. 如何处理 `needs_business_clarification`

- 不要猜
- 记录为业务澄清问题

## 10. 如何回写 GitHub Issue

- 回写 commit / evidence / blocker / next step
