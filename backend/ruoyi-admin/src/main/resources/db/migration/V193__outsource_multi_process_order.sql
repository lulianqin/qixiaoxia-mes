-- ============================================================
-- V193：加工单多工序 + 工序级扩展属性
--
-- 背景：一张加工单可含多道工序（V186 已建 qxx_wm_outsource_process_line），
--       每道工序有自己的扩展属性模板，属性值需落在工序明细行上。
--
-- 幂等：ALTER/INDEX 均先查 information_schema，重复执行跳过。
-- 字符集：utf8mb4
-- ============================================================

SET NAMES utf8mb4;

DROP PROCEDURE IF EXISTS add_col_if_missing;
CREATE PROCEDURE add_col_if_missing(IN tbl VARCHAR(64), IN col VARCHAR(64), IN ddl TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema=DATABASE() AND table_name=tbl AND column_name=col) THEN
        SET @s = ddl; PREPARE stmt FROM @s; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
END;

CALL add_col_if_missing('qxx_wm_outsource_process_line', 'ext_attrs',
    'ALTER TABLE qxx_wm_outsource_process_line ADD COLUMN ext_attrs varchar(1000) DEFAULT NULL COMMENT ''工序扩展属性JSON(按工序属性模板)'' AFTER done_qty');

DROP PROCEDURE IF EXISTS add_col_if_missing;

DROP PROCEDURE IF EXISTS add_idx_if_missing;
CREATE PROCEDURE add_idx_if_missing(IN tbl VARCHAR(64), IN idx VARCHAR(64), IN ddl TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.statistics
                   WHERE table_schema=DATABASE() AND table_name=tbl AND index_name=idx) THEN
        SET @s = ddl; PREPARE stmt FROM @s; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
END;

CALL add_idx_if_missing('qxx_wm_outsource_process_line', 'idx_opline_process',
    'ALTER TABLE qxx_wm_outsource_process_line ADD KEY idx_opline_process (factory_id, process_id)');

DROP PROCEDURE IF EXISTS add_idx_if_missing;
