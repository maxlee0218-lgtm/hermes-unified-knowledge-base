---
task_id: TASK-20260510-005-warehouse-rebuild-full-inventory
title: "数仓重构前全量摸排与资料通读"
owner: "用户"
target_agent: "数仓管家"
task_type: "WAREHOUSE"
warehouse: true
objective: "在正式启动数仓重构之前，对当前数仓、调度、同步、ADS链路、历史报告、GitHub/Wiki资料和已沉淀文件进行全量只读摸排，建立重构前基线。"
allowed_actions:
  - 读取 /root/wiki 全部相关文档
  - 读取 /root/multica-work/output 历史报告
  - 读取 GitHub llm-wiki 相关文件
  - 读取 Multica 历史任务状态
  - 读取已沉淀的数仓、数据质量、ADS、DolphinScheduler、DataX相关资料
  - 只读查询元数据与任务配置
  - 汇总问题、风险、链路、文件清单
  - 输出重构前基线报告
  - 更新 LLM Wiki/GitHub
forbidden_actions:
  - 修改生产数据库
  - 修改 PolarDB
  - 修改 DolphinScheduler 生产任务
  - 修改 DataX 生产配置
  - 执行 INSERT/UPDATE/DELETE/DROP/ALTER/TRUNCATE/CREATE
  - 自动上线任务
  - 自动重跑生产调度
  - 自动修复问题
  - 删除文件
  - force push
  - 泄露密码、token、连接串、密钥
acceptance_criteria:
  - 输出完整文件阅读清单
  - 输出当前数仓分层与核心表清单
  - 输出 DolphinScheduler 任务与链路清单
  - 输出 DataX 同步与增量策略清单
  - 输出 ADS_SC_XL_13 已知重构链路现状
  - 输出 ADS_GX_XS 数据质量摸排结论摘要
  - 输出当前风险清单与阻断点
  - 输出重构前不应立即动手的原因和边界
  - 输出第一阶段重构建议，但不执行重构
  - 更新 Wiki/GitHub 并记录 commit id
output_paths:
  - "/root/multica-work/output/20260510-数仓重构前全量摸排基线报告.md"
  - "/root/wiki/20-resources/warehouse-rebuild-pre-inventory.md"
knowledge_update_required: true
timeout_minutes: 60
created_at: "2026-05-10T08:50:00+09:00"
---

# 数仓重构前全量摸排与资料通读任务

## 背景
用户要求：在正式进行数仓重构之前，必须先把所有情况摸排一遍，并把已有文件、报告、知识沉淀全部读一遍。当前任务是重构前基线，不是执行重构。

## 核心目标
建立“重构前全景基线”，回答：

1. 当前数仓到底有什么；
2. 当前链路到底怎么跑；
3. 当前问题到底在哪里；
4. 哪些是已确认事实；
5. 哪些是猜测或待验证；
6. 哪些文件、报告、任务、知识需要作为重构依据；
7. 正式动手前还缺什么。

## 必须阅读/盘点范围

### 001 LLM Wiki / GitHub资料
- `/root/wiki/20-resources/infra-architecture.md`
- `/root/wiki/20-resources/ads-dq-sandbox-results.md`
- `/root/wiki/20-resources/agent-collaboration-runtime.md`
- `/root/wiki/20-resources/system-runtime-overview.md`（如存在）
- `/root/wiki/20-resources/warehouse*` 相关文件
- `/root/wiki/tasks/` 下与数仓、数据质量、ADS、Dolphin、DataX相关任务

### 002 本地历史报告
读取 `/root/multica-work/output/` 下相关报告，至少覆盖：
- ADS数据质量风险治理建议报告
- LEE13/LEE14沙箱验证报告
- 任务闭环与知识沉淀报告
- P1风险表排查计划
- Agent协同机制报告中与任务流有关的部分

### 003 数仓相关对象
只读盘点：
- da_dw
- da_dolphin
- da_datax
- ODS / DWD / ADS 分层
- dw_ods_prd / dw_dwd_prd / dw_ads_prd 表族
- 重点链路：ADS_SC_XL_13
- 重点表：ads_sc_xl_13_defined_manuf_line_name_combined_002 及其上游链路
- 已摸排过的 ads_gx_xs_* 表

### 004 调度与同步
只读盘点：
- DolphinScheduler 任务定义
- DolphinScheduler 调度状态
- DataX job_info / job_log / 增量参数
- 已知 create_time 近30天同步问题
- 物理删除、晚到数据、增量断流风险

### 005 已知业务与技术问题
必须纳入：
- ODS完整性问题
- APS物理删除与DataX同步窗口问题
- 业务规则与系统设计不一致问题
- 辅助表修正统计月份问题
- 宽表 row size too large 风险
- ADS空表/陈旧表问题
- Dolphin release_state=0导致调度不触发问题
- 表建好但未配置ETL调度问题

## 输出报告结构

报告标题：
《数仓重构前全量摸排基线报告》

必须包含：

001 摸排范围与已读文件清单
- 文件路径
- 文件类型
- 是否已读
- 关键结论

002 当前数仓全貌
- 数据库/Schema
- 分层
- 表族数量
- 核心链路
- 当前可信源

003 当前调度全貌
- DolphinScheduler 任务族
- 重点任务
- release_state 风险
- 失败/停用任务

004 当前同步全貌
- DataX同步策略
- 增量字段
- 已知漏洞
- 物理删除与晚到数据风险

005 当前重点链路
- ADS_SC_XL_13链路
- ads_sc_xl_13_defined_manuf_line_name_combined_002链路
- ads_gx_xs_* 数据质量链路

006 已确认问题清单
按 P0/P1/P2 分级。

007 重构前风险边界
- 哪些不能直接改
- 哪些必须只读摸排
- 哪些必须先做沙箱
- 哪些需要业务确认

008 第一阶段重构建议
只提出建议，不执行。
必须给出：
- 最短路径
- 最小闭环
- 第一批适合重构/验证的对象
- 不建议立即做的事情

009 待确认问题
列出必须由用户/业务/运维确认的问题。

## 严格边界
本任务只做只读摸排、通读文件、总结、建议。
不允许执行任何生产修改、不允许修复、不允许上线、不允许重跑生产调度。

## 验收标准
报告必须能让用户和 ChatGPT 在不额外翻历史聊天的情况下，理解当前数仓重构前的全貌，并决定下一步是否进入第一阶段重构设计。
