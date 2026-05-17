# Repository Inventory

## 主知识库

| 仓库 | 角色 | 处理策略 |
|---|---|---|
| maxlee0218-lgtm/hermes-unified-knowledge-base | 主知识库 | 作为唯一长期知识入口 |

## 来源仓库

| 仓库 | 当前内容判断 | 目标归档位置 | 优先级 |
|---|---|---|---|
| maxlee0218-lgtm/warehouse-rebuild | 数仓重构项目、ADS_SC_XL_13、warehouse-2.0初始资料 | 02-data-warehouse/projects/ | P0 |
| maxlee0218-lgtm/warehouse-engineering-playbook | 数仓工程实践、DataX/Dolphin、质量、对账经验 | 06-engineering-playbooks/warehouse/ 与 02-data-warehouse/tooling/ | P0 |
| maxlee0218-lgtm/llm-wiki | LLM、Agent、AI工程知识 | 01-ai-agent-systems/ | P1 |
| maxlee0218-lgtm/obnote | 基础设施、运维、数据工程笔记 | 03-infrastructure/ 与 02-data-warehouse/ | P1 |
| maxlee0218-lgtm/obsidian-vault | 个人知识、业务笔记、模板 | 07-personal-knowledge/ 与 04-business-domains/ | P1 |
| maxlee0218-lgtm/openclaw-v2-infra | OpenClaw基础设施、连接器、执行器经验 | 03-infrastructure/openclaw/ | P2 |
| maxlee0218-lgtm/certificate-system | 证书系统项目 | 05-project-archives/certificate-system/ | P3 |

## 第一轮迁移重点

```text
1. warehouse-rebuild 中的数仓重构核心资料
2. warehouse-engineering-playbook 中的 DataX / Dolphin / 质量 / 对账资料
3. Hermes Kanban / MCP / Agent 协作资料
4. 当前数仓2.0任务入口
```

## 状态

```text
inventory_created_by: GPT
status: pending_hermes_scan
next_action: Hermes 扫描来源仓库并生成 source_to_target_map.csv
```