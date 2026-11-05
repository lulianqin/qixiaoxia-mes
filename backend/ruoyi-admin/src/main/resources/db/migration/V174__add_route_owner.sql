-- ============================================================
-- 工艺路线增加负责人
--
-- 说明：
--   1. 工艺路线（qxx_pro_route，即产品线）支持配置负责人。
--   2. 新建工单未指定负责人时，自动继承所属工艺路线的负责人。
--   3. 业务表，factory_id 由 FactoryIdInterceptor 处理，无需在本迁移中写。
-- ============================================================

SET NAMES utf8mb4;

ALTER TABLE qxx_pro_route
    ADD COLUMN owner_id   bigint(20)   DEFAULT NULL COMMENT '路线负责人ID(关联sys_user)' AFTER route_desc,
    ADD COLUMN owner_name varchar(64) DEFAULT NULL COMMENT '路线负责人姓名(快照)' AFTER owner_id;
