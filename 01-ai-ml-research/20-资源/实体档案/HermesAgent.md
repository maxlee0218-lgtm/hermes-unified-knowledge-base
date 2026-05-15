---
title: "Hermes Agent"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: entity
tags: [ai-ml, reference]
sources: [raw/articles/hermes-agent-best-practices.docx]
status: dormant
---

<!-- UID: 20260506-hermes-agent -->

# Hermes Agent

## 概述

Nous Research 发布的开源 AI Agent 框架，核心卖点是原生 Function Calling 支持和「会自我成长」的 Skill 记忆体系。

## 关键特性

| 特性 | 说明 |
|------|------|
| 原生 Function Calling | 内置工具调用，无需二次封装 |
| Skill 记忆体系 | 可持久化存储和复用技能 |
| 多平台支持 | CLI / Telegram / Discord / 飞书 / 微信 |
| 多模型路由 | 支持按场景自动/手动切换模型 |

## 目录结构

```
~/.hermes/
├── config.yaml      # 主配置（非敏感）
├── .env             # 密钥和凭据
├── SOUL.md          # Agent 人格定义
├── memories/        # 持久记忆
├── skills/          # 技能目录
├── sessions/        # 会话历史
└── logs/            # 日志
```

## 配置优先级（高 → 低）

1. CLI 参数（每次调用时临时覆盖）
2. `~/.hermes/config.yaml`
3. `~/.hermes/.env`
4. 框架内置默认值

## 黄金法则

1. 密钥放 .env，配置放 config.yaml
2. 记忆要精简，技能要沉淀
3. 信任但验证，关键操作要审批
4. 模型按场景切换，不要一刀切
5. 定期备份 ~/.hermes/ 目录

## 相关资源

- [[Hermes最佳实践|Hermes Agent 最佳实践详解]]
- [[dalm-hallucination-mitigation-system|大模型全链路抗幻觉指令体系]] — 行为准则补充
