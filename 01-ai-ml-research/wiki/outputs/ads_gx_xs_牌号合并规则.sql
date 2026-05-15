-- 牌号合并规则 V2（CTE 版本）

WITH merged_data AS (
    SELECT 
        attr1,
        surface_thickness,
        surface_number,
        qx_a_weight,
        qx_b_weight,
        qx_c_weight,
        qx_d_weight,
        qx_weight,
        ajwjl,
        -- 合并规则
        CASE 
            -- 18、20厚度：90-120 合并
            WHEN surface_thickness IN ('18', '20') 
                 AND CAST(surface_number AS UNSIGNED) BETWEEN 90 AND 120 THEN
                CONCAT(surface_thickness, '厚度-90~120')
            
            -- 23厚度：95-120 合并
            WHEN surface_thickness = '23' 
                 AND CAST(surface_number AS UNSIGNED) BETWEEN 95 AND 120 THEN
                '23厚度-95~120'
            
            -- 27厚度：105-120 合并
            WHEN surface_thickness = '27' 
                 AND CAST(surface_number AS UNSIGNED) BETWEEN 105 AND 120 THEN
                '27厚度-105~120'
            
            -- 30厚度：110-120 合并
            WHEN surface_thickness = '30' 
                 AND CAST(surface_number AS UNSIGNED) BETWEEN 110 AND 120 THEN
                '30厚度-110~120'
            
            -- 其他：单独显示
            ELSE CONCAT(surface_thickness, '厚度-', surface_number)
        END AS display_group
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
)

SELECT 
    display_group,
    attr1,
    surface_thickness,
    surface_number,
    SUM(qx_a_weight) as qx_a_weight,
    SUM(qx_b_weight) as qx_b_weight,
    SUM(qx_c_weight) as qx_c_weight,
    SUM(qx_d_weight) as qx_d_weight,
    SUM(qx_weight) as qx_weight,
    SUM(ajwjl) as ajwjl,
    COUNT(*) as record_count
FROM merged_data
GROUP BY display_group, attr1, surface_thickness, surface_number
ORDER BY attr1, surface_thickness, surface_number;
