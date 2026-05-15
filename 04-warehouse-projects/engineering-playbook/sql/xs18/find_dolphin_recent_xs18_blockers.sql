SELECT
    pi.name AS process_instance,
    pi.process_definition_code,
    pi.state AS process_state,
    pi.start_time AS process_start,
    pi.end_time AS process_end,
    ti.name AS task_instance,
    ti.task_code,
    ti.state AS task_state,
    ti.start_time AS task_start,
    ti.end_time AS task_end,
    CONCAT_WS(',',
        IF(ti.task_params LIKE '%ods_crm_sa_sales_delivery_order_detail%', 'sales_detail', NULL),
        IF(ti.task_params LIKE '%with_attr_value%', 'with_attr_value', NULL),
        IF(ti.task_params LIKE '%ads_gx_xs_18_detail%', 'xs18_detail', NULL),
        IF(ti.task_params LIKE '%ods_crm_sa_sales_delivery_order%', 'sales_order', NULL),
        IF(ti.task_params LIKE '%ods_mes_wms_batch_info%', 'batch_info', NULL),
        IF(ti.task_params LIKE '%dwd_silicon_steel_surface_info%', 'surface_info', NULL)
    ) AS hit_tables
FROM t_ds_task_instance ti
JOIN t_ds_process_instance pi
    ON pi.id = ti.process_instance_id
WHERE (
       ti.task_params LIKE '%ods_crm_sa_sales_delivery_order_detail%'
    OR ti.task_params LIKE '%with_attr_value%'
    OR ti.task_params LIKE '%ads_gx_xs_18_detail%'
    OR ti.task_params LIKE '%ods_crm_sa_sales_delivery_order%'
    OR ti.task_params LIKE '%ods_mes_wms_batch_info%'
    OR ti.task_params LIKE '%dwd_silicon_steel_surface_info%'
)
AND (
       ti.end_time IS NULL
    OR ti.start_time >= DATE_SUB(NOW(), INTERVAL 2 HOUR)
    OR pi.end_time IS NULL
)
ORDER BY COALESCE(ti.end_time, NOW()) DESC, ti.start_time DESC
LIMIT 100;
