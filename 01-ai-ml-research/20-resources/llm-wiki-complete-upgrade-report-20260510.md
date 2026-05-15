# LLM Wiki 完全体升级报告

> 时间：2026-05-10

## 001 完成目录

已建立或确认：raw、wiki、references、tools、graph、20-resources、runtime-commands。

## 002 模板

已建立 references 模板：raw、source、article、entity、concept、synthesis、index、log。

## 003 实体页

已建立实体页：ChatGPT, RuntimeChief, Multica, GitHub, Codex, KimiClawWindowsWorker, Corelli, DataShrimp, WarehouseSteward, DolphinScheduler, DataX, dbt, ADS_SC_XL_13。

## 004 概念页

已建立概念页：RuntimeFlowGuard, CommandGateway, ReadOnlyFirst, ProductionGuardrails, WarehouseRebuildPlaybook, ReportValidation, DoneArchiveLifecycle, ReviewBacklogGovernance, AgentRoleBoundary, LLMWikiIngest。

## 005 资料吸收

已吸收来源：Knowledge Base Rules, Warehouse Engineering Playbook Absorption, Runtime Governor Report, Multica Command Gateway SPIKE, Multica Command Gateway Update Status SPIKE, LLM Wiki Complete Upgrade Spec。

## 006 工具

已建立 tools/health.py、kb_lint.py、build_index.py、ingest_check.py。

## 007 未完成事项

- graph 仍为预留目录；
- kb_lint.py、build_index.py、ingest_check.py 为占位工具；
- 后续需要逐步把 20-resources 的历史报告深度编译进 wiki。

## 008 下一步建议

1. 后续所有研究先 raw 后 wiki；
2. 每次知识沉淀必须更新 index 和 log；
3. 主链路重建前，先保持知识库健康；
4. 运行 `python tools/health.py --json` 验收结构。
