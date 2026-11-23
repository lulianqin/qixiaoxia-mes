-- ============================================================
-- V206 为业务主数据/单据表增加逻辑删除标记
-- 0=存在  2=删除（与 sys_dept/sys_user/sys_role 保持一致）
-- 幂等：列/索引已存在则跳过
-- ============================================================

DROP PROCEDURE IF EXISTS qxx_add_del_flag;
DELIMITER $$
CREATE PROCEDURE qxx_add_del_flag(IN tbl VARCHAR(64), IN cn VARCHAR(64))
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_schema = DATABASE() AND table_name = tbl AND column_name = 'del_flag') THEN
    SET @s = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN `del_flag` char(1) NOT NULL DEFAULT ''0'' COMMENT ''', cn, '删除标志（0代表存在 2代表删除）''');
    PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.statistics
                  WHERE table_schema = DATABASE() AND table_name = tbl AND index_name = 'idx_del_flag') THEN
    SET @s = CONCAT('ALTER TABLE `', tbl, '` ADD KEY `idx_del_flag` (`factory_id`,`del_flag`)');
    PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
  END IF;
END$$
DELIMITER ;

CALL qxx_add_del_flag('qxx_md_item','物料');
CALL qxx_add_del_flag('qxx_pro_route','工艺路线');
CALL qxx_add_del_flag('qxx_pro_process','工序');
CALL qxx_add_del_flag('qxx_pro_workorder','生产工单');
CALL qxx_add_del_flag('qxx_sal_order','销售订单');
CALL qxx_add_del_flag('qxx_sal_quote','报价单');
CALL qxx_add_del_flag('qxx_pur_order','采购订单');
CALL qxx_add_del_flag('qxx_wm_material_stock','库存');

DROP PROCEDURE IF EXISTS qxx_add_del_flag;
