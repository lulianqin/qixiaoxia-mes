-- ============================================================
-- 采购单驳回重审：已审批/已下单且未收货 → 回到草稿
-- 记录驳回原因、驳回人、驳回时间，原单保留
-- ============================================================

SET NAMES utf8mb4;

ALTER TABLE qxx_pur_order
    ADD COLUMN reject_reason VARCHAR(500) DEFAULT NULL COMMENT '驳回原因',
    ADD COLUMN reject_by VARCHAR(64) DEFAULT NULL COMMENT '驳回人',
    ADD COLUMN reject_time DATETIME DEFAULT NULL COMMENT '驳回时间';
