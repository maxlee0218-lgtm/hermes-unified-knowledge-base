---
title: "Token 优化"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: concept
tags: [ai-ml, implement]
sources: [raw/articles/llm-advanced-knowledge-practice.md]
status: active
---

<!-- UID: 20260506-token-optimization -->

# Token 优化

## 核心策略

| 策略 | 节省比例 | 适用场景 |
|------|---------|---------|
| Prompt 压缩 | 15-30% | 长 prompt 场景 |
| 输出长度限制 | 20-40% | 响应通常较短 |
| 模型降级 | 50-80% | 简单/批量任务 |
| 缓存 | 30-60% | 重复 query |
| 批量处理 | 20-30% | 离线任务 |

## Prompt 压缩方法

```typescript
compressPrompt(prompt: string): string {
  // 移除注释和空白
  let compressed = prompt
    .replace(/\/\/.*$/gm, '')
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/\n{3,}/g, '\n\n');
  
  // 提取关键指令 + 压缩后内容
  const essential = this.extractEssential(prompt);
  return essential + '\n\n' + compressed;
}
```

## 关键要点

- Token 按量计费，优化直接省钱
- 预留输出空间避免超出上下文窗口
- 对重复 query 使用缓存

## 相关

- [[LLM进阶知识|LLM 进阶知识与实践]] — 源文档
- [[RAG进阶|RAG 进阶]] — 检索阶段的上下文压缩
