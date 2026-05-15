-- Read-only recon for combined candidate readiness

-- SECTION 01: readiness_summary
SELECT 'defined_manuf_line_name' AS input_name, 'pending_execution' AS status
UNION ALL
SELECT 'with_attr_value', 'partial'
UNION ALL
SELECT 'ads_sc_xl_01_local', 'partial'
UNION ALL
SELECT 'with_result_confirm_local', 'partial'
UNION ALL
SELECT 'total_rows_postprocess', 'partial';

-- SECTION 02: defined_manuf_line_name row/key summary
SELECT
  COUNT(*) AS row_cnt,
  COUNT(DISTINCT CONCAT_WS('|', tenant_id, data_date, plate_type, manuf_line_name, COALESCE(attr1, ''))) AS distinct_keys
FROM ads_sc_xl_13_defined_manuf_line_name;

-- SECTION 03: ads_sc_xl_01 row/key summary
SELECT
  COUNT(*) AS row_cnt,
  COUNT(DISTINCT CONCAT_WS('|', tenant_id, data_date, wh_code, dept_code, machine_code, other_machine_code, rd_style_name, bill_type)) AS distinct_keys
FROM ads_sc_xl_01;

-- SECTION 04: with_result_confirm row/key summary
SELECT
  COUNT(*) AS row_cnt,
  COUNT(DISTINCT CONCAT_WS('|', tenant_id, report_id, attribute1, attribute2, attribute23)) AS distinct_keys
FROM with_result_confirm
WHERE report_id IN ('237', '239', '543')
  AND result_cat = 'REPORT_BUSINESS_DATA';

-- SECTION 05: candidate_join_key_coverage
SELECT
  c.tenant_id,
  c.data_date,
  c.manuf_line_name,
  COALESCE(c.attr1, '') AS attr1,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name c
GROUP BY c.tenant_id, c.data_date, c.manuf_line_name, COALESCE(c.attr1, '')
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 06: candidate_metric_coverage
SELECT
  tenant_id,
  data_date,
  manuf_line_name,
  COALESCE(attr1, '') AS attr1,
  SUM(day_weight) AS total_day_weight,
  SUM(day_quantity) AS total_day_quantity
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY tenant_id, data_date, manuf_line_name, COALESCE(attr1, '')
ORDER BY total_day_weight DESC
LIMIT 200;

-- SECTION 07: source_only / baseline_only blueprint
SELECT
  'source_only_and_baseline_only_require_local_candidate_layer' AS note;

-- SECTION 08: complete_combined_local_blocker_summary
SELECT 'with_attr_value' AS blocker, 'partial + pending_execution' AS status
UNION ALL
SELECT 'ads_sc_xl_01_local', 'partial + pending_execution'
UNION ALL
SELECT 'with_result_confirm_local', 'partial + pending_execution'
UNION ALL
SELECT 'total_rows_postprocess', 'partial + pending_execution';
