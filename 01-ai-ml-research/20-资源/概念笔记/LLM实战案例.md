---
title: "LLM 实战案例"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: concept
tags: [ai-ml, implement]
sources: [raw/articles/llm-advanced-knowledge-practice.md]
status: active
---

<!-- UID: 20260506-llm-practical-cases -->

# LLM 实战案例

## 案例一：智能客服系统

**架构流程**

```
用户 → 意图识别 → [闲聊]/[业务查询]/[问题解决]
                     ↓          ↓            ↓
                 闲聊Agent    知识库RAG    问题处理流
                                 ↓            ↓
                             答案生成      工单创建
```

**多轮对话状态机**

```typescript
class CustomerService {
  async handle(message: UserMessage, sessionId: string): Promise<Response> {
    const intent = await this.classifyIntent(message);
    const state = this.updateState(state, intent, message);  // 提取实体、填充槽位
    return this.route(state);
  }
}
```

**升级策略**：情感触发升级

- 负面情绪强度 > 0.7 → 升级
- 轮次 > 5 且未解决 → 升级
- 用户明确要求"人工"或"客服" → 升级

**知识库问答**

```typescript
async answer(query: string, context: UserContext): Promise<QAResponse> {
  const rewrittenQuery = await this.rewriteQuery(query, context);  // 查询改写
  const relevantDocs = await this.retriever.retrieve(rewrittenQuery, { topK: 5 });
  const answer = await this.generator.complete(buildPrompt(rewrittenQuery, relevantDocs));
  return { content: answer.content, sources: relevantDocs.map(d => d.source) };
}
```

## 案例二：代码审查 Agent

**规则驱动 + LLM 语义分析**

| 类型 | 示例 | 实现方式 |
|------|------|---------|
| 策略驱动 | 硬编码密码、循环内数据库查询 | RegExp + 固定规则 |
| 语义分析 | 逻辑错误、边界条件、可读性 | LLM + JSON 输出 |

```typescript
async review(code: string, language: string): Promise<ReviewResult[]> {
  const ruleIssues = this.rules
    .filter(r => code.match(r.pattern))
    .map(r => ({ severity: r.severity, message: r.name, suggestion: r.fix }));
  const semanticIssues = await this.llmAnalyze(code, language);
  return [...ruleIssues, ...semanticIssues];
}
```

## 案例三：文档问答系统

```typescript
class DocumentQASystem {
  async ingestDocument(file: File): Promise<void> {
    const doc = await this.documentParser.parse(file);
    const chunks = await this.chunker.chunk(doc, { strategy: 'semantic', maxChunkSize: 500 });
    const vectors = await this.embedChunks(chunks);
    await this.vectorStore.store(chunks, vectors);
  }

  async query(question: string): Promise<QueryResponse> {
    const relevantChunks = await this.vectorStore.search(question, { topK: 10 });
    const answer = await this.llm.complete(buildAnswerPrompt(question, relevantChunks));
    return { answer: answer.content, sources: extractSources(relevantChunks) };
  }
}
```

## 相关

- [[LLM进阶知识|LLM 进阶知识与实践]] — 源文档
- [[Agent架构|Agent 架构模式]] — 多 Agent 协同设计
- [[RAG进阶|RAG 进阶]] — 检索与重排序
- [[LLM陷阱|LLM 踩坑记录]] — 案例部署中的常见问题
