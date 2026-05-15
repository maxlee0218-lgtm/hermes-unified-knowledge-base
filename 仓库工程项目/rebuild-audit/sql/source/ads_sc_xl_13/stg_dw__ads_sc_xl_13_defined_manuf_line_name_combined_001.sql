{{ config(tags=["staging_dw", "ads_xl13"]) }}

select
  tenant_id,
  plate_type,
  group_manuf_line_name,
  manuf_line_name,
  coalesce(attr1, '') as attr1,
  period,
  cast(data_date as date) as biz_date,
  cast(weight as double) as weight,
  cast(quantity as double) as quantity,
  rk,
  rk1,
  rk2,
  remark
from {{ source("dw", "ads_sc_xl_13_defined_manuf_line_name_combined_001") }}
