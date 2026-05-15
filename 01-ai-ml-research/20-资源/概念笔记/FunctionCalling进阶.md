---
title: "Function Calling 的设计质量决定 Agent 能力上限"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: concept
tags: [ai-ml, implement]
sources: [raw/articles/llm-advanced-knowledge-practice.md]
status: active
---

<!-- UID: 20260506-function-calling-advanced -->

> Function Calling 不是简单地给 LLM 一些工具，而是设计一套好用的接口。工具描述质量、参数设计、嵌套调用处理是三大核心。

## 参数设计原则

1. **描述具体可操作** — 不要"搜索代码"，要"在代码库中搜索指定功能的实现"
2. **给示例** — `examples` 字段极大提升准确性
3. **限制和默认值** — 用 `enum`、`minimum`、`maximum`、`default` 约束 LLM 的选择空间
4. **必填和可选分离** — `required` 数组明确分界

## 嵌套调用处理

- 设置 `maxDepth` 防止死循环（建议 3 层）
- 调用每层递增，超过则返回错误
- 状态共享通过 `ExecutionContext` 管理

## 与我的关联

- smolagents 的工具系统已经做了好的参数验证
- 自定义工具时需要参照这些原则

## 相关

- [[Agent架构]] ^> — 工具调用是 Agent 架构的核心组成
- [[smolagents框架]] !> — 框架层面的具体实现
- [[Agent生产安全]] +> — 生产环境的工具安全约束
