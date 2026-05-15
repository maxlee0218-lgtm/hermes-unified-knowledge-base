-- =======================================
-- xs_18 final plan
-- 目标：
--   1. 使用临时表先构建 2026 年以来明细，缩短正式表写锁时间。
--   2. 将 place/channel 修正前置到 INSERT 阶段，避免后置 UPDATE 扫大表。
--   3. 将一对多 receive_warehouse 映射压成一对一，避免 JOIN 放大行数。
--   4. 使用 UPSERT 刷新日/月汇总，避免整表 DELETE + INSERT。
--   5. 配合 Dolphin 工作流串行等待，避免多实例互相清表。
-- =======================================

SET @start_date = DATE('2026-01-01');
SET @end_date = CURDATE();
SET @end_next_date = DATE_ADD(@end_date, INTERVAL 1 DAY);
SET @start_month = LEFT(@start_date, 7);
SET @start_month_date = STR_TO_DATE(CONCAT(@start_month, '-01'), '%Y-%m-%d');

DROP TEMPORARY TABLE IF EXISTS tmp_ads_gx_xs_18_detail;
DROP TEMPORARY TABLE IF EXISTS tmp_ads_gx_xs_18_batches;

CREATE TEMPORARY TABLE tmp_ads_gx_xs_18_detail LIKE ads_gx_xs_18_detail;

CREATE TEMPORARY TABLE tmp_ads_gx_xs_18_batches (
    batch_code varchar(50) NOT NULL,
    PRIMARY KEY (batch_code)
) ENGINE=MEMORY;

-- 来源一：转库单
INSERT INTO tmp_ads_gx_xs_18_detail (
    silicon_steel_product_category_name, out_warehouse, cust_code, cust_abbr,
    batch_code, quantity, steel_grade, surface, grade, spec, iron_loss,
    transfer_order_code, transfer_order_date, return_weight, return_created_time,
    weight, amount_in_tax, wh_name, channel, contract_code, data_date, place
)
SELECT
    si.silicon_steel_product_category_name,
    t.out_warehouse,
    ti.cust_code,
    ti.cust_abbr,
    ti.batch_code,
    ti.quantity,
    bi.steel_grade,
    bi.surface,
    bi.grade,
    bi.spec,
    NULL AS iron_loss,
    t.transfer_order_code,
    t.transfer_order_date,
    IFNULL(rd.actual_return_exchange_quantity, 0) AS return_weight,
    rd.created_time AS return_created_time,
    ti.quantity AS weight,
    0.0 AS amount_in_tax,
    ww.wh_name,
    CASE
        WHEN ti.cust_abbr = '佛山湘宏财' THEN '湖南宏旺'
        ELSE COALESCE(ch.attribute1, '湖南宏旺')
    END AS channel,
    ti.contract_code,
    DATE(COALESCE(t.transfer_order_date, t.approve_date)) AS data_date,
    COALESCE(pd.receive_warehouse, sdd.receive_warehouse, ti.receive_warehouse) AS place
FROM ods_crm_sa_transfer_order t
JOIN ods_crm_sa_transfer_order_detail ti
    ON t.transfer_order_id = ti.transfer_order_id
   AND ti.status = 1
JOIN ods_mes_wms_warehouse ww
    ON t.in_warehouse_code = ww.wh_code
   AND ww.status = 1
   AND SUBSTR(ww.wh_name, 1, 1) = 'B'
   AND ww.wh_code <> 2098
LEFT JOIN ods_crm_sv_return_detail rd
    ON ti.contract_code = rd.contract_code
   AND ti.batch_code = rd.batch_code
   AND rd.return_detail_status IN (20, 30, 40)
JOIN ods_mes_wms_batch_info bi
    ON ti.batch_code = bi.batch_code
   AND bi.status = 1
   AND t.tenant_id = bi.tenant_id
JOIN dwd_silicon_steel_surface_info si
    ON bi.surface = si.surface
   AND si.silicon_steel_product_category_name IS NOT NULL
LEFT JOIN (
    SELECT contract_code, MAX(receive_warehouse) AS receive_warehouse
    FROM ods_crm_sa_sales_delivery_order_detail
    WHERE tenant_id = 92
      AND receive_warehouse IS NOT NULL
      AND status = 1
    GROUP BY contract_code
) sdd
    ON ti.contract_code = sdd.contract_code
LEFT JOIN (
    SELECT source_code, MAX(receive_warehouse) AS receive_warehouse
    FROM ods_crm_sa_pending_delivery
    WHERE tenant_id IN (92, 108)
      AND receive_warehouse IS NOT NULL
    GROUP BY source_code
) pd
    ON t.transfer_order_code = pd.source_code
LEFT JOIN (
    SELECT attribute2, MAX(attribute1) AS attribute1
    FROM with_attr_value
    WHERE scene = 'bi_gx_xs_012_detail_attr1_2'
    GROUP BY attribute2
) ch
    ON ti.cust_abbr = ch.attribute2
WHERE t.transfer_order_state IN (20, 40)
  AND t.status = 1
  AND t.tenant_id IN (92, 108)
  AND (
      (t.transfer_order_date IS NOT NULL
       AND t.transfer_order_date >= @start_date)
      OR
      (t.transfer_order_date IS NULL
       AND t.approve_date >= @start_date)
  );

INSERT IGNORE INTO tmp_ads_gx_xs_18_batches (batch_code)
SELECT DISTINCT batch_code
FROM tmp_ads_gx_xs_18_detail
WHERE batch_code IS NOT NULL;

-- 来源二：销售发货单，硅钢
INSERT INTO tmp_ads_gx_xs_18_detail (
    silicon_steel_product_category_name, out_warehouse, cust_code, cust_abbr,
    batch_code, quantity, steel_grade, surface, grade, spec, iron_loss,
    transfer_order_code, transfer_order_date, return_weight, return_created_time,
    weight, amount_in_tax, wh_name, channel, contract_code, data_date, place
)
SELECT
    si.silicon_steel_product_category_name,
    sdod.wh_code,
    sdo.cust_code,
    sdo.cust_abbr,
    sdod.batch_code,
    sdod.weight,
    bi.steel_grade,
    bi.surface,
    bi.grade,
    bi.spec,
    bi.iron_loss,
    sdo.sales_delivery_order_code,
    sdod.sales_delivery_order_date,
    IFNULL(srd.actual_return_exchange_quantity, 0) AS return_weight,
    srd.created_time AS return_created_time,
    sdod.weight,
    sdod.amount_in_tax,
    '' AS wh_name,
    CASE
        WHEN sdo.cust_abbr = '佛山湘宏财' THEN '湖南宏旺'
        ELSE COALESCE(ch.attribute1, '湖南宏旺')
    END AS channel,
    sdod.contract_code,
    DATE(IFNULL(sdo.approver_date, sdo.created_time)) AS data_date,
    COALESCE(pd.receive_warehouse, sdd.receive_warehouse, sdod.receive_warehouse) AS place
FROM ods_crm_sa_sales_delivery_order sdo
JOIN ods_crm_sa_sales_delivery_order_detail sdod
    ON sdo.sales_delivery_order_code = sdod.sales_delivery_order_code
   AND sdod.status = 1
   AND sdod.sales_delivery_order_detail_state IN ('50', '20', '30')
JOIN ods_mes_wms_batch_info bi
    ON sdod.batch_code = bi.batch_code
   AND bi.status = 1
   AND sdo.tenant_id = bi.tenant_id
JOIN dwd_silicon_steel_surface_info si
    ON bi.surface = si.surface
   AND si.silicon_steel_product_category_name IS NOT NULL
LEFT JOIN ods_crm_sv_return_detail srd
    ON sdod.sales_order_detail_code = srd.sales_order_detail_code
   AND sdod.batch_code = srd.batch_code
   AND sdod.prod_spec3 = srd.prod_spec3
   AND srd.return_detail_status IN (20, 30, 40)
LEFT JOIN (
    SELECT contract_code, MAX(receive_warehouse) AS receive_warehouse
    FROM ods_crm_sa_sales_delivery_order_detail
    WHERE tenant_id = 92
      AND receive_warehouse IS NOT NULL
      AND status = 1
    GROUP BY contract_code
) sdd
    ON sdod.contract_code = sdd.contract_code
LEFT JOIN (
    SELECT source_code, MAX(receive_warehouse) AS receive_warehouse
    FROM ods_crm_sa_pending_delivery
    WHERE tenant_id IN (92, 108)
      AND receive_warehouse IS NOT NULL
    GROUP BY source_code
) pd
    ON sdo.sales_delivery_order_code = pd.source_code
LEFT JOIN (
    SELECT attribute2, MAX(attribute1) AS attribute1
    FROM with_attr_value
    WHERE scene = 'bi_gx_xs_012_detail_attr1_2'
    GROUP BY attribute2
) ch
    ON sdo.cust_abbr = ch.attribute2
LEFT JOIN tmp_ads_gx_xs_18_batches tmp
    ON tmp.batch_code = sdod.batch_code
WHERE sdo.tenant_id IN (92, 108)
  AND sdod.created_time >= @start_date
  AND tmp.batch_code IS NULL;

INSERT IGNORE INTO tmp_ads_gx_xs_18_batches (batch_code)
SELECT DISTINCT batch_code
FROM tmp_ads_gx_xs_18_detail
WHERE batch_code IS NOT NULL;

-- 来源三：销售发货单，铁心
INSERT INTO tmp_ads_gx_xs_18_detail (
    silicon_steel_product_category_name, out_warehouse, cust_code, cust_abbr,
    batch_code, quantity, steel_grade, surface, grade, spec, iron_loss,
    transfer_order_code, transfer_order_date, return_weight, return_created_time,
    weight, amount_in_tax, wh_name, channel, contract_code, data_date, place
)
SELECT
    '铁心' AS silicon_steel_product_category_name,
    sdod.wh_code,
    sdo.cust_code,
    sdo.cust_abbr,
    sdod.batch_code,
    sdod.weight,
    bi.steel_grade,
    bi.surface,
    bi.grade,
    bi.spec,
    bi.iron_loss,
    sdo.sales_delivery_order_code,
    sdod.sales_delivery_order_date,
    IFNULL(srd.actual_return_exchange_quantity, 0) AS return_weight,
    srd.created_time AS return_created_time,
    sdod.weight,
    sdod.amount_in_tax,
    '' AS wh_name,
    CASE
        WHEN sdo.cust_abbr = '佛山湘宏财' THEN '湖南宏旺'
        ELSE COALESCE(ch.attribute1, '湖南宏旺')
    END AS channel,
    sdod.contract_code,
    DATE(IFNULL(sdo.approver_date, sdo.created_time)) AS data_date,
    COALESCE(pd.receive_warehouse, sdd.receive_warehouse, sdod.receive_warehouse) AS place
FROM ods_crm_sa_sales_delivery_order sdo
JOIN ods_crm_sa_sales_delivery_order_detail sdod
    ON sdo.sales_delivery_order_code = sdod.sales_delivery_order_code
   AND sdod.status = 1
   AND sdod.sales_delivery_order_detail_state IN ('50', '20', '30')
JOIN (
    SELECT DISTINCT attribute1
    FROM with_attr_value
    WHERE scene = 'bi_gx_xs_017_STOCK_NAME'
) av1
    ON sdod.sku_name = av1.attribute1
LEFT JOIN ods_mes_wms_batch_info bi
    ON sdod.batch_code = bi.batch_code
   AND bi.status = 1
   AND sdo.tenant_id = bi.tenant_id
LEFT JOIN ods_crm_sv_return_detail srd
    ON sdod.sales_order_detail_code = srd.sales_order_detail_code
   AND sdod.batch_code = srd.batch_code
   AND sdod.prod_spec3 = srd.prod_spec3
   AND srd.return_detail_status IN (20, 30, 40)
LEFT JOIN (
    SELECT contract_code, MAX(receive_warehouse) AS receive_warehouse
    FROM ods_crm_sa_sales_delivery_order_detail
    WHERE tenant_id = 92
      AND receive_warehouse IS NOT NULL
      AND status = 1
    GROUP BY contract_code
) sdd
    ON sdod.contract_code = sdd.contract_code
LEFT JOIN (
    SELECT source_code, MAX(receive_warehouse) AS receive_warehouse
    FROM ods_crm_sa_pending_delivery
    WHERE tenant_id IN (92, 108)
      AND receive_warehouse IS NOT NULL
    GROUP BY source_code
) pd
    ON sdo.sales_delivery_order_code = pd.source_code
LEFT JOIN (
    SELECT attribute2, MAX(attribute1) AS attribute1
    FROM with_attr_value
    WHERE scene = 'bi_gx_xs_012_detail_attr1_2'
    GROUP BY attribute2
) ch
    ON sdo.cust_abbr = ch.attribute2
LEFT JOIN tmp_ads_gx_xs_18_batches tmp
    ON tmp.batch_code = sdod.batch_code
WHERE sdo.tenant_id IN (92, 108)
  AND sdod.created_time >= @start_date
  AND sdo.sales_delivery_order_code NOT IN ('FHD202501031919', 'FHD202503290024')
  AND tmp.batch_code IS NULL;

-- 短事务替换正式明细。
START TRANSACTION;

DELETE FROM ads_gx_xs_18_detail;

INSERT INTO ads_gx_xs_18_detail (
    silicon_steel_product_category_name, out_warehouse, cust_code, cust_abbr,
    batch_code, quantity, steel_grade, surface, grade, spec, iron_loss,
    transfer_order_code, transfer_order_date, return_weight, return_created_time,
    weight, amount_in_tax, wh_name, channel, contract_code, data_date, place
)
SELECT
    silicon_steel_product_category_name, out_warehouse, cust_code, cust_abbr,
    batch_code, quantity, steel_grade, surface, grade, spec, iron_loss,
    transfer_order_code, transfer_order_date, return_weight, return_created_time,
    weight, amount_in_tax, wh_name, channel, contract_code, data_date, place
FROM tmp_ads_gx_xs_18_detail;

COMMIT;

DROP TEMPORARY TABLE IF EXISTS tmp_ads_gx_xs_18_detail;
DROP TEMPORARY TABLE IF EXISTS tmp_ads_gx_xs_18_batches;

-- Dolphin 原任务中还包含对 ads_gx_xs_12_detail 的佛山湘宏财归属修正。
-- 这里保留原口径，但增加差异判断，避免每次无效更新扫表。
UPDATE ads_gx_xs_12_detail a
JOIN with_attr_value b
    ON a.salesman = b.attribute1
   AND b.scene = 'bi_gx_xs_012_detail_attr1'
SET a.attr1 = b.attribute2
WHERE a.cust_abbr = '佛山湘宏财'
  AND (a.attr1 <> b.attribute2 OR a.attr1 IS NULL);

-- 日汇总：从 2026-01-01 到今天按天 UPSERT。
INSERT INTO ads_gx_xs_18_01 (
    silicon_steel_product_category_name, data_date,
    attr1, attr2, attr3, attr4, attr5, attr6, attr7,
    sync_time, period
)
SELECT
    b.silicon_steel_product_category_name,
    di.date_id AS data_date,
    SUM(CASE WHEN de.channel = '湖南宏旺' THEN IFNULL(de.weight, 0) END) / 1000,
    SUM(CASE WHEN de.channel = '佛山宏旺' THEN IFNULL(de.weight, 0) END) / 1000,
    SUM(CASE WHEN de.channel = '江苏宏旺' THEN IFNULL(de.weight, 0) END) / 1000,
    SUM(CASE WHEN de.channel = '河南宏旺' THEN IFNULL(de.weight, 0) END) / 1000,
    SUM(CASE WHEN de.channel = '成都宏旺' THEN IFNULL(de.weight, 0) END) / 1000,
    SUM(CASE WHEN de.channel = '佛山宏芯' THEN IFNULL(de.weight, 0) END) / 1000,
    SUM(CASE WHEN de.channel IN ('湖南宏旺', '佛山宏旺', '江苏宏旺', '河南宏旺', '成都宏旺', '佛山宏芯')
             THEN IFNULL(de.weight, 0) END) / 1000,
    CURRENT_DATE,
    'D'
FROM dim_date_info di
JOIN (
    SELECT DISTINCT silicon_steel_product_category_name
    FROM ads_gx_xs_18_detail
    WHERE silicon_steel_product_category_name IS NOT NULL
) b ON 1 = 1
LEFT JOIN ads_gx_xs_18_detail de
    ON di.date_id = de.data_date
   AND b.silicon_steel_product_category_name = de.silicon_steel_product_category_name
WHERE di.date_id >= @start_date
  AND di.date_id < @end_next_date
GROUP BY b.silicon_steel_product_category_name, di.date_id
ON DUPLICATE KEY UPDATE
    attr1 = VALUES(attr1),
    attr2 = VALUES(attr2),
    attr3 = VALUES(attr3),
    attr4 = VALUES(attr4),
    attr5 = VALUES(attr5),
    attr6 = VALUES(attr6),
    attr7 = VALUES(attr7),
    sync_time = VALUES(sync_time);

-- 月汇总：从 start_month 起重算到本月。
INSERT INTO ads_gx_xs_18_01 (
    silicon_steel_product_category_name, data_date,
    attr1, attr2, attr3, attr4, attr5, attr6, attr7,
    sync_time, period
)
WITH monthly_agg AS (
    SELECT
        silicon_steel_product_category_name,
        SUBSTR(data_date, 1, 7) AS data_date,
        SUM(CASE WHEN channel = '湖南宏旺' THEN IFNULL(weight, 0) END) / 1000 AS attr1,
        SUM(CASE WHEN channel = '佛山宏旺' THEN IFNULL(weight, 0) END) / 1000 AS attr2,
        SUM(CASE WHEN channel = '江苏宏旺' THEN IFNULL(weight, 0) END) / 1000 AS attr3,
        SUM(CASE WHEN channel = '河南宏旺' THEN IFNULL(weight, 0) END) / 1000 AS attr4,
        SUM(CASE WHEN channel = '成都宏旺' THEN IFNULL(weight, 0) END) / 1000 AS attr5,
        SUM(CASE WHEN channel = '佛山宏芯' THEN IFNULL(weight, 0) END) / 1000 AS attr6,
        SUM(CASE WHEN channel IN ('湖南宏旺', '佛山宏旺', '江苏宏旺', '河南宏旺', '成都宏旺', '佛山宏芯')
                 THEN IFNULL(weight, 0) END) / 1000 AS attr7
    FROM ads_gx_xs_18_detail
    WHERE data_date >= @start_month_date
      AND data_date < @end_next_date
    GROUP BY silicon_steel_product_category_name, SUBSTR(data_date, 1, 7)

    UNION ALL

    SELECT
        silicon_steel_product_category_name,
        SUBSTR(return_created_time, 1, 7) AS data_date,
        -SUM(CASE WHEN channel = '湖南宏旺' THEN IFNULL(return_weight, 0) END) / 1000 AS attr1,
        -SUM(CASE WHEN channel = '佛山宏旺' THEN IFNULL(return_weight, 0) END) / 1000 AS attr2,
        -SUM(CASE WHEN channel = '江苏宏旺' THEN IFNULL(return_weight, 0) END) / 1000 AS attr3,
        -SUM(CASE WHEN channel = '河南宏旺' THEN IFNULL(return_weight, 0) END) / 1000 AS attr4,
        -SUM(CASE WHEN channel = '成都宏旺' THEN IFNULL(return_weight, 0) END) / 1000 AS attr5,
        -SUM(CASE WHEN channel = '佛山宏芯' THEN IFNULL(return_weight, 0) END) / 1000 AS attr6,
        -SUM(CASE WHEN channel IN ('湖南宏旺', '佛山宏旺', '江苏宏旺', '河南宏旺', '成都宏旺', '佛山宏芯')
                  THEN IFNULL(return_weight, 0) END) / 1000 AS attr7
    FROM ads_gx_xs_18_detail
    WHERE silicon_steel_product_category_name IS NOT NULL
      AND return_created_time >= @start_month_date
      AND return_created_time < @end_next_date
    GROUP BY silicon_steel_product_category_name, SUBSTR(return_created_time, 1, 7)
)
SELECT
    silicon_steel_product_category_name,
    data_date,
    NULLIF(SUM(attr1), 0),
    NULLIF(SUM(attr2), 0),
    NULLIF(SUM(attr3), 0),
    NULLIF(SUM(attr4), 0),
    NULLIF(SUM(attr5), 0),
    NULLIF(SUM(attr6), 0),
    NULLIF(SUM(attr7), 0),
    CURRENT_DATE,
    'M'
FROM monthly_agg
GROUP BY silicon_steel_product_category_name, data_date
ON DUPLICATE KEY UPDATE
    attr1 = VALUES(attr1),
    attr2 = VALUES(attr2),
    attr3 = VALUES(attr3),
    attr4 = VALUES(attr4),
    attr5 = VALUES(attr5),
    attr6 = VALUES(attr6),
    attr7 = VALUES(attr7),
    sync_time = VALUES(sync_time);
