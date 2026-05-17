# UKB-P0-002：迁移 warehouse-rebuild 到统一知识库

## 任务元信息

```yaml
task_id: UKB-P0-002
title: 迁移 warehouse-rebuild 到统一知识库
priority: P0
tenant: unified-knowledge-base
owner: Hermes
executor: Claude Code preferred, Hermes allowed
reviewer: GPT
status: ready
repo: maxlee0218-lgtm/hermes-unified-knowledge-base
source_repo: maxlee0218-lgtm/warehouse-rebuild
target_root: 02-data-warehouse/projects/
```

## 目标

将 `warehouse-rebuild` 仓库中的有效内容迁移到 `hermes-unified-knowledge-base`，作为旧仓库删除前的第一批迁移试点。

本任务允许迁移文件，但必须保留来源信息，不允许删除旧仓库。

## 来源仓库

```text
maxlee0218-lgtm/warehouse-rebuild
```

## 目标目录建议

```text
02-data-warehouse/projects/warehouse-rebuild/
02-data-warehouse/projects/ads_sc_xl_13/
02-data-warehouse/projects/warehouse-2.0/
05-archives/source-repos/warehouse-rebuild/
05-archives/migration-receipts/
```

## 迁移范围

优先迁移以下目录和文件：

```text
README.md
assessments/
audit/
clarifications/
decision_log/
discovery/
docs/
governance/
handoff/
lineage/
reviews/
roadmap/
scripts/
sql/
warehouse-2.0/
```

## 映射规则

```text
warehouse-rebuild/README.md
  → 02-data-warehouse/projects/warehouse-rebuild/README.md

warehouse-rebuild/lineage/ads_sc_xl_13/
  → 02-data-warehouse/projects/ads_sc_xl_13/lineage/

warehouse-rebuild/sql/
  → 02-data-warehouse/projects/ads_sc_xl_13/sql/

warehouse-rebuild/warehouse-2.0/
  → 02-data-warehouse/projects/warehouse-2.0/

warehouse-rebuild/assessments/
warehouse-rebuild/audit/
warehouse-rebuild/governance/
warehouse-rebuild/handoff/
warehouse-rebuild/reviews/
warehouse-rebuild/roadmap/
warehouse-rebuild/discovery/
warehouse-rebuild/clarifications/
warehouse-rebuild/decision_log/
  → 02-data-warehouse/projects/warehouse-rebuild/{same_dir}/

warehouse-rebuild/scripts/
  → 02-data-warehouse/projects/warehouse-rebuild/scripts/
```

## 关键要求

1. 不要删除旧仓库。
2. 不要覆盖主知识库中更高优先级的新入口。
3. 旧 `warehouse-rebuild/warehouse-2.0/TASK_INBOX.md` 若存在，不作为新入口，只归档。
4. 统一知识库唯一任务入口仍然是：
   `00-knowledge-base-governance/HERMES_TASK_INBOX.md`
5. 迁移时保留来源信息。
6. 如有同名冲突，写入 conflict report，不要强行覆盖。
7. 大批量文件建议由 Mac Claude Code 执行。

## 必须产出

```text
05-archives/migration-receipts/warehouse-rebuild_migration_receipt.md
00-knowledge-base-governance/migration-progress/UKB-P0-002_status.md
00-knowledge-base-governance/HERMES_TASK_STATUS.md
```

如果发现冲突，请更新：

```text
00-knowledge-base-governance/duplicate_and_conflict_report.md
00-knowledge-base-governance/deprecated_entrypoints.md
00-knowledge-base-governance/delete_readiness_matrix.md
```

## migration receipt 必须包含

```text
source_repo:
source_default_branch:
source_last_commit:
migrated_paths:
target_paths:
skipped_paths:
skip_reason:
duplicate_resolution:
verification_result:
can_delete: pending
notes:
```

## 验收标准

1. `warehouse-rebuild` 的高价值内容已迁入统一知识库。
2. ADS_SC_XL_13 资料可在 `02-data-warehouse/projects/ads_sc_xl_13/` 找到。
3. warehouse-2.0 资料可在 `02-data-warehouse/projects/warehouse-2.0/` 找到。
4. 旧任务入口被标记为 deprecated，不再作为活入口。
5. migration receipt 存在。
6. delete readiness 对 warehouse-rebuild 仍为 pending，直到 GPT 审查通过。

## 推荐执行方式

推荐由 Hermes 派给 Mac Claude Code：

```text
branch: claude/UKB-P0-002-migrate-warehouse-rebuild
PR title: [Claude] UKB-P0-002 migrate warehouse-rebuild
```

如果 Hermes 直接执行，也请使用分支和 PR；如直接提交 main，必须在状态文件中说明原因。
