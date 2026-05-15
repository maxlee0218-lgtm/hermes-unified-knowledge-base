# Runtime 执行指令：待审核收口

时间：2026-05-10
发起方：ChatGPT
接收方：Runtime首脑
模式：允许执行低风险任务状态收口；禁止生产变更。

## 目标

当前 in_review 长期停留约 7 个，DRY-RUN 只会报告，不能解决堆积。本轮目标是实际降低 review backlog。

## 允许执行

1. LEE-23：如确认为测试/重复任务，标记 cancelled 或 closed，并记录原因。
2. LEE-25：如确认为与 LEE-26 重复，标记 duplicate/closed，保留 LEE-26。
3. LEE-31：转交 Kimi Claw Windows Worker 做只读补证；如果无法转交，标记 blocked 并写明原因。
4. LEE-29、LEE-30、LEE-32、LEE-33、LEE-34、LEE-35：逐项检查报告与 Wiki。
   - 有报告和 Wiki 的，标记 done。
   - 缺报告的，标记 blocked 或 waiting_for_report。
   - 缺 Wiki 的，要求原 Agent 补 Wiki，不继续占用 review_ready。
5. TASK-20260510-004：如对应 LEE-28 已 done，清理 inbox 残留或标记 archived-residue。
6. 本地 active ghost 文件：按 Multica 真实状态迁移或标记 ghost-resolved。
7. heartbeat：更新 owner，明确 inbox_loop 由 Runtime首脑接管。
8. 更新 runtime-governor-report.md，必须输出 review backlog 变化前后数量。

## 禁止执行

- 不修改生产数据库
- 不修改 PolarDB
- 不修改 DolphinScheduler
- 不修改 DataX
- 不重跑生产任务
- 不自动补数
- 不删除业务文件
- 不读取或写入密钥原文
- 不 force push

## 验收标准

1. review backlog 必须从当前数量下降，或逐项给出无法下降的原因。
2. LEE-23 有最终处理状态。
3. LEE-25 有最终处理状态。
4. LEE-31 已转入 Kimi Claw 或明确 blocked 原因。
5. 每个 in_review 任务都有最终分类：done / blocked / waiting_for_report / duplicate / manual_decision。
6. runtime-governor-report.md 已更新。
7. GitHub commit id 已输出。
