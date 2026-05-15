-- ADS_SC_XL_13 legacy source snapshot
-- Task: 18333852605954 ADS_SC_XL_13_PROCESS_001
-- Role: dwd_mes_mm_task_group_output -> ads_sc_xl_13_process1

SELECT
  a.tenant_id,
  a.plate_type,
  a.surface,
  a.bi_sc_xl_013_process_001_attr1 AS attr1,
  a.steel_grade_series,
  a.defined_manuf_line_name AS group_manuf_line_name,
  a.defined_manuf_line_name AS manuf_line_name,
  a.bi_sc_xl_013_process_001_dataDate AS data_date,
  SUM(a.weight) / 1000 AS weight,
  SUM(a.quantity) AS quantity,
  SUM(a.roll_length) AS manufacturing_finished_output_length
FROM dwd_mes_mm_task_group_output a
WHERE a.plate_type IS NOT NULL
  AND a.defined_manuf_line_name IS NOT NULL
  AND a.batch_code IS NOT NULL
  AND a.batch_code <> ''
  AND a.is_ignore = 0
  AND a.bi_sc_xl_013_process_001_dataDate >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY
  a.tenant_id,
  a.defined_manuf_line_name,
  a.surface,
  a.bi_sc_xl_013_process_001_attr1,
  a.steel_grade_series,
  a.bi_sc_xl_013_process_001_dataDate,
  a.plate_type;

-- Tenant-specific filters and lower_weight exclusions are part of the stable logic.
