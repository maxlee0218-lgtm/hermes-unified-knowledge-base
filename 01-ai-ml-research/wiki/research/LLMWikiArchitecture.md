---
title: "LLM Wiki Architecture"
type: research
tags: [llm-wiki, astro, samur]
sources: []
raw: []
last_updated: 2026-05-10
status: stable
---
# LLM Wiki Architecture

## Summary

本仓库采用 Astro-Han/karpathy-llm-wiki 作为轻量 Skill 核心，采用 SamurAIGPT/llm-wiki-agent 作为完整模板参考。

## Decision

- Astro 负责规则：raw/wiki/index/log/ingest/query/lint。
- Samur 负责结构参考：sources/entities/concepts/syntheses/tools/graph。
- 当前不引入复杂图谱依赖，先完成可持续知识库底座。
