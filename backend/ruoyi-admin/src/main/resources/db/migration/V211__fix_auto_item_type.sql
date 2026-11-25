-- ============================================================
-- V211: 销售订单接单自动建档物料补默认分类「纸袋成品」
--
-- 背景：
--   接单自动创建的物料未设置 item_type_id（落库为 0），在物料主数据按分类
--   浏览时查不到。新代码已默认归入 FINISHED-BAG（纸袋成品），此处回填历史数据。
--
-- 口径：
--   仅处理 remark='销售订单接单自动建档' 且分类为空的物料；
--   分类ID按 item_type_code 动态解析，不写死自增ID，可重复执行。
-- 字符集：utf8mb4
-- 日期：2026-11-25
-- ============================================================

SET NAMES utf8mb4;

UPDATE qxx_md_item i
    JOIN qxx_md_item_type t
        ON t.item_type_code = 'FINISHED-BAG'
       AND t.del_flag = '0'
       AND t.factory_id = i.factory_id
SET i.item_type_id   = t.item_type_id,
    i.item_type_code = t.item_type_code,
    i.item_type_name = t.item_type_name
WHERE i.del_flag = '0'
  AND i.remark = '销售订单接单自动建档'
  AND (i.item_type_id IS NULL OR i.item_type_id = 0);
