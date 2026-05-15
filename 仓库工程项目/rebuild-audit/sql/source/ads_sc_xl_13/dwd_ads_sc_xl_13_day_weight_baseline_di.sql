{{ config(tags=["ads_xl13", "reconciliation"]) }}

select
  biz_date,
  tenant_id,
  plate_type,
  group_manuf_line_name,
  manuf_line_name,
  attr1,
  day_weight as baseline_day_weight_tons,
  day_quantity as baseline_day_quantity
from {{ ref("stg_dw__ads_sc_xl_13_defined_manuf_line_name_combined_002") }}
