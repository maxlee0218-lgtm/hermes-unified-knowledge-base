# Dolphin Process Chain 18341376834048

- Project: `生产-通用`
- Process name: `生产实绩（dwd_task_prod_actual）`
- Release state: `1`
- Updated at: `2026-03-21 10:16:27`

## Relations

- START -> `生产实绩（dwd_task_prod_actual）`

## Tasks

### `生产实绩（dwd_task_prod_actual）`

- Code: `18341376834049`
- Type: `SQL`
- Upstream nodes: `START`
- Downstream nodes: `END`
- Write tables: `etl_checkpoint`, `etl_run_log`, `dwd_task_prod_actual`, `job_name`, `etl_update_queue`, `task_inst_id`
- Read tables: `etl_checkpoint`, `ods_mes_mm_task_prod_actual`, `ods_mes_mm_qc_defect_data`, `etl_update_queue`, `ods_mes_mm_qc_actual_defect_rela`, `ods_mes_sys_attr_value`, `dwd_task_prod_actual`, `ods_mes_pm_sku`, `ods_mes_mm_order_item_task`, `ods_mes_mm_order_item`, `ods_mes_mm_machine`, `ods_mes_mm_workcenter`, `ods_mes_mdm_tenant`, `ods_mes_wms_batch_info`, `with_attr_value`

```sql
/* =========================================================
   全量/增量通用最终版（checkpoint + run_log + queue）
   目标：dwd_task_prod_actual
   队列：etl_update_queue（通用）
   水位：etl_checkpoint（通用）
   日志：etl_run_log（通用，可看本次消费/剩余）
   兼容：海豚 SQL 节点 executeUpdate（避免裸 SELECT）

/* ====== 0) 参数区（按需改） ====== */
START TRANSACTION;
SET @job := 'dwd_task_prod_actual';
SET @batch_id := REPLACE(UUID(), '-', '');
SET @lock_expire_min := 30;
SET @full_seed := 0;

/* ====== 1) 确保 checkpoint 存在并“锁行”避免并发推进 ====== */
INSERT INTO etl_checkpoint(job_name, last_success_wm, safety_lag_seconds, max_lookback_seconds)
VALUES (@job, '1970-01-01 00:00:00', 3600, 86400)
ON DUPLICATE KEY UPDATE job_name = job_name;

UPDATE etl_checkpoint
SET updated_at = updated_at
WHERE job_name = @job;

/* ====== 2) 固化窗口（wm_end / wm_start） ====== */
SET @wm_end := NOW();

SET @last_wm := (SELECT last_success_wm FROM etl_checkpoint WHERE job_name=@job);
SET @lag_sec := (SELECT safety_lag_seconds FROM etl_checkpoint WHERE job_name=@job);
SET @wm_start := DATE_SUB(@last_wm, INTERVAL @lag_sec SECOND);

/* ====== 3) run_log：RUNNING ====== */
INSERT INTO etl_run_log(job_name, batch_id, status, window_start, window_end, wm_before, started_at, err_msg)
VALUES (@job, @batch_id, 'RUNNING', @wm_start, @wm_end, @last_wm, NOW(), NULL);

SET @run_id := LAST_INSERT_ID();

/* =========================================================
   4) 入队列
   ========================================================= */

INSERT IGNORE INTO etl_update_queue(job_name, id, status, batch_id, locked_time, attempts, updated_time)
SELECT @job, s.actual_id, 0, NULL, NULL, 0, NOW()
FROM ods_mes_mm_task_prod_actual s
WHERE @full_seed = 0
  AND s.r_modified_time > @wm_start
  AND s.r_modified_time <= @wm_end;

INSERT IGNORE INTO etl_update_queue(job_name, id, status, batch_id, locked_time, attempts, updated_time)
SELECT @job, dr.actual_id, 0, NULL, NULL, 0, NOW()
FROM ods_mes_mm_qc_defect_data dd
         JOIN ods_mes_mm_qc_actual_defect_rela dr
              ON dr.defect_data_id = dd.defect_data_id
WHERE @full_seed = 0
  AND dd.status = 1
  AND dr.status = 1
  AND dr.is_main_defect = 1
  AND dd.r_modified_time > @wm_start
  AND dd.r_modified_time <= @wm_end;

/* ====== 5) 回收超时锁（避免死锁批次卡住） ====== */
UPDATE etl_update_queue
SET status = 0,
    batch_id = NULL,
    locked_time = NULL
WHERE job_name = @job
  AND status = 1
  AND locked_time < DATE_SUB(NOW(), INTERVAL @lock_expire_min MINUTE);

/* ====== 6) 锁一批 NEW（LIMIT 写死数字） ====== */
UPDATE etl_update_queue q
SET q.status      = 1,
    q.batch_id    = @batch_id,
    q.locked_time = NOW(),
    q.attempts    = q.attempts + 1
WHERE q.job_name = @job
  AND q.status = 0
ORDER BY q.updated_time
LIMIT 50000;

/* ====== 7) 记录 picked_cnt ====== */
UPDATE etl_run_log
SET picked_cnt = (
    SELECT COUNT(*)
    FROM etl_update_queue
    WHERE job_name=@job AND status=1 AND batch_id=@batch_id
)
WHERE run_id=@run_id;

/* ==
```
