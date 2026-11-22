-- ============================================================
-- V199: 生产流转单保存权限
--
-- 背景：流转单页面支持调整产品属性/生产属性/印刷要求/包装要求/发货要求/
--       工艺流程/备注并保存（底层复用编辑工单逻辑），保存动作使用独立权限。
--
-- 字符集：utf8mb4
-- 日期：2026-11-19
-- ============================================================

SET NAMES utf8mb4;

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '保存流转单', 2300, 21, '', NULL, 'F', '0', '0', 'mes:pro:workorder:flowSheetSave', '#', 'admin', NOW(), '生产流转单保存（独立权限）'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workorder:flowSheetSave');
