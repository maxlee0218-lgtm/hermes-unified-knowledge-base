# ChatGPT 100源研究日志 - Batch 004

> 创建时间：2026-05-10
> 责任主体：ChatGPT
> 本批范围：调度、同步、CDC、数据质量、数据可观测、生产安全。

---

## Batch 004 来源清单

| ID | 来源 | 类别 | 类型 | ChatGPT判断 |
|---|---|---|---|---|
| SRC-051 | Apache DolphinScheduler Official Docs: https://dolphinscheduler.apache.org/en-us/docs/latest/user_doc/guide/quick-start.html | 调度 | official_doc | 高适配。当前生产和测试都涉及 Dolphin，必须保留并摸清工作流、任务定义、release_state、依赖和调度周期。 |
| SRC-052 | DolphinScheduler Architecture: https://dolphinscheduler.apache.org/en-us/docs/latest/user_doc/about/architecture.html | 调度架构 | official_doc | 高适配。应借鉴其 master/worker/alert/api 等组件边界，避免误判调度故障来源。 |
| SRC-053 | DolphinScheduler Task Definition: https://dolphinscheduler.apache.org/en-us/docs/latest/user_doc/guide/project/workflow-definition.html | 工作流定义 | official_doc | 高适配。重构前必须盘点 workflow、task、dependency、schedule、release_state。 |
| SRC-054 | Apache Airflow DAGs: https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html | DAG / 调度概念 | official_doc | 中适配。DAG 概念可用于重新表达 Dolphin 链路和 dbt 模型依赖。 |
| SRC-055 | Airflow Best Practices: https://airflow.apache.org/docs/apache-airflow/stable/best-practices.html | 调度最佳实践 | official_doc | 中适配。借鉴幂等、可重试、测试、分区等原则；不替换 Dolphin。 |
| SRC-056 | Dagster Assets: https://docs.dagster.io/concepts/assets/software-defined-assets | 数据资产编排 | official_doc | 中参考。资产驱动模型适合指导“表是资产，不只是任务产物”的盘点方式。 |
| SRC-057 | Dagster Asset Checks: https://docs.dagster.io/concepts/assets/asset-checks | 数据质量检查 | official_doc | 中参考。asset checks 思路可用于速程监控和 dbt tests 的统一表达。 |
| SRC-058 | Prefect Work Pools: https://docs.prefect.io/v3/concepts/work-pools | Worker / 执行池 | official_doc | 中参考。当前 Windows 执行面可借鉴 work pool 隔离思想。 |
| SRC-059 | Airbyte Incremental Sync: https://docs.airbyte.com/platform/using-airbyte/core-concepts/sync-modes/incremental-append | 增量同步 | official_doc | 中参考。Airbyte 的增量同步模式可对照 DataX 增量窗口漏洞。 |
| SRC-060 | Airbyte CDC: https://docs.airbyte.com/platform/using-airbyte/core-concepts/sync-modes/incremental-deduped-history | CDC / 去重历史 | official_doc | 中参考。CDC/历史模式对物理删除和更新捕获有参考，但当前不急于替换 DataX。 |
| SRC-061 | Debezium SQL Server Connector: https://debezium.io/documentation/reference/stable/connectors/sqlserver.html | CDC | official_doc | 低到中参考。当前源多为 MySQL/PolarDB 相关，SQL Server 仅作 CDC 思路参考。 |
| SRC-062 | Debezium Outbox Pattern: https://debezium.io/documentation/reference/stable/transformations/outbox-event-router.html | 事件同步 | official_doc | 低参考。对当前离线数仓过重，不作为第一阶段。 |
| SRC-063 | Kafka Connect Concepts: https://docs.confluent.io/platform/current/connect/concepts.html | 数据管道 | vendor_doc | 中参考。长期数据同步平台化会涉及 connectors、source/sink、offset；当前不引入。 |
| SRC-064 | Great Expectations Expectations: https://docs.greatexpectations.io/docs/reference/learn/terms/expectation | 数据质量规则 | official_doc | 高参考。Expectation 模型可转化为速程监控规则与 dbt tests。 |
| SRC-065 | Great Expectations Checkpoints: https://docs.greatexpectations.io/docs/reference/learn/terms/checkpoint | 数据质量执行 | official_doc | 中参考。checkpoint 思路对应定期质量巡检和结果归档。 |
| SRC-066 | SodaCL Reference: https://docs.soda.io/soda-cl/soda-cl-overview.html | 质量规则代码化 | official_doc | 中参考。质量规则应该文本化、版本化、可复用。 |
| SRC-067 | Monte Carlo Data Observability: https://www.montecarlodata.com/data-observability/ | 数据可观测 | vendor_guide | 中参考。可观测维度包括 freshness、volume、schema、lineage、quality，适合速程监控定位。 |
| SRC-068 | Datafold Data Diff: https://docs.datafold.com/docs/data-diff-overview | 新旧比对 | vendor_doc | 高参考。新旧链路并跑时必须做 data diff、行数、指标和字段层比对。 |
| SRC-069 | dbt Audit Helper: https://github.com/dbt-labs/dbt-audit-helper | 新旧比对 | open_source_project | 高适配。适合 dbt pilot 阶段做表对比、列对比和迁移校验。 |
| SRC-070 | dbt Expectations: https://github.com/calogica/dbt-expectations | dbt质量测试 | open_source_project | 中适配。可扩展 dbt tests，但第一阶段先用内置测试即可。 |
| SRC-071 | OpenLineage Integration Overview: https://openlineage.io/docs/ | 血缘采集 | official_doc | 中参考。当前先不接入，但应模仿 job/run/dataset 元数据结构。 |
| SRC-072 | Marquez: https://marquezproject.ai/ | 血缘服务 | open_source_project | 低到中参考。太重，不先部署；可借鉴 UI/lineage 概念。 |
| SRC-073 | Google SRE Incident Management: https://sre.google/sre-book/managing-incidents/ | 事故管理 | official_book | 高参考。异常任务、红色任务、blocked/failed 必须有分级、升级和人工决策。 |
| SRC-074 | Google SRE Monitoring Distributed Systems: https://sre.google/sre-book/monitoring-distributed-systems/ | 监控 | official_book | 中参考。速程监控应关注症状、SLA、错误预算，而不是只堆指标。 |
| SRC-075 | Atlassian Incident Management Guide: https://www.atlassian.com/incident-management | 事故管理 | vendor_guide | 中参考。适合设计异常任务的响应、沟通、复盘流程。 |

---

## Batch 004 收敛结论

001 Dolphin 仍是当前最现实的编排层，不应被 dbt、Airflow、Dagster 替换。

002 Windows 测试环境要建立“执行池”概念，避免 GPT、Dolphin、dbt、监控、Agent 混成一团。

003 DataX 的问题不是工具不可用，而是增量策略、删除捕获、晚到数据和补偿机制需要治理。

004 数据质量规则要代码化、版本化、可复用。第一阶段优先采用 dbt tests + 速程监控，不急于引入 Great Expectations / Soda 全套平台。

005 新旧并跑不能只看总数，必须有 data diff、字段差异、时间窗口差异、业务口径差异解释。

006 异常任务治理应借鉴 SRE 事故管理：分级、升级、记录、复盘、人工确认，不自动恢复生产。

---

## 当前累计进度

- Batch 001：12源
- Batch 002：18源
- Batch 003：20源
- Batch 004：25源
- 累计：75源 / 100源
