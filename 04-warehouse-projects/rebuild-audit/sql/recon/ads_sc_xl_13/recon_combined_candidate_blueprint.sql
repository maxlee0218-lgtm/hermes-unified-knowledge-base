-- Read-only recon for combined candidate blueprint

-- SECTION 01: input_readiness_summary
SELECT 'defined_manuf_line_name' AS input_name, 'pending_execution' AS status
UNION ALL
SELECT 'with_attr_value', 'partial'
UNION ALL
SELECT 'ads_sc_xl_01_local', 'partial'
UNION ALL
SELECT 'with_result_confirm_local', 'partial'
UNION ALL
SELECT 'total_rows_postprocess_local', 'partial';

-- SECTION 02: candidate_row_count_blueprint
SELECT COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name;

-- SECTION 03: candidate_join_key_coverage
SELECT
  tenant_id,
  data_date,
  plate_type,
  manuf_line_name,
  COALESCE(attr1, '') AS attr1,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name
GROUP BY tenant_id, data_date, plate_type, manuf_line_name, COALESCE(attr1, '')
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 04: candidate_metric_coverage
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

-- SECTION 05: with_attr_value_mapping_impact
SELECT
  'with_attr_value' AS source_name,
  'mapping still partial and pending execution validation' AS impact_statement;

-- SECTION 06: ads_sc_xl_01_mapping_impact
SELECT
  'ads_sc_xl_01_local' AS source_name,
  'join skeleton ready but candidate join still pending execution validation' AS impact_statement;

-- SECTION 07: with_result_confirm_impact
SELECT
  'with_result_confirm_local' AS source_name,
  'manual confirm layer is structurally clear but not yet executed' AS impact_statement;

-- SECTION 08: total_rows_postprocess_impact
SELECT
  'total_rows_postprocess_local' AS source_name,
  'summary rows are postprocess branches and must remain explicit in candidate layer' AS impact_statement;

-- SECTION 09: source_only_rows
SELECT
  'source_only_rows_require_candidate_execution_validation' AS note;

-- SECTION 10: baseline_only_rows
SELECT
  'baseline_only_rows_require_candidate_execution_validation' AS note;

-- SECTION 11: key_level_diff_blueprint
SELECT
  tenant_id,
  data_date,
  plate_type,
  manuf_line_name,
  COALESCE(attr1, '') AS attr1
FROM ads_sc_xl_13_defined_manuf_line_name
LIMIT 200;

-- SECTION 12: metric_level_diff_blueprint
SELECT
  tenant_id,
  data_date,
  manuf_line_name,
  COALESCE(attr1, '') AS attr1,
  day_weight,
  day_quantity,
  day_breakdown_frequency
FROM ads_sc_xl_13_defined_manuf_line_name_combined
LIMIT 200;

-- SECTION 13: pass_fail_summary_blueprint
SELECT
  'pending_execution' AS execution_status,
  'ready_for_candidate_blueprint' AS current_status,
  'candidate blueprint can proceed, but complete combined_local remains blocked' AS conclusion_hint;

-- SECTION 14: why_complete_combined_local_remains_blocked
SELECT 'with_attr_value' AS blocker, 'partial + pending_execution' AS status
UNION ALL
SELECT 'ads_sc_xl_01_local', 'partial + pending_execution'
UNION ALL
SELECT 'with_result_confirm_local', 'partial + pending_execution'
UNION ALL
SELECT 'total_rows_postprocess_local', 'partial + pending_execution';
