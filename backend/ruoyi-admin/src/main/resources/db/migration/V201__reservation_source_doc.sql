-- ============================================================
-- V201: 预占明细支持通用来源单据（销售出库“开单即锁”）
--
-- 背景：
--   预占表原先只挂了 workorder_id / issue_id，无法表达“销售出库单”
--   创建时锁料。增加通用来源单据字段，供销售出库等单据复用。
--
-- 含：
--   ① qxx_wm_stock_reservation 增加 source_doc_type/source_doc_id/
--      source_doc_code/source_line_id
--   ② 来源单据索引
--
-- 字符集：utf8mb4
-- 日期：2026-11-21
-- ============================================================

SET NAMES utf8mb4;

ALTER TABLE qxx_wm_stock_reservation
    ADD COLUMN source_doc_type VARCHAR(32) DEFAULT NULL COMMENT '来源单据类型:PRODUCT_SALES等' AFTER sales_order_line_id,
    ADD COLUMN source_doc_id BIGINT(20) DEFAULT NULL COMMENT '来源单据ID' AFTER source_doc_type,
    ADD COLUMN source_doc_code VARCHAR(64) DEFAULT NULL COMMENT '来源单据编码' AFTER source_doc_id,
    ADD COLUMN source_line_id BIGINT(20) DEFAULT NULL COMMENT '来源单据行ID' AFTER source_doc_code,
    ADD KEY idx_res_source (factory_id, source_doc_type, source_doc_id);
