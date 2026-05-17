# UKB-P0-001：全量梳理现有GitHub仓库并生成统一知识库迁移与删除准备清单

## 任务元信息

```yaml
task_id: UKB-P0-001
title: 全量梳理现有GitHub仓库并生成统一知识库迁移与删除准备清单
priority: P0
tenant: unified-knowledge-base
owner: Hermes
reviewer: GPT
status: ready
repo: maxlee0218-lgtm/hermes-unified-knowledge-base
working_dir: 00-knowledge-base-governance/
final_goal: migrate_everything_into_one_repo_then_delete_old_repos
```

## 目标

把当前分散在多个 GitHub 仓库里的有效内容统一迁移到主知识库：

```text
maxlee0218-lgtm/hermes-unified-knowledge-base
```

本任务只做第一步：**全量盘点、迁移设计、冲突识别、删除准备矩阵**。

不要在本任务中批量搬迁文件，也不要删除任何旧仓库。

## 来源仓库

请盘点以下仓库：

```text
maxlee0218-lgtm/warehouse-rebuild
maxlee0218-lgtm/warehouse-engineering-playbook
maxlee0218-lgtm/llm-wiki
maxlee0218-lgtm/obnote
maxlee0218-lgtm/obsidian-vault
maxlee0218-lgtm/openclaw-v2-infra
maxlee0218-lgtm/certificate-system
```

主仓库本身也要盘点：

```text
maxlee0218-lgtm/hermes-unified-knowledge-base
```

## 先读取

```text
00-knowledge-base-governance/UNIFIED_KNOWLEDGE_BASE_PLAN.md
00-knowledge-base-governance/REPOSITORY_DECOMMISSION_PLAN.md
00-knowledge-base-governance/repository_inventory.md
00-knowledge-base-governance/source_to_target_map.csv
```

## 必须输出

请生成或更新以下文件：

```text
00-knowledge-base-governance/repository_inventory_detailed.md
00-knowledge-base-governance/source_to_target_map.csv
00-knowledge-base-governance/migration_batches.md
00-knowledge-base-governance/duplicate_and_conflict_report.md
00-knowledge-base-governance/deprecated_entrypoints.md
00-knowledge-base-governance/delete_readiness_matrix.md
00-knowledge-base-governance/HERMES_TASK_STATUS.md
```

## 输出文件要求

### 1. repository_inventory_detailed.md

必须覆盖每个仓库：

```text
repo_name
visibility
default_branch
main_purpose
important_directories
important_files
estimated_value
migration_priority
recommended_action
risk_notes
```

### 2. source_to_target_map.csv

字段必须包含：

```csv
source_repo,source_path,content_type,current_purpose,target_path,migration_priority,migration_action,status,notes
```

migration_action 可取：

```text
copy_as_archive
copy_and_curate
merge_curated
scan_then_curate
archive_index_only
skip_duplicate
skip_low_value
needs_gpt_decision
needs_user_confirm
```

### 3. migration_batches.md

按批次组织迁移：

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

每个 batch 必须包含：

```text
目标
来源仓库
目标路径
迁移范围
不迁移范围
验收标准
风险
是否需要用户确认
```

### 4. duplicate_and_conflict_report.md

记录：

```text
重复文件
同名不同内容
同一主题多版本
旧入口与新入口冲突
建议保留版本
建议废弃版本
需要GPT判断的问题
```

### 5. deprecated_entrypoints.md

列出旧入口：

```text
旧README入口
旧TASK_INBOX入口
旧项目目录入口
旧看板/任务入口
是否还应使用
替代入口
```

### 6. delete_readiness_matrix.md

每个旧仓库必须有一行结论：

```text
repo_name
migrated: yes/no/partial
migration_receipt_exists: yes/no
open_questions
running_code_or_actions: yes/no/unknown
secrets_or_deployments: yes/no/unknown
can_delete: yes/no/pending
reason
```

当前阶段大多数仓库应为 `pending`，不要过早标记 yes。

### 7. HERMES_TASK_STATUS.md

必须回写：

```text
当前状态：
已扫描仓库：
高价值目录：
建议迁移批次：
重复和冲突：
已生成文件：
需要GPT判断：
需要用户确认：
GitHub分支：
GitHub PR：
下一步：
```

## 执行边界

```text
1. 不删除任何旧仓库。
2. 不批量迁移文件。
3. 不覆盖主知识库已有高价值文件。
4. 不提交敏感信息。
5. 不把低价值重复内容强行迁入。
6. 不把 can_delete 写成 yes，除非证据充分。
```

## 完成方式

推荐新建分支：

```text
hermes/ukb-p0-001-repo-inventory
```

推荐 PR 标题：

```text
[Hermes] UKB-P0-001 repository consolidation inventory
```

PR 描述必须包含：

```text
1. 已扫描仓库列表
2. 生成/更新文件列表
3. 每个仓库迁移建议
4. 重复和冲突摘要
5. delete_readiness_matrix 摘要
6. 需要GPT判断的问题
7. 需要用户确认的问题
```

如果无法创建 PR，可以直接更新 main，但必须在 HERMES_TASK_STATUS.md 中说明。