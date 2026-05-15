# with_attr_value Scene Matrix

## 总体判断

`with_attr_value` 不是单一 ODS 镜像，而是一个被多个工作流读写、承载业务映射规则的配置/结果表。

对 `ADS_SC_XL_13` 来说，它不是“可有可无的维表”，而是 `combined` 上游的高影响支撑对象。

## 场景矩阵

### 1. `attr1` 映射

- 使用位置：
  - `dwd_mes_mm_task_group_output`
  - `ads_sc_xl_13_process1`
  - `combined`
- 影响字段：
  - `attr1`
- 来源字段：
  - `machine_code`
  - `steel_grade`
  - `surface/spec` 派生
- join key：
  - `tenant_id`
  - `attribute2 = machine_code`
- filter 条件：
  - `scene in BI-SC-KC-013-DEFINED-TYPE-*`
- 是否依赖 `ods_mes_sys_attr_value`：
  - 间接依赖
- 是否依赖 `dwd_silicon_steel_surface_info`：
  - 部分分支依赖
- 是否能直接复刻：
  - 部分可以
- 是否阻塞 `combined`：
  - 是
- 验收 SQL：
  - `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`

### 2. `manuf_line_name` 映射

- 使用位置：
  - `dwd_mes_mm_task_group_output`
  - `defined_manuf_line_name`
  - `combined`
- 影响字段：
  - `defined_manuf_line_name`
  - `manuf_line_name`
- 来源字段：
  - `machine_code`
- join key：
  - `tenant_id`
  - `attribute2 = machine_code`
- filter 条件：
  - `scene in BI-SC-KC-013-DEFINED-TYPE-*`
- 是否依赖 `ods_mes_sys_attr_value`：
  - 间接依赖
- 是否依赖 `dwd_silicon_steel_surface_info`：
  - 否，主路径不直接依赖
- 是否能直接复刻：
  - 部分可以
- 是否阻塞 `combined`：
  - 是
- 验收 SQL：
  - `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`

### 3. `defined_manuf_line_name` 映射

- 使用位置：
  - `dwd_mes_mm_task_group_output`
- 影响字段：
  - `defined_manuf_line_name`
- 来源字段：
  - `attribute1`
- join key：
  - `tenant_id`
  - `attribute2 = machine_code`
- filter 条件：
  - `scene in BI-SC-KC-013-DEFINED-TYPE-LZ/JJG/GG`
- 是否依赖 `ods_mes_sys_attr_value`：
  - 间接
- 是否依赖 `dwd_silicon_steel_surface_info`：
  - 否
- 是否能直接复刻：
  - 是，但要按租户/scene 拆
- 是否阻塞 `combined`：
  - 是
- 验收 SQL：
  - `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`

### 4. 仓库映射

- 使用位置：
  - `ads_sc_xl_01`
  - 生产入库量
  - 成品入库量
- 影响字段：
  - 仓库是否纳入
  - 仓库对应产线
- 来源字段：
  - `wh_code`
  - `dept_code`
  - `steel_grade`
  - `sku_code`
  - `machine_code`
- join key：
  - `tenant_id`
  - `attribute2/3/4/5/6`
- filter 条件：
  - `scene like BI-SC-KC-013-WH-CODE-*`
- 是否依赖 `ods_mes_sys_attr_value`：
  - 否
- 是否依赖 `dwd_silicon_steel_surface_info`：
  - 否
- 是否能直接复刻：
  - 部分可以
- 是否阻塞 `combined`：
  - 是
- 验收 SQL：
  - `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`

### 5. 单据类型映射

- 使用位置：
  - `ads_sc_xl_01`
  - 成品入库量
- 影响字段：
  - 哪些 `rd_style / rd_style_name` 纳入统计
- 来源字段：
  - `rd_style`
  - `rd_style_name`
- join key：
  - `tenant_id`
  - `attribute1`
- filter 条件：
  - `scene like BI-SC-KC-013-RD-FINISHED-*`
- 是否依赖 `ods_mes_sys_attr_value`：
  - 否
- 是否依赖 `dwd_silicon_steel_surface_info`：
  - 否
- 是否能直接复刻：
  - 部分可以
- 是否阻塞 `combined`：
  - 是
- 验收 SQL：
  - `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`

### 6. 产线映射

- 使用位置：
  - `combined`
  - `rk`
  - 展示排序
- 影响字段：
  - `rk`
  - `group_manuf_line_name`
  - `manuf_line_name`
- 来源字段：
  - `attribute4`
  - `list_order`
- join key：
  - `tenant_id`
  - `attribute4 = manuf_line_name`
- filter 条件：
  - `scene in BI-SC-KC-013-DEFINED-PLATE-*`
- 是否依赖 `ods_mes_sys_attr_value`：
  - 否
- 是否依赖 `dwd_silicon_steel_surface_info`：
  - 否
- 是否能直接复刻：
  - 是
- 是否阻塞 `combined`：
  - 是
- 验收 SQL：
  - `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`

### 7. 牌号 / 表面分类映射

- 使用位置：
  - 硅钢销售/库存支线
  - `dwd_silicon_steel_surface_info`
- 影响字段：
  - `surface_thickness`
  - `surface_number`
  - 硅钢产品大类
- 来源字段：
  - `surface`
- join key：
  - `surface`
- filter 条件：
  - `silicon_steel_product_category_code`
- 是否依赖 `ods_mes_sys_attr_value`：
  - 是
- 是否依赖 `dwd_silicon_steel_surface_info`：
  - 是
- 是否能直接复刻：
  - 是
- 是否阻塞 `combined`：
  - 间接阻塞
- 验收 SQL：
  - `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`

### 8. `ads_sc_xl_01` 相关映射

- 使用位置：
  - `ads_sc_xl_01`
  - 生产入库量
  - 成品入库量
- 影响字段：
  - 产线映射
  - 仓库筛选
  - 单据类型筛选
- 来源字段：
  - `wh_code`
  - `dept_code`
  - `machine_code`
  - `other_machine_code`
  - `rd_style_name`
- join key：
  - 多字段组合
- filter 条件：
  - `scene like BI-SC-KC-013-WH-CODE-*`
  - `scene like BI-SC-KC-013-RD-FINISHED-*`
- 是否依赖 `ods_mes_sys_attr_value`：
  - 否
- 是否依赖 `dwd_silicon_steel_surface_info`：
  - 否
- 是否能直接复刻：
  - 部分可以
- 是否阻塞 `combined`：
  - 是
- 验收 SQL：
  - `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`

### 9. `combined` 相关映射

- 使用位置：
  - `ads_sc_xl_13_defined_manuf_line_name_combined`
- 影响字段：
  - `plate_type`
  - `manuf_line_name`
  - `rk`
  - 合计/总计形成前的主维度
- 来源字段：
  - `attribute4`
  - `attribute5`
  - `list_order`
- join key：
  - `tenant_id`
  - `manuf_line_name`
- filter 条件：
  - `scene in BI-SC-KC-013-DEFINED-PLATE-*`
- 是否依赖 `ods_mes_sys_attr_value`：
  - 间接
- 是否依赖 `dwd_silicon_steel_surface_info`：
  - 间接
- 是否能直接复刻：
  - 部分可以
- 是否阻塞 `combined`：
  - 是，当前主阻塞点之一
- 验收 SQL：
  - `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`

## 当前结论

- `with_attr_value` 可以开始按 scene 矩阵分段复刻
- 但不能说已经“完整可复刻”
- 当前状态更准确的说法是：
  - **可分段复刻**
  - **未整体闭合**
  - **当前不允许直接跳到完整 `combined_local` 重构**
