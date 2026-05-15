# Runtime 下一步执行清单

时间：2026-05-10

## 目标

收口当前 Runtime 状态差异，并把 Kimi Claw Windows Worker 纳入补证链路。

## Runtime首脑 处理项

1. LEE-23：标记为无继续推进价值的历史测试项。
2. LEE-25：标记为与 LEE-26 重复，保留 LEE-26。
3. LEE-31：转入 Kimi Claw Windows Worker 补证链路。
4. LEE-29、LEE-30、LEE-32、LEE-33、LEE-34、LEE-35：要求提交中间报告或明确缺口。
5. done 未归档任务：生成分批归档摘要。
6. inbox 残留与 ghost active 文件：按 Multica 当前状态生成同步建议。
7. heartbeat：将 inbox_loop owner 明确为 Runtime首脑。
8. 更新 runtime-governor-report.md，并提交 GitHub。

## Kimi Claw Windows Worker 处理项

首个任务：Windows 接入握手与 LEE-31 补证。

输出：

- kimi-claw-windows-worker-handshake.md
- lee31-windows-c-drive-evidence.md

要求：只读摸排 Windows C/D 盘、D:\AIWorker、dbt、Dolphin、测试数仓、速程监控相关痕迹。

## Codex 处理项

继续完成 Command Gateway SPIKE：

- runtime-commands 目录
- process_runtime_command.py
- create_issue dry-run
- done/failed JSON
- multica-command-gateway-spike-report.md

## 边界

只做 Runtime 状态治理、报告、归档摘要和只读补证。不处理生产变更，不处理敏感信息，不做强制推送。

## 验收

- LEE-23、LEE-25 有明确收口结论
- LEE-31 进入 Kimi Claw 补证链路
- review_stuck 有中间报告或缺口说明
- done 未归档有分批摘要
- ghost active 数量下降或有处理建议
- inbox_loop owner 明确
- Command Gateway dry-run 报告出现
