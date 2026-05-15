-- Read-only inspection for total rows postprocess impact

SHOW CREATE TABLE ads_sc_xl_13_defined_manuf_line_name_combined;
DESC ads_sc_xl_13_defined_manuf_line_name_combined;

SHOW CREATE TABLE ads_sc_xl_13_defined_manuf_line_name_combined_001;
DESC ads_sc_xl_13_defined_manuf_line_name_combined_001;

SHOW CREATE TABLE ads_sc_xl_13_defined_manuf_line_name_combined_002;
DESC ads_sc_xl_13_defined_manuf_line_name_combined_002;

-- SECTION 01: attr1='合计' existence
SELECT
  tenant_id,
  plate_type,
  manuf_line_name,
  data_date,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE attr1 = '合计'
GROUP BY tenant_id, plate_type, manuf_line_name, data_date
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 02: manuf_line_name='总计' existence
SELECT
  tenant_id,
  plate_type,
  data_date,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE manuf_line_name = '总计'
GROUP BY tenant_id, plate_type, data_date
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 03: key distribution blueprint
SELECT
  tenant_id,
  plate_type,
  group_manuf_line_name,
  manuf_line_name,
  attr1,
  data_date,
  rk,
  rk1,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE attr1 = '合计'
   OR manuf_line_name = '总计'
GROUP BY tenant_id, plate_type, group_manuf_line_name, manuf_line_name, attr1, data_date, rk, rk1
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 04: metric distribution blueprint
SELECT
  tenant_id,
  plate_type,
  manuf_line_name,
  attr1,
  data_date,
  day_weight,
  day_quantity,
  day_breakdown_frequency,
  day_manufacturing_finished_product,
  month_weight,
  month_quantity
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE attr1 = '合计'
   OR manuf_line_name = '总计'
LIMIT 200;

-- SECTION 05: can be aggregated from non-summary rows blueprint
SELECT
  tenant_id,
  plate_type,
  manuf_line_name,
  data_date,
  SUM(day_weight) AS agg_day_weight,
  SUM(day_quantity) AS agg_day_quantity
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE COALESCE(attr1, '') <> '合计'
  AND manuf_line_name <> '总计'
GROUP BY tenant_id, plate_type, manuf_line_name, data_date
ORDER BY agg_day_weight DESC
LIMIT 200;

-- SECTION 06: source-only / baseline-only risk blueprint
SELECT
  'summary_rows_require_explicit_postprocess_validation' AS risk_statement;
