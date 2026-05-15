---
title: "Agent 生产环境安全"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: concept
tags: [ai-ml, implement]
sources: [raw/articles/llm-agent-basics.docx]
status: active
---

<!-- UID: 20260506-agent-production-safety -->

# Agent 生产环境安全

## 核心风险

CodeAgent 让 LLM 生成并执行代码，意味着安全风险。四类威胁：

- **恶意代码执行**：LLM 生成破坏性代码
- **敏感数据泄露**：代码访问环境变量、配置文件
- **资源耗尽**：无限循环、过大文件操作
- **Prompt 注入**：用户输入劫持系统行为

## 沙箱方案

| 方案 | 适用阶段 | 特点 |
|------|---------|------|
| Local executor | 开发 | 默认，无隔离，最便捷 |
| E2B 沙箱 | 生产 | 云端沙箱，完全隔离 |
| Docker 沙箱 | 生产 | 本地容器，轻量级隔离 |

```python
from smolagents import CodeAgent

# 生产环境必须上沙箱
agent = CodeAgent(
    tools=[],
    model=model,
    executor_type="e2b",  # 或 "docker"
)
```

## 最佳实践

- **开发阶段**：Local executor 足够
- **生产阶段**：必须上 E2B 或 Docker 沙箱
- **输入验证**：所有用户输入经过验证
- **输出过滤**：审查 LLM 生成的代码再执行
- **权限最小化**：沙箱内只授权必要的系统调用

## 相关

- [[LLM与Agent基础|LLM 和 Agent 基础]] — 源文档
- [[smolagents框架|smolagents 框架入门]] — CodeAgent 安全配置
- [[幻觉缓解|抗幻觉技术体系]] — 安全约束与输入验证
