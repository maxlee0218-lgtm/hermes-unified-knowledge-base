# UKB-P0-002 Hermes-only 覆盖指令

## 结论

UKB-P0-002 由 Hermes 自己执行。

```yaml
task_id: UKB-P0-002
executor: Hermes only
claude_code: disabled
windows_agent: disabled
status: retry_required
reason: actual_source_files_not_migrated
```

## 覆盖范围

本文件覆盖以下旧描述：

```text
Claude Code preferred
Hermes 派给 Mac Claude Code
```

从本文件生效后，UKB-P0-002 不再派给 Claude Code。

## 当前问题

上一轮提交只生成了 migration receipts 和 manifest，实际仓库文件没有迁移到：

```text
05-archives/source-repos/
```

因此任务未通过 GPT 审查，必须由 Hermes 重试真实文件迁移。

## Hermes 必须执行

Hermes 需要自己完成：

```text
1. clone 主知识库
2. clone 7 个来源仓库
3. 创建分支 hermes/UKB-P0-002-raw-archive-all-repos
4. 将旧仓库实际文件复制到 05-archives/source-repos/{repo_name}/
5. 排除 .git、缓存、虚拟环境、二进制缓存、敏感文件
6. 生成或更新 migration_receipt
7. 生成 overall_migration_manifest.csv
8. 更新 HERMES_TASK_STATUS.md
9. 推分支并创建 PR
```

## 来源仓库

```text
warehouse-rebuild
warehouse-engineering-playbook
llm-wiki
obnote
obsidian-vault
openclaw-v2-infra
certificate-system
```

## 目标目录

```text
05-archives/source-repos/warehouse-rebuild/
05-archives/source-repos/warehouse-engineering-playbook/
05-archives/source-repos/llm-wiki/
05-archives/source-repos/obnote/
05-archives/source-repos/obsidian-vault/
05-archives/source-repos/openclaw-v2-infra/
05-archives/source-repos/certificate-system/
```

## 验收硬条件

```text
1. 上述 7 个目录必须存在。
2. 目录中必须有真实迁移文件，不允许只有 receipt。
3. 每个仓库必须有 migration_receipt。
4. delete_readiness_matrix 仍然保持 pending。
5. 旧仓库不删除。
6. 如果网络失败，任务状态必须是 blocked，不允许 completed。
```

## 建议分支与 PR

```text
branch: hermes/UKB-P0-002-raw-archive-all-repos
PR title: [Hermes] UKB-P0-002 raw archive all source repos
```

## 禁止事项

```text
1. 不派给 Claude Code。
2. 不启用 Windows Agent。
3. 不做二次整理。
4. 不去重。
5. 不重命名。
6. 不删除旧仓库。
7. 不把 receipt-only 标记为完成。
```
