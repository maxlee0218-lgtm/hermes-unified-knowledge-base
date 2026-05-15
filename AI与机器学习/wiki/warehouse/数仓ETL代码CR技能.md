---
title: 数仓ETL代码CR技能
date: 2026-05-13
tags: [warehouse, etl, code-review, skill]
status: stable
---

# 数仓ETL代码CR技能

## 1. 结论

`bigdata-etl-cr` 是面向数仓 ETL 代码审查的技能，用于分析 SQL/Spark/Flink 等大数据代码的逻辑合理性，发现数据正确性、数据质量、性能和可维护性问题。

该技能已沉淀为：

```text
skills/bigdata-etl-cr/SKILL.md
```

## 2. 适用场景

当用户需要以下能力时，优先读取该 Skill：

- CR ETL 代码；
- 审查 Hive SQL / Spark SQL / Flink SQL；
- 审查 DataWorks / MaxCompute SQL；
- 发现 JOIN、聚合、过滤、分区、空值、去重等逻辑问题；
- 对数仓脚本做上线前检查；
- 对 ADS / DWD / ODS 加工逻辑做复核。

## 3. 审查维度

该 Skill 的核心检查维度包括：

1. 数据正确性；
2. 数据质量；
3. 性能优化；
4. 代码规范；
5. 常见逻辑陷阱。

重点关注：

- JOIN 条件是否完整；
- 是否存在一对多膨胀；
- WHERE / 分区过滤是否完整；
- GROUP BY 字段是否完整；
- SUM / COUNT / DISTINCT 是否符合业务语义；
- NULL、空字符串、除零、类型转换是否安全；
- 时间边界、跨天、月末年末是否正确；
- 状态流转和业务规则是否完整。

## 4. 输出标准

CR 输出统一分为：

- 严重问题：必须修复；
- 潜在风险：建议修复；
- 优化建议：可选优化；
- 检查统计；
- 总体评价。

## 5. 使用规则

使用该 Skill 时，必须优先要求或整理以下上下文：

1. ETL 代码；
2. 表结构；
3. 业务口径；
4. 调度周期；
5. 增量字段；
6. 分区字段；
7. 是否存在晚到数据、删除数据、重算逻辑；
8. 目标表用途。

如果上下文不足，允许给出“疑似问题”，但不能把猜测当成确定结论。

## 6. 当前体系中的使用位置

| 角色 | 使用方式 |
|---|---|
| 首脑 | 用于验收 ETL 代码审查结论 |
| 数据虾-Windows-Kimi | 用于只读分析、SQL 逻辑复核 |
| 代码工-Windows-Codex | 用于 SQL / 脚本生成后的自检和修复 |
| 任务管家-Windows-Kimi | 用于分派 ETL CR 任务时指定检查标准 |

## 7. 边界

- 该 Skill 只做代码审查，不直接执行生产 SQL；
- 该 Skill 不替代业务口径确认；
- 涉及生产变更时，必须经过人工确认；
- 涉及数据库查询时，仍遵守 Windows MCP 只读边界。

## 8. 后续动作

1. 用该 Skill 审查后续 ADS_SC_XL_13 样板链路 SQL；
2. 将常见问题沉淀为“数仓 ETL 问题模式库”；
3. 与 `数据访问只读安全边界`、`数仓重构验收与回滚手册` 联动使用。

## 9. 来源路径

- `skills/bigdata-etl-cr/SKILL.md`
- 用户提供的 bigdata-etl-cr Skill 定义
