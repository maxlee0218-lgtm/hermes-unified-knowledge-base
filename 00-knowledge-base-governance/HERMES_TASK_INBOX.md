# Hermes 全局任务入口

> Hermes 领取任务优先读取本文件。本文件是统一知识库整理项目的总入口。

## 当前 active_task

```yaml
active_task_id: UKB-P0-002
title: 迁移 warehouse-rebuild 到统一知识库
status: active
priority: P0
tenant: unified-knowledge-base
repo: maxlee0218-lgtm/hermes-unified-knowledge-base
working_dir: 00-knowledge-base-governance/
owner: Hermes
executor: Claude Code preferred, Hermes allowed
reviewer: GPT
task_spec: 00-knowledge-base-governance/tasks/UKB-P0-002_migrate_warehouse_rebuild.md
source_repo: maxlee0218-lgtm/warehouse-rebuild
final_goal: migrate_everything_into_one_repo_then_delete_old_repos
```

## Hermes 执行方式

请直接读取任务规格文件：

```text
00-knowledge-base-governance/tasks/UKB-P0-002_migrate_warehouse_rebuild.md
```

该文件是本轮任务的完整执行说明。

## 上一轮审查

UKB-P0-001 已由 GPT 审查通过，审查文件：

```text
00-knowledge-base-governance/reviews/UKB-P0-001_GPT_REVIEW.md
```

## 本轮目标

将 `warehouse-rebuild` 仓库中的有效内容迁移到 `hermes-unified-knowledge-base`，作为旧仓库删除前的第一批迁移试点。

## 本轮必须产出

```text
05-archives/migration-receipts/warehouse-rebuild_migration_receipt.md
00-knowledge-base-governance/migration-progress/UKB-P0-002_status.md
00-knowledge-base-governance/HERMES_TASK_STATUS.md
```

如发现冲突，请更新：

```text
00-knowledge-base-governance/duplicate_and_conflict_report.md
00-knowledge-base-governance/deprecated_entrypoints.md
00-knowledge-base-governance/delete_readiness_matrix.md
```

## 推荐执行方式

推荐 Hermes 派给 Mac Claude Code 执行：

```text
branch: claude/UKB-P0-002-migrate-warehouse-rebuild
PR title: [Claude] UKB-P0-002 migrate warehouse-rebuild
```

如果 Hermes 直接执行，也请优先使用分支和 PR。

## 下一轮任务

GPT 审查本轮产物后，会更新本文件的 active_task。Hermes 后续只需要继续轮询本文件。