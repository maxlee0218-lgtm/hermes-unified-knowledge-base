-- ADS_SC_XL_13 legacy source snapshot
-- Task: 18333852605955 ADS_SC_XL_13_DEFINED
-- Role: date skeleton fill for process1

SELECT
  dr.date_id AS data_date,
  t.tenant_id,
  t.plate_type,
  t.surface,
  t.attr1,
  t.steel_grade_series,
  t.group_manuf_line_name,
  t.manuf_line_name,
  COALESCE(orig.weight, 0) AS weight,
  COALESCE(orig.quantity, 0) AS quantity
FROM (
  SELECT date_id
  FROM dim_date_info
  WHERE date_id <= CURDATE()
    AND date_id >= CURDATE() - INTERVAL 35 DAY
) dr
JOIN (
  SELECT DISTINCT
    tenant_id,
    plate_type,
    surface,
    attr1,
    steel_grade_series,
    group_manuf_line_name,
    manuf_line_name
  FROM ads_sc_xl_13_process1
  WHERE data_date >= CURDATE() - INTERVAL 350 DAY
) t
LEFT JOIN ads_sc_xl_13_process1 orig
  ON dr.date_id = orig.data_date
 AND t.tenant_id = orig.tenant_id
 AND t.plate_type = orig.plate_type
 AND t.surface = orig.surface
 AND (t.attr1 <=> orig.attr1)
 AND t.steel_grade_series = orig.steel_grade_series
 AND t.group_manuf_line_name = orig.group_manuf_line_name
 AND t.manuf_line_name = orig.manuf_line_name;
