---
title: "LLM 和 Agent 基础"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: concept
tags: [ai-ml, reference]
sources: [raw/articles/llm-agent-basics.docx]
status: active
---

<!-- UID: 20260506-llm-agent-basics -->

# LLM 和 Agent 基础

> 本文系统性介绍了 AI Agent 的概念、与 LLM 的区别，并通过 Python 代码实例展示了如何实现一个最小的 ReAct Agent。还深入解析了 smolagents 框架的内部机制。

## 章节导航

1. [[ReAct模式|ReAct 循环与手写实现]] — 从原理到 ~50 行纯 Python 实现
2. [[smolagents框架|smolagents 框架入门]] — CodeAgent / ToolCallingAgent、工具系统、内部机制
3. [[多Agent协调|多 Agent 协作]] — Manager-Worker 模式与专业分工
4. [[Agent生产安全|Agent 生产环境安全]] — 沙箱、输入验证、安全威胁

## 核心观念

> **LLM 是只能说话的大脑，Agent 是能思考、能动手、能从结果中学习的完整系统。**

## Agent 四大支柱

- **LLM**：推理和决策的核心大脑
- **工具（Tools）**：让 LLM 能够与外部世界交互的"手"
- **ReAct 循环**： Thought → Action → Observation 的交替执行机制
- **记忆**：保存历史交互以支持上下文理解

## 为什么现在 Agent 变得实用

1. LLM 能力跃升：GPT-4、Claude、DeepSeek 等模型推理能力足够强
2. 工具调用标准化：Function Calling、Tool Use、MCP 统一接口
3. 框架生态成熟：LangChain、LangGraph、smolagents、CrewAI 等降低了构建门槛

## 相关

- [[LLM进阶知识|LLM 进阶知识与实践]] — 进阶主题（Temperature、RAG、Agent 架构、Token 优化）
- [[Agent架构|Agent 架构模式]] — 单/多 Agent 架构设计
- [[HermesAgent|Hermes Agent]] — 另一个原生 Function Calling 框架
