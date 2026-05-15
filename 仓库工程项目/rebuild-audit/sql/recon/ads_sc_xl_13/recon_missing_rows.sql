-- Read-only missing-row analysis

WITH baseline AS (
  SELECT
    data_date,
    tenant_id,
    plate_type,
    manuf_line_name,
    COALESCE(attr1, '') AS attr1,
    day_weight
  FROM ads_sc_xl_13_defined_manuf_line_name_combined_002
),
check_rows AS (
  SELECT
    data_date,
    tenant_id,
    plate_type,
    manuf_line_name,
    COALESCE(attr1, '') AS attr1
  FROM ads_sc_xl_13_defined_manuf_line_name_combined
)
SELECT
  b.*
FROM baseline b
LEFT JOIN check_rows c
  ON b.data_date = c.data_date
 AND b.tenant_id = c.tenant_id
 AND b.plate_type = c.plate_type
 AND b.manuf_line_name = c.manuf_line_name
 AND b.attr1 = c.attr1
WHERE c.data_date IS NULL;
