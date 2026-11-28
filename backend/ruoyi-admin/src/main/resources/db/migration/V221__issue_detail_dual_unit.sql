-- ============================================================
-- V221: 补 qxx_wm_issue_detail 的双单位字段
--
-- 背景：
--   实体 WmIssueDetail 与 Mapper 的 selectVo/insert/update 都使用
--   unit2 / unit2_name / conversion_rate / quantity2（辅助单位与换算），
--   但建表脚本里没有这四列。写路径是动态 <if>，只有传了辅助单位才写，
--   所以历史发料没报错；一旦查询「发料明细列表」就报 Unknown column 'unit2'。
--
--   本迁移补齐四列（可空），不改存量数据。
--
-- 幂等：逐列判断存在性。字符集：utf8mb4    日期：2026-11-27
-- ============================================================

SET NAMES utf8mb4;

SET @c := (SELECT COUNT(*) FROM information_schema.columns
            WHERE table_schema = DATABASE() AND table_name = 'qxx_wm_issue_detail' AND column_name = 'unit2');
SET @s := IF(@c = 0,
  'ALTER TABLE qxx_wm_issue_detail ADD COLUMN unit2 varchar(64) default null comment ''辅助单位编码(卷/根/桶)'' AFTER unit_name',
  'SELECT 1');
PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;

SET @c := (SELECT COUNT(*) FROM information_schema.columns
            WHERE table_schema = DATABASE() AND table_name = 'qxx_wm_issue_detail' AND column_name = 'unit2_name');
SET @s := IF(@c = 0,
  'ALTER TABLE qxx_wm_issue_detail ADD COLUMN unit2_name varchar(64) default null comment ''辅助单位名称'' AFTER unit2',
  'SELECT 1');
PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;

SET @c := (SELECT COUNT(*) FROM information_schema.columns
            WHERE table_schema = DATABASE() AND table_name = 'qxx_wm_issue_detail' AND column_name = 'conversion_rate');
SET @s := IF(@c = 0,
  'ALTER TABLE qxx_wm_issue_detail ADD COLUMN conversion_rate decimal(18,6) default null comment ''主辅单位换算率(辅助→主)'' AFTER unit2_name',
  'SELECT 1');
PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;

SET @c := (SELECT COUNT(*) FROM information_schema.columns
            WHERE table_schema = DATABASE() AND table_name = 'qxx_wm_issue_detail' AND column_name = 'quantity2');
SET @s := IF(@c = 0,
  'ALTER TABLE qxx_wm_issue_detail ADD COLUMN quantity2 decimal(18,4) default null comment ''发料数量(辅助单位)'' AFTER quantity',
  'SELECT 1');
PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
