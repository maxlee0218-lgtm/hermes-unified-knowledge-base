# Dolphin Process Chain 18334034498304

- Project: `生产-通用`
- Process name: `班组产能（dwd_mes_hmes_mm_task_group_output）`
- Release state: `1`
- Updated at: `2026-04-25 11:40:12`

## Relations

- START -> `班组产能（dwd_mes_hmes_mm_task_group_output）`

## Tasks

### `班组产能（dwd_mes_hmes_mm_task_group_output）`

- Code: `18334034498312`
- Type: `SQL`
- Upstream nodes: `START`
- Downstream nodes: `END`
- Write tables: `dwd_mes_mm_task_group_output_update_queue`, `dwd_mes_mm_task_group_output`, `dwd_update_tracker`, `sku_name`
- Read tables: `dwd_mes_mm_task_group_output_update_queue`, `ods_mes_mm_task_group_output`, `dwd_update_tracker`, `ods_mes_pm_stat_cat_sku`, `ods_mes_sys_attr_value`, `ods_mes_mm_task_prod_actual`, `ods_mes_pm_stat_cat`, `ods_mes_mm_order_item_task`, `ods_mes_mm_order_item`, `ods_mes_pm_sku`, `ods_mes_mm_machine_group`, `ods_mes_mm_machine`, `ods_mes_mm_workcenter`, `with_attr_value`, `dwd_silicon_steel_surface_info`

```sql
START TRANSACTION;
DELETE
FROM
    dwd_mes_mm_task_group_output_update_queue;
INSERT INTO dwd_mes_mm_task_group_output_update_queue (id, modified_time) SELECT DISTINCT
                                                                              a.id,
                                                                              NOW()
FROM
    ods_mes_mm_task_group_output a
        JOIN ods_mes_mm_task_prod_actual b ON b.actual_id = a.actual_id
WHERE
    b.r_modified_time >= (SELECT last_updated FROM dwd_update_tracker WHERE table_name = 'dwd_mes_mm_task_group_output')
  AND b.r_modified_time <= NOW() UNION SELECT id, NOW() FROM ods_mes_mm_task_group_output WHERE r_modified_time >= (SELECT last_updated FROM dwd_update_tracker WHERE table_name = 'dwd_mes_mm_task_group_output')
                                                                                            AND r_modified_time <= NOW();
UPDATE dwd_update_tracker
SET last_updated = NOW() - INTERVAL 1 HOUR
WHERE
    table_name = 'dwd_mes_mm_task_group_output';
INSERT INTO dwd_mes_mm_task_group_output (
    id,
    sku_code,
    sku_name,
    batch_code,
    actual_id,
    steel_grade,
    spec,
    surface,
    grade,
    inner_grade,
    weight,
    quantity,
    roll_length,
    group_id,
    group_name,
    group_leader,
    cat_name,
    steel_grade_series,
    date_time,
    start_time,
    end_time,
    data_date,
    MONTH,
    YEAR,
    tenant_id,
    rate             ,
    rate_unit     ,
    rate_type        ,
    theory_use_time,
    actual_use_time,
    send_happened,
    is_ignore,
    manuf_line_code,
    manuf_line_name,
    sku_type,
    r_modified_time,r_modified_date,
    is_retention,is_baf, proce_note ,
    flaw_describe,
    split_in_weight,
    yield_rate,next_machine_code ,
    next_sku_code ) SELECT
                        a.id,
                        b.sku_code,
                        sku.sku_name,
                        b.batch_code,
                        b.actual_id,
                        b.steel_grade,
                        b.spec,
                        b.surface,
                        b.grade,
                        b.inner_grade,
                        a.weight,
                        a.quantity,
                        a.meter_num AS roll_length,
                        a.group_id AS group_id,
                        a.group_code AS group_name,
                        mg.group_leader AS group_leader,
                        IFNULL(
                                (
                                    SELECT
                                        d.cat_name
                                    FROM
                                        ods_mes_pm_stat_cat_sku c
                                            JOIN ods_mes_pm_stat_cat d ON c.top_cat_code = d.cat_code
                                    WHERE
                                        c.sku_code = b.sku_
```
