---
task_id: TASK-20260510-002-system-full-picture-inventory
title: "全局系统全貌盘点（硬件/软件/项目/Agent/运行态）"
owner: "用户"
target_agent: "深度研究智能体"
task_type: "KNOWLEDGE"
objective: "输出当前整个 Agent Runtime 系统的全貌，包括硬件、软件、运行中的项目、Agent、任务流、知识库、数据库、服务、网络关系、风险、边界和当前运行状态，为后续统一规划提供基线。"
allowed_actions:
  - 读取 /root/wiki
  - 读取 /root/multica-work/output
  - 检查 GitHub llm-wiki
  - 检查 PocketClaw 配置
  - 检查 Multica 任务状态
  - 检查 Agent 注册情况
  - 检查服务器基础信息
  - 检查 Windows Worker 报告
  - 输出系统盘点报告
  - 更新 LLM Wiki
forbidden_actions:
  - 修改生产数据库
  - 修改 PolarDB
  - 修改 DolphinScheduler
  - 修改 DataX
  - 自动恢复服务
  - 删除任务
  - force push
  - 修改系统配置
  - 安装新软件
acceptance_criteria:
  - 输出完整系统拓扑
  - 输出硬件节点清单
  - 输出软件与服务清单
  - 输出 Agent 与职责映射
  - 输出任务协同链路
  - 输出当前运行中的项目
  - 输出风险与阻断点
  - 输出建议但不执行
output_paths:
  - "/root/multica-work/output/20260510-系统全貌盘点报告.md"
  - "/root/wiki/20-resources/system-runtime-overview.md"
knowledge_update_required: true
timeout_minutes: 45
created_at: "2026-05-10T07:30:00+09:00"
---

# 全局系统全貌盘点

请从“系统架构师 + 运维审计 + Agent Runtime治理”视角，输出当前系统的完整全貌。

必须覆盖：

001 硬件与节点
- 111服务器
- 150服务器
- Windows PC
- PocketClaw 所在节点
- 各节点职责
- CPU/内存/磁盘/网络角色

002 软件与Runtime
- OpenClaw
- Hermes
- Multica
- PocketClaw
- GitHub/Git任务总线
- LLM Wiki
- task_inbox_check.sh
- PocketClaw 定时任务

003 Agent
- 数据专家
- 数仓管家
- 深度研究智能体
- 当前注册状态
- 职责边界
- 当前问题

004 项目与任务
- 当前运行中的项目
- ADS数据质量治理
- 数仓监控大屏迁移
- GitHub任务总线
- 当前 active/review/done 状态

005 数据与系统
- PolarDB
- DolphinScheduler
- DataX
- ODS/DWD/ADS
- Windows沙箱
- 当前连接边界

006 协同链路
ChatGPT → GitHub → PocketClaw → Multica → Agent → REVIEW → DONE → Wiki/GitHub

007 风险与阻断
- 当前最危险风险
- 当前最脆弱链路
- 当前单点故障
- 当前治理缺口

008 当前阶段判断
- 当前属于什么阶段
- 哪些能力已成熟
- 哪些能力仍是实验态
- 下一阶段最应该做什么

禁止扩展自动化范围。
只允许盘点、总结、判断、建议。
