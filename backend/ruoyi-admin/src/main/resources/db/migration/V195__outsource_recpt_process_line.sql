-- ============================================================
-- V195：加工结果明细支持按工序录入
--
-- 背景：一张加工单可含多道工序（V186/V193），代厂商录结果需按工序
--       记录本次完成数量，并回写工序行 done_qty。
--
-- 幂等：ALTER 均先查 information_schema，重复执行跳过。
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

CALL add_col_if_missing('qxx_wm_outsource_recpt_line', 'process_line_id',
    'ALTER TABLE qxx_wm_outsource_recpt_line ADD COLUMN process_line_id bigint DEFAULT NULL COMMENT ''对应加工单工序行ID'' AFTER order_id');

CALL add_col_if_missing('qxx_wm_outsource_recpt_line', 'process_id',
    'ALTER TABLE qxx_wm_outsource_recpt_line ADD COLUMN process_id bigint DEFAULT NULL COMMENT ''工序ID'' AFTER process_line_id');

CALL add_col_if_missing('qxx_wm_outsource_recpt_line', 'process_name',
    'ALTER TABLE qxx_wm_outsource_recpt_line ADD COLUMN process_name varchar(255) DEFAULT NULL COMMENT ''工序名称'' AFTER process_id');

DROP PROCEDURE IF EXISTS add_col_if_missing;

DROP PROCEDURE IF EXISTS add_idx_if_missing;
CREATE PROCEDURE add_idx_if_missing(IN tbl VARCHAR(64), IN idx VARCHAR(64), IN ddl TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.statistics
                   WHERE table_schema=DATABASE() AND table_name=tbl AND index_name=idx) THEN
        SET @s = ddl; PREPARE stmt FROM @s; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
END;

CALL add_idx_if_missing('qxx_wm_outsource_recpt_line', 'idx_orline_process_line',
    'ALTER TABLE qxx_wm_outsource_recpt_line ADD KEY idx_orline_process_line (order_id, process_line_id)');

DROP PROCEDURE IF EXISTS add_idx_if_missing;
