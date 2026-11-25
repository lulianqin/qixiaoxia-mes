-- ============================================================
-- V209: 销售订单增加「需方主体」，签约主体语义调整为「供方主体」
--
-- 背景：ERP 采购单转工厂销售订单时，ERP 采购单的需方不再作为 MES 客户名称，
--   客户名称改为取 ERP 销售订单的客户名称（按名称自动匹配/创建 MES 客户）。
--   需方主体单独落库展示；原「签约主体」即 ERP 采购单供方，界面统一改称「供方主体」。
--
-- 含：① qxx_sal_order 加 demander_name 列（存 ERP 采购单需方名称原文）
--    ② sign_company 列注释由「签约主体」调整为「供方主体」
--
-- 幂等：列存在跳过（存储过程）
-- 字符集：utf8mb4
-- 日期：2026-11-25
-- ============================================================

SET NAMES utf8mb4;

-- ① 需方主体
DROP PROCEDURE IF EXISTS proc_add_sal_order_demander_name;
DELIMITER $$
CREATE PROCEDURE proc_add_sal_order_demander_name()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='qxx_sal_order'
                   AND COLUMN_NAME='demander_name') THEN
        ALTER TABLE qxx_sal_order ADD COLUMN demander_name varchar(255) DEFAULT NULL
            COMMENT '需方主体(ERP采购单需方名称,外部来源原样保存)' AFTER sign_company;
    END IF;
END$$
DELIMITER ;
CALL proc_add_sal_order_demander_name();
DROP PROCEDURE IF EXISTS proc_add_sal_order_demander_name;

-- ② 签约主体注释改为供方主体（字段名不变，兼容既有数据与接口）
ALTER TABLE qxx_sal_order
    MODIFY COLUMN sign_company varchar(20) DEFAULT NULL
        COMMENT '供方主体(sys_company字典值,对应ERP采购单供方)';
