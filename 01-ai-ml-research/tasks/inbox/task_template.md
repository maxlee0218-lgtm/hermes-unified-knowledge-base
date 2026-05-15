---
task_id: TASK-YYYYMMDD-NNN
title: "任务标题"
owner: "主脑"
# target_agent 规则：
# - PLAN / REVIEW / KNOWLEDGE 类任务 → 研究与架构官
# - DATA / SANDBOX / SQL 类任务 → 研究与架构官
# - WAREHOUSE / 调度 / 链路排查类任务 → 研究与架构官
# 当前 Multica 唯一有效 Agent：研究与架构官
# 禁止使用：主脑、OpenClaw、ChatGPT、自定义未注册名称
target_agent: "研究与架构官"
objective: "任务目标描述"
allowed_actions:
  - SELECT
  - SHOW
  - 本地沙箱验证
  - 报告生成
  - 知识沉淀
forbidden_actions:
  - INSERT
  - UPDATE
  - DELETE
  - DROP
  - ALTER
  - 修改生产配置
  - 自动上线
acceptance_criteria:
  - 有根因分析
  - 有本地报告
  - 有治理建议
  - 有知识沉淀
output_paths:
  - "D:\\AIWorker\\reports\\"
  - "/root/multica-work/output/"
knowledge_update_required: true
timeout_minutes: 30
created_at: "2026-05-09T00:00:00+08:00"
---

# 任务描述

## 背景

## 目标

## 执行边界

## 禁止事项

## 验收标准

## 输出要求

## 知识沉淀要求
