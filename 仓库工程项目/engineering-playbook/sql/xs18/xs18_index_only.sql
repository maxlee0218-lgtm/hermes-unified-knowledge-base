-- =======================================
-- ads_gx_xs_18 海豚现有逻辑：仅索引优化，不改业务 SQL
-- 执行建议：
--   1. 先确保海豚相关任务暂停，避免 DDL 等 metadata lock。
--   2. 一条一条执行；每条成功后用 SHOW INDEX 确认。
--   3. 当前已验证 ads_gx_xs_12_detail 的 cust_abbr/salesman 索引已存在，不重复创建。
-- =======================================

SET SESSION lock_wait_timeout = 10;

-- 1) 支撑两段 place 修正子查询：
--    SELECT DISTINCT contract_code, receive_warehouse
--    FROM ods_crm_sa_sales_delivery_order_detail
--    WHERE tenant_id = 92 AND receive_warehouse IS NOT NULL AND status = 1
--
-- 当前 EXPLAIN 显示该子查询在销售明细上全表/并行扫。
-- 这个索引用 tenant_id/status 先过滤，再按 contract_code/receive_warehouse 输出 DISTINCT。
ALTER TABLE ods_crm_sa_sales_delivery_order_detail
    ADD INDEX idx_xs18_sdod_tenant_status_contract_recv
        (tenant_id, status, contract_code, receive_warehouse),
    ALGORITHM=INPLACE,
    LOCK=NONE;

-- 2) 支撑来源一转库单过滤：
--    WHERE transfer_order_state IN (20,40)
--      AND status = 1
--      AND tenant_id IN (92,108)
--      AND YEAR(transfer_order_date) >= '2026'
--
-- 不改 YEAR() 写法，仅补一个符合现有过滤和 join 的索引。
ALTER TABLE ods_crm_sa_transfer_order
    ADD INDEX idx_xs18_to_filter_join
        (tenant_id, status, transfer_order_state, transfer_order_date, transfer_order_id, in_warehouse_code),
    ALGORITHM=INPLACE,
    LOCK=NONE;

-- 3) 支撑来源二/三发货明细过滤：
--    sdod.status = 1
--    sdod.sales_delivery_order_detail_state IN ('50','20','30')
--    sdod.created_time >= '2026-01-01'
--
-- 现有 idx_created_time 只有单列，idx_code_status_state 更适合按单据号回查。
-- 该索引让优化器可以从状态 + 创建时间范围切入，再关联单据号和批号。
ALTER TABLE ods_crm_sa_sales_delivery_order_detail
    ADD INDEX idx_xs18_sdod_state_created_order_batch
        (status, sales_delivery_order_detail_state, created_time, sales_delivery_order_code, batch_code),
    ALGORITHM=INPLACE,
    LOCK=NONE;

-- 4) 支撑渠道更新：
--    JOIN with_attr_value b
--      ON a.cust_abbr = b.attribute2
--     AND b.scene = 'bi_gx_xs_012_detail_attr1_2'
--
-- 当前 EXPLAIN 已能走 scene 开头索引且只估 7 行，此索引属于低成本兜底。
-- 如果 DDL 窗口很紧，可放在第二优先级。
ALTER TABLE with_attr_value
    ADD INDEX idx_wav_scene_attr2_attr1
        (scene, attribute2, attribute1),
    ALGORITHM=INPLACE,
    LOCK=NONE;

-- 5) 可选：支撑 pending_delivery place 修正。
-- 当前已有 idx_tenant_source(tenant_id, source_code)，20 万行表通常够用。
-- 若后续 EXPLAIN 仍慢，再执行这个覆盖索引。
-- ALTER TABLE ods_crm_sa_pending_delivery
--     ADD INDEX idx_xs18_pd_tenant_source_recv
--         (tenant_id, source_code, receive_warehouse),
--     ALGORITHM=INPLACE,
--     LOCK=NONE;
