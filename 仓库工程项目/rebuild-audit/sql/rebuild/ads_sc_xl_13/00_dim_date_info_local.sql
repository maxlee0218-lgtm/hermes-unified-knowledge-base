-- READ-ONLY blueprint for dim_date_info_local
-- This file does not create or write any table.

WITH date_spine AS (
  SELECT
    date_id
  FROM dim_date_info
  WHERE date_id BETWEEN CURRENT_DATE - INTERVAL 35 DAY AND CURRENT_DATE
),
date_range_check AS (
  SELECT
    MIN(date_id) AS min_date_id,
    MAX(date_id) AS max_date_id,
    COUNT(*) AS date_cnt
  FROM date_spine
),
date_continuity_check AS (
  SELECT
    date_id,
    LAG(date_id) OVER (ORDER BY date_id) AS prev_date_id,
    DATEDIFF(date_id, LAG(date_id) OVER (ORDER BY date_id)) AS day_gap
  FROM date_spine
)
SELECT *
FROM date_spine
ORDER BY date_id;

-- Optional diagnostics:
-- SELECT * FROM date_range_check;
-- SELECT * FROM date_continuity_check WHERE day_gap IS NOT NULL AND day_gap <> 1;
