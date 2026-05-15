-- Read-only zero-fill validation for process1 -> defined

-- 1. process1 original row count
SELECT COUNT(*) AS process1_row_cnt
FROM ads_sc_xl_13_process1
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY;

-- 2. combo seed size
WITH combo_seed AS (
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
)
SELECT COUNT(*) AS combo_seed_cnt
FROM combo_seed;

-- 3. 35-day date spine size
WITH date_spine AS (
  SELECT date_id
  FROM dim_date_info
  WHERE date_id BETWEEN CURRENT_DATE - INTERVAL 35 DAY AND CURRENT_DATE
)
SELECT COUNT(*) AS date_spine_cnt
FROM date_spine;

-- 4. theoretical filled grid size
WITH date_spine AS (
  SELECT date_id
  FROM dim_date_info
  WHERE date_id BETWEEN CURRENT_DATE - INTERVAL 35 DAY AND CURRENT_DATE
),
combo_seed AS (
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
)
SELECT
  (SELECT COUNT(*) FROM date_spine) * (SELECT COUNT(*) FROM combo_seed) AS theoretical_grid_rows;

-- 5. defined actual row count
SELECT COUNT(*) AS defined_row_cnt
FROM ads_sc_xl_13_defined
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY;

-- 6. defined zero rows
SELECT COUNT(*) AS defined_zero_weight_rows
FROM ads_sc_xl_13_defined
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
  AND COALESCE(weight, 0) = 0;

-- 7. defined non-zero rows
SELECT COUNT(*) AS defined_nonzero_weight_rows
FROM ads_sc_xl_13_defined
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
  AND COALESCE(weight, 0) <> 0;

-- 8. baseline-only zero rows attribution
WITH baseline_zero AS (
  SELECT
    data_date,
    tenant_id,
    plate_type,
    manuf_line_name,
    COALESCE(attr1, '') AS attr1
  FROM ads_sc_xl_13_defined_manuf_line_name_combined_002
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
    AND COALESCE(day_weight, 0) = 0
)
SELECT COUNT(*) AS baseline_only_zero_like_rows
FROM baseline_zero;

-- 9. source-only rows attribution blueprint
WITH process1_combo AS (
  SELECT DISTINCT
    data_date,
    tenant_id,
    plate_type,
    surface,
    COALESCE(attr1, '') AS attr1,
    steel_grade_series,
    group_manuf_line_name,
    manuf_line_name
  FROM ads_sc_xl_13_process1
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
),
defined_combo AS (
  SELECT DISTINCT
    data_date,
    tenant_id,
    plate_type,
    surface,
    COALESCE(attr1, '') AS attr1,
    steel_grade_series,
    group_manuf_line_name,
    manuf_line_name
  FROM ads_sc_xl_13_defined
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
)
SELECT p.*
FROM process1_combo p
LEFT JOIN defined_combo d
  ON p.data_date = d.data_date
 AND p.tenant_id = d.tenant_id
 AND p.plate_type = d.plate_type
 AND p.surface = d.surface
 AND p.attr1 = d.attr1
 AND p.steel_grade_series = d.steel_grade_series
 AND p.group_manuf_line_name = d.group_manuf_line_name
 AND p.manuf_line_name = d.manuf_line_name
WHERE d.data_date IS NULL
LIMIT 200;

-- 10. key-level diff blueprint
WITH process1_daily AS (
  SELECT
    data_date,
    tenant_id,
    plate_type,
    surface,
    COALESCE(attr1, '') AS attr1,
    steel_grade_series,
    group_manuf_line_name,
    manuf_line_name,
    SUM(COALESCE(weight, 0)) AS weight,
    SUM(COALESCE(quantity, 0)) AS quantity
  FROM ads_sc_xl_13_process1
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
  GROUP BY 1,2,3,4,5,6,7,8
),
defined_daily AS (
  SELECT
    data_date,
    tenant_id,
    plate_type,
    surface,
    COALESCE(attr1, '') AS attr1,
    steel_grade_series,
    group_manuf_line_name,
    manuf_line_name,
    SUM(COALESCE(weight, 0)) AS weight,
    SUM(COALESCE(quantity, 0)) AS quantity
  FROM ads_sc_xl_13_defined
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
  GROUP BY 1,2,3,4,5,6,7,8
)
SELECT
  COALESCE(p.data_date, d.data_date) AS data_date,
  COALESCE(p.tenant_id, d.tenant_id) AS tenant_id,
  COALESCE(p.plate_type, d.plate_type) AS plate_type,
  COALESCE(p.surface, d.surface) AS surface,
  COALESCE(p.attr1, d.attr1) AS attr1,
  COALESCE(p.steel_grade_series, d.steel_grade_series) AS steel_grade_series,
  COALESCE(p.group_manuf_line_name, d.group_manuf_line_name) AS group_manuf_line_name,
  COALESCE(p.manuf_line_name, d.manuf_line_name) AS manuf_line_name,
  p.weight AS process1_weight,
  d.weight AS defined_weight,
  p.quantity AS process1_quantity,
  d.quantity AS defined_quantity
FROM process1_daily p
FULL OUTER JOIN defined_daily d
  ON p.data_date = d.data_date
 AND p.tenant_id = d.tenant_id
 AND p.plate_type = d.plate_type
 AND p.surface = d.surface
 AND p.attr1 = d.attr1
 AND p.steel_grade_series = d.steel_grade_series
 AND p.group_manuf_line_name = d.group_manuf_line_name
 AND p.manuf_line_name = d.manuf_line_name
LIMIT 500;

-- 11. date gap check in defined
WITH ordered_dates AS (
  SELECT DISTINCT data_date
  FROM ads_sc_xl_13_defined
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
),
date_gap AS (
  SELECT
    data_date,
    LAG(data_date) OVER (ORDER BY data_date) AS prev_date,
    DATEDIFF(data_date, LAG(data_date) OVER (ORDER BY data_date)) AS day_gap
  FROM ordered_dates
)
SELECT *
FROM date_gap
WHERE day_gap IS NOT NULL
  AND day_gap <> 1;

-- 12. dimension combination gap check
WITH combo_seed AS (
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
),
defined_combo AS (
  SELECT DISTINCT
    tenant_id,
    plate_type,
    surface,
    COALESCE(attr1, '') AS attr1,
    steel_grade_series,
    group_manuf_line_name,
    manuf_line_name
  FROM ads_sc_xl_13_defined
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
)
SELECT *
FROM combo_seed c
LEFT JOIN defined_combo d
  ON c.tenant_id = d.tenant_id
 AND c.plate_type = d.plate_type
 AND c.surface = d.surface
 AND c.attr1 = d.attr1
 AND c.steel_grade_series = d.steel_grade_series
 AND c.group_manuf_line_name = d.group_manuf_line_name
 AND c.manuf_line_name = d.manuf_line_name
WHERE d.tenant_id IS NULL
LIMIT 200;
