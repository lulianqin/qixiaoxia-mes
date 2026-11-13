-- ============================================================
-- 销售订单新增「生产备注」
-- 生成工单时优先带入生产备注，未填则沿用订单备注
-- ============================================================

SET NAMES utf8mb4;

ALTER TABLE qxx_sal_order
    ADD COLUMN production_remark VARCHAR(500) DEFAULT NULL COMMENT '生产备注(生成工单时带入)' AFTER client_order_code;
