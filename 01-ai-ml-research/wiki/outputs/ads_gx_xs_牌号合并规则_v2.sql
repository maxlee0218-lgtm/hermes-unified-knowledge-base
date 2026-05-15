-- 牌号合并规则 V2（只改 surface_number 显示，不动其他字段）
-- 规则：
-- 18、20厚度：90-120 合并显示为 "90-120"
-- 23厚度：95-120 合并显示为 "95-120"
-- 27厚度：105-120 合并显示为 "105-120"
-- 30厚度：110-120 合并显示为 "110-120"
-- 其他：保持原样

SELECT 
    attr1,
    surface_thickness,
    CASE 
        WHEN surface_thickness IN ('18', '20') 
             AND CAST(surface_number AS UNSIGNED) BETWEEN 90 AND 120 THEN '90-120'
        WHEN surface_thickness = '23' 
             AND CAST(surface_number AS UNSIGNED) BETWEEN 95 AND 120 THEN '95-120'
        WHEN surface_thickness = '27' 
             AND CAST(surface_number AS UNSIGNED) BETWEEN 105 AND 120 THEN '105-120'
        WHEN surface_thickness = '30' 
             AND CAST(surface_number AS UNSIGNED) BETWEEN 110 AND 120 THEN '110-120'
        ELSE surface_number
    END AS surface_number,
    qx_a_weight,
    qx_b_weight,
    qx_c_weight,
    qx_d_weight,
    qx_weight,
    data_date,
    sync_time,
    rk,
    rk1,
    ajwjl
FROM (
    -- 历史数据
    SELECT * FROM ads_gx_xs_20_03
    WHERE data_date != CURRENT_DATE
      AND (qx_a_weight IS NOT NULL OR qx_b_weight IS NOT NULL OR qx_c_weight IS NOT NULL OR ajwjl IS NOT NULL)
    
    UNION ALL
    
    -- 当天数据
    SELECT * FROM ads_gx_xs_04_03
    WHERE data_date = CURRENT_DATE
      AND (qx_a_weight IS NOT NULL OR qx_b_weight IS NOT NULL OR qx_c_weight IS NOT NULL OR ajwjl IS NOT NULL)
) a
ORDER BY attr1, surface_thickness, surface_number;
