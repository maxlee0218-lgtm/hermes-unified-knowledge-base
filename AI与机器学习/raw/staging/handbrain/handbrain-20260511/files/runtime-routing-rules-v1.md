# Runtime首脑 简化调度机制 v1.0

## 1. 现状诊断

### 1.1 当前任务分布（截至 2026-05-11）

| 状态 | 数量 | 关键Issue |
|------|------|-----------|
| todo | 0 | - |
| in_progress | 2 | LEE-59 (test-agent), LEE-57 (PocketClaw REVIEW LOOP修复) |
| in_review | 0 | - |
| blocked | 3 | LEE-62 (本任务), LEE-61 (测试中间层), LEE-58 (Windows C盘迁移) |
| done | 32+ | 历史已完成 |

### 1.2 超时根因分析

**直接原因：**
- Runtime首脑被直接分配业务任务（LEE-62），而非Runtime专属任务（[Runtime Patrol]/[Runtime Closeout]/[Runtime Maintenance]）
- Runtime首脑instructions中明确禁止执行业务任务，但任务创建者未遵循此规则
- 导致Runtime首脑陷入"接收任务→判断不能执行→尝试路由→超时"的循环

**系统性原因：**
1. **任务入口无过滤**：用户/中间层可直接向Runtime首脑分配业务任务，绕过路由层
2. **Runtime职责边界未在创建端强制执行**：任务创建时无校验机制确保Runtime只接收Runtime专属任务
3. **超时后无降级预案**：Runtime卡住时，没有自动转派或降级机制
4. **in_review队列为空**：验收环节未形成持续运转，导致完成闭环断裂

## 2. 简化调度规则

### 2.1 核心原则：三层防御

```
第一层：入口过滤（创建时）
├── 任务标题必须以 [Runtime Patrol] / [Runtime Closeout] / [Runtime Maintenance] 开头
├── 或任务明确标记 type: runtime-only
└── 不符合 → 自动拒绝并路由到正确Agent

第二层：Runtime自检（执行时）
├── 收到任务 → 先判断issue_type
├── 非Runtime任务 → 立即路由，不进入业务分析
└── 路由失败 → 标记blocked + next_command_or_decision

第三层：贾维斯兜底（超时后）
├── Runtime超过10分钟无响应 → 贾维斯接管
├── 贾维斯直接协调各Agent，跳过Runtime路由
└── 事后补Runtime规则更新
```

### 2.2 路由矩阵（简化版）

| 任务类型 | 目标Agent | 判断关键词 |
|----------|-----------|-----------|
| 研究/架构/规划/Wiki | 研究与架构官 | research, architecture, plan, wiki, standard, methodology |
| SQL/数据质量/沙箱/表根因 | 数据开发专家 | SQL, data quality, sandbox, table, root cause, PolarDB |
| Windows/Linux资产/服务/工具链 | 运维/资产管家 | Windows, Linux, C盘, D盘, service, install, toolchain |
| Runtime流程/状态/收口 | Runtime首脑 | [Runtime Patrol], [Runtime Closeout], [Runtime Maintenance] |
| 验收/审计/verdict | 验收官/审计官 | review, audit, validate, in_review |
| 数仓调度/ODS/DWD/ADS（暂停中） | 数仓运行管家-暂停重建 | warehouse, Dolphin, DataX, ODS, DWD, ADS |

### 2.3 快速决策树

```
收到新任务
├── 标题含 [Runtime *]?
│   ├── 是 → Runtime处理
│   └── 否 → 继续判断
├── 描述含 "Runtime" 且是流程任务?
│   ├── 是 → Runtime处理
│   └── 否 → 继续判断
├── 是业务任务?
│   ├── 是 → 按路由矩阵分派
│   └── 否 → 标记blocked，写next_command_or_decision
└── 路由失败?
    ├── 是 → 标记blocked，写原因
    └── 否 → 完成分派
```

### 2.4 超时降级规则

| 场景 | 超时阈值 | 降级动作 |
|------|----------|----------|
| Runtime无响应 | 10分钟 | 贾维斯接管，直接协调Agent |
| in_review超30分钟 | 30分钟 | Runtime强制转blocked |
| in_review超60分钟+需用户决策 | 60分钟 | 必须转blocked |
| Agent执行超时 | 任务级timeout | Runtime标记blocked，写next_command |

## 3. 立即执行动作

### 3.1 当前blocked任务处理

| Issue | 当前状态 | 建议动作 |
|-------|----------|----------|
| LEE-62 | blocked | **本任务**：贾维斯已接管，输出调度规则后，建议标记done或转给研究与架构官沉淀为Wiki |
| LEE-61 | blocked | 测试任务，建议取消或标记done |
| LEE-58 | blocked | Windows C盘迁移，应转派给运维/资产管家 |

### 3.2 in_progress任务监控

| Issue | 负责Agent | 状态 |
|-------|-----------|------|
| LEE-59 | 研究与架构官 | test-agent，建议尽快完成或取消 |
| LEE-57 | 研究与架构官 | PocketClaw修复，高优先级，持续监控 |

### 3.3 建立调度规则文件

建议将本规则沉淀到Wiki/GitHub：
- 路径：`/root/wiki/20-resources/runtime-routing-rules-v1.md`
- 同步到GitHub：`llm-wiki/runtime-routing-rules-v1.md`

## 4. 验收标准

- [x] 任务堆积原因已分析
- [x] 调度规则已建立（三层防御+简化路由矩阵+决策树+超时降级）
- [ ] 规则文件已落盘（建议由研究与架构官执行）
- [ ] blocked任务已重新分派（LEE-58需转派）
- [ ] in_progress任务持续监控中

## 5. 下一步建议

1. **立即**：将LEE-58转派给运维/资产管家，解除blocked
2. **短期**：由研究与架构官将本规则沉淀为Wiki正式文档
3. **中期**：在任务创建入口增加Runtime过滤校验（如GitHub command file中增加type字段校验）
4. **长期**：建立Runtime autopilot，每5分钟自动巡检任务状态，自动触发降级

---

生成时间：2026-05-11
生成Agent：Runtime首脑（被贾维斯接管后输出）
版本：v1.0
