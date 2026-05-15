# ADS_SC_XL_13 Manifest

## 锚点

- 目标表：`ads_sc_xl_13_defined_manuf_line_name_combined_002`
- 所在库：`da_dw`
- 表类型：`BASE TABLE`

## 稳定链

- 工作流：`18333852605952` `产量日报表（ADS_SC_XL_13）`
- 终端任务：
  - `18333852605973` -> `_001`
  - `21226918778112` -> `_002`

## 关键上游

- `18334034498304` `班组产能（dwd_mes_hmes_mm_task_group_output）`
- `18341376834048` `生产实绩（dwd_task_prod_actual）`
- `18340742659072` `入库单（dwd_mes_hmes_wms_wh_enter_item）`

## 关键 DataX 作业

- `25` `mm_task_group_output（增量）`
- `24` `mm_task_prod_actual（增量）`
- `31` `wms_wh_enter（增量）`
- `32` `wms_wh_enter_item（增量）`
- `17` `wms_batch_info（增量）`

## 当前状态

- 主链已摸清
- 支线已分层
- 目标表已锚定
- DataX ODS 同步链已大体收齐
- tenant 维最终转换闭环仍未显式暴露
