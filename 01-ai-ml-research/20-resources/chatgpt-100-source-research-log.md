# ChatGPT 100源研究日志

> 创建时间：2026-05-10
> 责任主体：ChatGPT
> 状态：进行中

## 000 纠偏

100源研究由 ChatGPT 亲自负责。深度研究智能体只可作为候选资料收集辅助，不能替代 ChatGPT 完成最终阅读、判断、取舍和主路径收敛。

## Batch 001：首批12个来源

| ID | 来源 | 类别 | 类型 | 当前判断 |
|---|---|---|---|---|
| SRC-001 | dbt Developer Hub: https://docs.getdbt.com/ | dbt / SQL工程化 | official_doc | 高适配。用于 Windows 测试环境的模型、血缘、测试、文档层，不直接替代 Dolphin。 |
| SRC-002 | Apache Airflow Scheduler: https://airflow.apache.org/docs/apache-airflow/stable/administration-and-deployment/scheduler.html | 调度 | official_doc | 中适配。借鉴任务状态、调度器、DAG运行、并发和异常治理，不替换 Dolphin。 |
| SRC-003 | Alibaba DataX: https://github.com/alibaba/DataX | 数据同步 | open_source_project | 高适配。保留 DataX 做同步层，但必须审计增量、删除、晚到数据和补偿。 |
| SRC-004 | Prefect Deployments: https://docs.prefect.io/v3/concepts/deployments | Workflow | official_doc | 中适配。借鉴 deployment、worker、参数化和远程触发模型。 |
| SRC-005 | Dagster Software-defined Assets: https://dagster.io/glossary/software-defined-assets | 数据资产 | framework_doc | 中适配。借鉴“资产优先”思路梳理ODS/DWD/ADS。 |
| SRC-006 | Great Expectations OSS: https://docs.greatexpectations.io/docs/0.18/core/introduction/introduction | 数据质量 | official_doc | 高适配。借鉴数据质量规则即测试、Data Docs、验证报告。 |
| SRC-007 | Soda Core: https://docs.soda.io/soda-core/overview-main.html | 数据质量 | official_doc | 中适配。借鉴 checks-as-code，不急于引入工具。 |
| SRC-008 | Elementary for dbt: https://docs.elementary-data.com/features/data-tests/dbt-tests | dbt观测 | official_doc | 高适配。借鉴 freshness、volume、schema、test result、exposure 监控。 |
| SRC-009 | OpenLineage: https://openlineage.io/ | 血缘 / 可观测 | open_standard | 中适配。借鉴 dataset/job/run 元数据模型。 |
| SRC-010 | OpenAI Agents SDK Guardrails: https://openai.github.io/openai-agents-python/guardrails/ | Agent治理 | official_doc | 高适配。借鉴输入、输出、工具调用的 guardrail 思路，强化生产边界。 |
| SRC-011 | CrewAI Documentation: https://docs.crewai.com/ | 多Agent | framework_doc | 中适配。借鉴 roles、flows、guardrails、memory、knowledge、observability。 |
| SRC-012 | Airflow Cron and Time Intervals: https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/cron.html | 调度时间窗口 | official_doc | 中适配。用于校正业务日、data_date、work_data_date 和调度周期。 |

## Batch 001 初步收敛

第一批研究支持当前主路径：

```text
生产不动；Windows先行；Dolphin保留编排；DataX保留同步；dbt旁路引入；速程监控承担生产护栏；Agent系统先强化边界、状态机、heartbeat和异常治理。
```

## 下一批研究方向

- LangGraph / AutoGen / IssueOps / GitOps；
- dbt tests、docs、exposures、semantic layer；
- DolphinScheduler 官方文档；
- Airbyte / CDC / Debezium；
- MetricFlow / Cube / semantic layer；
- SRE runbook / incident management。
