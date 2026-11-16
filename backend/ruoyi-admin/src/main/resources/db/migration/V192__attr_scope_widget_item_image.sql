-- ============================================================
-- V190: 扩展属性分域 + 控件类型 + 物料主图 + 客户PO回填
--
-- 背景：
--   ① 生产流转单不应把纸袋专用字段硬编码在工单表，改为「产品属性 / 生产属性」两类扩展属性；
--   ② 属性需要支持文本、多行文本、数字、日期、单选、多选、图片、附件等控件；
--   ③ 物料档案需要主图；
--   ④ ERP/SRM 下发未传客户PO号时，用外部采购单号回填。
--
-- 字符集：utf8mb4
-- 日期：2026-11-16
-- ============================================================

SET NAMES utf8mb4;

-- ① 属性定义增加「属性域」与「控件类型」
ALTER TABLE qxx_md_attr_def
    ADD COLUMN attr_scope  VARCHAR(20) NOT NULL DEFAULT 'PRODUCT'
        COMMENT '属性域：PRODUCT-产品属性，PRODUCTION-生产/流转单属性' AFTER attr_type,
    ADD COLUMN widget_type VARCHAR(20) NOT NULL DEFAULT 'TEXT'
        COMMENT '控件类型：TEXT/TEXTAREA/NUMBER/DATE/SELECT/MULTI_SELECT/BOOL/IMAGE/FILE' AFTER attr_scope;

-- 历史属性按原 attr_type 映射控件类型
UPDATE qxx_md_attr_def
   SET widget_type = CASE attr_type
                          WHEN 'NUMBER' THEN 'NUMBER'
                          WHEN 'SELECT' THEN 'SELECT'
                          WHEN 'BOOL'   THEN 'BOOL'
                          WHEN 'DATE'   THEN 'DATE'
                          ELSE 'TEXT'
                      END
 WHERE widget_type IS NULL OR widget_type = 'TEXT';

-- 纸袋类生产属性归入生产域
UPDATE qxx_md_attr_def
   SET attr_scope = 'PRODUCTION'
 WHERE attr_code IN ('BAG_MOUTH_TYPE', 'BAG_BOTTOM_TYPE', 'BAG_ROPE_SPEC');

UPDATE qxx_md_attr_def SET attr_name = '口部提袋' WHERE attr_code = 'BAG_MOUTH_TYPE' AND attr_name = '口部提拔';

-- ② 补齐纸袋生产属性字典（缺失才插入）
INSERT INTO qxx_md_attr_def (factory_id, attr_code, attr_name, attr_type, attr_scope, widget_type, attr_unit, sort_order, enable_flag, create_by, create_time)
SELECT 0, 'ORDER_MATERIAL', '订单材质', 'TEXT', 'PRODUCTION', 'TEXT', NULL, 10, '1', 'admin', sysdate() FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_attr_def WHERE attr_code = 'ORDER_MATERIAL');

INSERT INTO qxx_md_attr_def (factory_id, attr_code, attr_name, attr_type, attr_scope, widget_type, attr_unit, sort_order, enable_flag, create_by, create_time)
SELECT 0, 'MATERIAL_GRAM', '材质克重', 'NUMBER', 'PRODUCTION', 'NUMBER', 'g', 20, '1', 'admin', sysdate() FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_attr_def WHERE attr_code = 'MATERIAL_GRAM');

INSERT INTO qxx_md_attr_def (factory_id, attr_code, attr_name, attr_type, attr_scope, widget_type, attr_unit, sort_order, enable_flag, create_by, create_time)
SELECT 0, 'ROLL_WIDTH', '订单门幅', 'TEXT', 'PRODUCTION', 'TEXT', 'mm', 30, '1', 'admin', sysdate() FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_attr_def WHERE attr_code = 'ROLL_WIDTH');

INSERT INTO qxx_md_attr_def (factory_id, attr_code, attr_name, attr_type, attr_scope, widget_type, attr_unit, sort_order, enable_flag, create_by, create_time)
SELECT 0, 'LOSS_RATE', '损耗比率', 'NUMBER', 'PRODUCTION', 'NUMBER', '%', 40, '1', 'admin', sysdate() FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_attr_def WHERE attr_code = 'LOSS_RATE');

INSERT INTO qxx_md_attr_def (factory_id, attr_code, attr_name, attr_type, attr_scope, widget_type, attr_unit, sort_order, enable_flag, create_by, create_time)
SELECT 0, 'ORDER_WEIGHT', '订单重量', 'NUMBER', 'PRODUCTION', 'NUMBER', '吨', 50, '1', 'admin', sysdate() FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_attr_def WHERE attr_code = 'ORDER_WEIGHT');

INSERT INTO qxx_md_attr_def (factory_id, attr_code, attr_name, attr_type, attr_scope, widget_type, attr_unit, sort_order, enable_flag, create_by, create_time)
SELECT 0, 'PLATE_CIRCUMFERENCE', '版辊周长', 'NUMBER', 'PRODUCTION', 'NUMBER', 'mm', 60, '1', 'admin', sysdate() FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_attr_def WHERE attr_code = 'PLATE_CIRCUMFERENCE');

-- 绑定到「纸袋成品」分类
INSERT INTO qxx_md_item_type_attr (factory_id, item_type_id, attr_id, required, sort_order, enable_flag, create_by, create_time)
SELECT t.factory_id, t.item_type_id, a.attr_id, '0', 90 + a.sort_order, '1', 'admin', sysdate()
  FROM qxx_md_item_type t
  JOIN qxx_md_attr_def a
    ON a.attr_code IN ('ORDER_MATERIAL', 'MATERIAL_GRAM', 'ROLL_WIDTH', 'LOSS_RATE', 'ORDER_WEIGHT', 'PLATE_CIRCUMFERENCE')
 WHERE t.item_type_name = '纸袋成品'
   AND EXISTS (SELECT 1 FROM qxx_md_item_type_attr x
                WHERE x.factory_id = t.factory_id AND x.item_type_id = t.item_type_id AND x.attr_id = a.attr_id) = 0;

-- ③ 物料主图
ALTER TABLE qxx_md_item
    ADD COLUMN image_url VARCHAR(500) DEFAULT NULL COMMENT '物料主图' AFTER specification;

-- ④ ERP/SRM 下发未传客户PO号时，回填外部采购单号
UPDATE qxx_sal_order
   SET client_order_code = external_order_no
 WHERE (client_order_code IS NULL OR client_order_code = '')
   AND external_order_no IS NOT NULL AND external_order_no <> '';

UPDATE qxx_pro_workorder wo
  JOIN qxx_sal_order o ON o.order_code = wo.source_code AND o.factory_id = wo.factory_id
   SET wo.client_order_code = o.external_order_no
 WHERE (wo.client_order_code IS NULL OR wo.client_order_code = '')
   AND o.external_order_no IS NOT NULL AND o.external_order_no <> '';

-- ⑤ 历史流转单字段回填到 line_attrs，保证旧单据在流转单预览中仍可见
UPDATE qxx_pro_workorder
   SET line_attrs = JSON_SET(COALESCE(line_attrs, JSON_OBJECT()), '$.BAG_MOUTH_TYPE', bag_mouth)
 WHERE production_no IS NOT NULL AND bag_mouth IS NOT NULL AND bag_mouth <> '';

UPDATE qxx_pro_workorder
   SET line_attrs = JSON_SET(COALESCE(line_attrs, JSON_OBJECT()), '$.BAG_BOTTOM_TYPE', bottom_board)
 WHERE production_no IS NOT NULL AND bottom_board IS NOT NULL AND bottom_board <> '';

UPDATE qxx_pro_workorder
   SET line_attrs = JSON_SET(COALESCE(line_attrs, JSON_OBJECT()), '$.ORDER_MATERIAL', material)
 WHERE production_no IS NOT NULL AND material IS NOT NULL AND material <> '';

UPDATE qxx_pro_workorder
   SET line_attrs = JSON_SET(COALESCE(line_attrs, JSON_OBJECT()), '$.MATERIAL_GRAM', material_gram)
 WHERE production_no IS NOT NULL AND material_gram IS NOT NULL;

UPDATE qxx_pro_workorder
   SET line_attrs = JSON_SET(COALESCE(line_attrs, JSON_OBJECT()), '$.ROLL_WIDTH', roll_width)
 WHERE production_no IS NOT NULL AND roll_width IS NOT NULL AND roll_width <> '';

UPDATE qxx_pro_workorder
   SET line_attrs = JSON_SET(COALESCE(line_attrs, JSON_OBJECT()), '$.LOSS_RATE', loss_rate)
 WHERE production_no IS NOT NULL AND loss_rate IS NOT NULL;

UPDATE qxx_pro_workorder
   SET line_attrs = JSON_SET(COALESCE(line_attrs, JSON_OBJECT()), '$.ORDER_WEIGHT', order_weight)
 WHERE production_no IS NOT NULL AND order_weight IS NOT NULL;

UPDATE qxx_pro_workorder
   SET line_attrs = JSON_SET(COALESCE(line_attrs, JSON_OBJECT()), '$.PLATE_CIRCUMFERENCE', plate_circumference)
 WHERE production_no IS NOT NULL AND plate_circumference IS NOT NULL;
