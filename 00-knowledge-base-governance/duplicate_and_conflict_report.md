# 重复与冲突报告

> 任务ID: UKB-P0-001
> 生成时间: 2026-05-17

---

## 已知重复/冲突

| 类型 | 描述 | 影响 | 建议 |
|------|------|------|------|
| 路径冲突 | warehouse-rebuild/warehouse-2.0/ 与 统一知识库/02-data-warehouse/projects/warehouse-2.0/ | 任务入口重复 | 合并时保留统一知识库版本，备份旧版本 |
| 命名冲突 | TASK_INBOX.md 可能在多个仓库存在 | 任务入口混乱 | 统一使用 HERMES_TASK_INBOX.md |
| 内容重复 | llm-wiki/04-warehouse-projects/ 与 warehouse-rebuild/ 可能重复 | 存储浪费 | 迁移时去重，保留最新版本 |
| 目录重叠 | warehouse-engineering-playbook/docs/ 与 统一知识库/06-engineering-playbooks/ 可能重叠 | 文档分散 | 合并并标记来源 |

## 潜在冲突（待迁移时确认）

```text
1. warehouse-rebuild 和 llm-wiki/04-warehouse-projects/ 是否有重复数仓资料?
2. warehouse-engineering-playbook 和 统一知识库/02-data-warehouse/tooling/ 是否有重复?
3. obsidian-vault/业务口径/ 和 统一知识库/04-business-domains/ 是否有重复?
4. obnote/entities/ 和 统一知识库/04-business-domains/ 是否有重复?
```

## 冲突解决原则

```text
1. 统一知识库版本优先
2. 保留来源仓库链接作为回溯
3. 重复内容标记并合并
4. 冲突由GPT审查后决策
5. 所有合并操作保留git history
```
