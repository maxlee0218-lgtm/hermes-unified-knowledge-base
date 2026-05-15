-- Shared support dimension snapshot
-- Task: 18266359629952 硅钢表面属性(dwd_silicon_steel_surface_info)
-- Workflow: 18266359629824 维度表

SELECT DISTINCT
  attr_value AS surface,
  REGEXP_SUBSTR(attr_value, '[0-9]+', 1, 1) AS surface_thickness,
  CASE
    WHEN LOCATE('QW', attr_value) > 0 THEN 'QW'
    ELSE REGEXP_SUBSTR(attr_value, '[0-9]+', 1, 2)
  END AS surface_number,
  TRIM(REGEXP_SUBSTR(attr_value, '[^0-9]+', REGEXP_INSTR(attr_value, '[0-9]') + 1, 1)) AS surface_middle_part
FROM ods_mes_sys_attr_value
WHERE attr_id = '1015'
  AND STATUS = 1;

-- Subsequent updates derive:
-- - silicon_steel_product_category_code
-- - silicon_steel_product_category_name
-- - attr1
