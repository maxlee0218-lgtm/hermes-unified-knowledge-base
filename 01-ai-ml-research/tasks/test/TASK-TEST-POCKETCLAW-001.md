---
task_id: TASK-TEST-POCKETCLAW-001
title: "【测试】PocketClaw定时入口机制dry-run验证"
owner: "主脑"
target_agent: "主脑"
objective: "验证PocketClaw → task_inbox_check.sh → 状态文件生成 → 日志记录 → 不误触生产动作"
allowed_actions:
  - 文件读取
  - 状态文件生成
  - 日志写入
  - dry-run输出
forbidden_actions:
  - 连接数据库
  - 创建生产Issue
  - 调度Windows Agent
  - 修改生产配置
  - 写生产PolarDB
  - 改生产DolphinScheduler
  - 改生产DataX
  - 自动上线
acceptance_criteria:
  - 脚本能读取测试任务
  - 能识别task_id
  - 能生成status json
  - 能写入logs
  - 不创建真实生产任务
  - 不改动生产
output_paths:
  - "/root/wiki/tasks/logs/task_inbox_watcher.log"
  - "/root/wiki/tasks/status/TASK-TEST-POCKETCLAW-001.json"
knowledge_update_required: false
timeout_minutes: 5
created_at: "2026-05-09T23:55:00+08:00"
---

# 测试任务描述

## 背景
验证PocketClaw定时拉取任务机制是否正常工作，不误触生产动作。

## 目标
1. 验证task_inbox_check.sh能读取inbox任务文件
2. 验证能识别task_id和边界配置
3. 验证能生成status JSON文件
4. 验证能写入日志
5. 验证不会创建真实Multica Issue
6. 验证不会连接数据库或修改生产

## 执行边界
- 只执行dry-run模式
- 只验证文件读取和状态迁移
- 不创建真实生产任务

## 禁止事项
- 不连接数据库
- 不创建生产Issue
- 不调度Windows Agent
- 不修改生产配置

## 验收标准
- [ ] 脚本读取测试任务成功
- [ ] task_id识别正确
- [ ] status JSON生成成功
- [ ] 日志写入成功
- [ ] 无生产动作触发

## 输出要求
- dry-run结果输出到日志
- status文件记录验证状态

## 知识沉淀要求
- 本次测试不更新知识库
- 测试通过后更新机制文档
