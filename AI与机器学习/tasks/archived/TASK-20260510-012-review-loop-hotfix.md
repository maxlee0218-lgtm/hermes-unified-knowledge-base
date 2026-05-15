---
task_id: TASK-20260510-012-review-loop-hotfix
title: "P0：修复 PocketClaw 五分钟 REVIEW LOOP 待审核堆积识别问题"
owner: "用户"
target_agent: "数仓管家"
task_type: "RUNTIME_MONITOR"
priority: "P0"
objective: "修复 task_review_check.sh 对待审核任务堆积识别不完整的问题，确保它能同时识别本地 /root/wiki/tasks/review 目录和 Multica in_review/review 状态中的任务，并正确写入 review_loop_status.json、review_alert 与 heartbeat。"
allowed_actions:
  - 读取 /root/wiki/tasks/task_review_check.sh
  - 读取 /root/wiki/tasks/logs/task_review_watcher.log
  - 读取 /root/wiki/tasks/status/review_loop_status.json
  - 读取 /root/wiki/tasks/status/heartbeat.json
  - 读取 Multica 当前任务状态
  - 修改 task_review_check.sh 的只读巡检逻辑
  - 增加 Multica in_review/review 任务统计
  - 增加 review_stuck 检查
  - 修复 heartbeat 标准结构写入
  - dry-run 验证
  - 输出修复报告
  - 更新 LLM Wiki/GitHub
forbidden_actions:
  - 自动验收任务
  - 自动关闭任务
  - 自动 retry 任务
  - 自动 restart 服务
  - 自动恢复服务
  - 修改生产数据库
  - 修改 PolarDB
  - 修改 DolphinScheduler
  - 修改 DataX
  - 删除任务文件
  - force push
  - 泄露密码/token/密钥/连接串
acceptance_criteria:
  - 明确当前待审核堆积的真实数量
  - 明确为什么旧脚本未正确识别待审核堆积
  - review_loop_status.json 同时包含 local_review_count 与 multica_review_count
  - review_loop_status.json 包含 review_stuck_count
  - review_alert 能列出具体 LEE 编号和任务标题
  - heartbeat 恢复为 inbox_loop/review_loop 标准结构
  - 不执行任何自动验收/关闭/重试动作
  - dry-run 通过
  - 更新 Wiki/GitHub 并记录 commit id
output_paths:
  - "/root/multica-work/output/20260510-review-loop-hotfix报告.md"
  - "/root/wiki/20-resources/review-loop-hotfix-20260510.md"
knowledge_update_required: true
timeout_minutes: 30
created_at: "2026-05-10T10:05:00+08:00"
---

# P0：修复 PocketClaw 五分钟 REVIEW LOOP 待审核堆积识别问题

## 背景
用户观察到 PocketClaw 五分钟 review loop 存在问题：后台待审核任务已经堆积，但 review loop 没有正确收口或提醒。

当前配置：

```text
任务名称：任务review检查
执行频率：每5分钟
执行命令：bash /root/wiki/tasks/task_review_check.sh
工作目录：/root/wiki/tasks
超时时间：3分钟
失败重试：0
日志输出：/root/wiki/tasks/logs/task_review_watcher.log
```

## 已知线索
当前 GitHub 中的 review_loop_status.json 显示：

```json
{
  "check_time": "2026-05-10 09:53:25",
  "issues_found": 4,
  "running_timeout": 2,
  "review_backlog": 0,
  "done_unarchived": 4,
  "blocked_failed": 1,
  "missing_status": 0,
  "knowledge_pending": 4,
  "github_pending": 1,
  "requires_attention": true
}
```

但用户实际看到后台存在待审核堆积。

初步判断：

```text
旧脚本只统计 /root/wiki/tasks/review/*.md，未统计 Multica 中 in_review/review 状态的任务。
```

## 必须修复

### 001 统计口径修复
review loop 必须同时统计：

1. 本地 review 目录：`/root/wiki/tasks/review/*.md`
2. Multica review 状态：`in_review` / `review` / `review_ready` 等实际状态
3. 已完成但未进入 done 的任务
4. active 超时任务
5. review_stuck 任务

### 002 状态文件修复
`review_loop_status.json` 必须至少包含：

```json
{
  "check_time": "...",
  "local_review_count": 0,
  "multica_review_count": 0,
  "review_backlog_total": 0,
  "review_stuck_count": 0,
  "running_timeout": 0,
  "done_unarchived": 0,
  "blocked_failed": 0,
  "knowledge_pending": 0,
  "github_pending": 0,
  "requires_attention": true
}
```

### 003 alert 修复
如果待审核堆积，alert 必须列出：

- LEE 编号；
- 任务标题；
- 状态；
- 卡住时长；
- 建议动作：人工验收 / 补报告 / 保持 blocked。

### 004 heartbeat 修复
当前 heartbeat.json 被污染为闭环收口摘要。必须恢复为标准结构：

```json
{
  "schema_version": "1.0",
  "updated_at": "...",
  "inbox_loop": {...},
  "review_loop": {...},
  "mode": "limited_formal_run",
  "forbidden_actions_enforced": true
}
```

### 005 严格边界
本任务只修复识别、提醒、状态和心跳。

禁止：

- 自动验收；
- 自动关闭；
- 自动重试；
- 自动恢复；
- 自动改生产。

## 验收标准
修复后，用户应能通过 GitHub 看到：

- review loop 最近一次运行；
- 待审核真实数量；
- 哪些 LEE 卡在 review；
- 哪些 active 超时；
- 哪些 done 未归档；
- 哪些需要人工决策。
