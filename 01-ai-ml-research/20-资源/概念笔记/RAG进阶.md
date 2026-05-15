---
title: "RAG 进阶"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: concept
tags: [ai-ml, reference]
sources: [raw/articles/llm-advanced-knowledge-practice.md]
status: active
---

<!-- UID: 20260506-rag-advanced -->

# RAG 进阶

## 分块策略优化

```typescript
const productionChunking = {
  codeDoc: {
    strategy: 'recursive',
    delimiters: ['\n\n', '\n', '。', '！', '？', ' '],
    maxChunkSize: 500,
    overlap: 50,
  },
  knowledgeBase: {
    strategy: 'semantic',
    preserveStructure: true,  // 保留<h1>, <h2>等结构
  },
};
```

## 混合检索（RRF 融合）

```typescript
class HybridRetriever {
  async retrieve(query: string, topK: number = 10) {
    // 1. 向量检索 + 关键词检索
    const vectorResults = await vectorStore.search(query, topK * 2);
    const keywordResults = await keywordIndex.search(query, topK * 2);
    
    // 2. RRF融合（倒数排名融合）
    return this.rrfFusion([
      { results: vectorResults, weight: 0.6 },
      { results: keywordResults, weight: 0.4 },
    ]);
  }
  
  // score = Σ weight/(60 + rank + 1)
  rrfFusion(scoredResults) { /* ... */ }
}
```

## 关键经验

- 技术文档：代码与注释绑定切分，不分离
- 知识库：按标题层级语义切分
- 混合检索的 RRF 公式中 k 通常取 60

## 相关

- [[LLM进阶知识|LLM 进阶知识与实践]] — 源文档
- [[Token优化|Token 优化]] — RAG 中上下文压缩必备
