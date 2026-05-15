---
task_id: TASK-20260510-003-loop-heartbeat-to-github
title: "为 inbox loop / review loop 增加 GitHub 可见 heartbeat"
owner: "用户"
target_agent: "深度研究智能体"
task_type: "KNOWLEDGE"
knowledge: true
objective: "在不扩大自动执行权限的前提下，为 PocketClaw 的 10分钟 inbox loop 和 5分钟 review loop 增加可被 ChatGPT 从 GitHub 侧检查的 heartbeat 文件与同步规则。"
allowed_actions:
  - 检查 task_inbox_check.sh
  - 检查 task_review_check.sh
  - 设计 heartbeat.json 格式
  - 创建或更新 /root/wiki/tasks/status/heartbeat.json
  - 设计最小安全 GitHub 同步方式
  - 更新 RUNTIME_BASELINE.md
  - 输出 heartbeat 机制报告
  - 推送 GitHub
forbidden_actions:
  - 修改生产数据库
  - 修改 PolarDB
  - 修改 DolphinScheduler
  - 修改 DataX
  - 自动恢复服务
  - 自动retry任务
  - 自动restart服务
  - 自动创建生产任务
  - 修改密钥/token/白名单
  - force push
  - 删除历史任务或报告
  - 扩大允许任务类型
acceptance_criteria:
  - heartbeat.json 包含 inbox_loop_last_run
  - heartbeat.json 包含 review_loop_last_run
  - heartbeat.json 包含两个 loop 的最近状态
  - heartbeat.json 不包含密钥、token、数据库信息
  - ChatGPT 可通过 GitHub 读取 heartbeat 判断两个 loop 是否运行
  - 不改变两个 loop 的执行边界
  - 更新 LLM Wiki/GitHub 并输出 commit id
output_paths:
  - "/root/wiki/tasks/status/heartbeat.json"
  - "/root/multica-work/output/20260510-loop-heartbeat机制报告.md"
  - "/root/wiki/20-resources/pocketclaw-loop-heartbeat.md"
knowledge_update_required: true
timeout_minutes: 30
created_at: "2026-05-10T07:45:00+09:00"
---

# 为两个 PocketClaw 定时循环增加 GitHub 可见 heartbeat

## 背景
用户希望 ChatGPT 能从后台判断两个 PocketClaw 定时任务是否仍在持续运行。
目前日志和 status 主要在 150 本地，ChatGPT 只能看到 GitHub，无法确认两个 loop 当前是否活着。

## 目标
建立一个最小可观测 heartbeat 文件：

`/root/wiki/tasks/status/heartbeat.json`

并通过安全方式同步到 GitHub，使 ChatGPT 可以读取该文件判断：
- 10分钟 inbox loop 最近是否执行；
- 5分钟 review loop 最近是否执行；
- 两个 loop 是否有错误；
- 是否处于有限正式运行边界内。

## 建议 heartbeat 格式

```json
{
  "updated_at": "2026-05-10 07:45:00+09:00",
  "inbox_loop": {
    "last_run": "2026-05-10 07:40:00+09:00",
    "status": "ok",
    "last_log": "inbox scanned, no new task",
    "last_issue_created": null
  },
  "review_loop": {
    "last_run": "2026-05-10 07:43:00+09:00",
    "status": "ok",
    "blocked_count": 1,
    "review_count": 0
  },
  "mode": "limited_formal_run",
  "forbidden_actions_enforced": true
}
```

## 执行边界
本任务只允许新增观测能力，不允许扩大自动化范围。

## 必须判断
001 是否由两个脚本分别更新同一个 heartbeat 文件；
002 是否需要文件锁，避免并发写冲突；
003 是否每次运行都 git commit/push，还是按频率/变化阈值同步；
004 如何避免 5分钟一次 push 造成 GitHub 噪声；
005 最推荐的最小方案。

## 推荐原则
不要每5分钟都 push。优先考虑：
- 本地每次更新 heartbeat；
- 每30分钟或状态变化时再 commit/push；
- 或由单独 sync 脚本同步 heartbeat。

## 输出要求
输出：
`/root/multica-work/output/20260510-loop-heartbeat机制报告.md`

并更新：
`/root/wiki/20-resources/pocketclaw-loop-heartbeat.md`

最终推送 GitHub，记录 commit id。
