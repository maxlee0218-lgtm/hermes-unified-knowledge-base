-- Read-only inspection for combined candidate inputs

SHOW CREATE TABLE ads_sc_xl_13_defined_manuf_line_name;
DESC ads_sc_xl_13_defined_manuf_line_name;

SHOW CREATE TABLE with_attr_value;
DESC with_attr_value;

SHOW CREATE TABLE ads_sc_xl_01;
DESC ads_sc_xl_01;

SHOW CREATE TABLE with_result_confirm;
DESC with_result_confirm;

SHOW CREATE TABLE ads_sc_xl_13_defined_manuf_line_name_combined;
DESC ads_sc_xl_13_defined_manuf_line_name_combined;

-- SECTION 01: main chain row/key distribution
SELECT
  COUNT(*) AS row_cnt,
  COUNT(DISTINCT CONCAT_WS('|', tenant_id, data_date, plate_type, manuf_line_name, COALESCE(attr1, ''))) AS distinct_keys
FROM ads_sc_xl_13_defined_manuf_line_name;

-- SECTION 02: with_attr_value key scene distribution
SELECT
  scene,
  tenant_id,
  COUNT(*) AS row_cnt
FROM with_attr_value
WHERE scene LIKE 'BI-SC-KC-013%'
GROUP BY scene, tenant_id
ORDER BY scene, tenant_id;

-- SECTION 03: ads_sc_xl_01 key candidate distribution
SELECT
  tenant_id,
  data_date,
  wh_code,
  dept_code,
  machine_code,
  other_machine_code,
  rd_style_name,
  bill_type,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_01
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY tenant_id, data_date, wh_code, dept_code, machine_code, other_machine_code, rd_style_name, bill_type
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 04: with_result_confirm key candidate distribution
SELECT
  tenant_id,
  report_id,
  attribute1,
  attribute2,
  attribute23,
  COUNT(*) AS row_cnt
FROM with_result_confirm
WHERE report_id IN ('237', '239', '543')
GROUP BY tenant_id, report_id, attribute1, attribute2, attribute23
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 05: total_rows_postprocess key distribution
SELECT
  tenant_id,
  plate_type,
  manuf_line_name,
  attr1,
  data_date,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE attr1 = '合计'
   OR manuf_line_name = '总计'
GROUP BY tenant_id, plate_type, manuf_line_name, attr1, data_date
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 06: candidate join key null checks
SELECT
  SUM(CASE WHEN tenant_id IS NULL THEN 1 ELSE 0 END) AS tenant_id_nulls,
  SUM(CASE WHEN data_date IS NULL THEN 1 ELSE 0 END) AS data_date_nulls,
  SUM(CASE WHEN manuf_line_name IS NULL OR manuf_line_name = '' THEN 1 ELSE 0 END) AS manuf_line_name_null_or_blank
FROM ads_sc_xl_13_defined_manuf_line_name;

-- SECTION 07: candidate metric null/zero checks
SELECT
  SUM(CASE WHEN day_weight IS NULL THEN 1 ELSE 0 END) AS day_weight_nulls,
  SUM(CASE WHEN day_weight = 0 THEN 1 ELSE 0 END) AS day_weight_zeros,
  SUM(CASE WHEN day_quantity IS NULL THEN 1 ELSE 0 END) AS day_quantity_nulls
FROM ads_sc_xl_13_defined_manuf_line_name_combined;

-- SECTION 08: source-only risk input blueprint
SELECT 'source_only_blueprint_requires_candidate_layer' AS note;

-- SECTION 09: baseline-only risk input blueprint
SELECT 'baseline_only_blueprint_requires_candidate_layer' AS note;
