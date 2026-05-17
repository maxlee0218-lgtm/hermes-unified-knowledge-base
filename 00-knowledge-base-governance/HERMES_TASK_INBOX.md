# Hermes 全局任务入口

> Hermes 领取任务优先读取本文件。本文件是统一知识库整理项目的总入口。

## 当前 active_task

```yaml
active_task_id: UKB-P0-002
title: 原样整合所有旧仓库到统一知识库 raw archive
status: active
priority: P0
tenant: unified-knowledge-base
repo: maxlee0218-lgtm/hermes-unified-knowledge-base
working_dir: 00-knowledge-base-governance/
owner: GPT
scheduler: Hermes
executor: Claude Code preferred
reviewer: GPT
task_spec: 00-knowledge-base-governance/tasks/UKB-P0-002_raw_archive_all_repos.md
strategy: consolidate_first_curate_later
windows_agent: disabled
final_goal: migrate_everything_into_one_repo_then_delete_old_repos
```

## Hermes 执行方式

请直接读取任务规格文件：

```text
00-knowledge-base-governance/tasks/UKB-P0-002_raw_archive_all_repos.md
```

该文件是本轮任务的完整执行说明。

## 上一轮审查

UKB-P0-001 已由 GPT 审查通过，审查文件：

```text
00-knowledge-base-governance/reviews/UKB-P0-001_GPT_REVIEW.md
```

## 本轮目标

先把所有旧仓库的有效内容原样整合到统一知识库，不做精细整理、不做去重、不做重命名。

统一归档目录：

```text
05-archives/source-repos/
```

来源仓库：

```text
warehouse-rebuild
warehouse-engineering-playbook
llm-wiki
obnote
obsidian-vault
openclaw-v2-infra
certificate-system
```

## 本轮必须产出

```text
05-archives/migration-receipts/warehouse-rebuild_migration_receipt.md
05-archives/migration-receipts/warehouse-engineering-playbook_migration_receipt.md
05-archives/migration-receipts/llm-wiki_migration_receipt.md
05-archives/migration-receipts/obnote_migration_receipt.md
05-archives/migration-receipts/obsidian-vault_migration_receipt.md
05-archives/migration-receipts/openclaw-v2-infra_migration_receipt.md
05-archives/migration-receipts/certificate-system_migration_receipt.md
05-archives/migration-receipts/overall_migration_manifest.csv
00-knowledge-base-governance/migration-progress/UKB-P0-002_status.md
00-knowledge-base-governance/HERMES_TASK_STATUS.md
```

## 推荐执行方式

推荐 Hermes 派给 Mac Claude Code 执行：

```text
branch: claude/UKB-P0-002-raw-archive-all-repos
PR title: [Claude] UKB-P0-002 raw archive all source repos
```

Claude Code 只负责机械迁移和生成凭证，不负责二次整理和分类。

## 下一轮任务

GPT 审查本轮产物后，会更新本文件的 active_task。Hermes 后续只需要继续轮询本文件。