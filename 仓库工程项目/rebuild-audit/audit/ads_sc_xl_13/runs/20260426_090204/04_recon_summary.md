# Reconciliation Summary

## Target

- acceptance anchor:
  - `ads_sc_xl_13_defined_manuf_line_name_combined_001`
  - `ads_sc_xl_13_defined_manuf_line_name_combined_002`
- first metric:
  - `_002.day_weight`
  - `_001.weight` as daily equivalent

## Verified result

- local `combined -> combined_002` projection already reproduced with `0 diff`
- therefore `combined_002` shell is not the core issue

## Current day_weight breakdown

- `matched`: `10047`
- `mismatched`: `1411`
- `baseline_only`: `4627`
- `source_only`: `15`

### baseline_only split

- zero-weight rows: `4273`
  - mostly date-skeleton rows from `dim_date_info`
- positive-weight rows: `453`
  - mainly `总计` and `合计` synthetic rows

### mismatch emphasis

- biggest current mismatch sits upstream of `combined_002`
- focus area:
  - `process1`
  - `defined`
  - `defined_manuf_line_name`
  - `combined`
  - support overlays and synthetic rows

## Current interpretation

Do not solve this by editing `combined_002` directly.

The required path is:

1. rebuild support chains
2. rebuild `combined`
3. rebuild `_001 / _002`
4. then run field-level diff
