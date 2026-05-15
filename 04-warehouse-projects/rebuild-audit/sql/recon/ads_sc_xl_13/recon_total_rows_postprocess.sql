-- Read-only recon for total rows postprocess

-- SECTION 01: generate attr1='合计' blueprint from detail rows
SELECT
  tenant_id,
  plate_type,
  group_manuf_line_name,
  manuf_line_name,
  data_date,
  SUM(day_weight) AS total_day_weight,
  SUM(day_quantity) AS total_day_quantity
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE COALESCE(attr1, '') <> '合计'
  AND manuf_line_name <> '总计'
GROUP BY tenant_id, plate_type, group_manuf_line_name, manuf_line_name, data_date
ORDER BY total_day_weight DESC
LIMIT 200;

-- SECTION 02: generate manuf_line_name='总计' blueprint from detail rows
SELECT
  tenant_id,
  plate_type,
  data_date,
  SUM(day_weight) AS total_day_weight,
  SUM(day_quantity) AS total_day_quantity
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE manuf_line_name <> '总计'
  AND COALESCE(attr1, '') <> '合计'
GROUP BY tenant_id, plate_type, data_date
ORDER BY total_day_weight DESC
LIMIT 200;

-- SECTION 03: baseline summary-row comparison
SELECT
  CASE
    WHEN attr1 = '合计' THEN 'attr1_total'
    WHEN manuf_line_name = '总计' THEN 'manuf_line_total'
    ELSE 'detail'
  END AS row_kind,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name_combined
GROUP BY row_kind
ORDER BY row_kind;

-- SECTION 04: source-only summary rows
SELECT
  tenant_id,
  plate_type,
  manuf_line_name,
  attr1,
  data_date,
  COUNT(*) AS row_cnt
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE attr1 = '合计'
   OR manuf_line_name = '总计'
GROUP BY tenant_id, plate_type, manuf_line_name, attr1, data_date
ORDER BY row_cnt DESC
LIMIT 100;

-- SECTION 05: baseline-only summary rows blueprint
SELECT
  'baseline_only_summary_rows_require_local_postprocess_layer' AS note;

-- SECTION 06: metric-level diff blueprint
SELECT
  tenant_id,
  plate_type,
  manuf_line_name,
  attr1,
  data_date,
  day_weight,
  day_quantity,
  month_weight,
  month_quantity
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE attr1 = '合计'
   OR manuf_line_name = '总计'
LIMIT 200;

-- SECTION 07: pass_fail_summary_blueprint
SELECT
  'pending_execution' AS execution_status,
  'partial' AS current_status,
  'summary rows are explicit postprocess branches, not raw fact rows' AS conclusion_hint;
