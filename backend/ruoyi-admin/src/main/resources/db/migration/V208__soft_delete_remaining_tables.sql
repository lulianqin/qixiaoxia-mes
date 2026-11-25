-- ============================================================
-- V208: 为尚未支持逻辑删除的表补 del_flag 列
-- 0=存在  2=删除（与 sys_user/sys_role/sys_dept 保持一致）
-- 涉及的删除接口已在本版本改为 update ... set del_flag='2'
-- 幂等：列已存在则跳过
-- 注意：sys_post 无 factory_id，不加 idx_del_flag 索引
-- ============================================================

DROP PROCEDURE IF EXISTS qxx_add_del_flag_v208;
DELIMITER $$
CREATE PROCEDURE qxx_add_del_flag_v208(IN tbl VARCHAR(64), IN cn VARCHAR(64))
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_schema = DATABASE() AND table_name = tbl AND column_name = 'del_flag') THEN
    SET @s = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN `del_flag` char(1) NOT NULL DEFAULT ''0'' COMMENT ''', cn, '删除标志（0代表存在 2代表删除）''');
    PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
  END IF;
END$$
DELIMITER ;

CALL qxx_add_del_flag_v208('sys_post', '岗位');
CALL qxx_add_del_flag_v208('qxx_md_item_type', '物料分类');
CALL qxx_add_del_flag_v208('qxx_md_vendor', '供应商');

DROP PROCEDURE IF EXISTS qxx_add_del_flag_v208;

-- ============================================================
-- 报价单新增软删除按钮权限（原 V181 只建了 query/edit/submit）
-- sys_menu 为全局表；sys_role_menu 含 factory_id，Flyway 裸 JDBC 须显式写 0
-- 幂等：menu_id / role_menu 组合存在则跳过
-- ============================================================
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT 2974, '报价单删除', 2970, 4, 'F', '0', '0', 'mes:sal:quote:remove', 'admin', sysdate()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2974);

INSERT INTO sys_role_menu (role_id, menu_id, factory_id)
SELECT 1, 2974, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = 1 AND menu_id = 2974 AND factory_id = 0);
