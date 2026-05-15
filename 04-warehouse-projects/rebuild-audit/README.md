# warehouse-rebuild

## 当前聚焦链路
ADS_SC_XL_13

## 当前目标
重构并存库 ADS_SC_XL_13 主链和支撑链。

## 当前验收表
- ads_sc_xl_13_defined_manuf_line_name_combined_001
- ads_sc_xl_13_defined_manuf_line_name_combined_002

## 当前核心判断
combined_002 壳层已不是主要问题，下一步重点是 combined 上游中间逻辑和支撑链复刻。

## 下一步入口文件
- lineage/ads_sc_xl_13/06_next_rebuild_order.md
- lineage/ads_sc_xl_13/05_missing_links.md
- lineage/ads_sc_xl_13/diagrams/ads_sc_xl_13_full_dependency.mmd

## 当前阶段约束
- 当前阶段只做只读审计、文件整理、链路绘制、SQL 归档。
- 不修改生产数据库。
- 不修改 Dolphin 任务。
- 不修改 DataX 配置。
- 所有数据库 SQL 仅允许 `SELECT / SHOW / DESC / EXPLAIN`。

## 当前已落文档
- 项目目标与当前状态：`docs/`
- ADS_SC_XL_13 主链、支撑链、DAG、缺口、重构顺序：`lineage/ads_sc_xl_13/`
- 只读检查 SQL、对账 SQL、重构蓝图 SQL：`sql/`
- 审计运行留痕：`audit/ads_sc_xl_13/runs/`
- 交接打包：`handoff/ads_sc_xl_13_handoff_latest.zip`
