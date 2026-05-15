# ChatGPT 100源研究日志 - Batch 005

> 创建时间：2026-05-10
> 责任主体：ChatGPT
> 本批范围：Agent工程化、GitOps/IssueOps、AI读数、语义层、文档化、变更治理、最终架构收敛。

---

## Batch 005 来源清单

| ID | 来源 | 类别 | 类型 | ChatGPT判断 |
|---|---|---|---|---|
| SRC-076 | OpenAI Agents SDK Tracing: https://openai.github.io/openai-agents-python/tracing/ | Agent可观测 | official_doc | 高适配。Agent执行必须有trace、span、tool调用记录，当前系统应继续补强任务证据链。 |
| SRC-077 | OpenAI Agents SDK Tools: https://openai.github.io/openai-agents-python/tools/ | Tool use | official_doc | 高适配。工具调用边界要明确，生产工具必须受 guardrails 和人工审批限制。 |
| SRC-078 | OpenAI Agents SDK Handoffs: https://openai.github.io/openai-agents-python/handoffs/ | Agent交接 | official_doc | 高适配。可借鉴 handoff 思路设计数据专家、数仓管家、深度研究智能体之间的交接规范。 |
| SRC-079 | LangGraph Memory Concepts: https://langchain-ai.github.io/langgraph/concepts/memory/ | Agent记忆 | official_doc | 高适配。长期项目必须把经验沉淀到 Wiki/Git，而不是只靠上下文窗口。 |
| SRC-080 | LangGraph Streaming: https://langchain-ai.github.io/langgraph/concepts/streaming/ | Agent运行观测 | official_doc | 中适配。建设期需要可观察进度，但当前通过 heartbeat/status/report 足够。 |
| SRC-081 | GitHub Actions Workflow Syntax: https://docs.github.com/actions/writing-workflows/workflow-syntax-for-github-actions | GitOps / Workflow | official_doc | 中参考。GitHub 原生 workflow 可用于未来自动校验任务文件格式，但当前 PocketClaw 已承担触发。 |
| SRC-082 | GitHub Issues Documentation: https://docs.github.com/issues | IssueOps | official_doc | 高参考。Issue/label/assignee/milestone 可作为任务状态与审批模型，但当前先用 tasks 文件体系。 |
| SRC-083 | GitHub Projects Documentation: https://docs.github.com/issues/planning-and-tracking-with-projects | 项目管理 | official_doc | 中参考。后续可用于可视化 active/review/done，但当前先不新增平台依赖。 |
| SRC-084 | Argo CD GitOps Principles: https://argo-cd.readthedocs.io/en/stable/ | GitOps | official_doc | 低到中参考。GitOps 思想适合知识和配置版本化，但当前不是 Kubernetes 部署项目，不引入 Argo CD。 |
| SRC-085 | Flux GitOps Toolkit: https://fluxcd.io/flux/ | GitOps | official_doc | 低参考。理念可借鉴，工具不适合当前阶段。 |
| SRC-086 | Humanloop Prompt Management: https://humanloop.com/ | LLMOps / Prompt管理 | vendor_doc | 中参考。提示词、评测、版本化对后续AI读数有价值，但当前先用 Wiki/Git 管理规范。 |
| SRC-087 | LangSmith Evaluation: https://docs.smith.langchain.com/evaluation | LLM评测 | official_doc | 中参考。AI读数后续需要评测集和回归测试，当前先沉淀标准问题和正确答案。 |
| SRC-088 | Ragas Documentation: https://docs.ragas.io/ | RAG评测 | open_source_project | 中参考。后续AI读数/知识问答需要评测，但不阻塞数仓样板链路。 |
| SRC-089 | LlamaIndex Workflows: https://docs.llamaindex.ai/en/stable/module_guides/workflow/ | Agent/RAG工作流 | official_doc | 中参考。可借鉴工作流思想，但当前不替换已跑通任务总线。 |
| SRC-090 | LlamaIndex SQL Query Engines: https://docs.llamaindex.ai/en/stable/examples/index_structs/struct_indices/SQLIndexDemo/ | Text-to-SQL | official_doc | 中参考。AI读数不能直接自由 Text-to-SQL，必须有语义层、权限和质量状态约束。 |
| SRC-091 | Vanna AI Docs: https://vanna.ai/docs/ | Text-to-SQL | framework_doc | 中参考。适合后续读数原型，但当前必须先完成标准模型和指标口径。 |
| SRC-092 | Metabase Semantic Layer / Models: https://www.metabase.com/docs/latest/data-modeling/models | BI语义建模 | official_doc | 中参考。可借鉴把复杂SQL封装成模型的思路，避免AI直接读散乱表。 |
| SRC-093 | Apache Superset Semantic Layer: https://superset.apache.org/docs/using-superset/semantic-layer/ | BI语义层 | official_doc | 中参考。metrics/dimensions/datasets 概念对后续AI读数有借鉴。 |
| SRC-094 | Cube Semantic Layer: https://cube.dev/semantic-layer | 语义层 | vendor_doc | 高参考。进一步支持“AI读数要通过语义层”的路线。 |
| SRC-095 | Transform MetricFlow historical docs: https://docs.getdbt.com/docs/build/metricflow | 指标层 | official_doc | 高参考。指标定义版本化，是后续AI读数的重要前置。 |
| SRC-096 | ADR GitHub: https://github.com/joelparkerhenderson/architecture-decision-record | ADR / 决策记录 | open_source_project | 高适配。业务方案、主路径、Go/No-Go 判断应作为 ADR 形式沉淀。 |
| SRC-097 | Diataxis Documentation Framework: https://diataxis.fr/ | 文档体系 | methodology | 中适配。Wiki 应区分教程、操作指南、解释、参考，避免混杂。 |
| SRC-098 | The Twelve-Factor App: https://12factor.net/ | 配置/部署原则 | methodology | 中参考。配置与密钥应从代码中分离，支持当前禁止明文密码入Git。 |
| SRC-099 | OWASP Secrets Management Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html | 安全 / 密钥治理 | security_guide | 高适配。明文密码、token、连接串不得进入 Wiki/Git，迁移前必须脱敏。 |
| SRC-100 | Google SRE Postmortem Culture: https://sre.google/sre-book/postmortem-culture/ | 复盘 / 事故治理 | official_book | 高适配。任务失败、blocked、生产风险、Agent失误都要复盘并写入知识库。 |

---

## Batch 005 收敛结论

001 Agent 工程化不能只看“能不能执行”，还要看：trace、tool边界、handoff、memory、evaluation、postmortem。

002 当前 GitHub + PocketClaw + Multica 方案已经够用，不要急于迁移到复杂 GitOps/Kubernetes 工具。

003 AI读数必须经历四个前置：标准模型、语义层、指标口径、数据质量状态。没有这些，Text-to-SQL 只会放大口径混乱。

004 Wiki 需要从“文件堆积”升级为“决策记录 + 操作手册 + 参考资料 + 复盘”的结构。

005 安全原则必须硬化：所有报告和 Git 文件都不得出现密钥、密码、token、连接串原文。

006 失败和异常不是临时问题，而是系统能力的一部分；必须建立 blocked/failed/review_stuck 的复盘与升级机制。

---

## 当前累计进度

- Batch 001：12源
- Batch 002：18源
- Batch 003：20源
- Batch 004：25源
- Batch 005：25源
- 累计：100源 / 100源

---

## 100源完成后的总判断

当前项目最稳主路径保持不变：

```text
生产不动
Windows测试环境先行
Dolphin保留编排
DataX保留同步
dbt旁路引入作为模型/测试/文档/血缘层
速程监控做生产护栏
Agent系统强化状态机、guardrails、handoff、heartbeat、异常治理、知识沉淀
后续AI读数必须基于标准模型、语义层、指标口径、血缘和数据质量状态
```

当前明确反对：

```text
直接改生产
全面替换Dolphin
全面替换DataX
立刻引入重型数据治理平台
让AI自由Text-to-SQL读生产
把多Agent变成无状态群聊
把100源研究外包给Agent而不由ChatGPT收敛
```
