-- ============================================================
-- V211 业务单据与主数据清理（软删除）+ 日志物理清理
-- 覆盖页面：客户/加工单/排产任务/报工/异常/采购入库/采购退货/
--          产品入库/生产领料/生产退料/销售出库/来料检验/过程检验/
--          编码记录/待办事项
-- 日志表（操作日志、登录日志）按需求物理删除
-- 幂等：加列用存储过程判断，置删与清日志可重复执行
-- ============================================================

SET @now = NOW();
SET @op = 'admin';

-- ---------- 1. 为 15 张主表增加 del_flag ----------
DROP PROCEDURE IF EXISTS qxx_add_del_flag_v211;
DELIMITER $$
CREATE PROCEDURE qxx_add_del_flag_v211(IN tbl VARCHAR(64), IN cn VARCHAR(64))
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_schema = DATABASE() AND table_name = tbl AND column_name = 'del_flag') THEN
    SET @s = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN `del_flag` char(1) NOT NULL DEFAULT ''0'' COMMENT ''', cn, '删除标志（0存在 2删除）''');
    PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
  END IF;
END$$
DELIMITER ;

CALL qxx_add_del_flag_v211('qxx_md_client',          '客户');
CALL qxx_add_del_flag_v211('qxx_wm_outsource_order', '加工单');
CALL qxx_add_del_flag_v211('qxx_pro_task',           '排产任务');
CALL qxx_add_del_flag_v211('qxx_pro_feedback',       '生产报工');
CALL qxx_add_del_flag_v211('qxx_pro_exception',      '异常台账');
CALL qxx_add_del_flag_v211('qxx_wm_item_recpt',      '采购入库');
CALL qxx_add_del_flag_v211('qxx_wm_rt_vendor',       '采购退货');
CALL qxx_add_del_flag_v211('qxx_wm_product_recpt',   '产品入库');
CALL qxx_add_del_flag_v211('qxx_wm_issue_header',    '生产领料');
CALL qxx_add_del_flag_v211('qxx_wm_rt_issue',        '生产退料');
CALL qxx_add_del_flag_v211('qxx_wm_product_sales',   '销售出库');
CALL qxx_add_del_flag_v211('qxx_qc_iqc',             '来料检验');
CALL qxx_add_del_flag_v211('qxx_qc_ipqc',            '过程检验');
CALL qxx_add_del_flag_v211('sys_auto_code_result',   '编码记录');
CALL qxx_add_del_flag_v211('sys_todo_list',          '待办事项');

DROP PROCEDURE IF EXISTS qxx_add_del_flag_v211;

-- ---------- 2. 全量逻辑删除（明细表随主表，不单独标记） ----------
UPDATE qxx_md_client          SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE qxx_wm_outsource_order SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE qxx_pro_task           SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE qxx_pro_feedback       SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE qxx_pro_exception      SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE qxx_wm_item_recpt      SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE qxx_wm_rt_vendor       SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE qxx_wm_product_recpt   SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE qxx_wm_issue_header    SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE qxx_wm_rt_issue        SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE qxx_wm_product_sales   SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE qxx_qc_iqc             SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE qxx_qc_ipqc            SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE sys_auto_code_result   SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';
UPDATE sys_todo_list          SET del_flag='2', update_by=@op, update_time=@now WHERE del_flag='0';

-- ---------- 3. 操作日志 / 登录日志：物理删除 ----------
-- 注意：这两张是系统审计表，按需求清空；执行前请确认已做整库备份
DELETE FROM sys_oper_log;
DELETE FROM sys_logininfor;
