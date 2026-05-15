# Runtime首脑 与 Codex 分工边界

时间：2026-05-10
状态：生效

## 001 核心裁决

Runtime首脑 是 Runtime 治理执行 owner。
Codex 只是临时工具工，不作为长期运行中枢。

后续状态收口、任务巡检、生命周期治理、heartbeat、review backlog、done/archive、ghost task、状态差异处理，默认由 Runtime首脑负责。

Codex 只负责：

- 写脚本；
- 修脚本；
- 探测 CLI；
- 搭建 Command Gateway；
- dry-run 验证；
- 输出工具实现报告。

Codex 不负责长期盯任务，不负责最终运行治理，不负责替代 Runtime首脑。

## 002 当前 approved 状态收口任务归属

文件：

```text
20-resources/runtime-approved-status-closure-20260510.md
```

任务 owner：Runtime首脑。

执行方式：Runtime首脑 读取授权文件后，使用已由 Codex 搭好的 Command Gateway / multica CLI 能力执行状态收口。

Codex 只在工具不可用时补工具，不主动接管业务任务。

## 003 Runtime首脑 本轮必须执行

Runtime首脑 需要完成：

- 读取 approved 授权文件；
- 再次读取 Multica 当前状态；
- 仅处理授权文件列出的 LEE 编号；
- 执行状态收口；
- 写入 done/failed 审计 JSON；
- 更新 runtime-governor-report.md；
- 输出 review backlog 前后变化；
- 输出 GitHub commit id。

## 004 Codex 后续定位

Codex 后续只在以下场景使用：

- Command Gateway 缺能力；
- CLI 参数变化；
- 脚本报错；
- 需要新增 dry-run 类型；
- 需要修复 process_runtime_command.py。

不再默认让 Codex 领取 Runtime 业务治理任务。

## 005 边界

Runtime首脑 和 Codex 都不得修改生产数据库、DolphinScheduler、DataX、PolarDB，不得重跑生产任务，不得自动补数，不得泄露密钥，不得 force push。
