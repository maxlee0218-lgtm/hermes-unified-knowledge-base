---
title: "Wiki 总地图 — 个人全能知识库"
created: 2026-05-06
updated: 2026-05-06
stage: connect
type: moc
tags: [thinking, reference]
status: active
---

<!-- UID: 20260506-index -->

> 本知识库处于早期建设阶段，核心聚焦 AI/ML 领域。未来向基础设施、财务、健康、生活扩展。所有笔记严格遵守 [[SCHEMA|知识库宪法]] 执行。

## 领域状态

| 领域 | 阶段 | 笔记数 | 内容地图 |
|------|------|--------|--------|
| AI/ML | 建设中 | 18 | [[LLM进阶知识|LLM 进阶知识地图]] |
| 基础设施 | 待建设 | 0 | — |
| 开发技术 | 待建设 | 0 | — |
| 生活与个人 | 待建设 | 0 | — |

---

## 责任领域（Areas）

### [[AI与ML概览|AI/ML]]
当前核心领域，包含 Agent 架构、LLM 原理、生产安全、实战案例。

## Agent 体系

Agent 是当前知识库的核心主题。从原理到实践，从单体到多体协作。

- [[ReAct模式]] ^> — ReAct 循环是 Agent 推理的基础机制
- [[Agent架构]] +> — 单/多 Agent 架构设计
- [[多Agent协调]] +> — Manager-Worker 协作模式
- [[smolagents框架]] !> — smolagents 框架的具体应用
- [[Agent生产安全]] !> — 生产环境的安全约束

## LLM 原理与优化

- [[LLM与Agent基础]] ^> — LLM 和 Agent 的基础概念
- [[LLM幻觉]] — 幻觉的定义与 7 大类型
- [[幻觉缓解]] +> — 全链路抗幻觉技术
- [[温度调优]] — 温度参数的本质与策略
- [[RAG进阶]] — RAG 进阶策略（分块、混合检索、重排序）
- [[Token优化]] — Token 优化与成本控制
- [[性能与成本]] +> — 性能与成本的平衡

## 工程实践

- [[Hermes最佳实践]] !> — Hermes Agent 的配置与部署
- [[Hermes配置变更SOP]] !> — Hermes 配置变更 SOP（检查清单+回滚方案）
- [[LLM实战案例]] !> — 三个实战案例
- [[PocketClaw模型错误]] !> — PocketClaw "模型错误" 排查（provider 缓存清理）
- [[记忆系统优化]] +> — 记忆系统优化方案
- [[HermesAgent全面审计]] +> — Hermes Agent 全面自检报告
- [[LLM陷阱]] x> — 踩坑记录与反面教材

## 实体档案

- [[HermesAgent]] — Nous Research Agent 框架
- [[DALM幻觉缓解系统]] — 抗幻觉指令体系文档

---

## 进行中的项目

- 暂无

## 待研究问题

- [ ] 基础设施自动化运维体系
- [ ] 个人财务投资框架
- [ ] 健康数据追踪与分析

## 知识库元数据

- [[SCHEMA]] ^> — 本库的最高准则
- [[LOG]] -> — 所有变更操作记录
