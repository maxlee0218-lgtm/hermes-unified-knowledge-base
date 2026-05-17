# 迁移批次计划

> 任务ID: UKB-P0-001
> 生成时间: 2026-05-17

---

## 批次概览

| 批次 | 仓库 | 状态 | 优先级 | 大小 |
|------|------|------|--------|------|
| Batch 1 | warehouse-rebuild | 🟢 可执行 | P0 | 1627KB |
| Batch 2 | warehouse-engineering-playbook | 🟢 可执行 | P0 | 32KB |
| Batch 3 | llm-wiki | 🟢 可执行 | P1 | 3457KB |
| Batch 4 | obnote + obsidian-vault | 🟢 可执行 | P1 | 251KB |
| Batch 5 | openclaw-v2-infra | 🟢 可执行 | P2 | 199KB |
| Batch 6 | certificate-system | 🟡 待确认 | P3 | 1105KB |
| Batch 7 | 生成迁移收据和删除准备矩阵 | 🟢 可执行 | P0 | - |
| Batch 8 | 用户确认后删除旧仓库 | ⚪ 未开始 | P0 | - |

## 详细批次说明

### Batch 1: warehouse-rebuild (1627KB)

```yaml
status: ready
priority: P0
content:
  - README.md (项目入口)
  - lineage/ (ADS_SC_XL_13血缘证据)
  - sql/ (SQL资产)
  - warehouse-2.0/ (warehouse 2.0初始资料)
  - assessments/ (评估文档)
  - audit/ (审计文档)
  - governance/ (治理文档)
  - discovery/ (发现文档)
  - handoff/ (交接文档)
  - reviews/ (审查文档)
  - roadmap/ (路线图)
  - scripts/ (脚本)
  - clarifications/ (澄清文档)
  - decision_log/ (决策日志)
target_path: 02-data-warehouse/projects/
action: 按目录映射迁移，合并到统一知识库
risk: warehouse-2.0/ 可能与现有目录冲突
```

### Batch 2: warehouse-engineering-playbook (32KB)

```yaml
status: ready
priority: P0
content:
  - README.md
  - docs/ (工程文档)
  - sql/ (SQL模板)
  - templates/ (模板文件)
target_path: 06-engineering-playbooks/warehouse/
action: 提取DataX/Dolphin/质量/对账资料
risk: 内容可能较少，需确认完整性
```

### Batch 3: llm-wiki (3457KB)

```yaml
status: ready
priority: P1
content:
  - 大量AI/Agent/LLM资料
  - 包含04-warehouse-projects/子目录
  - 与warehouse-rebuild有重叠
target_path: 01-ai-agent-systems/ 和 02-data-warehouse/
action: 筛选Agent相关内容，数仓内容合并
risk: 内容量大，需仔细筛选
```

### Batch 6: certificate-system (1105KB)

```yaml
status: pending_confirmation
priority: P3
content:
  - Python代码 (app.py, models/, routes/, services/)
  - 部署脚本
  - 测试报告
target_path: 05-project-archives/certificate-system/
action: 用户确认是否保留代码仓库
risk: 如果仍在使用，删除会导致问题
```

## 执行顺序建议

```text
1. Batch 1 + Batch 2 (P0，可并行)
2. Batch 3 (P1，需筛选)
3. Batch 4 + Batch 5 (P1/P2，可并行)
4. Batch 6 (P3，需用户确认)
5. Batch 7 (生成收据和矩阵)
6. Batch 8 (用户确认后删除)
```
