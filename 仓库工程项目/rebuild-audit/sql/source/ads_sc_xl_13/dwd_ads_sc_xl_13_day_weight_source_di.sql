{{ config(tags=["ads_xl13", "reconciliation"]) }}

select
  biz_date,
  tenant_id,
  plate_type,
  defined_manuf_line_name as group_manuf_line_name,
  defined_manuf_line_name as manuf_line_name,
  attr1,
  sum(coalesce(weight, 0)) / 1000.0 as source_day_weight_tons,
  sum(coalesce(quantity, 0)) as source_day_quantity,
  count(*) as source_row_cnt
from {{ ref("stg_dw__dwd_mes_mm_task_group_output_xl13") }}
where biz_date is not null
  and plate_type is not null
  and defined_manuf_line_name is not null
  and batch_code is not null
  and batch_code <> ''
  and coalesce(is_ignore, 0) = 0
  and (
    tenant_id in (80, 92)
    or (tenant_id not in (80, 92) and coalesce(send_happened, 0) = 1)
  )
group by 1, 2, 3, 4, 5, 6
