# P1 business clarification split

## actual execution blocker

- 没有真实只读执行结果
- 没有 row count / coverage / diff 实测结果

## business semantic blocker

- `with_result_confirm` 中 `report_id = 237 / 239 / 543` 的权威日/月 override 字段
- `with_attr_value` 的 warehouse/doc-type scene family 中 `attribute*` slot 到业务字段的映射
- `attr1='合计'` 与 `manuf_line_name='总计'` 的生成层级
- `zero-fill` 是否参与 `total_rows / postprocess`

## tooling / connector blocker

- 当前线程没有直接数据库真实只读执行证据
- 需要在后续 actual readonly execution 环境中运行 SQL

## documentation blocker

- `docs/11_executor_heartbeat_reporting_policy.md` 当前 `not_found`
- completion receipt 的 `Heartbeat status` 只能用 fallback 方式补齐，不能引用文件原文
