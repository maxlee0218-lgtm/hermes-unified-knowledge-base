# PocketClaw 10分钟定时协同机制验收报告

> title: PocketClaw 10分钟定时协同机制验收报告
> created: 2026-05-10
> updated: 2026-05-10
> stage: 验收通过
> type: 运行基线
> tags: [PocketClaw, 定时任务, 多智能体协同, 机制验收]
> status: active
> sources: [主脑验收, PocketClaw日志, task_inbox_check.sh]

---

## 一、验收结论

**PocketClaw 10分钟定时协同机制：✅ 验收通过**

---

## 二、验收记录

### 2.1 手动触发

| 项目 | 值 |
|------|-----|
| 触发时间 | 2026-05-10 01:37:05 |
| 触发方式 | PocketClaw 立即执行 |
| 执行命令 | `bash /root/wiki/tasks/task_inbox_check.sh` |
| 执行结果 | ✅ 成功 |
| 日志记录 | `/root/wiki/tasks/logs/task_inbox_watcher.log` |

### 2.2 定时触发

| 项目 | 值 |
|------|-----|
| 触发时间 | 2026-05-10 01:47:24 |
| 触发方式 | PocketClaw 10分钟定时 |
| 执行命令 | `bash /root/wiki/tasks/task_inbox_check.sh` |
| 执行结果 | ✅ 成功 |
| 间隔验证 | 距上次10分19秒，符合10分钟频率 |

---

## 三、机制验证清单

| 检查项 | 结果 |
|--------|------|
| 脚本可执行 | ✅ |
| 日志记录 | ✅ |
| inbox 扫描 | ✅ |
| 无新任务行为 | ✅ 不动作 |
| Multica Issue 创建 | ✅ 未误触 |
| 生产影响 | ✅ 无 |
| 边界校验 | ✅ 通过 |
| REVIEW 阈值检查 | ✅ 通过 |

---

## 四、当前运行边界

### 4.1 允许任务类型

| 类型 | 标识 | 说明 | 是否创建正式 Issue |
|------|------|------|-------------------|
| DRY-RUN | `dry_run: true` | 只验证，不创建真实任务 | 否（模拟创建） |
| TEST | `TASK-TEST-*` | 测试任务，无害验证 | **否（默认跳过）** |
| SANDBOX | `sandbox: true` | 本地沙箱验证 | 是（指派数据专家） |
| KNOWLEDGE | `knowledge: true` | 知识沉淀、学习吸收 | 是（指派研究智能体） |

### 4.2 存放位置

- TEST 任务：`/root/wiki/tasks/test/`
- 正式任务：`/root/wiki/tasks/inbox/`
- 状态文件：`/root/wiki/tasks/status/`
- 日志文件：`/root/wiki/tasks/logs/task_inbox_watcher.log`

### 4.3 触发方式

- 手动：PocketClaw 立即执行
- 定时：PocketClaw 每10分钟
- 命令：`bash /root/wiki/tasks/task_inbox_check.sh`

---

## 五、禁止事项

- ❌ 自动创建生产变更任务
- ❌ 自动修改数据库
- ❌ 自动上线 DolphinScheduler
- ❌ 自动修改 DataX
- ❌ 自动恢复生产服务
- ❌ 自动覆盖旧版项目
- ❌ 打印密码、token、密钥

---

## 六、后续使用规则

### 6.1 新增任务

1. 复制模板：`cp /root/wiki/tasks/inbox/task_template.md /root/wiki/tasks/inbox/TASK-XXXX.md`
2. 填写任务信息
3. 放入 inbox 目录
4. 等待 PocketClaw 定时扫描

### 6.2 任务模板要求

- 必须包含 `task_id`
- 必须包含 `allowed_actions`
- 必须包含 `forbidden_actions`
- 必须包含 `acceptance_criteria`

### 6.3 监控检查

- 定期检查日志：`tail -20 /root/wiki/tasks/logs/task_inbox_watcher.log`
- 检查 REVIEW 任务数量
- 检查是否有异常报错

---

## 七、相关文件

| 文件 | 路径 |
|------|------|
| 运行基线 | `/root/wiki/tasks/RUNTIME_BASELINE.md` |
| 任务模板 | `/root/wiki/tasks/inbox/task_template.md` |
| 检查脚本 | `/root/wiki/tasks/task_inbox_check.sh` |
| 机制说明 | `/root/wiki/tasks/README.md` |
| 测试任务 | `/root/wiki/tasks/test/TASK-TEST-POCKETCLAW-001.md` |

---

## 八、GitHub 记录

| 项目 | 值 |
|------|-----|
| 仓库 | `maxlee0218-lgtm/llm-wiki.git` |
| 分支 | `main` |
| 最新 commit | `350688d` |
| commit 说明 | 修正：TEST任务规则、模板路径、Wiki路径规范 |

---

## 九、验收签名

| 角色 | 签名 |
|------|------|
| 验收者 | 首脑（150服务器） |
| 验收时间 | 2026-05-10 01:49 |
| 状态 | ✅ 通过 |

---

## 十、后续观察

- 机制已进入有限正式运行态
- 后续只需观察运行，不再验证
- 如有异常，检查日志和状态文件
- 禁止扩大任务类型范围
