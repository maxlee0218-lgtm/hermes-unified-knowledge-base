-- Read-only inspection for with_attr_value

SHOW CREATE TABLE with_attr_value;
DESC with_attr_value;
SELECT COUNT(*) AS total_rows FROM with_attr_value;

-- scene and tenant distribution
SELECT scene, tenant_id, COUNT(*) AS row_cnt
FROM with_attr_value
GROUP BY scene, tenant_id
ORDER BY scene, tenant_id
LIMIT 200;

-- attr_code not confirmed in current environment
-- SELECT attr_code, COUNT(*) FROM with_attr_value GROUP BY attr_code;

-- attr_name not confirmed in current environment
-- SELECT attr_name, COUNT(*) FROM with_attr_value GROUP BY attr_name;

-- attr_value not confirmed as a direct column in current environment
-- SELECT attr_value, COUNT(*) FROM with_attr_value GROUP BY attr_value;

-- attr_value_code not confirmed in current environment
-- SELECT attr_value_code, COUNT(*) FROM with_attr_value GROUP BY attr_value_code;

-- type not confirmed in current environment
-- SELECT type, COUNT(*) FROM with_attr_value GROUP BY type;

-- current environment has scene / tenant_id / created_time / modified_time
SELECT MIN(created_time) AS min_created_time, MAX(created_time) AS max_created_time
FROM with_attr_value;

SELECT MIN(modified_time) AS min_modified_time, MAX(modified_time) AS max_modified_time
FROM with_attr_value;

-- deleted not confirmed
-- enabled not confirmed
