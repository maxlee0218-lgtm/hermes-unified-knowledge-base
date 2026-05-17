# 统一知识库整理总方案

## 1. 总目标

将当前分散在多个 GitHub 仓库中的资料、项目文档、工程经验、审计记录、Agent协作记录、数仓重构资料、基础设施笔记和个人知识库，统一整理到一个主知识库仓库中。

主知识库仓库：

```text
maxlee0218-lgtm/hermes-unified-knowledge-base
```

后续所有新资料、项目沉淀、任务入口、知识归档，原则上都进入该仓库。

## 2. 来源仓库

当前需要统一梳理的来源仓库：

```text
maxlee0218-lgtm/hermes-unified-knowledge-base
maxlee0218-lgtm/warehouse-rebuild
maxlee0218-lgtm/warehouse-engineering-playbook
maxlee0218-lgtm/llm-wiki
maxlee0218-lgtm/obnote
maxlee0218-lgtm/obsidian-vault
maxlee0218-lgtm/openclaw-v2-infra
maxlee0218-lgtm/certificate-system
```

## 3. 整理原则

```text
1. hermes-unified-knowledge-base 是唯一主知识库。
2. 其他仓库作为来源仓库，不再作为日常知识入口。
3. 不直接删除旧仓库。
4. 先做索引，再迁移，再整理，再标记旧入口状态。
5. 每个迁移文件必须保留来源仓库、来源路径、来源用途。
6. 同类内容统一归入同一知识域。
7. 项目执行资料和沉淀知识分开管理。
8. Hermes 后续只读统一任务入口，不再从多个仓库找任务。
```

## 4. 统一知识域设计

```text
00-knowledge-base-governance/   知识库治理、目录规范、迁移清单、入口说明
01-ai-agent-systems/            AI Agent、Hermes、MCP、代码Agent、协作协议
02-data-warehouse/              数仓重构、DataX、Dolphin、SQL、数据质量、元数据治理
03-infrastructure/              基础设施、部署、运维、监控、连接器
04-business-domains/            业务口径、数据字典、业务规则、报表口径
05-project-archives/            历史项目归档，按项目沉淀证据和交付物
06-engineering-playbooks/       工程手册、最佳实践、模板、Runbook
07-personal-knowledge/          个人知识、学习笔记、Obsidian内容整理
08-reference/                   外部参考、资料索引、引用说明
```

## 5. 项目资料归档规则

数仓重构项目统一归入：

```text
02-data-warehouse/projects/warehouse-2.0/
```

历史 ADS_SC_XL_13 重构资料归入：

```text
02-data-warehouse/projects/ads_sc_xl_13/
```

DataX / Dolphin 经验归入：

```text
02-data-warehouse/tooling/datax-dolphin/
```

质量、对账、元数据规范归入：

```text
02-data-warehouse/governance/
```

Hermes / Kanban / MCP 协作归入：

```text
01-ai-agent-systems/hermes/
```

## 6. 迁移阶段

### 阶段A：全仓库盘点

输出：

```text
00-knowledge-base-governance/repository_inventory.md
00-knowledge-base-governance/source_to_target_map.csv
```

### 阶段B：建立统一入口

输出：

```text
00-knowledge-base-governance/MAIN_ENTRY.md
00-knowledge-base-governance/HERMES_TASK_INBOX.md
00-knowledge-base-governance/HERMES_TASK_STATUS.md
```

### 阶段C：迁移高价值内容

优先迁移：

```text
1. 数仓重构资料
2. DataX / Dolphin 集成资料
3. Hermes Agent / Kanban / MCP 协作资料
4. 工程实践手册
5. 业务口径和数据字典模板
```

### 阶段D：建立旧仓库索引

每个旧仓库都要形成一个索引页：

```text
00-knowledge-base-governance/source-repos/{repo_name}.md
```

### 阶段E：设置后续写入规则

后续所有新知识、项目沉淀、任务入口，默认进入本仓库。

## 7. Hermes 执行方式

Hermes 后续只需要读取：

```text
00-knowledge-base-governance/HERMES_TASK_INBOX.md
```

并将状态写回：

```text
00-knowledge-base-governance/HERMES_TASK_STATUS.md
```

GPT 作为统一任务入口，负责更新 HERMES_TASK_INBOX。