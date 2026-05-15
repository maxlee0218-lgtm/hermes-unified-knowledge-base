-- READ-ONLY rebuild blueprint for defined

WITH date_spine AS (
  SELECT date_id
  FROM dim_date_info
  WHERE date_id >= CURRENT_DATE - INTERVAL 35 DAY
    AND date_id <= CURRENT_DATE
),
combo_set AS (
  SELECT DISTINCT
    tenant_id,
    plate_type,
    surface,
    attr1,
    steel_grade_series,
    group_manuf_line_name,
    manuf_line_name
  FROM ads_sc_xl_13_process1
)
SELECT *
FROM date_spine d
CROSS JOIN combo_set c;
