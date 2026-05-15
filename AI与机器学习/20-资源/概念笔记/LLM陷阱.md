---
title: "LLM 踩坑记录"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: concept
tags: [ai-ml, reference]
sources: [raw/articles/llm-advanced-knowledge-practice.md]
status: active
---

<!-- UID: 20260506-llm-pitfalls -->

# LLM 踩坑记录

## 常见陷阱

| 陷阱 | 症状 | 解决方案 |
|------|------|---------|
| 上下文稀释 | 长对话后 LLM "遗忘"早期信息 | 定期总结、状态注入、定期重置 |
| Prompt 注入 | 用户劫持系统行为 | 输入验证、分隔符转义、权限隔离 |
| Token 预算耗尽 | 长文档处理失败 | 分块处理、滑动窗口、摘要压缩 |
| 输出不稳定 | 相似输入差异大 | 降低 Temperature、添加输出格式约束 |
| 函数调用死循环 | Agent 反复调用同一工具 | 深度限制、结果缓存、前置条件检查 |
| 检索不准 | 检索结果与问题不相关 | 混合检索、查询改写、重排序 |
| 多 Agent 状态不一致 | 各 Agent 输出冲突 | 共享状态存储、主管 Agent 统一协调 |
| 成本失控 | 日均消耗快速增长 | 设置用量限额、监控告警、定期审计 |
| 幻觉回答 | 生成看似合理但错误的内容 | 引用检索、置信度过滤、人工复核 |
| 输出格式错误 | JSON 解析失败、格式不符 | 结构化输出 Prompt、输出后校验、重试机制 |

## 调试技巧

1. **Prompt 版本化**
   ```typescript
   const promptRegistry = {
     'v1.0': { /* 初始版本 */ },
     'v1.1': { /* 添加格式约束 */ },
     'v2.0': { /* 重构结构 */ },
   };
   ```

2. **对话回放**
   ```typescript
   async function replaySession(sessionId: string) {
     const history = await storage.getMessages(sessionId);
     for (const msg of history) console.log(`[${msg.role}] ${msg.content}`);
   }
   ```

3. **关键节点埋点**
   ```typescript
   class TracedLLMClient {
     async complete(prompt, options) {
       const traceId = generateTraceId();
       logger.info(`[${traceId}] 开始请求`, { promptLength: prompt.length });
       try {
         const result = await this.client.complete(prompt, options);
         logger.info(`[${traceId}] 完成`, { duration, outputLength: result.content.length });
         return result;
       } catch (error) {
         logger.error(`[${traceId}] 失败`, { error, duration });
         throw error;
       }
     }
   }
   ```

## 监控与告警

**关键指标**

| 类别 | 指标 | 说明 |
|------|------|------|
| 延迟 | p50 / p99 Latency | 首字节时间比总延迟更重要 |
| 成本 | dailyCost / costPerRequest | 每次请求均价与日度总额 |
| 质量 | errorRate / retryRate | 错误率 > 5% 即为严重 |
| 用户 | satisfactionScore | 近期反馈得分均值 |

**告警阈值**

```typescript
const alerts = [
  { metric: 'p99Latency',    threshold: 30000, severity: 'warning'  },
  { metric: 'errorRate',     threshold: 0.05,  severity: 'critical' },
  { metric: 'dailyCost',     threshold: 1000,  severity: 'warning'  },
  { metric: 'costPerRequest', threshold: 0.5,   severity: 'warning'  },
];
```

**自动修复**

```typescript
private async autoRemediate(alert: Alert): Promise<void> {
  if (alert.metric === 'dailyCost') {
    await this.configManager.update('defaultModel', 'gpt-3.5-turbo');
  }
  if (alert.metric === 'p99Latency') {
    await this.cacheManager.setTTL(3600);
  }
}
```

## 测试推荐

| 类型 | 范例 | 关注点 |
|------|------|--------|
| Prompt 效果测试 | 意图识别准确率 > 0.8 | 输出结构与置信度 |
| 单元测试 | JSON 解析、格式验证 | 字段完整性 |
| E2E 测试 | 完整客服对话流程 | 状态机转换 |

## 相关

- [[LLM进阶知识|LLM 进阶知识与实践]] — 源文档
- [[性能与成本|性能与成本优化]] — 成本速控与告警配置
- [[幻觉缓解|抗幻觉技术体系]] — 幻觉处理专项
