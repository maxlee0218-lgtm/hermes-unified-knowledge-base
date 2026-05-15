-- Read-only inspection for support chains

SHOW CREATE TABLE with_attr_value;
DESC with_attr_value;
SELECT scene, COUNT(*) AS row_cnt
FROM with_attr_value
WHERE scene LIKE 'BI-SC-KC-013%'
   OR scene LIKE 'BI-SC-XL-013%'
GROUP BY scene
ORDER BY scene;

SHOW CREATE TABLE with_result_confirm;
DESC with_result_confirm;
SELECT report_id, COUNT(*) AS row_cnt
FROM with_result_confirm
WHERE result_cat = 'REPORT_BUSINESS_DATA'
  AND report_id IN ('237', '239', '543')
GROUP BY report_id
ORDER BY report_id;

SHOW CREATE TABLE dim_date_info;
DESC dim_date_info;
SELECT COUNT(*) AS row_cnt, MIN(date_id) AS min_date_id, MAX(date_id) AS max_date_id
FROM dim_date_info;

SHOW CREATE TABLE ads_sc_xl_01;
DESC ads_sc_xl_01;
SELECT COUNT(*) AS row_cnt, MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date
FROM ads_sc_xl_01;

SHOW CREATE TABLE dwd_silicon_steel_surface_info;
DESC dwd_silicon_steel_surface_info;
SELECT COUNT(*) AS row_cnt
FROM dwd_silicon_steel_surface_info;

SHOW CREATE TABLE ods_mes_mdm_tenant;
DESC ods_mes_mdm_tenant;
SELECT COUNT(*) AS row_cnt
FROM ods_mes_mdm_tenant;

SHOW CREATE TABLE dim_ums_tenant;
DESC dim_ums_tenant;
SELECT COUNT(*) AS row_cnt
FROM dim_ums_tenant;
