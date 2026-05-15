-- Read-only anchor inspection for combined_002

SHOW CREATE TABLE ads_sc_xl_13_defined_manuf_line_name_combined_002;
DESC ads_sc_xl_13_defined_manuf_line_name_combined_002;

SELECT
  COUNT(*) AS total_rows,
  MIN(data_date) AS min_data_date,
  MAX(data_date) AS max_data_date,
  SUM(day_weight) AS sum_day_weight,
  SUM(day_quantity) AS sum_day_quantity
FROM ads_sc_xl_13_defined_manuf_line_name_combined_002;

SELECT
  tenant_id,
  plate_type,
  manuf_line_name,
  attr1,
  data_date,
  day_weight
FROM ads_sc_xl_13_defined_manuf_line_name_combined_002
ORDER BY data_date DESC
LIMIT 50;

EXPLAIN
SELECT
  tenant_id,
  plate_type,
  manuf_line_name,
  attr1,
  data_date,
  day_weight
FROM ads_sc_xl_13_defined_manuf_line_name_combined_002
WHERE data_date >= CURRENT_DATE - INTERVAL 7 DAY;
