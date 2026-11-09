-- ============================================================
-- V175: 左侧菜单树重组
--
-- 目标结构（一级菜单，首页为常量路由始终第一）：
--   1. 组织管理（原“系统管理”改名，保留用户/角色/部门/岗位/通知公告）
--   2. 主数据管理
--   3. 仓库管理
--   4. 生产管理
--   5. 质量管理
--   6. 设备工具管理（设备管理 + 工装管理 合并）
--   7. 采购管理
--   8. 日历管理
--   9. 系统管理（原 MES管理/系统管理，接管菜单/字典/参数/日志/API Key）
--  10. 销售管理
--
-- 说明：
--   1. 菜单 path 保持原有 URL，避免前端硬编码跳转失效：
--      一级目录 path 使用 mes/{模块}，使其前端路由仍为 /mes/{模块}/{页面}；
--      合并后的“设备工具管理”一级 path 为 mes，子菜单 path 为 dv/xxx、tm/xxx。
--   2. route_name 显式指定，避免含斜杠 path 生成非法路由名。
--   3. 幂等：全部按 menu_id 更新/删除，可重复执行。
--   4. sys_menu / sys_role_menu 为系统全局表，无 factory_id。
-- ============================================================

SET NAMES utf8mb4;

-- 1. 原一级“系统管理”改名为“组织管理”，仅保留组织类菜单
UPDATE sys_menu SET menu_name = '组织管理', order_num = 1 WHERE menu_id = 1;

-- 2. 组织管理下的其余菜单迁移到“系统管理”（2009）
UPDATE sys_menu SET parent_id = 2009, order_num = 7 WHERE menu_id = 102;  -- 菜单管理
UPDATE sys_menu SET parent_id = 2009, order_num = 8 WHERE menu_id = 105;  -- 字典管理
UPDATE sys_menu SET parent_id = 2009, order_num = 9 WHERE menu_id = 106;  -- 参数设置
UPDATE sys_menu SET parent_id = 2009, order_num = 10 WHERE menu_id = 108; -- 日志管理（目录）
UPDATE sys_menu SET parent_id = 2009, order_num = 11 WHERE menu_id = 118; -- API Key管理

-- 3. MES管理下的二级目录提升为一级
UPDATE sys_menu SET parent_id = 0, path = 'mes/md',  route_name = 'Md',  order_num = 2,  icon = 'table'   WHERE menu_id = 2001;
UPDATE sys_menu SET parent_id = 0, path = 'mes/wm',  route_name = 'Wm',  order_num = 3                    WHERE menu_id = 2002;
UPDATE sys_menu SET parent_id = 0, path = 'mes/pro', route_name = 'Pro', order_num = 4                    WHERE menu_id = 2003;
UPDATE sys_menu SET parent_id = 0, path = 'mes/pur', route_name = 'Pur', order_num = 7                    WHERE menu_id = 2006;
UPDATE sys_menu SET parent_id = 0, path = 'mes/cal', route_name = 'Cal', order_num = 8                    WHERE menu_id = 2007;
UPDATE sys_menu SET parent_id = 0, path = 'mes/sys', route_name = 'Sys', order_num = 9                    WHERE menu_id = 2009;
UPDATE sys_menu SET parent_id = 0, path = 'mes/sal', route_name = 'Sal', order_num = 10                   WHERE menu_id = 2900;

-- 4. 质量管理（28900）提升到生产管理之后
UPDATE sys_menu SET order_num = 5 WHERE menu_id = 28900;

-- 5. 设备管理 + 工装管理 合并为“设备工具管理”
--    一级 path 用 mes，子菜单路径保留 dv/、tm/ 前缀，前端 URL 不变
UPDATE sys_menu SET menu_name = '设备工具管理', parent_id = 0, path = 'mes',
                  route_name = 'Dv', order_num = 6, icon = 'monitor' WHERE menu_id = 2005;

UPDATE sys_menu SET parent_id = 2005, path = 'dv/machinerytype', route_name = 'DvMachinerytype', order_num = 1 WHERE menu_id = 23343;
UPDATE sys_menu SET parent_id = 2005, path = 'dv/machinery',     route_name = 'DvMachinery',     order_num = 2 WHERE menu_id = 23348;

UPDATE sys_menu SET parent_id = 2005, path = 'tm/tooltype', route_name = 'TmTooltype', order_num = 3 WHERE menu_id = 23333;
UPDATE sys_menu SET parent_id = 2005, path = 'tm/tool',     route_name = 'TmTool',     order_num = 4 WHERE menu_id = 23338;

-- 6. 清理废弃目录：MES管理（2000，二级已全部提升）、工装管理（2008，已合并）、
--    质量管理1（2004，停用隐藏）
DELETE FROM sys_role_menu WHERE menu_id IN (2000, 2008, 2004);
DELETE FROM sys_menu WHERE menu_id IN (2000, 2008, 2004);
