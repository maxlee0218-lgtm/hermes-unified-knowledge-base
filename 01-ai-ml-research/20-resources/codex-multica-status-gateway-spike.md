# Codex 指令：Multica 状态网关 SPIKE

时间：2026-05-10
接收方：Codex
模式：dry-run only

## 目标

当前 Runtime 报告能发现 review backlog，但不能真正收口。请扩展 Multica Command Gateway，先验证 Multica CLI 是否支持 issue 状态更新，并生成 dry-run 命令，不真实修改任何 Multica Issue。

## 任务 1：探测 CLI

执行并记录：

```bash
multica issue update --help
multica issue --help
multica issue list --limit 20 --output json
```

同时查找是否存在 comment 相关子命令。

输出：

```text
20-resources/multica-issue-update-capability-report.md
```

报告说明：

- 是否支持更新 status
- status 参数名
- 支持的 status 值
- 使用 LEE 编号还是 UUID
- 是否支持 comment
- 是否支持 JSON 输出

## 任务 2：扩展脚本

修改：

```text
runtime-commands/process_runtime_command.py
```

新增 dry-run command type：

```text
update_issue_status
add_issue_comment
```

要求：

- 只渲染命令
- 不执行真实更新
- 写 done JSON
- JSON 记录 issue、目标状态、渲染命令、executed=false

## 任务 3：生成 dry-run 收口命令

在 `runtime-commands/pending/` 生成 dry-run YAML：

- LEE-23：建议 cancelled，历史测试/重复
- LEE-25：建议 cancelled/duplicate，保留 LEE-26
- LEE-29：建议 done，已有报告和 Wiki
- LEE-32：建议 done，已有报告和 Wiki
- LEE-33：建议 done，已有报告和 Wiki
- LEE-34：建议 done，已有报告和 Wiki
- LEE-35：建议 done，已有报告和 Wiki
- LEE-30：建议 blocked 或 waiting_for_report，缺 Windows D盘报告
- LEE-31：建议 waiting_for_kimi_claw_worker，等待 Windows Worker 补证

全部必须是：

```yaml
mode: dry_run
```

## 禁止

不启用 approved。不真实修改 Multica。不关闭真实任务。不标记真实 done。不改生产。不删文件。不打印密钥。不 force push。

## 输出报告

生成：

```text
20-resources/multica-command-gateway-update-status-spike-report.md
```

必须写明：

- CLI 探测结果
- 脚本修改摘要
- 生成的 YAML 清单
- done JSON 清单
- 是否真实修改 Multica：No
- Git commit id
- 是否可以进入人工批准阶段
