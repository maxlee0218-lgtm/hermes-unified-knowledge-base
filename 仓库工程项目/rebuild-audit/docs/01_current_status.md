# 当前状态

## 已知主链

`dwd_mes_mm_task_group_output`
-> `ads_sc_xl_13_process1`
-> `ads_sc_xl_13_defined`
-> `ads_sc_xl_13_defined_manuf_line_name`
-> `ads_sc_xl_13_defined_manuf_line_name_combined`
-> `ads_sc_xl_13_defined_manuf_line_name_combined_001`
-> `ads_sc_xl_13_defined_manuf_line_name_combined_002`

## 已知判断

- `combined_002` 最终投影已经可以本地 `0 diff`
- 当前差异重点不在 `combined_002` 壳层
- 当前差异重点在 `combined` 上游中间逻辑

## 当前重点缺口

1. `with_attr_value`
2. `with_result_confirm`
3. `dim_date_info`
4. `ads_sc_xl_01`
5. tenant 链
6. 合计 / 总计后置行

## 当前稳定工作流

- `18334034498304` 班组产能（`dwd_mes_hmes_mm_task_group_output`）
- `18341376834048` 生产实绩（`dwd_task_prod_actual`）
- `18340742659072` 入库单（`dwd_mes_hmes_wms_wh_enter_item`）
- `18333852605952` 产量日报表（`ADS_SC_XL_13`）

## 当前稳定终端任务

- `18333852605973` `BI_SC_XL_013_DEFINED_MANUF_LINE_NAME_COMBINED_001`
- `21226918778112` `BI_SC_XL_013_DEFINED_MANUF_LINE_NAME_COMBINED_002`

## 当前候选重构链

- `21459078230272` `产量日报表（ADS_SC_XL_13）_003_全链路重构_v3`

当前这条 `003` 链仅作为候选对照，不作为稳定验收链。
