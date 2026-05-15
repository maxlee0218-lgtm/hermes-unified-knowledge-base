# Agent 协同机制运行规范

> title: Agent 协同机制运行规范
> created: 2026-05-10
> updated: 2026-05-10
> stage: 正式运行
> type: 运行基线
> tags: [Agent协同, 任务分配, Multica, PocketClaw]
> status: active
> sources: [GitHub任务总线打通验证报告]

---

## 一、协同链路

```
ChatGPT 写任务文件
  → 推送到 GitHub
    → PocketClaw 定时扫描 / 手动触发
      → 执行 task_inbox_check.sh
        → git pull 同步到本地
          → 识别 inbox 新任务
            → 边界校验（allowed/forbidden actions）
              → Agent 名称校验
                → 创建 Multica Issue
                  → 生成 status json
                    → 移动到 active
                      → 指派 Agent 执行
                        → REVIEW / DONE
                          → LLM Wiki / GitHub 沉淀
```

---

## 二、Agent 分配规则

### 2.1 必须使用已注册 Agent

**⚠️ 重要更新（2026-05-10）：**

当前 Multica 唯一有效的 Agent 名称：

| Agent 名称 | 状态 | 说明 |
|-----------|------|------|
| 研究与架构官 | ✅ 有效 | 当前唯一可用 Agent |

**历史 Agent 名称（已失效）：**

| Agent 名称 | 状态 | 说明 |
|-----------|------|------|
| 数据专家 | ❌ 无效 | Multica 不再识别 |
| 数仓管家 | ❌ 无效 | Multica 不再识别 |
| 深度研究智能体 | ❌ 无效 | Multica 不再识别 |

### 2.2 禁止使用的名称

**以下名称不能作为 target_agent / assignee：**

| 禁止名称 | 原因 |
|----------|------|
| 主脑 | 是调度者，不是执行 Agent |
| OpenClaw | 是控制面，不是 Agent |
| ChatGPT | 是模型，不是 Agent |
| 数据专家 | ❌ Multica 不识别 |
| 数仓管家 | ❌ Multica 不识别 |
| 深度研究智能体 | ❌ Multica 不识别 |
| 自定义未注册名称 | Multica 无法识别 |

### 2.3 默认分配规则

```yaml
# 任务类型 → 默认 Agent（当前统一指派）
PLAN / REVIEW / KNOWLEDGE → 研究与架构官
DATA / SANDBOX / SQL → 研究与架构官
WAREHOUSE / 调度 / 链路排查 → 研究与架构官
# 注意：当前所有任务统一指派给 研究与架构官
```

---

## 三、任务文件规范

### 3.1 必填字段

```yaml
---
task_id: TASK-YYYYMMDD-NNN-描述
title: "任务标题"
# target_agent 规则：
# - PLAN / REVIEW / KNOWLEDGE → 深度研究智能体
# - DATA / SANDBOX / SQL → 数据专家
# - WAREHOUSE / 调度 / 链路排查 → 数仓管家
# 禁止使用：主脑、OpenClaw、ChatGPT、自定义未注册名称
target_agent: "数据专家"  # 必须是已注册 Agent
objective: "任务目标描述"
allowed_actions:
  - 允许的动作1
  - 允许的动作2
forbidden_actions:
  - 禁止的动作1
  - 禁止的动作2
acceptance_criteria:
  - 验收标准1
  - 验收标准2
---
```

### 3.2 文件存放位置

| 状态 | 路径 |
|------|------|
| 待处理 | `/root/wiki/tasks/inbox/` |
| 执行中 | `/root/wiki/tasks/active/` |
| 审核中 | `/root/wiki/tasks/review/` |
| 已完成 | `/root/wiki/tasks/done/` |
| 已归档 | `/root/wiki/tasks/archived/` |
| 状态记录 | `/root/wiki/tasks/status/` |

---

## 四、安全边界

### 4.1 禁止自动执行

- ❌ 修改生产数据库
- ❌ 修改 PolarDB
- ❌ 修改 DolphinScheduler 生产任务
- ❌ 修改 DataX 生产配置
- ❌ 自动恢复服务
- ❌ 自动上线
- ❌ 修改密钥/token/白名单
- ❌ force push
- ❌ 删除历史任务或报告
- ❌ 创建生产变更任务

### 4.2 允许执行

- ✅ 读取 GitHub 本地同步内容
- ✅ 检查 tasks 目录状态
- ✅ 检查 PocketClaw 触发日志
- ✅ 检查 task_inbox_check.sh 执行状态
- ✅ 检查 Multica Issue 创建状态
- ✅ 输出协同机制加固报告
- ✅ 更新 LLM Wiki 和 GitHub

---

## 五、触发机制

### 5.1 PocketClaw 定时触发

| 配置项 | 值 |
|--------|-----|
| 定时名称 | 任务inbox检查 |
| 执行命令 | `bash /root/wiki/tasks/task_inbox_check.sh` |
| 执行频率 | 每 10 分钟 |
| 执行环境 | 150服务器（Hermes） |
| 日志路径 | `/root/wiki/tasks/logs/task_inbox_watcher.log` |

### 5.2 手动触发

- PocketClaw 立即执行
- 或 SSH 到 150 服务器手动运行

---

## 六、验收标准

### 6.1 任务总线验收

| 检查项 | 标准 |
|--------|------|
| GitHub 同步 | `git pull` 能拉到最新 commit |
| 任务识别 | inbox 新任务被正确识别 |
| 边界校验 | allowed/forbidden actions 被校验 |
| Agent 校验 | target_agent 必须是已注册 Agent |
| Multica Issue | 自动创建 Issue 并指派 Agent |
| 状态生成 | 生成 status json 文件 |
| 任务移动 | 从 inbox 移动到 active |
| 安全边界 | 高风险任务不会自动执行 |

### 6.2 协同免转发验收

| 检查项 | 标准 |
|--------|------|
| 用户不转发 | ChatGPT 写 GitHub 后自动进入流程 |
| 主脑自动调度 | task_inbox_check.sh 自动执行 |
| Agent 自动执行 | Multica Issue 创建后 Agent 自动执行 |
| 结果自动沉淀 | 完成后自动更新 LLM Wiki / GitHub |

---

## 七、相关文件

| 文件 | 路径 |
|------|------|
| 任务模板 | `/root/wiki/tasks/inbox/task_template.md` |
| 运行基线 | `/root/wiki/tasks/RUNTIME_BASELINE.md` |
| 检查脚本 | `/root/wiki/tasks/task_inbox_check.sh` |
| 机制说明 | `/root/wiki/tasks/README.md` |
| 验收报告 | `/root/multica-work/output/20260510-GitHub任务总线打通验证报告.md` |

---

## 八、GitHub 记录

| 项目 | 值 |
|------|-----|
| 仓库 | `maxlee0218-lgtm/llm-wiki.git` |
| 任务 commit | `b22babae` |
| 验证 commit | `23418c6` |
| 规则更新 commit | 待记录 |

---

## 九、历史记录

| 时间 | 事件 |
|------|------|
| 2026-05-10 01:37:05 | PocketClaw 手动触发成功 |
| 2026-05-10 01:47:24 | PocketClaw 定时触发成功 |
| 2026-05-10 06:59:38 | GitHub 任务总线打通，LEE-24 创建成功 |
| 2026-05-10 06:59 | Agent 分配规则更新 |

---

## 十、结论

**Agent 协同机制：✅ 正式运行**

- ChatGPT → GitHub → PocketClaw → Multica → Agent 全链路打通
- Agent 分配规则明确
- 安全边界生效
- 用户不需要手动转发长文本

**下一阶段：**
- 观察 LEE-24 执行
- 持续优化规则
- 沉淀更多知识
