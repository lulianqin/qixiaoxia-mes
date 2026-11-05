-- ============================================================
-- B4 工单负责人（手工可调整）
--
-- 说明：
--   1. 不新增产品线主数据，产品线即工单所挂工艺路线（前端展示路线名称）。
--   2. 工单负责人用于任务未设置负责人时回退：下发/开工闸门、我的任务/待办归属。
-- ============================================================

SET NAMES utf8mb4;

ALTER TABLE qxx_pro_workorder
    ADD COLUMN owner_id BIGINT DEFAULT NULL COMMENT '工单负责人ID(关联sys_user)' AFTER route_product_id,
    ADD COLUMN owner_name VARCHAR(64) DEFAULT NULL COMMENT '工单负责人昵称快照' AFTER owner_id;
