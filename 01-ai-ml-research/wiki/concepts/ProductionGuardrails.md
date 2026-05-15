---
title: "ProductionGuardrails"
type: concept
tags: [safety, production]
sources: []
raw: []
last_updated: 2026-05-10
status: stable
---
# ProductionGuardrails

## Definition

生产护栏是所有 AI/Agent 工作的硬边界。

## Rules

- 不修改生产数据库
- 不修改 DolphinScheduler 生产任务
- 不修改 DataX 生产任务
- 不自动补数
- 不重跑生产
- 生产动作必须人工确认、可备份、可回滚
