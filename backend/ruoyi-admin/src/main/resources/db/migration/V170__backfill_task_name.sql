-- 排产任务历史上存在 task_name 为空的记录（自动排产/工单生成等路径产品信息缺失时未生成名称），
-- 报工/任务列表任务名称显示为空。按工单名-工序名回填（幂等，仅处理空值，显式带 factory_id）。
UPDATE qxx_pro_task t
LEFT JOIN qxx_pro_workorder w
  ON w.workorder_id = t.workorder_id
 AND w.factory_id = t.factory_id
SET t.task_name = CASE
    WHEN w.workorder_name IS NOT NULL AND t.process_name IS NOT NULL THEN CONCAT(w.workorder_name, '-', t.process_name)
    WHEN w.workorder_name IS NOT NULL THEN w.workorder_name
    ELSE CONCAT('任务-', t.task_code)
END
WHERE (t.task_name IS NULL OR t.task_name = '')
  AND t.factory_id IS NOT NULL;
