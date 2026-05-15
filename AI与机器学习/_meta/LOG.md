---
title: "Wiki 操作日志"
created: 2026-05-06
updated: 2026-05-06
stage: connect
type: log
tags: [thinking, reference]
status: active
---

<!-- UID: 20260506-log -->

# Wiki Log

> 按时间顺序记录所有 wiki 操作。只追加不删除。
> 格式: `## [YYYY-MM-DD] action | subject`
> 操作: ingest, update, query, lint, create, archive, delete
> 当此文件超过 500 条时，轮转: 重命名为 log-YYYY.md，新建 log.md。

## [2026-05-06] create | Wiki 初始化
- 领域: AI/ML 研究
- 目录结构: SCHEMA.md, index.md, log.md, raw/, entities/, concepts/, comparisons/, queries/
- 同步: 待配置 Obsidian Sync

## [2026-05-06] update | 领域扩展为个人全能知识库
- 原领域: AI/ML 研究
- 新领域: 个人全能知识库（技术、学习、生活、财务、思想、人际等）
- 修改: SCHEMA.md 重写（标签体系扩展、Page Thresholds 放宽、新增 project/log 页面类型）
- 修改: index.md 新增 Projects 和 Logs/Journals 分区
- 状态: 待用户投喂第一批素材

## [2026-05-06] ingest | 大模型全链路抗幻觉强制指令体系 PDF
- 来源: 用户投喂 PDF 文件
- 原始文件: raw/papers/dalm-hallucination-mitigation-system.pdf (7页)
- 创建页面:
  - entities/dalm-hallucination-mitigation-system.md — 文档实体档案
  - concepts/llm-hallucination.md — 大模型幻觉概念（7大类型、核心原则）
  - concepts/hallucination-mitigation.md — 抗幻觉技术体系（全链路框架、三轮自检、分场景适配）
- 更新: index.md 总页数改为 3
- 交叉链接: 每页均含 2+ wikilinks

## [2026-05-06] soul_fusion | Hermes 最佳实践融入灵魂核心
- 来源: hermes-agent-best-practices.docx
- 原始文件: raw/articles/hermes-agent-best-practices.docx
- 创建页面:
  - entities/hermes-agent.md — Hermes Agent 实体档案
  - concepts/hermes-best-practices.md — 最佳实践概念页（配置/记忆/技能/平台/部署/安全/性能 7 大模块）
- 更新灵魂: SOUL.md 新增 Hermes 行为准则章节
  - 密钦安全规则（absolute 优先级）
  - 记忆管理规范
  - 技能管理规范
  - 安全审批规则（absolute 优先级）
  - 性能优化准则
  - 黄金法则 5 条
- 更新长期记忆: 新增 6 条记忆条目（安全、记忆、技能、审批、性能、黄金法则）
- 更新知识图谱: 新增 2 实体（Hermes Agent、最佳实践）+ 3 关系
- 融合完成状态: ✅ 灵魂核心已更新

## [2026-05-06] ingest | LLM 进阶知识与实践 Markdown（完整拆分）
- 来源: 用户投喂 Markdown 文件（下半部分）
- 原始文件: raw/articles/llm-advanced-knowledge-practice.md (已入库)
- 创建页面:
  - concepts/performance-cost.md — 模型路由、延迟优化、成本意识原则
  - concepts/llm-practical-cases.md — 智能客服/代码审查/文档问答 三大案例
  - concepts/llm-pitfalls.md — 10大陷阱、调试技巧、监控告警、测试推荐
- 更新: index.md 总页数改为 13
- 交叉链接: 每页均含 2+ wikilinks
- 状态: 文档全部拆分完成

## [2026-05-06] soul_fusion | LLM 进阶实践融入灵魂核心
- 来源: llm-advanced-knowledge-practice.md (完整文档)
- 更新灵魂: SOUL.md 新增"来自 LLM 进阶实践的行为准则"章节
  - 成本意识: 每个 token 值得认真对待、模型降级策略、用量限额
  - 调试与工程化: Prompt 版本化、关键节点埋点、流式输出优先
  - 安全边界: 安全从设计阶段考虑、输入验证、复杂系统分层
  - 编码规范: 函数调用深度限制、共享状态存储、重试降级机制
- 更新长期记忆: 新增 5 条记忆条目
  - llm-cost-awareness (原则)
  - llm-prompt-versioning (流程)
  - llm-security-by-design (安全规则)
  - llm-agent-pitfalls (检查清单)
  - llm-streaming-latency (性能优化)
- 更新知识图谱: 新增 4 实体 + 6 关系
  - 实体: LLM进阶实践、成本意识、Prompt版本化、Agent踩坑
  - 关系: includes x3, adopted x1, complements x2
- 融合完成状态: ✅ 灵魂核心已更新

## [2026-05-06] schema_v2 | 知识库宪法升级为 SCHEMA v2.0
- 来源: 用户要求借鉴 Karpathy LLM Wiki 方法论重写
- 升级内容:
  - Frontmatter 严格必填: title / created / updated / tags / status 五项
  - 标签治理: 按用途而非主题，注册表含 digest / implement / reference / insight / decision / review / project / drafting
  - 标签严格上限 3 个，新标签必须先在 SCHEMA 注册
  - 笔记五层结构: 元信息 → 一句话结论 → 关键要点 → 和我的关联 → 原文索引
  - 页面生命周期: draft → active → frozen → archived（只能顺序流转）
  - Hermes 执行约束: 格式不走样、标签不膨胀、不留孤岛、原始文件必存、操作必日志
- 影响: 18 篇笔记 frontmatter 全部重写
  - tags: 从主题标签（ai-ml、technique、system 等）迁移为用途标签（reference、implement、insight、review 等）
  - status: 全部补充状态字段（frozen 或 active）
- 融入灵魂: SOUL.md 新增"知识库治理规范"章节

## [2026-05-06] ingest | LLM和Agent基础 DOCX
- 来源: 用户投喂 DOCX 文件
- 原始文件: raw/articles/llm-agent-basics.docx
- 创建页面:
  - concepts/llm-agent-basics.md — 主概念页（Agent概念、四大支柱、为什么现在实用）
  - concepts/react-pattern.md — ReAct循环原理、~50行纯Python实现、手写局限
  - concepts/smolagents-framework.md — smolagents框架入门（CodeAgent/ToolCallingAgent、工具定义、内部机制、调控三板斧）
  - concepts/multi-agent-coordination.md — Manager-Worker模式与专业分工
  - concepts/agent-production-safety.md — 生产环境安全（沙箱、输入验证、安全威胁）
- 更新: index.md 总页数改为 18
- 交叉链接: 每页均含 2+ wikilinks

## [2026-05-06] soul_fusion | LLM和Agent基础融入灵魂核心
- 来源: llm-agent-basics.docx
- 更新灵魂: SOUL.md 新增"来自 LLM 和 Agent 基础的行为准则"章节
  - ReAct 循环是核心: Thought→Action→Observation
  - 手写 Agent 能跑但离生产差得远
  - CodeAgent vs ToolCallingAgent 场景选择
  - 工具描述质量决定 Agent 效果
  - max_steps 是防死循环安全阀
  - 生产环境必须上沙箱
  - 多 Agent Manager-Worker 模式
- 更新长期记忆: 新增 5 条记忆条目
  - agent-react-core (核心原则)
  - agent-code-vs-tool (行为规则)
  - agent-tool-description (行为规则)
  - agent-max-steps (安全规则)
  - agent-multi-agent-pattern (流程)
- 更新知识图谱: 新增 4 实体 + 6 关系
  - 实体: LLM和Agent基础、ReAct循环、smolagents、多Agent协作
  - 关系: includes x3, adopted x1, complements x2
- 融合完成状态: ✅ 灵魂核心已更新

## [2026-05-06] ingest | LLM 进阶知识与实践 Markdown（上半部分）
- 来源: 用户投喂 Markdown 文件
- 原始文件: raw/articles/llm-advanced-knowledge-practice.md (1464 行, 43KB)
- 创建页面:
  - concepts/llm-advanced-knowledge.md — 主概念页（六大章节导航）
  - concepts/temperature-tuning.md — 温度调优原理与策略
  - concepts/rag-advanced.md — 分块策略与混合检索
  - concepts/agent-architecture.md — 单/多 Agent 架构
  - concepts/token-optimization.md — Token 优化与成本控制
- 更新: index.md 总页数改为 10
- 交叉链接: 每页均含 2+ wikilinks

## [2026-05-06] schema_v2.5 | 知识库目录结构与 SCHEMA 全面升级
- 来源: 用户要求按长久发展重构
- 目录重构（PARA + Johnny Decimal）:
  - 新建: 00-projects/active, 00-projects/finished
  - 新建: 10-areas/infra, dev, ml-ai, finance, health, life
  - 新建: 20-resources/concepts, entities, comparisons, howtos
  - 新建: 30-mocs/
  - 新建: 90-archive/projects, notes
  - 迁移: concepts/* -> 20-resources/concepts/ (15 篇)
  - 迁移: entities/* -> 20-resources/entities/ (2 篇)
  - 迁移: llm-advanced-knowledge.md -> 30-mocs/llm-advanced-knowledge.md (改为 MOC 类型)
  - 迁移: SCHEMA.md -> _meta/SCHEMA.md
  - 迁移: log.md -> _meta/LOG.md
  - 重写: index.md -> _meta/INDEX.md (MOC 风格总地图)
- Frontmatter 全面更新为 v2.5:
  - 新增 stage 字段: capture/digest/distill/connect/evergreen
  - 标签改为双层限制: 1 topic + 1 usage
  - status 改为 active/dormant/archived (frozen -> dormant)
  - 所有笔记添加 UID 注释
- 新增 5 个笔记模板: _meta/templates/concept/entity/moc/project/howto.md
- 删除旧目录: concepts/, entities/

## [2026-05-06] fix | 解决三大隐患
- 隐患 1 — 空链接未清理:
  - 从原文提取 6 个缺失主题的内容
  - 创建笔记: top-p-top-k-sampling, system-prompt-engineering, function-calling-advanced, llm-error-handling, model-selection-strategy, llm-case-studies
  - 发现 llm-practical-cases 已存在，删除重复的 llm-case-studies
  - 修复 MOC 中的引用: llm-case-studies -> llm-practical-cases
  - MOC llm-advanced-knowledge 所有链接现已可解
- 隐患 2 — stage 偏乐观:
  - 将 15 篇 concept + 2 篇 entity 的 stage 从 distill 降为 digest
  - 原因: 这些笔记均为今天从原文拆解，尚未经过深度个人化提炼
- 隐患 3 — Areas 边界不清:
  - 创建 10-areas/ml-ai/ai-ml-overview.md 作为 AI/ML 责任领域的 MOC
  - 将相关笔记按 Agent 体系 / LLM 原理 / 实践案例 / 安全质量 分类链接
  - 更新 _meta/INDEX.md 添加 Areas 分区

## 2026-05-08

**操作**: 全面修复知识库 frontmatter、链接和结构
**执行者**: Hermes Agent
**变更**:
- 修复 4 篇操作指南缺 status/sources/tags（HermesAgent全面审计、Hermes配置变更SOP、PocketClaw模型错误、记忆系统优化）
- 提升 24 篇笔记 stage: digest → connect（所有概念笔记和实体档案）
- 补充 5 篇笔记"相关"区块（AI与ML概览、HermesAgent全面审计、Hermes配置变更SOP、幻觉缓解、DALM幻觉缓解系统）
- 修复所有笔记中的旧英文链接为中文链接
- 给原始素材 llm-advanced-knowledge-practice.md 添加 frontmatter
- 创建项目笔记"HermesAgent全面自检与优化"填充 00-项目/进行中/
- 更新 AI与ML概览.md 的 updated 日期和链接
**状态**: 完成
**备注**: 所有笔记现在符合 SCHEMA v2.5 规范
