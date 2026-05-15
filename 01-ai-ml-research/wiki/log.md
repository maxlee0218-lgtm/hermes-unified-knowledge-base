# 操作日志

## [2026-05-11] ingest | 首脑（历史别名）沉淀文件导入
- 导入81个原始报告文件
- 导入7个贾维斯分析产出文件
- 生成manifest和敏感扫描报告
- 位置：raw/staging/handbrain/handbrain-20260511/

## [2026-05-11] bootstrap | 完全体初始化
- 执行 bootstrap_complete_wiki.py
- 生成概念页10个
- 生成实体页13个
- health.py检查通过（fatal=0, warning=0）

## [2026-05-11] optimize | 参考架构优化
- 创建 outputs/ 目录
- 创建 raw/README.md
- 创建 references/tools.md
- 创建 references/workflow.md
- 优化 CLAUDE.md
- 更新 index.md

## [2026-05-11] compile | 第一批正式知识页
- 口径纠偏：Runtime首脑→Runtime治理者，手脑/索娜→首脑（历史别名）
- 生成7个正式知识页：
  - Runtime流程保障总账
  - 数仓重构工程手册
  - 数仓重构准入门槛
  - 智能体角色边界
  - Windows资产治理
  - AgentOS方法论吸收
  - 首脑历史沉淀资料20260511统一分析
- 更新index.md和log.md

## [2026-05-12] compile | 第二阶段全量知识编译

- 补齐第二阶段全量知识编译目标页；
- 形成运行治理、数仓重构、Agent协同、运维资产、外部研究五大知识域；
- 更新 index.md 的“第二阶段全量知识编译”导航区；
- 继续保持口径：首脑 = 手脑 = 索娜，Runtime ≠ 首脑，Codex = 工具工。

## [2026-05-12] decision | 六项待裁决事项正式裁决

- 样板链路固定为 ADS_SC_XL_13
- dbt 作为长期旁路工具
- 建立全 ADS 质量巡检（只读扫描）
- AgentOS 只吸收机制，不接新框架
- Ruflo 暂只作为研究资料保留
- 建立外部框架固定评估模板
- 所有裁决已固化到正式知识库

## [2026-05-14] D024 | 统一命名 Multica，废弃旧智能体

- **命名统一**：所有 `Multica.ai` / `multica.ai` / `ClawPilot` / `clawpilot` 统一为 **Multica**
- **智能体废弃**：
  - 任务管家-Windows-Kimi → **已废弃**
  - 数据虾-Windows-Kimi → **已废弃**
  - 代码工-Windows-Codex → **已废弃**
- **平台账号**：
  - Windows: `mul_08eb7fcb5b6886513d578f6a141b31b32608a07d`
  - 111服务器: `mul_9ca19bb69907e9ff275471a4e0e3f7c96df045a4`
- **影响**：llm-wiki 中所有相关页面已标记为废弃状态
- **状态**：completed

## [2026-05-14] 其他更新

- 更新 `AI数仓协作架构图与流程.md`：Multica 统一命名，智能体标记废弃
- 更新 `Multica任务管理规范.md`：规范冻结，任务全部关闭
- 更新 `智能体角色边界.md`：所有智能体标记废弃
- 更新 `手脑分离模式规范.md`：智能体标记废弃
- 更新 `Windows智能体技能清单.md`：所有技能标记失效
- 更新 `index.md`：相关条目标记废弃

- 安装原版 superpowers (obra/superpowers)
- 安装中文增强版 superpowers-zh (jnMetaCode/superpowers-zh)
- 整合8个核心skills到Hermes skills体系：
  - test-driven-development
  - systematic-debugging
  - subagent-driven-development
  - writing-plans
  - chinese-code-review
  - chinese-commit-conventions
  - chinese-documentation
  - chinese-git-workflow
- 位置：~/.hermes/skills/software-development/superpowers/

## [2026-05-12] optimize | 知识库治理优化

- 新增 `wiki/00-当前主路径.md`
- 新增 `wiki/outputs/当前决策总账.md`
- 新增 `wiki/outputs/知识库治理优化报告.md`
- 重写 `wiki/index.md`：把当前主路径和当前决策总账提到最前
- 升级 `references/workflow.md`：补充决策固化、来源地图、当前主路径、状态管理、治理检查流程
- 明确当前阶段：Codex 暂停、首脑服务器不重置、首脑接手、下一阶段进入 ADS_SC_XL_13 样板链路准备

## [2026-05-12] takeover | 首脑接手知识库维护

- 首脑已读取当前主路径；
- 首脑已读取当前决策总账；
- 首脑已读取知识库治理优化报告；
- 首脑确认接手 llm-wiki 知识库维护；
- 修复 `知识库治理优化报告.md` 未在 index 中显式引用的 warning；
- 当前不进入 ADS_SC_XL_13 摸排，等待用户下一步确认。

## [2026-05-13] decision | Windows DataGrip + MCP 数据库访问标准

- 确认 Windows 作为数据库访问 Runtime；
- 确认 DataGrip 作为人工连接维护工具；
- 确认 MCP 作为 Agent 数据访问出口；
- Agent 不直接接触数据库账号密码；
- 新增 Windows数据库MCP访问规范；
- 新增 数据访问只读安全边界；
- 新增 WindowsMCP数据库访问dry-run验证报告；
- 当前仅完成 dry-run，不查询业务明细，不执行写操作。

## [2026-05-13] validate | Multica 任务管家链路 dry-run 验证

- 创建 任务管家-Windows-Kimi Agent；
- 创建 数据虾-Windows-Kimi Agent；
- 创建 代码工-Windows-Codex Agent；
- 派发 LEE-98：任务管家链路验证，状态 done；
- 派发 LEE-99：数据虾可用性验证，状态 in_review；
- 派发 LEE-100：代码工可用性验证，状态 todo（Codex 不可用）；
- Multica CLI 可用，任务分派链路已验证；
- 未触碰生产数据库；
- 未输出密钥。

## [2026-05-13] architecture | AI数仓协作架构图与任务流程沉淀

- 新增 `wiki/outputs/AI数仓协作架构图与流程.md`；
- 沉淀当前协作架构：首脑、Multica.ai、Windows Runtime、任务管家、数据虾、代码工、DataGrip + MCP、llm-wiki；
- 沉淀当前任务流程：用户提需、首脑判断、Multica 创建 Issue、任务管家拆分、Windows Runtime 执行、结果回写、首脑验收、llm-wiki 沉淀；
- 更新 `wiki/index.md` 当前入口，加入架构图与流程页；
- 当前仍保持 dry-run / 只读优先，不进入生产动作。

## [2026-05-13] dry-run | Windows MCP 数据库只读连通性验证

- 派发 LEE-102：数据虾-Windows-Kimi 执行数据库 dry-run；
- 任务状态 in_review；
- Windows 不可达，dry-run 在 150 服务器执行；
- 未查询业务明细；
- 未输出密钥；
- 未执行写操作；
- 更新 WindowsMCP数据库访问dry-run验证报告。

## [2026-05-13] skill | 沉淀 PolarDB 数据分析技能

- 创建 skill: polardb-data-analysis；
- 包含 SSH 隧道连接、数据质量摸排、根因分析、SQL 优化、海豚脚本生成；
- 模板：牌号合并规则 SQL；
- 脚本：connect_tunnel.py；

## [2026-05-13] skill | 沉淀数仓 ETL 代码 CR 技能

- 新增 `skills/bigdata-etl-cr/SKILL.md`；
- 新增 `wiki/warehouse/数仓ETL代码CR技能.md`；
- 更新 `wiki/index.md`，加入 Skills / 技能 区域和数仓说明页；
- 该技能用于 Hive SQL、Spark SQL、Flink SQL、DataWorks / MaxCompute SQL 等 ETL 代码 CR；
- 检查维度包括数据正确性、数据质量、性能优化、代码规范和常见逻辑陷阱；
- 后续可用于 ADS_SC_XL_13 样板链路 SQL 审查。

## [2026-05-14] takeover | 新 Hermes 单体首脑接手

- 服务器 VM-0-9-ubuntu 上新 Hermes (v0.12.0) 接手为单体首脑；
- 旧首脑运行态不再继承；
- Windows 已重置，暂不纳入执行链路；
- Multica.ai、多智能体、任务管家、数据虾、代码工全部暂停；
- 数据库、MCP、生产系统全部暂停；
- llm-wiki 作为唯一正式知识底座，克隆至 /srv/ai/llm-wiki；
- SSH Deploy Key 已配置（id_ed25519_new）；
- 已读取全部知识库核心文件；
- 新增接手报告：wiki/outputs/新Hermes单体首脑接手报告.md；
- 更新 index.md 主路径摘要；
- 追加决策总账 D023；
- 当前只做知识库接手和状态收口。
