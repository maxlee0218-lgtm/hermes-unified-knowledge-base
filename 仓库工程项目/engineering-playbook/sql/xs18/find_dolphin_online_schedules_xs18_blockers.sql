SELECT DISTINCT
    p.name AS project_name,
    pd.name AS process_name,
    pd.code AS process_code,
    pd.version AS process_version,
    pd.release_state AS process_release_state,
    s.id AS schedule_id,
    s.release_state AS schedule_release_state,
    s.crontab,
    GROUP_CONCAT(DISTINCT td.name ORDER BY td.name SEPARATOR ' | ') AS hit_tasks,
    GROUP_CONCAT(DISTINCT
        CONCAT_WS(',',
            IF(td.task_params LIKE '%ods_crm_sa_sales_delivery_order_detail%', 'sales_detail', NULL),
            IF(td.task_params LIKE '%with_attr_value%', 'with_attr_value', NULL),
            IF(td.task_params LIKE '%ads_gx_xs_18_detail%', 'xs18_detail', NULL),
            IF(td.task_params LIKE '%ods_crm_sa_sales_delivery_order%', 'sales_order', NULL),
            IF(td.task_params LIKE '%ods_mes_wms_batch_info%', 'batch_info', NULL),
            IF(td.task_params LIKE '%dwd_silicon_steel_surface_info%', 'surface_info', NULL)
        )
        ORDER BY td.name SEPARATOR ' | '
    ) AS hit_tables
FROM t_ds_task_definition td
JOIN t_ds_process_task_relation r
    ON r.post_task_code = td.code
   AND r.post_task_version = td.version
   AND r.project_code = td.project_code
JOIN t_ds_process_definition pd
    ON pd.code = r.process_definition_code
   AND pd.version = r.process_definition_version
   AND pd.project_code = r.project_code
LEFT JOIN t_ds_schedules s
    ON s.process_definition_code = pd.code
LEFT JOIN t_ds_project p
    ON p.code = td.project_code
WHERE (
       td.task_params LIKE '%ods_crm_sa_sales_delivery_order_detail%'
    OR td.task_params LIKE '%with_attr_value%'
    OR td.task_params LIKE '%ads_gx_xs_18_detail%'
)
AND pd.release_state = 1
AND s.release_state = 1
GROUP BY
    p.name,
    pd.name,
    pd.code,
    pd.version,
    pd.release_state,
    s.id,
    s.release_state,
    s.crontab
ORDER BY p.name, pd.name;
