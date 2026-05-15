-- Read-only inspection for ads_sc_xl_01_local blueprint

SHOW CREATE TABLE ads_sc_xl_01;
DESC ads_sc_xl_01;
SELECT COUNT(*) AS total_rows FROM ads_sc_xl_01;

-- SECTION 01: date candidate distribution
SELECT
  MIN(data_date) AS min_data_date,
  MAX(data_date) AS max_data_date,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_01;

-- work_date not confirmed in current environment
-- SELECT MIN(work_date), MAX(work_date), COUNT(*) FROM ads_sc_xl_01;

-- SECTION 02: tenant distribution
SELECT
  tenant_id,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_01
GROUP BY tenant_id
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 03: warehouse candidate distribution
SELECT
  wh_code,
  wh_name,
  dept_code,
  dept_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_01
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY wh_code, wh_name, dept_code, dept_name
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 04: document type candidate distribution
SELECT
  bill_type,
  rd_style,
  rd_style_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_01
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY bill_type, rd_style, rd_style_name
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 05: machine candidate distribution
SELECT
  machine_code,
  other_machine_code,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_01
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY machine_code, other_machine_code
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 06: category and plate candidate distribution
SELECT
  products_category,
  plate_type,
  products_type,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_01
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY products_category, plate_type, products_type
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 07: attr* / attribute* candidate distribution
-- attr1 not confirmed as direct column in ads_sc_xl_01 current evidence
-- SELECT attr1, COUNT(*) FROM ads_sc_xl_01 GROUP BY attr1;
-- attribute1..attribute7 not confirmed as direct columns in ads_sc_xl_01 current evidence

-- SECTION 08: warehouse scene candidate distribution against with_attr_value
SELECT
  av.scene,
  av.tenant_id,
  COUNT(*) AS row_cnt
FROM with_attr_value av
WHERE av.scene LIKE 'BI-SC-KC-013-WH-CODE-%'
GROUP BY av.scene, av.tenant_id
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 09: document type scene candidate distribution against with_attr_value
SELECT
  av.scene,
  av.tenant_id,
  COUNT(*) AS row_cnt
FROM with_attr_value av
WHERE av.scene LIKE 'BI-SC-KC-013-RD-FINISHED-%'
GROUP BY av.scene, av.tenant_id
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 10: possible join key value distribution
SELECT
  tenant_id,
  wh_code,
  dept_code,
  machine_code,
  other_machine_code,
  rd_style_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_01
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY
  tenant_id,
  wh_code,
  dept_code,
  machine_code,
  other_machine_code,
  rd_style_name
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 11: null / abnormal blueprint
SELECT
  SUM(CASE WHEN tenant_id IS NULL THEN 1 ELSE 0 END) AS tenant_id_nulls,
  SUM(CASE WHEN data_date IS NULL THEN 1 ELSE 0 END) AS data_date_nulls,
  SUM(CASE WHEN wh_code IS NULL OR wh_code = '' THEN 1 ELSE 0 END) AS wh_code_null_or_blank,
  SUM(CASE WHEN rd_style_name IS NULL OR rd_style_name = '' THEN 1 ELSE 0 END) AS rd_style_name_null_or_blank,
  SUM(CASE WHEN machine_code IS NULL OR machine_code = '' THEN 1 ELSE 0 END) AS machine_code_null_or_blank
FROM ads_sc_xl_01;

-- SECTION 12: explain-only join blueprint
EXPLAIN
SELECT
  a.tenant_id,
  a.wh_code,
  a.dept_code,
  a.machine_code,
  a.other_machine_code,
  a.rd_style,
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
