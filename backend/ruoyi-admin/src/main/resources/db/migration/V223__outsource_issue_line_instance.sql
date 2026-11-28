-- ============================================================
-- V223：外协发料行绑定「库存实物实例」（分切母卷直选）
--
-- 背景：分切单（sourceType=SLITTING）发料此前只按 item+batch 发料，
--       扣的是库存桶汇总，母卷与分切出的子件之间无法建立
--       parent_instance_id 追溯关系（子件溯源断链）。
-- 方案：qxx_wm_outsource_issue_line 增加实例字段，一行绑定一个母卷：
--       instance_id   - qxx_wm_stock_instance.instance_id
--       instance_code - 实例编号快照（发料后仍可读，便于打印/对账）
--       发料执行时按实例扣减 remaining_quantity，并把实例所属
--       material_stock_id 回填到库存事务上，保证桶账与实例同步。
-- 兼容：不选实例的发料行保持原行为（按批次 FIFO 出库），仅加列。
-- 字符集：utf8mb4    日期：2026-11-27
-- ============================================================

SET NAMES utf8mb4;

DROP PROCEDURE IF EXISTS add_col_if_missing;
CREATE PROCEDURE add_col_if_missing(IN tbl VARCHAR(64), IN col VARCHAR(64), IN ddl TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=tbl AND column_name=col) THEN
        SET @s = ddl; PREPARE stmt FROM @s; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
END;

CALL add_col_if_missing('qxx_wm_outsource_issue_line', 'instance_id',
    'ALTER TABLE qxx_wm_outsource_issue_line ADD COLUMN instance_id bigint DEFAULT NULL COMMENT ''发料母卷/母件实物实例ID''');

CALL add_col_if_missing('qxx_wm_outsource_issue_line', 'instance_code',
    'ALTER TABLE qxx_wm_outsource_issue_line ADD COLUMN instance_code varchar(64) DEFAULT NULL COMMENT ''实物实例编号快照''');

DROP PROCEDURE IF EXISTS add_col_if_missing;
