-- ═══════════════════════════════════════════════════════════════════════
-- V167 外协「代厂商操作」支持
--
-- 背景：当前签收/录结果/完成/发货回厂四个动作在后端硬校验"必须厂商账号"，
--       厂商不登录系统时外协单永远停在已发料，收货无法进行。
--       业务要求：厂商暂不入系统，由工单负责人/工序负责人代办，
--       同时保留厂商账号及其操作能力。
--
-- 改动：
--   1. qxx_wm_outsource_order 加 agent_operator（代操作人；NULL=本人操作）
--   2. 菜单加 28807「代厂商操作」权限 mes:wm:outsource:agentOps
--   3. 授权给 admin(1) + 仓库管理(100) + 生产管理(107)
--
-- 注：sys_menu / sys_role_menu 无 factory_id 的按框架表处理；
--     sys_role_menu 有 factory_id，需显式写。
-- @author qixiaoxia
-- ═══════════════════════════════════════════════════════════════════════

SET NAMES utf8mb4;

-- 1. 外协单头加代操作人（幂等）
DROP PROCEDURE IF EXISTS add_col_if_missing;
CREATE PROCEDURE add_col_if_missing(IN tbl VARCHAR(64), IN col VARCHAR(64), IN ddl TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=tbl AND column_name=col) THEN
        SET @s = ddl; PREPARE stmt FROM @s; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
END;

CALL add_col_if_missing('qxx_wm_outsource_order', 'agent_operator',
    'ALTER TABLE qxx_wm_outsource_order ADD COLUMN agent_operator varchar(64) DEFAULT NULL COMMENT ''代操作人(内部员工代厂商操作时记录，NULL=厂商本人操作)''');

DROP PROCEDURE IF EXISTS add_col_if_missing;

-- 2. 菜单：代厂商操作权限（28806 已被厂商签收占用，用 28807）
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT 28807, '代厂商操作', 28800, 7, 'F', '0', '0', 'mes:wm:outsource:agentOps', 'admin', NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 28807);

-- 3. 角色授权：admin(1, factory_id=0) + 仓库管理(100) + 生产管理(107)
INSERT INTO sys_role_menu (role_id, menu_id, factory_id)
SELECT 1, 28807, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = 1 AND rm.menu_id = 28807 AND rm.factory_id = 0);

INSERT INTO sys_role_menu (role_id, menu_id, factory_id)
SELECT 100, 28807, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = 100 AND rm.menu_id = 28807 AND rm.factory_id = 1);

INSERT INTO sys_role_menu (role_id, menu_id, factory_id)
SELECT 107, 28807, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = 107 AND rm.menu_id = 28807 AND rm.factory_id = 1);
