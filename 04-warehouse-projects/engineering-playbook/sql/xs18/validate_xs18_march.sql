SET @m_start = DATE('2026-03-01');
SET @m_end = DATE('2026-03-02');

DROP TEMPORARY TABLE IF EXISTS tmp_xs18_old_march;
DROP TEMPORARY TABLE IF EXISTS tmp_xs18_old_batches;
DROP TEMPORARY TABLE IF EXISTS tmp_xs18_new_march;
DROP TEMPORARY TABLE IF EXISTS tmp_xs18_new_batches;

CREATE TEMPORARY TABLE tmp_xs18_old_march LIKE ads_gx_xs_18_detail;
CREATE TEMPORARY TABLE tmp_xs18_new_march LIKE ads_gx_xs_18_detail;

CREATE TEMPORARY TABLE tmp_xs18_old_batches (
    batch_code varchar(50) NOT NULL,
    PRIMARY KEY (batch_code)
);

CREATE TEMPORARY TABLE tmp_xs18_new_batches (
    batch_code varchar(50) NOT NULL,
    PRIMARY KEY (batch_code)
);

-- old/current Dolphin logic, limited to March output dates
INSERT INTO tmp_xs18_old_march
SELECT si.silicon_steel_product_category_name,
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
       0.0,
       ww.wh_name,
       '湖南宏旺' AS channel,
       ti.contract_code,
       CASE WHEN DATE(t.transfer_order_date) IS NULL THEN DATE(t.approve_date)
            ELSE DATE(t.transfer_order_date) END AS data_date,
       ti.receive_warehouse
FROM ods_crm_sa_transfer_order t
JOIN ods_crm_sa_transfer_order_detail ti
    ON t.transfer_order_id = ti.transfer_order_id AND ti.status = 1
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
    ON ti.batch_code = bi.batch_code AND bi.status = 1 AND t.tenant_id = bi.tenant_id
JOIN dwd_silicon_steel_surface_info si
    ON bi.surface = si.surface AND si.silicon_steel_product_category_name IS NOT NULL
WHERE t.transfer_order_state IN (20, 40)
  AND t.status = 1
  AND YEAR(t.transfer_order_date) >= '2026'
  AND t.tenant_id IN (92, 108)
  AND (CASE WHEN DATE(t.transfer_order_date) IS NULL THEN DATE(t.approve_date)
            ELSE DATE(t.transfer_order_date) END) >= @m_start
  AND (CASE WHEN DATE(t.transfer_order_date) IS NULL THEN DATE(t.approve_date)
            ELSE DATE(t.transfer_order_date) END) < @m_end;

UPDATE tmp_xs18_old_march a
JOIN (
    SELECT DISTINCT contract_code, receive_warehouse
    FROM ods_crm_sa_sales_delivery_order_detail
    WHERE tenant_id = 92
      AND receive_warehouse IS NOT NULL
      AND status = 1
) b
    ON a.contract_code = b.contract_code
SET a.place = b.receive_warehouse
WHERE a.place IS NULL;

UPDATE tmp_xs18_old_march a
JOIN (
    SELECT DISTINCT contract_code, receive_warehouse
    FROM ods_crm_sa_sales_delivery_order_detail
    WHERE tenant_id = 92
      AND receive_warehouse IS NOT NULL
      AND status = 1
) b
    ON a.contract_code = b.contract_code
SET a.place = b.receive_warehouse
WHERE a.place <> b.receive_warehouse;

INSERT IGNORE INTO tmp_xs18_old_batches (batch_code)
SELECT DISTINCT batch_code FROM tmp_xs18_old_march WHERE batch_code IS NOT NULL;

INSERT INTO tmp_xs18_old_march
SELECT si.silicon_steel_product_category_name,
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
       '',
       '湖南宏旺',
       sdod.contract_code,
       DATE(IFNULL(sdo.approver_date, sdo.created_time)),
       sdod.receive_warehouse
FROM ods_crm_sa_sales_delivery_order sdo
JOIN ods_crm_sa_sales_delivery_order_detail sdod
    ON sdo.sales_delivery_order_code = sdod.sales_delivery_order_code
   AND sdod.status = 1
   AND sdod.sales_delivery_order_detail_state IN ('50', '20', '30')
JOIN ods_mes_wms_batch_info bi
    ON sdod.batch_code = bi.batch_code AND bi.status = 1 AND sdo.tenant_id = bi.tenant_id
JOIN dwd_silicon_steel_surface_info si
    ON bi.surface = si.surface AND si.silicon_steel_product_category_name IS NOT NULL
LEFT JOIN ods_crm_sv_return_detail srd
    ON sdod.sales_order_detail_code = srd.sales_order_detail_code
   AND sdod.batch_code = srd.batch_code
   AND sdod.prod_spec3 = srd.prod_spec3
   AND srd.return_detail_status IN (20, 30, 40)
LEFT JOIN tmp_xs18_old_batches old_batch
    ON old_batch.batch_code = sdod.batch_code
WHERE sdo.tenant_id IN (92, 108)
  AND sdod.created_time >= '2026-01-01'
  AND DATE(IFNULL(sdo.approver_date, sdo.created_time)) >= @m_start
  AND DATE(IFNULL(sdo.approver_date, sdo.created_time)) < @m_end
  AND old_batch.batch_code IS NULL;

INSERT IGNORE INTO tmp_xs18_old_batches (batch_code)
SELECT DISTINCT batch_code FROM tmp_xs18_old_march WHERE batch_code IS NOT NULL;

INSERT INTO tmp_xs18_old_march
SELECT '铁心',
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
       '',
       '湖南宏旺',
       sdod.contract_code,
       DATE(IFNULL(sdo.approver_date, sdo.created_time)),
       sdod.receive_warehouse
FROM ods_crm_sa_sales_delivery_order sdo
JOIN ods_crm_sa_sales_delivery_order_detail sdod
    ON sdo.sales_delivery_order_code = sdod.sales_delivery_order_code
   AND sdod.status = 1
   AND sdod.sales_delivery_order_detail_state IN ('50', '20', '30')
JOIN with_attr_value av1
    ON sdod.sku_name = av1.attribute1
   AND av1.scene = 'bi_gx_xs_017_STOCK_NAME'
LEFT JOIN ods_mes_wms_batch_info bi
    ON sdod.batch_code = bi.batch_code AND bi.status = 1 AND sdo.tenant_id = bi.tenant_id
LEFT JOIN ods_crm_sv_return_detail srd
    ON sdod.sales_order_detail_code = srd.sales_order_detail_code
   AND sdod.batch_code = srd.batch_code
   AND sdod.prod_spec3 = srd.prod_spec3
   AND srd.return_detail_status IN (20, 30, 40)
LEFT JOIN tmp_xs18_old_batches old_batch
    ON old_batch.batch_code = sdod.batch_code
WHERE sdo.tenant_id IN (92, 108)
  AND sdod.created_time >= '2026-01-01'
  AND DATE(IFNULL(sdo.approver_date, sdo.created_time)) >= @m_start
  AND DATE(IFNULL(sdo.approver_date, sdo.created_time)) < @m_end
  AND sdo.sales_delivery_order_code NOT IN ('FHD202501031919', 'FHD202503290024')
  AND old_batch.batch_code IS NULL;

UPDATE tmp_xs18_old_march a
JOIN (
    SELECT DISTINCT source_code, receive_warehouse
    FROM ods_crm_sa_pending_delivery
    WHERE tenant_id IN (92, 108)
) b
    ON a.transfer_order_code = b.source_code
SET a.place = b.receive_warehouse
WHERE a.place <> b.receive_warehouse OR a.place IS NULL;

UPDATE tmp_xs18_old_march a
JOIN with_attr_value b
    ON a.cust_abbr = b.attribute2
   AND b.scene = 'bi_gx_xs_012_detail_attr1_2'
SET a.channel = b.attribute1
WHERE a.cust_abbr <> '佛山湘宏财';

-- new/final optimized logic, limited to March output dates
INSERT INTO tmp_xs18_new_march
SELECT si.silicon_steel_product_category_name,
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
       0.0,
       ww.wh_name,
       CASE WHEN ti.cust_abbr = '佛山湘宏财' THEN '湖南宏旺'
            ELSE COALESCE(ch.attribute1, '湖南宏旺') END AS channel,
       ti.contract_code,
       DATE(COALESCE(t.transfer_order_date, t.approve_date)) AS data_date,
       COALESCE(pd.receive_warehouse, sdd.receive_warehouse, ti.receive_warehouse) AS place
FROM ods_crm_sa_transfer_order t
JOIN ods_crm_sa_transfer_order_detail ti
    ON t.transfer_order_id = ti.transfer_order_id AND ti.status = 1
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
    ON ti.batch_code = bi.batch_code AND bi.status = 1 AND t.tenant_id = bi.tenant_id
JOIN dwd_silicon_steel_surface_info si
    ON bi.surface = si.surface AND si.silicon_steel_product_category_name IS NOT NULL
LEFT JOIN (
    SELECT contract_code, MAX(receive_warehouse) AS receive_warehouse
    FROM ods_crm_sa_sales_delivery_order_detail
    WHERE tenant_id = 92 AND receive_warehouse IS NOT NULL AND status = 1
    GROUP BY contract_code
) sdd ON ti.contract_code = sdd.contract_code
LEFT JOIN (
    SELECT source_code, MAX(receive_warehouse) AS receive_warehouse
    FROM ods_crm_sa_pending_delivery
    WHERE tenant_id IN (92, 108) AND receive_warehouse IS NOT NULL
    GROUP BY source_code
) pd ON t.transfer_order_code = pd.source_code
LEFT JOIN (
    SELECT attribute2, MAX(attribute1) AS attribute1
    FROM with_attr_value
    WHERE scene = 'bi_gx_xs_012_detail_attr1_2'
    GROUP BY attribute2
) ch ON ti.cust_abbr = ch.attribute2
WHERE t.transfer_order_state IN (20, 40)
  AND t.status = 1
  AND t.tenant_id IN (92, 108)
  AND YEAR(t.transfer_order_date) >= '2026'
  AND DATE(COALESCE(t.transfer_order_date, t.approve_date)) >= @m_start
  AND DATE(COALESCE(t.transfer_order_date, t.approve_date)) < @m_end;

INSERT IGNORE INTO tmp_xs18_new_batches (batch_code)
SELECT DISTINCT batch_code FROM tmp_xs18_new_march WHERE batch_code IS NOT NULL;

INSERT INTO tmp_xs18_new_march
SELECT si.silicon_steel_product_category_name,
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
       '',
       CASE WHEN sdo.cust_abbr = '佛山湘宏财' THEN '湖南宏旺'
            ELSE COALESCE(ch.attribute1, '湖南宏旺') END AS channel,
       sdod.contract_code,
       DATE(IFNULL(sdo.approver_date, sdo.created_time)),
       COALESCE(pd.receive_warehouse, sdd.receive_warehouse, sdod.receive_warehouse)
FROM ods_crm_sa_sales_delivery_order sdo
JOIN ods_crm_sa_sales_delivery_order_detail sdod
    ON sdo.sales_delivery_order_code = sdod.sales_delivery_order_code
   AND sdod.status = 1
   AND sdod.sales_delivery_order_detail_state IN ('50', '20', '30')
JOIN ods_mes_wms_batch_info bi
    ON sdod.batch_code = bi.batch_code AND bi.status = 1 AND sdo.tenant_id = bi.tenant_id
JOIN dwd_silicon_steel_surface_info si
    ON bi.surface = si.surface AND si.silicon_steel_product_category_name IS NOT NULL
LEFT JOIN ods_crm_sv_return_detail srd
    ON sdod.sales_order_detail_code = srd.sales_order_detail_code
   AND sdod.batch_code = srd.batch_code
   AND sdod.prod_spec3 = srd.prod_spec3
   AND srd.return_detail_status IN (20, 30, 40)
LEFT JOIN (
    SELECT contract_code, MAX(receive_warehouse) AS receive_warehouse
    FROM ods_crm_sa_sales_delivery_order_detail
    WHERE tenant_id = 92 AND receive_warehouse IS NOT NULL AND status = 1
    GROUP BY contract_code
) sdd ON sdod.contract_code = sdd.contract_code
LEFT JOIN (
    SELECT source_code, MAX(receive_warehouse) AS receive_warehouse
    FROM ods_crm_sa_pending_delivery
    WHERE tenant_id IN (92, 108) AND receive_warehouse IS NOT NULL
    GROUP BY source_code
) pd ON sdo.sales_delivery_order_code = pd.source_code
LEFT JOIN (
    SELECT attribute2, MAX(attribute1) AS attribute1
    FROM with_attr_value
    WHERE scene = 'bi_gx_xs_012_detail_attr1_2'
    GROUP BY attribute2
) ch ON sdo.cust_abbr = ch.attribute2
LEFT JOIN tmp_xs18_new_batches new_batch
    ON new_batch.batch_code = sdod.batch_code
WHERE sdo.tenant_id IN (92, 108)
  AND sdod.created_time >= '2026-01-01'
  AND DATE(IFNULL(sdo.approver_date, sdo.created_time)) >= @m_start
  AND DATE(IFNULL(sdo.approver_date, sdo.created_time)) < @m_end
  AND new_batch.batch_code IS NULL;

INSERT IGNORE INTO tmp_xs18_new_batches (batch_code)
SELECT DISTINCT batch_code FROM tmp_xs18_new_march WHERE batch_code IS NOT NULL;

INSERT INTO tmp_xs18_new_march
SELECT '铁心',
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
       '',
       CASE WHEN sdo.cust_abbr = '佛山湘宏财' THEN '湖南宏旺'
            ELSE COALESCE(ch.attribute1, '湖南宏旺') END AS channel,
       sdod.contract_code,
       DATE(IFNULL(sdo.approver_date, sdo.created_time)),
       COALESCE(pd.receive_warehouse, sdd.receive_warehouse, sdod.receive_warehouse)
FROM ods_crm_sa_sales_delivery_order sdo
JOIN ods_crm_sa_sales_delivery_order_detail sdod
    ON sdo.sales_delivery_order_code = sdod.sales_delivery_order_code
   AND sdod.status = 1
   AND sdod.sales_delivery_order_detail_state IN ('50', '20', '30')
JOIN (
    SELECT DISTINCT attribute1
    FROM with_attr_value
    WHERE scene = 'bi_gx_xs_017_STOCK_NAME'
) av1 ON sdod.sku_name = av1.attribute1
LEFT JOIN ods_mes_wms_batch_info bi
    ON sdod.batch_code = bi.batch_code AND bi.status = 1 AND sdo.tenant_id = bi.tenant_id
LEFT JOIN ods_crm_sv_return_detail srd
    ON sdod.sales_order_detail_code = srd.sales_order_detail_code
   AND sdod.batch_code = srd.batch_code
   AND sdod.prod_spec3 = srd.prod_spec3
   AND srd.return_detail_status IN (20, 30, 40)
LEFT JOIN (
    SELECT contract_code, MAX(receive_warehouse) AS receive_warehouse
    FROM ods_crm_sa_sales_delivery_order_detail
    WHERE tenant_id = 92 AND receive_warehouse IS NOT NULL AND status = 1
    GROUP BY contract_code
) sdd ON sdod.contract_code = sdd.contract_code
LEFT JOIN (
    SELECT source_code, MAX(receive_warehouse) AS receive_warehouse
    FROM ods_crm_sa_pending_delivery
    WHERE tenant_id IN (92, 108) AND receive_warehouse IS NOT NULL
    GROUP BY source_code
) pd ON sdo.sales_delivery_order_code = pd.source_code
LEFT JOIN (
    SELECT attribute2, MAX(attribute1) AS attribute1
    FROM with_attr_value
    WHERE scene = 'bi_gx_xs_012_detail_attr1_2'
    GROUP BY attribute2
) ch ON sdo.cust_abbr = ch.attribute2
LEFT JOIN tmp_xs18_new_batches new_batch
    ON new_batch.batch_code = sdod.batch_code
WHERE sdo.tenant_id IN (92, 108)
  AND sdod.created_time >= '2026-01-01'
  AND DATE(IFNULL(sdo.approver_date, sdo.created_time)) >= @m_start
  AND DATE(IFNULL(sdo.approver_date, sdo.created_time)) < @m_end
  AND sdo.sales_delivery_order_code NOT IN ('FHD202501031919', 'FHD202503290024')
  AND new_batch.batch_code IS NULL;

SELECT 'summary_old' AS side, COUNT(*) cnt, SUM(IFNULL(weight,0)) sum_weight, MIN(data_date) min_date, MAX(data_date) max_date
FROM tmp_xs18_old_march
UNION ALL
SELECT 'summary_new', COUNT(*), SUM(IFNULL(weight,0)), MIN(data_date), MAX(data_date)
FROM tmp_xs18_new_march;

SELECT 'old' AS side, silicon_steel_product_category_name, channel, COUNT(*) cnt, SUM(IFNULL(weight,0)) sum_weight
FROM tmp_xs18_old_march
GROUP BY silicon_steel_product_category_name, channel
UNION ALL
SELECT 'new', silicon_steel_product_category_name, channel, COUNT(*) cnt, SUM(IFNULL(weight,0)) sum_weight
FROM tmp_xs18_new_march
GROUP BY silicon_steel_product_category_name, channel
ORDER BY silicon_steel_product_category_name, channel, side;

SELECT 'old_minus_new' AS diff_side, o.batch_code, o.transfer_order_code, o.silicon_steel_product_category_name, o.channel, o.weight
FROM tmp_xs18_old_march o
LEFT JOIN tmp_xs18_new_march n ON n.batch_code = o.batch_code
WHERE n.batch_code IS NULL
LIMIT 30;

SELECT 'new_minus_old' AS diff_side, n.batch_code, n.transfer_order_code, n.silicon_steel_product_category_name, n.channel, n.weight
FROM tmp_xs18_new_march n
LEFT JOIN tmp_xs18_old_march o ON o.batch_code = n.batch_code
WHERE o.batch_code IS NULL
LIMIT 30;
