---
title: "Hermes Agent 全面自检与优化项目"
created: 2026-05-07
updated: 2026-05-08
stage: connect
type: project
tags: [devops, implement]
status: active
---

<!-- UID: 20260507-hermes-audit-project -->

# Hermes Agent 全面自检与优化项目

> 对 111.229.153.11 跳板机上的 Hermes Agent 进行全面检查、修复和优化。

## 目标

1. 修复 Gateway 连接问题（PocketClaw "模型错误"）
2. 升级 Hermes Agent 版本（v0.10.0 → v0.12.0）
3. 优化配置（custom provider、key 分离、YAML 修复）
4. 建立自动化运维（systemd、logrotate、定时清理）
5. 整理知识库（Git 中文化、commit 规范化）

## 里程碑

- [x] 2026-05-07: 诊断并修复 PocketClaw 连接问题
- [x] 2026-05-07: 配置改为 custom provider 直连 Kimi Coding API
- [x] 2026-05-07: 修复 YAML 缩进问题
- [x] 2026-05-07: 配置 systemd 管理 gateway（自动重启）
- [x] 2026-05-07: 配置 pm2 管理 clawpilot（开机自启）
- [x] 2026-05-07: 迁移日志到 /var/log/hermes/
- [x] 2026-05-07: 配置 logrotate（50M×5轮）
- [x] 2026-05-07: 清理记忆系统（标签化、压缩）
- [x] 2026-05-07: 编写全面自检报告
- [x] 2026-05-07: 编写记忆系统优化方案
- [x] 2026-05-08: 配置磁盘监控（80%报警）
- [x] 2026-05-08: 配置 config 自动备份（每10分钟）
- [x] 2026-05-08: 配置 session 清理（每天）
- [x] 2026-05-08: 清理 Git 工作树（500+未跟踪文件）
- [x] 2026-05-08: PolarDB 隧道去重
- [x] 2026-05-08: Git commit 全部中文化
- [x] 2026-05-08: 知识库目录和文件全部中文化
- [x] 2026-05-08: 修复所有笔记 frontmatter 和链接

## 关键决策

1. **不盲目升级版本** — 网络瓶颈（30KB/s）导致下载超时，优先保证服务稳定
2. **key 分离原则** — 111 gateway 专用 key，PocketClaw/对话端用不同 key
3. **systemd 替代 nohup** — 崩溃自动重启，日志持久化
4. **pm2 替代手动启动** — clawpilot 持久化运行
5. **中文优先** — 所有 commit、目录、文件名使用中文

## 产出物

- [[HermesAgent全面审计]] — 自检报告
- [[Hermes配置变更SOP]] — 配置变更标准操作流程
- [[PocketClaw模型错误]] — 故障排查记录
- [[记忆系统优化]] — 优化方案

## 相关

- [[Hermes最佳实践]] ^> — 一般性配置指南
- [[LLM陷阱]] x> — 反面教材
- [[基础设施]] v> — 所属责任领域
