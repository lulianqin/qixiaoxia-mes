-- ============================================================
-- V219: 入库明细允许暂不关联库存桶
--
-- 背景：
--   到货登记（移动端 /receive、PC 端草稿）在「逐件录入」时就要把每件实物写进
--   qxx_wm_item_recpt_detail，供确认入库时逐件建档。但该表的 material_stock_id
--   是 NOT NULL，草稿阶段尚未过账、没有库存桶，插入直接报
--   "Field 'material_stock_id' doesn't have a default value"。
--
--   该列的语义本就是「关联库存记录」，只有确认入库/过账后才成立，
--   因此改为可空，由确认入库流程回填（createInstancesForReceipt 已在回写）。
--
-- 幂等：MODIFY 可重复执行。字符集：utf8mb4    日期：2026-11-27
-- ============================================================

SET NAMES utf8mb4;

ALTER TABLE qxx_wm_item_recpt_detail
  MODIFY COLUMN material_stock_id bigint(20) default null
  comment '库存记录ID(关联qxx_wm_material_stock;草稿到货登记阶段为空,确认入库后回填)';
