-- Read-only inspection for dim_date_info

SHOW CREATE TABLE dim_date_info;
DESC dim_date_info;
SELECT COUNT(*) AS total_rows FROM dim_date_info;

-- date_id exists in current environment
SELECT MIN(date_id) AS min_date_id, MAX(date_id) AS max_date_id, COUNT(*) AS row_cnt
FROM dim_date_info;

-- work_date not confirmed in current environment
-- SELECT MIN(work_date), MAX(work_date), COUNT(*) FROM dim_date_info;

-- dt not confirmed in current environment
-- SELECT MIN(dt), MAX(dt), COUNT(*) FROM dim_date_info;

EXPLAIN
SELECT *
FROM dim_date_info
WHERE date_id BETWEEN CURRENT_DATE - INTERVAL 35 DAY AND CURRENT_DATE;
