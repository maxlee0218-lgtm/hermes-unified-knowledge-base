-- Read-only inspection for with_attr_value warehouse / document type scenes

SHOW CREATE TABLE with_attr_value;
DESC with_attr_value;
SELECT COUNT(*) AS total_rows FROM with_attr_value;

-- SECTION 01: relevant scene family distribution
SELECT
  scene,
  tenant_id,
  COUNT(*) AS row_cnt
FROM with_attr_value
WHERE scene LIKE 'BI-SC-KC-013-WH-CODE-%'
   OR scene LIKE 'BI-SC-KC-013-RD-FINISHED-%'
GROUP BY scene, tenant_id
ORDER BY scene, tenant_id;

-- SECTION 02: relevant scene candidate rows
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
WHERE scene LIKE 'BI-SC-KC-013-WH-CODE-%'
   OR scene LIKE 'BI-SC-KC-013-RD-FINISHED-%'
ORDER BY scene, tenant_id, list_order
LIMIT 500;

-- SECTION 03: upstream fact distribution in dwd_mes_wms_wh_enter_item
SELECT
  tenant_id,
  wh_code,
  dept_code,
  machine_code,
  other_machine_code,
  rd_style,
  rd_style_name,
  COUNT(*) AS row_cnt
FROM dwd_mes_wms_wh_enter_item
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY
  tenant_id,
  wh_code,
  dept_code,
  machine_code,
  other_machine_code,
  rd_style,
  rd_style_name
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 04: downstream fact distribution in ads_sc_xl_01
SELECT
  tenant_id,
  bill_type,
  wh_code,
  dept_code,
  machine_code,
  other_machine_code,
  rd_style,
  rd_style_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_01
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY
  tenant_id,
  bill_type,
  wh_code,
  dept_code,
  machine_code,
  other_machine_code,
  rd_style,
  rd_style_name
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 05: candidate explain only
EXPLAIN
SELECT
  a.tenant_id,
  a.wh_code,
  a.dept_code,
  a.machine_code,
  a.other_machine_code,
  a.rd_style_name,
  av.scene
FROM ads_sc_xl_01 a
LEFT JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY
  AND (
    av.scene LIKE 'BI-SC-KC-013-WH-CODE-%'
    OR av.scene LIKE 'BI-SC-KC-013-RD-FINISHED-%'
  );
