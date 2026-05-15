# Wiki Schema

## Domain
基础设施管理、证照系统运维、AI 工具链与自动化知识库

## Conventions
- 文件名：小写，连字符连接，无空格（如 `infrastructure-setup.md`）
- 每个 wiki 页面必须以 YAML frontmatter 开头
- 使用 `[[wikilinks]]` 链接页面（每页至少 2 个外部链接）
- 更新页面时必须更新 `updated` 日期
- 每个新页面必须添加到 `index.md` 的正确分区
- 每个动作必须记录到 `log.md`

## Frontmatter
```yaml
---
title: 页面标题
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: entity | concept | comparison | query | summary
tags: [来自下方分类]
sources: [raw/articles/source-name.md]
---
```

## Tag Taxonomy
- 基础设施: server, network, database, systemd, docker
- 证照系统: cert-system, queue, verification, sync
- AI 工具: llm, agent, skill, automation, workflow
- 项目管理: project, planning, documentation, report
- 系统架构: architecture, design-pattern, best-practice
- 安全: security, credential, encryption, compliance
- 监控: monitoring, logging, alerting, metrics
- 自动化: cron, script, pipeline, ci-cd
- 人物/组织: person, company, team, vendor
- 对比分析: comparison, benchmark, evaluation

规则：每个页面的标签必须出现在此分类中。如需新标签，先在此处添加，再使用。

## Page Thresholds
- **创建页面**：当实体/概念出现在 2+ 来源中，或是某来源的核心内容
- **添加到现有页面**：当来源提及已覆盖的内容
- **不创建页面**：仅为附带提及、细节或领域外内容
- **拆分页面**：当页面超过 200 行 — 拆分为子主题并交叉链接
- **归档页面**：当内容已被完全替代 — 移动到 `_archive/`，从 index 移除

## Entity Pages
每个重要实体一页。包含：
- 概述 / 是什么
- 关键事实和日期
- 与其他实体的关系（[[wikilinks]]）
- 来源引用

## Concept Pages
每个概忶或主题一页。包含：
- 定义 / 解释
- 当前知识状态
- 未解决问题或争论
- 相关概念（[[wikilinks]]）

## Comparison Pages
对比分析。包含：
- 对比对象和原因
- 对比维度（优先表格格式）
- 结论或综合
- 来源

## Update Policy
当新信息与现有内容冲突时：
1. 检查日期 — 新来源通常优先于旧来源
2. 如果真正矛盾，注明两种观点并带日期和来源
3. 在 frontmatter 中标记：`contradictions: [page-name]`
4. 在 lint 报告中标记待用户审核