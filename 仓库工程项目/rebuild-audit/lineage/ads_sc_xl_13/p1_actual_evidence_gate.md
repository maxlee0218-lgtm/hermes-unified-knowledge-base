# P1 actual evidence gate

## Rule

- 没有 actual evidence 不得进入 complete `combined_local`
- readonly dry-run `ready` 只表示执行准备完成
- actual evidence 必须来自真实只读执行结果
- business clarification 未解决不得硬编码

## Gate Table

| Gate ID | Gate name | Required evidence | Current status | Can proceed? | Reason | Next action |
|---|---|---|---|---|---|---|
| `AE-001` | `with_attr_value attr1/manuf_line_name` actual evidence | row count / key coverage / unmapped rows | `pending_execution` | `No` | no actual readonly evidence yet | collect evidence |
| `AE-002` | `with_attr_value warehouse/doc_type` actual evidence | scene coverage / source-only / baseline-only | `pending_execution` | `No` | no actual readonly evidence yet | collect evidence |
| `AE-003` | `ads_sc_xl_01_local` actual evidence | join coverage / key summary / metric summary | `pending_execution` | `No` | no actual readonly evidence yet | collect evidence |
| `AE-004` | `with_result_confirm_local` actual evidence | confirm coverage / downtime impact / remark impact | `pending_execution` | `No` | no actual readonly evidence yet | collect evidence |
| `AE-005` | `total_rows_postprocess_local` actual evidence | summary row existence / reducibility | `pending_execution` | `No` | no actual readonly evidence yet | collect evidence |
| `AE-006` | `combined_candidate` actual evidence | candidate key/metric coverage | `pending_execution` | `No` | no actual readonly evidence yet | collect evidence |
| `AE-007` | complete `combined_local` gate | all P1 actual evidence closed/pass | `blocked` | `No` | any pending/blocked P1 gate blocks complete combined_local | keep blocked |
