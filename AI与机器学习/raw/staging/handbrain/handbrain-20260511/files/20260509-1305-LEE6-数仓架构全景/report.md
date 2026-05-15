# PolarDB 数仓架构全景报告

> 生成时间：2026-05-09  
> 数据库：`hwpolardb-m-dev2.rwlb.rds.aliyuncs.com:5018`  
> 用户：`hw_dev_02`  
> 连接方式：SSH 隧道（150 本地 → 111 跳板机 → PolarDB）

---

## 一、数据库总览

| 数据库 | 表数量 | 估算数据量 | 业务领域 |
|--------|--------|-----------|---------|
| `aps_prd` | 1,082 | ~4.4 亿行 | APS 高级计划排产系统 |
| `aps_prd_20250621` | 38 | ~1,979 万行 | APS 新架构（待上线） |
| `da_dw` | 466 | ~2.8 亿行 | **数据仓库（核心）** |
| `hcrm_prd` | 193 | ~673 万行 | CRM 客户关系管理 |
| `hmdm_prd` | 92 | ~1,762 万行 | MDM 主数据管理 |
| `hupms_prd` | 86 | ~5.8 万行 | UPMS 统一权限管理 |
| `usrm_cloud_*` | 1,007 | 未统计 | USRM 供应链云平台（多模块） |
| `da_dolphin` | 67 | 未统计 | DolphinScheduler 调度平台 |
| `da_datax` | 12 | 未统计 | DataX 数据同步平台 |

> 注：`information_schema.TABLE_ROWS` 对 InnoDB 为估算值，部分库显示为 0 不代表空库。

---

## 二、数仓核心：`da_dw` 架构分层

`da_dw` 采用经典分层架构：

```
┌─────────────────────────────────────────┐
│              ADS 应用数据层              │  ← 174 张报表/指标表
│         （面向业务，直接消费）            │
├─────────────────────────────────────────┤
│              DWS 汇总数据层              │  ← 当前无独立表（逻辑在 DWD/ADS 中）
│         （主题宽表，跨域聚合）            │
├─────────────────────────────────────────┤
│              DWD 明细数据层              │  ← 64 张清洗后明细表
│         （统一粒度，业务过程）            │
├─────────────────────────────────────────┤
│              ODS 操作数据层              │  ← 156 张原始同步表
│         （贴源复制，保留原貌）            │
├─────────────────────────────────────────┤
│              DIM 维度表                  │  ← 4 张（日期、组织、仓库、租户）
├─────────────────────────────────────────┤
│              META 元数据层               │  ← 血缘、DQ、监控、ETL 调度
└─────────────────────────────────────────┘
```

### 2.1 各层规模

| 层级 | 表数 | 代表表 | 精确行数 |
|------|------|--------|---------|
| **ODS** | 156 | `ods_mes_mm_order_item_task` | 25,225,156 |
| | | `ods_mes_wms_wh_enter_item` | 11,248,076 |
| | | `ods_mes_wms_wh_output_item` | 11,413,303 |
| **DWD** | 64 | `dwd_mes_wms_current_stock_his` | 14,485,653 |
| | | `dwd_task_prod_actual` | 4,812,335 |
| **ADS** | 174 | `ads_sc_zl_15_detail` | 4,235,057 |
| | | `ads_sc_xl_01` | 3,039,875 |
| **DIM** | 4 | `dim_date_info` | 1,461 |
| **META/ETL** | ~20 | `etl_update_queue` | 5,684,165 |
| **其他** | 68 | `mm_task_prod_actual` | 5,571,427 |

---

## 三、核心表结构详解

### 3.1 ODS 层：贴源同步表

#### `ods_mes_mm_order_item_task`（生产工单项任务）
| 字段 | 类型 | 说明 |
|------|------|------|
| `task_inst_id` | bigint(20) PK | 任务实例ID |
| `order_item_id` | bigint(20) FK | 订单项ID |
| `task_inst_no` | int(11) | 任务实例序号 |
| `start_time` / `end_time` | datetime | 起止时间 |
| `machine_code` | varchar(50) | 机台编码 |
| `operation_code` | varchar(50) | 工序编码 |
| `handler` | varchar(50) | 处理人 |
| `task_status` | varchar(20) | 任务状态 |
| `tenant_id` | bigint(20) | 租户ID |
| `parent_task_id` | bigint(20) | 父任务ID（支持层级） |
| `make_order_num` | varchar(2000) | 制造订单号 |
| `schedule_thickness` | decimal(18,4) | 计划厚度 |

> 索引：复合索引覆盖 `tenant_id+status+machine_code`、`task_type+status+parent` 等高频查询场景。

#### `ods_mes_wms_wh_enter_item`（入库单明细）
| 字段 | 类型 | 说明 |
|------|------|------|
| `enter_item_id` | bigint(20) PK | 入库明细ID |
| `enter_id` | bigint(20) FK | 入库单ID |
| `sku_code` | varchar(50) | 物料编码 |
| `batch_code` | varchar(50) | 批次号 |
| `steel_grade` | varchar(50) | 钢种 |
| `spec` | varchar(100) | 规格 |
| `surface` | varchar(20) | 表面 |
| `grade` | varchar(10) | 等级 |
| `quantity` | decimal(18,4) | 数量 |
| `tax_price` / `price` | decimal(18,6) | 含税价/不含税价 |
| `weight` / `gross_weight` / `net_weight` | decimal(18,2) | 重量相关 |
| `act_height` / `act_width` | decimal(18,4) | 实际高/宽 |
| `coating_up_code` / `coating_down_code` | varchar(30) | 涂层编码 |
| `mo_code` | varchar(50) | 生产订单号 |
| `po_code` | varchar(20) | 采购订单号 |
| `in_batch_code` | varchar(50) | 来料批次 |
| `make_order_num` | varchar(1000) | 制造订单号 |
| `yield_rate` | decimal(18,2) | 成材率 |
| `prod_date` | datetime | 生产日期 |

> 字段极丰富（100+），覆盖硅钢全流程属性：钢种、规格、表面、涂层、磁性参数（`iron_loss`、`magnetoreception`）、力学参数（`hardness`、`gloss`、`elongation`）等。

#### `ods_mes_wms_wh_output_item`（出库单明细）
结构类似入库单，核心字段：
- `output_item_id` (PK), `output_id` (FK)
- `sku_code`, `batch_code`, `steel_grade`, `spec`, `surface`, `grade`
- `quantity`, `unit_price`, `amount`
- `net_weight`, `gross_weight`
- `mo_code`, `project_code`, `aps_cust_code`
- `rework_flag`（返工标记）

---

### 3.2 DWD 层：清洗后明细

#### `dwd_mes_wms_current_stock_his`（现存量历史快照）
| 字段 | 类型 | 说明 |
|------|------|------|
| `stock_inst_id` | bigint(20) | 库存实例ID |
| `top_cat_code` / `mid_cat_code` / `leaf_cat_code` | varchar(64) | 三级品类编码 |
| `sku_code` / `sku_name` | varchar(50/200) | 物料编码/名称 |
| `wh_code` / `wh_name` | varchar(50/200) | 仓库编码/名称 |
| `wh_class` | varchar(50) | 仓库类别 |
| `batch_code` | varchar(50) | 批次号 |
| `quantity` / `num` | decimal(20,6) | 数量/件数 |
| `ava_quantity` / `ava_num` | decimal(20,6) | 可用量/可用件数 |
| `lock_quantity` / `lock_num` | decimal(20,6) | 锁定量/锁定件数 |
| `plan_quantity` / `plan_num` | decimal(20,6) | 计划量 |
| `disable_quantity` / `disable_num` | decimal(20,6) | 冻结量 |
| `m_date` / `exp_date` | datetime | 生产日期/失效日期 |
| `data_date` | varchar(50) | 数据日期 |
| `days` | bigint(20) | 库龄天数 |
| `archive_date` / `archive_hour` | date / tinyint | 归档日期/小时（复合PK） |

> **设计特点**：按 `archive_date + archive_hour + tenant_id + stock_inst_id` 复合主键，支持小时级库存快照回溯。

#### `dwd_task_prod_actual`（生产实绩明细）
| 字段 | 类型 | 说明 |
|------|------|------|
| `actual_id` | bigint(20) PK | 实绩ID |
| `task_inst_id` | bigint(20) | 任务实例ID |
| `batch_code` / `in_batch_code` | varchar(50) | 批次/来料批次 |
| `steel_grade` / `steel_grade_type` | varchar(50) | 钢种/钢种类别 |
| `spec` | varchar(1000) | 规格 |
| `act_height` / `act_width` | decimal(18,4) | 实际高/宽 |
| `weight` / `gross_weight` / `net_weight` | decimal(18,2) | 重量 |
| `first_trial_time` / `first_trial_result` | datetime/varchar(20) | 首检时间/结果 |
| `retrial_time` / `retrial_result` | datetime/varchar(20) | 复检时间/结果 |
| `quality` | varchar(500) | 质量描述 |
| `sku_code` / `sku_name` | varchar(50/200) | 产出物料 |
| `coating_up_code` / `coating_down_code` | varchar(30) | 上下涂层 |
| `yield_rate` | decimal(18,2) | 成材率 |
| `waste_t_weight` | decimal(18,2) | 废料重量 |
| `data_date` | date | 数据日期 |
| `main_defect_code` / `main_defect_name` | varchar(50/255) | 主缺陷编码/名称 |
| `workshop_code` / `line_code` / `machine_code` | varchar(30/50) | 车间/产线/机台 |
| `manuf_line_code` / `manuf_line_name` | varchar(50/50) | 制造线 |
| `order_item_code` | varchar(50) | 订单项编码 |
| `mo_height` / `mo_width` / `mo_length` | decimal(18,4) | 订单规格 |

> 覆盖从原料投入到成品产出的全工序实绩，包含质量、工艺、设备、订单关联。

---

### 3.3 ADS 层：应用报表

#### `ads_sc_zl_15_detail`（质量报表明细）
字段结构与 `dwd_task_prod_actual` 高度一致，增加：
- `is_remove`（是否剔除）
- `month` / `year`（统计周期）
- `lower_amount`（降等金额）

#### `ads_sc_xl_01`（产量/销量报表）
| 字段 | 类型 | 说明 |
|------|------|------|
| `tenant_id` | bigint(20) | 租户 |
| `sku_code` / `sku_name` | varchar(50/100) | 物料 |
| `plate_type` / `products_type` | varchar(20) | 板型/产品类型 |
| `wh_code` / `wh_name` | varchar(30/100) | 仓库 |
| `dept_code` / `dept_name` | varchar(100) | 部门 |
| `machine_code` / `machine_name` | varchar(50) | 机台 |
| `steel_grade` / `steel_grade_series` | varchar(50/100) | 钢种/系列 |
| `surface` / `surface_thickness` | varchar(20)/bigint | 表面/厚度 |
| `spec` / `grade` | varchar(100)/varchar(10) | 规格/等级 |
| `weight` / `quantity` | decimal(40,2)/decimal(50,2) | 重量/数量 |
| `data_date` / `month` / `year` | varchar(10)/varchar(10)/int | 日期维度 |
| `bill_type` | varchar(30) | 单据类型 |
| `is_production_out` | bigint(20) | 是否生产出库 |

> 聚合粒度：物料+仓库+机台+日期，支持产销存分析。

---

### 3.4 DIM 层：维度表

#### `dim_date_info`（日期维度）
| 字段 | 类型 | 说明 |
|------|------|------|
| `date_id` | date PK | 日期 |
| `week_id` | varchar(30) | 周编码 |
| `week_day` | varchar(30) | 星期 |
| `day` / `month` / `quarter` / `year` | bigint/varchar | 日月季年 |
| `is_workday` | varchar(30) | 是否工作日 |
| `holiday_id` | varchar(30) | 节假日编码 |

---

## 四、表间关联关系

### 4.1 业务关联（通过字段隐式关联）

```
ods_mes_mm_order_item_task
    ├── task_inst_id ──→ dwd_task_prod_actual.task_inst_id
    ├── order_item_id ──→ ods_mes_mm_order_item.order_item_id
    └── machine_code ──→ dim_warehouse / 设备主数据

ods_mes_wms_wh_enter_item
    ├── enter_id ──→ ods_mes_wms_wh_enter.enter_id
    ├── sku_code ──→ 物料主数据
    ├── batch_code ──→ ods_mes_wms_batch_info.batch_code
    └── in_batch_code ──→ 上游产出批次

ods_mes_wms_wh_output_item
    ├── output_id ──→ ods_mes_wms_wh_output.output_id
    ├── sku_code ──→ 物料主数据
    └── batch_code ──→ 库存批次

dwd_task_prod_actual
    ├── batch_code ──→ 产出批次
    ├── in_batch_code ──→ 投入批次（自关联：上工序产出 = 下工序投入）
    ├── order_item_code ──→ 销售订单
    └── sku_code ──→ 产出物料
```

### 4.2 元数据层外键（显式约束）

| 表 | 外键字段 | 引用表 | 引用字段 |
|----|---------|--------|---------|
| `dq_check_result` | `rule_id` | `dq_rule_registry` | `rule_id` |
| `dq_check_result` | `run_id` | `ops_job_run_log` | `run_id` |
| `dq_rule_registry` | `table_id` | `meta_table_registry` | `table_id` |
| `lineage_edge` | `upstream_table_id` | `meta_table_registry` | `table_id` |
| `lineage_edge` | `downstream_table_id` | `meta_table_registry` | `table_id` |
| `lineage_edge` | `transform_job_id` | `ops_job_registry` | `job_id` |
| `meta_table_registry` | `source_id` | `meta_source_system` | `source_id` |
| `ops_job_registry` | `source_table_id` | `meta_table_registry` | `table_id` |
| `ops_job_registry` | `target_table_id` | `meta_table_registry` | `table_id` |
| `ops_job_run_log` | `job_id` | `ops_job_registry` | `job_id` |
| `mon_pipeline_stage_registry` | `pipeline_id` | `mon_pipeline_registry` | `pipeline_id` |
| `mon_stage_run_fact` | `stage_id` | `mon_pipeline_stage_registry` | `stage_id` |

---

## 五、ADS 层主题分类

| 主题域 | 表前缀 | 代表表 | 业务含义 |
|--------|--------|--------|---------|
| **供销-采购** | `ads_gx_cg_*` | `ads_gx_cg_07_detail` | 钢厂原料动态、合同预付款、降本 |
| **供销-销售** | `ads_gx_xs_*` | `ads_gx_xs_18_01` | 发货情况、销售明细 |
| **生产-库存** | `ads_sc_kc_*` | `ads_sc_kc_19_detail` | 成品库存、库龄、辅料仓 |
| **生产-计划** | `ads_sc_wk_*` | `ads_sc_wk_15_detail` | 坯料汇总/明细 |
| **生产-产量** | `ads_sc_xl_*` | `ads_sc_xl_01` | 产量统计、成材率、缺陷分析 |
| **质量** | `ads_sc_zl_*` | `ads_sc_zl_15_detail` | 质量明细、机台质量汇总 |
| **IHR-人事** | `ads_ihr_oa_*` | `ads_ihr_oa_01_detail` | OA/人事报表 |
| **物料成材率** | `ads_material_*` | `ads_material_yield_rate_detail` | 物料级成材率 |
| **质量设备** | `ads_quality_*` | `ads_quality_machine_summary` | 质量指标汇总 |

---

## 六、元数据与治理体系

### 6.1 已部署的治理表（结构完整，数据待填充）

| 表 | 用途 | 当前数据量 |
|----|------|-----------|
| `meta_source_system` | 源系统注册 | 0 |
| `meta_table_registry` | 表级元数据 | 0 |
| `ops_job_registry` | ETL 作业注册 | 0 |
| `ops_job_run_log` | 作业运行日志 | 0 |
| `lineage_edge` | 血缘关系 | 0 |
| `dq_rule_registry` | 数据质量规则 | 0 |
| `dq_check_result` | DQ 检查结果 | 0 |
| `mon_pipeline_registry` | 监控管道注册 | 10 |
| `mon_pipeline_stage_registry` | 管道阶段注册 | 19 |
| `mon_stage_run_fact` | 阶段运行事实 | 33 |
| `mon_alert_event` | 告警事件 | 未查询 |
| `mon_reconcile_rule_registry` | 对账规则 | 未查询 |
| `mon_reconcile_result` | 对账结果 | 未查询 |
| `metric_definition` | 指标定义 | 未查询 |
| `metric_run_result` | 指标运行结果 | 未查询 |

### 6.2 ETL 调度机制

- **调度引擎**：DolphinScheduler（`da_dolphin` 库）
- **增量同步**：`etl_update_queue`（568 万行）+ `dwd_update_tracker_v2`（增量水位表）
- **更新队列**：`dwd_*_update_queue` 系列表（如 `dwd_task_prod_actual_update_queue`）

---

## 七、数据量与增长趋势

### 7.1 da_dw 核心表精确行数

| 表名 | 层级 | 行数 | 数据特征 |
|------|------|------|---------|
| `ods_mes_mm_order_item_task` | ODS | 25,225,156 | 生产任务，持续增长 |
| `ods_mes_wms_wh_output_item` | ODS | 11,413,303 | 出库明细 |
| `ods_mes_wms_wh_enter_item` | ODS | 11,248,076 | 入库明细 |
| `dwd_mes_wms_current_stock_his` | DWD | 14,485,653 | 库存快照，小时级归档 |
| `dwd_task_prod_actual` | DWD | 4,812,335 | 生产实绩 |
| `ads_sc_zl_15_detail` | ADS | 4,235,057 | 质量报表 |
| `ads_sc_xl_01` | ADS | 3,039,875 | 产量报表 |
| `etl_update_queue` | ETL | 5,684,165 | 同步队列 |
| `mm_task_prod_actual` | OTHER | 5,571,427 | 生产实绩（原始） |

### 7.2 外部源库规模

| 数据库 | 估算总行数 | 说明 |
|--------|-----------|------|
| `aps_prd` | ~4.4 亿 | 排产系统，最大库 |
| `aps_prd_20250621` | ~1,979 万 | 新 APS，待切换 |
| `hmdm_prd` | ~1,762 万 | 主数据 |
| `hcrm_prd` | ~673 万 | CRM |

---

## 八、关键发现与备注

1. **分层规范**：`da_dw` 严格遵循 `ods_` / `dwd_` / `ads_` / `dim_` 前缀命名，易于识别。
2. **DWS 层缺失**：当前无独立 `dws_` 前缀表，主题宽表逻辑可能内嵌在 DWD 或 ADS 中。
3. **元数据空心化**：血缘、DQ、指标定义等治理表结构完整但数据为空，治理体系处于"框架已搭、内容待填"状态。
4. **监控体系有数据**：`mon_pipeline_registry` (10)、`mon_pipeline_stage_registry` (19)、`mon_stage_run_fact` (33) 有实际数据，说明监控管道已部分运行。
5. **增量同步成熟**：`etl_update_queue` + `dwd_update_tracker_v2` + 各 `update_queue` 表构成完整的增量同步体系。
6. **APS 双轨并行**：`aps_prd`（老）与 `aps_prd_20250621`（新）同时存在，注意切换风险。
7. **字段冗余度高**：ODS 层表字段极多（如 `ods_mes_wms_wh_enter_item` 100+ 字段），包含大量 `free1~free10` 扩展字段。
8. **硅钢业务特征**：表结构深度适配硅钢业务，包含磁性参数（铁损、磁感）、力学参数（硬度、光泽度、延伸率）、涂层参数等专属字段。

---

## 九、权限说明

- 用户 `hw_dev_02` 具备 `SELECT` 权限，可读取所有业务数据。
- 无 `INDEX`、`ALTER`、`PROCESS`、`ANALYZE` 权限，无法修改结构或查看进程。
- 本次摸排仅执行 `SHOW`、`DESCRIBE`、`SELECT COUNT(*)` 等只读操作，未触碰生产数据。
