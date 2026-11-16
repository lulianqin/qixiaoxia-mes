-- ============================================================
-- V183: 销售订单状态人工调整
--
-- 背景：一期弱化流程，销售订单状态允许人工任意调整，只留痕不做闸门校验。
--
-- 含：
--   ① 状态变更记录表 qxx_sal_order_status_log
--   ② 菜单按钮：销售订单改状态
--
-- 字符集：utf8mb4
-- 日期：2026-11-15
-- ============================================================

SET NAMES utf8mb4;

-- ① 销售订单状态变更记录
CREATE TABLE IF NOT EXISTS qxx_sal_order_status_log (
    log_id      BIGINT       NOT NULL AUTO_INCREMENT COMMENT '记录ID',
    factory_id  BIGINT       NOT NULL                COMMENT '工厂ID',
    order_id    BIGINT       NOT NULL                COMMENT '销售订单ID',
    order_code  VARCHAR(64)  DEFAULT NULL            COMMENT '销售订单号',
    from_status VARCHAR(32)  DEFAULT NULL            COMMENT '变更前状态',
    to_status   VARCHAR(32)  NOT NULL                COMMENT '变更后状态',
    reason      VARCHAR(500) DEFAULT NULL            COMMENT '变更原因',
    create_by   VARCHAR(64)  DEFAULT ''              COMMENT '操作人',
    create_time DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    PRIMARY KEY (log_id),
    KEY idx_status_log_order (factory_id, order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='销售订单状态变更记录';

-- ② 按钮权限（挂到销售订单菜单下）
INSERT INTO sys_menu (menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT '销售订单改状态', p.menu_id, 11, 'F', '0', '0', 'mes:sal:order:changeStatus', 'admin', sysdate()
FROM (SELECT menu_id FROM sys_menu WHERE perms = 'mes:sal:order:list' ORDER BY menu_id LIMIT 1) p
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:sal:order:changeStatus');
