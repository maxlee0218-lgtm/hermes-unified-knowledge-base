-- Support chain snapshot
-- Tasks:
-- - 18340742659073 入库单（dwd_mes_hmes_wms_wh_enter_item）
-- - 31/32 DataX ODS sync

SELECT
  ei.enter_item_id,
  en.enter_id,
  ei.batch_code,
  ei.sku_code,
  ei.weight,
  ei.quantity,
  en.wh_code,
  en.dept_code,
  ei.tenant_id,
  ei.r_modified_time
FROM ods_mes_wms_wh_enter_item ei
JOIN ods_mes_wms_wh_enter en
  ON en.enter_id = ei.enter_id
WHERE ei.r_modified_time >= @lastTime
  AND ei.r_modified_time < @currentTime;

-- The production task enriches:
-- - ods_mes_wms_batch_info
-- - ods_mes_sys_supplier
-- - ods_mes_sys_department
-- - dim_ums_tenant
-- - dwd_silicon_steel_surface_info
