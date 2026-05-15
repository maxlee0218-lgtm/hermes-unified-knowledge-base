{{ config(tags=["staging_dw", "ads_xl13"]) }}

select
  tenant_id,
  actual_id,
  plate_type,
  defined_manuf_line_name,
  coalesce(bi_sc_xl_013_process_001_attr1, '') as attr1,
  cast(bi_sc_xl_013_process_001_dataDate as date) as biz_date,
  cast(data_date as date) as raw_data_date,
  batch_code,
  is_ignore,
  send_happened,
  grade,
  is_retention,
  cast(weight as double) as weight,
  cast(quantity as double) as quantity,
  cast(roll_length as double) as roll_length
from {{ source("dw", "dwd_mes_mm_task_group_output_xl13") }}
