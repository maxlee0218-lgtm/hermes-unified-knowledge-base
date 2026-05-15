-- Read-only recon for ads_sc_xl_01_local join skeleton and candidate join
-- Candidate probes only. Do not treat attribute-slot matches as finalized semantics.

-- SECTION 01: source_row_count
SELECT COUNT(*) AS source_row_count
FROM ads_sc_xl_01
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY;

-- SECTION 02: candidate_join_key_distinct_count
SELECT COUNT(*) AS distinct_join_keys
FROM (
  SELECT DISTINCT
    tenant_id,
    data_date,
    wh_code,
    dept_code,
    machine_code,
    other_machine_code,
    rd_style,
    rd_style_name,
    bill_type
  FROM ads_sc_xl_01
  WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
) t;

-- SECTION 03: warehouse_mapping_coverage
SELECT 'attribute1_wh_code' AS candidate_rule, COUNT(*) AS matched_rows
FROM ads_sc_xl_01 a
JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND av.scene LIKE 'BI-SC-KC-013-WH-CODE-%'
 AND av.attribute1 = a.wh_code
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY
UNION ALL
SELECT 'attribute2_wh_code' AS candidate_rule, COUNT(*) AS matched_rows
FROM ads_sc_xl_01 a
JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND av.scene LIKE 'BI-SC-KC-013-WH-CODE-%'
 AND av.attribute2 = a.wh_code
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY
UNION ALL
SELECT 'attribute2_dept_code' AS candidate_rule, COUNT(*) AS matched_rows
FROM ads_sc_xl_01 a
JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND av.scene LIKE 'BI-SC-KC-013-WH-CODE-%'
 AND av.attribute2 = a.dept_code
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY
UNION ALL
SELECT 'attribute3_machine_code' AS candidate_rule, COUNT(*) AS matched_rows
FROM ads_sc_xl_01 a
JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND av.scene LIKE 'BI-SC-KC-013-WH-CODE-%'
 AND av.attribute3 = a.machine_code
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY
UNION ALL
SELECT 'attribute4_other_machine_code' AS candidate_rule, COUNT(*) AS matched_rows
FROM ads_sc_xl_01 a
JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND av.scene LIKE 'BI-SC-KC-013-WH-CODE-%'
 AND av.attribute4 = a.other_machine_code
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY;

-- SECTION 04: document_type_mapping_coverage
SELECT 'attribute1_rd_style' AS candidate_rule, COUNT(*) AS matched_rows
FROM ads_sc_xl_01 a
JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND av.scene LIKE 'BI-SC-KC-013-RD-FINISHED-%'
 AND av.attribute1 = a.rd_style
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY
UNION ALL
SELECT 'attribute1_rd_style_name' AS candidate_rule, COUNT(*) AS matched_rows
FROM ads_sc_xl_01 a
JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND av.scene LIKE 'BI-SC-KC-013-RD-FINISHED-%'
 AND av.attribute1 = a.rd_style_name
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY
UNION ALL
SELECT 'attribute2_rd_style' AS candidate_rule, COUNT(*) AS matched_rows
FROM ads_sc_xl_01 a
JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND av.scene LIKE 'BI-SC-KC-013-RD-FINISHED-%'
 AND av.attribute2 = a.rd_style
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY
UNION ALL
SELECT 'attribute2_rd_style_name' AS candidate_rule, COUNT(*) AS matched_rows
FROM ads_sc_xl_01 a
JOIN with_attr_value av
  ON a.tenant_id = av.tenant_id
 AND av.scene LIKE 'BI-SC-KC-013-RD-FINISHED-%'
 AND av.attribute2 = a.rd_style_name
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY;

-- SECTION 05: config_only_rows
SELECT
  av.scene,
  av.tenant_id,
  av.attribute1,
  av.attribute2,
  av.attribute3,
  av.attribute4
FROM with_attr_value av
WHERE (
    av.scene LIKE 'BI-SC-KC-013-WH-CODE-%'
    OR av.scene LIKE 'BI-SC-KC-013-RD-FINISHED-%'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM ads_sc_xl_01 a
    WHERE a.tenant_id = av.tenant_id
      AND a.data_date >= CURRENT_DATE - INTERVAL 35 DAY
      AND (
        a.wh_code = av.attribute1
        OR a.wh_code = av.attribute2
        OR a.dept_code = av.attribute2
        OR a.machine_code = av.attribute3
        OR a.other_machine_code = av.attribute4
        OR a.rd_style = av.attribute1
        OR a.rd_style_name = av.attribute1
        OR a.rd_style = av.attribute2
        OR a.rd_style_name = av.attribute2
      )
  )
LIMIT 100;

-- SECTION 06: source_only_rows
SELECT
  a.tenant_id,
  a.wh_code,
  a.dept_code,
  a.machine_code,
  a.other_machine_code,
  a.rd_style,
  a.rd_style_name,
  a.bill_type,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_01 a
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY
  AND NOT EXISTS (
    SELECT 1
    FROM with_attr_value av
    WHERE av.tenant_id = a.tenant_id
      AND (
        (
          av.scene LIKE 'BI-SC-KC-013-WH-CODE-%'
          AND (
            av.attribute1 = a.wh_code
            OR av.attribute2 = a.wh_code
            OR av.attribute2 = a.dept_code
            OR av.attribute3 = a.machine_code
            OR av.attribute4 = a.other_machine_code
          )
        )
        OR (
          av.scene LIKE 'BI-SC-KC-013-RD-FINISHED-%'
          AND (
            av.attribute1 = a.rd_style
            OR av.attribute1 = a.rd_style_name
            OR av.attribute2 = a.rd_style
            OR av.attribute2 = a.rd_style_name
          )
        )
      )
  )
GROUP BY
  a.tenant_id,
  a.wh_code,
  a.dept_code,
  a.machine_code,
  a.other_machine_code,
  a.rd_style,
  a.rd_style_name,
  a.bill_type
ORDER BY row_cnt DESC
LIMIT 100;

-- SECTION 07: baseline_only_rows
SELECT
  'baseline_only_blueprint' AS status,
  'requires downstream combined candidate keys to judge true baseline-only rows' AS note;

-- SECTION 08: key_level_diff_blueprint
SELECT
  tenant_id,
  data_date,
  wh_code,
  dept_code,
  machine_code,
  other_machine_code,
  rd_style,
  rd_style_name,
  bill_type
FROM ads_sc_xl_01
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
LIMIT 200;

-- SECTION 09: metric_level_impact_blueprint
SELECT
  tenant_id,
  data_date,
  machine_code,
  rd_style_name,
  SUM(weight) AS total_weight,
  SUM(quantity) AS total_quantity,
  SUM(roll_length) AS total_roll_length
FROM ads_sc_xl_01
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY
GROUP BY tenant_id, data_date, machine_code, rd_style_name
ORDER BY total_weight DESC
LIMIT 200;

-- SECTION 10: impact_on_combined_candidate
SELECT
  'combined_candidate' AS target_stage,
  'ads_sc_xl_01_local candidate join can be designed now, but mapping semantics are still partial' AS impact_statement;

-- SECTION 11: impact_on_combined_local
SELECT
  'combined_local' AS target_stage,
  'blocked until ads_sc_xl_01_local, with_result_confirm_local, and summary-row logic are sufficiently closed' AS impact_statement;

-- SECTION 12: pass_fail_summary_blueprint
SELECT
  'pending_execution' AS execution_status,
  'partial' AS current_status,
  'ads_sc_xl_01_local skeleton is ready; do not treat candidate joins as final business semantics' AS conclusion_hint;
