-- READ-ONLY rebuild blueprint for process1

WITH source_rows AS (
  SELECT
    bi_sc_xl_013_process_001_dataDate AS work_date,
    tenant_id,
    plate_type,
    surface,
    COALESCE(bi_sc_xl_013_process_001_attr1, '') AS attr1,
    steel_grade_series,
    defined_manuf_line_name AS manuf_line_name,
    weight,
    quantity,
    roll_length,
    grade,
    batch_code,
    is_ignore,
    send_happened,
    is_retention
  FROM dwd_mes_mm_task_group_output
)
SELECT *
FROM source_rows
WHERE work_date >= CURRENT_DATE - INTERVAL 35 DAY;
