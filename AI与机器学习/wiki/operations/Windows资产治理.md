---
title: Windows资产治理
date: 2026-05-11
tags: [windows, asset, governance]
sources:
  - raw/staging/handbrain/handbrain-20260511/files/20260510-四台机器运行资产全貌报告.md
  - raw/staging/handbrain/handbrain-20260511/files/20260511-Windows数仓数据备份清单.md
  - raw/staging/handbrain/handbrain-20260511/files/reports/windows_c_drive_inventory_and_migration_plan_20260511_0755_report.md
---

# Windows资产治理

## 1. 结论

Windows数仓专机是测试环境，承载dbt、DataX、DuckDB等工具，需规范资产管理。

## 2. 适用范围

- Windows数仓开发专机
- 本地测试环境
- 数据工具管理

## 3. 核心规则

| 规则 | 说明 |
|------|------|
| 测试环境隔离 | Windows不连接生产库，只用于测试 |
| 用户规范 | 统一使用hermes用户，避免39169混用 |
| 数据备份 | 关键数据定期备份到安全位置 |
| 工具管理 | DataX、dbt等工具版本统一管理 |

## 4. 关键事实

- 系统：Windows 11 Pro
- 用户：hermes / 39169（混用，需整理）
- 核心路径：D:/data-warehouse/
- dbt项目：01-dbt-duckdb/，完成度25%
- DataX配置：02-datax/
- 监控大屏：03-monitoring/

## 5. 风险与限制

- 需连接guest Wi-Fi才能访问生产库
- 用户profile混用，权限不清
- 系统可能重装，数据需备份
- Agent无法在Windows稳定执行

## 6. 后续动作

- [ ] 统一用户profile，清理39169
- [ ] 完成dbt建设，达到100%
- [ ] 建立定期备份机制
- [ ] 解决Agent执行环境问题

## 7. 来源路径

- `raw/staging/handbrain/handbrain-20260511/files/20260510-四台机器运行资产全貌报告.md`
- `raw/staging/handbrain/handbrain-20260511/files/20260511-Windows数仓数据备份清单.md`
- `raw/staging/handbrain/handbrain-20260511/files/reports/windows_c_drive_inventory_and_migration_plan_20260511_0755_report.md`
