-- ADS_SC_XL_13 legacy source snapshot
-- Task: 18333852605973 BI_SC_XL_013_DEFINED_MANUF_LINE_NAME_COMBINED_001

SELECT
  tenant_id,
  plate_type,
  group_manuf_line_name,
  manuf_line_name,
  attr1,
  '日' AS period,
  data_date,
  day_weight AS weight,
  day_quantity AS quantity
FROM ads_sc_xl_13_defined_manuf_line_name_combined

UNION ALL

SELECT
  tenant_id,
  plate_type,
  group_manuf_line_name,
  manuf_line_name,
  attr1,
  '月' AS period,
  data_date,
  month_weight AS weight,
  month_quantity AS quantity
FROM ads_sc_xl_13_defined_manuf_line_name_combined;

-- This table is a presentation table with mixed period semantics.
