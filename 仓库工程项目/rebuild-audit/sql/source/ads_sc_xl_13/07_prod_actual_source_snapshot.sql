-- Support chain snapshot
-- Task: 18341376834049 生产实绩（dwd_task_prod_actual）

SELECT
  s.actual_id,
  s.task_inst_id,
  s.batch_code,
  s.sku_code,
  s.weight,
  s.net_weight,
  s.quantity,
  s.yield_rate,
  s.loss_amount,
  s.r_modified_time
FROM ods_mes_mm_task_prod_actual s
WHERE s.r_modified_time > @wm_start
  AND s.r_modified_time <= @wm_end;

-- Actual production task also joins:
-- - ods_mes_mm_qc_defect_data
-- - ods_mes_mm_qc_actual_defect_rela
-- - ods_mes_wms_batch_info
-- - with_attr_value
