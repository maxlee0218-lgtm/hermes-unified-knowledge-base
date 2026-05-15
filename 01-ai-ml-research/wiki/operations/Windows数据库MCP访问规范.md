---
title: Windows数据库MCP访问规范
date: 2026-05-13
tags: [windows, mcp, database, operations]
status: stable
---

# Windows数据库MCP访问规范

## 1. 结论

Windows 作为数据库连接与凭据维护中心。DataGrip 用于人工维护数据库连接，MCP 作为 Agent 数据访问出口。Agent 不直接接触数据库账号密码。

## 2. 架构定位

- Windows：数据库访问 Runtime
- DataGrip：人工连接维护工具
- MCP：Agent 数据访问出口
- Multica.ai：Agent 面板和任务分派中心
- llm-wiki：正式知识库和决策库

## 3. 核心规则

1. 数据库账号密码只在 Windows 维护；
2. Agent 不直接持有账号密码；
3. 数据访问统一走 Windows MCP；
4. MCP 默认只读；
5. 查询结果必须脱敏；
6. 生产写操作必须人工执行；
7. MCP 配置不进入 Git；
8. llm-wiki 只记录规则，不记录密钥。

## 4. MCP 允许能力

- list_databases
- list_tables
- describe_table
- select_query
- explain_query
- sample_query

## 5. MCP 禁止能力

- 写 SQL
- DDL
- 调度修改
- DataX 修改
- DolphinScheduler 修改
- 密钥输出
- 全表无条件扫描
- 大批量明细导出

## 6. 操作流程

1. 人工在 DataGrip 维护连接；
2. Windows MCP 读取本地受控连接能力；
3. Agent 只调用 MCP 暴露的只读工具；
4. 查询前检查 SQL 类型；
5. 查询后输出摘要；
6. 结果进入报告或知识库；
7. 重要结论更新 index/log。

## 7. 风险与限制

- MCP 工具如果暴露 unrestricted_sql，会有高风险；
- 只读账号必须和写账号分离；
- 查询结果不能包含敏感明细；
- 大查询需要限制 LIMIT；
- MCP 配置文件不能提交到 Git。

## 8. 后续动作

- 标准化 MCP 工具名称；
- 建立 SQL 白名单；
- 建立查询审计日志；
- 建立 ADS_SC_XL_13 样板链路只读摸排前置检查。

## 9. 来源路径

- Windows DataGrip + MCP 架构决策
- wiki/outputs/当前决策总账.md
