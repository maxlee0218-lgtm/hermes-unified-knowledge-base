# UKB-P0-002：原样整合所有旧仓库到统一知识库

## 任务元信息

```yaml
task_id: UKB-P0-002
title: 原样整合所有旧仓库到统一知识库 raw archive
priority: P0
owner: GPT
scheduler: Hermes
executor: Claude Code preferred
target_repo: maxlee0218-lgtm/hermes-unified-knowledge-base
status: ready
strategy: consolidate_first_curate_later
windows_agent: disabled
```

## 目标

先把所有旧仓库的有效内容原样整合到统一知识库，不做精细整理、不做去重、不做重命名。

本阶段只解决一个问题：

```text
所有旧知识资产必须先集中到一个主仓库，并且保留来源可追溯。
```

统一主仓库：

```text
maxlee0218-lgtm/hermes-unified-knowledge-base
```

## 来源仓库

```text
maxlee0218-lgtm/warehouse-rebuild
maxlee0218-lgtm/warehouse-engineering-playbook
maxlee0218-lgtm/llm-wiki
maxlee0218-lgtm/obnote
maxlee0218-lgtm/obsidian-vault
maxlee0218-lgtm/openclaw-v2-infra
maxlee0218-lgtm/certificate-system
```

## 目标归档目录

```text
05-archives/source-repos/
  warehouse-rebuild/
  warehouse-engineering-playbook/
  llm-wiki/
  obnote/
  obsidian-vault/
  openclaw-v2-infra/
  certificate-system/
```

## 迁移原则

```text
1. 保留旧仓库原始目录结构。
2. 不重写内容。
3. 不合并重复文件。
4. 不删除旧仓库。
5. 不删除主知识库已有文件。
6. 不上传敏感文件、token、密钥、环境配置。
7. 不迁移 .git/、node_modules/、venv/、__pycache__/、大二进制缓存。
8. 如果存在敏感疑似文件，写入 skipped_paths，不迁移。
```

## 必须生成

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

## receipt 格式

每个 migration_receipt 必须包含：

```text
source_repo:
source_default_branch:
source_last_commit:
source_size:
target_path:
migrated_paths:
skipped_paths:
skip_reason:
sensitive_files_excluded:
verification_method:
verification_result:
can_delete: pending
notes:
```

## overall_migration_manifest.csv 字段

```csv
source_repo,source_path,target_path,item_type,migration_status,skip_reason,source_commit,notes
```

## 验收标准

```text
1. 7个来源仓库都在 05-archives/source-repos/ 下有对应目录。
2. 每个仓库都有 migration_receipt。
3. overall_migration_manifest.csv 存在。
4. delete_readiness_matrix 不允许标记 can_delete=yes，只能 pending。
5. 旧仓库不删除。
6. 提交 PR 等待 GPT 审查。
```

## 推荐执行方式

由 Hermes 派给 Mac Claude Code 执行：

```text
branch: claude/UKB-P0-002-raw-archive-all-repos
PR title: [Claude] UKB-P0-002 raw archive all source repos
```

Claude Code 只负责机械迁移和生成凭证，不负责二次整理和分类。

## GPT 审查重点

```text
1. 是否完整覆盖7个来源仓库。
2. 是否保留来源可追溯信息。
3. 是否排除了明显敏感文件。
4. 是否没有破坏主知识库入口。
5. 是否没有把旧入口误标为新入口。
```

## 后续任务

本任务通过后，再进入：

```text
UKB-P0-003：建立 START_HERE.md 和 00-control-center
UKB-P0-004：整理 skills registry
UKB-P0-005：整理数据开发 runbooks
UKB-P0-006：按知识域二次整理 raw archive
```