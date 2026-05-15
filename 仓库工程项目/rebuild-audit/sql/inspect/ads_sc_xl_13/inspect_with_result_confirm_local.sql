-- Read-only inspection for with_result_confirm_local closure

SHOW CREATE TABLE with_result_confirm;
DESC with_result_confirm;
SELECT COUNT(*) AS total_rows FROM with_result_confirm;

-- SECTION 01: report distribution
SELECT
  report_id,
  result_cat,
  status,
  COUNT(*) AS row_cnt
FROM with_result_confirm
GROUP BY report_id, result_cat, status
ORDER BY report_id, result_cat, status;

-- SECTION 02: date candidate distribution
SELECT
  MIN(attribute2) AS min_attribute2,
  MAX(attribute2) AS max_attribute2,
  COUNT(*) AS row_cnt
FROM with_result_confirm
WHERE report_id IN ('237', '239', '543');

SELECT
  MIN(period) AS min_period,
  MAX(period) AS max_period,
  COUNT(*) AS row_cnt
FROM with_result_confirm
WHERE report_id IN ('237', '239', '543');

-- SECTION 03: tenant distribution
SELECT
  tenant_id,
  report_id,
  COUNT(*) AS row_cnt
FROM with_result_confirm
WHERE report_id IN ('237', '239', '543')
GROUP BY tenant_id, report_id
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 04: candidate key distribution
SELECT
  tenant_id,
  attribute1,
  attribute2,
  attribute3,
  attribute23,
  COUNT(*) AS row_cnt
FROM with_result_confirm
WHERE report_id IN ('237', '239', '543')
GROUP BY tenant_id, attribute1, attribute2, attribute3, attribute23
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 05: candidate metric distribution
SELECT
  report_id,
  COUNT(attribute9) AS cnt_attr9,
  COUNT(attribute10) AS cnt_attr10,
  COUNT(attribute11) AS cnt_attr11,
  COUNT(attribute12) AS cnt_attr12,
  COUNT(attribute13) AS cnt_attr13
FROM with_result_confirm
WHERE report_id IN ('237', '239', '543')
GROUP BY report_id
ORDER BY report_id;

-- SECTION 06: ads_sc_xl_01 direct join candidates not confirmed
-- No stable evidence yet that with_result_confirm directly joins ads_sc_xl_01.
-- Keep this as an indirect relationship through combined candidate.

-- SECTION 07: defined_manuf_line_name / combined candidate key blueprint
SELECT
  tenant_id,
  attribute1 AS manuf_line_name_candidate,
  attribute2 AS data_date_candidate,
  attribute3 AS plate_type_candidate,
  attribute23 AS attr1_candidate,
  COUNT(*) AS row_cnt
FROM with_result_confirm
WHERE report_id IN ('237', '239', '543')
GROUP BY tenant_id, attribute1, attribute2, attribute3, attribute23
ORDER BY row_cnt DESC
LIMIT 200;

-- SECTION 08: null / abnormal blueprint
SELECT
  SUM(CASE WHEN tenant_id IS NULL THEN 1 ELSE 0 END) AS tenant_id_nulls,
  SUM(CASE WHEN attribute1 IS NULL OR attribute1 = '' THEN 1 ELSE 0 END) AS attribute1_null_or_blank,
  SUM(CASE WHEN attribute2 IS NULL OR attribute2 = '' THEN 1 ELSE 0 END) AS attribute2_null_or_blank,
  SUM(CASE WHEN report_id IS NULL OR report_id = '' THEN 1 ELSE 0 END) AS report_id_null_or_blank,
  SUM(CASE WHEN status IS NULL OR status = '' THEN 1 ELSE 0 END) AS status_null_or_blank
FROM with_result_confirm;

-- SECTION 09: explain-only combined join blueprint
EXPLAIN
SELECT
  c.tenant_id,
  c.manuf_line_name,
  c.attr1,
  c.data_date,
  w.report_id
FROM ads_sc_xl_13_defined_manuf_line_name_combined c
LEFT JOIN with_result_confirm w
  ON c.tenant_id = w.tenant_id
 AND c.manuf_line_name = w.attribute1
 AND c.data_date = w.attribute2
WHERE w.report_id IN ('237', '239', '543');
