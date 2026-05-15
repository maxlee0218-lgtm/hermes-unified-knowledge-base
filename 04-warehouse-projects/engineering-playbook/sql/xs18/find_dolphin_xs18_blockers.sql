SELECT
    p.name AS project_name,
    pd.name AS process_name,
    pd.code AS process_code,
    pd.version AS process_version,
    pd.release_state,
    td.name AS task_name,
    td.code AS task_code,
    td.version AS task_version,
    td.task_type,
    td.flag,
    CONCAT_WS(',',
        IF(td.task_params LIKE '%ods_crm_sa_sales_delivery_order_detail%', 'sales_detail', NULL),
        IF(td.task_params LIKE '%with_attr_value%', 'with_attr_value', NULL),
        IF(td.task_params LIKE '%ads_gx_xs_18_detail%', 'xs18_detail', NULL),
        IF(td.task_params LIKE '%ods_crm_sa_sales_delivery_order%', 'sales_order', NULL),
        IF(td.task_params LIKE '%ods_mes_wms_batch_info%', 'batch_info', NULL),
        IF(td.task_params LIKE '%dwd_silicon_steel_surface_info%', 'surface_info', NULL)
    ) AS hit_tables
FROM t_ds_task_definition td
LEFT JOIN t_ds_process_task_relation r
    ON r.post_task_code = td.code
   AND r.post_task_version = td.version
   AND r.project_code = td.project_code
LEFT JOIN t_ds_process_definition pd
    ON pd.code = r.process_definition_code
   AND pd.version = r.process_definition_version
   AND pd.project_code = r.project_code
LEFT JOIN t_ds_project p
    ON p.code = td.project_code
WHERE td.task_params LIKE '%ods_crm_sa_sales_delivery_order_detail%'
   OR td.task_params LIKE '%with_attr_value%'
   OR td.task_params LIKE '%ads_gx_xs_18_detail%'
   OR td.task_params LIKE '%ods_crm_sa_sales_delivery_order%'
   OR td.task_params LIKE '%ods_mes_wms_batch_info%'
   OR td.task_params LIKE '%dwd_silicon_steel_surface_info%'
ORDER BY pd.release_state DESC, process_name, task_name;
