---
title: "ReadOnlyFirst"
type: concept
tags: [safety, readonly]
sources: []
raw: []
last_updated: 2026-05-10
status: stable
---
# ReadOnlyFirst

## Definition

所有数据、运维、Runtime 调查默认只读优先。

## Rules

- 先读取证据，再判断动作
- 生产写操作必须人工确认
- Agent 默认不得改生产
- 工具权限按最小必要开放
