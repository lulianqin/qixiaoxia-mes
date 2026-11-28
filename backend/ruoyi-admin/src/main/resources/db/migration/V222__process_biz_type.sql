-- ============================================================
-- V222：工序增加「业务类型」，为分切外协提供显式标识
--
-- 背景：分切外协（sourceType=SLITTING）此前只能靠 process_code='SLITTING'
--       或工序名称判断，工序主数据没有分切工序时无法识别，也不允许用户
--       把任意工序标记为分切。
-- 方案：qxx_pro_process 增加 biz_type
--       NORMAL  - 普通工序（默认，走采购/加工单）
--       SLITTING- 分切工序（工单单据配置里生成「分切单」，走分切外协策略）
--       历史数据里编码为 SLITTING 的工序自动回填为分切，其余保持普通。
-- ============================================================

SET NAMES utf8mb4;

DROP PROCEDURE IF EXISTS add_col_if_missing;
CREATE PROCEDURE add_col_if_missing(IN tbl VARCHAR(64), IN col VARCHAR(64), IN ddl TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=tbl AND column_name=col) THEN
        SET @s = ddl; PREPARE stmt FROM @s; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
END;

CALL add_col_if_missing('qxx_pro_process', 'biz_type',
    'ALTER TABLE qxx_pro_process ADD COLUMN biz_type VARCHAR(20) DEFAULT ''NORMAL'' COMMENT ''业务类型:NORMAL-普通工序,SLITTING-分切'' AFTER process_name');

DROP PROCEDURE IF EXISTS add_col_if_missing;

-- 历史分切工序回填（存在才改，不影响其他工序）
UPDATE qxx_pro_process
SET biz_type = 'SLITTING'
WHERE process_code = 'SLITTING'
  AND (biz_type IS NULL OR biz_type = 'NORMAL');

-- 字典：业务类型
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)
SELECT '工序业务类型', 'mes_process_biz_type', '0', 'admin', NOW(), '工序业务类型列表'
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE dict_type = 'mes_process_biz_type');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 1, '普通工序', 'NORMAL', 'mes_process_biz_type', '', 'primary', 'Y', '0', 'admin', NOW(), '走采购单/加工单'
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_process_biz_type' AND dict_value = 'NORMAL');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 2, '分切', 'SLITTING', 'mes_process_biz_type', '', 'warning', 'N', '0', 'admin', NOW(), '单据配置中生成分切单，产出子件按实物实例管理'
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_process_biz_type' AND dict_value = 'SLITTING');
