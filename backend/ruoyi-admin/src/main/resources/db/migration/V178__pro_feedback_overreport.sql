-- ============================================================
-- 报工超计划：默认硬拦 + 授权提交留痕
-- 新增权限 mes:pro:feedback:overreport（默认仅 admin 通配拥有）
-- ============================================================

SET NAMES utf8mb4;

ALTER TABLE qxx_pro_feedback
    ADD COLUMN over_flag CHAR(1) DEFAULT NULL COMMENT '超报标识(Y/N)',
    ADD COLUMN over_qty DECIMAL(14,4) DEFAULT NULL COMMENT '超出计划数量',
    ADD COLUMN over_reason VARCHAR(500) DEFAULT NULL COMMENT '超报原因',
    ADD COLUMN over_approver VARCHAR(64) DEFAULT NULL COMMENT '超报授权人',
    ADD COLUMN over_approve_time DATETIME DEFAULT NULL COMMENT '超报授权时间';

SET @sql = (SELECT IF(COUNT(*) = 0,
    'ALTER TABLE qxx_pro_feedback ADD INDEX idx_feedback_task_id (task_id)',
    'SELECT 1')
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'qxx_pro_feedback'
      AND index_name = 'idx_feedback_task_id');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 生产报工页面下新增「超报授权」按钮权限（sys_menu 无 factory_id）
INSERT INTO sys_menu (menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT '超报授权', 2303, 9, 'F', '0', '0', 'mes:pro:feedback:overreport', 'admin', sysdate()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:feedback:overreport');
