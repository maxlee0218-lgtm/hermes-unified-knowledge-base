# ADS_SC_XL_13 Dependency DAG

## 说明

`03_dependency_dag.csv` 记录的是当前可见链路中的依赖边，不仅包含主链，还包含：

- DataX -> ODS
- ODS -> DWD
- DWD -> ADS 中间层
- supporting chains
- dictionary mapping
- date skeleton
- manual confirm
- unknown / blocker 节点

## 当前读法

建议先看这几组边：

1. 主链
   - `dwd_mes_mm_task_group_output -> ads_sc_xl_13_process1`
   - `ads_sc_xl_13_process1 -> ads_sc_xl_13_defined`
   - `ads_sc_xl_13_defined -> ads_sc_xl_13_defined_manuf_line_name`
   - `ads_sc_xl_13_defined_manuf_line_name -> ads_sc_xl_13_defined_manuf_line_name_combined`
   - `combined -> _001/_002`

2. 支撑链
   - `with_attr_value -> combined`
   - `with_result_confirm -> combined`
   - `dim_date_info -> defined`
   - `ads_sc_xl_01 -> 生产入库量 / 成品入库量`
   - `dwd_silicon_steel_surface_info -> with_attr_value/销售库存支线`

3. 缺口链
   - `ods_mes_ums_tenant -> UNKNOWN tenant transform`
   - `ods_fair_ums_tenant -> UNKNOWN tenant transform`
   - `UNKNOWN tenant transform -> ods_mes_mdm_tenant / dim_ums_tenant`

## 当前重点

如果只关心重构顺序，先看：

- `date_skeleton`
- `dictionary_mapping`
- `manual_confirm`
- `aggregation`
- `projection`

这五类边基本决定了 `combined` 能不能复现。
