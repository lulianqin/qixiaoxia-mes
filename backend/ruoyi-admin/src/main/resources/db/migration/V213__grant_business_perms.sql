-- ============================================================
-- V213: 补齐业务按钮权限，并拆分工序操作权限
--
-- 背景：
--   1) 生产工单菜单(2300) perms 为空且无 CRUD 子权限，导致
--      mes:pro:workorder:query/add/edit/remove/export 在角色配置中无法勾选，
--      非 admin 角色访问工单详情/齐套/排产等一律 403。
--   2) 扫描全后端发现 235 个业务权限串在代码中使用但 sys_menu 未定义，
--      对应按钮无法分配给任何角色。
--   3) 工序下发/开工/完成/编辑/取消原先共用 mes:pro:task:edit，
--      现拆为 dispatch/start/complete/edit/cancel 五个独立权限。
--
-- 口径：
--   - 所有 INSERT 均按 perms 做 NOT EXISTS 幂等判断，可重复执行；
--   - 新权限挂在对应业务页面菜单下，角色配置界面可直接勾选；
--   - 仅补权限数据，不改任何业务表数据。
-- 字符集：utf8mb4    日期：2026-11-26
-- ============================================================

SET NAMES utf8mb4;

-- 1. 生产工单列表权限（2300 本身 perms 为空，且 2305 已占用同父级下的 list，
--    受 uk_parent_perms 限制不能再给 2300 设置同一权限，故新增独立 F 记录）
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产工单-列表', 2300, 100, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:workorder:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workorder:list' AND parent_id = 2300);

-- 2. 补救生产工单下缺失/挂错父级的流转单、关联单据、豁免开工权限
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产工单-生成流转单', 2300, 90, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:workorder:flowSheet', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workorder:flowSheet');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产工单-保存流转单', 2300, 91, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:workorder:flowSheetSave', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workorder:flowSheetSave');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产工单-关联单据', 2300, 92, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:workorder:relatedDocs', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workorder:relatedDocs');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产工单-豁免开工', 2300, 93, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:workorder:override', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workorder:override');

UPDATE sys_menu
SET parent_id = 2300
WHERE perms = 'mes:pro:workorder:override'
  AND parent_id <> 2300;

-- 3. 全量补齐业务按钮权限（235 个）+ 工序 5 个独立权限中的 4 个新增项
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '计划班组-列表', 2007, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:cal:plan-team:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:cal:plan-team:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '班次-列表', 2007, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:cal:shift:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:cal:shift:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '班组成员-列表', 2007, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:cal:team-member:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:cal:team-member:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '设备类型-导出', 23343, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:dv:machinerytype:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:dv:machinerytype:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料主数据-新增', 2101, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:attrDef:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:attrDef:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料主数据-修改', 2101, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:attrDef:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:attrDef:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料主数据-导出', 2101, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:attrDef:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:attrDef:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料主数据-查询', 2101, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:attrDef:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:attrDef:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料主数据-删除', 2101, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:attrDef:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:attrDef:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料主数据-新增', 2101, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:bom:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:bom:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料主数据-修改', 2101, 107, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:bom:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:bom:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料主数据-导出', 2101, 108, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:bom:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:bom:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料主数据-列表', 2101, 109, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:bom:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:bom:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料主数据-查询', 2101, 110, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:bom:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:bom:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料主数据-删除', 2101, 111, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:bom:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:bom:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '客户管理-导入', 2105, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:client:import', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:client:import');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '工厂-列表', 2001, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:factory:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:factory:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料主数据-导入', 2101, 112, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:item:import', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:item:import');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料分类-导出', 2102, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:itemtype:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:itemtype:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '计量单位-新增', 2106, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:unitmeasure:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:unitmeasure:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '计量单位-修改', 2106, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:unitmeasure:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:unitmeasure:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '计量单位-导出', 2106, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:unitmeasure:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:unitmeasure:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '计量单位-查询', 2106, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:unitmeasure:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:unitmeasure:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '计量单位-删除', 2106, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:unitmeasure:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:unitmeasure:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '供应商管理-导入', 2104, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:vendor:import', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:vendor:import');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '车间管理-导出', 2107, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:workshop:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:workshop:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '工作站管理-导出', 2108, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:md:workstation:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:md:workstation:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '流转卡-新增', 2304, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:cardprocess:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:cardprocess:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '流转卡-修改', 2304, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:cardprocess:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:cardprocess:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '流转卡-导出', 2304, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:cardprocess:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:cardprocess:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '流转卡-列表', 2304, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:cardprocess:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:cardprocess:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '流转卡-查询', 2304, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:cardprocess:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:cardprocess:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '流转卡-删除', 2304, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:cardprocess:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:cardprocess:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产报工-新增', 2303, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:feedbackparam:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:feedbackparam:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产报工-修改', 2303, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:feedbackparam:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:feedbackparam:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产报工-导出', 2303, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:feedbackparam:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:feedbackparam:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产报工-列表', 2303, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:feedbackparam:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:feedbackparam:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产报工-查询', 2303, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:feedbackparam:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:feedbackparam:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产报工-删除', 2303, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:feedbackparam:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:feedbackparam:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料追溯-新增', 2307, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:materialtrace:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:materialtrace:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料追溯-修改', 2307, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:materialtrace:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:materialtrace:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料追溯-导出', 2307, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:materialtrace:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:materialtrace:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料追溯-列表', 2307, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:materialtrace:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:materialtrace:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '物料追溯-删除', 2307, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:materialtrace:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:materialtrace:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '用户工作站-导出', 2309, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:userworkstation:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:userworkstation:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产工单-新增', 2300, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:workorder:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workorder:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产工单-修改', 2300, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:workorder:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workorder:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产工单-导出', 2300, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:workorder:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workorder:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产工单-查询', 2300, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:workorder:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workorder:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产工单-删除', 2300, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:workorder:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workorder:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '上下工记录-导出', 2308, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:workrecord:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:workrecord:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购订单明细-导出', 23293, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pur:order-line:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pur:order-line:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购订单详情-导出', 2921, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pur:order:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pur:order:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '编码规则-新增', 2910, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:sys:autocodepart:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:sys:autocodepart:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '编码规则-修改', 2910, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:sys:autocodepart:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:sys:autocodepart:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '编码规则-导出', 2910, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:sys:autocodepart:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:sys:autocodepart:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '编码规则-列表', 2910, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:sys:autocodepart:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:sys:autocodepart:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '编码规则-查询', 2910, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:sys:autocodepart:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:sys:autocodepart:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '编码规则-删除', 2910, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:sys:autocodepart:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:sys:autocodepart:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '系统消息-修改', 2950, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:sys:message:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:sys:message:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '工装夹具清单-导出', 23338, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:tm:tool:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:tm:tool:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '工装夹具类型-导出', 23333, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:tm:tooltype:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:tm:tooltype:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '赋码管理-新增', 23199, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:barcode:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:barcode:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '赋码管理-修改', 23199, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:barcode:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:barcode:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '赋码管理-导出', 23199, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:barcode:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:barcode:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '赋码管理-查询', 23199, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:barcode:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:barcode:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '赋码管理-删除', 23199, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:barcode:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:barcode:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '批次管理-新增', 23191, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:batch:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:batch:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '批次管理-修改', 23191, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:batch:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:batch:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '批次管理-导出', 23191, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:batch:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:batch:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '批次管理-查询', 23191, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:batch:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:batch:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '批次管理-删除', 23191, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:batch:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:batch:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购入库-导出', 23362, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:item_recpt:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:item_recpt:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购入库-新增', 23362, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:item_recpt_detail:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:item_recpt_detail:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购入库-修改', 23362, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:item_recpt_detail:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:item_recpt_detail:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购入库-导出', 23362, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:item_recpt_detail:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:item_recpt_detail:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购入库-列表', 23362, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:item_recpt_detail:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:item_recpt_detail:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购入库-查询', 23362, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:item_recpt_detail:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:item_recpt_detail:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购入库-删除', 23362, 107, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:item_recpt_detail:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:item_recpt_detail:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购入库-新增', 23362, 108, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:item_recpt_line:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:item_recpt_line:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购入库-修改', 23362, 109, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:item_recpt_line:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:item_recpt_line:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购入库-导出', 23362, 110, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:item_recpt_line:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:item_recpt_line:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购入库-查询', 23362, 111, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:item_recpt_line:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:item_recpt_line:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购入库-删除', 23362, 112, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:item_recpt_line:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:item_recpt_line:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库存现有量-导出', 23360, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:material_stock:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:material_stock:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项出库-新增', 23194, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_issue:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_issue:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项出库-修改', 23194, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_issue:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_issue:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项出库-导出', 23194, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_issue:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_issue:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项出库-列表', 23194, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_issue:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_issue:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项出库-查询', 23194, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_issue:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_issue:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项出库-删除', 23194, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_issue:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_issue:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项出库-新增', 23194, 107, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_issue_line:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_issue_line:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项出库-修改', 23194, 108, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_issue_line:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_issue_line:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项出库-导出', 23194, 109, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_issue_line:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_issue_line:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项出库-列表', 23194, 110, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_issue_line:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_issue_line:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项出库-查询', 23194, 111, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_issue_line:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_issue_line:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项出库-删除', 23194, 112, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_issue_line:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_issue_line:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项入库-新增', 23193, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_recpt:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_recpt:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项入库-修改', 23193, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_recpt:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_recpt:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项入库-导出', 23193, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_recpt:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_recpt:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项入库-列表', 23193, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_recpt:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_recpt:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项入库-查询', 23193, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_recpt:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_recpt:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项入库-删除', 23193, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_recpt:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_recpt:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项入库-新增', 23193, 107, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_recpt_line:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_recpt_line:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项入库-修改', 23193, 108, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_recpt_line:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_recpt_line:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项入库-导出', 23193, 109, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_recpt_line:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_recpt_line:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项入库-列表', 23193, 110, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_recpt_line:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_recpt_line:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项入库-查询', 23193, 111, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_recpt_line:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_recpt_line:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '杂项入库-删除', 23193, 112, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:misc_recpt_line:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:misc_recpt_line:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '加工单-代操作', 28800, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:outsource:agentOps', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:outsource:agentOps');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '加工单-修改', 28800, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:outsource:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:outsource:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '加工单-删除', 28800, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:outsource:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:outsource:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '装箱管理-新增', 23200, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:package:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:package:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '装箱管理-修改', 23200, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:package:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:package:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '装箱管理-导出', 23200, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:package:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:package:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '装箱管理-查询', 23200, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:package:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:package:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '装箱管理-删除', 23200, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:package:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:package:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '装箱管理-新增', 23200, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:package_line:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:package_line:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '装箱管理-修改', 23200, 107, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:package_line:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:package_line:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '装箱管理-导出', 23200, 108, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:package_line:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:package_line:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '装箱管理-列表', 23200, 109, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:package_line:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:package_line:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '装箱管理-查询', 23200, 110, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:package_line:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:package_line:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '装箱管理-删除', 23200, 111, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:package_line:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:package_line:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售出库-新增', 23377, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:product_sales_detail:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:product_sales_detail:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售出库-修改', 23377, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:product_sales_detail:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:product_sales_detail:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售出库-导出', 23377, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:product_sales_detail:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:product_sales_detail:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售出库-列表', 23377, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:product_sales_detail:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:product_sales_detail:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售出库-查询', 23377, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:product_sales_detail:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:product_sales_detail:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售出库-删除', 23377, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:product_sales_detail:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:product_sales_detail:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售出库-新增', 23377, 107, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:product_sales_line:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:product_sales_line:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售出库-修改', 23377, 108, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:product_sales_line:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:product_sales_line:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售出库-导出', 23377, 109, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:product_sales_line:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:product_sales_line:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售出库-列表', 23377, 110, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:product_sales_line:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:product_sales_line:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售出库-查询', 23377, 111, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:product_sales_line:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:product_sales_line:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售出库-删除', 23377, 112, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:product_sales_line:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:product_sales_line:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '纸卷明细-新增', 23201, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:roll_detail:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:roll_detail:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '纸卷明细-修改', 23201, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:roll_detail:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:roll_detail:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '纸卷明细-导出', 23201, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:roll_detail:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:roll_detail:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '纸卷明细-列表', 23201, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:roll_detail:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:roll_detail:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '纸卷明细-查询', 23201, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:roll_detail:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:roll_detail:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '纸卷明细-删除', 23201, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:roll_detail:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:roll_detail:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-新增', 23198, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-修改', 23198, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-导出', 23198, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-列表', 23198, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-查询', 23198, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-删除', 23198, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-新增', 23198, 107, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales_detail:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales_detail:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-修改', 23198, 108, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales_detail:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales_detail:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-导出', 23198, 109, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales_detail:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales_detail:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-列表', 23198, 110, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales_detail:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales_detail:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-查询', 23198, 111, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales_detail:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales_detail:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-删除', 23198, 112, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales_detail:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales_detail:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-新增', 23198, 113, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales_line:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales_line:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-修改', 23198, 114, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales_line:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales_line:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-导出', 23198, 115, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales_line:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales_line:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-列表', 23198, 116, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales_line:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales_line:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-查询', 23198, 117, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales_line:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales_line:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '销售退货-删除', 23198, 118, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_sales_line:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_sales_line:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-新增', 23197, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-修改', 23197, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-导出', 23197, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-查询', 23197, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-删除', 23197, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-新增', 23197, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor_detail:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor_detail:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-修改', 23197, 107, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor_detail:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor_detail:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-导出', 23197, 108, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor_detail:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor_detail:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-列表', 23197, 109, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor_detail:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor_detail:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-查询', 23197, 110, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor_detail:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor_detail:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-删除', 23197, 111, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor_detail:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor_detail:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-新增', 23197, 112, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor_line:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor_line:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-修改', 23197, 113, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor_line:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor_line:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-导出', 23197, 114, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor_line:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor_line:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-列表', 23197, 115, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor_line:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor_line:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-查询', 23197, 116, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor_line:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor_line:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '采购退货-删除', 23197, 117, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rt_vendor_line:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rt_vendor_line:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产退料-导出', 2207, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rtissue:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rtissue:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产退料-新增', 2207, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rtissuedetail:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rtissuedetail:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产退料-修改', 2207, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rtissuedetail:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rtissuedetail:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产退料-导出', 2207, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rtissuedetail:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rtissuedetail:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产退料-列表', 2207, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rtissuedetail:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rtissuedetail:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产退料-查询', 2207, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rtissuedetail:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rtissuedetail:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产退料-删除', 2207, 107, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rtissuedetail:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rtissuedetail:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产退料-新增', 2207, 108, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rtissueline:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rtissueline:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产退料-修改', 2207, 109, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rtissueline:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rtissueline:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产退料-导出', 2207, 110, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rtissueline:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rtissueline:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产退料-列表', 2207, 111, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rtissueline:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rtissueline:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产退料-查询', 2207, 112, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rtissueline:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rtissueline:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '生产退料-删除', 2207, 113, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:rtissueline:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:rtissueline:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库存盘点-新增', 23372, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_taking:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_taking:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库存盘点-修改', 23372, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_taking:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_taking:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库存盘点-导出', 23372, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_taking:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_taking:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库存盘点-列表', 23372, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_taking:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_taking:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库存盘点-查询', 23372, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_taking:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_taking:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库存盘点-删除', 23372, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_taking:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_taking:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '盘点方案-新增', 23196, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_taking_plan:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_taking_plan:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '盘点方案-修改', 23196, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_taking_plan:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_taking_plan:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '盘点方案-导出', 23196, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_taking_plan:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_taking_plan:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '盘点方案-列表', 23196, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_taking_plan:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_taking_plan:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '盘点方案-查询', 23196, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_taking_plan:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_taking_plan:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '盘点方案-删除', 23196, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:stock_taking_plan:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:stock_taking_plan:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库位定义-新增', 23189, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:storage_area:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:storage_area:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库位定义-修改', 23189, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:storage_area:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:storage_area:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库位定义-导出', 23189, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:storage_area:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:storage_area:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库位定义-列表', 23189, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:storage_area:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:storage_area:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库位定义-查询', 23189, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:storage_area:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:storage_area:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库位定义-删除', 23189, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:storage_area:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:storage_area:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库位定义-新增', 23189, 107, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:storage_location:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:storage_location:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库位定义-修改', 23189, 108, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:storage_location:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:storage_location:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库位定义-导出', 23189, 109, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:storage_location:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:storage_location:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库位定义-列表', 23189, 110, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:storage_location:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:storage_location:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库位定义-查询', 23189, 111, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:storage_location:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:storage_location:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库位定义-删除', 23189, 112, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:storage_location:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:storage_location:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库存事务-新增', 23190, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transaction:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transaction:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库存事务-修改', 23190, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transaction:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transaction:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库存事务-导出', 23190, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transaction:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transaction:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库存事务-查询', 23190, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transaction:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transaction:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '库存事务-删除', 23190, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transaction:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transaction:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-新增', 23195, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-修改', 23195, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-导出', 23195, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-查询', 23195, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-删除', 23195, 105, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-新增', 23195, 106, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer_detail:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer_detail:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-修改', 23195, 107, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer_detail:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer_detail:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-导出', 23195, 108, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer_detail:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer_detail:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-列表', 23195, 109, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer_detail:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer_detail:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-查询', 23195, 110, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer_detail:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer_detail:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-删除', 23195, 111, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer_detail:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer_detail:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-新增', 23195, 112, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer_line:add', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer_line:add');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-修改', 23195, 113, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer_line:edit', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer_line:edit');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-导出', 23195, 114, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer_line:export', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer_line:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-列表', 23195, 115, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer_line:list', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer_line:list');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-查询', 23195, 116, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer_line:query', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer_line:query');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '转移调拨-删除', 23195, 117, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:wm:transfer_line:remove', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:transfer_line:remove');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '任务下发', 2302, 101, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:task:dispatch', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:task:dispatch');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '任务开工', 2302, 102, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:task:start', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:task:start');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '任务完成', 2302, 103, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:task:complete', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:task:complete');

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '任务取消', 2302, 104, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'mes:pro:task:cancel', '#', 'flyway', NOW(), 'V213 业务权限补齐'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:task:cancel');
