# 重构原则

## 审计原则

1. 只读分析
2. 不改库
3. 不改任务
4. 不改 DataX 配置
5. 不做修复
6. 先摸清链路，再谈问题
7. 不只看主链，必须把支线链路也拉出来

## 文件化原则

1. 所有结论必须落到文件
2. 所有链路必须结构化
3. 所有路径、命名、编号必须稳定
4. Mermaid 图、CSV、Markdown、SQL 要相互可追踪
5. ChatGPT 后续读取时不依赖终端上下文

## 重构原则

1. 先重建支撑链，再重建主链
2. 先重建 `combined`，再投影到 `_001 / _002`
3. 先对 `day_weight`，再扩展其他字段
4. 先做表级与字段级口径确认，再做全量 row-level diff

## 当前阶段禁止项

- 禁止执行 `DROP`
- 禁止执行 `DELETE`
- 禁止执行 `UPDATE`
- 禁止执行 `INSERT`
- 禁止执行 `TRUNCATE`
- 禁止执行 `INSERT OVERWRITE`

数据库审计 SQL 只允许：

- `SELECT`
- `SHOW`
- `DESC`
- `EXPLAIN`
