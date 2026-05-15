-- Read-only recon for with_attr_value warehouse / document type scene closure
-- Note: candidate probes only. Do not treat attribute slot matches as final business semantics.

-- SECTION 01: scene_family_row_counts
SELECT
  scene,
  tenant_id,
  COUNT(*) AS row_cnt
FROM with_attr_value
WHERE scene LIKE 'BI-SC-KC-013-WH-CODE-%'
   OR scene LIKE 'BI-SC-KC-013-RD-FINISHED-%'
GROUP BY scene, tenant_id
ORDER BY scene, tenant_id;

-- SECTION 02: warehouse_candidate_probe_counts
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

-- SECTION 03: document_type_candidate_probe_counts
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

-- SECTION 04: warehouse_unmatched_lower_bound
SELECT
  a.tenant_id,
  a.wh_code,
  a.dept_code,
  a.machine_code,
  a.other_machine_code,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_01 a
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY
  AND NOT EXISTS (
    SELECT 1
    FROM with_attr_value av
    WHERE av.tenant_id = a.tenant_id
      AND av.scene LIKE 'BI-SC-KC-013-WH-CODE-%'
      AND (
        av.attribute1 = a.wh_code
        OR av.attribute2 = a.wh_code
        OR av.attribute2 = a.dept_code
        OR av.attribute3 = a.machine_code
        OR av.attribute4 = a.other_machine_code
      )
  )
GROUP BY
  a.tenant_id,
  a.wh_code,
  a.dept_code,
  a.machine_code,
  a.other_machine_code
ORDER BY row_cnt DESC
LIMIT 100;

-- SECTION 05: document_type_unmatched_lower_bound
SELECT
  a.tenant_id,
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
      AND av.scene LIKE 'BI-SC-KC-013-RD-FINISHED-%'
      AND (
        av.attribute1 = a.rd_style
        OR av.attribute1 = a.rd_style_name
        OR av.attribute2 = a.rd_style
        OR av.attribute2 = a.rd_style_name
      )
  )
GROUP BY
  a.tenant_id,
  a.rd_style,
  a.rd_style_name,
  a.bill_type
ORDER BY row_cnt DESC
LIMIT 100;

-- SECTION 06: next_step_blueprint
SELECT
  'pending_execution' AS execution_status,
  'partial' AS evidence_status,
  'ads_sc_xl_01_local can move to blueprint stage, but combined_local remains blocked' AS conclusion_hint;
