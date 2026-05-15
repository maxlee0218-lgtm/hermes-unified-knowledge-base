# ADS_SC_XL_13 支撑链

## A. `with_attr_value` 链

- 来源是否是 `ods_mes_sys_attr_value`
  - 不是直接同义替代
  - `with_attr_value` 自身是配置/映射结果表
  - 它大量依赖业务维护和其他流程回填
- 是否经过 `dwd_silicon_steel_surface_info`
  - 部分支线会结合 `dwd_silicon_steel_surface_info`
  - 例如硅钢销售/库存类细分映射
- 映射了哪些字段
  - `attr1`
  - `manuf_line_name`
  - 仓库
  - 单据类型
  - 产线
  - 牌号/表面分类
- 对 `attr1 / manuf_line_name / 仓库 / 单据类型 / 产线` 的影响
  - 决定 `plate_type`
  - 决定 `defined_manuf_line_name`
  - 决定 `rk`
  - 决定哪些入库单据进入 `ads_sc_xl_01`
  - 决定哪些成品/现存量进入支线汇总

## B. `with_result_confirm` 链

- 来源表
  - `with_result_confirm`
- report_id 过滤条件
  - `237`
  - `239`
  - `543`
- 停机时间覆盖逻辑
  - `day_breakdown_frequency`
  - `day_planned_downtime`
  - `day_unplanned_downtime`
  - `month_*` 同类字段
- 备注覆盖逻辑
  - `remark`
- 人工确认字段影响
  - 直接影响 `combined` 层每日和月累计停机指标
  - 这不是原始事实表能直接推出来的，需要人工确认结果叠加

## C. `dim_date_info` 链

- 日期骨架在哪一层引入
  - `ads_sc_xl_13_defined`
- 是否负责补零行
  - 是
- 对 `baseline_only` 零行的影响
  - 当前大量 `baseline_only = 0 weight` 都来自这个补零逻辑
- 当前是否可复刻
  - 可以开始复刻
  - 当前状态应视为“可执行待验证”
- 验收 SQL
  - `sql/inspect/ads_sc_xl_13/inspect_dim_date_info.sql`
  - `sql/recon/ads_sc_xl_13/recon_dim_date_zero_fill.sql`

## D. `ads_sc_xl_01` 链

- 是否提供生产入库量
  - 是
- 是否提供成品入库量
  - 是
- 是直接 join 还是通过 CTE 加工
  - 作为支撑事实表被后续任务直接 join / group / window 聚合

## E. tenant 链

- `ods_mes_ums_tenant`
  - 已确认有 DataX 全量同步
- `ods_fair_ums_tenant`
  - 已确认有 DataX 全量同步
- `ods_mes_mdm_tenant`
  - 已确认为物理表
  - 被 `dwd_mes_wms_current_stock` 等读取
- `dim_ums_tenant`
  - 已确认为物理表
  - 被 `入库单` 和销售明细链读取
- 哪些已经闭合
  - `ums_tenant -> ods_mes_ums_tenant`
  - `ums_tenant -> ods_fair_ums_tenant`
- 哪些还缺转换任务
  - `ods_mes_ums_tenant / ods_fair_ums_tenant -> ods_mes_mdm_tenant / dim_ums_tenant`
  - 当前环境里没有显式 Dolphin/DataX/DB object 生产链

## F. `dwd_silicon_steel_surface_info` 链

- 是否来自 `ods_mes_sys_attr_value`
  - 是
- 是否已确认由维度表工作流产出
  - 是
  - workflow `18266359629824`
  - task `18266359629952`
  - task name `硅钢表面属性(dwd_silicon_steel_surface_info)`

## 当前判断

- `with_attr_value`
  - 已知消费面很大
  - 是 XL13 支撑链里的高影响对象
  - 当前只能说“可分段复刻”，不能说“整体闭合”
- `with_result_confirm`
  - 是停机时间和备注逻辑的唯一显式人工覆盖入口
- `dim_date_info`
  - 是补零行和连续日期的唯一显式骨架
  - 当前可进入本地复刻验证
- `ads_sc_xl_01`
  - 是入库量相关链路的核心支撑
- tenant 链
  - 仍是剩余显式缺口
