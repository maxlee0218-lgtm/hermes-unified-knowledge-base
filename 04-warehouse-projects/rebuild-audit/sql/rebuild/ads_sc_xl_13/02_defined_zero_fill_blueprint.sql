-- READ-ONLY blueprint for defined zero-fill reconstruction
-- This file does not create or write any table.

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
    attr1,
    steel_grade_series,
    group_manuf_line_name,
    manuf_line_name
  FROM ads_sc_xl_13_process1
  WHERE data_date >= CURRENT_DATE - INTERVAL 350 DAY
),
filled_grid AS (
  SELECT
    d.date_id AS data_date,
    c.tenant_id,
    c.plate_type,
    c.surface,
    c.attr1,
    c.steel_grade_series,
    c.group_manuf_line_name,
    c.manuf_line_name
  FROM date_spine d
  CROSS JOIN combo_seed c
),
process1_joined AS (
  SELECT
    g.data_date,
    g.tenant_id,
    g.plate_type,
    g.surface,
    g.attr1,
    g.steel_grade_series,
    g.group_manuf_line_name,
    g.manuf_line_name,
    COALESCE(p.weight, 0) AS weight,
    COALESCE(p.quantity, 0) AS quantity,
    COALESCE(p.lower_weight, 0) AS lower_weight,
    COALESCE(p.lower_quantity, 0) AS lower_quantity,
    COALESCE(p.manufacturing_finished_output_length, 0) AS manufacturing_finished_output_length,
    COALESCE(p.lower_manufacturing_finished_output_length, 0) AS lower_manufacturing_finished_output_length
  FROM filled_grid g
  LEFT JOIN ads_sc_xl_13_process1 p
    ON g.data_date = p.data_date
   AND g.tenant_id = p.tenant_id
   AND g.plate_type = p.plate_type
   AND g.surface = p.surface
   AND g.attr1 <=> p.attr1
   AND g.steel_grade_series = p.steel_grade_series
   AND g.group_manuf_line_name = p.group_manuf_line_name
   AND g.manuf_line_name = p.manuf_line_name
)
SELECT *
FROM process1_joined;
