SET @m_start = DATE('2026-03-01');
SET @m_end = DATE('2026-04-01');
SET @full_start = DATE('2026-01-01');

DROP TEMPORARY TABLE IF EXISTS tmp_xs18_old_march_cmp;
DROP TEMPORARY TABLE IF EXISTS tmp_xs18_new_march_cmp;
DROP TEMPORARY TABLE IF EXISTS tmp_xs18_old_batches;
DROP TEMPORARY TABLE IF EXISTS tmp_xs18_new_batches;
DROP TEMPORARY TABLE IF EXISTS tmp_xs18_sdo_march;
DROP TEMPORARY TABLE IF EXISTS tmp_xs18_sdod_march;
DROP TEMPORARY TABLE IF EXISTS tmp_xs18_sdd_place_old;
DROP TEMPORARY TABLE IF EXISTS tmp_xs18_sdd_place_new;
DROP TEMPORARY TABLE IF EXISTS tmp_xs18_pd_place_old;
DROP TEMPORARY TABLE IF EXISTS tmp_xs18_pd_place_new;
DROP TEMPORARY TABLE IF EXISTS tmp_xs18_channel_new;

CREATE TEMPORARY TABLE tmp_xs18_old_march_cmp (
    source_name varchar(20),
    silicon_steel_product_category_name varchar(200),
    channel varchar(200),
    batch_code varchar(100),
    transfer_order_code varchar(100),
    cust_abbr varchar(200),
    contract_code varchar(100),
    place varchar(200),
    weight decimal(18, 6),
    data_date date
);

CREATE TEMPORARY TABLE tmp_xs18_new_march_cmp LIKE tmp_xs18_old_march_cmp;

CREATE TEMPORARY TABLE tmp_xs18_old_batches (
    batch_code varchar(100) NOT NULL,
    PRIMARY KEY (batch_code)
);

CREATE TEMPORARY TABLE tmp_xs18_new_batches (
    batch_code varchar(100) NOT NULL,
    PRIMARY KEY (batch_code)
);

SELECT NOW() AS ts, '01 official March after final run' AS stage;
SELECT 'official_after_final_run' AS side,
       COUNT(*) AS cnt,
       ROUND(SUM(IFNULL(weight, 0)), 6) AS sum_weight,
       MIN(data_date) AS min_date,
       MAX(data_date) AS max_date
FROM ads_gx_xs_18_detail
WHERE data_date >= @m_start
  AND data_date < @m_end;

SELECT silicon_steel_product_category_name, channel, COUNT(*) AS cnt, ROUND(SUM(IFNULL(weight, 0)), 6) AS sum_weight
FROM ads_gx_xs_18_detail
WHERE data_date >= @m_start
  AND data_date < @m_end
GROUP BY silicon_steel_product_category_name, channel
ORDER BY silicon_steel_product_category_name, channel;

SELECT NOW() AS ts, '02 build March helpers' AS stage;
CREATE TEMPORARY TABLE tmp_xs18_sdo_march AS
SELECT sales_delivery_order_code,
       cust_code,
       cust_abbr,
       tenant_id,
       approver_date,
       created_time
FROM ods_crm_sa_sales_delivery_order
WHERE tenant_id IN (92, 108)
  AND (
      (approver_date >= @m_start AND approver_date < @m_end)
      OR
      (approver_date IS NULL AND created_time >= @m_start AND created_time < @m_end)
  );

CREATE INDEX idx_tmp_xs18_sdo_march_code ON tmp_xs18_sdo_march (sales_delivery_order_code);

CREATE TEMPORARY TABLE tmp_xs18_sdod_march AS
SELECT d.sales_delivery_order_code,
       d.wh_code,
       d.batch_code,
       d.weight,
       d.amount_in_tax,
       d.contract_code,
       d.receive_warehouse,
       d.sales_delivery_order_date,
       d.sales_order_detail_code,
       d.prod_spec3,
       d.sku_name
FROM ods_crm_sa_sales_delivery_order_detail d
JOIN tmp_xs18_sdo_march s
    ON d.sales_delivery_order_code = s.sales_delivery_order_code
WHERE d.status = 1
  AND d.sales_delivery_order_detail_state IN ('50', '20', '30')
  AND d.created_time >= @full_start;

CREATE INDEX idx_tmp_xs18_sdod_march_batch ON tmp_xs18_sdod_march (batch_code);
CREATE INDEX idx_tmp_xs18_sdod_march_contract ON tmp_xs18_sdod_march (contract_code);
CREATE INDEX idx_tmp_xs18_sdod_march_order_detail ON tmp_xs18_sdod_march (sales_order_detail_code, batch_code, prod_spec3);
CREATE INDEX idx_tmp_xs18_sdod_march_sku ON tmp_xs18_sdod_march (sku_name);

SELECT 'march_sales_headers' AS metric, COUNT(*) AS cnt FROM tmp_xs18_sdo_march
UNION ALL
SELECT 'march_sales_details', COUNT(*) FROM tmp_xs18_sdod_march;

SELECT NOW() AS ts, '03 build restricted maps' AS stage;
CREATE TEMPORARY TABLE tmp_xs18_sdd_place_old AS
SELECT DISTINCT d.contract_code, d.receive_warehouse
FROM ods_crm_sa_sales_delivery_order_detail d
JOIN (
    SELECT DISTINCT contract_code FROM tmp_xs18_sdod_march WHERE contract_code IS NOT NULL
) c ON d.contract_code = c.contract_code
WHERE d.tenant_id = 92
  AND d.receive_warehouse IS NOT NULL
  AND d.status = 1;

CREATE INDEX idx_tmp_xs18_sdd_place_old ON tmp_xs18_sdd_place_old (contract_code);

CREATE TEMPORARY TABLE tmp_xs18_sdd_place_new AS
SELECT d.contract_code, MAX(d.receive_warehouse) AS receive_warehouse
FROM ods_crm_sa_sales_delivery_order_detail d
JOIN (
    SELECT DISTINCT contract_code FROM tmp_xs18_sdod_march WHERE contract_code IS NOT NULL
) c ON d.contract_code = c.contract_code
WHERE d.tenant_id = 92
  AND d.receive_warehouse IS NOT NULL
  AND d.status = 1
GROUP BY d.contract_code;

CREATE INDEX idx_tmp_xs18_sdd_place_new ON tmp_xs18_sdd_place_new (contract_code);

CREATE TEMPORARY TABLE tmp_xs18_pd_place_old AS
SELECT DISTINCT p.source_code, p.receive_warehouse
FROM ods_crm_sa_pending_delivery p
JOIN (
    SELECT DISTINCT sales_delivery_order_code AS source_code FROM tmp_xs18_sdo_march
) s ON p.source_code = s.source_code
WHERE p.tenant_id IN (92, 108);

CREATE INDEX idx_tmp_xs18_pd_place_old ON tmp_xs18_pd_place_old (source_code);

CREATE TEMPORARY TABLE tmp_xs18_pd_place_new AS
SELECT p.source_code, MAX(p.receive_warehouse) AS receive_warehouse
FROM ods_crm_sa_pending_delivery p
JOIN (
    SELECT DISTINCT sales_delivery_order_code AS source_code FROM tmp_xs18_sdo_march
) s ON p.source_code = s.source_code
WHERE p.tenant_id IN (92, 108)
  AND p.receive_warehouse IS NOT NULL
GROUP BY p.source_code;

CREATE INDEX idx_tmp_xs18_pd_place_new ON tmp_xs18_pd_place_new (source_code);

CREATE TEMPORARY TABLE tmp_xs18_channel_new AS
SELECT attribute2, MAX(attribute1) AS attribute1
FROM with_attr_value
WHERE scene = 'bi_gx_xs_012_detail_attr1_2'
GROUP BY attribute2;

CREATE INDEX idx_tmp_xs18_channel_new ON tmp_xs18_channel_new (attribute2);

SELECT NOW() AS ts, '04 old logic, March rows only' AS stage;
INSERT INTO tmp_xs18_old_march_cmp
SELECT 'transfer' AS source_name,
       si.silicon_steel_product_category_name,
       '湖南宏旺' AS channel,
       ti.batch_code,
       t.transfer_order_code,
       ti.cust_abbr,
       ti.contract_code,
       ti.receive_warehouse AS place,
       ti.quantity AS weight,
       DATE(t.transfer_order_date) AS data_date
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
WHERE t.transfer_order_state IN (20, 40)
  AND t.status = 1
  AND t.tenant_id IN (92, 108)
  AND t.transfer_order_date >= @m_start
  AND t.transfer_order_date < @m_end;

UPDATE tmp_xs18_old_march_cmp a
JOIN tmp_xs18_sdd_place_old b
    ON a.contract_code = b.contract_code
SET a.place = b.receive_warehouse
WHERE a.place IS NULL;

UPDATE tmp_xs18_old_march_cmp a
JOIN tmp_xs18_sdd_place_old b
    ON a.contract_code = b.contract_code
SET a.place = b.receive_warehouse
WHERE a.place <> b.receive_warehouse;

INSERT IGNORE INTO tmp_xs18_old_batches (batch_code)
SELECT DISTINCT batch_code FROM tmp_xs18_old_march_cmp WHERE batch_code IS NOT NULL;

INSERT INTO tmp_xs18_old_march_cmp
SELECT 'sales_silicon' AS source_name,
       si.silicon_steel_product_category_name,
       '湖南宏旺' AS channel,
       sdod.batch_code,
       sdo.sales_delivery_order_code,
       sdo.cust_abbr,
       sdod.contract_code,
       sdod.receive_warehouse AS place,
       sdod.weight,
       DATE(IFNULL(sdo.approver_date, sdo.created_time)) AS data_date
FROM tmp_xs18_sdo_march sdo
JOIN tmp_xs18_sdod_march sdod
    ON sdo.sales_delivery_order_code = sdod.sales_delivery_order_code
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
LEFT JOIN tmp_xs18_old_batches old_batch
    ON old_batch.batch_code = sdod.batch_code
WHERE old_batch.batch_code IS NULL;

INSERT IGNORE INTO tmp_xs18_old_batches (batch_code)
SELECT DISTINCT batch_code FROM tmp_xs18_old_march_cmp WHERE batch_code IS NOT NULL;

INSERT INTO tmp_xs18_old_march_cmp
SELECT 'sales_iron' AS source_name,
       '铁心' AS silicon_steel_product_category_name,
       '湖南宏旺' AS channel,
       sdod.batch_code,
       sdo.sales_delivery_order_code,
       sdo.cust_abbr,
       sdod.contract_code,
       sdod.receive_warehouse AS place,
       sdod.weight,
       DATE(IFNULL(sdo.approver_date, sdo.created_time)) AS data_date
FROM tmp_xs18_sdo_march sdo
JOIN tmp_xs18_sdod_march sdod
    ON sdo.sales_delivery_order_code = sdod.sales_delivery_order_code
JOIN with_attr_value av1
    ON sdod.sku_name = av1.attribute1
   AND av1.scene = 'bi_gx_xs_017_STOCK_NAME'
LEFT JOIN ods_mes_wms_batch_info bi
    ON sdod.batch_code = bi.batch_code
   AND bi.status = 1
   AND sdo.tenant_id = bi.tenant_id
LEFT JOIN ods_crm_sv_return_detail srd
    ON sdod.sales_order_detail_code = srd.sales_order_detail_code
   AND sdod.batch_code = srd.batch_code
   AND sdod.prod_spec3 = srd.prod_spec3
   AND srd.return_detail_status IN (20, 30, 40)
LEFT JOIN tmp_xs18_old_batches old_batch
    ON old_batch.batch_code = sdod.batch_code
WHERE sdo.sales_delivery_order_code NOT IN ('FHD202501031919', 'FHD202503290024')
  AND old_batch.batch_code IS NULL;

UPDATE tmp_xs18_old_march_cmp a
JOIN tmp_xs18_pd_place_old b
    ON a.transfer_order_code = b.source_code
SET a.place = b.receive_warehouse
WHERE a.place <> b.receive_warehouse OR a.place IS NULL;

UPDATE tmp_xs18_old_march_cmp a
JOIN with_attr_value b
    ON a.cust_abbr = b.attribute2
   AND b.scene = 'bi_gx_xs_012_detail_attr1_2'
SET a.channel = b.attribute1
WHERE a.cust_abbr <> '佛山湘宏财';

SELECT NOW() AS ts, '05 new logic, March rows only' AS stage;
INSERT INTO tmp_xs18_new_march_cmp
SELECT 'transfer' AS source_name,
       si.silicon_steel_product_category_name,
       CASE WHEN ti.cust_abbr = '佛山湘宏财' THEN '湖南宏旺'
            ELSE COALESCE(ch.attribute1, '湖南宏旺') END AS channel,
       ti.batch_code,
       t.transfer_order_code,
       ti.cust_abbr,
       ti.contract_code,
       COALESCE(sdd.receive_warehouse, ti.receive_warehouse) AS place,
       ti.quantity AS weight,
       DATE(COALESCE(t.transfer_order_date, t.approve_date)) AS data_date
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
LEFT JOIN tmp_xs18_sdd_place_new sdd
    ON ti.contract_code = sdd.contract_code
LEFT JOIN tmp_xs18_channel_new ch
    ON ti.cust_abbr = ch.attribute2
WHERE t.transfer_order_state IN (20, 40)
  AND t.status = 1
  AND t.tenant_id IN (92, 108)
  AND (
      (t.transfer_order_date IS NOT NULL AND t.transfer_order_date >= @m_start AND t.transfer_order_date < @m_end)
      OR
      (t.transfer_order_date IS NULL AND t.approve_date >= @m_start AND t.approve_date < @m_end)
  );

INSERT IGNORE INTO tmp_xs18_new_batches (batch_code)
SELECT DISTINCT batch_code FROM tmp_xs18_new_march_cmp WHERE batch_code IS NOT NULL;

INSERT INTO tmp_xs18_new_march_cmp
SELECT 'sales_silicon' AS source_name,
       si.silicon_steel_product_category_name,
       CASE WHEN sdo.cust_abbr = '佛山湘宏财' THEN '湖南宏旺'
            ELSE COALESCE(ch.attribute1, '湖南宏旺') END AS channel,
       sdod.batch_code,
       sdo.sales_delivery_order_code,
       sdo.cust_abbr,
       sdod.contract_code,
       COALESCE(pd.receive_warehouse, sdd.receive_warehouse, sdod.receive_warehouse) AS place,
       sdod.weight,
       DATE(IFNULL(sdo.approver_date, sdo.created_time)) AS data_date
FROM tmp_xs18_sdo_march sdo
JOIN tmp_xs18_sdod_march sdod
    ON sdo.sales_delivery_order_code = sdod.sales_delivery_order_code
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
LEFT JOIN tmp_xs18_sdd_place_new sdd
    ON sdod.contract_code = sdd.contract_code
LEFT JOIN tmp_xs18_pd_place_new pd
    ON sdo.sales_delivery_order_code = pd.source_code
LEFT JOIN tmp_xs18_channel_new ch
    ON sdo.cust_abbr = ch.attribute2
LEFT JOIN tmp_xs18_new_batches new_batch
    ON new_batch.batch_code = sdod.batch_code
WHERE new_batch.batch_code IS NULL;

INSERT IGNORE INTO tmp_xs18_new_batches (batch_code)
SELECT DISTINCT batch_code FROM tmp_xs18_new_march_cmp WHERE batch_code IS NOT NULL;

INSERT INTO tmp_xs18_new_march_cmp
SELECT 'sales_iron' AS source_name,
       '铁心' AS silicon_steel_product_category_name,
       CASE WHEN sdo.cust_abbr = '佛山湘宏财' THEN '湖南宏旺'
            ELSE COALESCE(ch.attribute1, '湖南宏旺') END AS channel,
       sdod.batch_code,
       sdo.sales_delivery_order_code,
       sdo.cust_abbr,
       sdod.contract_code,
       COALESCE(pd.receive_warehouse, sdd.receive_warehouse, sdod.receive_warehouse) AS place,
       sdod.weight,
       DATE(IFNULL(sdo.approver_date, sdo.created_time)) AS data_date
FROM tmp_xs18_sdo_march sdo
JOIN tmp_xs18_sdod_march sdod
    ON sdo.sales_delivery_order_code = sdod.sales_delivery_order_code
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
LEFT JOIN tmp_xs18_sdd_place_new sdd
    ON sdod.contract_code = sdd.contract_code
LEFT JOIN tmp_xs18_pd_place_new pd
    ON sdo.sales_delivery_order_code = pd.source_code
LEFT JOIN tmp_xs18_channel_new ch
    ON sdo.cust_abbr = ch.attribute2
LEFT JOIN tmp_xs18_new_batches new_batch
    ON new_batch.batch_code = sdod.batch_code
WHERE sdo.sales_delivery_order_code NOT IN ('FHD202501031919', 'FHD202503290024')
  AND new_batch.batch_code IS NULL;

SELECT NOW() AS ts, '06 summary compare' AS stage;
SELECT 'old_march_only' AS side,
       COUNT(*) AS cnt,
       ROUND(SUM(IFNULL(weight, 0)), 6) AS sum_weight,
       MIN(data_date) AS min_date,
       MAX(data_date) AS max_date
FROM tmp_xs18_old_march_cmp
UNION ALL
SELECT 'new_march_only',
       COUNT(*),
       ROUND(SUM(IFNULL(weight, 0)), 6),
       MIN(data_date),
       MAX(data_date)
FROM tmp_xs18_new_march_cmp
UNION ALL
SELECT 'official_after_final_run',
       COUNT(*),
       ROUND(SUM(IFNULL(weight, 0)), 6),
       MIN(data_date),
       MAX(data_date)
FROM ads_gx_xs_18_detail
WHERE data_date >= @m_start
  AND data_date < @m_end;

SELECT side, source_name, silicon_steel_product_category_name, channel, cnt, sum_weight
FROM (
    SELECT 'old' AS side, source_name, silicon_steel_product_category_name, channel,
           COUNT(*) AS cnt, ROUND(SUM(IFNULL(weight, 0)), 6) AS sum_weight
    FROM tmp_xs18_old_march_cmp
    GROUP BY source_name, silicon_steel_product_category_name, channel
    UNION ALL
    SELECT 'new' AS side, source_name, silicon_steel_product_category_name, channel,
           COUNT(*) AS cnt, ROUND(SUM(IFNULL(weight, 0)), 6) AS sum_weight
    FROM tmp_xs18_new_march_cmp
    GROUP BY source_name, silicon_steel_product_category_name, channel
) x
ORDER BY source_name, silicon_steel_product_category_name, channel, side;

SELECT 'old_minus_new' AS diff_side,
       o.source_name,
       o.data_date,
       o.batch_code,
       o.transfer_order_code,
       o.silicon_steel_product_category_name,
       o.cust_abbr,
       o.channel,
       o.weight
FROM tmp_xs18_old_march_cmp o
LEFT JOIN tmp_xs18_new_march_cmp n
    ON IFNULL(n.batch_code, '') = IFNULL(o.batch_code, '')
   AND IFNULL(n.transfer_order_code, '') = IFNULL(o.transfer_order_code, '')
   AND IFNULL(n.silicon_steel_product_category_name, '') = IFNULL(o.silicon_steel_product_category_name, '')
   AND IFNULL(n.weight, 0) = IFNULL(o.weight, 0)
WHERE n.batch_code IS NULL
LIMIT 30;

SELECT 'new_minus_old' AS diff_side,
       n.source_name,
       n.data_date,
       n.batch_code,
       n.transfer_order_code,
       n.silicon_steel_product_category_name,
       n.cust_abbr,
       n.channel,
       n.weight
FROM tmp_xs18_new_march_cmp n
LEFT JOIN tmp_xs18_old_march_cmp o
    ON IFNULL(o.batch_code, '') = IFNULL(n.batch_code, '')
   AND IFNULL(o.transfer_order_code, '') = IFNULL(n.transfer_order_code, '')
   AND IFNULL(o.silicon_steel_product_category_name, '') = IFNULL(n.silicon_steel_product_category_name, '')
   AND IFNULL(o.weight, 0) = IFNULL(n.weight, 0)
WHERE o.batch_code IS NULL
LIMIT 30;
