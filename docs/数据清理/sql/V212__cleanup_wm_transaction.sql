-- ============================================================
-- V212  库存事务物理删除
-- 背景：采购入库 / 生产领料 / 产品入库 / 销售出库 / 委外等历史单据已全部清理，
--       配套的库存事务（qxx_wm_transaction）失去业务来源，业务要求物理删除。
-- 范围：只删「库存事务」页面的数据（qxx_wm_transaction）；
--       qxx_wm_material_stock（库存现有量 282 条期初）保持不动，
--       否则物料/库存页面会跟着归零。
-- 关联：qxx_pro_material_trace.transaction_id 逻辑引用事务（无物理外键），
--       事务删掉后这些追溯行会指向不存在的记录，故一并删除，避免追溯页出现空引用。
-- 幂等：DELETE 重复执行影响 0 行，可安全重跑。
-- ============================================================

-- ---------- 1. 清理指向事务的物料追溯行（避免悬空引用） ----------
DELETE FROM qxx_pro_material_trace WHERE transaction_id IS NOT NULL;

-- ---------- 2. 物理删除全部库存事务 ----------
DELETE FROM qxx_wm_transaction;

-- ---------- 3. 重置自增，让后续新事务号从 1 开始 ----------
ALTER TABLE qxx_wm_transaction AUTO_INCREMENT = 1;
