---
title: "RuntimeFlowGuard"
type: concept
tags: [runtime, observability, guard]
sources: []
raw: []
last_updated: 2026-05-10
status: stable
---
# RuntimeFlowGuard

## Definition

Runtime 流程保障总账，用于判断当前流程是否通、卡在哪、责任角色是谁、是否需要人工决策。

## Rules

- 只读观测
- 不补业务产物
- 不修改状态
- 输出 runtime-state.json 与 runtime-state.md
