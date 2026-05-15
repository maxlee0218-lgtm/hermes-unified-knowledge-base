{{ config(tags=["ads_xl13", "reconciliation"]) }}

with detail as (
  select * from {{ ref("dwd_ads_sc_xl_13_day_weight_reconciliation_di") }}
)

select
  biz_date,
  tenant_id,
  count(*) as row_cnt,
  sum(case when reconcile_status = 'matched' then 1 else 0 end) as matched_row_cnt,
  sum(case when reconcile_status = 'mismatched' then 1 else 0 end) as mismatched_row_cnt,
  sum(case when reconcile_status = 'source_only' then 1 else 0 end) as source_only_row_cnt,
  sum(case when reconcile_status = 'baseline_only' then 1 else 0 end) as baseline_only_row_cnt,
  sum(coalesce(source_day_weight_tons, 0)) as total_source_day_weight_tons,
  sum(coalesce(baseline_day_weight_tons, 0)) as total_baseline_day_weight_tons,
  sum(diff_day_weight_tons) as total_diff_day_weight_tons,
  sum(abs_diff_day_weight_tons) as total_abs_diff_day_weight_tons
from detail
group by 1, 2
