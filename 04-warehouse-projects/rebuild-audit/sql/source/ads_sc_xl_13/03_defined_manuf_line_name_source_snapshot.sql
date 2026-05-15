-- ADS_SC_XL_13 legacy source snapshot
-- Task: 18333852605956 ADS_SC_XL_13_DEFINED_MANUF_LINE_NAME

SELECT
  a.tenant_id,
  a.plate_type,
  a.group_manuf_line_name,
  a.manuf_line_name,
  a.attr1,
  a.data_date,
  SUM(a.weight) AS weight,
  SUM(a.quantity) AS quantity,
  SUM(a.lower_weight) AS lower_weight,
  SUM(a.lower_quantity) AS lower_quantity
FROM ads_sc_xl_13_defined a
WHERE a.manuf_line_name <> ''
  AND a.data_date >= CURRENT_DATE - INTERVAL 30 DAY
GROUP BY
  a.tenant_id,
  a.plate_type,
  a.manuf_line_name,
  a.attr1,
  a.data_date;
