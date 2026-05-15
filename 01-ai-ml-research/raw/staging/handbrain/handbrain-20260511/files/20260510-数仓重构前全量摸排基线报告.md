# 数仓重构前全量摸排基线报告

> 生成时间：2026-05-10 11:03 CST  
> 执行者：主脑（150服务器 Hermes）  
> 任务来源：TASK-20260510-005-warehouse-rebuild-full-inventory  
> 约束：只读摸排、总结、判断、建议。不执行任何生产修改。

---

## 001 摸排范围与已读文件清单

### 1.1 LLM Wiki / 20-resources 核心文档（8份）

| 序号 | 文件路径 | 是否已读 | 关键结论摘要 |
|------|----------|----------|--------------|
| 1 | `/root/wiki/20-resources/infra-architecture.md` | ✅ 已读 | 主脑执行规则：PolarDB只能由Windows智能体执行；生产库只读保护；三层知识沉淀闭环（本地+Wiki+GitHub）；已确认错误路径（111/150直连PolarDB失败、127.0.0.1:2222非Windows） |
| 2 | `/root/wiki/20-resources/ads-dq-sandbox-results.md` | ✅ 已读 | ADS 38张表摸排完成；P0风险2张（ads_gx_xs_25_01空表/ads_gx_xs_17_detail陈旧290天）；根因为调度未配置/工作流下线；建立空表/陈旧表排查SOP；P1候选4张待排查 |
| 3 | `/root/wiki/20-resources/agent-collaboration-runtime.md` | ✅ 已读 | Agent协同链路打通：ChatGPT→GitHub→PocketClaw→Multica→Agent；三类Agent（数据专家/数仓管家/深度研究智能体）；安全边界生效（禁止自动修改生产库/调度/同步）；PocketClaw每10分钟触发 |
| 4 | `/root/wiki/20-resources/system-runtime-overview.md` | ✅ 已读 | 四节点运行态：150主脑在线、111退役中SSH不可达、Windows SSH不可达（PolarDB出口阻断）、184备用在线但服务未运行；当前阶段：基础设施结束，有限正式运行 |
| 5 | `/root/wiki/20-resources/warehouse-rebuild-business-plan.md` | ✅ 已读 | 数仓重构业务方案：生产冻结原则、Windows先行验证原则、AI参与建设但不碰生产；分5阶段推进（0全貌摸排→1Windows治理→2最小链路验证→3新旧并跑→4生产改造建议→5AI辅助读数）；样板链路ADS_SC_XL_13 |
| 6 | `/root/wiki/20-resources/warehouse-rebuild-due-diligence-checklist.md` | ✅ 已读 | 15维度尽调清单；判断为Conditional Go（有条件启动）；3个P0阻断缺口（Windows不可达、验收标准未定义、回滚方案未定义）；10项准入门槛当前满足0/10 |
| 7 | `/root/wiki/20-resources/20260510-111服务器数仓监控大屏摸底报告.md` | ✅ 已读 | 111服务器warehouse-monitor-v2项目摸底：FastAPI+Python技术栈、18080端口运行中、config.json含明文密码（已脱敏）、无Git版本控制、可迁移但需安全处理 |
| 8 | `/root/wiki/20-resources/20260510-数仓监控大屏迁移状态报告.md` | ✅ 已读 | 迁移进度：111摸底完成→脱敏打包完成（9.8M）→Windows旧版备份完成→旁路部署进行中（LEE-22/数据专家） |

### 1.2 深度研究/Agent/运行态文档（4份）

| 序号 | 文件路径 | 是否已读 | 关键结论摘要 |
|------|----------|----------|--------------|
| 9 | `/root/wiki/20-resources/agentic-data-warehouse-100-source-research.md` | ✅ 已读 | 147源研究完成（超100目标）；核心结论：Agent协同需编排层(LangGraph/CrewAI)、GitHub Issue是最佳任务总线、dbt是现代化数仓核心、渐进式重构(Strangler Fig)是首选策略、语义层是AI读数安全边界 |
| 10 | `/root/wiki/20-resources/four-node-runtime-inventory.md` | ✅ 已读 | 四机资产全貌：150全组件在线、111 ICMP可达但SSH认证失败、184 Debian在线但无应用服务、Windows SSH不可达；关键风险：111遗留服务状态未知、Windows出口阻断、PocketClaw触发频率异常 |
| 11 | `/root/wiki/20-resources/runtime-governor-report.md` | ✅ 已读 | Runtime巡检：active 3个、review 6个、done 12个；review_ready 5个待用户验收；LEE-30 Windows D盘摸排报告未确认；inbox_loop heartbeat未写入；建议归档LEE-23测试任务 |
| 12 | `/root/wiki/20-resources/agent-role-operating-model.md` | ✅ 缺失 | 文件不存在（任务TASK-20260510-010指定输出路径，但尚未生成） |

### 1.3 任务文件（active/done，11份）

| 序号 | 文件路径 | 状态 | 关键结论摘要 |
|------|----------|------|--------------|
| 13 | `/root/wiki/tasks/active/TASK-20260510-005-warehouse-rebuild-full-inventory.md` | ✅ active | 本任务定义：数仓重构前全量摸排与资料通读，目标建立重构前基线 |
| 14 | `/root/wiki/tasks/active/TASK-20260510-006-windows-d-drive-inventory-extension.md` | ✅ active | Windows D盘数仓与Agent相关文件摸排，数据专家执行中 |
| 15 | `/root/wiki/tasks/active/TASK-20260510-007-windows-c-drive-inventory-and-migration-plan.md` | ✅ active | Windows C盘部署物摸排与迁移到D盘方案，数据专家执行中 |
| 16 | `/root/wiki/tasks/active/TASK-20260510-008-four-node-runtime-inventory.md` | ✅ active | 四台机器运行资产摸排，深度研究智能体执行中 |
| 17 | `/root/wiki/tasks/active/TASK-20260510-009-warehouse-rebuild-due-diligence-checklist.md` | ✅ active | 数仓重构前终极尽调清单，深度研究智能体执行中 |
| 18 | `/root/wiki/tasks/active/TASK-20260510-010-agent-role-assessment-and-operating-model.md` | ✅ active | 三类Agent角色摸底与协同规范，深度研究智能体执行中 |
| 19 | `/root/wiki/tasks/active/TASK-20260510-011-agentic-data-warehouse-100-source-research.md` | ✅ active | 100源研究任务，深度研究智能体执行中 |
| 20 | `/root/wiki/tasks/done/TASK-20260510-001-agent-collaboration-hardening.md` | ✅ done | Agent协同机制加固完成，GitHub任务总线打通验证通过 |
| 21 | `/root/wiki/tasks/done/TASK-20260510-002-system-full-picture-inventory.md` | ✅ done | 全局系统全貌盘点完成，产出system-runtime-overview.md |
| 22 | `/root/wiki/tasks/done/TASK-20260510-003-loop-heartbeat-to-github.md` | ✅ done | heartbeat机制建立，inbox/review loop可观测 |
| 23 | `/root/wiki/tasks/done/TASK-20260510-004-review-loop-warning-triage.md` | ✅ done | review loop warning分诊完成 |

### 1.4 缺失文件

| 文件路径 | 状态 | 说明 |
|----------|------|------|
| `/root/wiki/20-resources/agent-role-operating-model.md` | ❌ 缺失 | TASK-20260510-010产出，尚未生成 |
| `/root/wiki/20-resources/windows-d-drive-inventory.md` | ❌ 缺失 | TASK-20260510-006产出，数据专家Windows本地执行中 |
| `/root/wiki/20-resources/windows-c-drive-inventory-and-migration-plan.md` | ❌ 缺失 | TASK-20260510-007产出，数据专家Windows本地执行中 |

---

## 002 当前数仓全貌

### 2.1 数据库/Schema

| Schema | 表数 | 用途 |
|--------|------|------|
| `da_dw` | 约400+ | 数仓主库（ODS/DWD/ADS/DIM） |
| `da_dolphin` | 67 | DolphinScheduler调度元数据 |
| `da_datax` | 12 | DataX同步元数据 |

### 2.2 分层与表族

| 分层 | 表数 | 说明 |
|------|------|------|
| ODS | 156 | 贴源同步，含aps_prd(4.4亿行)、mes、wms等 |
| DWD | 64 | 明细数据层 |
| ADS | 174 | 应用数据层，按主题域分类 |
| DIM | 4 | 维度表 |
| DWS | 缺失 | 汇总层未建设，元数据空心化 |

### 2.3 核心链路

- **ADS_SC_XL_13**：用户熟悉、历史问题多、适合作为样板链路
- **ads_gx_xs_***：数据质量治理样板，38张表已摸排
- **aps_prd双轨**：老库4.4亿行 + 新库aps_prd_20250621(1979万行)

---

## 003 当前调度全貌（DolphinScheduler）

| 项 | 已知事实 |
|----|----------|
| 调度库 | `da_dolphin`，67张表 |
| release_state=0 | 存在工作流下线导致调度不触发（LEE-14根因） |
| 空表问题 | 表建好但未配置ETL调度（LEE-13根因） |
| cron示例 | `0 3/5 * * * ? *`（每5分钟） |
| 缺口 | 工作流完整清单未输出、release_state分布未统计、依赖关系未图谱化 |

---

## 004 当前同步全貌（DataX）

| 项 | 已知事实 |
|----|----------|
| 同步库 | `da_datax`，12张表 |
| 增量机制 | `etl_update_queue`(568万行) + `dwd_update_tracker_v2` |
| 历史问题 | create_time近30天同步问题 |
| 风险 | 物理删除处理方式未确认、晚到数据未量化、同步窗口漏数未评估 |

---

## 005 当前重点链路

### 5.1 ADS_SC_XL_13
- 推荐为第一条样板链路
- 重点表：`ads_sc_xl_13_defined_manuf_line_name_combined_002`
- 上下游链路基础已存在，适合验证ODS/DWD/ADS重构方法

### 5.2 ads_gx_xs_* 数据质量链路
- 38张表已摸排
- P0风险2张、P1风险4张、P2风险2张、P3风险30张
- 36张表无PK
- 适合验证空表/陈旧表/调度排查SOP

---

## 006 已确认问题清单（P0/P1/P2）

### P0（阻断重构）
| 问题 | 根因 | 状态 |
|------|------|------|
| Windows PC SSH不可达 | 所有数据任务阻断 | ❌ 未解决 |
| 验收标准未定义 | 无法判定重构成功 | ❌ 未定义 |
| 回滚方案未定义 | 重构失败无恢复手段 | ❌ 未定义 |

### P1（第一阶段前必须补清）
| 问题 | 根因 | 状态 |
|------|------|------|
| DataX同步策略未确认 | 增量/物理删除/晚到数据 | ⚠️ 部分已知 |
| DolphinScheduler工作流全景未输出 | 无法评估调度影响 | ⚠️ 部分已知 |
| ADS表消费端依赖未梳理 | 重构可能导致报表断裂 | ❌ 未梳理 |
| 源系统物理删除/晚到数据策略未确认 | ODS完整性风险 | ❌ 未确认 |
| 开发与发布SOP未建立 | 无灰度/回滚/比对流程 | ❌ 未建立 |

### P2（可边做边补）
| 问题 | 根因 | 状态 |
|------|------|------|
| 业务指标口径未文档化 | 重构后口径可能漂移 | ❌ 未文档化 |
| 血缘关系未完整追溯 | 元数据血缘表为空 | ❌ 未填充 |
| 数据质量持续监控未建立 | 问题发现滞后 | ❌ 未建立 |
| 大表性能与索引未盘点 | 重构后可能性能下降 | ❌ 未盘点 |
| 安全配置未全面扫描 | 明文密码泄露风险 | ⚠️ 部分处理 |
| 111服务器退役未完成 | 遗留服务可能干扰 | ⚠️ 退役中 |

---

## 007 重构前风险边界

### 绝对不能做的事情
1. 修改生产PolarDB（INSERT/UPDATE/DELETE/DROP/ALTER/TRUNCATE/CREATE）
2. 修改DolphinScheduler生产任务
3. 修改DataX生产配置
4. 自动上线新SQL/调度/同步
5. 自动重跑生产任务
6. 自动修复生产数据
7. 自动迁移C盘项目
8. 自动删除历史表或脚本
9. 跳过Windows沙箱验证直接上线
10. 没有回滚方案时启动重构

### 必须先做的事情
1. 恢复Windows PC可访问性
2. 定义验收标准
3. 定义回滚方案
4. 完成Dolphin/DataX全景摸排
5. 梳理ADS消费端依赖

---

## 008 第一阶段重构建议

### 建议第一批重构对象（低风险、高价值）

| 优先级 | 对象 | 理由 | 风险 |
|--------|------|------|------|
| 1 | ads_gx_xs_25_01 | 空表，根因明确（未配ETL），配置调度即可恢复 | 低 |
| 2 | ads_gx_xs_17_detail | 陈旧290天，根因明确（工作流下线），上线即可恢复 | 低 |
| 3 | ads_gx_xs_18_06_process1 | P1风险，滞后9个月，需排查调度状态 | 中 |
| 4 | ads_gx_xs_18_01_01 | P1风险，滞后4个月，需排查增量条件 | 中 |
| 5 | 元数据治理表填充 | 血缘/DQ/指标定义表结构已搭建但数据为空 | 低 |

### 不建议第一批动的对象
- `aps_prd` → ODS全量重构（4.4亿行大表，风险极高）
- 100+字段宽表（字段极多，业务影响面广）
- 涉及APS双轨切换的链路（切换时机未到）
- 无PK的36张表补主键（需业务确认唯一键）

---

## 009 待确认问题

1. Windows PC当前实际状态？（SSH认证失败，需修复或替代通道）
2. 111遗留服务是否仍在运行？（无法SSH验证）
3. 用户是否确认ADS_SC_XL_13作为第一条样板链路？
4. DataX增量策略和物理删除处理方式需与运维确认
5. DolphinScheduler工作流全景清单需Windows智能体执行
6. ADS表消费端依赖图谱需业务确认
7. 验收标准和回滚方案需用户评审

---

## 010 结论

**当前重构状态：Conditional Go（有条件启动）**

- ✅ 数仓分层架构清晰
- ✅ 数据质量摸排方法论已建立
- ✅ Agent协同链路已打通
- ✅ 100源研究完成，技术路径明确
- ❌ Windows节点不可达（P0阻断）
- ❌ 验收标准未定义（P0阻断）
- ❌ 回滚方案未定义（P0阻断）
- ❌ 10项准入门槛满足0/10

**最优主线：**
```
全貌摸排（进行中）
→ 恢复Windows可访问性（P0）
→ Windows测试环境治理
→ AI智能体工作模式固化
→ ADS_SC_XL_13样板链路
→ dbt模型与速程监控验证
→ 新旧比对
→ 人工决策生产改造
→ AI辅助读数
```

**本报告为只读摸排，未修改任何系统。**
