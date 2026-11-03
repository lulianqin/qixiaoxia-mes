-- ============================================================
-- P2：采购向导默认价格数据源（供应商报价优先 + 物料默认价兜底）
--
-- 价格口径统一为「元 / 主单位」（与 P1 的库存基准单位一致）。
-- 物料主数据 price 仅作兜底，供应商关系表价格优先。
-- 全部为 ALTER，无 INSERT，不涉及 factory_id 显式写入。
-- ============================================================

SET NAMES utf8mb4;

-- ---------- 1. 物料默认采购价（兜底） ----------
ALTER TABLE qxx_md_item
    ADD COLUMN default_purchase_price decimal(14,4) NULL COMMENT '默认采购价(元/主单位)',
    ADD COLUMN default_tax_rate decimal(5,2) NULL COMMENT '默认税率(%)';

-- ---------- 2. 物料-供应商报价（优先） ----------
ALTER TABLE qxx_md_item_vendor
    ADD COLUMN purchase_price decimal(14,4) NULL COMMENT '采购价(元/主单位)',
    ADD COLUMN tax_rate decimal(5,2) NULL COMMENT '税率(%)',
    ADD COLUMN currency varchar(8) NULL DEFAULT 'CNY' COMMENT '币种';
