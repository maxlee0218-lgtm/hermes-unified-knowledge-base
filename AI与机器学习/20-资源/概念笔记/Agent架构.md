---
title: "Agent 架构模式"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: concept
tags: [ai-ml, implement]
sources: [raw/articles/llm-advanced-knowledge-practice.md]
status: active
---

<!-- UID: 20260506-agent-architecture -->

# Agent 架构模式

## 单 Agent 模式

适合简单任务，处理逻辑相对固定的场景。

```
User Input → Prompt Router → Single Agent(Reasoning + Memory) → Response
```

## 多 Agent 协同模式

复杂任务，需要不同专长协作。

```typescript
class MultiAgentOrchestrator {
  // 1. 主管分解任务
  // 2. 并行分发给专业 Agent
  // 3. 主管整合结果
  
  async coordinate(task: string): Promise<string> {
    const subtasks = await this.managerAgent.decompose(task);
    const results = await Promise.all(subtasks.map(st => this.dispatchToAgent(st)));
    return this.managerAgent.synthesize(results);
  }
}
```

## 实战：代码审查 Agent 团队

| 角色 | 职责 | 聚焦 |
|------|------|------|
| manager | 任务分解、进度协调、结果整合 | 全局 |
| security-reviewer | 安全审查 | SQL注入、XSS、权限绕过 |
| performance-reviewer | 性能审查 | 时间复杂度、内存泄漏、N+1查询 |
| style-reviewer | 代码风格 | 命名规范、注释质量、代码结构 |

## 相关

- [[LLM进阶知识|LLM 进阶知识与实践]] — 源文档
- [[幻觉缓解|抗幻觉技术体系]] — 多 Agent 协同时必须考虑的问题
