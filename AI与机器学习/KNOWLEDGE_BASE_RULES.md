# LLM Wiki Knowledge Base Rules

> 生效时间：2026-05-10
> 当前裁决：主链路暂停重建前，先把知识库整理成长期可复用底座。

## 001 定位

本仓库不再只是临时任务中转仓，而是长期知识库、审计库和方案沉淀库。

核心目标：

```text
一次性对话 / 报告 / 外部资料 / 数仓经验
→ 可查询、可复用、可审计、可持续演进的知识库
```

## 002 基本结构

```text
raw/                 原始材料，只保存，不重写
wiki/                编译后的知识文章
wiki/index.md        全局索引
wiki/log.md          操作日志
20-resources/        当前阶段保留的报告和决策材料
runtime-commands/    仅作为任务入口和审计，不作为知识库主体
```

推荐主题：

```text
runtime    Runtime / Multica / Gateway / Flow Guard
warehouse  数仓 / Dolphin / DataX / dbt / 报表验证
agent      Agent 角色 / 协作规则 / 权限边界
research   外部项目 / 框架 / 工具研究
syntheses  查询总结 / 阶段性结论
```

## 003 资料进入规则

所有外部资料先进入 raw，再编译到 wiki。

```text
raw/<topic>/YYYY-MM-DD-<slug>.md
wiki/<topic>/<concept>.md
```

如果只是当前运行报告，可以先放 `20-resources/`，后续再归档到 wiki。

## 004 写入规则

每次知识沉淀必须做三件事：

1. 更新或新增 wiki 文章；
2. 更新 `wiki/index.md`；
3. 追加 `wiki/log.md`。

## 005 查询规则

后续问“我们知道什么”时，优先读取：

```text
wiki/index.md
→ 相关 wiki 文章
→ 必要时回查 raw 或 20-resources
```

## 006 安全规则

禁止进入 Git：

- 密码；
- token；
- API key；
- SSH 私钥；
- 生产连接串；
- 带用户名的服务器连接信息；
- 员工个人明细；
- 未脱敏业务导出。

## 007 当前主路径

先整理知识库，再重建主链路。

当前不继续扩大 Multica 主链路，不继续堆新 Agent，不让 Codex 接管治理。
