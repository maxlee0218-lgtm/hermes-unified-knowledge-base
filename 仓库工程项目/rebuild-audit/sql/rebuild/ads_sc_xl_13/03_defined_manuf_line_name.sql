-- READ-ONLY rebuild blueprint for defined_manuf_line_name

SELECT
  tenant_id,
  plate_type,
  group_manuf_line_name,
  manuf_line_name,
  attr1,
  data_date,
  SUM(weight) AS day_weight,
  SUM(quantity) AS day_quantity
FROM ads_sc_xl_13_defined
GROUP BY 1,2,3,4,5,6;
