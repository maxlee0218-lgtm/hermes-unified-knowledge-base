-- Read-only recon for with_result_confirm_local closure

-- SECTION 01: source_row_count
SELECT
  report_id,
  COUNT(*) AS row_cnt
FROM with_result_confirm
WHERE report_id IN ('237', '239', '543')
  AND result_cat = 'REPORT_BUSINESS_DATA'
GROUP BY report_id
ORDER BY report_id;

-- SECTION 02: candidate_join_key_distinct_count
SELECT COUNT(*) AS distinct_join_keys
FROM (
  SELECT DISTINCT
    tenant_id,
    attribute1,
    attribute2,
    attribute3,
    attribute23,
    report_id
  FROM with_result_confirm
  WHERE report_id IN ('237', '239', '543')
    AND result_cat = 'REPORT_BUSINESS_DATA'
) t;

-- SECTION 03: confirm_mapping_coverage
SELECT
  c.tenant_id,
  c.manuf_line_name,
  c.data_date,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name_combined c
LEFT JOIN with_result_confirm w
  ON c.tenant_id = w.tenant_id
 AND c.manuf_line_name = w.attribute1
 AND c.data_date = w.attribute2
 AND (COALESCE(c.attr1, '') = COALESCE(w.attribute23, '') OR c.attr1 IS NULL)
 AND w.report_id IN ('237', '239', '543')
 AND w.result_cat = 'REPORT_BUSINESS_DATA'
WHERE c.data_date >= CURRENT_DATE - INTERVAL 35 DAY
  AND w.tenant_id IS NULL
GROUP BY c.tenant_id, c.manuf_line_name, c.data_date
ORDER BY row_cnt DESC
LIMIT 100;

-- SECTION 04: source_only_rows
SELECT
  tenant_id,
  report_id,
  attribute1 AS manuf_line_name,
  attribute2 AS data_date,
  attribute23 AS attr1,
  COUNT(*) AS row_cnt
FROM with_result_confirm
WHERE report_id IN ('237', '239', '543')
  AND result_cat = 'REPORT_BUSINESS_DATA'
GROUP BY tenant_id, report_id, attribute1, attribute2, attribute23
ORDER BY row_cnt DESC
LIMIT 100;

-- SECTION 05: baseline_only_rows
SELECT
  'baseline_only_blueprint' AS status,
  'requires local reconstructed confirm layer to determine true baseline-only rows' AS note;

-- SECTION 06: key_level_diff_blueprint
SELECT
  tenant_id,
  attribute1 AS manuf_line_name,
  attribute2 AS data_date,
  attribute3 AS plate_type,
  attribute23 AS attr1,
  report_id
FROM with_result_confirm
WHERE report_id IN ('237', '239', '543')
LIMIT 200;

-- SECTION 07: metric_level_impact_blueprint
SELECT
  tenant_id,
  report_id,
  attribute1 AS manuf_line_name,
  attribute2 AS data_date,
  SUM(COALESCE(NULLIF(attribute9, ''), 0)) AS breakdown_frequency_sum,
  SUM(COALESCE(NULLIF(attribute10, ''), 0)) AS planned_downtime_sum,
  SUM(COALESCE(NULLIF(attribute11, ''), 0)) AS unplanned_downtime_sum
FROM with_result_confirm
WHERE report_id IN ('237', '239', '543')
  AND result_cat = 'REPORT_BUSINESS_DATA'
GROUP BY tenant_id, report_id, attribute1, attribute2
ORDER BY breakdown_frequency_sum DESC
LIMIT 200;

-- SECTION 08: impact_on_combined_candidate
SELECT
  'combined_candidate' AS target_stage,
  'candidate blueprint can proceed, but confirm coverage must remain explicit' AS impact_statement;

-- SECTION 09: impact_on_combined_local
SELECT
  'combined_local' AS target_stage,
  'blocked until with_result_confirm_local is executed and validated' AS impact_statement;

-- SECTION 10: pass_fail_summary_blueprint
SELECT
  'pending_execution' AS execution_status,
  'partial' AS current_status,
  'with_result_confirm is the manual override layer for downtime and remark' AS conclusion_hint;
