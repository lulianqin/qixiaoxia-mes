-- ============================================================
-- P1：产品级 BOM 合并 + 用量方式 + 单位精度 + 库存双单位
--
-- 1. 工单 BOM 增加「用量方式」与「来源」：
--    quantity_mode = PER_UNIT(按件用量) / TOTAL(整单总量)
--    bom_source    = PRODUCT(产品BOM) / PROCESS(工艺路线BOM)
-- 2. 提高 BOM / 库存 / 流水数量精度（原 2 位小数无法表达吨/卷换算）
-- 3. 库存增加辅助单位可用量 quantity_available2：
--    主单位数量(quantity_onhand/available)为权威值，
--    辅助单位数量(quantity_onhand2/available2)为记录/展示值（部分卷场景不随出库自动减少）
--
-- 说明：物料主单位、辅助单位与换算率来自 qxx_md_item（数据驱动，不在代码写死）。
-- 历史库存的单位归一化由管理接口触发（master data 调整后执行一次）。
-- ============================================================

SET NAMES utf8mb4;

-- ---------- 1. 工单 BOM ----------
ALTER TABLE qxx_pro_workorder_bom
    ADD COLUMN quantity_mode varchar(16) NOT NULL DEFAULT 'PER_UNIT'
        COMMENT '用量方式:PER_UNIT按件用量/TOTAL整单总量',
    ADD COLUMN bom_source varchar(16) NULL
        COMMENT 'BOM来源:PRODUCT产品BOM/PROCESS工艺路线BOM',
    ADD COLUMN scrap_rate decimal(5,4) NOT NULL DEFAULT 0.0000
        COMMENT '损耗率(0~1),需求=总量×(1+损耗率)',
    MODIFY quantity         decimal(18,4) NOT NULL COMMENT '用量(单位由unit_of_measure决定)',
    MODIFY total_quantity   decimal(18,4) NULL COMMENT '预计总用量(业务单位)',
    MODIFY total_quantity2  decimal(18,4) NULL COMMENT '预计总用量(库存基准单位)';

-- ---------- 2. 库存双单位 ----------
ALTER TABLE qxx_wm_material_stock
    ADD COLUMN quantity_available2 decimal(18,4) DEFAULT 0.0000 COMMENT '可用库存量(辅单位)',
    MODIFY quantity_onhand    decimal(18,4) DEFAULT 0.0000 COMMENT '现有库存量(主单位)',
    MODIFY quantity_onhand2   decimal(18,4) DEFAULT 0.0000 COMMENT '现有库存量(辅单位)',
    MODIFY quantity_available decimal(18,4) DEFAULT 0.0000 COMMENT '可用库存量(主单位)';

-- ---------- 3. 库存流水精度 ----------
ALTER TABLE qxx_wm_transaction
    MODIFY quantity  decimal(18,4) NULL COMMENT '数量(主单位)',
    MODIFY quantity2 decimal(18,4) NULL COMMENT '数量(辅单位)';
