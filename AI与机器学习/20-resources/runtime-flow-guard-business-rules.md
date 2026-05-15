# Runtime 流程保障业务规则

> 版本：v1.0  
> 适用范围：LEE Workspace Runtime 流程保障总账  
> 维护角色：Runtime首脑（只读观测，不执行业务）

---

## 001 目标

建立 Runtime 流程保障总账，让用户和 ChatGPT 能快速判断：

1. 当前流程是否通；
2. 卡在哪个环节；
3. 责任角色是谁；
4. 是否需要人工决策。

---

## 002 状态等级定义

| 等级 | 颜色 | 含义 | 触发条件 |
|------|------|------|----------|
| green | 🟢 | 流程健康 | 所有检查项通过，无阻塞 |
| yellow | 🟡 | 流程亚健康 | 存在轻微异常，但不阻断流程 |
| red | 🔴 | 流程阻塞 | 存在明确阻塞，需要人工介入 |
| black | ⚫ | 严重违规 | 涉及生产写操作、密钥泄露、权限变更等 |

---

## 003 Gateway 健康判断规则

| 规则 | 阈值 | 状态影响 |
|------|------|----------|
| gateway 最后活跃时间 | < 10 分钟 | green |
| gateway 最后活跃时间 | 10~30 分钟 | yellow |
| gateway 最后活跃时间 | > 30 分钟 | red |
| gateway failed 计数 | = 0 | green |
| gateway failed 计数 | > 0 | 至少 red |

**观测点**：
- `/root/wiki/runtime-commands/done/` 目录最后更新时间
- `/root/wiki/runtime-commands/failed/` 目录文件数量
- 最近创建的 issue 标识

---

## 004 Multica 状态判断规则

| 状态 | 健康标准 | 异常阈值 |
|------|----------|----------|
| todo | 正常存在 | 无 |
| in_progress | 正常存在 | 单个任务超过 60 分钟 → yellow |
| in_review | 正常存在 | 超过 30 分钟 → yellow；超过 60 分钟 → red |
| blocked | 需定期清理 | 超过 24 小时未处理 → yellow |
| done | 正常归档 | 无 |

---

## 005 Flow Health 判断规则

| 维度 | 通过标准 | 失败标准 |
|------|----------|----------|
| intake_ok | done 目录有正常处理记录 | failed 非空 或 done 超过 30 分钟无更新 |
| routing_ok | 任务正常分派到对应 agent | 任务未分派 或 分派到错误角色 |
| review_ok | in_review 无积压 或 正常流转 | in_review 超过阈值未处理 |
| closeout_ok | done 正常归档 或 按 verdict 收口 | 未收口 或 状态不一致 |
| state_observability_ok | heartbeat 与 Multica 实时状态一致 | 存在数值冲突 或 文件 stale |

---

## 006 Blocker 分类

| 类别 | 说明 | 示例 |
|------|------|------|
| gateway_stall | gateway 停止产生新记录 | done 目录超过 30 分钟无更新 |
| heartbeat_stale | 心跳文件长时间未更新 | heartbeat.json 超过 2 小时未更新 |
| state_mismatch | 本地状态与远程状态不一致 | review_backlog ≠ in_review 数量 |
| blocked_backlog | blocked issue 积压 | blocked 数量持续增长 |
| role_violation | 角色违规执行 | Runtime首脑 代写业务产物 |
| duplicate_issue | 重复 issue | 相同标题/内容重复创建 |
| manual_decision | 需要人工决策 | 用户未确认的阻塞点 |

---

## 007 角色违规定义

Runtime首脑 严禁以下行为：

- 代写业务报告、证据、SQL、业务产物；
- 直接关闭、评论、更新 Multica Issue 状态（除非按 verdict 收口）；
- 运行 `runtime-commands/process_runtime_command.py`；
- 修改生产数据库、PolarDB、DolphinScheduler、DataX；
- 执行 INSERT/UPDATE/DELETE/DROP/ALTER/TRUNCATE/CREATE；
- 重跑调度；
- 删除文件；
- force push；
- 读取或输出 API key、token、密码、连接串。

---

## 008 重复项判断规则

- 相同标题 + 相同描述摘要 → 疑似重复；
- 相同 task_id 在不同 issue 中出现 → 确认重复；
- 历史已处理过的 command 再次进入 pending → 需检查 idempotency。

---

## 009 人工决策触发条件

以下情况必须标记为 `manual_decisions`：

- blocked issue 超过 3 个且持续 24 小时以上；
- gateway 停滞原因不明；
- heartbeat 与 Multica 状态冲突无法自动解释；
- 存在生产写操作请求但无明确授权；
- 角色违规需要用户确认处理方案。

---

## 010 下一步动作优先级

| 优先级 | 触发条件 | 建议动作 |
|--------|----------|----------|
| P0 | overall_status = red/black | 立即检查 gateway/loop 状态，确认阻塞根因 |
| P0 | state_observability_ok = false | 修复 heartbeat 同步或确认 loop 存活 |
| P1 | blocked > 3 | 逐一评估 blocked issue，建议取消/归档/重试 |
| P1 | gateway_stall > 30min | 检查 Windows gateway / PocketClaw 进程 |
| P2 | duplicates > 0 | 清理重复 issue，强化 idempotency |
| P2 | role_violations > 0 | 按违规等级处理，必要时 blocked |

---

## 011 文件清单

Runtime 流程保障总账涉及以下文件：

| 文件 | 用途 | 更新频率 |
|------|------|----------|
| `scripts/runtime_state_snapshot.ps1` | PowerShell 采集脚本 | 按需运行 |
| `tasks/status/runtime-state.json` | 机器可读状态快照 | 每次运行更新 |
| `tasks/status/runtime-state.md` | 人工可读状态报告 | 每次运行更新 |
| `20-resources/runtime-flow-guard-business-rules.md` | 业务规则文档 | 规则变更时更新 |

---

## 012 变更记录

| 版本 | 时间 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-05-10 | 初始版本，建立流程保障总账规则体系 |

---

*本文档由 Runtime首脑 只读生成，不涉及生产系统修改。*
