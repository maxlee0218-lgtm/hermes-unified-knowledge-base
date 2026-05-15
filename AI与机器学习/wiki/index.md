# Wiki 索引

> 最后更新：2026-05-14  
> 当前页面数：约 94 个  
> 当前阶段：新 Hermes 单体首脑接手，多智能体暂停，知识库整理中

---

## 当前入口

- [当前主路径](00-当前主路径.md) - 当前阶段该做什么、不做什么
- [当前决策总账](outputs/当前决策总账.md) - 当前有效决策统一入口
- [AI数仓协作架构图与流程](outputs/AI数仓协作架构图与流程.md) - 当前架构图和任务流程图
- [操作日志](log.md) - 知识库变更记录
- [概览](overview.md) - 知识库总体说明

## 当前主路径摘要

```text
新 Hermes 作为单体首脑
llm-wiki 作为唯一正式知识底座
Windows 已重置，暂不纳入执行链路
Multica / 多智能体 / 任务管家 / 数据虾 / 代码工全部暂停
数据库 / MCP / 生产系统全部暂停
当前只做知识库接手和状态收口
```

---

## 概念（Concepts）

- [AgentRoleBoundary](concepts/AgentRoleBoundary.md) - Agent角色边界
- [CommandGateway](concepts/CommandGateway.md) - 命令网关
- [DoneArchiveLifecycle](concepts/DoneArchiveLifecycle.md) - Done归档生命周期
- [LLMWikiIngest](concepts/LLMWikiIngest.md) - LLM Wiki摄入流程
- [ProductionGuardrails](concepts/ProductionGuardrails.md) - 生产保护规范
- [ReadOnlyFirst](concepts/ReadOnlyFirst.md) - 只读优先原则
- [ReportValidation](concepts/ReportValidation.md) - 报告验证规范
- [ReviewBacklogGovernance](concepts/ReviewBacklogGovernance.md) - Review积压治理
- [RuntimeFlowGuard](concepts/RuntimeFlowGuard.md) - Runtime流程守护
- [WarehouseRebuildPlaybook](concepts/WarehouseRebuildPlaybook.md) - 数仓重构手册

## 实体（Entities）

- [ADS_SC_XL_13](entities/ADS_SC_XL_13.md) - ADS表实体
- [ChatGPT](entities/ChatGPT.md) - ChatGPT工具
- [Codex](entities/Codex.md) - Codex工具
- [Corelli](entities/Corelli.md) - Corelli项目
- [DataShrimp](entities/DataShrimp.md) - DataShrimp工具
- [DataX](entities/DataX.md) - DataX同步工具
- [DolphinScheduler](entities/DolphinScheduler.md) - DolphinScheduler调度
- [GitHub](entities/GitHub.md) - GitHub平台
- [KimiClawWindowsWorker](entities/KimiClawWindowsWorker.md) - KimiClaw Windows执行器
- [Multica](entities/Multica.md) - Multica多卡系统
- [RuntimeChief](entities/RuntimeChief.md) - Runtime治理者
- [WarehouseSteward](entities/WarehouseSteward.md) - 数仓管家
- [dbt](entities/dbt.md) - dbt转换工具

## 来源（Sources）

- [sources/README](sources/README.md) - 来源目录
- [knowledge-base-rules](sources/knowledge-base-rules.md) - 知识库规则
- [llm-wiki-complete-upgrade-spec](sources/llm-wiki-complete-upgrade-spec.md) - 升级规范
- [multica-command-gateway-spike](sources/multica-command-gateway-spike.md) - 命令网关调研
- [multica-command-gateway-update-status-spike](sources/multica-command-gateway-update-status-spike.md) - 状态更新调研
- [runtime-governor-report](sources/runtime-governor-report.md) - Runtime治理报告
- [warehouse-engineering-playbook-absorption](sources/warehouse-engineering-playbook-absorption.md) - 数仓工程手册
- [首脑历史沉淀资料来源地图](sources/首脑历史沉淀资料来源地图.md) - handbrain-20260511 来源地图

## Runtime / 运行治理

- [runtime/README](runtime/README.md) - Runtime目录
- [RuntimeOperatingModel](runtime/RuntimeOperatingModel.md) - Runtime运营模式
- [Runtime流程保障总账](runtime/Runtime流程保障总账.md) - Runtime三层闭环保障
- [运行治理总手册](runtime/运行治理总手册.md)
- [任务生命周期治理手册](runtime/任务生命周期治理手册.md)
- [GitHub任务总线与网关手册](runtime/GitHub任务总线与网关手册.md)

## 数仓（Warehouse）

- [warehouse/README](warehouse/README.md) - 数仓目录
- [WarehouseEngineeringPlaybook](warehouse/WarehouseEngineeringPlaybook.md) - 数仓工程手册
- [数仓重构工程手册](warehouse/数仓重构工程手册.md)
- [数仓重构准入门槛](warehouse/数仓重构准入门槛.md)
- [数仓重构总手册](warehouse/数仓重构总手册.md)
- [数据质量治理手册](warehouse/数据质量治理手册.md)
- [调度同步治理手册](warehouse/调度同步治理手册.md)
- [数仓重构验收与回滚手册](warehouse/数仓重构验收与回滚手册.md)
- [数据访问只读安全边界](warehouse/数据访问只读安全边界.md)
- [数仓ETL代码CR技能](warehouse/数仓ETL代码CR技能.md)
- [ADS_SC_XL_13样板链路裁决](warehouse/ADS_SC_XL_13样板链路裁决.md)
- [dbt旁路工具定位](warehouse/dbt旁路工具定位.md)
- [全ADS质量巡检方案](warehouse/全ADS质量巡检方案.md)

## Skills / 技能

- [bigdata-etl-cr](../skills/bigdata-etl-cr/SKILL.md) - 数仓 ETL 代码 CR 技能

## Agent / 首脑协作

- [agent/README](agent/README.md) - Agent目录
- [智能体角色边界](agent/智能体角色边界.md)
- [首脑协同总规范](agent/首脑协同总规范.md)
- [智能体执行与验收规范](agent/智能体执行与验收规范.md)
- [首脑自我改进清单](agent/首脑自我改进清单.md)
- [AgentOS机制吸收裁决](agent/AgentOS机制吸收裁决.md)

## 运维（Operations）

- [operations/README](operations/README.md) - 运维目录
- [Windows资产治理](operations/Windows资产治理.md)
- [Windows数据库MCP访问规范](operations/Windows数据库MCP访问规范.md)
- [SSH隧道替代方案](operations/SSH隧道替代方案.md)
- [SSH隧道合规替代方案](operations/SSH隧道合规替代方案.md)
- [Windows与服务器资产治理手册](operations/Windows与服务器资产治理手册.md)
- [敏感信息与配置治理手册](operations/敏感信息与配置治理手册.md)

## 研究（Research）

- [research/README](research/README.md) - 研究目录
- [LLMWikiArchitecture](research/LLMWikiArchitecture.md) - LLM Wiki架构研究
- [AgentOS方法论吸收](research/AgentOS方法论吸收.md)
- [外部方法论吸收总报告](research/外部方法论吸收总报告.md)
- [Agentic数仓重构研究摘要](research/Agentic数仓重构研究摘要.md)
- [Ruflo研究定位](research/Ruflo研究定位.md)
- [外部框架评估模板](research/外部框架评估模板.md)

## 产出（Outputs）

- [outputs/README](outputs/README.md) - 查询产出目录
- [AI数仓协作架构图与流程](outputs/AI数仓协作架构图与流程.md)
- [当前决策总账](outputs/当前决策总账.md)
- [知识库治理优化报告](outputs/知识库治理优化报告.md)
- [WindowsMCP数据库访问dry-run验证报告](outputs/WindowsMCP数据库访问dry-run验证报告.md)
- [Multica任务管家链路dry-run验证报告](outputs/Multica任务管家链路dry-run验证报告.md)
- [ads_gx_xs_20_03 缺数据根因分析](outputs/ads_gx_xs_20_03_缺数据根因分析.md)
- [ads_gx_xs_20_03 18点验证清单](outputs/ads_gx_xs_20_03_18点验证清单.md)
- [ads_gx_xs_20_03_04_03 研究报告](outputs/ads_gx_xs_20_03_04_03_研究报告.md)
- [ads_gx_xs_牌号合并规则说明](outputs/ads_gx_xs_牌号合并规则说明.md)
- [新Hermes单体首脑接手报告](outputs/新Hermes单体首脑接手报告.md)
- [首脑历史沉淀资料20260511统一分析](outputs/首脑历史沉淀资料20260511统一分析.md)
- [首脑历史沉淀资料全量编译总报告](outputs/首脑历史沉淀资料全量编译总报告.md)
- [六项待裁决事项正式裁决](outputs/六项待裁决事项正式裁决.md)

## 综合（Syntheses）

- [syntheses/README](syntheses/README.md) - 综合目录

## 原始资料（Raw）

- [raw/README](../raw/README.md) - 原始资料目录

## 参考（References）

- [tools](../references/tools.md) - 工具清单
- [workflow](../references/workflow.md) - 工作流规范

---

## 阶段记录

### 第一阶段：完全体初始化与手脑资料吸收

- [首脑历史沉淀资料20260511统一分析](outputs/首脑历史沉淀资料20260511统一分析.md)

### 第二阶段：全量知识编译

- [首脑历史沉淀资料全量编译总报告](outputs/首脑历史沉淀资料全量编译总报告.md)

### 第三阶段：待裁决事项正式裁决

- [六项待裁决事项正式裁决](outputs/六项待裁决事项正式裁决.md)

### 当前治理入口

- [当前主路径](00-当前主路径.md)
- [当前决策总账](outputs/当前决策总账.md)
- [AI数仓协作架构图与流程](outputs/AI数仓协作架构图与流程.md)
