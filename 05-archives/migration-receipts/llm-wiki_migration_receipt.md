# llm-wiki Migration Receipt

```yaml
source_repo: maxlee0218-lgtm/llm-wiki
source_default_branch: main
source_last_commit: be9ffed7bd089fdabebc30bd759c65d92d1be5b2
source_last_message: sync: auto-update 2026-05-16 08:19:22
source_size_kb: 3457
target_path: 05-archives/source-repos/llm-wiki/
migrated_files: 3240
skipped_files: 8
total_files: 3248
migrated_dirs: 419
```

## Migrated Paths

```
.git-sync.sh
.gitignore
.gitmodules
.obsidian/app.json
.obsidian/appearance.json
.obsidian/core-plugins.json
.obsidian/workspace-mobile.json
00-项目/进行中/HermesAgent全面自检与优化.md
01-ai-ml-research/.git-sync.sh
01-ai-ml-research/.gitignore
01-ai-ml-research/00-项目/进行中/HermesAgent全面自检与优化.md
01-ai-ml-research/10-领域/人工智能/AI与ML概览.md
01-ai-ml-research/10-领域/基础设施/基础设施资产清单.md
01-ai-ml-research/20-resources/20260510-111服务器数仓监控大屏摸底报告.md
01-ai-ml-research/20-resources/20260510-end-of-day-knowledge-handoff.md
01-ai-ml-research/20-resources/20260510-数仓监控大屏迁移状态报告.md
01-ai-ml-research/20-resources/ads-dq-sandbox-results.md
01-ai-ml-research/20-resources/agent-collaboration-runtime.md
01-ai-ml-research/20-resources/agent-role-operating-model.md
01-ai-ml-research/20-resources/agentic-data-warehouse-100-source-research.md
... and 3220 more
```

## Skipped Paths

```
01-ai-ml-research/20-资源/概念笔记/Token优化.md
03-certificate-system/django_rebuild/.env.example
04-warehouse-projects/rebuild-audit/audit/ads_sc_xl_13/runs/20260426_090204/01_keyword_hits.md
20-资源/概念笔记/Token优化.md
AI与机器学习/20-资源/概念笔记/Token优化.md
仓库工程项目/audit/ads_sc_xl_13/runs/20260426_090204/01_keyword_hits.md
仓库工程项目/rebuild-audit/audit/ads_sc_xl_13/runs/20260426_090204/01_keyword_hits.md
证书管理系统/django_rebuild/.env.example
```

## Skip Reason

```text
Skipped files matching:
- .git/ directories
- node_modules/
- venv/
- __pycache__/
- .env files
- Files containing 'token', 'secret', 'key', 'password', 'credential'
- Binary files (.pyc, .pyo, .so, .dll, .exe)
```

## Sensitive Files Excluded

```text
01-ai-ml-research/20-资源/概念笔记/Token优化.md
03-certificate-system/django_rebuild/.env.example
04-warehouse-projects/rebuild-audit/audit/ads_sc_xl_13/runs/20260426_090204/01_keyword_hits.md
20-资源/概念笔记/Token优化.md
AI与机器学习/20-资源/概念笔记/Token优化.md
仓库工程项目/audit/ads_sc_xl_13/runs/20260426_090204/01_keyword_hits.md
仓库工程项目/rebuild-audit/audit/ads_sc_xl_13/runs/20260426_090204/01_keyword_hits.md
证书管理系统/django_rebuild/.env.example
```

## Verification Method

```text
1. File count matches between source and target
2. File tree structure preserved
3. No sensitive files in target
```

## Verification Result

```text
Status: PENDING
Files to migrate: 3240
Files skipped: 8
Directories: 419
```

## Can Delete

```yaml
can_delete: pending
reason: Migration not yet verified by GPT
```

## Notes

```text
- This is a raw archive, no curation performed
- Original directory structure preserved
- Content not modified
- Duplicate files not merged
```
