---
title: 新Hermes单体首脑接手报告
date: 2026-05-14
tags: [takeover, single-chief, hermes, status]
status: stable
---

# 新Hermes单体首脑接手报告

## 001 接手结论

服务器 VM-0-9-ubuntu 上新 Hermes 已完成单体首脑接手。
旧首脑运行态不再继承，当前为全新单体模式。

## 002 Hermes 版本

Hermes Agent v0.12.0 (2026.4.30)

## 003 Hermes 路径

/home/ubuntu/.local/bin/hermes

## 004 llm-wiki 路径

/srv/ai/llm-wiki

## 005 当前 commit id

152216bbd938e186f23f88c0a6b3391b2b679160

## 006 health.py 检查结果

- fatal_count: 2
  - wiki/operations/SSH隧道合规替代方案.md (possible_secret)
  - wiki/operations/SSH隧道替代方案.md (possible_secret)
- warning_count: 7
  - wiki/runtime/任务执行追踪规范.md (missing_frontmatter)
  - wiki/agent/Windows智能体技能清单.md (not_in_index)
  - wiki/agent/手脑分离模式规范.md (not_in_index)
  - wiki/outputs/知识库当前状态整理报告.md (not_in_index)
  - wiki/runtime/Multica任务管理规范.md (not_in_index)
  - wiki/runtime/任务执行追踪规范.md (not_in_index)
  - wiki/runtime/历史任务归档.md (not_in_index)

## 007 已读取文件清单

- wiki/index.md
- wiki/00-当前主路径.md
- wiki/outputs/当前决策总账.md
- wiki/outputs/AI数仓协作架构图与流程.md
- wiki/log.md
- wiki/warehouse/数仓ETL代码CR技能.md
- skills/bigdata-etl-cr/SKILL.md

## 008 当前暂停事项

- Multica.ai / 多智能体暂停
- 任务管家 / 数据虾 / 代码工暂停
- 数据库 / MCP 暂停
- 生产系统暂停
- Windows Runtime 暂不纳入执行链路
- Codex 暂停
- Ruflo / 新 AgentOS 框架暂停

## 009 当前主路径

1. 新 Hermes 接手为单体首脑
2. Windows 重置后暂不纳入执行链路
3. Multica / 多智能体暂停
4. 数据库 / MCP 暂停
5. llm-wiki 作为唯一知识底座
6. 先整理知识库和技能
7. 等用户确认后，再恢复 DataGrip / 数据库 / MCP
8. 最后再考虑多智能体

## 010 当前风险

- health.py 有 2 个 fatal（possible_secret），均为 SSH 隧道相关文档，暂不处理
- 7 个 warning 为索引缺失或 frontmatter 缺失，后续整理时修复
- SSH Deploy Key 使用 id_ed25519_new，需确认 GitHub Deploy Key 配置持久有效
- Hermes 版本为 v0.12.0，非最新（最新 v0.13.0），后续可考虑升级

## 011 下一步建议

1. 确认 Tailscale 网络连通性（Linux 100.107.217.30 <-> Windows 100.116.239.96）
2. 整理知识库 health warnings（补齐 frontmatter、索引）
3. 处理 SSH 隧道文档中的 possible_secret fatal
4. 等用户确认后恢复数据库连接（通过 Windows DataGrip）
5. 等用户确认后再考虑多智能体架构

## 012 环境信息

| 项目 | 值 |
|---|---|
| 服务器 hostname | VM-0-9-ubuntu |
| Tailscale IP | 100.107.217.30 |
| Windows Tailscale IP | 100.116.239.96 |
| Python | 3.12.3 |
| Tailscale | v1.98.1 |
| SSH Deploy Key | id_ed25519_new |
| Git Config | 待配置 user.name / user.email |
