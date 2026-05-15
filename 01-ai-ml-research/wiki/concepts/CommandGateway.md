---
title: "CommandGateway"
type: concept
tags: [runtime, github, gateway]
sources: []
raw: []
last_updated: 2026-05-10
status: stable
---
# CommandGateway

## Definition

GitHub command file 到本地 gateway，再到 Multica CLI 的审计型任务入口。

## Rules

- 默认 dry-run
- approved 必须指定任务、动作和边界
- 不作为长期 Runtime 主脑
- 只保留审计和安全边界
