# Multica Issue Update Capability Report

检查时间：2026-05-10 15:31 CST

## 001 CLI 探测来源

本机没有 `multica` 命令。本次通过 Windows Worker 执行真实 CLI：

```text
C:\Users\39169\.multica\bin\multica.exe
```

探测命令：

```bash
multica issue --help
multica issue update --help
multica issue status --help
multica issue comment --help
multica issue comment add --help
multica issue list --limit 20 --output json
multica issue get LEE-23 --output json
```

## 002 是否支持更新 status

支持。

可用方式一：

```bash
multica issue update <id> --status <status> --output json
```

可用方式二：

```bash
multica issue status <id> <status> --output json
```

本次 gateway dry-run 统一渲染方式一，便于同时扩展 title/priority 等 update 参数。

## 003 status 参数名

`multica issue update` 的状态参数为：

```text
--status string
```

`multica issue status` 的状态参数为位置参数：

```text
multica issue status <id> <status>
```

## 004 支持的 status 值

`--help` 未列出枚举值。

从 `issue list --limit 20 --output json` 真实返回中观察到：

```text
in_review
done
blocked
cancelled
```

本次 dry-run 不验证或写入真实状态，只按指令渲染建议状态。

## 005 使用 LEE 编号还是 UUID

CLI 支持使用 LEE 编号。

只读验证：

```bash
multica issue get LEE-23 --output json
```

返回中包含：

```json
{
  "id": "07b869e5-3a64-433d-b5f1-41664fa48667",
  "identifier": "LEE-23",
  "number": 23,
  "status": "blocked"
}
```

因此 dry-run 命令可以渲染 `LEE-23`、`LEE-30` 等 identifier。

## 006 是否支持 comment

支持。

命令族：

```text
multica issue comment add <issue-id>
multica issue comment delete
multica issue comment list
```

`comment add` 支持：

```text
--content string
--content-stdin
--attachment strings
--parent string
--output string
```

gateway dry-run 对评论统一渲染：

```bash
multica issue comment add <issue-id> --content-stdin --output json
```

## 007 是否支持 JSON 输出

支持。

已确认：

```text
multica issue list --limit 20 --output json
multica issue get LEE-23 --output json
multica issue update <id> --status <status> --output json
multica issue comment add <issue-id> --content-stdin --output json
```

## 008 结论

Multica CLI 已具备状态更新和评论写入能力，但本阶段只允许 dry-run。可以进入下一阶段“人工批准后执行”的设计评审，但不能自动启用 `mode=approved`。

