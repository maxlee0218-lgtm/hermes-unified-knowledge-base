-- Read-only aggregation validation for defined -> defined_manuf_line_name

-- SECTION 01: row_count_check
-- 1. defined original row count
SELECT COUNT(*) AS defined_row_cnt
FROM ads_sc_xl_13_defined
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY;

-- 2. defined_manuf_line_name target row count
SELECT COUNT(*) AS defined_manuf_line_name_row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY;

-- SECTION 02: date_range_check
SELECT MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date
FROM ads_sc_xl_13_defined
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY;

SELECT MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date
FROM ads_sc_xl_13_defined_manuf_line_name
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY;

-- SECTION 03: group_key_distinct_check
-- 3. aggregation key distinct counts
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
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
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
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
) t;

-- SECTION 04: metric_conservation_check
-- 4. metric conservation
SELECT
  'defined' AS side_name,
  SUM(COALESCE(weight, 0)) AS sum_weight,
  SUM(COALESCE(quantity, 0)) AS sum_quantity,
  SUM(COALESCE(lower_weight, 0)) AS sum_lower_weight,
  SUM(COALESCE(lower_quantity, 0)) AS sum_lower_quantity,
  SUM(COALESCE(manufacturing_finished_output_length, 0)) AS sum_output_len,
  SUM(COALESCE(lower_manufacturing_finished_output_length, 0)) AS sum_lower_output_len
FROM ads_sc_xl_13_defined
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
UNION ALL
SELECT
  'defined_manuf_line_name' AS side_name,
  SUM(COALESCE(weight, 0)) AS sum_weight,
  SUM(COALESCE(quantity, 0)) AS sum_quantity,
  SUM(COALESCE(lower_weight, 0)) AS sum_lower_weight,
  SUM(COALESCE(lower_quantity, 0)) AS sum_lower_quantity,
  SUM(COALESCE(manufacturing_finished_output_length, 0)) AS sum_output_len,
  SUM(COALESCE(lower_manufacturing_finished_output_length, 0)) AS sum_lower_output_len
FROM ads_sc_xl_13_defined_manuf_line_name
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY;

-- SECTION 05: zero_row_retention_check
SELECT
  'defined' AS side_name,
  SUM(CASE WHEN COALESCE(weight, 0) = 0 THEN 1 ELSE 0 END) AS zero_weight_rows
FROM ads_sc_xl_13_defined
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
UNION ALL
SELECT
  'defined_manuf_line_name' AS side_name,
  SUM(CASE WHEN COALESCE(weight, 0) = 0 THEN 1 ELSE 0 END) AS zero_weight_rows
FROM ads_sc_xl_13_defined_manuf_line_name
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY;

-- SECTION 06: manuf_line_name_missing_check
-- 5. manuf_line_name missing check
SELECT *
FROM ads_sc_xl_13_defined
WHERE manuf_line_name IS NULL
   OR manuf_line_name = ''
LIMIT 200;

-- SECTION 07: group_vs_manuf_line_name_mismatch_check
-- 6. group_manuf_line_name vs manuf_line_name inconsistency
SELECT
  data_date,
  tenant_id,
  plate_type,
  group_manuf_line_name,
  manuf_line_name,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined
WHERE group_manuf_line_name IS NOT NULL
  AND manuf_line_name IS NOT NULL
  AND group_manuf_line_name <> manuf_line_name
GROUP BY 1,2,3,4,5
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 08: attr1_retention_check
-- 7. attr1 preservation
SELECT
  COALESCE(attr1, '') AS attr1,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined
GROUP BY COALESCE(attr1, '')
UNION ALL
SELECT
  COALESCE(attr1, '') AS attr1,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name
GROUP BY COALESCE(attr1, '');

-- SECTION 09: material_or_steel_grade_change_check
-- 8. steel_grade_series preservation
SELECT
  COALESCE(steel_grade_series, '') AS steel_grade_series,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined
GROUP BY COALESCE(steel_grade_series, '')
ORDER BY row_cnt DESC
LIMIT 200;

-- material_name is not confirmed as direct column in current environment
-- SELECT material_name, COUNT(*) FROM ads_sc_xl_13_defined GROUP BY material_name;

-- SECTION 10: source_only_rows_blueprint
-- 9. source-only rows blueprint
WITH src AS (
  SELECT
    data_date,
    tenant_id,
    plate_type,
    group_manuf_line_name,
    manuf_line_name,
    COALESCE(attr1, '') AS attr1
  FROM ads_sc_xl_13_defined
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
  GROUP BY 1,2,3,4,5,6
),
tgt AS (
  SELECT
    data_date,
    tenant_id,
    plate_type,
    group_manuf_line_name,
    manuf_line_name,
    COALESCE(attr1, '') AS attr1
  FROM ads_sc_xl_13_defined_manuf_line_name
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
  GROUP BY 1,2,3,4,5,6
)
SELECT src.*
FROM src
LEFT JOIN tgt
  ON src.data_date = tgt.data_date
 AND src.tenant_id = tgt.tenant_id
 AND src.plate_type = tgt.plate_type
 AND src.group_manuf_line_name = tgt.group_manuf_line_name
 AND src.manuf_line_name = tgt.manuf_line_name
 AND src.attr1 = tgt.attr1
WHERE tgt.data_date IS NULL
LIMIT 200;

-- SECTION 11: baseline_only_rows_blueprint
-- 10. baseline-only rows blueprint
SELECT tgt.*
FROM tgt
LEFT JOIN src
  ON src.data_date = tgt.data_date
 AND src.tenant_id = tgt.tenant_id
 AND src.plate_type = tgt.plate_type
 AND src.group_manuf_line_name = tgt.group_manuf_line_name
 AND src.manuf_line_name = tgt.manuf_line_name
 AND src.attr1 = tgt.attr1
WHERE src.data_date IS NULL
LIMIT 200;

-- SECTION 12: final_pass_fail_summary_blueprint
-- 11. metric-level diff blueprint
WITH src_metric AS (
  SELECT
    data_date,
    tenant_id,
    plate_type,
    group_manuf_line_name,
    manuf_line_name,
    COALESCE(attr1, '') AS attr1,
    SUM(COALESCE(weight, 0)) AS weight,
    SUM(COALESCE(quantity, 0)) AS quantity,
    SUM(COALESCE(lower_weight, 0)) AS lower_weight,
    SUM(COALESCE(lower_quantity, 0)) AS lower_quantity
  FROM ads_sc_xl_13_defined
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
  GROUP BY 1,2,3,4,5,6
),
tgt_metric AS (
  SELECT
    data_date,
    tenant_id,
    plate_type,
    group_manuf_line_name,
    manuf_line_name,
    COALESCE(attr1, '') AS attr1,
    SUM(COALESCE(weight, 0)) AS weight,
    SUM(COALESCE(quantity, 0)) AS quantity,
    SUM(COALESCE(lower_weight, 0)) AS lower_weight,
    SUM(COALESCE(lower_quantity, 0)) AS lower_quantity
  FROM ads_sc_xl_13_defined_manuf_line_name
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
  GROUP BY 1,2,3,4,5,6
)
SELECT
  COALESCE(s.data_date, t.data_date) AS data_date,
  COALESCE(s.tenant_id, t.tenant_id) AS tenant_id,
  COALESCE(s.plate_type, t.plate_type) AS plate_type,
  COALESCE(s.group_manuf_line_name, t.group_manuf_line_name) AS group_manuf_line_name,
  COALESCE(s.manuf_line_name, t.manuf_line_name) AS manuf_line_name,
  COALESCE(s.attr1, t.attr1) AS attr1,
  s.weight AS src_weight,
  t.weight AS tgt_weight,
  s.quantity AS src_quantity,
  t.quantity AS tgt_quantity
FROM src_metric s
FULL OUTER JOIN tgt_metric t
  ON s.data_date = t.data_date
 AND s.tenant_id = t.tenant_id
 AND s.plate_type = t.plate_type
 AND s.group_manuf_line_name = t.group_manuf_line_name
 AND s.manuf_line_name = t.manuf_line_name
 AND s.attr1 = t.attr1
LIMIT 500;

-- 12. zero-row preservation
SELECT
  SUM(CASE WHEN COALESCE(weight, 0) = 0 THEN 1 ELSE 0 END) AS defined_zero_rows
FROM ads_sc_xl_13_defined
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
UNION ALL
SELECT
  SUM(CASE WHEN COALESCE(weight, 0) = 0 THEN 1 ELSE 0 END) AS defined_manuf_line_name_zero_rows
FROM ads_sc_xl_13_defined_manuf_line_name
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY;
