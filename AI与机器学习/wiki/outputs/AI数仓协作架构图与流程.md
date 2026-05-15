---
title: AI数仓协作架构图与流程
date: 2026-05-13
tags: [architecture, workflow, multica, windows-runtime, warehouse]
status: stable
---

# AI数仓协作架构图与流程

## 1. 结论

当前采用“首脑判断、Multica.ai 分派、Windows Runtime 执行、DataGrip/MCP 统一数据访问、llm-wiki 沉淀”的协作结构。

## 2. 当前架构图

```mermaid
flowchart TB
    U[用户\n提出目标 / 查看结果 / 人工确认]
    Chief[首脑\n统筹 / 判断边界 / 验收 / 知识库维护]
    Multica[Multica.ai\nAgent 面板 / Issue 分派中心 / 状态跟踪]

    subgraph Win[Windows Runtime 核心执行环境]
        TM[任务管家-Windows-Kimi\n接收任务 / 拆分 / 分派 / 汇总]
        DS[数据虾-Windows-Kimi\n只读分析 / 报告]
        CD[代码工-Windows-Codex\n代码 / SQL / 脚本能力\n⚠️ 当前暂停]
        DBM[DataGrip + MCP\n数据访问与连接维护中心]
    end

    Biz[(业务数据源)]
    Wiki[llm-wiki\n正式知识库 / 决策库 / 报告沉淀]
    Hermes[Hermes\n可选执行工具\n不直接访问业务数据源]

    U --> Chief
    Chief --> Multica
    Multica --> Win
    TM --> DS
    TM --> CD
    DS --> DBM
    CD --> DBM
    DBM --> Biz
    Win --> Multica
    Multica --> Chief
    Chief --> Wiki
    Chief -.可选调用.-> Hermes
    Hermes -.辅助沉淀.-> Wiki
```

## 3. 任务流程图

```mermaid
flowchart TD
    A[1 用户提出需求]
    B[2 首脑判断目标与边界]
    C{是否适合 dry-run}
    D[3 在 Multica.ai 创建 Issue]
    E[4 分配给任务管家-Windows-Kimi]
    F[5 任务管家拆分子任务]
    G1[6A 分给数据虾-Windows-Kimi\n只读分析 / 报告]
    G2[6B 分给代码工-Windows-Codex\n脚本 / SQL / 代码能力\n⚠️ 当前暂停]
    H[7 Windows Runtime 执行]
    I[8 如需数据访问\n通过 DataGrip + MCP 只读访问]
    J[9 结果回写 Multica\n评论 / 状态 / 产出]
    K[10 首脑汇总与验收]
    L{是否达到验收标准}
    M[11 沉淀到 llm-wiki\n报告 / 决策 / 经验]
    N[12 用户查看结果并决定下一步]
    X[收紧边界 / 暂不执行]
    R[首脑重新下发任务]

    A --> B --> C
    C -- 是 --> D --> E --> F
    C -- 否 --> X --> B
    F --> G1
    F --> G2
    G1 --> H
    G2 --> H
    H --> I --> J
    H --> J
    J --> K --> L
    L -- 是 --> M --> N
    L -- 否 --> R --> D
```

## 4. 角色分工

| 角色 | 定位 | 主要职责 | 当前边界 |
|---|---|---|---|
| 用户 | 最终确认人 | 提目标、看结果、做人工确认 | 不维护复杂链路 |
| 首脑 | 统筹与验收 | 判断边界、分派方向、验收、知识库维护 | 不越权执行高风险动作 |
| Multica.ai | 任务平台 | Issue、Agent 分派、状态跟踪 | 不替代 llm-wiki |
| 任务管家-Windows-Kimi | 任务中转 | 接收、拆分、分派、汇总 | 不做最终决策 |
| 数据虾-Windows-Kimi | 数据分析 | 只读分析、报告输出 | 不做写入动作 |
| 代码工-Windows-Codex | 代码能力 | 脚本、SQL、代码生成和检查 | ⚠️ 当前暂停 |
| DataGrip + MCP | 数据访问出口 | 连接维护、只读能力出口 | 不向 Agent 暴露敏感连接信息 |
| llm-wiki | 知识库 | 决策、报告、经验沉淀 | 不保存敏感明细 |

## 5. 本轮运行原则

- 先 dry-run，后只读验证；
- 数据访问统一走 Windows MCP；
- Multica 负责任务分派和状态跟踪；
- 首脑负责最终判断与收口；
- llm-wiki 负责正式沉淀；
- Kimi 优先用于中文理解、任务整理、报告汇总；
- Codex 只作为代码能力工具，不作为主控（⚠️ 当前暂停）。

## 6. 下一步建议

1. 等待任务管家链路 dry-run 完成；
2. 记录 Codex 当前可用性状态；
3. 完成 Windows MCP 只读能力 dry-run；
4. 再进入 ADS_SC_XL_13 样板链路准备；
5. 阶段完成后更新本页或对应报告。

## 7. 来源路径

- `wiki/outputs/当前决策总账.md`
- `wiki/operations/Windows数据库MCP访问规范.md`
- `wiki/warehouse/数据访问只读安全边界.md`
- `wiki/outputs/Multica任务管家链路dry-run验证报告.md`
