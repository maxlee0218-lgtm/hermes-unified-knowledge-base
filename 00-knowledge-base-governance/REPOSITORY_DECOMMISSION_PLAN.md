# 旧仓库下线与删除计划

## 1. 最终目标

将所有历史分散仓库的有效内容统一迁移到：

```text
maxlee0218-lgtm/hermes-unified-knowledge-base
```

迁移完成并验收后，旧仓库可以删除。

## 2. 待下线仓库

| 仓库 | 处理目标 | 删除前要求 |
|---|---|---|
| maxlee0218-lgtm/warehouse-rebuild | 全量迁移到统一知识库 | 数仓重构资料、SQL、lineage、handoff全部迁移并校验 |
| maxlee0218-lgtm/warehouse-engineering-playbook | 全量迁移到统一知识库 | 工程手册、DataX/Dolphin、质量、对账资料全部迁移 |
| maxlee0218-lgtm/llm-wiki | 有效内容迁移到统一知识库 | AI/Agent相关资料迁移，低价值重复内容可不迁 |
| maxlee0218-lgtm/obnote | 有效内容迁移到统一知识库 | 基础设施和数据工程笔记迁移 |
| maxlee0218-lgtm/obsidian-vault | 有效内容迁移到统一知识库 | 模板、业务口径、个人知识迁移 |
| maxlee0218-lgtm/openclaw-v2-infra | 有效内容迁移到统一知识库 | 连接器、基础设施经验迁移 |
| maxlee0218-lgtm/certificate-system | 归档迁移或低优先级处理 | 如仍需保留代码，则不要删除；如只需知识沉淀，则迁移文档后删除 |

## 3. 删除前四步

### Step 1：全量盘点

输出：

```text
00-knowledge-base-governance/repository_inventory_detailed.md
00-knowledge-base-governance/source_to_target_map.csv
```

### Step 2：迁移内容

按批次迁移：

```text
Batch 1：warehouse-rebuild
Batch 2：warehouse-engineering-playbook
Batch 3：llm-wiki / Agent资料
Batch 4：obnote / obsidian-vault
Batch 5：openclaw-v2-infra
Batch 6：certificate-system
```

### Step 3：校验迁移完整性

每个仓库生成：

```text
00-knowledge-base-governance/decommission/{repo_name}_migration_receipt.md
```

必须包含：

```text
source_repo
source_default_branch
source_last_commit
migrated_paths
target_paths
skipped_paths
skip_reason
duplicate_resolution
verification_result
can_delete: yes/no
```

### Step 4：冻结与删除

删除前先确认：

```text
1. 统一知识库中可找到全部有效内容。
2. 旧仓库没有仍在使用的代码、部署、Secrets、Pages、Actions。
3. GitHub Issues / PR 中重要内容已经归档。
4. 用户确认 can_delete=yes。
```

## 4. 删除原则

```text
不迁移，不删除。
不校验，不删除。
不确认，不删除。
仍承载运行代码，不删除。
只承载历史资料，迁移后可删除。
```

## 5. 删除执行方式

当前 GPT 工具不直接执行仓库删除。

最终删除建议由用户在 GitHub 页面执行：

```text
Repo Settings → Danger Zone → Delete this repository
```

删除前请保留本文件和对应 migration_receipt。