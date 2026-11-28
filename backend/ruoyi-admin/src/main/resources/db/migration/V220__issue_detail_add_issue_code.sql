-- ============================================================
-- V220: 补 qxx_wm_issue_detail.issue_code
--
-- 背景：
--   实体 WmIssueDetail 与 WmIssueDetailMapper.xml 的 selectVo/resultMap 都使用
--   issue_code，但建表脚本里没有这一列。写路径用的是动态 <if>，单号为空时不写，
--   所以发料一直没报错；一旦走「发料明细列表」查询（selectVo 显式列出该列）
--   就报 Unknown column 'issue_code' in 'field list'。
--
--   本迁移补列，并把存量明细的单号按 issue_id 回填（同单据内一致，便于排查）。
--
-- 幂等：列存在则跳过；回填只处理空值。字符集：utf8mb4    日期：2026-11-27
-- ============================================================

SET NAMES utf8mb4;

SET @col_exists := (
  SELECT COUNT(*) FROM information_schema.columns
   WHERE table_schema = DATABASE()
     AND table_name = 'qxx_wm_issue_detail'
     AND column_name = 'issue_code'
);

SET @ddl := IF(@col_exists = 0,
  'ALTER TABLE qxx_wm_issue_detail ADD COLUMN issue_code varchar(64) default null comment ''领料单编码(冗余,便于明细追溯)'' AFTER issue_id',
  'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 存量明细回填单号
UPDATE qxx_wm_issue_detail d
  JOIN qxx_wm_issue_header h ON h.issue_id = d.issue_id
   SET d.issue_code = h.issue_code
 WHERE (d.issue_code IS NULL OR d.issue_code = '')
   AND h.issue_code IS NOT NULL;
