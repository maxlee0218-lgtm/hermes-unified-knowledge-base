#!/usr/bin/env python3
"""Bootstrap the complete LLM Wiki structure.

This script is intentionally local, deterministic, and file-only.
It does not call production systems, Multica, DolphinScheduler, DataX, or external APIs.

Run from repository root:
    python tools/bootstrap_complete_wiki.py
    python tools/health.py --json
"""
from __future__ import annotations

from pathlib import Path
from datetime import date

ROOT = Path(__file__).resolve().parents[1]
TODAY = "2026-05-10"


def write(path: str, content: str, overwrite: bool = True) -> None:
    p = ROOT / path
    p.parent.mkdir(parents=True, exist_ok=True)
    if p.exists() and not overwrite:
        return
    p.write_text(content.strip() + "\n", encoding="utf-8")


def frontmatter(title: str, typ: str, tags: str, status: str = "stable") -> str:
    return f"""---
title: \"{title}\"
type: {typ}
tags: [{tags}]
sources: []
raw: []
last_updated: {TODAY}
status: {status}
---
"""


ENTITIES = {
    "ChatGPT": ("entrypoint, decision", "用户唯一入口、方案裁决层、执行指令生成层。", "判断主路径、生成任务指令、审核 Agent 结果、维护知识库沉淀方向。", "不直接修改生产系统，不替代 Runtime 执行层。"),
    "RuntimeChief": ("runtime, governance", "Runtime 治理 owner，负责运行态巡检、生命周期治理、堵点识别、状态收口建议。", "读取 Multica 与 GitHub 状态，输出 runtime-state 与治理报告，识别 review、blocked、done/archive、heartbeat 问题。", "不修改 Multica 框架，不修改生产系统，不补业务产物。"),
    "Multica": ("runtime, issue, agent", "Issue / Agent Runtime 执行池。", "创建和跟踪 Issue，分配 Agent，记录任务状态，作为运行真相来源。", "不作为完整操作系统总账，不由 Agent 随意修改框架源码、daemon、配置或数据库。"),
    "GitHub": ("audit, knowledge, command", "指令、审计、知识沉淀层。", "保存知识库、任务指令、报告、done/failed 审计证据。", "不作为实时运行态真相；tasks/active 不得作为真实 active 判断依据。"),
    "Codex": ("tooling, coding-agent", "临时代码工具工。", "读仓库、写脚本、探测 CLI、修工具、生成报告模板、提交代码。", "不是主脑，不是 Runtime owner，不直接处理生产，不修改 Multica 框架。"),
    "KimiClawWindowsWorker": ("windows, worker, readonly", "Windows 本地只读执行节点。", "读取 Windows C/D 盘结构摘要，检查 D:\\AIWorker，补齐 Windows 环境证据。", "不连接生产，不迁移文件，不读取密钥原文，不绕过 Runtime首脑。"),
    "Corelli": ("agent, readonly, review", "只读观察与纠偏评论型协作角色。", "读取指定任务信息，观察流程偏差，在授权范围内写说明评论。", "默认不允许改状态、关闭任务或处理生产系统。"),
    "DataShrimp": ("agent, data, readonly", "数据只读调查角色。", "只读查询数仓与调度元数据，定位数据链路问题，输出证据、SQL、风险判断和报告。", "默认 SELECT-only，不修改生产数据库、调度任务、同步任务或密钥配置。"),
    "WarehouseSteward": ("agent, warehouse, governance", "数仓治理与方案执行辅助角色。", "梳理数仓链路，输出变更方案，管理验证、回滚、监控要求。", "不直接改生产；所有生产变更必须人工确认。"),
    "DolphinScheduler": ("warehouse, scheduler", "生产调度与依赖编排工具。", "编排数据任务，维护任务依赖，记录任务实例、失败、重试、日志路径。", "当前阶段不由 AI 直接修改生产调度，不替换为 dbt。"),
    "DataX": ("warehouse, sync", "当前生产同步工具。", "执行源系统到 ODS/仓库的同步；关注物理删除、晚到更新、创建时间增量漏数。", "当前阶段不由 AI 直接修改生产 DataX 配置或重跑同步。"),
    "dbt": ("warehouse, modeling, testing", "旁路建模、测试、文档和血缘工具。", "在测试环境做模型标准化，支持 SQL 测试、文档、血缘和重构前后对比。", "当前不替代 DolphinScheduler，不直接接管生产调度。"),
    "ADS_SC_XL_13": ("warehouse, sample-lineage, ads", "当前数仓重构样板链路。", "作为第一条可复制的重构样板，支持 ODS/DWD/ADS 链路摸排和重构验证。", "先在测试环境验证，生产动作必须人工确认。"),
}

CONCEPTS = {
    "RuntimeFlowGuard": ("runtime, observability, guard", "Runtime 流程保障总账，用于判断当前流程是否通、卡在哪、责任角色是谁、是否需要人工决策。", ["只读观测", "不补业务产物", "不修改状态", "输出 runtime-state.json 与 runtime-state.md"]),
    "CommandGateway": ("runtime, github, gateway", "GitHub command file 到本地 gateway，再到 Multica CLI 的审计型任务入口。", ["默认 dry-run", "approved 必须指定任务、动作和边界", "不作为长期 Runtime 主脑", "只保留审计和安全边界"]),
    "ReadOnlyFirst": ("safety, readonly", "所有数据、运维、Runtime 调查默认只读优先。", ["先读取证据，再判断动作", "生产写操作必须人工确认", "Agent 默认不得改生产", "工具权限按最小必要开放"]),
    "ProductionGuardrails": ("safety, production", "生产护栏是所有 AI/Agent 工作的硬边界。", ["不修改生产数据库", "不修改 DolphinScheduler 生产任务", "不修改 DataX 生产任务", "不自动补数", "不重跑生产", "生产动作必须人工确认、可备份、可回滚"]),
    "WarehouseRebuildPlaybook": ("warehouse, playbook", "数仓重构工程手册，强调先复现、再追链路、再验证、最后人工上线。", ["先查数据，再改逻辑", "归档表默认是证据", "总数和展示粒度都要验证", "变更必须最小范围、可备份、可回滚", "ADS_SC_XL_13 作为第一条样板链路"]),
    "ReportValidation": ("warehouse, report, validation", "报表验证要求同时验证数字正确性与展示粒度正确性。", ["SQL 跑通不等于报表修好", "总数正确也可能存在重复展示行", "需要验证行数、汇总、重复、标签、空值", "归档表默认作为对比基线"]),
    "DoneArchiveLifecycle": ("runtime, lifecycle", "任务从 done 进入 archive 的生命周期治理规则。", ["done 不等于最终闭环", "已完成任务应生成归档摘要", "测试/沙箱任务优先归档", "核心知识任务先补齐报告和 Wiki，再归档"]),
    "ReviewBacklogGovernance": ("runtime, review", "Review backlog 治理用于防止任务长期卡在待审核状态。", ["in_review 需要 SLA", "超时任务必须分类", "不能只巡检不收口", "状态变更必须有审计记录"]),
    "AgentRoleBoundary": ("agent, boundary, governance", "Agent 角色边界用于防止主脑、Runtime、工具工和执行节点职责混乱。", ["ChatGPT 裁决", "Runtime首脑治理", "Multica 执行池", "GitHub 审计知识", "Codex 工具工", "生产动作人工确认"]),
    "LLMWikiIngest": ("knowledge-base, ingest", "LLM Wiki ingest 是把原始资料转成可复用知识页的流程。", ["raw 保存不可变来源", "wiki 保存编译知识", "每次 ingest 更新 index 和 log", "query 结果归档到 syntheses", "禁止敏感信息入库"]),
}

TOPIC_READMES = {
    "runtime": ("Runtime Knowledge", "Runtime 主题收纳 Multica、Gateway、Runtime首脑、Flow Guard、任务生命周期、状态治理、运行观测相关知识。"),
    "warehouse": ("Warehouse Knowledge", "数仓主题收纳数仓重构、DolphinScheduler、DataX、dbt、ADS/DWD/ODS、报表验证、生产护栏相关知识。"),
    "agent": ("Agent Knowledge", "Agent 主题收纳角色边界、协作模式、权限规则、只读/执行分离、Codex 工具工定位等知识。"),
    "research": ("Research Knowledge", "Research 主题收纳外部项目、框架、工具研究，包括 Astro、Samur、Ruflo 等。"),
    "operations": ("Operations Knowledge", "Operations 主题收纳运行维护、流程保障、状态快照、告警与人工决策相关知识。"),
    "sources": ("Sources", "本目录保存每个原始资料的摘要页。原文或原始材料应保存在 raw/。"),
    "syntheses": ("Syntheses", "本目录保存阶段性总结、查询归档、决策摘要。"),
}

SOURCE_PAGES = {
    "knowledge-base-rules": ("Knowledge Base Rules", "KNOWLEDGE_BASE_RULES.md", "知识库定位、目录、查询、安全和当前主路径规则。"),
    "warehouse-engineering-playbook-absorption": ("Warehouse Engineering Playbook Absorption", "20-resources/warehouse-engineering-playbook-absorption-20260510.md", "数仓工程手册吸收，形成先复现、追链路、验证、回滚的工程基线。"),
    "runtime-governor-report": ("Runtime Governor Report", "20-resources/runtime-governor-report.md", "Runtime 治理报告，记录 Multica 状态、review、blocked、done/archive、heartbeat 等运行态问题。"),
    "multica-command-gateway-spike": ("Multica Command Gateway SPIKE", "20-resources/multica-command-gateway-spike-report.md", "GitHub command file 到 Multica CLI 的 dry-run 网关验证报告。"),
    "multica-command-gateway-update-status-spike": ("Multica Command Gateway Update Status SPIKE", "20-resources/multica-command-gateway-update-status-spike-report.md", "状态更新和评论能力的 gateway SPIKE 报告。"),
    "llm-wiki-complete-upgrade-spec": ("LLM Wiki Complete Upgrade Spec", "20-resources/llm-wiki-complete-upgrade-spec-20260510.md", "LLM Wiki 完全体升级规格书。"),
}


def main() -> None:
    for d in [
        "raw/runtime", "raw/warehouse", "raw/agent", "raw/research", "raw/operations", "raw/external",
        "wiki/sources", "wiki/entities", "wiki/concepts", "wiki/syntheses", "wiki/runtime", "wiki/warehouse", "wiki/agent", "wiki/research", "wiki/operations",
        "references", "tools", "graph", "20-resources", "runtime-commands",
    ]:
        (ROOT / d).mkdir(parents=True, exist_ok=True)

    for topic, (title, summary) in TOPIC_READMES.items():
        write(f"wiki/{topic}/README.md", f"""{frontmatter(title, topic if topic not in {'sources', 'syntheses'} else ('source' if topic == 'sources' else 'synthesis'), topic)}# {title}

{summary}
""")

    for name, (tags, role, responsibilities, boundaries) in ENTITIES.items():
        write(f"wiki/entities/{name}.md", f"""{frontmatter(name, 'entity', tags)}# {name}

## Role

{role}

## Responsibilities

{responsibilities}

## Boundaries

{boundaries}
""")

    for name, (tags, definition, rules) in CONCEPTS.items():
        rule_lines = "\n".join(f"- {r}" for r in rules)
        write(f"wiki/concepts/{name}.md", f"""{frontmatter(name, 'concept', tags)}# {name}

## Definition

{definition}

## Rules

{rule_lines}
""")

    for slug, (title, source_file, summary) in SOURCE_PAGES.items():
        write(f"raw/research/{TODAY}-{slug}.md", f"""---
title: \"{title}\"
source_file: \"{source_file}\"
collected: {TODAY}
published: Unknown
topic: research
---

# {title}

## Summary

{summary}

## Original Reference

See `{source_file}` in this repository.
""")
        write(f"wiki/sources/{slug}.md", f"""---
title: \"{title}\"
type: source
tags: [source, absorbed]
sources: []
raw: [raw/research/{TODAY}-{slug}.md]
last_updated: {TODAY}
status: stable
source_file: raw/research/{TODAY}-{slug}.md
---

# {title}

## Summary

{summary}

## Source File

`{source_file}`

## Connections

- [LLMWikiIngest](../concepts/LLMWikiIngest.md)
""")

    # Core synthesis pages
    write("wiki/research/LLMWikiArchitecture.md", f"""{frontmatter('LLM Wiki Architecture', 'research', 'llm-wiki, astro, samur')}# LLM Wiki Architecture

## Summary

本仓库采用 Astro-Han/karpathy-llm-wiki 作为轻量 Skill 核心，采用 SamurAIGPT/llm-wiki-agent 作为完整模板参考。

## Decision

- Astro 负责规则：raw/wiki/index/log/ingest/query/lint。
- Samur 负责结构参考：sources/entities/concepts/syntheses/tools/graph。
- 当前不引入复杂图谱依赖，先完成可持续知识库底座。
""")

    write("wiki/warehouse/WarehouseEngineeringPlaybook.md", f"""{frontmatter('Warehouse Engineering Playbook', 'warehouse', 'warehouse, playbook')}# Warehouse Engineering Playbook

## Summary

数仓工程不是单纯写 SQL，而是数据真实性、调度稳定性、业务口径、变更风险和可回滚工程治理。

## Operating Flow

1. 捕获症状。
2. 找到 ADS 表与报表 SQL。
3. 追踪 Dolphin/DataX/ODS/DWD。
4. 对比归档或基线。
5. 分类问题。
6. 选择最小安全修复。
7. 验证行数、汇总、重复、标签和重跑稳定性。
""")

    write("wiki/runtime/RuntimeOperatingModel.md", f"""{frontmatter('Runtime Operating Model', 'runtime', 'runtime, governance')}# Runtime Operating Model

## Summary

当前主链路暂停重建前，Multica 降级为 Issue / Agent 执行池，真正的顺畅性来自 Runtime Flow Guard 总账。

## Model

- ChatGPT：裁决入口。
- RuntimeChief：运行治理 owner。
- Multica：任务执行池。
- GitHub：审计与知识库。
- Codex：临时工具工。
""")

    index_entities = "\n".join(f"- [{name}](entities/{name}.md) — {data[1]} Updated: {TODAY}" for name, data in ENTITIES.items())
    index_concepts = "\n".join(f"- [{name}](concepts/{name}.md) — {data[1]} Updated: {TODAY}" for name, data in CONCEPTS.items())
    index_sources = "\n".join(f"- [{title}](sources/{slug}.md) — {summary} Updated: {TODAY}" for slug, (title, _, summary) in SOURCE_PAGES.items())
    write("wiki/index.md", f"""# Knowledge Base Index

> 本索引用于登记编译后的长期知识文章，不登记所有临时任务文件。

## Overview

- [Overview](overview.md) — 知识库总体说明与当前阶段主线。Updated: {TODAY}

## Sources

- [Sources README](sources/README.md) — 原始资料摘要页入口。Updated: {TODAY}
{index_sources}

## Entities

{index_entities}

## Concepts

{index_concepts}

## Runtime

- [Runtime README](runtime/README.md) — Runtime / Multica / Gateway / Flow Guard 主题入口。Updated: {TODAY}
- [Runtime Operating Model](runtime/RuntimeOperatingModel.md) — Runtime 运行模型。Updated: {TODAY}

## Warehouse

- [Warehouse README](warehouse/README.md) — 数仓、Dolphin、DataX、dbt、报表验证主题入口。Updated: {TODAY}
- [Warehouse Engineering Playbook](warehouse/WarehouseEngineeringPlaybook.md) — 数仓工程手册。Updated: {TODAY}

## Agent

- [Agent README](agent/README.md) — Agent 角色、协作边界、权限规则主题入口。Updated: {TODAY}

## Research

- [Research README](research/README.md) — 外部项目、框架、工具研究主题入口。Updated: {TODAY}
- [LLM Wiki Architecture](research/LLMWikiArchitecture.md) — LLM Wiki 架构裁决。Updated: {TODAY}

## Operations

- [Operations README](operations/README.md) — 日常运维、流程治理、运行观测主题入口。Updated: {TODAY}

## Syntheses

- [Syntheses README](syntheses/README.md) — 阶段性总结、查询归档、决策摘要入口。Updated: {TODAY}
""")

    write("wiki/log.md", f"""# Wiki Log

## [{TODAY}] init | LLM Wiki 完全体升级
- Created: wiki/index.md
- Created: wiki/overview.md
- Created: topic README pages
- Created: entity seed pages
- Created: concept seed pages
- Created: source summary pages
- Created: raw reference pages
- Created: tools/health.py and helper placeholders

## [{TODAY}] ingest | Initial repository knowledge absorption
- Updated: Knowledge Base Rules
- Updated: Warehouse Engineering Playbook
- Updated: Runtime Governor Report
- Updated: Multica Command Gateway SPIKE
- Updated: Multica Command Gateway Update Status SPIKE
- Updated: LLM Wiki Complete Upgrade Spec
""")

    write("wiki/overview.md", f"""{frontmatter('LLM Wiki Overview', 'synthesis', 'overview, knowledge-base')}# LLM Wiki Overview

本仓库升级为长期知识库、方案库、审计库和经验库。

当前阶段主线：

```text
先整理知识库
再重建主链路
```

## Architecture

- raw：原始资料。
- wiki：编译知识。
- references：模板。
- tools：健康检查和维护工具。
- graph：后续图谱预留。

## Current Decision

Astro 是核心规则，Samur 是完整模板；本仓库升级为可持续积累的 LLM Wiki。
""")

    write("20-resources/llm-wiki-complete-upgrade-report-20260510.md", f"""# LLM Wiki 完全体升级报告

> 时间：{TODAY}

## 001 完成目录

已建立或确认：raw、wiki、references、tools、graph、20-resources、runtime-commands。

## 002 模板

已建立 references 模板：raw、source、article、entity、concept、synthesis、index、log。

## 003 实体页

已建立实体页：{', '.join(ENTITIES.keys())}。

## 004 概念页

已建立概念页：{', '.join(CONCEPTS.keys())}。

## 005 资料吸收

已吸收来源：{', '.join(title for title, _, _ in SOURCE_PAGES.values())}。

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
""")

    print("LLM Wiki complete bootstrap finished.")


if __name__ == "__main__":
    main()
