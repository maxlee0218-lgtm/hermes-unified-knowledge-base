# ADS_SC_XL_13 Acceptance Criteria

## 当前验收目标

1. `ads_sc_xl_13_defined_manuf_line_name_combined_001`
2. `ads_sc_xl_13_defined_manuf_line_name_combined_002`

## 第一阶段验收

- 目标：`day_weight`
- 表：
  - `_001` 使用 `weight` 作为日级等价指标
  - `_002` 使用 `day_weight`
- 粒度：
  - `data_date`
  - `tenant_id`
  - `plate_type`
  - `manuf_line_name`
  - `attr1`

## 第二阶段验收

- 入库量字段
- 成品入库量字段
- 停机时间字段
- 备注字段

## 第三阶段验收

- `合计`
- `总计`
- 月累计字段
- `001 / 002` 的 row-level diff

## 判定标准

- 主链表结构对齐
- 支撑链来源明确
- 关键指标对账通过
- `_001 / _002` 投影结果对齐
- 缺口清单下降到可接受范围
