CREATE DATABASE IF NOT EXISTS dw_raw DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS dw_ods DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS dw_dwd DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS dw_dws DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

USE dw_raw;

CREATE TABLE IF NOT EXISTS raw_hmes_mm_task_prod_actual (
  actual_id bigint NOT NULL COMMENT '源主键',
  task_inst_id bigint DEFAULT NULL COMMENT '任务标识',
  batch_code varchar(50) DEFAULT NULL COMMENT '批号',
  in_batch_code varchar(50) DEFAULT NULL COMMENT '来料批号',
  sku_code varchar(50) DEFAULT NULL COMMENT 'SKU编码',
  tenant_id bigint NOT NULL COMMENT '租户标识',
  output_time datetime DEFAULT NULL COMMENT '产出时间',
  status tinyint DEFAULT NULL COMMENT '状态',
  weight decimal(18,2) DEFAULT NULL COMMENT '重量',
  net_weight decimal(18,2) DEFAULT NULL COMMENT '净重',
  quantity decimal(18,4) DEFAULT NULL COMMENT '数量',
  yield_rate decimal(18,2) DEFAULT NULL COMMENT '成材率',
  loss_amount decimal(18,2) DEFAULT NULL COMMENT '损失金额',
  markup_amount decimal(18,2) DEFAULT NULL COMMENT '加价金额',
  machine_code varchar(50) DEFAULT NULL COMMENT '机台编码',
  prod_wh_code varchar(30) DEFAULT NULL COMMENT '仓库编码',
  quality varchar(500) DEFAULT NULL COMMENT '品质信息',
  is_last_actual tinyint DEFAULT NULL COMMENT '是否最终实绩',
  r_modified_time datetime DEFAULT NULL COMMENT '源记录修改时间',
  created_time datetime DEFAULT NULL COMMENT '源创建时间',
  modified_time datetime DEFAULT NULL COMMENT '源修改时间',
  etl_batch_id varchar(64) NOT NULL COMMENT '平台批次号',
  etl_load_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '落地时间',
  etl_source_system varchar(32) NOT NULL DEFAULT 'hmes' COMMENT '源系统',
  etl_is_deleted tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (actual_id, etl_batch_id),
  KEY idx_r_modified_time (r_modified_time),
  KEY idx_etl_load_time (etl_load_time),
  KEY idx_tenant_output_time (tenant_id, output_time)
) COMMENT='RAW层：HMES生产实绩原始落地';

USE dw_ods;

CREATE TABLE IF NOT EXISTS ods_prod_actual_i (
  actual_id bigint NOT NULL COMMENT '业务主键',
  biz_date date NOT NULL COMMENT '业务日期',
  biz_time datetime DEFAULT NULL COMMENT '业务时间',
  tenant_id bigint NOT NULL COMMENT '租户标识',
  task_inst_id bigint DEFAULT NULL COMMENT '任务标识',
  batch_code varchar(50) DEFAULT NULL COMMENT '批号',
  in_batch_code varchar(50) DEFAULT NULL COMMENT '来料批号',
  sku_code varchar(50) DEFAULT NULL COMMENT 'SKU编码',
  machine_code varchar(50) DEFAULT NULL COMMENT '机台编码',
  prod_wh_code varchar(30) DEFAULT NULL COMMENT '仓库编码',
  weight decimal(18,2) DEFAULT NULL COMMENT '重量',
  net_weight decimal(18,2) DEFAULT NULL COMMENT '净重',
  quantity decimal(18,4) DEFAULT NULL COMMENT '数量',
  yield_rate decimal(18,2) DEFAULT NULL COMMENT '成材率',
  loss_amount decimal(18,2) DEFAULT NULL COMMENT '损失金额',
  markup_amount decimal(18,2) DEFAULT NULL COMMENT '加价金额',
  quality varchar(500) DEFAULT NULL COMMENT '品质信息',
  is_last_actual tinyint DEFAULT NULL COMMENT '是否最终实绩',
  status tinyint DEFAULT NULL COMMENT '状态',
  source_system varchar(32) NOT NULL DEFAULT 'hmes' COMMENT '源系统',
  source_modified_time datetime DEFAULT NULL COMMENT '源修改时间',
  etl_batch_id varchar(64) NOT NULL COMMENT '平台批次号',
  etl_load_time datetime NOT NULL COMMENT '加载时间',
  is_deleted tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  dw_created_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '仓内创建时间',
  dw_modified_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '仓内修改时间',
  PRIMARY KEY (actual_id),
  KEY idx_biz_date (biz_date),
  KEY idx_tenant_machine_date (tenant_id, machine_code, biz_date),
  KEY idx_source_modified_time (source_modified_time)
) COMMENT='ODS层：生产实绩标准化明细'
PARTITION BY RANGE COLUMNS (biz_date) (
  PARTITION p202601 VALUES LESS THAN ('2026-02-01'),
  PARTITION p202602 VALUES LESS THAN ('2026-03-01'),
  PARTITION p202603 VALUES LESS THAN ('2026-04-01'),
  PARTITION p202604 VALUES LESS THAN ('2026-05-01'),
  PARTITION pmax VALUES LESS THAN (MAXVALUE)
);

USE dw_dwd;

CREATE TABLE IF NOT EXISTS dwd_prod_actual_di (
  actual_id bigint NOT NULL COMMENT '实绩主键',
  biz_date date NOT NULL COMMENT '业务日期',
  tenant_id bigint NOT NULL COMMENT '租户标识',
  task_inst_id bigint DEFAULT NULL COMMENT '任务标识',
  batch_code varchar(50) DEFAULT NULL COMMENT '批号',
  in_batch_code varchar(50) DEFAULT NULL COMMENT '来料批号',
  sku_code varchar(50) DEFAULT NULL COMMENT 'SKU编码',
  machine_code varchar(50) DEFAULT NULL COMMENT '机台编码',
  machine_name varchar(100) DEFAULT NULL COMMENT '机台名称',
  manuf_line_code varchar(50) DEFAULT NULL COMMENT '产线编码',
  manuf_line_name varchar(100) DEFAULT NULL COMMENT '产线名称',
  operation_code varchar(50) DEFAULT NULL COMMENT '工序编码',
  operation_name varchar(100) DEFAULT NULL COMMENT '工序名称',
  workshop_code varchar(50) DEFAULT NULL COMMENT '车间编码',
  workshop_name varchar(100) DEFAULT NULL COMMENT '车间名称',
  prod_wh_code varchar(30) DEFAULT NULL COMMENT '产出仓库编码',
  weight decimal(18,2) DEFAULT NULL COMMENT '重量',
  net_weight decimal(18,2) DEFAULT NULL COMMENT '净重',
  quantity decimal(18,4) DEFAULT NULL COMMENT '数量',
  yield_rate decimal(18,2) DEFAULT NULL COMMENT '成材率',
  loss_amount decimal(18,2) DEFAULT NULL COMMENT '损失金额',
  markup_amount decimal(18,2) DEFAULT NULL COMMENT '加价金额',
  is_last_actual tinyint DEFAULT NULL COMMENT '是否最终实绩',
  quality_level varchar(64) DEFAULT NULL COMMENT '质量等级抽象',
  valid_flag tinyint NOT NULL DEFAULT 1 COMMENT '是否有效记录',
  source_system varchar(32) NOT NULL DEFAULT 'hmes' COMMENT '源系统',
  etl_batch_id varchar(64) NOT NULL COMMENT '平台批次号',
  etl_load_time datetime NOT NULL COMMENT '加载时间',
  dw_created_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '仓内创建时间',
  dw_modified_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '仓内修改时间',
  PRIMARY KEY (actual_id),
  KEY idx_biz_date (biz_date),
  KEY idx_tenant_line_date (tenant_id, manuf_line_code, biz_date),
  KEY idx_tenant_machine_date (tenant_id, machine_code, biz_date)
) COMMENT='DWD层：生产实绩事务事实表'
PARTITION BY RANGE COLUMNS (biz_date) (
  PARTITION p202601 VALUES LESS THAN ('2026-02-01'),
  PARTITION p202602 VALUES LESS THAN ('2026-03-01'),
  PARTITION p202603 VALUES LESS THAN ('2026-04-01'),
  PARTITION p202604 VALUES LESS THAN ('2026-05-01'),
  PARTITION pmax VALUES LESS THAN (MAXVALUE)
);

USE dw_dws;

CREATE TABLE IF NOT EXISTS dws_prod_yield_day_machine (
  biz_date date NOT NULL COMMENT '业务日期',
  tenant_id bigint NOT NULL COMMENT '租户标识',
  machine_code varchar(50) NOT NULL COMMENT '机台编码',
  machine_name varchar(100) DEFAULT NULL COMMENT '机台名称',
  manuf_line_code varchar(50) DEFAULT NULL COMMENT '产线编码',
  manuf_line_name varchar(100) DEFAULT NULL COMMENT '产线名称',
  actual_count bigint NOT NULL DEFAULT 0 COMMENT '实绩数',
  output_weight decimal(18,2) NOT NULL DEFAULT 0 COMMENT '产出重量',
  output_net_weight decimal(18,2) NOT NULL DEFAULT 0 COMMENT '产出净重',
  total_loss_amount decimal(18,2) NOT NULL DEFAULT 0 COMMENT '损失金额',
  avg_yield_rate decimal(18,4) DEFAULT NULL COMMENT '平均成材率',
  final_actual_count bigint NOT NULL DEFAULT 0 COMMENT '最终实绩数',
  etl_batch_id varchar(64) NOT NULL COMMENT '平台批次号',
  etl_load_time datetime NOT NULL COMMENT '加载时间',
  dw_created_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '仓内创建时间',
  dw_modified_time datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '仓内修改时间',
  PRIMARY KEY (biz_date, tenant_id, machine_code),
  KEY idx_tenant_line_date (tenant_id, manuf_line_code, biz_date)
) COMMENT='DWS层：按日按机台生产成材率汇总';

INSERT INTO dw_ods.ods_prod_actual_i (
  actual_id,
  biz_date,
  biz_time,
  tenant_id,
  task_inst_id,
  batch_code,
  in_batch_code,
  sku_code,
  machine_code,
  prod_wh_code,
  weight,
  net_weight,
  quantity,
  yield_rate,
  loss_amount,
  markup_amount,
  quality,
  is_last_actual,
  status,
  source_system,
  source_modified_time,
  etl_batch_id,
  etl_load_time,
  is_deleted
)
SELECT
  r.actual_id,
  DATE(COALESCE(r.output_time, r.created_time)) AS biz_date,
  COALESCE(r.output_time, r.created_time) AS biz_time,
  r.tenant_id,
  r.task_inst_id,
  r.batch_code,
  r.in_batch_code,
  r.sku_code,
  r.machine_code,
  r.prod_wh_code,
  r.weight,
  r.net_weight,
  r.quantity,
  r.yield_rate,
  r.loss_amount,
  r.markup_amount,
  r.quality,
  r.is_last_actual,
  r.status,
  r.etl_source_system,
  r.r_modified_time,
  r.etl_batch_id,
  r.etl_load_time,
  r.etl_is_deleted
FROM dw_raw.raw_hmes_mm_task_prod_actual r
WHERE r.etl_batch_id = '${batch_id}'
ON DUPLICATE KEY UPDATE
  biz_date = VALUES(biz_date),
  biz_time = VALUES(biz_time),
  tenant_id = VALUES(tenant_id),
  task_inst_id = VALUES(task_inst_id),
  batch_code = VALUES(batch_code),
  in_batch_code = VALUES(in_batch_code),
  sku_code = VALUES(sku_code),
  machine_code = VALUES(machine_code),
  prod_wh_code = VALUES(prod_wh_code),
  weight = VALUES(weight),
  net_weight = VALUES(net_weight),
  quantity = VALUES(quantity),
  yield_rate = VALUES(yield_rate),
  loss_amount = VALUES(loss_amount),
  markup_amount = VALUES(markup_amount),
  quality = VALUES(quality),
  is_last_actual = VALUES(is_last_actual),
  status = VALUES(status),
  source_modified_time = VALUES(source_modified_time),
  etl_batch_id = VALUES(etl_batch_id),
  etl_load_time = VALUES(etl_load_time),
  is_deleted = VALUES(is_deleted),
  dw_modified_time = CURRENT_TIMESTAMP;

INSERT INTO dw_dwd.dwd_prod_actual_di (
  actual_id,
  biz_date,
  tenant_id,
  task_inst_id,
  batch_code,
  in_batch_code,
  sku_code,
  machine_code,
  machine_name,
  manuf_line_code,
  manuf_line_name,
  operation_code,
  operation_name,
  workshop_code,
  workshop_name,
  prod_wh_code,
  weight,
  net_weight,
  quantity,
  yield_rate,
  loss_amount,
  markup_amount,
  is_last_actual,
  quality_level,
  valid_flag,
  source_system,
  etl_batch_id,
  etl_load_time
)
SELECT
  o.actual_id,
  o.biz_date,
  o.tenant_id,
  o.task_inst_id,
  o.batch_code,
  o.in_batch_code,
  o.sku_code,
  o.machine_code,
  m.machine_name,
  ml.manuf_line_code,
  ml.manuf_line_name,
  op.operation_code,
  op.operation_name,
  ml.workshop_code,
  ml.workshop_name,
  o.prod_wh_code,
  o.weight,
  o.net_weight,
  o.quantity,
  o.yield_rate,
  o.loss_amount,
  o.markup_amount,
  o.is_last_actual,
  CASE
    WHEN o.quality IS NULL OR o.quality = '' THEN 'unknown'
    ELSE 'filled'
  END AS quality_level,
  CASE
    WHEN o.is_deleted = 1 OR o.status <> 1 THEN 0
    ELSE 1
  END AS valid_flag,
  o.source_system,
  o.etl_batch_id,
  o.etl_load_time
FROM dw_ods.ods_prod_actual_i o
LEFT JOIN dw_dwd.dim_machine m
  ON o.machine_code = m.machine_code
LEFT JOIN dw_dwd.dim_manuf_line ml
  ON m.manuf_line_code = ml.manuf_line_code
LEFT JOIN dw_dwd.dim_operation op
  ON m.operation_code = op.operation_code
WHERE o.biz_date BETWEEN '${start_date}' AND '${end_date}'
ON DUPLICATE KEY UPDATE
  biz_date = VALUES(biz_date),
  tenant_id = VALUES(tenant_id),
  task_inst_id = VALUES(task_inst_id),
  batch_code = VALUES(batch_code),
  in_batch_code = VALUES(in_batch_code),
  sku_code = VALUES(sku_code),
  machine_code = VALUES(machine_code),
  machine_name = VALUES(machine_name),
  manuf_line_code = VALUES(manuf_line_code),
  manuf_line_name = VALUES(manuf_line_name),
  operation_code = VALUES(operation_code),
  operation_name = VALUES(operation_name),
  workshop_code = VALUES(workshop_code),
  workshop_name = VALUES(workshop_name),
  prod_wh_code = VALUES(prod_wh_code),
  weight = VALUES(weight),
  net_weight = VALUES(net_weight),
  quantity = VALUES(quantity),
  yield_rate = VALUES(yield_rate),
  loss_amount = VALUES(loss_amount),
  markup_amount = VALUES(markup_amount),
  is_last_actual = VALUES(is_last_actual),
  quality_level = VALUES(quality_level),
  valid_flag = VALUES(valid_flag),
  etl_batch_id = VALUES(etl_batch_id),
  etl_load_time = VALUES(etl_load_time),
  dw_modified_time = CURRENT_TIMESTAMP;

REPLACE INTO dw_dws.dws_prod_yield_day_machine (
  biz_date,
  tenant_id,
  machine_code,
  machine_name,
  manuf_line_code,
  manuf_line_name,
  actual_count,
  output_weight,
  output_net_weight,
  total_loss_amount,
  avg_yield_rate,
  final_actual_count,
  etl_batch_id,
  etl_load_time
)
SELECT
  biz_date,
  tenant_id,
  machine_code,
  MAX(machine_name) AS machine_name,
  MAX(manuf_line_code) AS manuf_line_code,
  MAX(manuf_line_name) AS manuf_line_name,
  COUNT(*) AS actual_count,
  SUM(COALESCE(weight, 0)) AS output_weight,
  SUM(COALESCE(net_weight, 0)) AS output_net_weight,
  SUM(COALESCE(loss_amount, 0)) AS total_loss_amount,
  AVG(CASE WHEN valid_flag = 1 THEN yield_rate END) AS avg_yield_rate,
  SUM(CASE WHEN is_last_actual = 1 THEN 1 ELSE 0 END) AS final_actual_count,
  '${batch_id}' AS etl_batch_id,
  CURRENT_TIMESTAMP AS etl_load_time
FROM dw_dwd.dwd_prod_actual_di
WHERE biz_date BETWEEN '${start_date}' AND '${end_date}'
  AND valid_flag = 1
GROUP BY biz_date, tenant_id, machine_code;

SELECT
  biz_date,
  COUNT(*) AS row_count,
  SUM(CASE WHEN actual_id IS NULL THEN 1 ELSE 0 END) AS null_pk_count,
  SUM(CASE WHEN tenant_id IS NULL THEN 1 ELSE 0 END) AS null_tenant_count,
  SUM(CASE WHEN machine_code IS NULL OR machine_code = '' THEN 1 ELSE 0 END) AS null_machine_count
FROM dw_dwd.dwd_prod_actual_di
WHERE biz_date BETWEEN '${start_date}' AND '${end_date}'
GROUP BY biz_date;
