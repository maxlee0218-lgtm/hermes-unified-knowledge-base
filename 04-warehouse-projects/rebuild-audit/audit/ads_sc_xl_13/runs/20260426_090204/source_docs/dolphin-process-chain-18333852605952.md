# Dolphin Process Chain 18333852605952

- Project: `生产-通用`
- Process name: `产量日报表（ADS_SC_XL_13）`
- Release state: `1`
- Updated at: `2026-04-24 17:29:08`

## Relations

- START -> `ADS_SC_XL_13_PROCESS_001`
- START -> `BI_SC_XL_013_DEFINED_DETAIL`
- `ADS_SC_XL_13_PROCESS_001` -> `ADS_SC_XL_13_DEFINED`
- `ADS_SC_XL_13_DEFINED` -> `ADS_SC_XL_13_DEFINED_MANUF_LINE_NAME`
- `ADS_SC_XL_13_DEFINED_MANUF_LINE_NAME` -> `ADS_SC_XL_13_defined_manuf_line_name_combined`
- `ADS_SC_XL_13_defined_manuf_line_name_combined` -> `生产入库量`
- `更新冷轧停机时间` -> `更新精加工停机时间`
- `更新精加工停机时间` -> `更新硅钢停机时间`
- `平均厚度更新` -> `月平均厚度更新`
- `生产入库量` -> `更新月生产入库量`
- `成品入库量` -> `月成品入库量`
- `更新月生产入库量` -> `平均厚度更新`
- `更新硅钢停机时间` -> `增加硅钢板块总计字段`
- `月成品入库量` -> `增加硅钢合计字段`
- `月平均厚度更新` -> `成品入库量`
- `增加硅钢合计字段` -> `更新月数据`
- `增加硅钢板块总计字段` -> `BI_SC_XL_013_DEFINED_MANUF_LINE_NAME_COMBINED_001`
- `增加硅钢板块总计字段` -> `BI_SC_XL_013_DEFINED_MANUF_LINE_NAME_COMBINED_002`
- `更新月数据` -> `更新冷轧停机时间`

## Tasks

### `ADS_SC_XL_13_PROCESS_001`

- Code: `18333852605954`
- Type: `SQL`
- Upstream nodes: `START`
- Downstream nodes: `ADS_SC_XL_13_DEFINED`
- Write tables: `ads_sc_xl_13_process1`
- Read tables: `ads_sc_xl_13_process1`, `dwd_mes_mm_task_group_output`, `dwd_mes_wms_current_stock`

```sql
DELETE
FROM
    ads_sc_xl_13_process1  where data_date >= CURRENT_DATE - INTERVAL 35 day
;
INSERT INTO ads_sc_xl_13_process1    SELECT
                                         a.tenant_id,
                                         a.plate_type,
                                         a.surface,
                                         a.bi_sc_xl_013_process_001_attr1 attr1,
                                         a.steel_grade_series,
                                         a.defined_manuf_line_name group_manuf_line_name,
                                         a.defined_manuf_line_name manuf_line_name,
                                         a.bi_sc_xl_013_process_001_dataDate  data_date,
                                         sum( a.weight )/ 1000 weight,
                                         sum( a.quantity ) quantity,
                                         sum( CASE WHEN a.grade in ('A','R') or a.batch_code like '%-RD' or (a.tenant_id= '79' and a.defined_manuf_line_name in ('飞剪一组','平板一组')) or is_retention = 1 THEN 0   ELSE a.weight END )/ 1000 lower_weight,
                                         sum(CASE WHEN a.grade in ('A','R') or a.batch_code like '%-RD' or (a.tenant_id= '79' and a.defined_manuf_line_name in ('飞剪一组','平板一组') )or is_retention = 1 THEN 0   ELSE a.quantity END )/ 1000 lower_quantity,
                                         sum( a.roll_length ) manufacturing_finished_output_length,
                                         sum( CASE WHEN a.grade in ('A','R') or a.batch_code like '%-RD' or (a.tenant_id= '79' and a.defined_manuf_line_name in ('飞剪一组','平板一组')) or is_retention = 1 THEN 0   ELSE a.roll_length END ) lower_manufacturing_finished_output_length,
                                         DATE_FORMAT( a.data_date, '%Y-%m' ) MONTH,
                                         YEAR ( a.data_date ) YEAR
FROM
    dwd_mes_mm_task_group_output a
WHERE a.plate_type is not null
  and  a.defined_manuf_line_name  is not null
  and a.batch_code is not null
  and a.batch_code <> '' and a.is_ignore=0
  AND tenant_id IN('80','92')
  AND a.bi_sc_xl_013_process_001_dataDate >= CURRENT_DATE - INTERVAL 35 day


GROUP BY
    a.tenant_id,
    a.defined_manuf_line_name,
    a.surface,a.bi_sc_xl_013_process_001_attr1  ,
    a.steel_grade_series,
    bi_sc_xl_013_process_001_dataDate ,
    a.plate_type
;

INSERT INTO ads_sc_xl_13_process1    SELECT
                                         a.tenant_id,
                                         a.plate_type,
                                         a.surface,a.bi_sc_xl_013_process_001_attr1 ,
                                         a.steel_grade_series,
                                         a.defined_manuf_line_name group_manuf_line_name,
                                         a.defined_manuf_line_name manuf_line_name,
                                         bi_sc_xl_013_process_001_dataDate  data_date,
                                 
```

### `ADS_SC_XL_13_DEFINED`

- Code: `18333852605955`
- Type: `SQL`
- Upstream nodes: `ADS_SC_XL_13_PROCESS_001`
- Downstream nodes: `ADS_SC_XL_13_DEFINED_MANUF_LINE_NAME`
- Write tables: `ads_sc_xl_13_defined`
- Read tables: `ads_sc_xl_13_defined`, `dim_date_info`, `ads_sc_xl_13_process1`

```sql

DELETE
FROM
    ads_sc_xl_13_defined
WHERE
    data_date >= CURDATE() - INTERVAL 35 day;
INSERT INTO ads_sc_xl_13_defined (
    data_date,
    tenant_id,
    plate_type,
    surface,
    attr1,
    steel_grade_series,
    group_manuf_line_name,
    manuf_line_name,
    weight,
    quantity,
    lower_weight,
    lower_quantity,
    manufacturing_finished_output_length,
    lower_manufacturing_finished_output_length,
    MONTH,
    YEAR) SELECT
              dr.date_id AS data_date,
              t.tenant_id,
              t.plate_type,
              t.surface,
              t.attr1,
              t.steel_grade_series,
              t.group_manuf_line_name,
              t.manuf_line_name,
              COALESCE(orig.weight, 0) AS weight,
              COALESCE(orig.quantity, 0) AS quantity,
              COALESCE(orig.lower_weight, 0) AS lower_weight,
              COALESCE(orig.lower_quantity, 0) AS lower_quantity,
              COALESCE(orig.manufacturing_finished_output_length, 0) AS manufacturing_finished_output_length,
              COALESCE(orig.lower_manufacturing_finished_output_length, 0) AS lower_manufacturing_finished_output_length,
              COALESCE(orig.MONTH, '未知') AS MONTH,
              COALESCE(orig.YEAR, '未知') AS YEAR
FROM
    (SELECT date_id FROM dim_date_info WHERE date_id <= CURDATE() AND date_id >= CURDATE() - INTERVAL 35 DAY) AS dr
        JOIN (SELECT DISTINCT tenant_id, plate_type, surface, attr1, steel_grade_series, group_manuf_line_name, manuf_line_name FROM ads_sc_xl_13_process1 where data_date >= CURDATE() - INTERVAL 350 DAY) AS t
        LEFT JOIN ads_sc_xl_13_process1 orig ON dr.date_id = orig.data_date
        AND t.tenant_id = orig.tenant_id
        AND t.plate_type = orig.plate_type
        AND t.surface = orig.surface
        AND
                                                CASE

                                                    WHEN t.attr1 IS NULL THEN
                                                        1 = 1 ELSE t.attr1 = orig.attr1
                                                    END
        AND t.steel_grade_series = orig.steel_grade_series
        AND t.group_manuf_line_name = orig.group_manuf_line_name
        AND t.manuf_line_name = orig.manuf_line_name
;
delete from ads_sc_xl_13_defined  where tenant_id =92 and manuf_line_name ='TCM' and attr1 is null ;
delete from ads_sc_xl_13_defined  where tenant_id =92 and manuf_line_name in ('1#SACL','2#SACL') and attr1 is null ;
```

### `ADS_SC_XL_13_DEFINED_MANUF_LINE_NAME`

- Code: `18333852605956`
- Type: `SQL`
- Upstream nodes: `ADS_SC_XL_13_DEFINED`
- Downstream nodes: `ADS_SC_XL_13_defined_manuf_line_name_combined`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name`
- Read tables: `ads_sc_xl_13_defined_manuf_line_name`, `ads_sc_xl_13_defined`

```sql
DELETE
FROM
    ads_sc_xl_13_defined_manuf_line_name where  data_date >= CURRENT_DATE - INTERVAL 30 day;
INSERT INTO ads_sc_xl_13_defined_manuf_line_name (
    tenant_id,
    plate_type,
    group_manuf_line_name,
    manuf_line_name,
    attr1,
    data_date,
    weight,
    quantity,
    average_thickness,
    lower_weight,
    lower_quantity,
    breakdown_frequency,
    planned_downtime,
    unplanned_downtime,
    manufacturing_finished_output_tons,
    manufacturing_finished_output_quantity,
    manufacturing_finished_output_length,
    lower_manufacturing_finished_output_length,
    manufacturing_finished_product,
    manufacturing_finished_product_quantity,
    MONTH,
    YEAR)  SELECT
               a.tenant_id,
               a.plate_type,
               a.group_manuf_line_name,
               a.manuf_line_name,
               a.attr1,
               a.data_date,
               SUM(a.weight) weight,
               SUM(a.quantity) quantity,
               '0.0' average_thickness,
               SUM(a.lower_weight) lower_weight,
               SUM(a.lower_quantity) lower_quantity,
               '0.0' breakdown_frequency,
               '0.0' planned_downtime,
               '0.0' unplanned_downtime,
               '0.0' manufacturing_finished_output_tons,
               '0.0' manufacturing_finished_output_quantity,
               SUM(a.manufacturing_finished_output_length) manufacturing_finished_output_length,
               SUM(a.lower_manufacturing_finished_output_length) lower_manufacturing_finished_output_length,
               '0.0' manufacturing_finished_product,
               '0.0' manufacturing_finished_product_quantity,
               substr(a.data_date, 1, 7) MONTH,
               YEAR(data_date) YEAR
FROM
    ads_sc_xl_13_defined a
WHERE
    a.manuf_line_name <> ''
  and a.data_date >= CURRENT_DATE - INTERVAL 30 day
GROUP BY
    a.tenant_id,
    a.plate_type,
    a.manuf_line_name,
    a.attr1,
    a.data_date;
```

### `BI_SC_XL_013_DEFINED_DETAIL`

- Code: `18333852605957`
- Type: `SQL`
- Upstream nodes: `START`
- Downstream nodes: `END`
- Write tables: `ads_sc_xl_13_defined_detail`
- Read tables: `ads_sc_xl_13_defined_detail`, `dwd_mes_mm_task_group_output`, `ods_mes_mm_task_prod_actual`, `ods_mes_wms_batch_info`, `with_attr_value`

```sql
DELETE from   ads_sc_xl_13_defined_detail WHERE data_date >= DATE_SUB(CURDATE(), INTERVAL 35 DAY); ;
INSERT into   ads_sc_xl_13_defined_detail
SELECT
    a.tenant_id,
    av1.attribute5 plate_type,
    av.attribute1 manuf_line_name,
    a.machine_code,
    a.data_date,
    a.batch_code,
    a.grade,
    a.sku_name,
    a.spec,
    sum(a.quantity) quantity,
    sum(a.roll_length) roll_length ,
    sum( a.weight )/ 1000 weight
FROM
    dwd_mes_mm_task_group_output a
        JOIN ods_mes_mm_task_prod_actual c ON a.actual_id = c.actual_id
        AND c.`status` = 1
        LEFT JOIN ods_mes_wms_batch_info b ON a.batch_code = b.batch_code
        AND a.tenant_id = b.tenant_id
        AND b.`status` = 1
        AND c.steel_grade = b.steel_grade
        AND c.spec = b.spec
        AND c.surface = b.surface
        AND c.grade = b.grade
        AND c.sku_code = b.sku_code

        JOIN with_attr_value av ON a.tenant_id = av.tenant_id
        AND a.machine_code = av.attribute2
        AND av.scene = 'BI-SC-KC-013-DEFINED-TYPE-LZ'
        JOIN with_attr_value av1 ON av.tenant_id = av1.tenant_id
        AND av.attribute1 = av1.attribute4
        AND av1.scene = 'BI-SC-KC-013-DEFINED-PLATE-LZ'
        AND av1.attribute5 IS NOT NULL
WHERE data_date >= DATE_SUB(CURDATE(), INTERVAL 35 DAY)  and a.batch_code is not null  and a.batch_code <> '' and a.is_ignore =  0 and a.send_happened= 1
GROUP BY
    av1.attribute5 ,a.sku_name,a.tenant_id,a.machine_code,a.spec,
    av.attribute1 ,
    a.data_date,
    a.batch_code,
    a.grade;

INSERT into   ads_sc_xl_13_defined_detail
SELECT
    a.tenant_id,
    av1.attribute5 plate_type,
    av.attribute1 manuf_line_name,
    a.machine_code,
    a.data_date,
    a.batch_code,
    a.grade,
    a.sku_name,
    a.spec,
    sum(a.quantity) quantity,
    sum(a.roll_length) roll_length ,
    sum( a.weight )/ 1000 weight
FROM
    dwd_mes_mm_task_group_output a
        JOIN ods_mes_mm_task_prod_actual c ON a.actual_id = c.actual_id
        AND c.`status` = 1
        LEFT JOIN ods_mes_wms_batch_info b ON a.batch_code = b.batch_code
        AND a.tenant_id = b.tenant_id
        AND b.`status` = 1
        AND c.steel_grade = b.steel_grade
        AND c.spec = b.spec
        AND c.surface = b.surface
        AND c.grade = b.grade
        AND c.sku_code = b.sku_code

        JOIN with_attr_value av ON a.tenant_id = av.tenant_id
        AND a.machine_code = av.attribute2
        AND av.scene = 'BI-SC-KC-013-DEFINED-TYPE-JJG'
        JOIN with_attr_value av1 ON av.tenant_id = av1.tenant_id
        AND av.attribute1 = av1.attribute4
        AND av1.scene = 'BI-SC-KC-013-DEFINED-PLATE-JJG'
        AND av1.attribute5 IS NOT NULL
WHERE data_date >= DATE_SUB(CURDATE(), INTERVAL 35 DAY)  and a.batch_code is not null  and a.batch_code <> '' and a.is_ignore =  0 and a.send_happened= 1
GROUP BY
    av1.attribute5 ,a.sku_name,a.tenant_id,a.machine_code,a.spec,
    av.attri
```

### `ADS_SC_XL_13_defined_manuf_line_name_combined`

- Code: `18333852605959`
- Type: `SQL`
- Upstream nodes: `ADS_SC_XL_13_DEFINED_MANUF_LINE_NAME`
- Downstream nodes: `生产入库量`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_combined`
- Read tables: `ads_sc_xl_13_defined_manuf_line_name_combined`, `ads_sc_xl_13_defined_manuf_line_name`, `with_attr_value`

```sql
DELETE
FROM
    ads_sc_xl_13_defined_manuf_line_name_combined
WHERE
    data_date >= CURRENT_DATE - INTERVAL 35 DAY;
INSERT INTO ads_sc_xl_13_defined_manuf_line_name_combined (
    `tenant_id`,
    `plate_type`,
    `group_manuf_line_name`,
    `manuf_line_name`,
    attr1,
    `data_date`,
    `day_weight`,
    `day_quantity`,
    `day_average_thickness`,
    `day_lower_weight`,
    `day_lower_quantity`,
    `day_breakdown_frequency`,
    `day_planned_downtime`,
    `day_unplanned_downtime`,
    `day_manufacturing_finished_output_tons`,
    `day_manufacturing_finished_output_quantity`,
    `day_manufacturing_finished_output_length`,
    `day_lower_manufacturing_finished_output_length`,
    `day_manufacturing_finished_product`,
    `day_manufacturing_finished_product_quantity`,
    `month`,
    `year`,
    `rk`,
    `remark`) SELECT
                  d.`tenant_id`,
                  d.`plate_type`,
                  d.`group_manuf_line_name`,
                  d.`manuf_line_name`,
                  d.attr1,
                  d.`data_date`,
                  d.`weight` AS day_weight,
                  d.`quantity` AS day_quantity,
                  d.`average_thickness` AS day_average_thickness,
                  d.`lower_weight` AS day_lower_weight,
                  d.`lower_quantity` AS day_lower_quantity,
                  d.`breakdown_frequency` AS day_breakdown_frequency,
                  d.`planned_downtime` AS day_planned_downtime,
                  d.`unplanned_downtime` AS day_unplanned_downtime,
                  d.`manufacturing_finished_output_tons` AS day_manufacturing_finished_output_tons,
                  d.`manufacturing_finished_output_quantity` AS day_manufacturing_finished_output_quantity,
                  d.`manufacturing_finished_output_length` AS day_manufacturing_finished_output_length,
                  d.`lower_manufacturing_finished_output_length` AS day_lower_manufacturing_finished_output_length,
                  d.`manufacturing_finished_product` AS day_manufacturing_finished_product,
                  d.`manufacturing_finished_product_quantity` AS day_manufacturing_finished_product_quantity,
                  DATE_FORMAT(d.`data_date`, '%Y-%m') AS MONTH,
                  YEAR(d.`data_date`) AS YEAR,
                  d.`rk`,
                  d.`remark`
FROM
    ads_sc_xl_13_defined_manuf_line_name d
        join (SELECT tenant_id,attribute4 FROM with_attr_value WHERE scene in('BI-SC-KC-013-DEFINED-PLATE-JJG','BI-SC-KC-013-DEFINED-PLATE-LZ','BI-SC-KC-013-DEFINED-PLATE-GG')  )b
             on d.tenant_id =b.tenant_id and d.manuf_line_name=b.attribute4
WHERE
    d.data_date >= CURRENT_DATE - INTERVAL 35 DAY  ;


UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN (SELECT tenant_id, attribute5 plate_type, attribute4 manuf_line_name, list_order FROM with_attr_value WHERE scene IN ('BI-SC-KC-013-DEFINED-PLATE-LZ', 'BI-SC-KC-013-D
```

### `更新冷轧停机时间`

- Code: `18333852605960`
- Type: `SQL`
- Upstream nodes: `更新月数据`
- Downstream nodes: `更新精加工停机时间`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_combined`, `with_result_confirm`
- Read tables: `with_result_confirm`

```sql
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN (
        SELECT
            tenant_id,
            attribute3 plate_type,
            attribute1 manuf_line_name,
            attribute2 data_date,
            COALESCE ( NULLIF( attribute9, '' ), 0 ) breakdown_frequency,
            COALESCE ( NULLIF( attribute10, '' ), 0 ) planned_downtime,
            COALESCE ( NULLIF( attribute11, '' ), 0 ) unplanned_downtime,
            IFNULL( attribute13, '' ) remark
        FROM
            with_result_confirm
        WHERE
            STATUS = '1'
          AND report_id = '237'
          AND result_cat = 'REPORT_BUSINESS_DATA'
    ) AS source ON target.tenant_id = source.tenant_id
        AND target.data_date = source.data_date
        AND target.manuf_line_name = source.manuf_line_name
SET target.day_breakdown_frequency = source.breakdown_frequency,
    target.day_planned_downtime = source.planned_downtime,
    target.day_unplanned_downtime = source.unplanned_downtime,
    target.remark = source.remark;
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN (
        SELECT
            tenant_id,
            attribute1 AS manuf_line_name,
            attribute2 AS data_date,
            SUM( attribute9 ) OVER ( PARTITION BY tenant_id, attribute1, substr( attribute2, 1, 7 ) ORDER BY attribute2 ) AS breakdown_frequency,
            SUM( attribute10 ) OVER ( PARTITION BY tenant_id, attribute1, substr( attribute2, 1, 7 ) ORDER BY attribute2 ) AS planned_downtime,
            SUM( attribute11 ) OVER ( PARTITION BY tenant_id, attribute1, substr( attribute2, 1, 7 ) ORDER BY attribute2 ) AS unplanned_downtime
        FROM
            with_result_confirm
        WHERE
            STATUS = '1'
          AND report_id = '237'
          AND result_cat = 'REPORT_BUSINESS_DATA'
    ) AS source ON target.tenant_id = source.tenant_id
        AND target.data_date = source.data_date
        AND target.manuf_line_name = source.manuf_line_name
SET target.month_breakdown_frequency = source.breakdown_frequency,
    target.month_planned_downtime = source.planned_downtime,
    target.month_unplanned_downtime = source.unplanned_downtime;
UPDATE with_result_confirm AS target
    INNER JOIN (
        SELECT
            tenant_id,
            attribute1 AS manuf_line_name,
            period AS data_date,
            SUM( attribute10 ) OVER ( PARTITION BY tenant_id, attribute1, substr( attribute2, 1, 7 ) ORDER BY period ) AS breakdown_frequency,
            SUM( attribute11 ) OVER ( PARTITION BY tenant_id, attribute1, substr( attribute2, 1, 7 ) ORDER BY period ) AS planned_downtime,
            SUM( attribute12 ) OVER ( PARTITION BY tenant_id, attribute1, substr( attribute2, 1, 7 ) ORDER BY period ) AS unplanned_downtime
        FROM
            with_result_confirm
        WHERE
            STATUS = '1'
          AND report_id = '237'
          AND result_cat = 'REPORT_
```

### `更新精加工停机时间`

- Code: `18333852605961`
- Type: `SQL`
- Upstream nodes: `更新冷轧停机时间`
- Downstream nodes: `更新硅钢停机时间`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_combined`, `with_result_confirm`
- Read tables: `with_result_confirm`

```sql
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN (
        SELECT
            tenant_id,
            attribute3 plate_type,
            attribute1 manuf_line_name,
            attribute2 data_date,
            COALESCE ( NULLIF( attribute10, '' ), 0 ) breakdown_frequency,
            COALESCE ( NULLIF( attribute11, '' ), 0 ) planned_downtime,
            COALESCE ( NULLIF( attribute12, '' ), 0 ) unplanned_downtime,
            IFNULL( attribute13, '' ) remark
        FROM
            with_result_confirm
        WHERE
            STATUS = '1'
          AND report_id = '239'
          AND result_cat = 'REPORT_BUSINESS_DATA'

    ) AS source ON target.tenant_id = source.tenant_id
        AND target.data_date = source.data_date
        AND target.manuf_line_name = source.manuf_line_name
SET target.day_breakdown_frequency = source.breakdown_frequency,
    target.day_planned_downtime = source.planned_downtime,
    target.day_unplanned_downtime = source.unplanned_downtime,
    target.remark = source.remark;
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN (
        SELECT
            tenant_id,
            attribute1 AS manuf_line_name,
            attribute2 AS data_date,
            SUM( attribute10 ) OVER ( PARTITION BY tenant_id, attribute1, substr( attribute2, 1, 7 ) ORDER BY attribute2 ) AS breakdown_frequency,
            SUM( attribute11 ) OVER ( PARTITION BY tenant_id, attribute1, substr( attribute2, 1, 7 ) ORDER BY attribute2 ) AS planned_downtime,
            SUM( attribute12 ) OVER ( PARTITION BY tenant_id, attribute1, substr( attribute2, 1, 7 ) ORDER BY attribute2 ) AS unplanned_downtime
        FROM
            with_result_confirm
        WHERE
            STATUS = '1'
          AND report_id = '239'
          AND result_cat = 'REPORT_BUSINESS_DATA'

    ) AS source ON target.tenant_id = source.tenant_id
        AND target.data_date = source.data_date
        AND target.manuf_line_name = source.manuf_line_name
SET target.month_breakdown_frequency = source.breakdown_frequency,
    target.month_planned_downtime = source.planned_downtime,
    target.month_unplanned_downtime = source.unplanned_downtime;
UPDATE with_result_confirm AS target
    INNER JOIN (
        SELECT
            tenant_id,
            attribute1 AS manuf_line_name,
            period AS data_date,
            SUM( attribute10 ) OVER ( PARTITION BY tenant_id, attribute1, substr( attribute2, 1, 7 ) ORDER BY period ) AS breakdown_frequency,
            SUM( attribute11 ) OVER ( PARTITION BY tenant_id, attribute1, substr( attribute2, 1, 7 ) ORDER BY period ) AS planned_downtime,
            SUM( attribute12 ) OVER ( PARTITION BY tenant_id, attribute1, substr( attribute2, 1, 7 ) ORDER BY period ) AS unplanned_downtime
        FROM
            with_result_confirm
        WHERE
            STATUS = '1'
          AND report_id = '239'
          AND result_cat = 'R
```

### `平均厚度更新`

- Code: `18333852605963`
- Type: `SQL`
- Upstream nodes: `更新月生产入库量`
- Downstream nodes: `月平均厚度更新`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_avg_thickness_data`, `ads_sc_xl_13_defined_manuf_line_name_combined`
- Read tables: `ads_sc_xl_13_defined_manuf_line_name_avg_thickness_data`, `dwd_mes_mm_task_group_output`, `dwd_task_prod_actual`

```sql
DELETE
FROM
    ads_sc_xl_13_defined_manuf_line_name_avg_thickness_data
WHERE
    data_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
INSERT INTO ads_sc_xl_13_defined_manuf_line_name_avg_thickness_data  SELECT
                                                                         a.tenant_id,
                                                                         a.plate_type,
                                                                         a.defined_manuf_line_name manuf_line_name,
                                                                         a.bi_sc_xl_013_process_001_attr1 attr1,
                                                                         CASE
                                                                             WHEN SUM(c.roll_length) = 0 THEN
                                                                                 0 ELSE SUM(c.act_height * c.roll_length) / SUM(c.roll_length)
                                                                             END average_thickness,
                                                                         a.data_date
FROM
    dwd_mes_mm_task_group_output a
        JOIN dwd_task_prod_actual c
             ON a.actual_id = c.actual_id
                 and  a.tenant_id = c.tenant_id
                 AND c.status = 1
                 AND a.data_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
WHERE
    a.data_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
  AND a.plate_type IS NOT NULL
  AND a.manuf_line_name IS NOT NULL
GROUP BY
    a.tenant_id,
    a.plate_type,
    a.defined_manuf_line_name,
    a.bi_sc_xl_013_process_001_attr1,
    a.data_date;

UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN ads_sc_xl_13_defined_manuf_line_name_avg_thickness_data AS source ON target.tenant_id = source.tenant_id
        AND target.plate_type = source.plate_type
        AND target.data_date = source.data_date
        AND target.manuf_line_name = source.manuf_line_name
        AND CASE WHEN target.attr1 IS NULL THEN 1 = 1 ELSE target.attr1 = source.attr1  END
SET target.day_average_thickness = source.average_thickness;
```

### `生产入库量`

- Code: `18333852605964`
- Type: `SQL`
- Upstream nodes: `ADS_SC_XL_13_defined_manuf_line_name_combined`
- Downstream nodes: `更新月生产入库量`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_lz`, `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_jjg`, `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_gg`, `ads_sc_xl_13_defined_manuf_line_name_combined`
- Read tables: `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_lz`, `ads_sc_xl_01`, `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_jjg`, `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_gg`, `with_attr_value`

```sql
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
SET target.day_manufacturing_finished_output_tons = 0,
    target.day_manufacturing_finished_output_quantity = 0;
DELETE
FROM
    ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_lz
WHERE
    data_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
INSERT INTO ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_lz SELECT
                                                                             a.tenant_id,
                                                                             b.attribute1 AS manuf_line_name,
                                                                             a.bi_sc_xl_013_process_001_attr1 attr1,
                                                                             SUM(CASE WHEN a.tenant_id = 80 AND a.wh_code = 'HNZZ6' AND a.rd_style = 0102 THEN 0 ELSE weight END) / 1000 AS manufacturing_finished_output_tons,
                                                                             SUM(CASE WHEN a.tenant_id = 80 AND a.wh_code = 'HNZZ6' AND a.rd_style = 0102 THEN 0 ELSE quantity END) AS manufacturing_finished_output_quantity,
                                                                             a.data_date,a.month
FROM
    ads_sc_xl_01 a
        JOIN with_attr_value b ON a.tenant_id = b.tenant_id
        AND b.scene = 'BI-SC-KC-013-WH-CODE-DEFINED-LZ'
        AND (b.attribute2 = '*' OR a.wh_code = b.attribute2)
        AND (b.attribute5 = '*' OR a.dept_code = b.attribute5)
        AND (b.attribute3 = '*' OR a.steel_grade = b.attribute3)
        AND (b.attribute4 = '*' OR a.sku_code = b.attribute4)
        AND (b.attribute6 = '*' OR a.machine_code = b.attribute6)
WHERE
    a.bill_type = 2
  AND a.data_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
  AND a.rd_style <> '1101'
GROUP BY
    a.tenant_id,
    b.attribute1,
    a.data_date,
    a.bi_sc_xl_013_process_001_attr1;
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_lz AS source ON target.tenant_id = source.tenant_id
        AND target.data_date = source.data_date
        AND target.manuf_line_name = source.manuf_line_name
        AND case when  target.attr1  is null then 1=1 else target.attr1 = source.attr1  end
SET target.day_manufacturing_finished_output_tons = source.manufacturing_finished_output_tons,
    target.day_manufacturing_finished_output_quantity = source.manufacturing_finished_output_quantity;





DELETE
FROM
    ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_jjg
WHERE
    data_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);


INSERT INTO ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_jjg SELECT
                                                                              a.tenant_id,
                                                                              b.attribute1 AS manuf_line_name,
                                                              
```

### `成品入库量`

- Code: `18333852605965`
- Type: `SQL`
- Upstream nodes: `月平均厚度更新`
- Downstream nodes: `月成品入库量`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_finished_product_jjg`, `ads_sc_xl_13_defined_manuf_line_name_finished_product_lz`, `ads_sc_xl_13_defined_manuf_line_name_finished_product_gg`, `ads_sc_xl_13_defined_manuf_line_name_combined`
- Read tables: `ads_sc_xl_13_defined_manuf_line_name_finished_product_jjg`, `ads_sc_xl_01`, `ads_sc_xl_13_defined_manuf_line_name_finished_product_lz`, `ads_sc_xl_13_defined_manuf_line_name_finished_product_gg`, `with_attr_value`

```sql
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target

SET target.day_manufacturing_finished_product = 0,
    target.day_manufacturing_finished_product_quantity = 0;
DELETE
FROM
    ads_sc_xl_13_defined_manuf_line_name_finished_product_jjg
WHERE
    data_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
INSERT INTO ads_sc_xl_13_defined_manuf_line_name_finished_product_jjg SELECT
                                                                          a.tenant_id,
                                                                          b.attribute1 manuf_line_name,
                                                                          a.bi_sc_xl_013_process_001_attr1 attr1,
                                                                          SUM(a.weight) / 1000 AS manufacturing_finished_product,
                                                                          SUM(a.quantity) AS manufacturing_finished_product_quantity,
                                                                          a.data_date
FROM
    ads_sc_xl_01 a
        JOIN with_attr_value b ON a.tenant_id = b.tenant_id
        AND b.scene = 'BI-SC-KC-013-WH-CODE-FINISHED-DEFINED-JJG'
        AND (b.attribute2 IN ('*', '') OR a.wh_code = b.attribute2)
        AND (b.attribute5 IN ('*', '') OR a.dept_code = b.attribute5)
        AND (b.attribute3 IN ('*', '') OR a.steel_grade = b.attribute3)
        AND (b.attribute4 IN ('*', '') OR a.sku_code = b.attribute4)
        AND (b.attribute6 IN ('*', '') OR a.machine_code = b.attribute6)
        AND (b.attribute7 IN ('*', '') OR a.other_machine_code = b.attribute7)
        JOIN with_attr_value c ON a.tenant_id = c.tenant_id
        AND c.scene = 'BI-SC-KC-013-RD-FINISHED-DEFINED-JJG'
        AND a.rd_style_name = c.attribute1
WHERE
    a.bill_type = 2
  AND a.data_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY
    a.tenant_id,
    b.attribute1,
    a.bi_sc_xl_013_process_001_attr1,
    a.data_date;
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN ads_sc_xl_13_defined_manuf_line_name_finished_product_jjg AS source ON target.tenant_id = source.tenant_id
        AND target.data_date = source.data_date
        AND target.manuf_line_name = source.manuf_line_name
        AND case when  target.attr1  is null then 1=1 else target.attr1 = source.attr1  end
SET target.day_manufacturing_finished_product = source.manufacturing_finished_product,
    target.day_manufacturing_finished_product_quantity = source.manufacturing_finished_product_quantity;
DELETE
FROM
    ads_sc_xl_13_defined_manuf_line_name_finished_product_lz
WHERE
    data_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
INSERT INTO ads_sc_xl_13_defined_manuf_line_name_finished_product_lz SELECT
                                                                         a.tenant_id,
                                                                         b.attribute1 manuf_line_name,
                                                      
```

### `更新月生产入库量`

- Code: `18333852605966`
- Type: `SQL`
- Upstream nodes: `生产入库量`
- Downstream nodes: `平均厚度更新`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_lz_m`, `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_jjg_m`, `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_gg_m`, `ads_sc_xl_13_defined_manuf_line_name_combined`
- Read tables: `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_lz_m`, `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_lz`, `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_jjg_m`, `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_jjg`, `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_gg_m`, `ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_gg`

```sql
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
SET target.month_manufacturing_finished_output_tons     = 0,
    target.month_manufacturing_finished_output_quantity = 0;
DELETE
FROM ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_lz_m;
INSERT INTO ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_lz_m
SELECT a.tenant_id,
       a.manuf_line_name,
       a.attr1,
       SUM(a.manufacturing_finished_output_tons)
           OVER (PARTITION BY tenant_id, a.manuf_line_name, a.attr1, a.month ORDER BY a.data_date) AS manufacturing_finished_output_tons,
       SUM(a.manufacturing_finished_output_quantity)
           OVER (PARTITION BY tenant_id, a.manuf_line_name, a.attr1, a.month ORDER BY a.data_date) AS manufacturing_finished_output_quantity,
       a.data_date
FROM ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_lz a
GROUP BY a.tenant_id,
         a.manuf_line_name,
         a.attr1,
         a.data_date;
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_lz_m AS source ON
        target.tenant_id = source.tenant_id
            AND target.data_date = source.data_date
            AND target.manuf_line_name = source.manuf_line_name
            AND
        CASE

            WHEN target.attr1 IS NULL THEN
                1 = 1
            ELSE target.attr1 = source.attr1
            END
SET target.month_manufacturing_finished_output_tons     = source.manufacturing_finished_output_tons,
    target.month_manufacturing_finished_output_quantity = source.manufacturing_finished_output_quantity;
DELETE
FROM ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_jjg_m;
INSERT INTO ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_jjg_m
SELECT a.tenant_id,
       a.manuf_line_name,
       a.attr1,
       SUM(a.manufacturing_finished_output_tons)
           OVER (PARTITION BY tenant_id, a.manuf_line_name, a.attr1, a.month ORDER BY a.data_date) AS manufacturing_finished_output_tons,
       SUM(a.manufacturing_finished_output_quantity)
           OVER (PARTITION BY tenant_id, a.manuf_line_name, a.attr1, a.month ORDER BY a.data_date) AS manufacturing_finished_output_quantity,
       data_date
FROM ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_jjg a
GROUP BY a.tenant_id,
         a.manuf_line_name,
         a.attr1,
         data_date;
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN ads_sc_xl_13_defined_manuf_line_name_finished_output_tons_jjg_m AS source ON
        target.tenant_id = source.tenant_id
            AND target.data_date = source.data_date
            AND target.manuf_line_name = source.manuf_line_name
            AND
        CASE

            WHEN target.attr1 IS NULL THEN
                1 = 1
            ELSE target.attr1 = source.attr1
            END
SET target.month_manufacturing_finished_output_tons     = source.manufacturing_finished_output_tons,
    target.month_manufac
```

### `更新硅钢停机时间`

- Code: `18333852605967`
- Type: `SQL`
- Upstream nodes: `更新精加工停机时间`
- Downstream nodes: `增加硅钢板块总计字段`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_combined`, `with_result_confirm`
- Read tables: `with_result_confirm`

```sql
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN (
        SELECT
            tenant_id,
            attribute3 plate_type,
            attribute1 manuf_line_name,
            attribute2 data_date,
            attribute23 attr1,
            COALESCE ( NULLIF( attribute9, '' ), 0 ) breakdown_frequency,
            COALESCE ( NULLIF( attribute10, '' ), 0 ) planned_downtime,
            COALESCE ( NULLIF( attribute11, '' ), 0 ) unplanned_downtime,
            IFNULL( attribute13, '' ) remark
        FROM
            with_result_confirm
        WHERE
            STATUS = '1'
          AND report_id = '543'
          AND result_cat = 'REPORT_BUSINESS_DATA'
    ) AS source ON target.tenant_id = source.tenant_id
        AND target.data_date = source.data_date
        AND target.manuf_line_name = source.manuf_line_name
        AND  case when target.attr1 is null  then  1=1 else target.attr1 = source.attr1 end
SET target.day_breakdown_frequency = source.breakdown_frequency,
    target.day_planned_downtime = source.planned_downtime,
    target.day_unplanned_downtime = source.unplanned_downtime,
    target.remark = source.remark;
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN (
        SELECT
            tenant_id,
            attribute1 AS manuf_line_name,
            attribute2 AS data_date,
            attribute23 attr1,
            SUM( attribute9 ) OVER ( PARTITION BY tenant_id, attribute1,attribute23, substr( attribute2, 1, 7 ) ORDER BY attribute2 ) AS breakdown_frequency,
            SUM( attribute10 ) OVER ( PARTITION BY tenant_id, attribute1,attribute23, substr( attribute2, 1, 7 ) ORDER BY attribute2 ) AS planned_downtime,
            SUM( attribute11 ) OVER ( PARTITION BY tenant_id, attribute1,attribute23, substr( attribute2, 1, 7 ) ORDER BY attribute2 ) AS unplanned_downtime
        FROM
            with_result_confirm
        WHERE
            STATUS = '1'
          AND report_id = '543'
          AND result_cat = 'REPORT_BUSINESS_DATA'
    ) AS source ON target.tenant_id = source.tenant_id
        AND target.data_date = source.data_date
        AND target.manuf_line_name = source.manuf_line_name
        AND  case when target.attr1 is null  then  1=1 else target.attr1 = source.attr1  end
SET target.month_breakdown_frequency = source.breakdown_frequency,
    target.month_planned_downtime = source.planned_downtime,
    target.month_unplanned_downtime = source.unplanned_downtime;
UPDATE with_result_confirm AS target
    INNER JOIN (
        SELECT
            tenant_id,
            attribute1 AS manuf_line_name,
            attribute23 attr1,
            period AS data_date,
            SUM( attribute10 ) OVER ( PARTITION BY tenant_id, attribute1,attribute23, substr( attribute2, 1, 7 ) ORDER BY period ) AS breakdown_frequency,
            SUM( attribute11 ) OVER ( PARTITION BY tenant_id, attribute1,attribute23, substr( attribute2, 1, 7 ) ORDER BY period ) AS planned_downtime,
            S
```

### `月成品入库量`

- Code: `18333852605968`
- Type: `SQL`
- Upstream nodes: `成品入库量`
- Downstream nodes: `增加硅钢合计字段`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_finished_product_lz_m`, `ads_sc_xl_13_defined_manuf_line_name_finished_product_jjg_m`, `ads_sc_xl_13_defined_manuf_line_name_finished_product_gg_m`, `ads_sc_xl_13_defined_manuf_line_name_combined`
- Read tables: `ads_sc_xl_13_defined_manuf_line_name_finished_product_lz_m`, `ads_sc_xl_13_defined_manuf_line_name_finished_product_lz`, `ads_sc_xl_13_defined_manuf_line_name_finished_product_jjg_m`, `ads_sc_xl_13_defined_manuf_line_name_finished_product_jjg`, `ads_sc_xl_13_defined_manuf_line_name_finished_product_gg_m`, `ads_sc_xl_13_defined_manuf_line_name_finished_product_gg`

```sql
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
SET target.month_manufacturing_finished_product          = 0,
    target.month_manufacturing_finished_product_quantity = 0;
DELETE
FROM ads_sc_xl_13_defined_manuf_line_name_finished_product_lz_m;
INSERT INTO ads_sc_xl_13_defined_manuf_line_name_finished_product_lz_m
SELECT a.tenant_id,
       a.manuf_line_name,
       a.attr1,
       SUM(a.manufacturing_finished_product)
           OVER (PARTITION BY tenant_id, a.manuf_line_name, a.attr1, DATE_FORMAT(a.data_date, '%Y-%m') ORDER BY a.data_date) AS manufacturing_finished_product,
       SUM(a.manufacturing_finished_product_quantity)
           OVER (PARTITION BY tenant_id, a.manuf_line_name, a.attr1, DATE_FORMAT(a.data_date, '%Y-%m') ORDER BY a.data_date) AS manufacturing_finished_product_quantity,
       a.data_date
FROM ads_sc_xl_13_defined_manuf_line_name_finished_product_lz a
GROUP BY a.tenant_id,
         a.manuf_line_name,
         a.attr1,
         a.data_date;
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN ads_sc_xl_13_defined_manuf_line_name_finished_product_lz_m AS source ON
        target.tenant_id = source.tenant_id
            AND target.data_date = source.data_date
            AND target.manuf_line_name = source.manuf_line_name
            AND
        CASE

            WHEN target.attr1 IS NULL THEN
                1 = 1
            ELSE target.attr1 = source.attr1
            END
SET target.month_manufacturing_finished_product          = source.manufacturing_finished_product,
    target.month_manufacturing_finished_product_quantity = source.manufacturing_finished_product_quantity;
DELETE
FROM ads_sc_xl_13_defined_manuf_line_name_finished_product_jjg_m;
INSERT INTO ads_sc_xl_13_defined_manuf_line_name_finished_product_jjg_m
SELECT a.tenant_id,
       a.manuf_line_name,
       a.attr1,
       SUM(a.manufacturing_finished_product)
           OVER (PARTITION BY tenant_id, a.manuf_line_name, a.attr1, DATE_FORMAT(a.data_date, '%Y-%m') ORDER BY a.data_date) AS manufacturing_finished_product,
       SUM(a.manufacturing_finished_product_quantity)
           OVER (PARTITION BY tenant_id, a.manuf_line_name, a.attr1, DATE_FORMAT(a.data_date, '%Y-%m') ORDER BY a.data_date) AS manufacturing_finished_product_quantity,
       data_date
FROM ads_sc_xl_13_defined_manuf_line_name_finished_product_jjg a
GROUP BY a.tenant_id,
         a.manuf_line_name,
         a.attr1,
         data_date;
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN ads_sc_xl_13_defined_manuf_line_name_finished_product_jjg_m AS source ON
        target.tenant_id = source.tenant_id
            AND target.data_date = source.data_date
            AND target.manuf_line_name = source.manuf_line_name
            AND
        CASE

            WHEN target.attr1 IS NULL THEN
                1 = 1
            ELSE target.attr1 = source.attr1
            END
SET target.month_manufacturing_finished_product          = sourc
```

### `月平均厚度更新`

- Code: `18333852605969`
- Type: `SQL`
- Upstream nodes: `平均厚度更新`
- Downstream nodes: `成品入库量`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_avg_thickness_data_month`, `ads_sc_xl_13_defined_manuf_line_name_combined`
- Read tables: `ads_sc_xl_13_defined_manuf_line_name_avg_thickness_data_month`, `dwd_mes_mm_task_group_output`, `ods_mes_mm_task_prod_actual`

```sql
DELETE
FROM
    ads_sc_xl_13_defined_manuf_line_name_avg_thickness_data_month
;
INSERT INTO ads_sc_xl_13_defined_manuf_line_name_avg_thickness_data_month SELECT
                                                                               a.tenant_id,
                                                                               a.plate_type,
                                                                               a.defined_manuf_line_name manuf_line_name,
                                                                               a.bi_sc_xl_013_process_001_attr1 attr1,
                                                                               CASE

                                                                                   WHEN SUM(c.roll_length) = 0 THEN
                                                                                       0 ELSE SUM(c.act_height * c.roll_length) / SUM(c.roll_length)
                                                                                   END average_thickness,
                                                                               substr(a.data_date,1,7) data_date
FROM
    dwd_mes_mm_task_group_output a
        JOIN ods_mes_mm_task_prod_actual c ON a.actual_id = c.actual_id
        AND c.`status` = 1
WHERE
   a.plate_type IS NOT NULL
  AND manuf_line_name IS NOT NULL
GROUP BY
    a.tenant_id,
    a.plate_type,
    a.defined_manuf_line_name ,
    a.bi_sc_xl_013_process_001_attr1 ,
    substr(a.data_date,1,7) ;
UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
    INNER JOIN ads_sc_xl_13_defined_manuf_line_name_avg_thickness_data_month AS source ON target.tenant_id = source.tenant_id
        AND target.plate_type = source.plate_type
        AND target.month = source.data_date
        AND target.manuf_line_name = source.manuf_line_name
        AND CASE WHEN target.attr1 IS NULL THEN 1 = 1 ELSE target.attr1 = source.attr1  END
SET target.day_average_thickness = source.average_thickness;
```

### `增加硅钢合计字段`

- Code: `18333852605970`
- Type: `SQL`
- Upstream nodes: `月成品入库量`
- Downstream nodes: `更新月数据`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_combined`
- Read tables: `ads_sc_xl_13_defined_manuf_line_name_combined`

```sql
DELETE from ads_sc_xl_13_defined_manuf_line_name_combined where data_date >= CURRENT_DATE - INTERVAL 35 DAY  and attr1  =  '合计' ;
INSERT INTO ads_sc_xl_13_defined_manuf_line_name_combined (
    tenant_id,
    plate_type,
    group_manuf_line_name,
    manuf_line_name,
    attr1,
    data_date,
    day_weight,
    day_quantity,
    day_average_thickness,
    day_lower_weight,
    day_lower_quantity,
    day_breakdown_frequency,
    day_planned_downtime,
    day_unplanned_downtime,
    day_manufacturing_finished_output_tons,
    day_manufacturing_finished_output_quantity,
    day_manufacturing_finished_output_length,
    day_lower_manufacturing_finished_output_length,
    day_manufacturing_finished_product,
    day_manufacturing_finished_product_quantity,
    month_weight,
    month_quantity,
    month_average_thickness,
    month_lower_weight,
    month_lower_quantity,
    month_breakdown_frequency,
    month_planned_downtime,
    month_unplanned_downtime,
    month_manufacturing_finished_output_tons,
    month_manufacturing_finished_output_quantity,
    month_manufacturing_finished_output_length,
    month_lower_manufacturing_finished_output_length,
    month_manufacturing_finished_product,
    month_manufacturing_finished_product_quantity,
    MONTH,
    YEAR,
    rk,
    rk1) SELECT
             a.tenant_id,
             plate_type,
             group_manuf_line_name,
             a.manuf_line_name,
             '合计' attr1,
             a.data_date,
             SUM(day_weight) AS total_day_weight,
             SUM(day_quantity) AS total_day_quantity,
             avg(day_average_thickness) AS total_day_average_thickness,
             SUM(day_lower_weight) AS total_day_lower_weight,
             SUM(day_lower_quantity) AS total_day_lower_quantity,
             SUM(day_breakdown_frequency) AS total_day_breakdown_frequency,
             SUM(day_planned_downtime) AS total_day_planned_downtime,
             SUM(day_unplanned_downtime) AS total_day_unplanned_downtime,
             SUM(day_manufacturing_finished_output_tons) AS total_day_manufacturing_finished_output_tons,
             SUM(day_manufacturing_finished_output_quantity) AS total_day_manufacturing_finished_output_quantity,
             SUM(day_manufacturing_finished_output_length) AS total_day_manufacturing_finished_output_length,
             SUM(day_lower_manufacturing_finished_output_length) AS total_day_lower_manufacturing_finished_output_length,
             SUM(day_manufacturing_finished_product) AS total_day_manufacturing_finished_product,
             SUM(day_manufacturing_finished_product_quantity) total_day_manufacturing_finished_quantity,
             SUM(month_weight) AS total_month_weight,
             SUM(month_quantity) AS total_month_quantity,
             avg(month_average_thickness) AS total_month_average_thickness,
             SUM(month_lower_weight) AS total_month_lower_weight,
             SUM(month_lower_quantity) AS total_month_lower_quantity,
             SUM(mont
```

### `增加硅钢板块总计字段`

- Code: `18333852605971`
- Type: `SQL`
- Upstream nodes: `更新硅钢停机时间`
- Downstream nodes: `BI_SC_XL_013_DEFINED_MANUF_LINE_NAME_COMBINED_001`, `BI_SC_XL_013_DEFINED_MANUF_LINE_NAME_COMBINED_002`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_combined`
- Read tables: `ads_sc_xl_13_defined_manuf_line_name_combined`

```sql
-- 1. 删除已有的“总计”记录
DELETE
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE manuf_line_name = '总计';

-- 2. 插入汇总后的“总计”记录
INSERT INTO ads_sc_xl_13_defined_manuf_line_name_combined (
    tenant_id,
    plate_type,
    group_manuf_line_name,
    manuf_line_name,
    attr1,
    data_date,
    day_weight,
    day_quantity,
    day_average_thickness,
    day_lower_weight,
    day_lower_quantity,
    day_breakdown_frequency,
    day_planned_downtime,
    day_unplanned_downtime,
    day_manufacturing_finished_output_tons,
    day_manufacturing_finished_output_quantity,
    day_manufacturing_finished_output_length,
    day_lower_manufacturing_finished_output_length,
    day_manufacturing_finished_product,
    day_manufacturing_finished_product_quantity,
    month_weight,
    month_quantity,
    month_average_thickness,
    month_lower_weight,
    month_lower_quantity,
    month_breakdown_frequency,
    month_planned_downtime,
    month_unplanned_downtime,
    month_manufacturing_finished_output_tons,
    month_manufacturing_finished_output_quantity,
    month_manufacturing_finished_output_length,
    month_lower_manufacturing_finished_output_length,
    month_manufacturing_finished_product,
    month_manufacturing_finished_product_quantity,
    MONTH,
    YEAR,
    rk,
    rk1
)
SELECT
    a.tenant_id,
    a.plate_type,
    '' AS group_manuf_line_name,
    '总计' AS manuf_line_name,
    '' AS attr1,
    a.data_date,
    SUM(a.day_weight) AS day_weight,
    SUM(a.day_quantity) AS day_quantity,
    AVG(a.day_average_thickness) AS day_average_thickness,
    SUM(a.day_lower_weight) AS day_lower_weight,
    SUM(a.day_lower_quantity) AS day_lower_quantity,
    SUM(a.day_breakdown_frequency) AS day_breakdown_frequency,
    SUM(a.day_planned_downtime) AS day_planned_downtime,
    SUM(a.day_unplanned_downtime) AS day_unplanned_downtime,
    SUM(a.day_manufacturing_finished_output_tons) AS day_manufacturing_finished_output_tons,
    SUM(a.day_manufacturing_finished_output_quantity) AS day_manufacturing_finished_output_quantity,
    SUM(a.day_manufacturing_finished_output_length) AS day_manufacturing_finished_output_length,
    SUM(a.day_lower_manufacturing_finished_output_length) AS day_lower_manufacturing_finished_output_length,
    SUM(a.day_manufacturing_finished_product) AS day_manufacturing_finished_product,
    SUM(a.day_manufacturing_finished_product_quantity) AS day_manufacturing_finished_product_quantity,
    SUM(a.month_weight) AS month_weight,
    SUM(a.month_quantity) AS month_quantity,
    AVG(a.month_average_thickness) AS month_average_thickness,
    SUM(a.month_lower_weight) AS month_lower_weight,
    SUM(a.month_lower_quantity) AS month_lower_quantity,
    SUM(a.month_breakdown_frequency) AS month_breakdown_frequency,
    SUM(a.month_planned_downtime) AS month_planned_downtime,
    SUM(a.month_unplanned_downtime) AS month_unplanned_downtime,
    SUM(a.month_manufacturing_finished_output_tons) AS month_manufacturing_finished_output_tons,
    SUM(a
```

### `更新月数据`

- Code: `18333852605972`
- Type: `SQL`
- Upstream nodes: `增加硅钢合计字段`
- Downstream nodes: `更新冷轧停机时间`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_combined_process1`, `ads_sc_xl_13_defined_manuf_line_name_combined`
- Read tables: `ads_sc_xl_13_defined_manuf_line_name_combined`, `ads_sc_xl_13_defined_manuf_line_name_combined_process1`

```sql
SET @start_month = DATE_FORMAT(CURRENT_DATE - INTERVAL 35 DAY, '%Y-%m');

TRUNCATE TABLE ads_sc_xl_13_defined_manuf_line_name_combined_process1;

INSERT INTO ads_sc_xl_13_defined_manuf_line_name_combined_process1 (
    tenant_id,
    plate_type,
    manuf_line_name,
    attr1,
    `MONTH`,
    data_date,
    month_weight,
    month_quantity,
    month_average_thickness,
    month_lower_weight,
    month_lower_quantity,
    month_breakdown_frequency,
    month_planned_downtime,
    month_unplanned_downtime,
    month_manufacturing_finished_output_tons,
    month_manufacturing_finished_output_quantity,
    month_manufacturing_finished_output_length,
    month_lower_manufacturing_finished_output_length,
    month_manufacturing_finished_product,
    month_manufacturing_finished_product_quantity
)
SELECT
    tenant_id,
    plate_type,
    manuf_line_name,
    attr1,
    month,
    data_date,
    SUM(COALESCE(day_weight, 0)) OVER w,
    SUM(COALESCE(day_quantity, 0)) OVER w,
    AVG(COALESCE(day_average_thickness, 0)) OVER w,
    SUM(COALESCE(day_lower_weight, 0)) OVER w,
    SUM(COALESCE(day_lower_quantity, 0)) OVER w,
    SUM(COALESCE(day_breakdown_frequency, 0)) OVER w,
    SUM(COALESCE(day_planned_downtime, 0)) OVER w,
    SUM(COALESCE(day_unplanned_downtime, 0)) OVER w,
    SUM(COALESCE(day_manufacturing_finished_output_tons, 0)) OVER w,
    SUM(COALESCE(day_manufacturing_finished_output_quantity, 0)) OVER w,
    SUM(COALESCE(day_manufacturing_finished_output_length, 0)) OVER w,
    SUM(COALESCE(day_lower_manufacturing_finished_output_length, 0)) OVER w,
    SUM(COALESCE(day_manufacturing_finished_product, 0)) OVER w,
    SUM(COALESCE(CAST(NULLIF(day_manufacturing_finished_product_quantity, '') AS DECIMAL(40,4)), 0)) OVER w
FROM ads_sc_xl_13_defined_manuf_line_name_combined
WHERE month >= @start_month
WINDOW w AS (
    PARTITION BY tenant_id, plate_type, manuf_line_name, attr1, month
    ORDER BY data_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
);

UPDATE ads_sc_xl_13_defined_manuf_line_name_combined AS target
INNER JOIN ads_sc_xl_13_defined_manuf_line_name_combined_process1 AS monthly
    ON target.tenant_id = monthly.tenant_id
    AND target.plate_type = monthly.plate_type
    AND target.manuf_line_name = monthly.manuf_line_name
    AND target.attr1 <=> monthly.attr1
    AND target.month = monthly.`MONTH`
    AND target.data_date = monthly.data_date
SET
    target.month_weight = monthly.month_weight,
    target.month_quantity = monthly.month_quantity,
    target.month_average_thickness = monthly.month_average_thickness,
    target.month_lower_weight = monthly.month_lower_weight,
    target.month_lower_quantity = monthly.month_lower_quantity,
    target.month_breakdown_frequency = monthly.month_breakdown_frequency,
    target.month_planned_downtime = monthly.month_planned_downtime,
    target.month_unplanned_downtime = monthly.month_unplanned_downtime,
    target.month_manufacturing_finished_output_tons = monthly.month_manufacturing
```

### `BI_SC_XL_013_DEFINED_MANUF_LINE_NAME_COMBINED_001`

- Code: `18333852605973`
- Type: `SQL`
- Upstream nodes: `增加硅钢板块总计字段`
- Downstream nodes: `END`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_combined_001`
- Read tables: `ads_sc_xl_13_defined_manuf_line_name_combined_001`, `ads_sc_xl_13_defined_manuf_line_name_combined`

```sql
DELETE
FROM
    ads_sc_xl_13_defined_manuf_line_name_combined_001
WHERE
    plate_type = '冷轧';
INSERT INTO ads_sc_xl_13_defined_manuf_line_name_combined_001 SELECT
                                                                   tenant_id,
                                                                   plate_type,
                                                                   group_manuf_line_name,
                                                                   manuf_line_name,
                                                                   '',
                                                                   '日' period,
                                                                   data_date AS data_date,
                                                                   day_weight AS weight,
                                                                   day_quantity AS quantity,
                                                                   day_average_thickness AS average_thickness,
                                                                   day_lower_weight AS lower_weight,
                                                                   day_lower_quantity AS lower_quantity,
                                                                   day_breakdown_frequency AS breakdown_frequency,
                                                                   day_planned_downtime AS planned_downtime,
                                                                   day_unplanned_downtime AS unplanned_downtime,
                                                                   day_manufacturing_finished_output_tons AS manufacturing_finished_output_tons,
                                                                   day_manufacturing_finished_output_quantity AS manufacturing_finished_output_quantity,
                                                                   day_manufacturing_finished_output_length AS manufacturing_finished_output_length,
                                                                   day_lower_manufacturing_finished_output_length AS lower_manufacturing_finished_output_length,
                                                                   day_manufacturing_finished_product AS manufacturing_finished_product,
                                                                   day_manufacturing_finished_product_quantity AS manufacturing_finished_product_quantity,
                                                                   rk,
                                                                   1 rk1,
                                                                   rk1 rk2,
                                                                   remark
FROM
    ads_sc_xl_13_defined_manuf_line_name_combined
WHERE
    plate_type = '冷轧' UNION ALL
SELECT
    tenant_id,
    plate_type,
    group_manuf_line_name,
    manuf_line_name,
    '',
    '月' period,
    data_date,
    month_weigh
```

### `BI_SC_XL_013_DEFINED_MANUF_LINE_NAME_COMBINED_002`

- Code: `21226918778112`
- Type: `SQL`
- Upstream nodes: `增加硅钢板块总计字段`
- Downstream nodes: `END`
- Write tables: `ads_sc_xl_13_defined_manuf_line_name_combined_002`
- Read tables: `ads_sc_xl_13_defined_manuf_line_name_combined`

```sql
truncate  table ads_sc_xl_13_defined_manuf_line_name_combined_002 ;
insert into ads_sc_xl_13_defined_manuf_line_name_combined_002
select tenant_id,
       plate_type,
       group_manuf_line_name,
       manuf_line_name,
       attr1,
       data_date,
       day_weight,
       day_quantity,
       day_average_thickness,
       day_lower_weight,
       day_lower_quantity,
       day_breakdown_frequency,
       day_planned_downtime,
       day_unplanned_downtime,
       day_manufacturing_finished_output_tons,
       day_manufacturing_finished_output_quantity,
       day_manufacturing_finished_output_length,
       day_lower_manufacturing_finished_output_length,
       day_manufacturing_finished_product,
       day_manufacturing_finished_product_quantity,
       month_weight,
       month_quantity,
       month_average_thickness,
       month_lower_weight,
       month_lower_quantity,
       month_breakdown_frequency,
       month_planned_downtime,
       month_unplanned_downtime,
       month_manufacturing_finished_output_tons,
       month_manufacturing_finished_output_quantity,
       month_manufacturing_finished_output_length,
       month_lower_manufacturing_finished_output_length,
       month_manufacturing_finished_product,
       month_manufacturing_finished_product_quantity,
       month,
       year,
       rk,
       rk1,
       remark,
       day_output_plan
from ads_sc_xl_13_defined_manuf_line_name_combined ;
```
