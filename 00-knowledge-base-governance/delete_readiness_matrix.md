# 删除准备矩阵

> 任务ID: UKB-P0-001
> 生成时间: 2026-05-17

---

## 删除前检查清单

| 仓库 | 代码保留 | 文档迁移 | Secrets检查 | Actions检查 | Pages检查 | 可删除 |
|------|----------|----------|-------------|-------------|-----------|--------|
| warehouse-rebuild | N/A | 🟡 待迁移 | 🟢 无 | 🟢 无 | 🟢 无 | 🟡 迁移后 |
| warehouse-engineering-playbook | N/A | 🟡 待迁移 | 🟢 无 | 🟢 无 | 🟢 无 | 🟡 迁移后 |
| llm-wiki | N/A | 🟡 待迁移 | 🟢 无 | 🟢 无 | 🟢 无 | 🟡 迁移后 |
| obnote | N/A | 🟡 待迁移 | 🟢 无 | 🟢 无 | 🟢 无 | 🟡 迁移后 |
| obsidian-vault | N/A | 🟡 待迁移 | 🟢 无 | 🟢 无 | 🟢 无 | 🟡 迁移后 |
| openclaw-v2-infra | N/A | 🟡 待迁移 | 🟢 无 | 🟢 无 | 🟢 无 | 🟡 迁移后 |
| certificate-system | 🟡 待确认 | 🟡 待迁移 | 🟢 无 | 🟢 无 | 🟢 无 | 🔴 需确认 |

## 删除条件

```text
1. 统一知识库中可找到全部有效内容
2. 旧仓库没有仍在使用的代码、部署、Secrets、Pages、Actions
3. GitHub Issues、Discussions、Wiki 已处理或迁移
4. 其他项目没有引用旧仓库的链接
5. 用户明确确认可以删除
```

## 删除流程

```text
Step 1: 完成所有迁移批次
Step 2: 生成 migration_receipt 并验证
Step 3: 用户确认删除
Step 4: 备份仓库（可选）
Step 5: 删除仓库
Step 6: 更新统一知识库中的入口说明
```

## 风险提醒

```text
- certificate-system 包含Python代码，可能仍在使用
- 删除后无法恢复（GitHub不提供恢复）
- 建议先Archive（归档）再删除，保留只读访问
```
