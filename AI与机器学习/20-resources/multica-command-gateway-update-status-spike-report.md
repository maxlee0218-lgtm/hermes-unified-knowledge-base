# Multica Command Gateway Update Status SPIKE Report

检查时间：2026-05-10 15:31 CST

## 001 CLI 探测结果

已通过 Windows Worker 上的真实 CLI 完成探测：

```text
C:\Users\39169\.multica\bin\multica.exe
```

关键结论：

- `multica issue update <id> --status <status> --output json` 支持状态更新。
- `multica issue status <id> <status> --output json` 也支持状态更新。
- `multica issue comment add <issue-id> --content-stdin --output json` 支持评论写入。
- `multica issue list --limit 20 --output json` 支持 JSON 输出。
- `multica issue get LEE-23 --output json` 验证 LEE 编号可作为 issue id。
- `--help` 未列出 status 枚举值；从真实 issue list 中观察到 `in_review`、`done`、`blocked`、`cancelled`。

能力明细见：

```text
20-resources/multica-issue-update-capability-report.md
```

## 002 脚本修改摘要

修改：

```text
runtime-commands/process_runtime_command.py
```

新增 dry-run command type：

```text
update_issue_status
add_issue_comment
```

行为：

- 只渲染命令；
- 不执行真实 Multica CLI 写操作；
- `mode=approved` 仍被禁止；
- `update_issue_status` 渲染：

```bash
multica issue update <issue> --status <target_status> --output json
```

- `add_issue_comment` 渲染：

```bash
multica issue comment add <issue> --content-stdin --output json
```

- done JSON 记录 `issue`、`target_status`、`rendered_command`、`executed=false`。
- 本机无 `multica` 时允许 dry-run 渲染通用 `multica ...` 命令；真实 CLI 参数已在 Windows Worker 上单独探测并记录。

## 003 生成的 YAML 清单

```text
runtime-commands/pending/CMD-20260510-010-lee-23-status-cancelled.yaml
runtime-commands/pending/CMD-20260510-011-lee-25-status-cancelled-duplicate.yaml
runtime-commands/pending/CMD-20260510-012-lee-29-status-done.yaml
runtime-commands/pending/CMD-20260510-013-lee-32-status-done.yaml
runtime-commands/pending/CMD-20260510-014-lee-33-status-done.yaml
runtime-commands/pending/CMD-20260510-015-lee-34-status-done.yaml
runtime-commands/pending/CMD-20260510-016-lee-35-status-done.yaml
runtime-commands/pending/CMD-20260510-017-lee-30-status-blocked.yaml
runtime-commands/pending/CMD-20260510-018-lee-31-status-blocked.yaml
runtime-commands/pending/CMD-20260510-019-lee-30-comment-waiting-report.yaml
```

建议状态：

| Issue | 建议 | 说明 |
|---|---|---|
| LEE-23 | cancelled | 历史测试/重复 |
| LEE-25 | cancelled | 与 LEE-26 重复，保留 LEE-26 |
| LEE-29 | done | 已有报告和 Wiki |
| LEE-32 | done | 已有报告和 Wiki |
| LEE-33 | done | 已有报告和 Wiki |
| LEE-34 | done | 已有报告和 Wiki |
| LEE-35 | done | 已有报告和 Wiki |
| LEE-30 | blocked | 缺 Windows D 盘报告 |
| LEE-31 | blocked | 等待 Windows Worker 补证 |
| LEE-30 | comment dry-run | 说明等待报告，不真实评论 |

## 004 done JSON 清单

本次 dry-run 生成：

```text
runtime-commands/done/CMD-20260510-010-lee-23-status-cancelled.json
runtime-commands/done/CMD-20260510-011-lee-25-status-cancelled-duplicate.json
runtime-commands/done/CMD-20260510-012-lee-29-status-done.json
runtime-commands/done/CMD-20260510-013-lee-32-status-done.json
runtime-commands/done/CMD-20260510-014-lee-33-status-done.json
runtime-commands/done/CMD-20260510-015-lee-34-status-done.json
runtime-commands/done/CMD-20260510-016-lee-35-status-done.json
runtime-commands/done/CMD-20260510-017-lee-30-status-blocked.json
runtime-commands/done/CMD-20260510-018-lee-31-status-blocked.json
runtime-commands/done/CMD-20260510-019-lee-30-comment-waiting-report.json
```

示例渲染：

```bash
multica issue update LEE-30 --status blocked --output json
multica issue comment add LEE-30 --content-stdin --output json
```

所有 JSON 均包含：

```json
{
  "mode": "dry_run",
  "status": "dry_run_rendered",
  "executed": false
}
```

## 005 dry-run 测试

执行：

```bash
python3 runtime-commands/process_runtime_command.py
```

结果：

```text
dry_run_rendered
```

说明：

- 本机没有 `multica` CLI，因此 dry-run 使用通用 `multica` 命令名渲染；
- 真实 CLI 能力由 Windows Worker 探测结果兜底；
- 未进入 `mode=approved`；
- 未执行任何真实 Multica 写操作。

## 006 是否真实修改 Multica

No。

本次没有真实执行：

```text
multica issue update
multica issue status
multica issue comment add
```

所有命令均只写入 dry-run JSON。

## 007 是否修改生产

No。

未修改生产数据库、PolarDB、DolphinScheduler、DataX、系统服务或运行配置。

## 008 Git commit id

实现提交：

```text
a6c61e7
```

## 009 是否可以进入人工批准阶段

可以进入人工批准阶段的设计评审，但不应自动启用。

进入 approved 模式前至少需要：

- 用户明确授权具体 LEE 编号和目标状态；
- 再次读取当前 Multica 状态，避免状态漂移；
- 对每条命令生成最终确认清单；
- 保留逐条执行和回滚/备注策略；
- 禁止批量无确认自动关闭或标记 done。
