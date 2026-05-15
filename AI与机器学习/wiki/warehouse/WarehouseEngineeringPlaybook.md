---
title: "Warehouse Engineering Playbook"
type: warehouse
tags: [warehouse, playbook]
sources: []
raw: []
last_updated: 2026-05-10
status: stable
---
# Warehouse Engineering Playbook

## Summary

数仓工程不是单纯写 SQL，而是数据真实性、调度稳定性、业务口径、变更风险和可回滚工程治理。

## Operating Flow

1. 捕获症状。
2. 找到 ADS 表与报表 SQL。
3. 追踪 Dolphin/DataX/ODS/DWD。
4. 对比归档或基线。
5. 分类问题。
6. 选择最小安全修复。
7. 验证行数、汇总、重复、标签和重跑稳定性。
