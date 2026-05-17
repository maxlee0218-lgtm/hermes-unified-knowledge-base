# Hermes 全局任务入口

> 以后 Hermes 领取任务优先读取本文件。本文件是统一知识库整理项目的总入口。

## 当前 active_task

```yaml
active_task_id: UKB-P0-001
title: 全量梳理现有GitHub仓库并生成统一知识库迁移清单
status: active
priority: P0
tenant: unified-knowledge-base
repo: maxlee0218-lgtm/hermes-unified-knowledge-base
working_dir: 00-knowledge-base-governance/
owner: Hermes
reviewer: GPT
```

## 本轮目标

对当前所有相关 GitHub 仓库做全面盘点，输出可执行的统一知识库迁移清单。

主知识库：

```text
maxlee0218-lgtm/hermes-unified-knowledge-base
```

来源仓库：

```text
maxlee0218-lgtm/warehouse-rebuild
maxlee0218-lgtm/warehouse-engineering-playbook
maxlee0218-lgtm/llm-wiki
maxlee0218-lgtm/obnote
maxlee0218-lgtm/obsidian-vault
maxlee0218-lgtm/openclaw-v2-infra
maxlee0218-lgtm/certificate-system
```

## 先读文件

```text
00-knowledge-base-governance/UNIFIED_KNOWLEDGE_BASE_PLAN.md
00-knowledge-base-governance/repository_inventory.md
00-knowledge-base-governance/source_to_target_map.csv
```

## 本轮必须产出

请生成或更新：

```text
00-knowledge-base-governance/repository_inventory_detailed.md
00-knowledge-base-governance/source_to_target_map.csv
00-knowledge-base-governance/migration_batches.md
00-knowledge-base-governance/duplicate_and_conflict_report.md
00-knowledge-base-governance/deprecated_entrypoints.md
00-knowledge-base-governance/HERMES_TASK_STATUS.md
```

## 执行要求

```text
1. 先盘点，不要批量搬迁。
2. 不要删除任何旧仓库内容。
3. 每个待迁移目录必须给出 source_repo、source_path、target_path、priority、action。
4. 同名或重复内容必须写入 duplicate_and_conflict_report.md。
5. 数仓重构、Dolphin/DataX、Hermes Agent 协作资料优先级最高。
6. 迁移动作要分批，不能一次性混搬。
7. 输出完成后提交 PR 或直接更新本仓库。
```

## 推荐迁移批次

```text
Batch 1：数仓重构与 warehouse-2.0 资料
Batch 2：DataX / Dolphin / 质量 / 对账工程手册
Batch 3：Hermes Agent / Kanban / MCP 协作资料
Batch 4：基础设施与连接器资料
Batch 5：个人知识库、模板、业务口径资料
Batch 6：弱相关项目归档
```

## 完成后回写

请更新：

```text
00-knowledge-base-governance/HERMES_TASK_STATUS.md
```

状态必须包含：

```text
完成了哪些仓库扫描
每个仓库的高价值目录
建议迁移批次
冲突和重复项
需要GPT判断的问题
需要用户确认的问题
下一步建议
```