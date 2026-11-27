-- 生产任务状态新增 DISPATCHED（已下发待开工）
-- 语义：工单开工后任务批量下发 → DISPATCHED（工位可见、未开始、不可报工）；
--       工人实际开工 → PRODUCING；暂停 → PAUSED；恢复 → PRODUCING。
-- 与 ProConstants.TASK_STATUS_DISPATCHED 对齐。sys_dict_* 为系统级表，无 factory_id。

-- 1. 文案对齐：NORMAL 由「正常」调整为「待下发」
UPDATE sys_dict_data
SET dict_label = '待下发', list_class = 'primary', remark = '已排产待下发'
WHERE dict_type = 'mes_pro_task_status' AND dict_value = 'NORMAL';

-- 2. 新增 DISPATCHED
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 3, '已下发', 'DISPATCHED', 'mes_pro_task_status', '', 'warning', 'N', '0', 'system', NOW(), '已派工到工位，待开工'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_pro_task_status' AND dict_value = 'DISPATCHED'
);

-- 3. 后续状态排序顺延，保证下拉顺序：待排产 → 待下发 → 已下发 → 生产中 → 已完成 → 暂停 → 取消
UPDATE sys_dict_data SET dict_sort = 1 WHERE dict_type = 'mes_pro_task_status' AND dict_value = 'PREPARE';
UPDATE sys_dict_data SET dict_sort = 2 WHERE dict_type = 'mes_pro_task_status' AND dict_value = 'NORMAL';
UPDATE sys_dict_data SET dict_sort = 4 WHERE dict_type = 'mes_pro_task_status' AND dict_value = 'PRODUCING';
UPDATE sys_dict_data SET dict_sort = 5 WHERE dict_type = 'mes_pro_task_status' AND dict_value = 'COMPLETED';
UPDATE sys_dict_data SET dict_sort = 6 WHERE dict_type = 'mes_pro_task_status' AND dict_value = 'PAUSED';
UPDATE sys_dict_data SET dict_sort = 7 WHERE dict_type = 'mes_pro_task_status' AND dict_value = 'CANCEL';
