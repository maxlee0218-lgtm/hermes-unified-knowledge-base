# Multi-Agent Coordination Protocol

## 目标

建立一个跨 ChatGPT 项目、跨 Codex 项目的协同机制。

不依赖任意单个对话框的上下文记忆，而是以 GitHub 仓库作为事实源，以 Issue 作为任务队列，以 Commit / PR / Issue comment 作为执行回执。

当前事实源仓库：

```text
maxlee0218-lgtm/warehouse-rebuild
```

当前主项目：

```text
ADS_SC_XL_13 数仓重构
```

## 核心原则

```text
GitHub repository = shared state
GitHub Issue = task order
Issue labels = task state machine
Codex project = executor
ChatGPT project = planner / reviewer / coordinator
Commit or PR = execution result
Issue comment = handoff receipt
```

## Agent 角色分工

### 1. Planner / Coordinator Agent

通常是当前 ChatGPT 项目。

职责：

- 读取仓库当前状态
- 判断下一轮推进目标
- 创建 GitHub Issue
- 给 Issue 添加标签
- 审查 Codex 输出
- 判断是否进入下一阶段
- 维护项目路线图、缺口清单、重构顺序

不直接做：

- 不在生产库执行写操作
- 不绕过 Issue 直接让执行器改大范围逻辑
- 不依赖聊天上下文做唯一事实源

### 2. Codex Executor Agent

可以在另一个 Codex 项目中运行。

职责：

- 定时扫描 GitHub Issue
- 只接收带 `codex-task` / `codex-ready` / `ads-sc-xl-13` 标签的 open Issue
- 按 Issue 正文执行
- 修改仓库文件
- 生成 inspect SQL / recon SQL / audit summary
- 提交 commit 或 PR
- 在 Issue 下回复执行结果

不直接做：

- 不修改生产数据库
- 不执行 DROP / DELETE / UPDATE / INSERT / TRUNCATE / INSERT OVERWRITE
- 不把密钥写入仓库、Issue 或日志
- 不在支撑链未闭合前直接写完整 `combined_local`

### 3. Reviewer Agent

可以是当前 ChatGPT，也可以是另一个审查对话。

职责：

- 读取 Codex commit / PR / Issue comment
- 检查是否满足 Issue 验收标准
- 标注 `codex-done` / `codex-blocked`
- 提出下一轮任务建议

## 标签状态机

任务 Issue 使用以下标签：

```text
ads-sc-xl-13      项目标识
codex-task        可被 Codex 执行的任务
codex-ready       等待 Codex 接单
codex-running     Codex 正在执行
codex-done        Codex 已完成
codex-blocked     Codex 执行失败或等待补充信息
review-needed     需要 ChatGPT 审查
human-needed      需要用户人工处理，例如授权、密钥、权限
```

状态流转：

```text
codex-ready
  -> codex-running
  -> codex-done
  -> review-needed
  -> next issue
```

异常流转：

```text
codex-ready
  -> codex-running
  -> codex-blocked
  -> human-needed or next diagnostic issue
```

## Issue 编写规范

每个 Issue 必须包含：

1. 背景
2. 本轮目标
3. 严格安全约束
4. 输入文件
5. 输出文件
6. SQL 限制
7. 验收标准
8. 回写格式
9. 不允许做什么

## Codex 回写格式

Codex 完成后必须在 Issue 下回复：

```text
Codex automation completed.

Commit or PR:
- <commit hash or PR link>

Changed files:
- <file 1>
- <file 2>

Current conclusion:
- <core conclusion>

Blockers:
- <blockers or None>

Can proceed to combined_local:
- Yes / No
- Reason: <reason>

Next suggested node:
- <node>

Handoff package:
- handoff/ads_sc_xl_13_handoff_latest.zip
```

## 当前安全边界

所有 Agent 必须遵守：

```text
1. 不修改生产数据库
2. 不执行 DROP / DELETE / UPDATE / INSERT / TRUNCATE / INSERT OVERWRITE
3. 数据库 SQL 只允许 SELECT / SHOW / DESC / EXPLAIN
4. 不在支撑链未闭合前直接写完整 combined_local
5. 不把密钥、token、API key、数据库密码写入仓库、Issue、日志或注释
6. 不把聊天上下文当作唯一事实源
7. 所有关键结论必须落仓库文件
```

## 当前主线判断

当前 `ADS_SC_XL_13` 的主判断：

- `combined_002` 壳层不是当前主要问题
- 差异重点在 `combined` 上游中间逻辑和支撑链
- 已确认 `dim_date_info` 可执行待验证
- `with_attr_value` 可分段复刻，但未整体闭合
- 当前不允许直接进入完整 `combined_local`

## 推荐下一轮

下一轮建议任务：

```text
ADS_SC_XL_13 第 2 轮任务：复刻 dim_date_info_local 并验证补零行
```

目标：

- 基于 `dim_date_info_rebuild_plan.md` 生成本地复刻蓝图
- 生成 defined 层 date spine + business combo 补零 SQL
- 验证 baseline_only 零行
- 判断是否可以进入 process1 / defined 重构
- 不进入完整 combined_local

## 跨项目协同说明

Codex 即使在另一个项目中运行，也必须以 GitHub 仓库为唯一事实源。

不要要求 Codex 依赖当前 ChatGPT 项目的私有上下文。

Codex 每次启动时都应先读取：

```text
README.md
docs/01_current_status.md
docs/04_codex_cli_handoff.md
docs/05_multi_agent_coordination.md
lineage/ads_sc_xl_13/05_missing_links.md
lineage/ads_sc_xl_13/06_next_rebuild_order.md
```

这样多个 Agent 即使处于不同 ChatGPT / Codex 项目，也能围绕同一套事实源协作。
