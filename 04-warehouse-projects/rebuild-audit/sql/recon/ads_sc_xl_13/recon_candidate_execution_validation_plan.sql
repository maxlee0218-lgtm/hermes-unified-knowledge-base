-- Read-only recon for candidate execution validation plan

-- SECTION 01: candidate input readiness
SELECT 'defined_manuf_line_name' AS input_name, 'pending_execution' AS status
UNION ALL
SELECT 'with_attr_value', 'partial'
UNION ALL
SELECT 'ads_sc_xl_01_local', 'partial'
UNION ALL
SELECT 'with_result_confirm_local', 'partial'
UNION ALL
SELECT 'total_rows_postprocess_local', 'partial';

-- SECTION 02: P1 support readiness
SELECT 'with_attr_value_attr1_manuf_line_name' AS support_name, 'partial' AS status
UNION ALL
SELECT 'with_attr_value_warehouse_doc_type', 'partial'
UNION ALL
SELECT 'ads_sc_xl_01_local', 'partial'
UNION ALL
SELECT 'with_result_confirm_local', 'partial'
UNION ALL
SELECT 'total_rows_postprocess_local', 'partial';

-- SECTION 03: total_rows_postprocess readiness
SELECT
  'total_rows_postprocess_local' AS support_name,
  'partial + pending_execution' AS status;

-- SECTION 04: candidate join key coverage
SELECT
  COUNT(DISTINCT CONCAT_WS('|', tenant_id, data_date, plate_type, manuf_line_name, COALESCE(attr1, ''))) AS distinct_candidate_keys
FROM ads_sc_xl_13_defined_manuf_line_name;

-- SECTION 05: candidate metric coverage
SELECT
  SUM(CASE WHEN day_weight IS NULL THEN 1 ELSE 0 END) AS day_weight_nulls,
  SUM(CASE WHEN day_quantity IS NULL THEN 1 ELSE 0 END) AS day_quantity_nulls,
  SUM(CASE WHEN day_breakdown_frequency IS NULL THEN 1 ELSE 0 END) AS day_breakdown_frequency_nulls
FROM ads_sc_xl_13_defined_manuf_line_name_combined;

-- SECTION 06: pass_fail_summary_blueprint
SELECT
  'pending_execution' AS execution_status,
  'ready_for_execution_validation_plan' AS current_status,
  'candidate execution validation can proceed as readonly dry-run planning' AS conclusion_hint;

-- SECTION 07: why complete combined_local remains blocked
SELECT 'with_attr_value' AS blocker, 'partial + pending_execution' AS status
UNION ALL
SELECT 'ads_sc_xl_01_local', 'partial + pending_execution'
UNION ALL
SELECT 'with_result_confirm_local', 'partial + pending_execution'
UNION ALL
SELECT 'total_rows_postprocess_local', 'partial + pending_execution';
