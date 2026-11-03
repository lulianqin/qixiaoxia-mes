-- 外协收货自动生成的报工记录历史上只写了 workorder_code，未写 workorder_name，
-- 报工列表工单名称为空。按工单主数据回填（幂等，仅处理空值）。
UPDATE qxx_pro_feedback f
JOIN qxx_pro_workorder w
  ON w.workorder_id = f.workorder_id
 AND w.factory_id = f.factory_id
SET f.workorder_name = w.workorder_name
WHERE f.workorder_name IS NULL OR f.workorder_name = '';
