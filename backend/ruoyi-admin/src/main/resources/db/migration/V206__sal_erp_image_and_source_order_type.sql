-- ============================================================
-- V206: ERP 下发订单增加「源订单类型」与明细「产品图片」
--
-- 背景：
--   1. ERP 采购单下发时未带源订单类型，MES 接单后 order_type 一律写死 STANDARD；
--      SRM 订单类型（0未知 1新单 2翻单 3异常单 4打样）与 MES 订单类型
--      （标品/小批量/礼品/备货订单/制版）字典不同，不能混用。
--      故新增独立列 source_order_type 保存源值，MES 自身 order_type 不动，
--      避免影响按 order_type 驱动的工艺路线解析。
--   2. ERP 采购单明细下发时未带产品图片，MES 明细无字段可存，新增 product_photo。
--      ERP 已在下发报文中把 Upload 开头的历史相对图片补成
--      http://system.yinxiamall.com/ 开头的完整地址。
--
-- 字符集：utf8mb4
-- 日期：2026-11-24
-- ============================================================

SET NAMES utf8mb4;

ALTER TABLE qxx_sal_order
    ADD COLUMN source_order_type varchar(20) DEFAULT NULL
        COMMENT '源订单类型(SRM订单Type: 0未知 1新单 2翻单 3异常单 4打样)' AFTER order_type;

ALTER TABLE qxx_sal_order_line
    ADD COLUMN product_photo varchar(1000) DEFAULT NULL
        COMMENT '产品图片(ERP采购单明细ProductPhoto,完整URL)' AFTER mes_product_name;

INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)
SELECT '源订单类型', 'mes_source_order_type', '0', 'admin', sysdate(), 'SRM销售订单Type: 0未知 1新单 2翻单 3异常单 4打样'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE dict_type = 'mes_source_order_type');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 0, '未知', '0', 'mes_source_order_type', '', 'info', 'N', '0', 'admin', sysdate(), 'SRM订单类型未知'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type='mes_source_order_type' AND dict_value='0');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 1, '新单', '1', 'mes_source_order_type', '', 'primary', 'N', '0', 'admin', sysdate(), 'SRM订单类型新单'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type='mes_source_order_type' AND dict_value='1');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 2, '翻单', '2', 'mes_source_order_type', '', 'success', 'N', '0', 'admin', sysdate(), 'SRM订单类型翻单'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type='mes_source_order_type' AND dict_value='2');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 3, '异常单', '3', 'mes_source_order_type', '', 'danger', 'N', '0', 'admin', sysdate(), 'SRM订单类型异常单'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type='mes_source_order_type' AND dict_value='3');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 4, '打样', '4', 'mes_source_order_type', '', 'warning', 'N', '0', 'admin', sysdate(), 'SRM订单类型打样'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type='mes_source_order_type' AND dict_value='4');
