-- Read-only inspection for with_attr_value attr1 / manuf_line_name closure

SHOW CREATE TABLE with_attr_value;
DESC with_attr_value;
SELECT COUNT(*) AS total_rows FROM with_attr_value;

-- Candidate column existence blueprint
-- Confirm whether these columns exist in current environment:
-- attr_code / attr_name / attr_value / attr_value_code / scene / type / tenant_id / deleted / enabled

SHOW CREATE TABLE ods_mes_sys_attr_value;
DESC ods_mes_sys_attr_value;
SELECT COUNT(*) AS total_rows FROM ods_mes_sys_attr_value;

SHOW CREATE TABLE dwd_silicon_steel_surface_info;
DESC dwd_silicon_steel_surface_info;
SELECT COUNT(*) AS total_rows FROM dwd_silicon_steel_surface_info;

-- Scene matrix focused on attr1 / manuf_line_name closure
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
WHERE scene IN (
  'BI-SC-KC-013-DEFINED-TYPE-LZ',
  'BI-SC-KC-013-DEFINED-TYPE-JJG',
  'BI-SC-KC-013-DEFINED-TYPE-GG',
  'BI-SC-KC-013-DEFINED-PLATE-LZ',
  'BI-SC-KC-013-DEFINED-PLATE-JJG',
  'BI-SC-KC-013-DEFINED-PLATE-GG'
)
ORDER BY scene, tenant_id, list_order
LIMIT 500;

-- attr1-related candidates in defined
SELECT
  COALESCE(attr1, '') AS attr1,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined
GROUP BY COALESCE(attr1, '')
ORDER BY row_cnt DESC
LIMIT 200;

SELECT
  COALESCE(attr1, '') AS attr1,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name
GROUP BY COALESCE(attr1, '')
ORDER BY row_cnt DESC
LIMIT 200;

-- manuf_line_name-related candidates
SELECT
  manuf_line_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined
GROUP BY manuf_line_name
ORDER BY row_cnt DESC
LIMIT 200;

SELECT
  manuf_line_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name
GROUP BY manuf_line_name
ORDER BY row_cnt DESC
LIMIT 200;

SELECT
  group_manuf_line_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined
GROUP BY group_manuf_line_name
ORDER BY row_cnt DESC
LIMIT 200;

SELECT
  group_manuf_line_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name
GROUP BY group_manuf_line_name
ORDER BY row_cnt DESC
LIMIT 200;

-- Candidate source fields in warehouse facts
SELECT
  machine_code,
  tenant_id,
  COUNT(*) AS row_cnt
FROM dwd_mes_mm_task_group_output
WHERE bi_sc_xl_013_process_001_dataDate >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY machine_code, tenant_id
ORDER BY row_cnt DESC
LIMIT 200;

EXPLAIN
SELECT
  a.tenant_id,
  a.machine_code,
  av.attribute1,
  av.attribute2,
  av.scene
FROM dwd_mes_mm_task_group_output a
LEFT JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND a.machine_code = av.attribute2
WHERE av.scene IN (
  'BI-SC-KC-013-DEFINED-TYPE-LZ',
  'BI-SC-KC-013-DEFINED-TYPE-JJG',
  'BI-SC-KC-013-DEFINED-TYPE-GG'
);
