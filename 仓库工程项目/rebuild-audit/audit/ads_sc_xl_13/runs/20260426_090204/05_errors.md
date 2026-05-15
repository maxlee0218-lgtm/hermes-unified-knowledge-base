# Errors / Blockers

## Current blockers

1. tenant transform chain is still not explicitly exposed
   - `ods_mes_ums_tenant / ods_fair_ums_tenant`
   - to `ods_mes_mdm_tenant / dim_ums_tenant`

2. `with_attr_value` is a high-impact support object with no single simple source chain

3. `with_result_confirm` is mandatory for downtime / remark overlays and still needs structured local replay logic

## Resolved during this run

- `dwd_silicon_steel_surface_info` production chain is no longer a blocker
- stable runtime is confirmed healthy
- `_001 -> _002` direct sync has been disproved and should not be treated as a missing DataX bug
