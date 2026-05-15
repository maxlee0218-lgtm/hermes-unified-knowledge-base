{{ config(tags=["ads_xl13", "reconciliation"]) }}

with source_data as (
  select * from {{ ref("dwd_ads_sc_xl_13_day_weight_source_di") }}
),
baseline_data as (
  select * from {{ ref("dwd_ads_sc_xl_13_day_weight_baseline_di") }}
)
select
  coalesce(s.biz_date, b.biz_date) as biz_date,
  coalesce(s.tenant_id, b.tenant_id) as tenant_id,
  coalesce(s.plate_type, b.plate_type) as plate_type,
  coalesce(s.group_manuf_line_name, b.group_manuf_line_name) as group_manuf_line_name,
  coalesce(s.manuf_line_name, b.manuf_line_name) as manuf_line_name,
  coalesce(s.attr1, b.attr1) as attr1,
  s.source_day_weight_tons,
  b.baseline_day_weight_tons,
  s.source_day_quantity,
  b.baseline_day_quantity,
  coalesce(s.source_day_weight_tons, 0) - coalesce(b.baseline_day_weight_tons, 0) as diff_day_weight_tons,
  abs(coalesce(s.source_day_weight_tons, 0) - coalesce(b.baseline_day_weight_tons, 0)) as abs_diff_day_weight_tons,
  case
    when s.biz_date is null then 'baseline_only'
    when b.biz_date is null then 'source_only'
    when abs(coalesce(s.source_day_weight_tons, 0) - coalesce(b.baseline_day_weight_tons, 0)) < 0.0001 then 'matched'
    else 'mismatched'
  end as reconcile_status
from source_data s
full outer join baseline_data b
  on s.biz_date = b.biz_date
 and s.tenant_id = b.tenant_id
 and s.plate_type = b.plate_type
 and s.manuf_line_name = b.manuf_line_name
 and s.attr1 = b.attr1
