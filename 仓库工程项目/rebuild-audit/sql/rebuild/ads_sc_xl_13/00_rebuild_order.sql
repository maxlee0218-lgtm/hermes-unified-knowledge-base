-- READ-ONLY blueprint
-- This file is intentionally non-destructive.
-- It records the target build order and the inspection queries to validate each stage.

SELECT '01_process1.sql' AS step_file, 'dwd_mes_mm_task_group_output -> ads_sc_xl_13_process1_local' AS step_name
UNION ALL
SELECT '02_defined.sql', 'ads_sc_xl_13_process1_local -> ads_sc_xl_13_defined_local'
UNION ALL
SELECT '03_defined_manuf_line_name.sql', 'ads_sc_xl_13_defined_local -> ads_sc_xl_13_defined_manuf_line_name_local'
UNION ALL
SELECT '04_combined.sql', 'defined_manuf_line_name_local + support chains -> combined_local'
UNION ALL
SELECT '05_combined_001.sql', 'combined_local -> _001_local'
UNION ALL
SELECT '06_combined_002.sql', 'combined_local -> _002_local';
