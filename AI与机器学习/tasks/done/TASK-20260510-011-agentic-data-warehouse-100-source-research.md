---
task_id: TASK-20260510-011-agentic-data-warehouse-100-source-research
title: "AI智能体驱动数仓重构：100篇成熟方案/框架/项目研究"
owner: "用户"
target_agent: "深度研究智能体"
task_type: "KNOWLEDGE"
knowledge: true
objective: "围绕当前项目：AI智能体辅助数仓重构、Windows测试环境、dbt建模、Dolphin/DataX调度同步、速程监控、Agent协同、后续AI读数，系统研究不少于100个相关成熟方案、框架、项目、官方文档、工程实践和案例，并形成可落地的方案收敛报告。"
allowed_actions:
  - 搜索和阅读公开资料
  - 阅读官方文档
  - 阅读成熟开源项目文档
  - 阅读工程实践文章
  - 阅读数据治理/数仓/dbt/Agent框架资料
  - 归纳对当前项目有用的结论
  - 输出100源阅读清单
  - 输出适配/不适配判断
  - 输出推荐主路径
  - 更新 LLM Wiki/GitHub
forbidden_actions:
  - 修改生产数据库
  - 修改生产调度
  - 修改任何运行配置
  - 自动安装软件
  - 自动创建生产任务
  - 复制长篇受版权保护正文
  - 泄露密钥/token/连接串
  - force push
acceptance_criteria:
  - 阅读/整理不少于100个来源
  - 每个来源必须有名称、URL或出处、类别、关键结论、对本项目的适用性判断
  - 来源必须覆盖 Agent框架、AgentOS、任务编排、GitOps、数仓建模、dbt、调度、数据质量、数据可观测、语义层、AI读数、Human-in-the-loop、生产安全
  - 明确哪些方案适合当前阶段
  - 明确哪些方案过重或不适合当前阶段
  - 输出一份面向本项目的主路径建议
  - 输出一个分阶段实施路线
  - 更新 Wiki/GitHub 并记录 commit id
output_paths:
  - "/root/multica-work/output/20260510-Agentic数仓重构100源研究报告.md"
  - "/root/wiki/20-resources/agentic-data-warehouse-100-source-research.md"
knowledge_update_required: true
timeout_minutes: 180
created_at: "2026-05-10T10:30:00+09:00"
---

# AI智能体驱动数仓重构：100源研究任务

## 背景
用户明确要求：在推进当前工作流前，至少阅读100篇/100个与当前工作流相关的文章、成熟方案、成熟框架和项目。

本项目不是普通数仓重构，而是：

```text
AI智能体参与数仓建造、开发、监控、排查问题、后续读数的标准化体系建设。
```

当前已知项目约束：
- 生产不动；
- Windows测试环境先行；
- AI只建议，不自动改生产；
- ChatGPT为统一方案裁决层；
- GitHub任务总线 + PocketClaw + Multica + Agent；
- 三类Agent：数据专家、数仓管家、深度研究智能体；
- 技术栈涉及 dbt、DolphinScheduler、DataX、PolarDB、速程监控、Windows测试环境。

## 必须覆盖的100源分类

### A. Agent / AgentOS / 多智能体协同（至少15个）
研究：
- Agent运行时
- 多Agent编排
- Tool use
- Memory
- Human-in-the-loop
- 任务生命周期
- Agent governance
- Agent observability

### B. 任务总线 / GitOps / Workflow（至少10个）
研究：
- GitHub/Git作为任务总线
- IssueOps
- GitOps
- 工作流状态机
- 审批与回滚
- 任务闭环

### C. 数仓现代化 / 数据建模（至少15个）
研究：
- 分层建模
- ODS/DWD/ADS
- Kimball/Inmon/Data Vault/宽表/指标层
- 旧数仓重构方法
- 渐进式重构
- 新旧并跑

### D. dbt / SQL工程化（至少12个）
研究：
- dbt官方文档
- dbt项目结构
- dbt tests
- dbt docs
- exposures
- semantic layer
- dbt + orchestration
- dbt + data quality

### E. 调度与同步（至少10个）
研究：
- DolphinScheduler
- Airflow
- Dagster
- Prefect
- DataX
- Airbyte
- CDC
- 增量同步
- 物理删除处理

### F. 数据质量 / 数据可观测（至少12个）
研究：
- Great Expectations
- Soda
- Monte Carlo
- Elementary
- OpenLineage/Marquez
- 数据SLA
- 空表、陈旧表、行数异常、schema drift

### G. AI辅助数据分析 / AI读数 / 语义层（至少10个）
研究：
- Text-to-SQL安全
- semantic layer
- metrics layer
- Cube / MetricFlow / dbt Semantic Layer
- AI分析助手如何防止幻觉
- 指标口径治理

### H. 生产安全 / 沙箱 / Human Approval（至少8个）
研究：
- 生产冻结
- 沙箱验证
- 新旧比对
- 人工审批
- 只读权限
- 回滚
- 变更管理

### I. 企业知识库 / 文档 / Runbook（至少8个）
研究：
- Runbook
- SRE playbook
- ADR
- Docs-as-code
- 知识沉淀
- 事后复盘

## 每个来源记录格式

每个来源必须按以下格式记录：

```yaml
id: SRC-001
name: 来源名称
url_or_source: 链接或出处
category: A/B/C/D/E/F/G/H/I
source_type: official_doc / framework / open_source_project / case_study / engineering_blog / paper
summary: 关键内容摘要
relevant_to_project: high / medium / low
usable_now: yes / no / later
why: 为什么适合或不适合
recommended_action: 对当前项目的建议动作
```

## 输出报告结构

报告标题：
《AI智能体驱动数仓重构100源研究报告》

必须包含：

001 一页总览结论
- 100源阅读完成情况
- 最重要的10条结论
- 当前项目最应该采用的主路径

002 来源清单
- 不少于100条
- 按分类组织

003 成熟方案对比
- Agent协同方案
- 数仓重构方案
- dbt工程化方案
- 数据质量方案
- AI读数方案

004 当前项目适配判断
- 适合立即采用
- 适合稍后采用
- 不适合当前阶段
- 明确反对采用

005 推荐主路径
必须结合当前约束：
- 生产不动
- Windows先行
- dbt旁路引入
- Dolphin保留编排
- DataX保留同步
- 速程监控做生产护栏
- AI只建议不动生产

006 分阶段实施路线
- 现在做什么
- 下阶段做什么
- 什么暂时不要做

007 对当前任务体系的改造建议
- ChatGPT / GitHub / PocketClaw / Multica / Agent
- inbox loop / review loop / heartbeat
- 异常任务治理

008 对AI读数的前置条件
- 标准模型
- 语义层
- 指标口径
- 数据质量状态
- 安全查询边界

## 严格边界
本任务是研究任务，不执行任何系统变更。
不得复制长篇受版权保护正文，只做摘要和工程化结论。
