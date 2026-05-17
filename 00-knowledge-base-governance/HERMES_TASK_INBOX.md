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
task_spec: 00-knowledge-base-governance/tasks/UKB-P0-001_repo_consolidation_inventory.md
final_goal: migrate_everything_into_one_repo_then_delete_old_repos
```

## Hermes 执行方式

请直接读取任务规格文件：

```text
00-knowledge-base-governance/tasks/UKB-P0-001_repo_consolidation_inventory.md
```

该文件是本轮任务的完整执行说明。

## 本轮目标

对当前所有相关 GitHub 仓库做全面盘点，输出可执行的统一知识库迁移清单，并为后续删除旧仓库做准备。

主知识库：

```text
maxlee0218-lgtm/hermes-unified-knowledge-base
```

## 先读文件

```text
00-knowledge-base-governance/UNIFIED_KNOWLEDGE_BASE_PLAN.md
00-knowledge-base-governance/REPOSITORY_DECOMMISSION_PLAN.md
00-knowledge-base-governance/repository_inventory.md
00-knowledge-base-governance/source_to_target_map.csv
00-knowledge-base-governance/tasks/UKB-P0-001_repo_consolidation_inventory.md
```

## 本轮必须产出

```text
00-knowledge-base-governance/repository_inventory_detailed.md
00-knowledge-base-governance/source_to_target_map.csv
00-knowledge-base-governance/migration_batches.md
00-knowledge-base-governance/duplicate_and_conflict_report.md
00-knowledge-base-governance/deprecated_entrypoints.md
00-knowledge-base-governance/delete_readiness_matrix.md
00-knowledge-base-governance/HERMES_TASK_STATUS.md
```

## 完成后回写

请更新：

```text
00-knowledge-base-governance/HERMES_TASK_STATUS.md
```

并提交 PR 或直接更新本仓库。

## 下一轮任务

GPT 审查本轮产物后，会更新本文件的 active_task。Hermes 后续只需要继续轮询本文件。