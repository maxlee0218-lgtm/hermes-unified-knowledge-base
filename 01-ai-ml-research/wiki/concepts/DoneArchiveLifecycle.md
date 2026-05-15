---
title: "DoneArchiveLifecycle"
type: concept
tags: [runtime, lifecycle]
sources: []
raw: []
last_updated: 2026-05-10
status: stable
---
# DoneArchiveLifecycle

## Definition

任务从 done 进入 archive 的生命周期治理规则。

## Rules

- done 不等于最终闭环
- 已完成任务应生成归档摘要
- 测试/沙箱任务优先归档
- 核心知识任务先补齐报告和 Wiki，再归档
