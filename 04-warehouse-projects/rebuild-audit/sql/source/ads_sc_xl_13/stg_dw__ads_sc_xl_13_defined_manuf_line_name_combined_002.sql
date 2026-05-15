{{ config(tags=["staging_dw", "ads_xl13"]) }}

select
  tenant_id,
  plate_type,
  group_manuf_line_name,
  manuf_line_name,
  coalesce(attr1, '') as attr1,
  cast(data_date as date) as biz_date,
  cast(day_weight as double) as day_weight,
  cast(day_quantity as double) as day_quantity,
  cast(month_weight as double) as month_weight,
  cast(month_quantity as double) as month_quantity,
  month,
  year,
  rk,
  rk1,
  remark,
  day_output_plan
from {{ source("dw", "ads_sc_xl_13_defined_manuf_line_name_combined_002") }}
