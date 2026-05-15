---
task_id: TASK-20260510-001-agent-collaboration-hardening
title: "Agent 协同机制加固：免人工转发模式"
owner: 数据专家
target_agent: 数据专家
task_type: "PLAN"
objective: "在不需要用户转发长文本的前提下，检查并加固 ChatGPT → GitHub任务入口 → PocketClaw定时扫描 → Multica分发 → Agent执行 → REVIEW/DONE → LLM Wiki/GitHub沉淀 的协同闭环。"
allowed_actions:
  - 读取 GitHub /root/wiki 本地同步内容
  - 检查 tasks/inbox active review done archived status logs 目录
  - 检查 PocketClaw 10分钟触发日志
  - 检查 task_inbox_check.sh 执行状态
  - 检查 Multica Issue 创建状态
  - 输出协同机制加固报告
  - 更新 LLM Wiki 和 GitHub
forbidden_actions:
  - 修改生产数据库
  - 修改 PolarDB
  - 修改 DolphinScheduler 生产任务
  - 修改 DataX 生产配置
  - 自动恢复服务
  - 自动上线
  - 修改密钥/token/白名单
  - force push
  - 删除历史任务或报告
  - 创建生产变更任务
acceptance_criteria:
  - 确认 GitHub 任务入口可被 PocketClaw 拉取
  - 确认任务状态流转规则有效
  - 确认高风险任务不会自动执行
  - 输出当前协同链路状态报告
  - 输出发现的问题和修正建议
  - 如有必要，只提交低风险脚本文档修正建议，不直接扩大自动化范围
output_paths:
  - "/root/multica-work/output/20260510-Agent协同机制加固报告.md"
  - "/root/wiki/20-resources/agent-collaboration-runtime.md"
knowledge_update_required: true
timeout_minutes: 30
created_at: "2026-05-10T07:00:00+09:00"
---

# Agent 协同机制加固任务

## 背景
用户明确要求：继续推进 Agent 协同机制，但不要再让用户人工转发任何任务内容。

当前系统已经具备：
- ChatGPT 可直接写入 GitHub 仓库 `llm-wiki`
- PocketClaw 每10分钟触发本地 watcher
- `/root/wiki/tasks/inbox/` 作为任务入口
- `task_inbox_check.sh` 创建 Multica Issue
- 主脑负责监控、验收、归档、知识沉淀

## 目标
验证并加固以下链路：

```text
ChatGPT
→ GitHub: tasks/inbox/*.md
→ PocketClaw 10分钟 git pull / watcher
→ task_inbox_check.sh
→ Multica Issue
→ Agent执行
→ REVIEW
→ DONE
→ LLM Wiki + GitHub沉淀
```

## 执行边界
本任务是 PLAN / KNOWLEDGE / TEST 类任务，只允许检查和输出建议，不允许触发生产变更。

## 重点检查项

001 GitHub 任务入口：
- 是否能看到本任务文件；
- 是否已通过 git pull 同步到 `/root/wiki/tasks/inbox/`；
- 是否存在重复任务风险。

002 PocketClaw 触发：
- 最近两次触发时间；
- 是否执行 `task_inbox_check.sh`；
- 是否有错误日志。

003 任务状态流转：
- 是否从 inbox 进入 active；
- 是否生成 status json；
- 是否创建 Multica Issue；
- REVIEW 阈值是否生效。

004 安全边界：
- 高风险动作是否被 forbidden_actions 拦截；
- 是否仍保持有限正式运行；
- 是否禁止自动生产变更。

005 协同免转发能力：
- 用户是否已不需要复制长文本；
- ChatGPT 写 GitHub 后，任务是否能自动进入主脑流程；
- 如不能，指出阻断点。

## 输出要求

生成：
`/root/multica-work/output/20260510-Agent协同机制加固报告.md`

报告必须包含：
- 当前协同链路状态；
- 本任务是否被自动拉取；
- PocketClaw触发记录；
- Multica Issue创建结果；
- 是否存在阻断；
- 修正建议；
- 是否需要用户介入；
- 下一阶段建议。

## 知识沉淀
如本任务成功验证“ChatGPT → GitHub → PocketClaw → Multica”链路，请更新：
`/root/wiki/20-resources/agent-collaboration-runtime.md`

并推送 GitHub，记录 commit id。
