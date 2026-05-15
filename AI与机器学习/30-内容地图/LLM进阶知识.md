---
title: "LLM 进阶知识与实践"
created: 2026-05-06
updated: 2026-05-06
stage: connect
type: moc
tags: [ai-ml, reference]
sources: [raw/articles/llm-advanced-knowledge-practice.md]
status: active
---

<!-- UID: 20260506-llm-advanced-knowledge -->

# LLM 进阶知识与实践

## 概述

面向已掌握基础概念的开发者，深入探讨 LLM 原理、高级 Prompt 工程、RAG/Agent 项目优化、成本效率等进阶主题。本文档覆盖 Temperature 调优、Top-P/Top-K 采样、Context Window 优化、System Prompt 工程、RAG 进阶、Function Calling 进阶、多模态应用、Agent 架构设计、性能与成本优化等核心领域。

## 六大章节结构

| 章节 | 内容 | 关键概念 |
|------|------|---------|
| 一、进阶概念篇 | Temperature、Top-P/Top-K、Context Window、System Prompt | [[温度调优|Temperature 调优]]、[[TopP与TopK采样|采样策略]]、[[系统提示工程|System Prompt 工程]] |
| 二、高级技术篇 | RAG、Function Calling、多模态 | [[RAG进阶|RAG 进阶]]、[[FunctionCalling进阶|Function Calling 进阶]] |
| 三、架构设计篇 | Agent 架构、状态管理、人机协作、错误处理 | [[Agent架构|Agent 架构模式]]、[[LLM错误处理|错误处理策略]] |
| 四、性能与成本优化 | Token 优化、模型选择、延迟优化 | [[Token优化|Token 优化]]、[[模型选择策略|模型选择策略]] |
| 五、实战案例 | 智能客服、代码审查Agent、文档问答系统 | [[LLM实战案例|LLM 实战案例]] |
| 六、踩坑记录 | 常见陷阱、调试技巧、监控告警、测试 | [[LLM陷阱|踩坑记录]] |

## 重要原则

- **不是所有上下文都需要完整输入** — Context Window 优化的核心思想
- **成本意识** — Token 消耗直接关系成本，需要系统性优化
- **安全第一** — Prompt 注入防护和函数调用安全不可忽视
- **重视调试** — LLM 应用的调试比传统软件更复杂，需要专门的技巧

## 与其他概念的关系

- [[LLM幻觉|LLM 幻觉]] — 进阶实践中必须考虑的核心问题
- [[幻觉缓解|抗幻觉技术体系]] — 与本文档的安全实践相互补充
- [[Hermes最佳实践|Hermes Agent 最佳实践]] — 框架层面的实施指南

## 来源

- 原始文件: raw/articles/llm-advanced-knowledge-practice.md (1464 行, 43KB)