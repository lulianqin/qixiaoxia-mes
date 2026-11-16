-- ============================================================
-- V185: 采购单支持成品/原料/辅料采购，行可关联工序任务
--
-- 背景：一期主生产单派生三类采购单（成品采购、原料采购、辅料采购），
--       多道工序可合并开一张采购单，采购行需回指工序任务。
--
-- 含：
--   ① qxx_pur_order_line 增加 task_id / process_id / process_code / process_name
--   ② 字典 mes_purchase_type 增 FINISHED / RAW
--   ③ 菜单按钮：采购单改状态
--
-- 字符集：utf8mb4
-- 日期：2026-11-15
-- ============================================================

SET NAMES utf8mb4;

-- ① 采购行关联工序任务
ALTER TABLE qxx_pur_order_line
    ADD COLUMN task_id     BIGINT       DEFAULT NULL COMMENT '工序任务ID(关联qxx_pro_task,成品采购/多工序合并)' AFTER order_id,
    ADD COLUMN process_id  BIGINT       DEFAULT NULL COMMENT '工序ID(关联qxx_pro_process)' AFTER task_id,
    ADD COLUMN process_code VARCHAR(64) DEFAULT NULL COMMENT '工序编码' AFTER process_id,
    ADD COLUMN process_name VARCHAR(255) DEFAULT NULL COMMENT '工序名称' AFTER process_code;

ALTER TABLE qxx_pur_order_line
    ADD KEY idx_pur_line_task (task_id);

-- ② 采购类型字典扩展（原有 PAPER/AUX/PACK/OTHER 保留）
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 5, '成品采购', 'FINISHED', 'mes_purchase_type', '', 'success', 'N', '0', 'admin', sysdate(), '直采成品(含委外整单加工)'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_purchase_type' AND dict_value = 'FINISHED');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 6, '原料采购', 'RAW', 'mes_purchase_type', '', 'primary', 'N', '0', 'admin', sysdate(), '原纸/原料采购'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_purchase_type' AND dict_value = 'RAW');

-- ③ 按钮权限
INSERT INTO sys_menu (menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT '采购单改状态', p.menu_id, 20, 'F', '0', '0', 'mes:pur:order:changeStatus', 'admin', sysdate()
FROM (SELECT menu_id FROM sys_menu WHERE perms = 'mes:pur:order:list' ORDER BY menu_id LIMIT 1) p
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pur:order:changeStatus');
