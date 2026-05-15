# PocketClaw 任务机制运行基线

> 生效时间：2026-05-10 北京时间 00:10
> 状态：有限正式运行
> 阶段：基础设施阶段结束，进入有限正式运行

---

## 一、运行配置

| 配置项 | 值 |
|--------|-----|
| 定时名称 | 任务inbox检查 |
| 执行命令 | `bash /root/wiki/tasks/task_inbox_check.sh` |
| 执行频率 | 每 10 分钟 |
| 执行环境 | 150服务器（Hermes） |
| 日志路径 | `/root/wiki/tasks/logs/task_inbox_watcher.log` |
| 状态目录 | `/root/wiki/tasks/status/` |

---

## 二、当前允许任务类型

第一阶段只允许处理以下类型任务：

| 类型 | 标识 | 说明 | 是否创建正式 Issue | 默认指派 Agent |
|------|------|------|-------------------|----------------|
| DRY-RUN | `dry_run: true` | 只验证，不创建真实任务 | 否（模拟创建） | - |
| TEST | `TASK-TEST-*` | 测试任务，无害验证 | **否（默认跳过）** | - |
| SANDBOX | `sandbox: true` | 本地沙箱验证 | 是 | 研究与架构官 |
| KNOWLEDGE | `knowledge: true` | 知识沉淀、学习吸收 | 是 | 研究与架构官 |
| PLAN | `plan: true` | 规划、架构、方法论 | 是 | 研究与架构官 |
| DATA | `data: true` | 数据分析、SQL、质量摸排 | 是 | 研究与架构官 |
| WAREHOUSE | `warehouse: true` | 数仓运维、调度、链路排查 | 是 | 研究与架构官 |

**⚠️ 注意：当前 Multica 只识别"研究与架构官"，所有任务统一指派。**

### Agent 分配规则

**必须使用 Multica 已注册 Agent 名称：**

| 任务类型 | 指派 Agent | 说明 |
|----------|-----------|------|
| PLAN / REVIEW / KNOWLEDGE | 深度研究智能体 | 规划、架构、方法论、学习吸收 |
| DATA / SANDBOX / SQL | 数据专家 | 数据分析、SQL、质量摸排、沙箱验证 |
| WAREHOUSE / 调度 / 链路排查 | 数仓管家 | 数仓运维、调度排查、链路检查 |

**禁止使用的 assignee：**
- ❌ `主脑`（不是 Agent，是调度者）
- ❌ `OpenClaw`（不是 Agent）
- ❌ `ChatGPT`（不是 Agent）
- ❌ 任何自定义未注册名称

**有效的 Agent 名称（严格匹配）：**
- ✅ `数据专家`
- ✅ `数仓管家`
- ✅ `深度研究智能体`

### TEST 任务特殊规则

- **默认行为**：TEST 任务（task_id 以 `TASK-TEST-` 开头）**不进入正式 Issue 创建**
- **存放位置**：`/root/wiki/tasks/test/`（而非 inbox）
- **触发方式**：手动执行 `DRY_RUN=1 bash /root/wiki/tasks/task_inbox_check.sh`
- **例外情况**：若 TEST 任务需要创建正式 Issue，必须在任务文件中显式声明 `allow_real_issue: true`

```yaml
# TEST 任务示例（不创建正式 Issue）
task_id: TASK-TEST-POCKETCLAW-001
allow_real_issue: false  # 默认，可省略

# 若需要创建正式 Issue（例外情况）
task_id: TASK-TEST-STRESS-001
allow_real_issue: true   # 显式声明
```

---

## 三、当前禁止动作

| 禁止项 | 说明 |
|--------|------|
| 自动创建生产变更任务 | 不允许自动创建影响生产的任务 |
| 自动修改数据库 | 不允许 INSERT/UPDATE/DELETE/DROP/ALTER |
| 自动上线 DolphinScheduler | 不允许自动修改生产调度 |
| 自动执行高风险动作 | 不允许自动修改生产配置、上线SQL |
| 跳过边界校验 | 所有任务必须定义 forbidden_actions |
| REVIEW未清理时无限创建 | REVIEW > 3 时暂停拉取 |

---

## 四、状态迁移规则

```
inbox (新任务)
  → task_inbox_check.sh 检查
  → 校验边界（必须定义 forbidden_actions）
  → 检查 REVIEW 阈值
  → 创建 Multica Issue
  → active (执行中)
    → Agent 执行
    → review (待验收)
      → 主脑验收
      → done (已完成)
        → 知识沉淀（LLM Wiki + GitHub）
        → archived (已归档)
```

### 异常流

```
RUNNING
  → BLOCKED（卡住/无日志/超时）
  → RETRY（重试，最多3次）
  → FAILED（失败，需人工介入）
```

---

## 五、REVIEW 阈值

| 阈值 | 动作 |
|------|------|
| REVIEW <= 3 | 正常拉取新任务 |
| REVIEW > 3 | 暂停拉取，优先验收 |

---

## 六、回滚方式

### 6.1 暂停机制

```bash
# 临时暂停（不删除配置）
# 在 PocketClaw 中禁用定时任务
```

### 6.2 紧急停止

```bash
# 创建停止标记文件
touch /root/wiki/tasks/PAUSE

# 脚本检测到 PAUSE 文件后自动退出
```

### 6.3 恢复运行

```bash
# 删除停止标记
rm /root/wiki/tasks/PAUSE
```

---

## 七、dry-run 使用方法

### 7.1 手动触发 dry-run

```bash
DRY_RUN=1 bash /root/wiki/tasks/task_inbox_check.sh
```

### 7.2 预期输出

```
[2026-05-10 00:04:58] 🔍 DRY_RUN 模式：只验证文件读取、状态迁移、日志记录
[2026-05-10 00:04:58] 📥 发现新任务: TASK-TEST-POCKETCLAW-001.md
[2026-05-10 00:04:58] ✅ 边界校验通过
[2026-05-10 00:04:58] 🔍 DRY_RUN: 模拟创建 Multica Issue
[2026-05-10 00:04:58] ✅ DRY_RUN: 模拟成功: DRY-RUN-TEST
[2026-05-10 00:04:58] 📂 DRY_RUN: 任务保留在 inbox
[2026-05-10 00:04:58] ✅ DRY_RUN: 测试任务验证完成
```

### 7.3 验证标准

- [ ] 日志写入成功
- [ ] 状态文件生成
- [ ] 不创建真实 Multica Issue
- [ ] 任务保留在 inbox

---

## 八、回归测试任务

| 任务 | 用途 | 状态 |
|------|------|------|
| TASK-TEST-POCKETCLAW-001 | 回归测试，验证机制完整性 | 保留在 inbox |

---

## 九、监控与告警

### 9.1 日志检查

```bash
# 查看最新日志
tail -20 /root/wiki/tasks/logs/task_inbox_watcher.log
```

### 9.2 状态检查

```bash
# 查看所有任务状态
ls -la /root/wiki/tasks/status/
```

### 9.3 异常判断

| 异常 | 标志 | 处理 |
|------|------|------|
| 脚本执行失败 | 退出码非0 | 检查日志，修复后重试 |
| Multica 创建失败 | `❌ Multica Issue 创建失败` | 检查 multica daemon |
| 边界校验失败 | `❌ 边界校验失败` | 补充 forbidden_actions |
| REVIEW 堆积 | `⚠️ REVIEW 任务超过阈值` | 优先验收 REVIEW |

---

## 十、合规声明

- 本机制只创建任务，不直接执行
- 所有执行由 Multica Agent 完成
- 不动生产，不改配置
- 禁止动作由任务文件定义，脚本自动校验
- 知识沉淀到 LLM Wiki 和 GitHub

---

## 十一、更新记录

| 时间 | 更新内容 | 更新者 |
|------|---------|--------|
| 2026-05-10 | 初始创建，有限正式运行基线 | 首脑 |

---

## 十二、当前状态

- ✅ 基础设施：已完成
- ✅ dry-run 测试：已通过
- ⏳ 有限正式运行：已启用
- 📋 允许任务类型：DRY-RUN / TEST / SANDBOX / KNOWLEDGE
- 🚫 禁止：生产变更 / 数据库修改 / 自动上线
