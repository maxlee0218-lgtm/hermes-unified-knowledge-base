-- Read-only design SQL for validating dim_date_info zero-fill behavior

-- 1. dim_date_info continuity and 35-day window coverage
WITH date_spine AS (
  SELECT date_id
  FROM dim_date_info
  WHERE date_id BETWEEN CURRENT_DATE - INTERVAL 35 DAY AND CURRENT_DATE
),
date_continuity AS (
  SELECT
    date_id,
    LAG(date_id) OVER (ORDER BY date_id) AS prev_date_id,
    DATEDIFF(date_id, LAG(date_id) OVER (ORDER BY date_id)) AS day_gap
  FROM date_spine
)
SELECT
  MIN(date_id) AS min_date_id,
  MAX(date_id) AS max_date_id,
  COUNT(*) AS window_day_cnt
FROM date_spine;

SELECT *
FROM date_continuity
WHERE day_gap IS NOT NULL
  AND day_gap <> 1;

-- 2. 350-day combo seed size
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

-- 3. Theoretical date x combo grid size
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
  (SELECT COUNT(*) FROM date_spine) AS date_cnt,
  (SELECT COUNT(*) FROM combo_seed) AS combo_cnt,
  (SELECT COUNT(*) FROM date_spine) * (SELECT COUNT(*) FROM combo_seed) AS theoretical_grid_rows;

-- 4. baseline_only zero rows
WITH baseline_rows AS (
  SELECT
    data_date AS work_date,
    tenant_id,
    plate_type,
    manuf_line_name,
    COALESCE(attr1, '') AS attr1,
    day_weight
  FROM ads_sc_xl_13_defined_manuf_line_name_combined_002
),
zero_rows AS (
  SELECT *
  FROM baseline_rows
  WHERE COALESCE(day_weight, 0) = 0
),
continuous_dates AS (
  SELECT date_id
  FROM dim_date_info
  WHERE date_id BETWEEN CURRENT_DATE - INTERVAL 35 DAY AND CURRENT_DATE
)
SELECT COUNT(*) AS baseline_zero_row_cnt
FROM zero_rows;

-- 5. zero-row dimension distribution
SELECT
  tenant_id,
  plate_type,
  manuf_line_name,
  attr1,
  COUNT(*) AS zero_days
FROM zero_rows
GROUP BY 1,2,3,4
ORDER BY zero_days DESC
LIMIT 100;

-- 6. missing date skeleton comparison
WITH combo_seed AS (
  SELECT DISTINCT
    tenant_id,
    plate_type,
    manuf_line_name,
    COALESCE(attr1, '') AS attr1
  FROM ads_sc_xl_13_defined
),
expected_rows AS (
  SELECT
    d.date_id AS work_date,
    c.tenant_id,
    c.plate_type,
    c.manuf_line_name,
    c.attr1
  FROM continuous_dates d
  CROSS JOIN combo_seed c
)
SELECT
  e.work_date,
  e.tenant_id,
  e.plate_type,
  e.manuf_line_name,
  e.attr1
FROM expected_rows e
LEFT JOIN baseline_rows b
  ON e.work_date = b.work_date
 AND e.tenant_id = b.tenant_id
 AND e.plate_type = b.plate_type
 AND e.manuf_line_name = b.manuf_line_name
 AND e.attr1 = b.attr1
WHERE b.work_date IS NULL
LIMIT 200;

-- 7. baseline_only zero-row attribution by dimension
SELECT
  plate_type,
  manuf_line_name,
  attr1,
  COUNT(*) AS row_cnt
FROM zero_rows
GROUP BY 1,2,3
ORDER BY row_cnt DESC
LIMIT 100;

-- 8. attr1 / manuf_line_name combinations missing from baseline
WITH baseline_combo AS (
  SELECT DISTINCT
    work_date,
    tenant_id,
    plate_type,
    manuf_line_name,
    attr1
  FROM baseline_rows
),
combo_seed AS (
  SELECT DISTINCT
    tenant_id,
    plate_type,
    COALESCE(attr1, '') AS attr1,
    manuf_line_name
  FROM ads_sc_xl_13_process1
  WHERE data_date >= CURRENT_DATE - INTERVAL 350 DAY
),
date_spine AS (
  SELECT date_id AS work_date
  FROM dim_date_info
  WHERE date_id BETWEEN CURRENT_DATE - INTERVAL 35 DAY AND CURRENT_DATE
),
expected_combo AS (
  SELECT d.work_date, c.*
  FROM date_spine d
  CROSS JOIN combo_seed c
)
SELECT
  e.work_date,
  e.tenant_id,
  e.plate_type,
  e.manuf_line_name,
  e.attr1
FROM expected_combo e
LEFT JOIN baseline_combo b
  ON e.work_date = b.work_date
 AND e.tenant_id = b.tenant_id
 AND e.plate_type = b.plate_type
 AND e.manuf_line_name = b.manuf_line_name
 AND e.attr1 = b.attr1
WHERE b.work_date IS NULL
LIMIT 200;
