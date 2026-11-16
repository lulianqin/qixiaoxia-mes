-- ============================================================
-- V187: 库存表支持手工维护 / Excel 导入
--
-- 背景：一期库存以数据管理为主，需要手工新增/编辑库存与 Excel 导入，
--       一张库存表承载所有物料（成品/原料/纸边/辅料/废纸/外采）。
--
-- 含：
--   ① qxx_wm_material_stock 新增库存分类与纸袋行业字段
--   ② 字典 mes_stock_type
--   ③ 菜单按钮：库存手工维护、导入、模板下载
--
-- 字符集：utf8mb4
-- 日期：2026-11-15
-- ============================================================

SET NAMES utf8mb4;

-- ① 库存字段扩展
ALTER TABLE qxx_wm_material_stock
    ADD COLUMN stock_type     VARCHAR(32)   DEFAULT 'RAW' COMMENT '库存类型:ORDER/SPOT/PURCHASE_SPOT/RAW/PAPER_EDGE/OUTSOURCE_PAPER/WASTE/AUX',
    ADD COLUMN width          VARCHAR(50)   DEFAULT NULL  COMMENT '门幅',
    ADD COLUMN material       VARCHAR(100)  DEFAULT NULL  COMMENT '材质',
    ADD COLUMN gram_weight    DECIMAL(18,4) DEFAULT NULL  COMMENT '克重',
    ADD COLUMN roll_count     DECIMAL(18,4) DEFAULT NULL  COMMENT '卷数',
    ADD COLUMN pack_qty       DECIMAL(18,4) DEFAULT NULL  COMMENT '装箱数量(箱规,个/箱)',
    ADD COLUMN box_count      DECIMAL(18,4) DEFAULT NULL  COMMENT '箱数',
    ADD COLUMN paper_source   VARCHAR(200)  DEFAULT NULL  COMMENT '纸张来源',
    ADD COLUMN usage_desc     VARCHAR(200)  DEFAULT NULL  COMMENT '用途/用途详情',
    ADD COLUMN stocktake_date DATE          DEFAULT NULL  COMMENT '盘点日期';

ALTER TABLE qxx_wm_material_stock
    ADD KEY idx_stock_type (factory_id, stock_type);

-- ①-2 唯一键补 stock_type：同一物料同批次可在「订单库存」与「现货库存」并存（不同库存类型=不同库存行）
DROP PROCEDURE IF EXISTS proc_v187_uk_stock;
CREATE PROCEDURE proc_v187_uk_stock()
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.STATISTICS
               WHERE table_schema = DATABASE() AND table_name = 'qxx_wm_material_stock'
                 AND index_name = 'uk_stock' AND column_name = 'stock_type') THEN
        SET @v187_noop = 1;
    ELSE
        IF EXISTS (SELECT 1 FROM information_schema.STATISTICS
                   WHERE table_schema = DATABASE() AND table_name = 'qxx_wm_material_stock'
                     AND index_name = 'uk_stock') THEN
            ALTER TABLE qxx_wm_material_stock DROP INDEX uk_stock;
        END IF;
        ALTER TABLE qxx_wm_material_stock
            ADD UNIQUE KEY uk_stock (factory_id, item_id, batch_id, warehouse_id, vendor_id, workorder_id, quality_status, stock_type);
    END IF;
END;
CALL proc_v187_uk_stock();
DROP PROCEDURE IF EXISTS proc_v187_uk_stock;

-- ② 字典：库存类型
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)
SELECT '库存类型', 'mes_stock_type', '0', 'admin', sysdate(), '统一库存表的库存分类'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE dict_type = 'mes_stock_type');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 1, '订单成品库存', 'ORDER', 'mes_stock_type', '', 'primary', 'N', '0', 'admin', sysdate(), '按订单备货的成品'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_stock_type' AND dict_value = 'ORDER');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 2, '现货成品库存', 'SPOT', 'mes_stock_type', '', 'success', 'N', '0', 'admin', sysdate(), '现货成品'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_stock_type' AND dict_value = 'SPOT');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 3, '外采现货', 'PURCHASE_SPOT', 'mes_stock_type', '', 'warning', 'N', '0', 'admin', sysdate(), '外采待售现货'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_stock_type' AND dict_value = 'PURCHASE_SPOT');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 4, '原料库存', 'RAW', 'mes_stock_type', '', 'info', 'Y', '0', 'admin', sysdate(), '原纸/原料'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_stock_type' AND dict_value = 'RAW');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 5, '纸边库存', 'PAPER_EDGE', 'mes_stock_type', '', 'info', 'N', '0', 'admin', sysdate(), '分切纸边'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_stock_type' AND dict_value = 'PAPER_EDGE');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 6, '外加工纸', 'OUTSOURCE_PAPER', 'mes_stock_type', '', 'info', 'N', '0', 'admin', sysdate(), '外发加工后的纸张'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_stock_type' AND dict_value = 'OUTSOURCE_PAPER');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 7, '废纸', 'WASTE', 'mes_stock_type', '', 'danger', 'N', '0', 'admin', sysdate(), '废纸登记'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_stock_type' AND dict_value = 'WASTE');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 8, '辅料', 'AUX', 'mes_stock_type', '', 'primary', 'N', '0', 'admin', sysdate(), '绳子/胶水/纸箱等'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_stock_type' AND dict_value = 'AUX');

-- ③ 按钮权限
INSERT INTO sys_menu (menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT '库存手工新增', p.menu_id, 20, 'F', '0', '0', 'mes:wm:material_stock:add', 'admin', sysdate()
FROM (SELECT menu_id FROM sys_menu WHERE perms = 'mes:wm:stock:list' AND menu_type = 'C' ORDER BY menu_id LIMIT 1) p
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:material_stock:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT '库存编辑', p.menu_id, 21, 'F', '0', '0', 'mes:wm:material_stock:edit', 'admin', sysdate()
FROM (SELECT menu_id FROM sys_menu WHERE perms = 'mes:wm:stock:list' AND menu_type = 'C' ORDER BY menu_id LIMIT 1) p
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:material_stock:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT '库存删除', p.menu_id, 22, 'F', '0', '0', 'mes:wm:material_stock:remove', 'admin', sysdate()
FROM (SELECT menu_id FROM sys_menu WHERE perms = 'mes:wm:stock:list' AND menu_type = 'C' ORDER BY menu_id LIMIT 1) p
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:material_stock:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT '库存导入', p.menu_id, 23, 'F', '0', '0', 'mes:wm:material_stock:import', 'admin', sysdate()
FROM (SELECT menu_id FROM sys_menu WHERE perms = 'mes:wm:stock:list' AND menu_type = 'C' ORDER BY menu_id LIMIT 1) p
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:material_stock:import');
