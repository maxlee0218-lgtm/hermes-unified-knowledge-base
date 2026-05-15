-- READ-ONLY rebuild blueprint for combined_002

SELECT
  tenant_id,
  plate_type,
  group_manuf_line_name,
  manuf_line_name,
  attr1,
  data_date,
  day_weight,
  day_quantity,
  month_weight,
  month_quantity,
  rk,
  rk1,
  remark
FROM ads_sc_xl_13_defined_manuf_line_name_combined;
