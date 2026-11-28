-- ============================================================
-- V224：工序增加「排序号」
--
-- 背景：工序列表此前固定按 process_id desc 展示，无法按业务顺序维护。
-- 方案：qxx_pro_process 增加 order_num，列表按 order_num 升序展示；
--       历史工序按工厂分组、process_id 升序回填连续序号 1~N，
--       回填后立即拥有可用的业务排序，无需逐条手工维护。
-- ============================================================

SET NAMES utf8mb4;

DROP PROCEDURE IF EXISTS add_col_if_missing;
CREATE PROCEDURE add_col_if_missing(IN tbl VARCHAR(64), IN col VARCHAR(64), IN ddl TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=tbl AND column_name=col) THEN
        SET @s = ddl; PREPARE stmt FROM @s; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
END;

CALL add_col_if_missing('qxx_pro_process', 'order_num',
    'ALTER TABLE qxx_pro_process ADD COLUMN order_num INT NOT NULL DEFAULT 0 COMMENT ''排序号(升序)'' AFTER process_name');

DROP PROCEDURE IF EXISTS add_col_if_missing;

-- 历史数据回填：每个工厂独立从 1 开始，按原 process_id 顺序编号
-- 不依赖 del_flag：该列在部分环境可能不存在，回填包含已删除行只会让序号留空档，不影响使用
UPDATE qxx_pro_process t
JOIN (
    SELECT process_id,
           ROW_NUMBER() OVER (PARTITION BY factory_id ORDER BY process_id) AS rn
    FROM qxx_pro_process
) r ON r.process_id = t.process_id
SET t.order_num = r.rn
WHERE t.order_num = 0;
