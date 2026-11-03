-- ═══════════════════════════════════════════════════════════════════════
-- V168 分切子卷规格回填
--
-- 背景：厂商录分切结果时以 qxx_wm_outsource_recpt_line.ext_attrs
--       ({"width":门幅, "gsm":克重}) 提交实际规格，但旧代码建子卷时
--       没有写入 qxx_wm_roll_detail.actual_width / actual_weight_gsm，
--       导致纸卷明细查不到规格。
--       代码已修复（SlittingResultStrategy.fillActualSpec）；本迁移回填历史数据。
--
-- 仅回填空值，不覆盖已有数据；ext_attrs 非法时跳过。
-- @author qixiaoxia
-- ═══════════════════════════════════════════════════════════════════════

SET NAMES utf8mb4;

UPDATE qxx_wm_roll_detail r
JOIN qxx_wm_outsource_recpt_line l
  ON l.source_ref_type = 'ROLL'
 AND l.source_ref_id = r.roll_id
SET r.actual_width = COALESCE(NULLIF(r.actual_width, ''),
        IF(JSON_VALID(l.ext_attrs), JSON_UNQUOTE(JSON_EXTRACT(l.ext_attrs, '$.width')), NULL)),
    r.actual_weight_gsm = COALESCE(NULLIF(r.actual_weight_gsm, ''),
        IF(JSON_VALID(l.ext_attrs), JSON_UNQUOTE(JSON_EXTRACT(l.ext_attrs, '$.gsm')), NULL))
WHERE l.ext_attrs IS NOT NULL
  AND (r.actual_width IS NULL OR r.actual_width = ''
       OR r.actual_weight_gsm IS NULL OR r.actual_weight_gsm = '');
