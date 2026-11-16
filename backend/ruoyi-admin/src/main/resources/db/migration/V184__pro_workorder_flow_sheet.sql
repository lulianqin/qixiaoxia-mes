-- ============================================================
-- V184: 生产工单 - 生产流转单字段
--
-- 背景：一期需要在工单列表点【生成流转单】时补齐纸袋行业字段并导出 Excel 套打。
--       这些字段只落在工单主表，销售订单/明细不改。
--       建工单时逻辑保持不变，点【生成流转单】时才补齐。
--
-- 含：
--   ① qxx_pro_workorder 新增 16 个流转单字段
--   ② production_no 唯一键（同一工厂内不重号，NULL 不参与唯一约束）
--   ③ 菜单按钮：生成流转单
--
-- 字符集：utf8mb4
-- 日期：2026-11-15
-- ============================================================

SET NAMES utf8mb4;

-- ① 流转单字段
ALTER TABLE qxx_pro_workorder
    ADD COLUMN title               VARCHAR(200)  DEFAULT NULL COMMENT '标题(默认:生产流转单)',
    ADD COLUMN bill_date           DATE          DEFAULT NULL COMMENT '制单日期',
    ADD COLUMN order_date          DATE          DEFAULT NULL COMMENT '下单日期',
    ADD COLUMN production_no       VARCHAR(64)   DEFAULT NULL COMMENT '生产编号(订单号-s序号)',
    ADD COLUMN order_qty           DECIMAL(18,4) DEFAULT NULL COMMENT '订单数量(与计划数量区分)',
    ADD COLUMN bag_mouth           VARCHAR(100)  DEFAULT NULL COMMENT '口部提袋(锯齿口/平口)',
    ADD COLUMN bottom_board        VARCHAR(100)  DEFAULT NULL COMMENT '底板',
    ADD COLUMN material            VARCHAR(100)  DEFAULT NULL COMMENT '订单材质',
    ADD COLUMN material_gram       DECIMAL(18,4) DEFAULT NULL COMMENT '订单材质克重',
    ADD COLUMN roll_width          VARCHAR(50)   DEFAULT NULL COMMENT '订单门幅',
    ADD COLUMN loss_rate           DECIMAL(9,2)  DEFAULT NULL COMMENT '损耗比率(%)',
    ADD COLUMN order_weight        DECIMAL(18,4) DEFAULT NULL COMMENT '订单重量(吨)',
    ADD COLUMN plate_circumference DECIMAL(18,2) DEFAULT NULL COMMENT '版辊周长(mm)',
    ADD COLUMN process_flow        TEXT          DEFAULT NULL COMMENT '工艺流程',
    ADD COLUMN product_image       VARCHAR(500)  DEFAULT NULL COMMENT '产品图片',
    ADD COLUMN salesperson         VARCHAR(64)   DEFAULT NULL COMMENT '业务员';

-- ② 生产编号唯一（同一工厂内）；历史数据为 NULL 不受影响
ALTER TABLE qxx_pro_workorder
    ADD UNIQUE KEY uk_workorder_production_no (factory_id, production_no);

-- ③ 按钮权限（挂到生产工单菜单 parent_id=2003/path=workorder 下，该菜单 perms 为空不能按权限查）
INSERT INTO sys_menu (menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT '生成流转单', p.menu_id, 20, 'F', '0', '0', 'mes:pro:workorder:flowSheet', 'admin', sysdate()
FROM (SELECT menu_id FROM sys_menu WHERE parent_id = 2003 AND path = 'workorder' AND menu_type = 'C' LIMIT 1) p
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workorder:flowSheet');
