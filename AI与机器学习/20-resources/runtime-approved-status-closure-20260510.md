# Runtime Approved 状态收口授权

时间：2026-05-10
授权方：用户，经 ChatGPT 转达
接收方：Runtime首脑 / Codex Command Gateway
模式：approved，仅限本文件列出的 LEE 状态收口动作

## 001 授权范围

用户已批准执行以下 Multica Issue 状态收口命令：

| Issue | 目标状态 | 原因 |
|---|---|---|
| LEE-23 | cancelled | 历史测试/重复任务 |
| LEE-25 | cancelled | 与 LEE-26 重复，保留 LEE-26 |
| LEE-29 | done | 已有报告和 Wiki |
| LEE-32 | done | 已有报告和 Wiki |
| LEE-33 | done | 已有报告和 Wiki |
| LEE-34 | done | 已有报告和 Wiki |
| LEE-35 | done | 已有报告和 Wiki |
| LEE-30 | blocked | 缺 Windows D 盘报告，等待补证 |
| LEE-31 | blocked | 等待 Kimi Claw Windows Worker 补证 |

同时允许给 LEE-30 写入说明评论：等待 Windows D 盘报告补证。

## 002 执行要求

1. 执行前再次读取当前 Multica 状态，避免状态漂移。
2. 只处理本文件列出的 LEE 编号。
3. 使用 Command Gateway 已验证的命令能力执行。
4. 每条命令执行后写入 done/failed JSON。
5. 更新 runtime-governor-report.md。
6. 输出 review backlog 变化前后数量。
7. 输出 GitHub commit id。

## 003 绝对禁止

- 不处理本文件之外的 Issue；
- 不修改生产数据库；
- 不修改 PolarDB；
- 不修改 DolphinScheduler；
- 不修改 DataX；
- 不重跑生产任务；
- 不自动补数；
- 不删除业务文件；
- 不泄露密钥；
- 不 force push。

## 004 验收标准

执行完成后必须满足：

1. LEE-23 状态已收口。
2. LEE-25 状态已收口，LEE-26 保留。
3. LEE-29/32/33/34/35 已转 done。
4. LEE-30/31 已转 blocked 或等价等待补证状态。
5. review backlog 明显下降。
6. failed=0 或逐项说明失败原因。
7. runtime-governor-report.md 已更新。
8. GitHub 有执行报告和 commit id。
