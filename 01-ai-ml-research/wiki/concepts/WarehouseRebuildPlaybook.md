---
title: "WarehouseRebuildPlaybook"
type: concept
tags: [warehouse, playbook]
sources: []
raw: []
last_updated: 2026-05-10
status: stable
---
# WarehouseRebuildPlaybook

## Definition

数仓重构工程手册，强调先复现、再追链路、再验证、最后人工上线。

## Rules

- 先查数据，再改逻辑
- 归档表默认是证据
- 总数和展示粒度都要验证
- 变更必须最小范围、可备份、可回滚
- ADS_SC_XL_13 作为第一条样板链路
