-- ============================================================
-- V225: 产成品销售出库明细仓库ID允许为空（待定仓）
--
-- 背景：
--   产成品销售出库单在开单阶段可能尚未确定出库仓库，
--   qxx_wm_product_sales_line.warehouse_id 当前为 NOT NULL，
--   待定仓场景无法保存。改为可空，出库确认时须指定仓库。
--
-- 幂等：MODIFY 可重复执行。字符集：utf8mb4    日期：2026-11-28
-- ============================================================

SET NAMES utf8mb4;

ALTER TABLE qxx_wm_product_sales_line
  MODIFY COLUMN warehouse_id bigint NULL COMMENT '仓库ID（空=待定仓，出库确认时须指定）';
