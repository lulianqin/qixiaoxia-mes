-- ============================================================
-- V197: 开单页工序配置增强
--
-- 背景：工艺路线与工序版块直接配置 开单类型/数量/单价/交期/供应商，
--       单据配置页展示并可编辑产品名称。
--
-- 含：
--   ① qxx_pro_workorder_process 增加 开单类型 / 计划数量
--   ② qxx_pur_order_line 增加 产品名称快照
--   ③ qxx_wm_outsource_process_line 增加 产品名称快照
--
-- 字符集：utf8mb4
-- 日期：2026-11-18
-- ============================================================

SET NAMES utf8mb4;

ALTER TABLE qxx_pro_workorder_process
    ADD COLUMN doc_type VARCHAR(16) DEFAULT 'PROCESS' COMMENT '开单类型:PROCESS-加工,PURCHASE-采购' AFTER is_outsource,
    ADD COLUMN plan_qty DECIMAL(14,4) DEFAULT NULL COMMENT '计划数量' AFTER unit_price;

ALTER TABLE qxx_pur_order_line
    ADD COLUMN product_name VARCHAR(255) DEFAULT NULL COMMENT '产品名称快照(开单页配置,导出用)';

ALTER TABLE qxx_wm_outsource_process_line
    ADD COLUMN product_name VARCHAR(255) DEFAULT NULL COMMENT '产品名称快照(开单页配置,导出用)';
