-- ============================================================
-- V189: 一期菜单命名调整
--
-- 含：
--   ① 「外协管理」菜单改名「加工单」（路由与权限不变）
--   ② 生产工单菜单下补充「关联单据」查询按钮
--
-- 字符集：utf8mb4
-- 日期：2026-11-15
-- ============================================================

SET NAMES utf8mb4;

-- ① 外协管理 → 加工单
UPDATE sys_menu
SET menu_name = '加工单'
WHERE perms = 'mes:wm:outsource:list'
  AND menu_name IN ('外协管理', '外协订单', '外协加工');

-- ② 关联单据（采购单/加工单聚合查看）
INSERT INTO sys_menu (menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT '关联单据', p.menu_id, 21, 'F', '0', '0', 'mes:pro:workorder:relatedDocs', 'admin', sysdate()
FROM (SELECT menu_id FROM sys_menu WHERE parent_id = 2003 AND path = 'workorder' AND menu_type = 'C' LIMIT 1) p
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workorder:relatedDocs');
