-- Read-only recon for readonly execution dry-run package

-- SECTION 01: P1 readiness summary
SELECT 'with_attr_value_attr1_manuf_line_name' AS node_name, 'partial + pending_execution' AS status
UNION ALL
SELECT 'with_attr_value_warehouse_doc_type', 'partial + pending_execution'
UNION ALL
SELECT 'ads_sc_xl_01_local', 'partial + pending_execution'
UNION ALL
SELECT 'with_result_confirm_local', 'partial + pending_execution'
UNION ALL
SELECT 'total_rows_postprocess_local', 'partial + pending_execution';

-- SECTION 02: candidate input coverage summary
SELECT
  COUNT(DISTINCT CONCAT_WS('|', tenant_id, data_date, plate_type, manuf_line_name, COALESCE(attr1, ''))) AS distinct_candidate_keys
FROM ads_sc_xl_13_defined_manuf_line_name;

-- SECTION 03: source-only / baseline-only blueprint
SELECT 'source_only_blueprint_requires_actual_execution' AS note
UNION ALL
SELECT 'baseline_only_blueprint_requires_actual_execution';

-- SECTION 04: total_rows_postprocess blueprint
SELECT
  COUNT(*) AS summary_row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE attr1 = '合计'
   OR manuf_line_name = '总计';

-- SECTION 05: go/no-go summary
SELECT
  'go_for_evidence_collection' AS dry_run_status,
  'blocked_for_complete_combined_local' AS complete_combined_local_status,
  'actual readonly execution evidence still missing' AS reason;
