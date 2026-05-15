---
title: "Multica"
type: entity
tags: [runtime, issue, agent]
sources: []
raw: []
last_updated: 2026-05-10
status: stable
---
# Multica

## Role

Issue / Agent Runtime 执行池。

## Responsibilities

创建和跟踪 Issue，分配 Agent，记录任务状态，作为运行真相来源。

## Boundaries

不作为完整操作系统总账，不由 Agent 随意修改框架源码、daemon、配置或数据库。
