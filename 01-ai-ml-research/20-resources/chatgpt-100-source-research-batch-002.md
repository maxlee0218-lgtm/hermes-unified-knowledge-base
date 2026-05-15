# ChatGPT 100源研究日志 - Batch 002

> 创建时间：2026-05-10
> 责任主体：ChatGPT
> 本批范围：Agent编排、IssueOps、CDC、语义层、元数据、数据血缘、数据质量、调度同步。

---

## Batch 002 来源清单

| ID | 来源 | 类别 | 类型 | ChatGPT判断 |
|---|---|---|---|---|
| SRC-013 | LangGraph Persistence: https://docs.langchain.com/oss/python/langgraph/persistence | Agent运行时 / 状态持久化 | official_doc | 高适配。checkpoints、threads、human-in-the-loop、time travel、fault tolerance 对当前 PocketClaw/Multica/Agent 任务状态治理有直接借鉴价值。 |
| SRC-014 | LangGraph Human-in-the-loop: https://langchain-ai.lang.chat/langgraph/tutorials/get-started/4-human-in-the-loop/ | Agent审批 / 人机协同 | official_doc | 高适配。interrupt/resume 思路可转化为生产动作必须人工确认、异常任务进入人工决策队列。 |
| SRC-015 | Microsoft AutoGen stable docs: https://microsoft.github.io/autogen/stable/index.html | 多Agent框架 | official_doc | 中适配。AutoGen 的 AgentChat/Core/Extensions 可借鉴，但当前不建议替换已跑通的 GitHub + PocketClaw + Multica 链路。 |
| SRC-016 | AutoGen 0.2 Multi-agent Conversation Framework: https://microsoft.github.io/autogen/0.2/docs/Use-Cases/agent_chat | 多Agent协作 | official_doc | 中适配。多 Agent 对话适合研究，但当前项目更需要任务状态机和证据闭环，而不是开放式群聊。 |
| SRC-017 | Microsoft Agent Framework migration from AutoGen: https://learn.microsoft.com/agent-framework/migration-guide/from-autogen/ | Agent框架演进 | official_doc | 中适配。说明真实企业 Agent 框架会从聊天式协作转向更结构化的运行时与工作流。支持我们当前收敛到任务总线和状态机。 |
| SRC-018 | IssueOps Docs: https://issue-ops.github.io/docs/ | IssueOps / GitHub任务总线 | community_doc | 高适配。Issue/PR作为用户界面，背后用自动化驱动流程，这与当前 GitHub tasks/inbox 任务总线高度一致。 |
| SRC-019 | IssueOps Issue Workflow: https://issue-ops.github.io/docs/setup/issue-workflow | IssueOps状态处理 | community_doc | 高适配。opened/edited/reopened 事件、label控制、validate/approve/deny 可借鉴到 task_inbox_check 和 review_loop。 |
| SRC-020 | Debezium Architecture: https://debezium.io/documentation/reference/stable/architecture.html | CDC / 同步架构 | official_doc | 中适配。当前不建议马上引入 Kafka/Debezium，但 CDC 架构可作为 DataX 近30天窗口、物理删除、晚到数据问题的长期替代方向。 |
| SRC-021 | Debezium MySQL Connector: https://debezium.io/documentation/reference/stable/connectors/mysql.html | MySQL CDC / 删除捕获 | official_doc | 高参考。binlog可捕获 INSERT/UPDATE/DELETE，正好对应当前 DataX 无法可靠处理物理删除的问题；但落地复杂，暂列后续方案。 |
| SRC-022 | Debezium Tutorial: https://debezium.io/documentation/reference/stable/tutorial.html | CDC实践 | official_doc | 中适配。可作为未来小规模 CDC PoC 教材，不应阻塞当前 Windows 测试环境和 dbt pilot。 |
| SRC-023 | Airbyte Docs: https://docs.airbyte.com/ | 数据复制 / AI上下文层 | official_doc | 中适配。Airbyte 适合标准化 API/连接器同步，长期可替代手写 API 同步；当前先不引入，避免新系统过重。 |
| SRC-024 | Cube Introduction: https://docs.cube.dev/docs/introduction | 语义层 / AI分析 | official_doc | 高参考。Cube强调人和AI都使用开放语义层，支持当前“后续AI读数必须基于标准语义层”的判断。 |
| SRC-025 | Cube Data Modeling: https://docs.cube.dev/docs/data-modeling/overview | 语义建模 | official_doc | 高参考。measures、dimensions、views 对后续指标口径和 AI 读数非常关键；但当前先用 dbt/文档打基础。 |
| SRC-026 | OpenMetadata Lineage API: https://docs.open-metadata.org/v1.12.x/api-reference/lineage | 元数据 / 血缘 | official_doc | 高参考。entity-to-entity lineage、column-level mappings、pipeline reference 对当前 ADS/DWD/ODS 血缘盘点有直接借鉴价值。 |
| SRC-027 | OpenMetadata Explore Lineage: https://docs.open-metadata.org/how-to-guides/data-lineage/explore | 血缘探索 | official_doc | 高参考。表、Dashboard、Pipeline血缘和column-level lineage说明：重构前必须不仅看表，还要看报表和下游消费。 |
| SRC-028 | OpenMetadata GitHub: https://github.com/open-metadata/OpenMetadata | 数据治理平台 | open_source_project | 中适配。OpenMetadata 太重，不建议当前引入；但它的数据目录、血缘、质量、协作模型值得作为目标形态参考。 |
| SRC-029 | OpenMetadata Standards - Lineage: https://openmetadatastandards.org/lineage/lineage/ | 血缘标准 | open_standard | 高参考。数据流、column lineage、transformation logic、impact analysis 都应进入重构前摸排基线。 |
| SRC-030 | MetricLayer Semantic Layer Guide: https://www.metriclayer.dev/semantic-layer/ | 语义层 / 指标治理 | engineering_guide | 中参考。强调集中管理 grain、filters、aggregations、version-controlled YAML，对指标口径漂移治理有启发。 |

---

## Batch 002 收敛结论

001 Agent 方向：不要把当前系统改成开放式多Agent聊天。当前更需要的是：任务状态机、checkpoint、人工审批、异常升级、证据闭环。

002 GitHub任务总线方向：IssueOps/GitOps思想支持当前做法，但必须补强 validate / approve / deny / transition 机制，不能只靠 inbox 拉任务。

003 CDC方向：Debezium 能解决 DataX 对物理删除、晚到数据、增量窗口不稳的问题，但当前引入成本高，暂不作为第一阶段主路径。

004 语义层方向：AI 读数的前置不是“让AI直接查库”，而是必须有语义层、指标口径、血缘、质量状态。Cube / MetricLayer / dbt Semantic Layer 都支持这个判断。

005 元数据方向：OpenMetadata 类平台不适合当前立即部署，但其 lineage / pipeline / dashboard / column-level lineage 模型应该被复制到当前摸排报告结构中。

---

## 当前累计进度

- Batch 001：12源
- Batch 002：18源
- 累计：30源 / 100源

---

## 当前主路径没有改变

```text
生产不动；Windows先行；Dolphin保留编排；DataX保留同步；dbt旁路引入；速程监控做生产护栏；Agent系统强化任务状态机、人审、异常治理和知识沉淀；AI读数必须基于语义层和质量状态。
```
