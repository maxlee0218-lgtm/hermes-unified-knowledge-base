# dim_date_info Rebuild Plan

## 1. 在 ADS_SC_XL_13 哪一层引入

`dim_date_info` 在稳定链的 `ads_sc_xl_13_defined` 层引入。

位置：

- `ads_sc_xl_13_process1`
  - 先产出有业务数据的日期行
- `ads_sc_xl_13_defined`
  - 再用 `dim_date_info` 作为日期骨架补齐连续日期

所以它不是最终展示层才参与，而是在主链中间层就开始决定后续 `combined` 的日级完整性。

## 2. 它参与生成哪些 `baseline_only` 零行

当前已确认：

- `baseline_only` 零重量行：`4273`
- 这些行的主来源不是原始业务事实，而是 `dim_date_info` 补零逻辑

逻辑本质：

1. 取 `ads_sc_xl_13_process1` 最近较长窗口内的历史组合全集
2. 取 `dim_date_info` 当前窗口的连续日期
3. 做 `date x business_combo`
4. left join 回 `process1`
5. `weight / quantity / lower_weight / lower_quantity` 补 `0`

## 3. 日期范围如何确定

当前稳定链使用两类日期窗口：

- 核心补零窗口：
  - `CURRENT_DATE - INTERVAL 35 DAY` 到 `CURRENT_DATE`
- 业务组合全集窗口：
  - `CURRENT_DATE - INTERVAL 350 DAY`

所以本地复刻时建议固定两层窗口：

- `date_spine_window = 35 day`
- `combo_seed_window = 350 day`

## 4. 日期 x 业务组合集合如何生成

当前稳定思路：

1. 从 `ads_sc_xl_13_process1` 取 distinct 组合：
   - `tenant_id`
   - `plate_type`
   - `surface`
   - `attr1`
   - `steel_grade_series`
   - `group_manuf_line_name`
   - `manuf_line_name`
2. 从 `dim_date_info` 取连续日期：
   - `date_id`
3. `CROSS JOIN`
4. 用这些字段回连 `ads_sc_xl_13_process1`

这意味着：

- `dim_date_info` 自身不携带业务维度
- 它只负责提供连续日期
- 业务维度来自 `process1` 的历史组合全集

## 5. left join 后哪些指标补 0

当前已明确要补 `0` 的指标至少包括：

- `weight`
- `quantity`
- `lower_weight`
- `lower_quantity`
- `manufacturing_finished_output_length`
- `lower_manufacturing_finished_output_length`

后续到 `defined_manuf_line_name` / `combined` 层后，再继续扩展到：

- `day_weight`
- `day_quantity`
- 月累计类字段

## 6. 哪些字段需要保留原业务维度

补零时必须保留：

- `tenant_id`
- `plate_type`
- `surface`
- `attr1`
- `steel_grade_series`
- `group_manuf_line_name`
- `manuf_line_name`
- `data_date`

不能只补日期不补维度，否则后续：

- `defined_manuf_line_name`
- `combined`
- `_001 / _002`

都会出现丢行或聚合错位。

## 7. 本地复刻 SQL 蓝图

建议本地复刻顺序：

1. `dim_date_info_local`
2. `ads_sc_xl_13_process1_local`
3. `ads_sc_xl_13_defined_seed_combo_local`
4. `ads_sc_xl_13_defined_date_spine_local`
5. `ads_sc_xl_13_defined_local`

蓝图：

```sql
with date_spine as (
  select date_id
  from dim_date_info
  where date_id between current_date - interval 35 day and current_date
),
combo_seed as (
  select distinct
    tenant_id,
    plate_type,
    surface,
    attr1,
    steel_grade_series,
    group_manuf_line_name,
    manuf_line_name
  from ads_sc_xl_13_process1
  where data_date >= current_date - interval 350 day
),
filled as (
  select
    d.date_id as data_date,
    c.*
  from date_spine d
  cross join combo_seed c
)
select
  f.data_date,
  f.tenant_id,
  f.plate_type,
  f.surface,
  f.attr1,
  f.steel_grade_series,
  f.group_manuf_line_name,
  f.manuf_line_name,
  coalesce(p.weight, 0) as weight,
  coalesce(p.quantity, 0) as quantity
from filled f
left join ads_sc_xl_13_process1 p
  on f.data_date = p.data_date
 and f.tenant_id = p.tenant_id
 and f.plate_type = p.plate_type
 and f.surface = p.surface
 and f.attr1 <=> p.attr1
 and f.steel_grade_series = p.steel_grade_series
 and f.group_manuf_line_name = p.group_manuf_line_name
 and f.manuf_line_name = p.manuf_line_name;
```

## 8. 验收口径

`dim_date_info` 本地复刻通过，至少要满足：

1. 日期连续性正确
   - 无缺天
2. `baseline_only` 零行数量能被解释
3. `defined_local` 的补零行和稳定链同粒度可对上
4. 对 `day_weight` 的影响表现为：
   - 缺数据的行是 `0`
   - 不是直接缺行

## 当前结论

`dim_date_info` 当前已经足够明确，状态应从“阻塞未知”调整为：

- **可执行待验证**

它不是当前最难的缺口，后续可以先复刻。 
