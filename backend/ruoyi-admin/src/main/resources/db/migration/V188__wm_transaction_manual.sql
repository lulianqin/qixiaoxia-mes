-- ============================================================
-- V188: 库存流水支持手工/导入留痕
--
-- 背景：一期手工新增/编辑/删除库存、Excel 导入库存都必须可追溯。
--       复用 qxx_wm_transaction，扩展业务类型并记录变更前后值。
--
-- 含：
--   ① qxx_wm_transaction 增加 before_quantity / after_quantity / import_batch_no / operation_source
--   ② transaction_type 注释扩展，新增 MANUAL_IN / MANUAL_OUT / MANUAL_ADJUST / IMPORT
--
-- 字符集：utf8mb4
-- 日期：2026-11-15
-- ============================================================

SET NAMES utf8mb4;

-- ① 审计字段
ALTER TABLE qxx_wm_transaction
    ADD COLUMN before_quantity DECIMAL(14,4) DEFAULT NULL COMMENT '变更前库存量(手工调整/导入留痕)',
    ADD COLUMN after_quantity  DECIMAL(14,4) DEFAULT NULL COMMENT '变更后库存量',
    ADD COLUMN import_batch_no VARCHAR(64)   DEFAULT NULL COMMENT '导入批次号(同一批Excel共用)',
    ADD COLUMN operation_source VARCHAR(16)  DEFAULT NULL COMMENT '操作来源:MANUAL-手工/EXCEL-导入';

ALTER TABLE qxx_wm_transaction
    ADD KEY idx_txn_import_batch (import_batch_no);

-- ② 事务类型注释扩展
ALTER TABLE qxx_wm_transaction
    MODIFY COLUMN transaction_type VARCHAR(50) NOT NULL
    COMMENT '事务类型:RECEIPT-入库,ISSUE-出库,TRANSFER-调拨,RETURN-退货,ADJUST-调整,SPLIT-分切,MANUAL_IN-手工新增,MANUAL_OUT-手工删除,MANUAL_ADJUST-手工编辑,IMPORT-Excel导入';
