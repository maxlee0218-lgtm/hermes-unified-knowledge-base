---
title: "ReportValidation"
type: concept
tags: [warehouse, report, validation]
sources: []
raw: []
last_updated: 2026-05-10
status: stable
---
# ReportValidation

## Definition

报表验证要求同时验证数字正确性与展示粒度正确性。

## Rules

- SQL 跑通不等于报表修好
- 总数正确也可能存在重复展示行
- 需要验证行数、汇总、重复、标签、空值
- 归档表默认作为对比基线
