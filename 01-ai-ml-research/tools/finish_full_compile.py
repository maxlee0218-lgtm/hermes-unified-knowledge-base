from pathlib import Path
from datetime import datetime

ROOT = Path.cwd()
TODAY = "2026-05-12"

pages = {
"wiki/research/Agentic数仓重构研究摘要.md": """---
title: Agentic数仓重构研究摘要
date: 2026-05-12
tags: [research, agentic-warehouse]
status: stable
---

# Agentic数仓重构研究摘要

## 1. 结论

Agentic 数仓重构的核心不是让智能体直接改生产，而是让智能体参与尽调、规则整理、质量检查、链路追踪、验收设计和知识沉淀。

## 2. 适用范围

适用于数仓重构前尽调、ADS/DWD/ODS 链路分析、质量规则生成、调度同步风险识别和验收报告编制。

## 3. 已确认事实

- 数仓重构需要先做全景摸排；
- Agent 适合做只读分析、规则归纳和文档沉淀；
- 生产变更必须由人工确认；
- dbt 可作为旁路验证和文档工具；
- DolphinScheduler 和 DataX 仍是当前生产链路关键组件。

## 4. 核心规则

1. Agent 先读，不先改；
2. 先分析链路，再设计变更；
3. 先验证，再上线；
4. 所有结论必须有来源；
5. 所有风险必须可回退；
6. 样板链路优先于全量铺开。

## 5. 操作流程

1. 收集表、任务、同步、报表资料；
2. 建立链路图；
3. 标记风险；
4. 生成重构方案；
5. 生成验收标准；
6. 生成回退方案；
7. 沉淀到 wiki。

## 6. 风险与限制

- Agent 不能替代业务口径确认；
- Agent 不能直接处理生产变更；
- 源系统删除、补录、晚到数据仍需系统级治理；
- 大规模重构必须先做样板。

## 7. 待裁决事项

- 第一条样板链路是否固定为 ADS_SC_XL_13；
- dbt 是否作为长期旁路工具；
- 是否建立全 ADS 质量巡检。

## 8. 后续动作

- 建立 Agentic 数仓重构模板；
- 建立样板链路验收页；
- 建立数仓风险清单；
- 将研究结论转为工程规范。

## 9. 来源路径

- raw/staging/handbrain/handbrain-20260511/files/20260510-Agentic数仓重构100源研究报告.md
""",

"wiki/research/外部方法论吸收总报告.md": """---
title: 外部方法论吸收总报告
date: 2026-05-12
tags: [research, methodology]
status: stable
---

# 外部方法论吸收总报告

## 1. 结论

外部方法论只吸收原则，不直接引入新框架。当前优先吸收 LLM Wiki、AgentOS、Agentic 数仓中的状态机、审计、角色边界、知识沉淀和工具治理思想。

## 2. 适用范围

适用于首脑体系、Runtime 治理、知识库维护、数仓工程化和 Agent 协作规范。

## 3. 已确认事实

- Astro 风格适合轻量 Skill；
- Samur 风格适合完整模板参考；
- AgentOS 强调角色、状态、工具、审计和边界；
- 新框架不能在主链路未稳时直接接入。

## 4. 核心规则

1. 先吸收方法，不急于部署；
2. 所有外部方法必须转译成本地规则；
3. 不引入新的状态复杂度；
4. 研究结论必须进入 sources、research、index、log；
5. 未裁决内容标记为 draft。

## 5. 操作流程

1. 收集资料；
2. 进入 raw；
3. 提炼原则；
4. 判断采纳、暂缓或拒绝；
5. 编译到 wiki/research；
6. 更新 index/log。

## 6. 风险与限制

- 直接上新框架会增加混乱；
- 方法论没有本地规则就无法复用；
- 多框架并行容易职责冲突。

## 7. 待裁决事项

- AgentOS 哪些机制进入首脑规范；
- Ruflo 是否只作为研究资料保留；
- 外部框架研究是否建立固定评估模板。

## 8. 后续动作

- 建立外部框架评估模板；
- 建立采纳/暂缓/拒绝字段；
- 把方法论转为首脑与 Runtime 的本地规则。

## 9. 来源路径

- raw/staging/handbrain/handbrain-20260511/files/AgentOS方法论吸收报告.md
- raw/staging/handbrain/handbrain-20260511/files/20260510-Agentic数仓重构100源研究报告.md
""",

"wiki/warehouse/数仓重构验收与回滚手册.md": """---
title: 数仓重构验收与回滚手册
date: 2026-05-12
tags: [warehouse, acceptance]
status: stable
---

# 数仓重构验收与回滚手册

## 1. 结论

数仓重构必须先定义验收标准和恢复预案，再进入实施。验收要覆盖数据一致性、业务口径、展示结果、性能和调度稳定性。

## 2. 适用范围

适用于 ADS、DWD、ODS 链路调整，报表口径调整，调度链路调整和监控大屏迁移。

## 3. 已确认事实

- 历史尽调将验收标准缺失列为关键阻断；
- SQL 结果正确不等于报表展示正确；
- 新旧链路对比是降低风险的关键；
- 业务口径未确认时，技术验收不能代表最终通过。

## 4. 核心规则

1. 每个重构对象必须有验收清单；
2. 每个变更必须有恢复条件；
3. 新旧结果必须可比对；
4. 旧链路至少保留一个观察周期；
5. 切换后必须有观测窗口；
6. 业务口径必须有人确认。

## 5. 操作流程

1. 定义验收指标；
2. 定义比对范围；
3. 定义性能基线；
4. 定义异常处理条件；
5. 执行新旧对比；
6. 出具验收报告；
7. 确认后逐步切换。

## 6. 风险与限制

- 没有历史基线时只能先建立基线；
- 业务辅助表可能导致技术比对差异；
- 数据晚到会影响当天验收；
- 范围过大会导致异常难以定位。

## 7. 待裁决事项

- 观察周期长度；
- 差异阈值定义；
- 最终业务验收责任人。

## 8. 后续动作

- 建立统一验收模板；
- 建立恢复检查清单；
- 先对 ADS_SC_XL_13 样板链路设计验收方案；
- 将验收结果进入 wiki/outputs。

## 9. 来源路径

- raw/staging/handbrain/handbrain-20260511/files/20260510-数仓重构前终极尽调清单.md
- raw/staging/handbrain/handbrain-20260511/files/20260511-验收标准清单-v1.0.md
"""
}

for path, content in pages.items():
    p = ROOT / path
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(content.strip() + "\n", encoding="utf-8")

index_path = ROOT / "wiki/index.md"
index = index_path.read_text(encoding="utf-8") if index_path.exists() else "# Wiki 索引\n"

block = """
## 第二阶段全量知识编译

- [首脑历史沉淀资料全量编译总报告](outputs/首脑历史沉淀资料全量编译总报告.md)
- [首脑历史沉淀资料来源地图](sources/首脑历史沉淀资料来源地图.md)
- [运行治理总手册](runtime/运行治理总手册.md)
- [任务生命周期治理手册](runtime/任务生命周期治理手册.md)
- [GitHub任务总线与网关手册](runtime/GitHub任务总线与网关手册.md)
- [数仓重构总手册](warehouse/数仓重构总手册.md)
- [数据质量治理手册](warehouse/数据质量治理手册.md)
- [调度同步治理手册](warehouse/调度同步治理手册.md)
- [数仓重构验收与回滚手册](warehouse/数仓重构验收与回滚手册.md)
- [首脑协同总规范](agent/首脑协同总规范.md)
- [智能体执行与验收规范](agent/智能体执行与验收规范.md)
- [首脑自我改进清单](agent/首脑自我改进清单.md)
- [Windows与服务器资产治理手册](operations/Windows与服务器资产治理手册.md)
- [敏感信息与配置治理手册](operations/敏感信息与配置治理手册.md)
- [外部方法论吸收总报告](research/外部方法论吸收总报告.md)
- [Agentic数仓重构研究摘要](research/Agentic数仓重构研究摘要.md)
"""

if "## 第二阶段全量知识编译" not in index:
    index = index.rstrip() + "\n\n" + block.strip() + "\n"
index_path.write_text(index, encoding="utf-8")

log_path = ROOT / "wiki/log.md"
log = log_path.read_text(encoding="utf-8") if log_path.exists() else "# 操作日志\n"
log_block = """
## [2026-05-12] compile | 第二阶段全量知识编译

- 补齐第二阶段全量知识编译目标页；
- 形成运行治理、数仓重构、Agent协同、运维资产、外部研究五大知识域；
- 更新 index.md 的“第二阶段全量知识编译”导航区；
- 继续保持口径：首脑 = 手脑 = 索娜，Runtime ≠ 首脑，Codex = 工具工。
"""
if "第二阶段全量知识编译" not in log:
    log = log.rstrip() + "\n\n" + log_block.strip() + "\n"
log_path.write_text(log, encoding="utf-8")

print("finish_full_compile done")
