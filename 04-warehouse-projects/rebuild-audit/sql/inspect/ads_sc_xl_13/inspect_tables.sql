-- Read-only inspection for ADS_SC_XL_13 related tables

SHOW CREATE TABLE ads_sc_xl_13_defined_manuf_line_name_combined_001;
DESC ads_sc_xl_13_defined_manuf_line_name_combined_001;
SELECT COUNT(*) AS total_rows, MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date FROM ads_sc_xl_13_defined_manuf_line_name_combined_001;

SHOW CREATE TABLE ads_sc_xl_13_defined_manuf_line_name_combined_002;
DESC ads_sc_xl_13_defined_manuf_line_name_combined_002;
SELECT COUNT(*) AS total_rows, MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date, SUM(day_weight) AS sum_day_weight FROM ads_sc_xl_13_defined_manuf_line_name_combined_002;

SHOW CREATE TABLE ads_sc_xl_13_defined_manuf_line_name_combined;
DESC ads_sc_xl_13_defined_manuf_line_name_combined;
SELECT COUNT(*) AS total_rows, MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date, SUM(day_weight) AS sum_day_weight FROM ads_sc_xl_13_defined_manuf_line_name_combined;

SHOW CREATE TABLE ads_sc_xl_13_defined_manuf_line_name;
DESC ads_sc_xl_13_defined_manuf_line_name;
SELECT COUNT(*) AS total_rows, MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date FROM ads_sc_xl_13_defined_manuf_line_name;

SHOW CREATE TABLE ads_sc_xl_13_defined;
DESC ads_sc_xl_13_defined;
SELECT COUNT(*) AS total_rows, MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date FROM ads_sc_xl_13_defined;

SHOW CREATE TABLE ads_sc_xl_13_process1;
DESC ads_sc_xl_13_process1;
SELECT COUNT(*) AS total_rows, MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date FROM ads_sc_xl_13_process1;

SHOW CREATE TABLE dwd_mes_mm_task_group_output;
DESC dwd_mes_mm_task_group_output;
SELECT COUNT(*) AS total_rows, MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date FROM dwd_mes_mm_task_group_output;

SHOW CREATE TABLE ads_sc_xl_01;
DESC ads_sc_xl_01;
SELECT COUNT(*) AS total_rows, MIN(data_date) AS min_data_date, MAX(data_date) AS max_data_date FROM ads_sc_xl_01;

SHOW CREATE TABLE dim_date_info;
DESC dim_date_info;
SELECT COUNT(*) AS total_rows, MIN(date_id) AS min_date_id, MAX(date_id) AS max_date_id FROM dim_date_info;
-- work_date / dt are not confirmed columns in current environment.

SHOW CREATE TABLE dwd_silicon_steel_surface_info;
DESC dwd_silicon_steel_surface_info;
SELECT COUNT(*) AS total_rows FROM dwd_silicon_steel_surface_info;

SHOW CREATE TABLE ods_mes_sys_attr_value;
DESC ods_mes_sys_attr_value;
SELECT COUNT(*) AS total_rows FROM ods_mes_sys_attr_value;

SHOW CREATE TABLE ods_mes_mdm_tenant;
DESC ods_mes_mdm_tenant;
SELECT COUNT(*) AS total_rows, MIN(created_time) AS min_created_time, MAX(created_time) AS max_created_time FROM ods_mes_mdm_tenant;

SHOW CREATE TABLE dim_ums_tenant;
DESC dim_ums_tenant;
SELECT COUNT(*) AS total_rows, MIN(created_time) AS min_created_time, MAX(created_time) AS max_created_time FROM dim_ums_tenant;

SHOW CREATE TABLE ods_mes_ums_tenant;
DESC ods_mes_ums_tenant;
SELECT COUNT(*) AS total_rows, MIN(created_time) AS min_created_time, MAX(created_time) AS max_created_time FROM ods_mes_ums_tenant;

SHOW CREATE TABLE ods_fair_ums_tenant;
DESC ods_fair_ums_tenant;
SELECT COUNT(*) AS total_rows, MIN(created_time) AS min_created_time, MAX(created_time) AS max_created_time FROM ods_fair_ums_tenant;
