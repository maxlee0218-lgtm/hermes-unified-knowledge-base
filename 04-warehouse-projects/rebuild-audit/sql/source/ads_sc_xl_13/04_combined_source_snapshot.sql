-- ADS_SC_XL_13 legacy source snapshot
-- Core task: 18333852605959 ADS_SC_XL_13_defined_manuf_line_name_combined
-- Supporting tasks:
-- 18333852605960 / 61 / 63 / 64 / 65 / 66 / 67 / 68 / 69 / 70 / 71 / 72

SELECT
  d.tenant_id,
  d.plate_type,
  d.group_manuf_line_name,
  d.manuf_line_name,
  d.attr1,
  d.data_date,
  d.weight AS day_weight,
  d.quantity AS day_quantity,
  DATE_FORMAT(d.data_date, '%Y-%m') AS month,
  YEAR(d.data_date) AS year,
  d.rk,
  d.remark
FROM ads_sc_xl_13_defined_manuf_line_name d
JOIN (
  SELECT tenant_id, attribute4
  FROM with_attr_value
  WHERE scene IN (
    'BI-SC-KC-013-DEFINED-PLATE-JJG',
    'BI-SC-KC-013-DEFINED-PLATE-LZ',
    'BI-SC-KC-013-DEFINED-PLATE-GG'
  )
) b
  ON d.tenant_id = b.tenant_id
 AND d.manuf_line_name = b.attribute4
WHERE d.data_date >= CURRENT_DATE - INTERVAL 35 DAY;

-- Additional updates on this table:
-- 1) with_result_confirm report_id = 237 / 239 / 543
-- 2) avg_thickness tables
-- 3) ads_sc_xl_01 driven finished output / finished product tables
-- 4) month rollup process1 table
-- 5) attr1='合计' rows
-- 6) manuf_line_name='总计' rows
