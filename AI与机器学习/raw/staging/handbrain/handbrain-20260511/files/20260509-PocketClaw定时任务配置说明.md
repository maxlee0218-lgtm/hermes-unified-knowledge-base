# PocketClaw 定时拉取任务配置说明

> 配置时间：2026-05-09 北京时间 23:55
> 配置者：首脑（150服务器）
> 状态：待用户手工配置

---

## 一、定时任务配置

### 1.1 基本配置

| 配置项 | 值 | 说明 |
|--------|-----|------|
| 定时名称 | 任务inbox检查 | 用于标识 |
| 执行命令 | `bash /root/wiki/tasks/task_inbox_check.sh` | 检查脚本路径 |
| 建议频率 | 每 10 分钟 | 平衡实时性和资源消耗 |
| 执行环境 | 150服务器（Hermes） | 主脑所在服务器 |

### 1.2 高级配置

| 配置项 | 建议值 | 说明 |
|--------|--------|------|
| 超时时间 | 60 秒 | 脚本执行超时 |
| 重试次数 | 2 次 | 失败后重试 |
| 重试间隔 | 5 分钟 | 重试间隔 |
| 日志保留 | 30 天 | 自动清理旧日志 |

---

## 二、成功判断

### 2.1 成功标志

- 脚本退出码：0
- 日志中出现：`✅ Multica Issue 创建成功: LEE-XX`
- 任务文件从 `inbox/` 移动到 `active/`
- `status/` 目录生成 `${task_id}.json`

### 2.2 成功示例

```bash
# 手动测试
bash /root/wiki/tasks/task_inbox_check.sh

# 预期输出（日志）
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

## 三、失败判断

### 3.1 失败标志

- 脚本退出码：非 0
- 日志中出现：`❌ 边界校验失败`
- 或 `❌ Multica Issue 创建失败`
- 任务文件保留在 `inbox/`

### 3.2 常见失败原因

| 失败原因 | 日志标志 | 处理方案 |
|---------|---------|---------|
| REVIEW 任务过多 | `⚠️ REVIEW 任务超过阈值` | 先验收 REVIEW 任务 |
| 边界校验失败 | `❌ 边界校验失败` | 补充任务文件的 forbidden_actions |
| Multica 连接失败 | `❌ Multica Issue 创建失败` | 检查 multica daemon 状态 |
| 重复任务 | `⚠️ 任务已存在状态文件` | 删除旧状态文件或修改 task_id |

---

## 四、是否会创建 Multica Issue

**会。**

这是本机制的核心功能：
- 读取 inbox 中的任务文件
- 校验边界（必须定义 forbidden_actions）
- 自动创建 Multica Issue
- 指派给 target_agent 指定的 Agent
- 将任务移动到 active 目录

---

## 五、是否需要人工确认

**不需要。**

本机制设计为自动化：
- 任务文件一旦放入 inbox，即视为已确认
- 边界校验自动执行
- Multica Issue 自动创建
- 主脑后续监控执行和验收

**例外情况需要人工确认：**
- REVIEW 任务 > 3 时暂停拉取
- 需要手动清理 REVIEW 任务后恢复

---

## 六、配置步骤

### 6.1 在 PocketClaw 中配置

1. 打开 PocketClaw 应用
2. 进入「定时任务」或「Cron」设置
3. 添加新定时任务：
   - 名称：`任务inbox检查`
   - 命令：`bash /root/wiki/tasks/task_inbox_check.sh`
   - 频率：`*/10 * * * *`（每10分钟）
   - 环境：150服务器
4. 保存配置

### 6.2 验证配置

```bash
# 手动测试一次
bash /root/wiki/tasks/task_inbox_check.sh

# 检查日志
tail -20 /root/wiki/tasks/logs/task_inbox_watcher.log
```

### 6.3 创建测试任务

```bash
# 复制模板
cp /root/wiki/tasks/inbox/task_template.md /root/wiki/tasks/inbox/TASK-TEST-001.md

# 编辑任务文件
# 修改 task_id, title, target_agent 等字段

# 等待10分钟，或手动执行检查脚本
bash /root/wiki/tasks/task_inbox_check.sh
```

---

## 七、安全声明

- 本机制只创建任务，不直接执行
- 所有执行由 Multica Agent 完成
- 不动生产，不改配置
- 禁止动作由任务文件定义，脚本自动校验
- 知识沉淀到 LLM Wiki 和 GitHub

---

## 八、维护联系

- 问题反馈：检查 `/root/wiki/tasks/logs/task_inbox_watcher.log`
- 状态查询：`ls -la /root/wiki/tasks/status/`
- 手动触发：`bash /root/wiki/tasks/task_inbox_check.sh`

---

## 九、当前状态

- ✅ 目录结构：已创建
- ✅ 任务模板：已创建
- ✅ 检查脚本：已创建
- ✅ README：已创建
- ✅ 配置说明：已输出
- ⏳ PocketClaw 配置：待用户手工配置
- ⏳ 定时启用：待用户确认

**当前状态：可调用入口已准备，未启用自动运行**
