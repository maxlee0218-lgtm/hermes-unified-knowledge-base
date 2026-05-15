# 当前架构

## 1. 生产运行架构

当前 `ADS_SC_XL_13` 相关链路运行在三层：

1. 业务源层
   - `hmes_prd`
2. 同步层
   - `DataX`
3. 编排与数仓层
   - `DolphinScheduler`
   - `da_dw`

## 2. 业务到 ADS 主路径

业务源路径：

- `hmes_prd.mm_task_group_output`
- `hmes_prd.mm_task_prod_actual`
- `hmes_prd.wms_wh_enter`
- `hmes_prd.wms_wh_enter_item`
- `hmes_prd.wms_batch_info`

DataX ODS 路径：

- `ods_mes_mm_task_group_output`
- `ods_mes_mm_task_prod_actual`
- `ods_mes_wms_wh_enter`
- `ods_mes_wms_wh_enter_item`
- `ods_mes_wms_batch_info`

Dolphin DWD/ADS 路径：

- `dwd_mes_mm_task_group_output`
- `dwd_task_prod_actual`
- `dwd_mes_wms_wh_enter_item`
- `ads_sc_xl_01`
- `ads_sc_xl_13_process1`
- `ads_sc_xl_13_defined`
- `ads_sc_xl_13_defined_manuf_line_name`
- `ads_sc_xl_13_defined_manuf_line_name_combined`
- `ads_sc_xl_13_defined_manuf_line_name_combined_001`
- `ads_sc_xl_13_defined_manuf_line_name_combined_002`

## 3. 支撑链架构

这条链不是只有主路径，还依赖以下支撑对象：

- `with_attr_value`
- `with_result_confirm`
- `dim_date_info`
- `ads_sc_xl_01`
- `dwd_silicon_steel_surface_info`
- `ods_mes_mdm_tenant`
- `dim_ums_tenant`
- `ods_mes_ums_tenant`
- `ods_fair_ums_tenant`

## 4. 当前运行特征

已确认稳定运行的关键工作流：

- `班组产能`
- `生产实绩`
- `入库单`
- `产量日报表（ADS_SC_XL_13）`

所以当前问题不在“调度不跑”，而在“中间业务逻辑是否完整重构”。
