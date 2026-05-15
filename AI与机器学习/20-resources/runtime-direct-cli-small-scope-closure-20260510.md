# Runtime首脑 小范围真实收口指令

时间：2026-05-10
发起方：ChatGPT
接收方：Runtime首脑
模式：小范围真实执行

## 001 核心原则

本任务只使用 Multica 官方 CLI，不修改 Multica 框架。

允许：
- 调用官方 multica CLI 查询 Issue；
- 调用官方 multica CLI 更新指定 Issue 状态；
- 写入 Issue 评论；
- 更新 runtime-governor-report.md；
- 写 GitHub 审计记录。

禁止：
- 不修改 Multica 源码；
- 不修改 Multica daemon；
- 不修改 Multica 配置；
- 不修改 Multica 数据库；
- 不修改 Multica autopilot 机制；
- 不修改 agent 底层运行方式；
- 不修改生产数据库；
- 不修改 DolphinScheduler；
- 不修改 DataX；
- 不删除业务文件；
- 不读取或写入密钥原文；
- 不 force push。

## 002 本轮只处理两个 Issue

只允许处理：

1. LEE-25
2. LEE-29

不得处理其他 Issue。

## 003 执行动作

### LEE-25

目标状态：cancelled

原因：与 LEE-26 重复，LEE-26 已保留为完成态。

执行前必须：
- 读取 LEE-25 当前状态；
- 读取 LEE-26 当前状态；
- 确认 LEE-26 为 done 或已有完整报告；
- 写入说明评论；
- 再更新 LEE-25 状态。

### LEE-29

目标状态：done

原因：已有报告和 Wiki，可先作为小范围状态收口验证对象。

执行前必须：
- 读取 LEE-29 当前状态；
- 确认报告路径存在；
- 确认 Wiki 路径存在；
- 写入说明评论；
- 再更新 LEE-29 状态。

## 004 建议 CLI

以实际 help 为准，可参考：

```bash
multica issue get LEE-25 --output json
multica issue get LEE-26 --output json
multica issue get LEE-29 --output json
multica issue comment add LEE-25 --content-stdin --output json
multica issue update LEE-25 --status cancelled --output json
multica issue comment add LEE-29 --content-stdin --output json
multica issue update LEE-29 --status done --output json
```

如当前 CLI 推荐 `multica issue status <id> <status>`，可使用该官方命令。

## 005 验收标准

执行完成后必须输出：

1. LEE-25 执行前状态；
2. LEE-25 执行后状态；
3. LEE-29 执行前状态；
4. LEE-29 执行后状态；
5. review backlog 执行前数量；
6. review backlog 执行后数量；
7. 使用的 CLI 命令摘要；
8. 是否有失败；
9. 是否触碰生产：必须为否；
10. GitHub commit id。

## 006 输出路径

更新：

```text
/root/wiki/20-resources/runtime-governor-report.md
```

新增或更新：

```text
/root/wiki/20-resources/runtime-direct-cli-small-scope-closure-report.md
```

## 007 成功判定

如果 LEE-25 和 LEE-29 都成功收口，且 review backlog 下降，则下一轮再处理剩余 review。

如果任一失败，不继续扩大范围，必须输出失败原因。
