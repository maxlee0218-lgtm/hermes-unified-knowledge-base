-- Read-only inspection for process1 -> defined inputs

SHOW CREATE TABLE ads_sc_xl_13_process1;
DESC ads_sc_xl_13_process1;
SELECT COUNT(*) AS total_rows FROM ads_sc_xl_13_process1;
SELECT MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date FROM ads_sc_xl_13_process1;

SHOW CREATE TABLE ads_sc_xl_13_defined;
DESC ads_sc_xl_13_defined;
SELECT COUNT(*) AS total_rows FROM ads_sc_xl_13_defined;
SELECT MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date FROM ads_sc_xl_13_defined;

-- key dimension distribution in process1
SELECT
  tenant_id,
  plate_type,
  surface,
  COALESCE(attr1, '') AS attr1,
  steel_grade_series,
  group_manuf_line_name,
  manuf_line_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_process1
GROUP BY 1,2,3,4,5,6,7
ORDER BY row_cnt DESC
LIMIT 200;

-- combo seed cardinality
SELECT COUNT(*) AS combo_seed_cnt
FROM (
  SELECT DISTINCT
    tenant_id,
    plate_type,
    surface,
    COALESCE(attr1, '') AS attr1,
    steel_grade_series,
    group_manuf_line_name,
    manuf_line_name
  FROM ads_sc_xl_13_process1
  WHERE data_date >= CURRENT_DATE - INTERVAL 350 DAY
) t;

-- metric null / zero distributions in process1
SELECT
  SUM(CASE WHEN weight IS NULL THEN 1 ELSE 0 END) AS null_weight_rows,
  SUM(CASE WHEN COALESCE(weight, 0) = 0 THEN 1 ELSE 0 END) AS zero_weight_rows,
  SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity_rows,
  SUM(CASE WHEN COALESCE(quantity, 0) = 0 THEN 1 ELSE 0 END) AS zero_quantity_rows
FROM ads_sc_xl_13_process1;

-- defined side zero distribution
SELECT
  SUM(CASE WHEN weight IS NULL THEN 1 ELSE 0 END) AS null_weight_rows,
  SUM(CASE WHEN COALESCE(weight, 0) = 0 THEN 1 ELSE 0 END) AS zero_weight_rows,
  SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity_rows,
  SUM(CASE WHEN COALESCE(quantity, 0) = 0 THEN 1 ELSE 0 END) AS zero_quantity_rows
FROM ads_sc_xl_13_defined;

EXPLAIN
SELECT
  tenant_id,
  plate_type,
  surface,
  COALESCE(attr1, '') AS attr1,
  steel_grade_series,
  group_manuf_line_name,
  manuf_line_name
FROM ads_sc_xl_13_process1
WHERE data_date >= CURRENT_DATE - INTERVAL 350 DAY;
