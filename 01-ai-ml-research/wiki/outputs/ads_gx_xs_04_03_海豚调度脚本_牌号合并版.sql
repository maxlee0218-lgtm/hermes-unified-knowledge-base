START TRANSACTION;

DELETE FROM with_attr_value
WHERE scene = 'BI_GX_XS_006_WJ_CONTRACT_DETAIL';

INSERT INTO with_attr_value (
    tenant_id, scene,
    attribute1, attribute2, attribute3, attribute4, attribute5,
    attribute6, attribute7, attribute8, attribute9
)
SELECT
    sc.tenant_id,
    'BI_GX_XS_006_WJ_CONTRACT_DETAIL' AS scene,
    sc.contract_code,
    scd.prod_spec2 AS surface,
    a.surface_thickness,
    a.surface_number,
    sc.contract_month,
    ROUND(SUM(CASE
        WHEN scd.unit_code = '002' THEN scd.weight / 1000
        WHEN scd.unit_code = '003' THEN scd.weight
        ELSE 0
    END), 2) AS total_contract_weight,
    ROUND(SUM(CASE
        WHEN scd.unit_code = '002' THEN scd.quantity_allocated / 1000
        WHEN scd.unit_code = '003' THEN scd.quantity_allocated
        ELSE 0
    END), 2) AS quantity_dj,
    ROUND(SUM(CASE
        WHEN scd.unit_code = '002' THEN scd.quantity_unshipped / 1000
        WHEN scd.unit_code = '003' THEN scd.quantity_unshipped
        ELSE 0
    END), 2) AS quantity_sy,
    a.attr1
FROM ods_crm_sa_contract sc
JOIN ods_crm_sa_contract_detail scd
    ON sc.contract_code = scd.contract_code
   AND scd.contract_detail_state IN (30, 50)
   AND scd.status = 1
   AND scd.quantity_unshipped > 0
   AND scd.prod_spec4 = 'A'
JOIN dwd_silicon_steel_surface_info a
    ON scd.prod_spec2 = a.surface
   AND a.silicon_steel_product_category_code = 'QX'
WHERE sc.contract_state IN (30, 50)
  AND sc.contract_type <> '40'
  AND sc.contract_month >= '2025'
  AND sc.status = 1
GROUP BY
    sc.tenant_id,
    sc.contract_code,
    scd.prod_spec2,
    a.surface_thickness,
    a.surface_number,
    sc.contract_month,
    a.attr1;

DELETE FROM ads_gx_xs_04_03;

INSERT INTO ads_gx_xs_04_03 (
    tenant_id, attr1, surface_thickness, surface_number,
    qx_a_weight, qx_b_weight, qx_c_weight, qx_d_weight, qx_weight,
    data_date, sync_time, rk, rk1
)
SELECT
    aa.tenant_id,
    aa.attr1,
    aa.surface_thickness,
    -- 牌号合并规则：只改 surface_number 显示
    CASE 
        WHEN aa.surface_thickness IN ('18', '20') 
             AND CAST(aa.surface_number AS UNSIGNED) BETWEEN 90 AND 120 THEN '90-120'
        WHEN aa.surface_thickness = '23' 
             AND CAST(aa.surface_number AS UNSIGNED) BETWEEN 95 AND 120 THEN '95-120'
        WHEN aa.surface_thickness = '27' 
             AND CAST(aa.surface_number AS UNSIGNED) BETWEEN 105 AND 120 THEN '105-120'
        WHEN aa.surface_thickness = '30' 
             AND CAST(aa.surface_number AS UNSIGNED) BETWEEN 110 AND 120 THEN '110-120'
        ELSE aa.surface_number
    END AS surface_number,
    SUM(CASE WHEN a.grade = 'A' THEN a.weight END) AS qx_a_weight,
    SUM(CASE WHEN a.grade = 'B' THEN a.weight END) AS qx_b_weight,
    SUM(CASE WHEN a.grade = 'C' THEN a.weight END) AS qx_c_weight,
    SUM(CASE WHEN a.grade = 'D' THEN a.weight END) AS qx_d_weight,
    SUM(CASE WHEN a.grade IN ('A', 'B', 'C', 'D') THEN a.weight END) AS qx_weight,
    CURRENT_DATE AS data_date,
    NOW() AS sync_time,
    1 AS rk,
    1 AS rk1
FROM (
    SELECT DISTINCT
        a.tenant_id,
        a.attr1,
        c.surface_thickness,
        c.surface_number
    FROM ads_gx_xs_20_detail a
    JOIN dwd_silicon_steel_surface_info c
        ON a.surface = c.surface
    WHERE a.tenant_id = 92
      AND a.hour = 18
      AND a.data_date >= CURRENT_DATE - INTERVAL 30 DAY

    UNION

    SELECT DISTINCT
        tenant_id,
        attribute9 AS attr1,
        attribute3 AS surface_thickness,
        attribute4 AS surface_number
    FROM with_attr_value
    WHERE scene = 'BI_GX_XS_006_WJ_CONTRACT_DETAIL'
) aa
LEFT JOIN ads_gx_xs_04_detail a
    ON aa.tenant_id = a.tenant_id
   AND aa.attr1 = a.attr1
   AND aa.surface_thickness = a.surface_thickness
   AND aa.surface_number = a.surface_number
GROUP BY
    aa.tenant_id,
    aa.attr1,
    aa.surface_thickness,
    -- 牌号合并规则：GROUP BY 也需要同步修改
    CASE 
        WHEN aa.surface_thickness IN ('18', '20') 
             AND CAST(aa.surface_number AS UNSIGNED) BETWEEN 90 AND 120 THEN '90-120'
        WHEN aa.surface_thickness = '23' 
             AND CAST(aa.surface_number AS UNSIGNED) BETWEEN 95 AND 120 THEN '95-120'
        WHEN aa.surface_thickness = '27' 
             AND CAST(aa.surface_number AS UNSIGNED) BETWEEN 105 AND 120 THEN '105-120'
        WHEN aa.surface_thickness = '30' 
             AND CAST(aa.surface_number AS UNSIGNED) BETWEEN 110 AND 120 THEN '110-120'
        ELSE aa.surface_number
    END;

UPDATE ads_gx_xs_04_03 AS t
JOIN (
    SELECT
        tenant_id,
        attribute9 AS attr1,
        attribute3 AS surface_thickness,
        -- 牌号合并规则：JOIN 条件也需要同步修改
        CASE 
            WHEN attribute3 IN ('18', '20') 
                 AND CAST(attribute4 AS UNSIGNED) BETWEEN 90 AND 120 THEN '90-120'
            WHEN attribute3 = '23' 
                 AND CAST(attribute4 AS UNSIGNED) BETWEEN 95 AND 120 THEN '95-120'
            WHEN attribute3 = '27' 
                 AND CAST(attribute4 AS UNSIGNED) BETWEEN 105 AND 120 THEN '105-120'
            WHEN attribute3 = '30' 
                 AND CAST(attribute4 AS UNSIGNED) BETWEEN 110 AND 120 THEN '110-120'
            ELSE attribute4
        END AS surface_number,
        SUM(attribute8) AS quantity
    FROM with_attr_value
    WHERE scene = 'BI_GX_XS_006_WJ_CONTRACT_DETAIL'
    GROUP BY
        tenant_id,
        attribute9,
        attribute3,
        CASE 
            WHEN attribute3 IN ('18', '20') 
                 AND CAST(attribute4 AS UNSIGNED) BETWEEN 90 AND 120 THEN '90-120'
            WHEN attribute3 = '23' 
                 AND CAST(attribute4 AS UNSIGNED) BETWEEN 95 AND 120 THEN '95-120'
            WHEN attribute3 = '27' 
                 AND CAST(attribute4 AS UNSIGNED) BETWEEN 105 AND 120 THEN '105-120'
            WHEN attribute3 = '30' 
                 AND CAST(attribute4 AS UNSIGNED) BETWEEN 110 AND 120 THEN '110-120'
            ELSE attribute4
        END
) AS src
    ON t.tenant_id = src.tenant_id
   AND t.attr1 = src.attr1
   AND t.surface_thickness = src.surface_thickness
   AND t.surface_number = src.surface_number
SET t.ajwjl = src.quantity;

COMMIT;
