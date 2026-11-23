-- ============================================================
-- V205: 销售订单新增「签约主体」
--
-- 背景：销售订单导出单据抬头需要显示本单的签约主体（对应 ERP 采购单的供方），
--   由固定「企小侠MES」改为按单取值。
--   字典 sys_company：
--     浙江圣享实业有限公司          40
--     温州全印家供应链管理有限公司  50
--     龙港市开守电子商务商行        70
--     龙港市龙湾麦诺电子商务商行    80
--
-- 含：① qxx_sal_order 加 sign_company 列（存字典值）
--    ② sys_company 字典类型 + 4 条字典数据
--
-- 幂等：列存在跳过（存储过程）/ 字典按 dict_type、dict_type+dict_value 判重
-- 字符集：utf8mb4
-- 日期：2026-11-23
-- 注：sys_dict_type / sys_dict_data 无 factory_id 字段，不适用多工厂规则。
-- ============================================================

SET NAMES utf8mb4;

-- ① 销售订单加签约主体列
DROP PROCEDURE IF EXISTS proc_add_sal_order_sign_company;
DELIMITER $$
CREATE PROCEDURE proc_add_sal_order_sign_company()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='qxx_sal_order'
                   AND COLUMN_NAME='sign_company') THEN
        ALTER TABLE qxx_sal_order ADD COLUMN sign_company varchar(20) DEFAULT NULL
            COMMENT '签约主体(sys_company字典值,对应ERP采购单供方)' AFTER order_name;
    END IF;
END$$
DELIMITER ;
CALL proc_add_sal_order_sign_company();
DROP PROCEDURE IF EXISTS proc_add_sal_order_sign_company;

-- ② 签约主体字典
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)
SELECT '签约主体', 'sys_company', '0', 'admin', sysdate(), '销售订单签约主体,对应ERP采购单供方'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE dict_type = 'sys_company');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 1, '浙江圣享实业有限公司', '40', 'sys_company', '', 'primary', 'N', '0', 'admin', sysdate(), 'ERP采购单供方'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'sys_company' AND dict_value = '40');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 2, '温州全印家供应链管理有限公司', '50', 'sys_company', '', 'success', 'N', '0', 'admin', sysdate(), 'ERP采购单供方'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'sys_company' AND dict_value = '50');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 3, '龙港市开守电子商务商行', '70', 'sys_company', '', 'warning', 'N', '0', 'admin', sysdate(), 'ERP采购单供方'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'sys_company' AND dict_value = '70');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 4, '龙港市麦诺电子商务商行', '80', 'sys_company', '', 'info', 'N', '0', 'admin', sysdate(), 'ERP采购单供方'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'sys_company' AND dict_value = '80');
