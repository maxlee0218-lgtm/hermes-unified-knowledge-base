# 数仓2.0重构协作区

本目录是 Hermes 实际工作仓库中的数仓2.0协作区。

## 固定任务入口

```text
04-warehouse-projects/rebuild-audit/TASK_INBOX.md
```

## 状态回写

```text
04-warehouse-projects/rebuild-audit/TASK_STATUS.md
```

## 当前第一批任务

```text
销售毛利 / 批次成本样板链路迁移输入
```

## 当前交付目录

```text
04-warehouse-projects/rebuild-audit/warehouse-2.0/01_migration_input/
```

## 新生产调度原则

```text
DolphinScheduler 统一编排
Dolphin Shell任务调用 DataX
DataX 不独立定时运行
ODS检查通过后再进入下游 DWD / DIM / DWS / ADS / 质量 / 对账
```
