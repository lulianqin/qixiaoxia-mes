-- ============================================================
-- V191: 库存模型去行业化（数据来自物料档案）
--
-- 背景：
--   ① 「库存类型 stock_type」是冗余字段：成品/原料/纸边/废纸等
--      本质是物料分类（qxx_md_item.item_type_id），订单成品/现货/外采
--      可由工单、客户、供应商是否为空自然区分，不应额外存字段。
--   ② 卷数/箱数/装箱数量不应作为库存行业列硬编码：
--      其他行业原料可能是吨/根/米，单位与换算率应由物料档案的
--      主单位、辅助单位、换算率（装箱规格）决定。
--   ③ 门幅/材质/克重/纸张来源/用途属于物料属性，归物料档案
--      （ext_attrs / 分类属性模板），库存行不再冗余快照。
--
-- 含：
--   ① 恢复库存唯一键 uk_stock（不含 stock_type）
--   ② 库存增加客户维度（订单成品区分现货）
--   ③ 删除 stock_type 与行业专用列
--   ④ 删除 mes_stock_type 字典
--
-- 字符集：utf8mb4
-- 日期：2026-11-16
-- ============================================================

SET NAMES utf8mb4;

-- ① 恢复唯一键（先删含 stock_type 的索引）
ALTER TABLE qxx_wm_material_stock DROP INDEX idx_stock_type;
ALTER TABLE qxx_wm_material_stock DROP INDEX uk_stock;
ALTER TABLE qxx_wm_material_stock
    ADD UNIQUE KEY uk_stock (factory_id, item_id, batch_id, warehouse_id, vendor_id, workorder_id, quality_status);

-- ② 客户维度：订单成品挂客户，现货/外采客户为空
ALTER TABLE qxx_wm_material_stock
    ADD COLUMN client_id   BIGINT(20)   DEFAULT 0    COMMENT '客户ID(关联qxx_md_client,0=不适用)' AFTER vendor_name,
    ADD COLUMN client_name VARCHAR(255) DEFAULT NULL COMMENT '客户名称' AFTER client_id;

-- ③ 删除库存类型与行业专用字段
ALTER TABLE qxx_wm_material_stock
    DROP COLUMN stock_type,
    DROP COLUMN width,
    DROP COLUMN material,
    DROP COLUMN gram_weight,
    DROP COLUMN roll_count,
    DROP COLUMN pack_qty,
    DROP COLUMN box_count,
    DROP COLUMN paper_source,
    DROP COLUMN usage_desc,
    DROP COLUMN ext_attrs;

-- ④ 删除库存类型字典
DELETE FROM sys_dict_data WHERE dict_type = 'mes_stock_type';
DELETE FROM sys_dict_type WHERE dict_type = 'mes_stock_type';
