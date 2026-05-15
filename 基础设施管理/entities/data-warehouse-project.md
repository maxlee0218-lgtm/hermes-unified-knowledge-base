---
title: "数仓重构项目 (D:\data-warehouse)"
created: 2026-05-05
updated: 2026-05-05
type: entity
tags: [project, data-warehouse, dbt, duckdb, dolphinscheduler]
sources: []
---

# 数仓重构项目 (D:\data-warehouse)

> 大狂→Windows 本机数仓重构专用目录
> 整理时间: 2026-05-01
> 最近更新: 2026-05-05

---

## 一、项目概览

| 属性 | 值 |
|------|-----|
| **位置** | `D:\data-warehouse` |
| **总大小** | 约 25 GB |
| **主要技术** | dbt + DuckDB + DataX + DolphinScheduler |
| **数据库** | MySQL 8.4.9 (端口 3406) |
| **调度平台** | DolphinScheduler Standalone (端口 8080) |
| **AI 助手** | Kimi Desktop (端口 18679) |

---

## 二、目录结构

```
D:\data-warehouse
├── 00-projects/                    (1.52 GB) - 现有项目迁移
│   ├── control_plane_exports/      - 控制平面导出
│   └── stock-dolphin-refactor-test/ - Stock-Dolphin 重构测试
│       ├── csv_staging/            - CSV 暂存数据
│       ├── csv_staging_v2/         - CSV 暂存数据 v2
│       ├── dumps/                  - 数据导出
│       ├── dumps_full/             - 完整数据导出
│       ├── sql/                    - SQL 脚本
│       ├── task-patches/           - 任务补丁
│       └── workflow-update/        - 工作流更新
│
├── 01-dbt-duckdb/                 (21.89 GB) - dbt + DuckDB 本地数仓
│   ├── data_warehouse/           - dbt 项目主目录
│   │   ├── models/             - 数据模型 (bronze/silver/gold)
│   │   ├── seeds/              - 种子数据
│   │   ├── tests/              - 测试脚本
│   │   ├── macros/            - 宏定义
│   │   ├── analyses/          - 分析脚本
│   │   └── snapshots/         - 快照定义
│   ├── scripts/                - 辅助脚本
│   ├── logs/                   - 执行日志
│   ├── docs/                   - 文档
│   ├── venv/                   - Python 虚拟环境
│   ├── dev.duckdb             - 开发环境数据库
│   ├── dw_rebuild.duckdb      - 重构主数据库
│   ├── dw_rebuild_prod.duckdb - 生产环境数据库
│   └── dw_staging*.duckdb     - 测试数据库
│
├── 02-datax/                      (447 MB) - DataX 数据同步
│   ├── datax-home/             - DataX 发行版
│   ├── jobs/                   - 同步任务定义
│   ├── scripts/                - 辅助脚本
│   └── venv/                   - Python 虚拟环境
│
├── 03-monitoring/                 (127 MB) - 监控脚本
│   ├── local/                  - 本地 dbt 监控
│   ├── production/             - 生产环境监控测试
│   └── venv/                   - Python 虚拟环境
│
├── 04-backups/                    (944 MB) - 自动备份
│
├── 05-docs/                       (少量) - 文档 + Obsidian 同步
│   └── obsidian-sync/         - Obsidian 同步脚本
│
├── 06-logs/                       (少量) - 执行日志
│
├── csv_staging/                   (288 MB) - CSV 暂存区
└── scripts/                       (少量) - 通用脚本
```

---

## 三、虚拟环境

| 环境 | 路径 | 用途 |
|------|-------|------|
| **dbt-duckdb** | `01-dbt-duckdb\venv\` | dbt-core + dbt-duckdb + duckdb |
| **datax-utils** | `02-datax\venv\` | pandas + sqlalchemy + pymysql + requests |
| **monitoring** | `03-monitoring\venv\` | pandas + requests |

### 使用方式
```powershell
# dbt
& "D:\data-warehouse\01-dbt-duckdb\venv\Scripts\python.exe" -m dbt --version

# DataX 辅助脚本
& "D:\data-warehouse\02-datax\venv\Scripts\python.exe" script.py

# 监控脚本
& "D:\data-warehouse\03-monitoring\venv\Scripts\python.exe" monitor.py
```

---

## 四、数据模型架构 (dbt)

```yaml
# dbt_project.yml 关键配置
models:
  data_warehouse:
    bronze:          # 原始层
      +materialized: table
      +tags: ["bronze", "raw"]
      +docs:
        node_color: "#8B4513"  # 棕色
    
    silver:          # 清洁层
      +materialized: table
      +tags: ["silver", "cleaned"]
      +docs:
        node_color: "#C0C0C0"  # 银色
    
    gold:            # 业务层
      +materialized: table
```

### 层级说明
| 层级 | 名称 | 颜色 | 说明 |
|------|------|------|------|
| Bronze | 原始层 | 棕色 (#8B4513) | 未处理的原始数据 |
| Silver | 清洁层 | 银色 (#C0C0C0) | 清洗、转换后的数据 |
| Gold | 业务层 | 默认 | 业务可用的聚合数据 |

---

## 五、服务状态

| 服务 | 端口 | 状态 |
|------|------|------|
| MySQL 8.4.9 | 3406 | ✓ 运行中 |
| DolphinScheduler Standalone | 8080 | ✓ 运行中 |
| Kimi Desktop | 18679 | ✓ 运行中 |

---

## 六、关键脚本

### 数据拉取
| 脚本 | 功能 |
|------|------|
| `csv_staging_pull.py` | 从源系统拉取 CSV 数据 |
| `fast_csv_pull.py` | 快速 CSV 拉取 |
| `multi_thread_pull.py` | 多线程数据拉取 |
| `business_pull_current_stock.py` | 业务库实时库存拉取 |
| `polardb_to_duckdb_loader.py` | PolarDB → DuckDB 加载 |

### 数据加载
| 脚本 | 功能 |
|------|------|
| `csv_to_duckdb_import.py` | CSV 导入 DuckDB |
| `load_dwd_tms.py` | 加载 DWD TMS 数据 |
| `polardb_bulk_load.py` | PolarDB 批量加载 |
| `sample_to_duckdb.py` | 样本数据导入 |

### 监控与检查
| 脚本 | 功能 |
|------|------|
| `auto_monitor.py` | 自动监控 |
| `check_schema.py` | 检查数据库 Schema |
| `check_duckdb_tables.py` | 检查 DuckDB 表结构 |
| `dbt_auto_verify.py` | dbt 自动验证 |

### 辅助工具
| 脚本 | 功能 |
|------|------|
| `analyze_migration.py` | 迁移分析 |
| `extract_ds_tasks.py` | 提取 DolphinScheduler 任务 |
| `batch_bronze_generator.py` | 批量 Bronze 层生成 |

---

## 七、数据库文件

| 数据库 | 路径 | 用途 |
|--------|--------|------|
| dev.duckdb | `01-dbt-duckdb\dev.duckdb` | 开发环境 |
| dw_rebuild.duckdb | `01-dbt-duckdb\dw_rebuild.duckdb` | 主重构数据库 |
| dw_rebuild_prod.duckdb | `01-dbt-duckdb\dw_rebuild_prod.duckdb` | 生产环境 |
| dw_staging.duckdb | `01-dbt-duckdb\dw_staging.duckdb` | 测试环境 |

---

## 八、最近活动 (2026-05-05)

- csv_staging 数据更新
- dbt 模型执行与验证
- dw_rebuild.duckdb 数据库更新

---

## 九、待处理事项

- [ ] 检查是否需要清理过期的 .tmp 和 .wal 文件
- [ ] 定期备份策略验证
- [ ] 监控告警规则完善
- [ ] 文档自动化同步
