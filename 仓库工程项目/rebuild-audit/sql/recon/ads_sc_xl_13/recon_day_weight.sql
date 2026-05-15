-- Read-only reconciliation for day_weight

WITH source_side AS (
  SELECT
    a.bi_sc_xl_013_process_001_dataDate AS work_date,
    a.tenant_id,
    a.plate_type,
    a.defined_manuf_line_name AS manuf_line_name,
    COALESCE(a.bi_sc_xl_013_process_001_attr1, '') AS attr1,
    SUM(a.weight) / 1000 AS day_weight
  FROM dwd_mes_mm_task_group_output a
  WHERE a.bi_sc_xl_013_process_001_dataDate >= CURRENT_DATE - INTERVAL 35 DAY
    AND a.plate_type IS NOT NULL
    AND a.defined_manuf_line_name IS NOT NULL
    AND a.batch_code IS NOT NULL
    AND a.batch_code <> ''
    AND COALESCE(a.is_ignore, 0) = 0
  GROUP BY 1,2,3,4,5
),
baseline_side AS (
  SELECT
    data_date AS work_date,
    tenant_id,
    plate_type,
    manuf_line_name,
    COALESCE(attr1, '') AS attr1,
    day_weight
  FROM ads_sc_xl_13_defined_manuf_line_name_combined_002
)
SELECT
  COALESCE(s.work_date, b.work_date) AS work_date,
  COALESCE(s.tenant_id, b.tenant_id) AS tenant_id,
  COALESCE(s.plate_type, b.plate_type) AS plate_type,
  COALESCE(s.manuf_line_name, b.manuf_line_name) AS manuf_line_name,
  COALESCE(s.attr1, b.attr1) AS attr1,
  s.day_weight AS source_day_weight,
  b.day_weight AS baseline_day_weight,
  COALESCE(s.day_weight, 0) - COALESCE(b.day_weight, 0) AS diff_day_weight
FROM source_side s
FULL OUTER JOIN baseline_side b
  ON s.work_date = b.work_date
 AND s.tenant_id = b.tenant_id
 AND s.plate_type = b.plate_type
 AND s.manuf_line_name = b.manuf_line_name
 AND s.attr1 = b.attr1;
