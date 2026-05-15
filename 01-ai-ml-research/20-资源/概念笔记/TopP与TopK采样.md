---
title: "Top-P 与 Top-K 采样是两种补充策略"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: concept
tags: [ai-ml, reference]
sources: [raw/articles/llm-advanced-knowledge-practice.md]
status: active
---

<!-- UID: 20260506-top-p-top-k-sampling -->

> Top-K 从前 K 个最高概率词中采样，Top-P（核采样）从累积概率超过 P 的最小词集中采样。两者常与 Temperature 联合使用，构成采样三角。

## 核心差异

| 策略 | 机制 | 适用场景 | 缺点 |
|------|------|---------|------|
| Top-K | 固定前 K 个词 | 需要精确控制生成数量 | 概率分布差时候选进低质词 |
| Top-P | 动态调整词集大小 | 大多数场景更灵活 | 极端分布时词集过大 |

## 实战组合

与 Temperature 的配合策略：

| 场景 | Temperature | Top-P | Top-K |
|------|-------------|-------|-------|
| 日常对话 | 0.7 | 0.9 | 50 |
| 专业场景 | 0.3 | 0.85 | 20 |
| 创意发散 | 1.0 | 0.95 | 100 |

## 与我的关联

- 目前使用模型时很少系统性调试这三个参数的组合，通常只设 Temperature
- 计划在下个 Agent 项目中加入采样策略 A/B 测试

## 相关

- [[温度调优]] ^> — 采样策略是 Temperature 调优的下位概念
- [[LLM与Agent基础]] ^> — 基础概念的上位概念
