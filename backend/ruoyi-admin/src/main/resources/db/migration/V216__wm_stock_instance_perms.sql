-- ============================================================
-- V216: 库存实物实例（qxx_wm_stock_instance）按钮权限
--
-- 背景：
--   V215 建了通用实物实例表与接口，WmStockInstanceController 使用
--   mes:wm:stock_instance:list/query/add/edit/remove 五个权限串，
--   但 sys_menu 未定义，非 admin 角色调用库存下钻、发料选实例会 403。
--
-- 口径：
--   权限挂在「库存现有量」菜单 23201 下；按 perms 幂等，可重复执行；
--   仅补权限数据，不动业务表。
-- 字符集：utf8mb4    日期：2026-11-27
-- ============================================================

SET NAMES utf8mb4;

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '实物实例-列表', 23201, 120, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_instance:list', '#', 'flyway', NOW(), 'V216 实物实例权限'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_instance:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '实物实例-查询', 23201, 121, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_instance:query', '#', 'flyway', NOW(), 'V216 实物实例权限'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_instance:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '实物实例-新增', 23201, 122, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_instance:add', '#', 'flyway', NOW(), 'V216 实物实例权限'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_instance:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '实物实例-修改', 23201, 123, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_instance:edit', '#', 'flyway', NOW(), 'V216 实物实例权限'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_instance:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '实物实例-删除', 23201, 124, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_instance:remove', '#', 'flyway', NOW(), 'V216 实物实例权限'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_instance:remove');
