# Hermes 全局任务入口

> 以后 Hermes 领取任务优先读取本文件。本文件是统一知识库整理项目的总入口。

## 当前 active_task

```yaml
active_task_id: UKB-P0-001
title: 全量梳理现有GitHub仓库并生成统一知识库迁移与删除准备清单
status: active
priority: P0
tenant: unified-knowledge-base
repo: maxlee0218-lgtm/hermes-unified-knowledge-base
working_dir: 00-knowledge-base-governance/
owner: Hermes
reviewer: GPT
final_goal: migrate_everything_into_one_repo_then_delete_old_repos
```

## 本轮目标

对当前所有相关 GitHub 仓库做全面盘点，输出可执行的统一知识库迁移清单，并为后续删除旧仓库做准备。

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
00-knowledge-base-governance/REPOSITORY_DECOMMISSION_PLAN.md
```

## 本轮必须产出

请生成或更新：

```text
00-knowledge-base-governance/repository_inventory_detailed.md
00-knowledge-base-governance/source_to_target_map.csv
00-knowledge-base-governance/migration_batches.md
00-knowledge-base-governance/duplicate_and_conflict_report.md
00-knowledge-base-governance/deprecated_entrypoints.md
00-knowledge-base-governance/delete_readiness_matrix.md
00-knowledge-base-governance/HERMES_TASK_STATUS.md
```

## 执行要求

```text
1. 先盘点，不要立刻删除旧仓库。
2. 旧仓库最终目标是删除，但必须先迁移、校验、生成 receipt。
3. 每个待迁移目录必须给出 source_repo、source_path、target_path、priority、action。
4. 每个仓库必须判断 can_delete: yes/no/pending。
5. 同名或重复内容必须写入 duplicate_and_conflict_report.md。
6. 数仓重构、Dolphin/DataX、Hermes Agent 协作资料优先级最高。
7. 迁移动作要分批，不能一次性混搬。
8. 输出完成后提交 PR 或直接更新本仓库。
```

## 推荐迁移批次

```text
Batch 1：warehouse-rebuild 全量迁移
Batch 2：warehouse-engineering-playbook 全量迁移
Batch 3：llm-wiki 中 AI Agent / Hermes / MCP 相关内容迁移
Batch 4：obnote / obsidian-vault 有效内容迁移
Batch 5：openclaw-v2-infra 有效内容迁移
Batch 6：certificate-system 文档归档或确认是否保留代码
Batch 7：生成每个旧仓库的 migration_receipt 和 delete_readiness_matrix
Batch 8：用户确认后删除旧仓库
```

## 删除前置条件

```text
1. 有效内容已迁入 hermes-unified-knowledge-base。
2. 迁移后能在新目录找到。
3. 重复和冲突已处理。
4. 每个来源仓库都有 migration_receipt。
5. delete_readiness_matrix 标记 can_delete=yes。
6. 用户最终确认。
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
每个仓库的 can_delete 判断
需要GPT判断的问题
需要用户确认的问题
下一步建议
```