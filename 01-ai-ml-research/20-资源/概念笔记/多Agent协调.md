---
title: "多 Agent 协作"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: concept
tags: [ai-ml, implement]
sources: [raw/articles/llm-agent-basics.docx]
status: active
---

<!-- UID: 20260506-multi-agent-coordination -->

# 多 Agent 协作

## Manager-Worker 模式

当任务足够复杂时，一个 Agent 搞不定。smolagents 支持将 Worker 作为"工具"交给 Manager 调度。

```python
from smolagents import CodeAgent

# Worker 1：搜索
search_agent = CodeAgent(
    tools=[search_tech_news, search_company_info],
    model=model,
    name="search_agent",
    description="搜索 Agent：负责搜索科技新闻和公司信息。",
)

# Worker 2：分析
analyst_agent = CodeAgent(
    tools=[], model=model,
    name="analyst_agent",
    description="分析 Agent：负责数据分析、趋势判断和撰写报告。",
    add_base_tools=True,
)

# Manager：调度两个 Worker
manager = CodeAgent(
    tools=[],
    model=model,
    managed_agents=[search_agent, analyst_agent],
)

result = manager.run(
    "请帮我分析当前 AI 行业的竞争格局。"
    "先搜索 AI 领域的最新新闻和主要公司信息，"
    "然后基于这些信息写一份简短的行业分析报告。"
)
```

## 核心价值

**专业分工**：搜索 Agent 专注信息检索，分析 Agent 专注推理总结，各司其职。

## 设计要点

- **Worker 的 `description` 是关键**：Manager 通过读取 description 决定子任务分配给谁
- **Worker 执行完后返回结果给 Manager**，Manager 汇总后给出最终答案
- **避免过度拆分**：任务太细碎会增加调度开销

## 相关

- [[LLM与Agent基础|LLM 和 Agent 基础]] — 源文档
- [[Agent架构|Agent 架构模式]] — 单/多 Agent 架构设计
- [[LLM陷阱|LLM 踩坑记录]] — 多 Agent 状态不一致等常见问题
