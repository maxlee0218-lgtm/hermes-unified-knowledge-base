# PocketClaw 定时拉取任务机制

> 本目录为 PocketClaw 定时任务入口，用于自动从 inbox 拉取新任务并创建 Multica Issue。
> 由用户手工在 PocketClaw 中配置定时任务。

---

## 目录结构

```
/root/wiki/tasks/
├── inbox/          # 新任务入口（放置 .md 任务文件）
├── active/         # 执行中任务
├── review/         # 待验收任务
├── done/           # 已完成任务
├── archived/       # 已归档任务
├── status/         # 任务状态文件（JSON）
├── logs/           # 执行日志
├── task_template.md # 任务模板
├── task_inbox_check.sh # 检查脚本
└── README.md       # 本文件
```

---

## 使用方式

### 1. 创建新任务

复制模板：
```bash
cp /root/wiki/tasks/inbox/task_template.md /root/wiki/tasks/inbox/TASK-20260509-001.md
```

编辑任务文件，填写：
- task_id
- title
- target_agent
- objective
- allowed_actions
- forbidden_actions
- acceptance_criteria
- output_paths
- timeout_minutes

### 2. PocketClaw 定时配置

在 PocketClaw 中配置定时任务：

| 配置项 | 值 |
|--------|-----|
| 定时名称 | 任务inbox检查 |
| 执行命令 | `bash /root/wiki/tasks/task_inbox_check.sh` |
| 建议频率 | 每 10 分钟 |
| 日志路径 | `/root/wiki/tasks/logs/task_inbox_watcher.log` |

### 3. 成功判断

- 日志中出现 `✅ Multica Issue 创建成功: LEE-XX`
- 任务文件从 inbox 移动到 active
- status 目录生成 `${task_id}.json`

### 4. 失败判断

- 日志中出现 `❌ 边界校验失败`
- 或 `❌ Multica Issue 创建失败`
- 任务文件保留在 inbox

---

## 任务生命周期

```
inbox (新任务)
  → task_inbox_check.sh 检查
  → 校验边界
  → 创建 Multica Issue
  → active (执行中)
    → Agent 执行
    → review (待验收)
      → 主脑验收
      → done (已完成)
        → 知识沉淀
        → archived (已归档)
```

---

## 安全规则

- REVIEW 任务 > 3 时，暂停拉取新任务
- 禁止重复创建同一个任务
- 禁止跳过边界校验
- 禁止直接改生产
- 禁止没有验收就归档

---

## 状态文件格式

`/root/wiki/tasks/status/${task_id}.json`：

```json
{
  "task_id": "TASK-20260509-001",
  "task_file": "TASK-20260509-001.md",
  "multica_issue": "LEE-25",
  "status": "active",
  "created_at": "2026-05-09 23:55:00",
  "agent": "数据专家",
  "log_file": "/root/wiki/tasks/logs/task_inbox_watcher.log"
}
```

---

## 日志格式

`/root/wiki/tasks/logs/task_inbox_watcher.log`：

```
[2026-05-09 23:55:00] === 开始检查 inbox ===
[2026-05-09 23:55:00] 当前 REVIEW 任务数量: 2
[2026-05-09 23:55:01] 📥 发现新任务: TASK-20260509-001.md
[2026-05-09 23:55:01] ✅ 边界校验通过
[2026-05-09 23:55:03] 🚀 创建 Multica Issue...
[2026-05-09 23:55:05] ✅ Multica Issue 创建成功: LEE-25
[2026-05-09 23:55:05] 📂 任务已移动到 active
[2026-05-09 23:55:05] === 检查结束 ===
```

---

## 维护说明

- 定期清理 logs 目录（保留最近30天）
- 定期归档 archived 目录（保留最近90天）
- 任务模板更新后，需同步到 inbox

---

## 合规声明

- 本机制只创建任务，不直接执行
- 所有执行由 Multica Agent 完成
- 不动生产，不改配置
- 知识沉淀到 LLM Wiki 和 GitHub
