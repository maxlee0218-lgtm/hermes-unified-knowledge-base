# Codex CLI Handoff Protocol

## 目标

把 GitHub Issue 作为任务源，把 Codex CLI 作为本地执行器，把 Git commit 和 Issue comment 作为结果回传。

这不是让 ChatGPT 和 Codex 实时互聊，而是建立一个稳定的工程握手协议：

```text
ChatGPT 创建 / 更新 GitHub Issue
        ↓
Codex CLI 在本地读取 Issue
        ↓
Codex CLI 修改仓库文件、生成文档和 SQL
        ↓
Codex CLI 执行只读检查或本地脚本
        ↓
git commit / git push
        ↓
Codex 在 Issue 里回复结果
        ↓
ChatGPT 读取 Issue、commit 和仓库文件，继续下发下一轮任务
```

## 当前仓库

```text
maxlee0218-lgtm/warehouse-rebuild
```

## 当前任务入口

```text
Issue #1: ADS_SC_XL_13 下一轮任务：验证 dim_date_info 与 with_attr_value 支撑链
```

## 本地执行前置条件

本机需要具备：

```bash
git --version
gh --version
codex --version
```

如果没有 Codex CLI，可按官方方式安装，例如：

```bash
npm install -g @openai/codex
# 或
brew install --cask codex
```

## 推荐执行模式

当前数仓重构项目建议使用：

```bash
codex --auto-edit
```

原因：

- 允许 Codex 自动编辑仓库文件
- 仍然会在执行 shell 命令前要求确认
- 比 full-auto 更适合当前只读审计和文件沉淀阶段

不建议默认使用：

```bash
codex --full-auto
```

除非已经确认仓库干净、任务只在沙箱内执行、且不会触碰生产库。

## 手动执行方式

```bash
cd /Users/lijun/Documents/Codex/2026-04-25/new-chat-2/warehouse-rebuild

git pull origin main

gh issue view 1 --repo maxlee0218-lgtm/warehouse-rebuild --comments

codex --auto-edit
```

然后在 Codex CLI 里输入：

```text
请读取 GitHub Issue #1 的任务要求，并在当前仓库执行。
严格遵守 Issue 中的安全约束：不修改生产库，只生成文档、inspect SQL、recon SQL、审计摘要和 commit。
执行完后 push，并在 Issue #1 回复执行结果。
```

## 半自动执行方式

可以使用仓库脚本：

```bash
bash scripts/run_codex_issue.sh 1
```

该脚本会：

1. 拉取最新代码
2. 读取指定 Issue 的标题、正文和评论
3. 生成本地任务提示文件 `.codex_task_issue_<issue>.md`
4. 调用 Codex CLI 执行任务

## 安全边界

Codex 执行时必须遵守：

```text
1. 不允许修改生产数据库
2. 不允许 DROP / DELETE / UPDATE / INSERT / TRUNCATE / INSERT OVERWRITE
3. 数据库 SQL 只允许 SELECT / SHOW / DESC / EXPLAIN
4. 不允许直接写完整 combined_local，除非支撑链已经闭合
5. 所有结论必须落到仓库文件
6. 所有执行结果必须 commit + Issue comment
```

## Issue 回复格式

Codex 完成后，需要在 Issue 下回复：

```text
执行完成。

commit hash:
新增 / 修改文件:
dim_date_info 是否可复刻:
with_attr_value 是否可复刻:
是否允许进入 combined_local 重构:
当前最大阻塞点:
下一轮建议节点:
```

## 推荐协作原则

```text
GitHub 是事实源
Issue 是任务单
Codex CLI 是执行器
Commit 是执行结果
Issue 评论是回执
ChatGPT 是下一轮任务仲裁者
```
