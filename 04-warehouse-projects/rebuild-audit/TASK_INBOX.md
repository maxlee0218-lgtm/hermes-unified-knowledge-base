# Hermes 最新任务入口

> 固定入口。Hermes / Kimi 以后只需要读取本文件，不需要用户复制大段任务。

## 重要说明

当前 Hermes 实际工作仓库是：

```text
maxlee0218-lgtm/hermes-unified-knowledge-base
```

当前任务入口位于：

```text
04-warehouse-projects/rebuild-audit/TASK_INBOX.md
```

交付物请优先落到本仓库：

```text
04-warehouse-projects/rebuild-audit/warehouse-2.0/01_migration_input/
```

如需同步到旧协作仓库，可再同步到：

```text
maxlee0218-lgtm/warehouse-rebuild/warehouse-2.0/
```

## 轮询规则

建议 Hermes / Kimi 每 5-10 分钟读取一次本文件。

```text
读取 TASK_INBOX.md
  ↓
识别 active_task
  ↓
在 Hermes Kanban 创建或更新任务
  ↓
领取 ready 任务执行
  ↓
提交文件或 PR
  ↓
更新 TASK_STATUS.md
  ↓
等待 GPT 审查并派发下一轮
```

## 当前 active_task

```yaml
active_task_id: WH2-P0-001
title: 销售毛利/批次成本样板链路迁移输入
status: active
priority: P0
tenant: warehouse-2.0
repo: maxlee0218-lgtm/hermes-unified-knowledge-base
working_dir: 04-warehouse-projects/rebuild-audit/warehouse-2.0/
owner: Hermes
reviewer: GPT
```

## 本轮目标

基于老生产只读资料，围绕“销售毛利 / 批次成本”第一批样板链路，生成迁移输入资料。

第一批关注对象：

```text
ads_gx_xs_18
ads_gx_cg_07_detail
BATCH_NUM
采购成本
销售收入
库存批次
生产加工
毛利计算
```

新生产核心要求：

```text
DolphinScheduler 统一编排
Dolphin Shell任务调用 DataX
DataX 不再独立定时运行
DataX 完成 ODS 同步后进入 ODS 落地检查
下游 DWD / DIM / DWS / ADS / 质量 / 对账全部由 Dolphin 编排
```

## 本轮交付目录

```text
04-warehouse-projects/rebuild-audit/warehouse-2.0/01_migration_input/
```

## 本轮必须交付文件

```text
old_ads_contract.csv
old_ads_usage_priority.csv
old_table_lineage.csv
old_datax_mapping.csv
old_dolphin_workflow_mapping.csv
batch_num_loss_matrix.csv
dolphin_datax_orchestration_plan.csv
pilot_sales_profit_scope.md
hermes_run_summary.md
```

## 完成条件

```text
1. 所有CSV有表头。
2. 所有判断有 evidence。
3. 所有判断有 confidence。
4. 不确定内容标记 unknown。
5. 不提交密码、token、真实敏感连接信息。
6. 提交分支或 PR。
7. 更新 TASK_STATUS.md。
8. 在 Hermes Kanban complete 中写 summary + metadata handoff。
```

## 状态回写

Hermes 完成或阻塞时必须更新：

```text
04-warehouse-projects/rebuild-audit/TASK_STATUS.md
```

如果无法更新文件，至少在 PR 或提交说明中写明状态。

## 下一轮任务来源

GPT 审查 PR 后，会更新本文件的 active_task。Hermes 后续只需要继续轮询本文件。