-- Read-only recon for with_attr_value attr1 / manuf_line_name scene closure

-- SECTION 01: attr1_mapping_coverage
SELECT
  a.tenant_id,
  a.machine_code,
  COUNT(*) AS row_cnt
FROM dwd_mes_mm_task_group_output a
LEFT JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND a.machine_code = av.attribute2
 AND av.scene IN (
   'BI-SC-KC-013-DEFINED-TYPE-LZ',
   'BI-SC-KC-013-DEFINED-TYPE-JJG',
   'BI-SC-KC-013-DEFINED-TYPE-GG'
 )
WHERE a.bi_sc_xl_013_process_001_dataDate >= CURRENT_DATE - INTERVAL 35 DAY
  AND av.with_id IS NULL
GROUP BY a.tenant_id, a.machine_code
ORDER BY row_cnt DESC
LIMIT 100;

-- SECTION 02: manuf_line_name_mapping_coverage
SELECT
  a.tenant_id,
  a.machine_code,
  COUNT(*) AS row_cnt
FROM dwd_mes_mm_task_group_output a
LEFT JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND a.machine_code = av.attribute2
 AND av.scene IN (
   'BI-SC-KC-013-DEFINED-TYPE-LZ',
   'BI-SC-KC-013-DEFINED-TYPE-JJG',
   'BI-SC-KC-013-DEFINED-TYPE-GG'
 )
WHERE a.bi_sc_xl_013_process_001_dataDate >= CURRENT_DATE - INTERVAL 35 DAY
  AND av.with_id IS NULL
GROUP BY a.tenant_id, a.machine_code
ORDER BY row_cnt DESC
LIMIT 100;

-- SECTION 03: source_only_rows
WITH warehouse_side AS (
  SELECT DISTINCT
    tenant_id,
    machine_code
  FROM dwd_mes_mm_task_group_output
  WHERE bi_sc_xl_013_process_001_dataDate >= CURRENT_DATE - INTERVAL 35 DAY
),
mapping_side AS (
  SELECT DISTINCT
    tenant_id,
    attribute2 AS machine_code
  FROM with_attr_value
  WHERE scene IN (
    'BI-SC-KC-013-DEFINED-TYPE-LZ',
    'BI-SC-KC-013-DEFINED-TYPE-JJG',
    'BI-SC-KC-013-DEFINED-TYPE-GG'
  )
)
SELECT w.*
FROM warehouse_side w
LEFT JOIN mapping_side m
  ON w.tenant_id = m.tenant_id
 AND w.machine_code = m.machine_code
WHERE m.machine_code IS NULL
LIMIT 200;

-- SECTION 04: baseline_only_rows
SELECT m.*
FROM mapping_side m
LEFT JOIN warehouse_side w
  ON w.tenant_id = m.tenant_id
 AND w.machine_code = m.machine_code
WHERE w.machine_code IS NULL
LIMIT 200;

-- SECTION 05: key_level_diff_blueprint
SELECT
  a.tenant_id,
  a.machine_code,
  a.bi_sc_xl_013_process_001_attr1 AS attr1_candidate,
  a.defined_manuf_line_name AS manuf_line_name_candidate
FROM dwd_mes_mm_task_group_output a
WHERE a.bi_sc_xl_013_process_001_dataDate >= CURRENT_DATE - INTERVAL 35 DAY
LIMIT 200;

-- SECTION 06: metric_level_impact_blueprint
SELECT
  tenant_id,
  defined_manuf_line_name,
  bi_sc_xl_013_process_001_attr1 AS attr1,
  SUM(weight) / 1000 AS source_weight
FROM dwd_mes_mm_task_group_output
WHERE bi_sc_xl_013_process_001_dataDate >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY 1,2,3
ORDER BY source_weight DESC
LIMIT 200;

-- SECTION 07: defined_to_defined_manuf_line_name_mapping_impact
SELECT
  data_date,
  tenant_id,
  plate_type,
  group_manuf_line_name,
  manuf_line_name,
  COALESCE(attr1, '') AS attr1,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined
GROUP BY 1,2,3,4,5,6
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 08: impact_on_combined_candidate
SELECT
  'combined_candidate' AS target_stage,
  'with_attr_value attr1/manuf_line_name mapping required before stable combined projection' AS impact_statement;

-- SECTION 09: impact_on_combined_local
SELECT
  'combined_local' AS target_stage,
  'blocked until with_attr_value mapping closure is sufficiently validated' AS impact_statement;

-- SECTION 10: pass_fail_summary_blueprint
SELECT
  'pending_execution' AS execution_status,
  'needs_business_clarification' AS semantic_status,
  'with_attr_value is a config mapping dependency, not a fact chain' AS conclusion_hint;
