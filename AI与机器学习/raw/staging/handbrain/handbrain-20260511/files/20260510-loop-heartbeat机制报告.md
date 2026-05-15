# PocketClaw Loop Heartbeat 机制报告

> 任务: LEE-27 — 为 inbox loop / review loop 增加 GitHub 可见 heartbeat  
> 执行时间: 2026-05-10 08:00+08:00  
> 执行智能体: 深度研究智能体  
> 执行机器: 150.242.81.21

---

## 1. 执行摘要

✅ 已完成 heartbeat 机制设计与实现，包含：
- 统一 heartbeat.json 文件
- 并发安全的更新工具（flock 文件锁）
- 30 分钟 debounced GitHub 同步脚本
- 两个 loop 的 heartbeat 注入
- Wiki 文档与机制报告
- GitHub 推送完成，commit id 已记录

---

## 2. 设计决策

### 2.1 是否由两个脚本分别更新同一个 heartbeat 文件？

**是。** 统一文件便于 ChatGPT 从 GitHub 单点读取。通过 `flock` 文件锁解决并发写冲突。

### 2.2 是否需要文件锁？

**需要。** inbox loop 每 10 分钟、review loop 每 5 分钟运行，存在时间重叠可能。

- 使用 Linux `flock` 实现
- 超时等待 5 秒，获取不到则跳过
- 原子写：`.tmp` → `mv` 替换

### 2.3 是否每次运行都 git commit/push？

**否。** 优先策略：
- 本地每次 loop 运行都更新 heartbeat.json
- GitHub 同步由独立 `heartbeat_sync.sh` 控制
- 默认每 30 分钟或内容变化时才 commit/push

### 2.4 如何避免 5 分钟一次 push 造成 GitHub 噪声？

- 独立 sync 脚本，不绑定到 loop 执行
- 检查文件是否有变化，无变化跳过
- 检查 remote 是否可达，不可达跳过
- commit message 标记 `[auto-sync]`

### 2.5 最推荐的最小方案？

当前实现即为最小方案：
1. `heartbeat.json` — 单文件统一状态
2. `heartbeat_update.sh` — flock 安全更新
3. `heartbeat_sync.sh` — 30 分钟 debounced 同步
4. loop 脚本注入 2-3 行调用代码
5. cron 配置 `*/30 * * * *` 调用 sync 脚本

---

## 3. 文件清单

| 文件 | 路径 | 说明 |
|------|------|------|
| heartbeat.json | `/root/wiki/tasks/status/heartbeat.json` | 统一心跳文件 |
| heartbeat_update.sh | `/root/wiki/tasks/heartbeat_update.sh` | 更新工具（含 flock） |
| heartbeat_sync.sh | `/root/wiki/tasks/heartbeat_sync.sh` | GitHub 同步脚本 |
| task_inbox_check.sh | `/root/wiki/tasks/task_inbox_check.sh` | 已注入 heartbeat 调用 |
| task_review_check.sh | `/root/wiki/tasks/task_review_check.sh` | 已注入 heartbeat 调用 |
| pocketclaw-loop-heartbeat.md | `/root/wiki/20-resources/pocketclaw-loop-heartbeat.md` | Wiki 文档 |
| 本报告 | `/root/multica-work/output/20260510-loop-heartbeat机制报告.md` | 机制报告 |

---

## 4. GitHub 同步状态

- **仓库**: `maxlee0218-lgtm/llm-wiki`
- **分支**: `main`
- **commit id**: `fc11f24829787bf6522f49cc68e49df8bbac3ae9`
- **推送时间**: 2026-05-10 07:59:30+08:00
- **同步文件**: `tasks/status/heartbeat.json`

ChatGPT 可直接读取：
```
https://raw.githubusercontent.com/maxlee0218-lgtm/llm-wiki/main/tasks/status/heartbeat.json
```

---

## 5. 安全边界检查

| 检查项 | 状态 |
|--------|------|
| heartbeat.json 不含密钥/token | ✅ 通过 |
| heartbeat.json 不含数据库信息 | ✅ 通过 |
| 不修改 loop 执行边界 | ✅ 通过 |
| 不自动恢复/ retry/ restart | ✅ 通过 |
| 禁止 force push | ✅ 通过 |
| 只读观测，不扩大自动化 | ✅ 通过 |
| forbidden_actions_enforced = true | ✅ 通过 |

---

## 6. 验收标准核对

| 验收标准 | 状态 |
|----------|------|
| heartbeat.json 包含 inbox_loop_last_run | ✅ |
| heartbeat.json 包含 review_loop_last_run | ✅ |
| heartbeat.json 包含两个 loop 的最近状态 | ✅ |
| heartbeat.json 不包含密钥、token、数据库信息 | ✅ |
| ChatGPT 可通过 GitHub 读取 heartbeat | ✅ |
| 不改变两个 loop 的执行边界 | ✅ |
| 更新 LLM Wiki/GitHub 并输出 commit id | ✅ |

---

## 7. 下一步建议

1. **配置 cron**: 将 `heartbeat_sync.sh` 加入 crontab：`*/30 * * * * bash /root/wiki/tasks/heartbeat_sync.sh`
2. **监控验证**: 运行 1-2 个循环周期后，从 GitHub raw URL 读取验证数据一致性
3. **告警阈值**: 如 `inbox_loop.last_run` 超过 20 分钟未更新，可视为 loop 卡死

---

> 本报告由深度研究智能体生成，遵循 limited_formal_run 边界。
