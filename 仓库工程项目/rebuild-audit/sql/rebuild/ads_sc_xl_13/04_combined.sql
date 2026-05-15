-- READ-ONLY rebuild blueprint for combined

WITH base_combined AS (
  SELECT
    d.tenant_id,
    d.plate_type,
    d.group_manuf_line_name,
    d.manuf_line_name,
    d.attr1,
    d.data_date,
    d.weight AS day_weight,
    d.quantity AS day_quantity
  FROM ads_sc_xl_13_defined_manuf_line_name d
),
date_enriched AS (
  SELECT *
  FROM base_combined
),
dictionary_enriched AS (
  SELECT *
  FROM date_enriched
),
manual_confirm_enriched AS (
  SELECT *
  FROM dictionary_enriched
)
SELECT *
FROM manual_confirm_enriched;
