-- Read-only inspection for defined -> defined_manuf_line_name

SHOW CREATE TABLE ads_sc_xl_13_defined;
DESC ads_sc_xl_13_defined;
SELECT COUNT(*) AS total_rows FROM ads_sc_xl_13_defined;
SELECT MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date FROM ads_sc_xl_13_defined;

SHOW CREATE TABLE ads_sc_xl_13_defined_manuf_line_name;
DESC ads_sc_xl_13_defined_manuf_line_name;
SELECT COUNT(*) AS total_rows FROM ads_sc_xl_13_defined_manuf_line_name;
SELECT MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date FROM ads_sc_xl_13_defined_manuf_line_name;

-- manuf_line_name distribution
SELECT
  manuf_line_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined
GROUP BY manuf_line_name
ORDER BY row_cnt DESC
LIMIT 100;

SELECT
  manuf_line_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name
GROUP BY manuf_line_name
ORDER BY row_cnt DESC
LIMIT 100;

-- group_manuf_line_name distribution
SELECT
  group_manuf_line_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined
GROUP BY group_manuf_line_name
ORDER BY row_cnt DESC
LIMIT 100;

SELECT
  group_manuf_line_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name
GROUP BY group_manuf_line_name
ORDER BY row_cnt DESC
LIMIT 100;

-- attr1 distribution
SELECT
  COALESCE(attr1, '') AS attr1,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined
GROUP BY COALESCE(attr1, '')
ORDER BY row_cnt DESC
LIMIT 100;

SELECT
  COALESCE(attr1, '') AS attr1,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name
GROUP BY COALESCE(attr1, '')
ORDER BY row_cnt DESC
LIMIT 100;

-- steel_grade_series distribution
SELECT
  COALESCE(steel_grade_series, '') AS steel_grade_series,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined
GROUP BY COALESCE(steel_grade_series, '')
ORDER BY row_cnt DESC
LIMIT 100;

-- material_name not confirmed as a direct column in current environment
-- SELECT material_name, COUNT(*) FROM ads_sc_xl_13_defined GROUP BY material_name;

-- metric totals and zero/null checks
SELECT
  SUM(COALESCE(weight, 0)) AS sum_weight,
  SUM(COALESCE(quantity, 0)) AS sum_quantity,
  SUM(COALESCE(lower_weight, 0)) AS sum_lower_weight,
  SUM(COALESCE(lower_quantity, 0)) AS sum_lower_quantity,
  SUM(CASE WHEN COALESCE(weight, 0) = 0 THEN 1 ELSE 0 END) AS zero_weight_rows,
  SUM(CASE WHEN weight IS NULL THEN 1 ELSE 0 END) AS null_weight_rows
FROM ads_sc_xl_13_defined;

SELECT
  SUM(COALESCE(weight, 0)) AS sum_weight,
  SUM(COALESCE(quantity, 0)) AS sum_quantity,
  SUM(COALESCE(lower_weight, 0)) AS sum_lower_weight,
  SUM(COALESCE(lower_quantity, 0)) AS sum_lower_quantity,
  SUM(CASE WHEN COALESCE(weight, 0) = 0 THEN 1 ELSE 0 END) AS zero_weight_rows,
  SUM(CASE WHEN weight IS NULL THEN 1 ELSE 0 END) AS null_weight_rows
FROM ads_sc_xl_13_defined_manuf_line_name;

-- theoretical aggregation grain
SELECT COUNT(*) AS defined_key_cnt
FROM (
  SELECT DISTINCT
    data_date,
    tenant_id,
    plate_type,
    group_manuf_line_name,
    manuf_line_name,
    COALESCE(attr1, '') AS attr1
  FROM ads_sc_xl_13_defined
) t;

SELECT COUNT(*) AS defined_manuf_line_name_key_cnt
FROM (
  SELECT DISTINCT
    data_date,
    tenant_id,
    plate_type,
    group_manuf_line_name,
    manuf_line_name,
    COALESCE(attr1, '') AS attr1
  FROM ads_sc_xl_13_defined_manuf_line_name
) t;

EXPLAIN
SELECT
  data_date,
  tenant_id,
  plate_type,
  group_manuf_line_name,
  manuf_line_name,
  COALESCE(attr1, '') AS attr1,
  SUM(weight) AS sum_weight
FROM ads_sc_xl_13_defined
GROUP BY 1,2,3,4,5,6;
