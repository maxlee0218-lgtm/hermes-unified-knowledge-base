# ChatGPT 100源研究日志 - Batch 003

> 创建时间：2026-05-10
> 责任主体：ChatGPT
> 本批范围：dbt工程化、语义层、指标层、数据建模、Data Vault、数仓现代化。

---

## Batch 003 来源清单

| ID | 来源 | 类别 | 类型 | ChatGPT判断 |
|---|---|---|---|---|
| SRC-031 | dbt Tests: https://docs.getdbt.com/docs/build/data-tests | dbt / 数据质量 | official_doc | 高适配。dbt tests 可作为 Windows 新链路的第一层质量门禁，适合先覆盖 not_null、unique、relationships、accepted_values。 |
| SRC-032 | dbt Sources: https://docs.getdbt.com/docs/build/sources | dbt / 源表管理 | official_doc | 高适配。sources 可记录 ODS/源表新鲜度和来源，是重构前把 DataX/ODS 边界写清楚的关键。 |
| SRC-033 | dbt Freshness: https://docs.getdbt.com/reference/resource-properties/freshness | dbt / freshness | official_doc | 高适配。对空表、陈旧表、同步断流非常有价值，应纳入速程监控和 dbt 测试组合。 |
| SRC-034 | dbt Exposures: https://docs.getdbt.com/docs/build/exposures | dbt / 下游消费 | official_doc | 高适配。用于记录报表、大屏、监控、下游消费，解决“表谁在用”的问题。 |
| SRC-035 | dbt Docs: https://docs.getdbt.com/docs/collaborate/documentation | dbt / 文档 | official_doc | 高适配。为 AI 后续读数提供字段、模型、血缘解释基础。 |
| SRC-036 | dbt Semantic Layer: https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl | 语义层 / 指标 | official_doc | 高适配但稍后采用。AI读数必须依托语义层，但第一阶段先把模型和口径文档做好。 |
| SRC-037 | MetricFlow: https://docs.getdbt.com/docs/build/metricflow | 指标层 | official_doc | 高参考。MetricFlow 的 metrics/specs 可作为后续指标口径固化方向。 |
| SRC-038 | dbt Project Structure: https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview | dbt / 项目结构 | official_doc | 高适配。Windows dbt 项目应按 staging/intermediate/marts 或 ODS/DWD/ADS 适配分层。 |
| SRC-039 | dbt Incremental Models: https://docs.getdbt.com/docs/build/incremental-models | dbt / 增量建模 | official_doc | 高适配但谨慎使用。第一阶段可先全量小样本验证，后续再引入增量。 |
| SRC-040 | dbt Snapshots: https://docs.getdbt.com/docs/build/snapshots | dbt / 历史变更 | official_doc | 中适配。适合捕获维表缓慢变化，但不解决源端物理删除全部问题。 |
| SRC-041 | Kimball Group Dimensional Modeling: https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/ | 数仓建模 | methodology | 高适配。ADS/报表层应更接近维度建模和业务过程，而不是无限堆宽表。 |
| SRC-042 | Kimball Bus Architecture: https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/kimball-data-warehouse-bus-architecture/ | 数仓架构 | methodology | 高参考。重构不应一次性全域改造，应先做可复用的一条业务过程样板链。 |
| SRC-043 | Data Vault Alliance: https://datavaultalliance.com/ | Data Vault | methodology | 中参考。适合复杂历史追踪，但当前阶段过重，不作为第一阶段主路径。 |
| SRC-044 | Data Vault 2.0 overview: https://www.datavaultalliance.com/news/dv/dv20 | Data Vault | methodology | 低到中适配。理念可参考，但你们当前更需要低成本旁路试点。 |
| SRC-045 | Microsoft Fabric Medallion Architecture: https://learn.microsoft.com/fabric/onelake/onelake-medallion-lakehouse-architecture | 分层架构 | official_doc | 中参考。Bronze/Silver/Gold 与 ODS/DWD/ADS 类似，可借鉴数据质量逐层提升思想。 |
| SRC-046 | Databricks Medallion Architecture: https://www.databricks.com/glossary/medallion-architecture | 分层架构 | vendor_doc | 中参考。强调逐层清洗、验证、聚合，支持 Windows 试验链路分层。 |
| SRC-047 | DataHub Metadata Platform: https://datahubproject.io/ | 元数据 / 数据目录 | open_source_project | 中参考。当前不部署，但其元数据、血缘、ownership 模型可借鉴。 |
| SRC-048 | DataHub Lineage: https://docs.datahub.com/docs/lineage/lineage-feature-guide | 血缘 | official_doc | 中参考。支持字段级血缘和影响分析，说明重构前必须看下游影响。 |
| SRC-049 | Apache Atlas: https://atlas.apache.org/ | 元数据治理 | open_source_project | 低到中适配。工具较重，不适合当前，但概念模型可参考。 |
| SRC-050 | Amundsen Data Discovery: https://www.amundsen.io/ | 数据发现 | open_source_project | 低到中适配。说明数据资产目录很重要，但当前不新增平台。 |

---

## Batch 003 收敛结论

001 dbt 应成为 Windows 测试环境的“模型 + 测试 + 文档 + 血缘”层，而不是调度替代品。

002 第一阶段 dbt 最小能力包：sources、models、tests、docs、exposures、freshness。

003 AI 读数的前置不是 LLM 能力，而是模型文档、指标口径、血缘、质量状态和语义层。

004 Data Vault、完整数据目录平台、重型治理平台当前都过重，暂不作为第一阶段落地目标。

005 样板链路应以 ADS_SC_XL_13 为业务过程，优先建立可复制方法，而不是一次性治理全部表。

---

## 当前累计进度

- Batch 001：12源
- Batch 002：18源
- Batch 003：20源
- 累计：50源 / 100源
