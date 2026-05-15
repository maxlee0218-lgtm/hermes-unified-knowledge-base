---
title: "LLMWikiIngest"
type: concept
tags: [knowledge-base, ingest]
sources: []
raw: []
last_updated: 2026-05-10
status: stable
---
# LLMWikiIngest

## Definition

LLM Wiki ingest 是把原始资料转成可复用知识页的流程。

## Rules

- raw 保存不可变来源
- wiki 保存编译知识
- 每次 ingest 更新 index 和 log
- query 结果归档到 syntheses
- 禁止敏感信息入库
