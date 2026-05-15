-- Read-only reconciliation for combined -> combined_002

SELECT
  tenant_id,
  plate_type,
  manuf_line_name,
  COALESCE(attr1, '') AS attr1,
  data_date,
  day_weight,
  month_weight,
  day_quantity,
  month_quantity
FROM ads_sc_xl_13_defined_manuf_line_name_combined_002
ORDER BY data_date DESC, tenant_id, manuf_line_name;

EXPLAIN
SELECT
  tenant_id,
  plate_type,
  manuf_line_name,
  attr1,
  data_date,
  day_weight,
  month_weight
FROM ads_sc_xl_13_defined_manuf_line_name_combined_002
WHERE data_date >= CURRENT_DATE - INTERVAL 35 DAY;
