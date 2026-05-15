---
task_id: TASK-20260510-004-review-loop-warning-triage
title: "REVIEW LOOP warning 状态分诊与闭环建议"
owner: "用户"
target_agent: "深度研究智能体"
task_type: "REVIEW"
review: true
objective: "读取 heartbeat.json 与当前任务状态，分析 review_loop warning 的原因，明确 review backlog=1 与 blocked_failed=1 对应任务，并输出只读分诊建议，不执行修复动作。"
allowed_actions:
  - 读取 /root/wiki/tasks/status/heartbeat.json
  - 读取 /root/wiki/tasks/status/*.json
  - 读取 /root/wiki/tasks/logs/task_review_watcher.log
  - 读取 Multica 当前任务状态
  - 输出分诊报告
  - 更新 LLM Wiki/GitHub 知识记录
forbidden_actions:
  - 修改生产数据库
  - 修改 PolarDB
  - 修改 DolphinScheduler
  - 修改 DataX
  - 自动retry任务
  - 自动restart服务
  - 自动恢复服务
  - 自动创建生产任务
  - 删除任务
  - 关闭任务
  - force push
acceptance_criteria:
  - 明确 review backlog=1 对应哪个任务
  - 明确 blocked_failed=1 对应哪个任务
  - 判断是否需要人工处理
  - 判断是否可归档/废弃/保留观察
  - 不执行任何修复动作
  - 输出报告路径和 commit id
output_paths:
  - "/root/multica-work/output/20260510-review-loop-warning分诊报告.md"
  - "/root/wiki/20-resources/review-loop-warning-triage.md"
knowledge_update_required: true
timeout_minutes: 20
created_at: "2026-05-10T08:05:00+09:00"
---

# REVIEW LOOP warning 状态分诊任务

## 背景
ChatGPT 已从 GitHub 读取到 heartbeat.json，显示：
- inbox_loop: ok
- review_loop: warning
- review_backlog: 1
- blocked_failed: 1
- errors: 0

这说明脚本本身正常，但巡检发现有任务待处理。

## 目标
只读分析 warning 的原因，明确具体任务，并提出下一步建议。

## 检查项
001 当前 heartbeat 最新内容；
002 review_backlog=1 对应任务；
003 blocked_failed=1 对应任务；
004 是否需要用户人工判断；
005 是否有可直接归档的历史任务；
006 是否存在任务状态文件与 Multica 实际状态不一致。

## 输出要求
生成：
`/root/multica-work/output/20260510-review-loop-warning分诊报告.md`

并更新：
`/root/wiki/20-resources/review-loop-warning-triage.md`

最终推送 GitHub，记录 commit id。

## 边界
本任务只做分诊和建议，不做自动修复、不重试、不关闭任务、不动生产。
