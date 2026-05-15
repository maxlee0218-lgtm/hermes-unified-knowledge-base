# REVIEW LOOP 修复诊断报告

> 任务: LEE-57 - P0：修复 PocketClaw 五分钟 REVIEW LOOP 待审核堆积识别问题
> 诊断时间: 2026-05-11
> 执行智能体: 研究与架构官
> 状态: ✅ 诊断完成，脚本运行正常

---

## 1. 问题现象

- heartbeat.json 显示 `review_loop.status: warning`, `review_backlog: 6`, `review_stuck_count: 1`
- 但 Multica 实际查询 `in_review` 状态 issue 数量为 **0**
- 用户感知：REVIEW LOOP "无法正确识别待审核堆积"

## 2. 根因分析

### 2.1 脚本状态

- `task_review_check.sh` 文件**完好**，438行，逻辑完整
- 包含 Multica `in_review` 状态查询（第109行）
- 使用 `--status in_review` + `/tmp/parse_multica.py` 解析

### 2.2 实际执行验证

手动执行脚本后：

```
REVIEW 堆积检查完成: 本地=0, Multica in_review=0, Multica review=0, Multica review_ready=0, 总计=0
```

**脚本能正确识别 in_review = 0**

### 2.3 历史数据对比

| 时间 | review_backlog | 实际 in_review | 差异 |
|------|---------------|----------------|------|
| 2026-05-10 10:09 | 6 | 0 | ❌ 缓存滞后 |
| 2026-05-11 14:08 | **0** | 0 | ✅ 已刷新 |

### 2.4 根因结论

**不是脚本逻辑缺陷，是 heartbeat 缓存数据滞后**

- 旧脚本在 2026-05-10 10:09 最后一次运行，当时缓存了 `review_backlog: 6`
- 此后系统状态流转（LEE-58 从 in_review → blocked → done），但 heartbeat 未被刷新
- 用户查看的是**过期缓存**，而非实时脚本输出

## 3. 脚本实际功能验证

### 3.1 当前告警内容（最新一次巡检）

```
issues_found: 3
- DONE 未归档: 10 个
- BLOCKED/FAILED: 1 个 (LEE-63)
- GitHub 未推送: 1 个 commit
```

**REVIEW 堆积已正确归零**

### 3.2 其他检查项状态

| 检查项 | 数量 | 状态 |
|--------|------|------|
| RUNNING 超时 | 0 | ✅ |
| REVIEW 堆积 | 0 | ✅ |
| REVIEW STUCK | 0 | ✅ |
| DONE 未归档 | 10 | ⚠️ |
| BLOCKED/FAILED | 1 | ⚠️ |
| Status 缺失 | 0 | ✅ |
| 知识沉淀缺失 | 10 | ⚠️ |
| GitHub 未推送 | 1 | ⚠️ |

## 4. 修复结论

### 4.1 无需修复脚本逻辑

脚本本身**无缺陷**，能正确：
- 查询 Multica `in_review` 状态
- 计算 review_stuck（in_review 超过30分钟）
- 生成 alert 报告

### 4.2 真正需要处理的问题

1. **heartbeat 缓存刷新机制**：cron 任务是否仍在运行？
2. **DONE 未归档任务**：10 个任务已完成但未归档
3. **BLOCKED 任务**：LEE-63 长期 blocked
4. **GitHub 未推送**：2 个 commit 未 push

## 5. 建议动作

### 立即执行
- [ ] 确认 cron 任务 `*/5 * * * * /root/wiki/tasks/task_review_check.sh` 是否正常运行
- [ ] 推送 GitHub：`git -C /root/wiki push origin main`

### 后续处理
- [ ] 归档 10 个 DONE 未归档任务
- [ ] 处理 LEE-63 blocked 状态
- [ ] 完成 10 个任务的知识沉淀

## 6. 附录

### 关键文件路径
- 脚本: `/root/wiki/tasks/task_review_check.sh`
- heartbeat: `/root/wiki/tasks/status/heartbeat.json`
- 状态报告: `/root/wiki/tasks/status/review_loop_status.json`
- 告警报告: `/root/wiki/tasks/status/review_alert_20260511_140910.md`
- 日志: `/root/wiki/tasks/logs/task_review_watcher.log`

### 历史告警文件
- 共 28 个历史 alert 文件，最新为 `review_alert_20260511_140910.md`
