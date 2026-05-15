-- Support chain snapshot
-- Task: 18340742659074 ads_sc_xl_01(入库量)

SELECT
  a.tenant_id,
  a.bill_type,
  a.wh_code,
  a.dept_code,
  a.machine_code,
  a.other_machine_code,
  a.rd_style,
  a.rd_style_name,
  a.sku_code,
  a.steel_grade,
  a.surface,
  a.grade,
  a.weight,
  a.quantity,
  a.data_date,
  a.bi_sc_xl_013_process_001_attr1
FROM dwd_mes_wms_wh_enter_item a
WHERE a.data_date >= CURRENT_DATE - INTERVAL 35 DAY;

-- This table feeds:
-- - 生产入库量
-- - 成品入库量
