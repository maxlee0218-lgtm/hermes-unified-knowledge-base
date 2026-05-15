-- ADS_SC_XL_13 legacy source snapshot
-- Task: 18334034498312 班组产能（dwd_mes_hmes_mm_task_group_output）
-- Role: ODS -> DWD for group output
-- Evidence source: warehouse-platform/docs/upstreams/dolphin-process-chain-18334034498304.md

SELECT
  a.id,
  b.sku_code,
  b.batch_code,
  b.actual_id,
  a.weight,
  a.quantity,
  a.meter_num AS roll_length,
  CASE
    WHEN a.tenant_id = 80 AND HOUR(a.end_time) < 9 THEN DATE(a.end_time) - INTERVAL 1 DAY
    WHEN a.tenant_id <> 80 AND HOUR(a.end_time) < 8 THEN DATE(a.end_time) - INTERVAL 1 DAY
    ELSE DATE(a.end_time)
  END AS data_date,
  a.tenant_id
FROM ods_mes_mm_task_group_output a
JOIN ods_mes_mm_task_prod_actual b
  ON b.actual_id = a.actual_id
WHERE a.status = 1
  AND a.end_time IS NOT NULL;

-- Mapping updates in the same task:
-- 1) with_attr_value -> defined_manuf_line_name / plate_type
-- 2) dwd_silicon_steel_surface_info -> surface_thickness / surface_number / middle_part
