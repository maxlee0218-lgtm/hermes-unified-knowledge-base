# Dolphin Process Chain 18340742659072

- Project: `生产-通用`
- Process name: `入库单（dwd_mes_hmes_wms_wh_enter_item）`
- Release state: `1`
- Updated at: `2026-04-09 16:17:14`

## Relations

- START -> `入库单（dwd_mes_hmes_wms_wh_enter_item）`
- `入库单（dwd_mes_hmes_wms_wh_enter_item）` -> `ads_sc_xl_01(入库量)`

## Tasks

### `入库单（dwd_mes_hmes_wms_wh_enter_item）`

- Code: `18340742659073`
- Type: `SQL`
- Upstream nodes: `START`
- Downstream nodes: `ads_sc_xl_01(入库量)`
- Write tables: `dwd_mes_wms_wh_enter_item_update_queue`, `dwd_mes_wms_wh_enter_item`, `dwd_mes_wms_wh_enter_item_process1`, `dwd_mes_wms_wh_enter_item_process2`, `modified_time`, `dwd_update_tracker`, `ven_code`, `machine_code`
- Read tables: `ods_mes_wms_wh_enter_item`, `dwd_update_tracker`, `ods_mes_wms_wh_enter`, `ods_mes_pm_stat_cat_sku`, `dwd_mes_wms_wh_enter_item_update_queue`, `dwd_mes_wms_wh_enter_item_process2`, `dwd_mes_wms_wh_enter_item`, `with_attr_value`, `dwd_wh_output_item`, `ods_mes_pm_stat_cat`, `ods_mes_pm_sku`, `ods_mes_sys_supplier`, `ods_mes_sys_department`, `ods_mes_wms_batch_info`, `ods_mes_sys_attr_value`, `ods_mes_wms_warehouse`, `ods_mes_mm_order_item_task`, `ods_mes_mm_order_item`, `ods_mes_mm_task_wh_enter`, `ods_mes_mm_task_prod_actual`, `dwd_mes_wms_wh_enter_item_process1`, `dwd_silicon_steel_surface_info`, `ranked_data`, `ods_mes_mm_machine`, `dim_ums_tenant`, `ods_mes_pu_purchase_arrival_item`

```sql
START TRANSACTION;
INSERT INTO dwd_mes_wms_wh_enter_item_update_queue ( id, table_name, type ,modified_time )
SELECT
    enter_item_id id,
    'dwd_mes_wms_wh_enter_item',
    'enter_item_id' type ,
    NOW()
FROM
    ods_mes_wms_wh_enter_item
WHERE
    r_modified_time >= (SELECT last_updated from dwd_update_tracker where table_name = 'dwd_mes_wms_wh_enter_item' )
  AND r_modified_time <= now()
ON DUPLICATE KEY UPDATE modified_time = NOW();

INSERT INTO dwd_mes_wms_wh_enter_item_update_queue ( id, table_name, type ,modified_time )
SELECT
    enter_item_id id,
    'dwd_mes_wms_wh_enter_item' table_name,
    'enter_item_id' type ,
    NOW() modified_time
FROM
    ods_mes_wms_wh_enter en
        INNER JOIN ods_mes_wms_wh_enter_item ei ON en.enter_id = ei.enter_id
WHERE
    en.r_modified_time >=  (SELECT last_updated from dwd_update_tracker where table_name = 'dwd_mes_wms_wh_enter_item' )
  AND en.r_modified_time <= now()
ON DUPLICATE KEY UPDATE modified_time = NOW();

INSERT INTO dwd_mes_wms_wh_enter_item_update_queue ( id, table_name, type ,modified_time )
SELECT distinct
    batch_code id,
    'dwd_mes_wms_wh_enter_item',
    'batch_code' type ,
    NOW()
FROM
    ods_mes_wms_wh_enter_item
WHERE
    r_modified_time >= (SELECT last_updated from dwd_update_tracker where table_name = 'dwd_mes_wms_wh_enter_item' )
  AND r_modified_time <= now()
ON DUPLICATE KEY UPDATE modified_time = NOW();

INSERT INTO dwd_mes_wms_wh_enter_item_update_queue ( id, table_name,type , modified_time )
SELECT distinct
    ei.batch_code id,
    'dwd_mes_wms_wh_enter_item' table_name,
    'batch_code' type ,
    NOW() modified_time
FROM
    ods_mes_wms_wh_enter en
        INNER JOIN ods_mes_wms_wh_enter_item ei ON en.enter_id = ei.enter_id
WHERE
    en.r_modified_time >=  (SELECT last_updated from dwd_update_tracker where table_name = 'dwd_mes_wms_wh_enter_item' )
  AND en.r_modified_time <= now()
ON DUPLICATE KEY UPDATE modified_time = NOW();


update dwd_update_tracker SET last_updated = NOW() - INTERVAL 300 MINUTE    where table_name = 'dwd_mes_wms_wh_enter_item' ;

INSERT INTO dwd_mes_wms_wh_enter_item (
    ven_code,
    wh_code,
    wh_name,
    wh_class,
    is_pre_purchase,
    bred_vouch,
    enter_date,
    enter_code,
    rd_style,
    rd_style_name,
    checked_time,
    data_date,
    work_data_date,
    MONTH,
    YEAR,
    checked_by,
    en_note,
    bill_type,
    dept_code,
    rd_flag,
    source,
    verify_status,
    u8_enter_id,
    u8_enter_code,
    print_times,
    enter_item_id,
    enter_id,
    row_no,
    sku_code,
    model,
    unit,
    batch_code,
    steel_grade,
    steel_grade_series,
    spec,
    surface,
    grade,
    producer,
    quantity,
    tax_price,
    tax_amount,
    price,
    amount,
    roll_length,
    voucher_no,
    weight,
    note,
    tenant_id,
    u8_enter_item_id,
    bill_status,
    row_ver,
    en_STATU
```

### `ads_sc_xl_01(入库量)`

- Code: `18340742659074`
- Type: `SQL`
- Upstream nodes: `入库单（dwd_mes_hmes_wms_wh_enter_item）`
- Downstream nodes: `END`
- Write tables: `ads_sc_xl_01`
- Read tables: `ads_sc_xl_01`, `dwd_mes_wms_wh_enter_item`

```sql

DELETE
FROM
    ads_sc_xl_01
WHERE
    data_date >= CURRENT_DATE - INTERVAL 35 DAY;
INSERT INTO ads_sc_xl_01 (
    products_category,
    plate_type,
    products_type,
    tenant_id,
    sku_code,
    sku_name,
    wh_code,
    wh_name,
    dept_code,
    dept_name,
    machine_code,
    machine_name,
    other_machine_code,
    other_machine_name,
    rd_style,
    rd_style_name,
    top_cat_name,
    steel_grade_series,
    steel_grade,
    surface,
    surface_thickness,
    surface_number,
    surface_middle_part,
    grade,
    spec,
    weight,
    quantity,
    roll_length,
    iron_loss,
    data_date,
    MONTH,
    YEAR,
    sync_time,
    bill_type,
    is_production_out) SELECT
                           a.products_category,
                           a.plate_type,
                           a.products_type,
                           a.tenant_id,
                           sku_code,
                           sku_name,
                           wh_code,
                           wh_name,
                           dept_code,
                           dept_name,
                           machine_code,
                           machine_name,
                           other_machine_code,
                           other_machine_name,

                           rd_style,
                           rd_style_name,
                           top_cat_name,
                           steel_grade_series,
                           steel_grade,
                           surface,
                           surface_thickness,
                           surface_number,
                           surface_middle_part,
                           grade,
                           spec,
                           SUM(weight) AS weight,
                           SUM(quantity) AS quantity,
                           SUM(roll_length) roll_length,
                           avg(iron_loss) iron_loss,
                           data_date,
                           MONTH,
                           YEAR,
                           NOW() AS sync_time,
                           bill_type,
                           is_production_out
FROM
    dwd_mes_wms_wh_enter_item a
WHERE
    verify_status = '2'
  AND bill_type IN (1, 2)
  AND data_date >= CURRENT_DATE - INTERVAL 35 DAY
  AND ((dept_code = '160502005' AND machine_code = 'CS02' AND parent_batch_code NOT LIKE '%-RD')
    OR (dept_code <> '160502005' OR machine_code <> 'CS02'))

GROUP BY
    a.tenant_id,
    sku_code,
    sku_name,
    wh_code,
    wh_name,
    dept_code,
    dept_name,
    machine_code,
    other_machine_code,

    rd_style,
    rd_style_name,
    top_cat_name,
    steel_grade_series,
    steel_grade,
    surface,
    surface_thickness,
    surface_number,
    surface_middle_part,
    grade,
    spec,
    data_date,
    MONTH,
    YEAR,
    bill_type,
    is_production_
```
