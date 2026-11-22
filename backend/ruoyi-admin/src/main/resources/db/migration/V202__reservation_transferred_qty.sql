-- ============================================================
-- V202: 预占明细区分“转领料单”与“释放回库存”
--
-- 背景：
--   released_qty 同时被用于“转给领料单”和“释放回库存”，
--   导致工单 BOM 重对齐时把已释放量误算成已处理量。
--   新增 transferred_qty 单独记录“已转领料单未消耗”，
--   released_qty 只表示“释放回库存”。
--
-- 字符集：utf8mb4
-- 日期：2026-11-21
-- ============================================================

SET NAMES utf8mb4;

ALTER TABLE qxx_wm_stock_reservation
    ADD COLUMN transferred_qty DECIMAL(14,4) NOT NULL DEFAULT 0.0000
        COMMENT '已转领料单未消耗数量(主单位)' AFTER released_qty;
