# PocketClaw Loop Heartbeat 机制

> 版本: v1.0  
> 创建: 2026-05-10  
> 关联任务: [LEE-27](mention://issue/f7d9725a-02de-430a-9a8d-2f2b1b223695)  
> 目的: 让 ChatGPT 能从 GitHub 侧判断两个 PocketClaw 定时 loop 是否活着

---

## 1. 文件位置

| 文件 | 路径 | 说明 |
|------|------|------|
| heartbeat.json | `/root/wiki/tasks/status/heartbeat.json` | 统一心跳文件 |
| heartbeat_update.sh | `/root/wiki/tasks/heartbeat_update.sh` | 更新工具（含文件锁） |
| heartbeat_sync.sh | `/root/wiki/tasks/heartbeat_sync.sh` | GitHub 同步脚本 |
| inbox loop | `/root/wiki/tasks/task_inbox_check.sh` | 10分钟 inbox 检查 |
| review loop | `/root/wiki/tasks/task_review_check.sh` | 5分钟 review 巡检 |

---

## 2. heartbeat.json 格式

```json
{
  "schema_version": "1.0",
  "updated_at": "2026-05-10 07:59:17+0800",
  "inbox_loop": {
    "last_run": "2026-05-10 07:59:03+0800",
    "status": "ok",
    "last_log_summary": "no new task",
    "last_issue_created": "LEE-99",
    "tasks_processed": 1,
    "errors": 0
  },
  "review_loop": {
    "last_run": "2026-05-10 07:59:17+0800",
    "status": "warning",
    "last_log_summary": "issues found",
    "issues_found": 2,
    "running_timeout": 0,
    "review_backlog": 1,
    "blocked_failed": 1,
    "github_pending": 0,
    "errors": 0
  },
  "mode": "limited_formal_run",
  "forbidden_actions_enforced": true,
  "github_sync": {
    "last_sync": "2026-05-10 07:58:19+0800",
    "sync_interval_min": 30,
    "pending_sync": false,
    "commit_id": "fc11f24"
  }
}
```

### 字段说明

- `updated_at`: 整个 heartbeat 的最后更新时间
- `inbox_loop.last_run`: inbox loop 最近一次执行时间
- `inbox_loop.status`: `ok` / `warning` / `error` / `running` / `unknown`
- `inbox_loop.tasks_processed`: 本次处理的新任务数
- `review_loop.issues_found`: review loop 发现的问题类别数
- `review_loop.blocked_failed`: BLOCKED/FAILED issue 数量
- `mode`: 当前运行模式，固定为 `limited_formal_run`
- `forbidden_actions_enforced`: 禁止动作是否生效
- `github_sync.commit_id`: 最近一次成功同步的 commit

---

## 3. 更新机制

### 3.1 并发安全

两个 loop 分别每 10 分钟和每 5 分钟运行，存在并发写同一个文件的风险。

**解决方案**: `heartbeat_update.sh` 使用 Linux `flock` 文件锁：

```bash
exec 200>"$LOCK_FILE"
flock -w 5 200
# ... 安全读写 ...
exec 200>&-
```

- 超时等待 5 秒，获取不到锁则跳过本次更新
- 原子写：先写 `.tmp` 文件，再 `mv` 替换

### 3.2 调用方式

**inbox loop** 在以下时机调用：
1. 脚本开始时: `heartbeat_update.sh inbox "running" "inbox scan started"`
2. 创建 issue 成功时: `heartbeat_update.sh inbox "ok" "issue created" "LEE-xxx"`
3. 脚本结束时（无新任务）: `heartbeat_update.sh inbox "ok" "no new task"`

**review loop** 在以下时机调用：
1. 脚本开始时: `heartbeat_update.sh review "running" "review scan started" 0 0 0 0 0 0`
2. 脚本结束时: 汇总所有计数器一次性更新

---

## 4. GitHub 同步机制

### 4.1 核心原则

> **不要每 5 分钟都 push。**

- 本地每次 loop 运行都更新 `heartbeat.json`
- GitHub 同步由独立脚本 `heartbeat_sync.sh` 控制
- 默认每 **30 分钟** 或 heartbeat 内容变化时才 commit/push

### 4.2 同步策略

| 条件 | 行为 |
|------|------|
| heartbeat.json 无变化 | 跳过 |
| remote 不可达 | 跳过，记录日志 |
| 有变化且 remote 可达 | pull --ff-only → add → commit → push |
| commit 成功 | 更新 heartbeat 中的 `github_sync.commit_id` |

### 4.3 cron 配置建议

```bash
# 添加到 crontab
*/30 * * * * bash /root/wiki/tasks/heartbeat_sync.sh >> /root/wiki/tasks/logs/heartbeat_sync.log 2>&1
```

### 4.4 安全边界

- ❌ 禁止 `force push`
- ❌ 禁止删除历史 commit
- ❌ heartbeat.json 不包含密钥、token、数据库连接信息
- ✅ 只同步 `tasks/status/heartbeat.json` 单个文件
- ✅ commit message 明确标记 `[auto-sync]`

---

## 5. ChatGPT 如何读取

ChatGPT 可通过 GitHub raw URL 直接读取：

```
https://raw.githubusercontent.com/maxlee0218-lgtm/llm-wiki/main/tasks/status/heartbeat.json
```

判断逻辑示例：

```python
import json, requests, datetime

url = "https://raw.githubusercontent.com/maxlee0218-lgtm/llm-wiki/main/tasks/status/heartbeat.json"
hb = requests.get(url).json()

now = datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=8)))
inbox_last = datetime.datetime.fromisoformat(hb['inbox_loop']['last_run'])
review_last = datetime.datetime.fromisoformat(hb['review_loop']['last_run'])

# 判断 loop 是否活着（15分钟内）
inbox_alive = (now - inbox_last).total_seconds() < 15 * 60
review_alive = (now - review_last).total_seconds() < 15 * 60

print(f"inbox loop: {'活着' if inbox_alive else '可能卡死'} ({hb['inbox_loop']['status']})")
print(f"review loop: {'活着' if review_alive else '可能卡死'} ({hb['review_loop']['status']})")
print(f"mode: {hb['mode']}, forbidden enforced: {hb['forbidden_actions_enforced']}")
```

---

## 6. 运行模式与边界

本 heartbeat 机制遵循 **limited_formal_run** 模式：

- 只增加观测能力，不扩大自动化执行范围
- 不改变 inbox loop / review loop 的执行边界
- 不自动恢复、不自动 retry、不自动 restart
- 所有生产动作仍需主脑确认

---

## 7. 变更记录

| 日期 | 版本 | 变更 |
|------|------|------|
| 2026-05-10 | v1.0 | 初始实现，含 flock 并发锁、30分钟 debounced sync |

---

> 最新 commit: `fc11f24829787bf6522f49cc68e49df8bbac3ae9`
