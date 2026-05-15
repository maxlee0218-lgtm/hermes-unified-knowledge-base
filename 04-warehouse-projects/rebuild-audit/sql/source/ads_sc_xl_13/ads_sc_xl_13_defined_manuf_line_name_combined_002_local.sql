{{ config(tags=["ads_xl13", "delivery"]) }}

select
  tenant_id,
  plate_type,
  group_manuf_line_name,
  manuf_line_name,
  attr1,
  biz_date as data_date,
  day_weight,
  day_quantity,
  month_weight,
  month_quantity,
  month,
  year,
  rk,
  rk1,
  remark,
  day_output_plan
from {{ ref("stg_dw__ads_sc_xl_13_defined_manuf_line_name_combined") }}
