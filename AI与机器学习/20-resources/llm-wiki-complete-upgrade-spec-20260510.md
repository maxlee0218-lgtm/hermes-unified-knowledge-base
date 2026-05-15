# LLM Wiki 完全体升级规格书

> 时间：2026-05-10  
> 当前裁决：主链路暂停重建前，先把知识库升级成完整、可持续、可审计、可被 Agent 维护的知识系统。  
> 参考：Astro-Han/karpathy-llm-wiki、SamurAIGPT/llm-wiki-agent。  
> 执行原则：Astro 做核心 Skill；Samur 做完整模板参考；不引入复杂运行依赖；先完成知识库骨架、规则、索引、日志、健康检查。

---

## 001 总体定位

`llm-wiki` 从现在开始不再只是 Runtime 任务中转仓，而是用户的长期知识库、方案库、审计库、经验库。

目标：

```text
一次性聊天 / 研究 / 报告 / 数仓排障 / Agent 运行经验
→ raw 原始证据
→ wiki 编译知识
→ index 可查目录
→ log 可审计历史
→ health 可检查结构
→ synthesis 可归档决策
```

---

## 002 采用的设计组合

### Astro-Han/karpathy-llm-wiki：作为核心 Skill

吸收点：

1. `raw/` 保存不可变原始资料；
2. `wiki/` 保存 LLM 编译后的知识文章；
3. 每次 ingest 必须同时更新 `wiki/index.md` 与 `wiki/log.md`；
4. 查询时先读 index，再读相关文章；
5. lint 分为确定性自动修复和启发式报告；
6. archive/query 结果作为单独 syntheses 页面，不覆盖原知识。

### SamurAIGPT/llm-wiki-agent：作为完整模板参考

吸收点：

1. `sources/`：来源摘要；
2. `entities/`：系统、项目、角色、工具实体；
3. `concepts/`：方法、框架、原则、模式；
4. `syntheses/`：阶段性总结和查询归档；
5. `tools/health.py`：每次会话都能跑的结构健康检查；
6. `graph/`：后续知识图谱预留，不作为当前强依赖。

---

## 003 完全体目录结构

请在仓库根目录建立：

```text
raw/
  runtime/
  warehouse/
  agent/
  research/
  operations/
  external/

wiki/
  index.md
  log.md
  overview.md
  sources/
  entities/
  concepts/
  syntheses/
  runtime/
  warehouse/
  agent/
  research/
  operations/

references/
  raw-template.md
  source-template.md
  article-template.md
  entity-template.md
  concept-template.md
  synthesis-template.md
  index-template.md
  log-template.md

tools/
  health.py
  kb_lint.py
  build_index.py
  ingest_check.py

graph/
  README.md

20-resources/
  继续保留当前阶段报告、裁决、运行材料

runtime-commands/
  只作为任务入口和审计，不作为知识库主体
```

目录职责：

| 目录 | 职责 |
|---|---|
| raw/ | 原始材料，只保存，不重写观点 |
| wiki/ | 编译后的长期知识 |
| wiki/sources/ | 每个来源一页摘要 |
| wiki/entities/ | 人、系统、项目、Agent、工具 |
| wiki/concepts/ | 方法论、原则、框架、模式 |
| wiki/syntheses/ | 阶段性结论、查询归档、决策摘要 |
| references/ | 模板层 |
| tools/ | 健康检查、索引生成、lint 工具 |
| graph/ | 后续图谱预留 |

---

## 004 页面 Frontmatter 规范

所有 wiki 页面统一使用：

```yaml
---
title: "页面标题"
type: source | entity | concept | synthesis | runtime | warehouse | agent | research | operations
tags: []
sources: []
raw: []
last_updated: YYYY-MM-DD
status: draft | stable | archived
---
```

补充规则：

- `source` 页面必须有 `source_file`；
- `synthesis` 页面必须写明它回答的问题；
- `entity` 页面用于系统、项目、Agent、工具；
- `concept` 页面用于工程原则、方法论、流程模式；
- `status=draft` 表示仍未验收；
- `status=stable` 表示可作为后续问答依据；
- `status=archived` 表示历史快照，不自动更新。

---

## 005 Ingest 工作流

触发场景：

```text
吸收资料
沉淀经验
整理报告
外部项目研究
把这段放进知识库
```

流程：

1. 将原始材料保存到 `raw/<topic>/YYYY-MM-DD-<slug>.md`；
2. 为该来源创建或更新 `wiki/sources/<slug>.md`；
3. 判断是否需要新增/更新：
   - `wiki/entities/`；
   - `wiki/concepts/`；
   - `wiki/runtime/`；
   - `wiki/warehouse/`；
   - `wiki/agent/`；
   - `wiki/research/`；
4. 更新 `wiki/index.md`；
5. 追加 `wiki/log.md`；
6. 运行 `python tools/health.py`；
7. 输出变更摘要。

禁止：

- 原始材料直接改写；
- 不更新 index/log；
- 不写来源；
- 将密钥、连接串、token、人员明细放入 Git。

---

## 006 Query 工作流

触发场景：

```text
我们现在知道什么？
总结某个项目
查询 Runtime 经验
查询数仓排障方法
比较两个框架
```

流程：

1. 读取 `wiki/index.md`；
2. 读取相关 wiki 页面；
3. 必要时回查 raw 来源；
4. 输出答案，并引用 wiki 页面；
5. 如果用户要求沉淀，则新建 `wiki/syntheses/<slug>.md`；
6. 更新 index/log。

---

## 007 Health 工作流

每次重要操作前后都可以运行：

```bash
python tools/health.py
python tools/health.py --json
python tools/health.py --save
```

必须检查：

1. wiki 页面是否有 frontmatter；
2. index 中登记的文件是否存在；
3. 实际 wiki 文件是否都进入 index；
4. log 是否覆盖 source ingest；
5. 是否存在空文件；
6. 是否存在明显敏感字段；
7. raw 引用是否存在；
8. wikilink 是否断裂。

`health` 只做结构检查，不做语义判断。

---

## 008 Lint 工作流

`lint` 周期性执行，不要求每次执行。

检查：

- 孤儿页面；
- 断链；
- 概念重复；
- 同一事实冲突；
- 被新资料覆盖的旧结论；
- 经常被提及但没有独立页面的概念；
- synthesis 引用的源页面是否已发生重大更新。

当前阶段只报告，不自动大规模修复。

---

## 009 初始必须建立的实体页

请创建以下实体页：

```text
wiki/entities/ChatGPT.md
wiki/entities/RuntimeChief.md
wiki/entities/Multica.md
wiki/entities/GitHub.md
wiki/entities/Codex.md
wiki/entities/KimiClawWindowsWorker.md
wiki/entities/Corelli.md
wiki/entities/DataShrimp.md
wiki/entities/WarehouseSteward.md
wiki/entities/DolphinScheduler.md
wiki/entities/DataX.md
wiki/entities/dbt.md
wiki/entities/ADS_SC_XL_13.md
```

---

## 010 初始必须建立的概念页

请创建以下概念页：

```text
wiki/concepts/RuntimeFlowGuard.md
wiki/concepts/CommandGateway.md
wiki/concepts/ReadOnlyFirst.md
wiki/concepts/ProductionGuardrails.md
wiki/concepts/WarehouseRebuildPlaybook.md
wiki/concepts/ReportValidation.md
wiki/concepts/DoneArchiveLifecycle.md
wiki/concepts/ReviewBacklogGovernance.md
wiki/concepts/AgentRoleBoundary.md
wiki/concepts/LLMWikiIngest.md
```

---

## 011 初始必须建立的主题入口页

```text
wiki/runtime/README.md
wiki/warehouse/README.md
wiki/agent/README.md
wiki/research/README.md
wiki/operations/README.md
wiki/sources/README.md
wiki/syntheses/README.md
```

---

## 012 初始必须吸收的资料

优先从已有仓库内容吸收：

1. `KNOWLEDGE_BASE_RULES.md`；
2. `20-resources/warehouse-engineering-playbook-absorption-20260510.md`；
3. `20-resources/runtime-governor-report.md`；
4. `20-resources/multica-command-gateway-spike-report.md`；
5. `20-resources/multica-command-gateway-update-status-spike-report.md`；
6. Runtime Flow Guard 相关任务与报告；
7. Astro-Han/karpathy-llm-wiki 的 SKILL 规则；
8. SamurAIGPT/llm-wiki-agent 的 AGENTS 规则。

---

## 013 安全规则

禁止进入 Git：

```text
密码
token
API key
SSH 私钥
生产连接串
带用户名的服务器连接信息
员工个人明细
原始业务导出
未脱敏日志
```

提交前必须做敏感字段扫描。

---

## 014 当前阶段禁令

在知识库完全体落地前：

1. 不继续扩 Multica 主链路；
2. 不新增新 Agent 主脑；
3. 不让 Codex 接管 Runtime；
4. 不把 runtime-commands 当知识库主体；
5. 不把 20-resources 当最终知识结构；
6. 不做生产变更。

---

## 015 验收标准

完全体第一阶段完成标准：

1. 目录结构存在；
2. `wiki/index.md` 存在；
3. `wiki/log.md` 存在；
4. `wiki/overview.md` 存在；
5. references 模板存在；
6. tools/health.py 可运行；
7. 初始实体页存在；
8. 初始概念页存在；
9. 至少 5 个已有资料被吸收到 wiki；
10. `python tools/health.py --json` 返回无 fatal；
11. GitHub commit id 输出。

---

## 016 一句话结论

```text
Astro 是核心规则，Samur 是完整模板；
本仓库升级为可持续积累的 LLM Wiki，
先整理知识，再重建主链路。
```
