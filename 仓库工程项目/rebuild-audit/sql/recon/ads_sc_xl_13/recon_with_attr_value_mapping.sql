-- Read-only design SQL for validating with_attr_value mapping impact

-- 1. scene distribution
SELECT scene, tenant_id, COUNT(*) AS row_cnt
FROM with_attr_value
GROUP BY scene, tenant_id
ORDER BY scene, tenant_id;

-- 2. key scene matrix for XL13
SELECT
  scene,
  tenant_id,
  attribute1,
  attribute2,
  attribute3,
  attribute4,
  attribute5,
  attribute6,
  attribute7,
  list_order
FROM with_attr_value
WHERE scene LIKE 'BI-SC-KC-013%'
ORDER BY scene, tenant_id, list_order
LIMIT 500;

-- 3. attr1 / manuf_line_name mapping coverage against DWD source
SELECT
  a.tenant_id,
  a.machine_code,
  COUNT(*) AS row_cnt
FROM dwd_mes_mm_task_group_output a
LEFT JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND a.machine_code = av.attribute2
 AND av.scene IN (
   'BI-SC-KC-013-DEFINED-TYPE-LZ',
   'BI-SC-KC-013-DEFINED-TYPE-JJG',
   'BI-SC-KC-013-DEFINED-TYPE-GG'
 )
WHERE a.bi_sc_xl_013_process_001_dataDate >= CURRENT_DATE - INTERVAL 35 DAY
  AND av.with_id IS NULL
GROUP BY a.tenant_id, a.machine_code
ORDER BY row_cnt DESC
LIMIT 100;

-- 4. ads_sc_xl_01 warehouse / document mapping coverage
SELECT
  a.tenant_id,
  a.wh_code,
  a.dept_code,
  a.machine_code,
  a.rd_style_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_01 a
LEFT JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND av.scene LIKE 'BI-SC-KC-013-WH-CODE-%'
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY
  AND av.with_id IS NULL
GROUP BY a.tenant_id, a.wh_code, a.dept_code, a.machine_code, a.rd_style_name
ORDER BY row_cnt DESC
LIMIT 100;

-- 5. combined-side missing mapping symptoms
SELECT
  tenant_id,
  plate_type,
  manuf_line_name,
  COALESCE(attr1, '') AS attr1,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name_combined_002
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY 1,2,3,4
HAVING COUNT(*) > 0
ORDER BY row_cnt DESC
LIMIT 100;
