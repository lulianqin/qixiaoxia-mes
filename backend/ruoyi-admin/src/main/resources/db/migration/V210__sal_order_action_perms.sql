-- ============================================================
-- V210: 销售订单操作按钮权限拆分
--
-- 背景：接单/取消/结单原复用 mes:sal:order:edit，无法按角色单独授权；
--       另外 V181 的「打回」菜单使用 menu_id=2917，与 V125 详情页菜单冲突，
--       导致打回按钮权限 mes:sal:order:reject 实际没有菜单行，非 admin 无法授权。
--
-- 拆分结果：
--   查看   mes:sal:order:query      （沿用查询权限，不再共用 edit）
--   接单   mes:sal:order:accept     （新增，含接单默认值接口）
--   打回   mes:sal:order:reject     （权限串沿用，本次补建菜单行）
--   修改   mes:sal:order:edit       （保持不变）
--   取消   mes:sal:order:cancel     （新增）
--   结单   mes:sal:order:close      （新增）
--
-- 授权策略：
--   接单/取消/结单：授予当前拥有「修改」(2904) 的角色，保证升级后能力不回退；
--   打回：仅授予 admin，保持升级前实际效果（原菜单缺失，非 admin 无该权限），
--         后续可在角色菜单中按需勾选。
--
-- 幂等：菜单按 perms + menu_id 判重；授权按 (role_id, menu_id, factory_id) 判重。
-- 日期：2026-11-25
-- ============================================================

SET NAMES utf8mb4;

-- ============================================================
-- ① 按钮菜单（sys_menu 为全局表，无 factory_id）
-- ============================================================
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT 2922, '销售订单接单', 2901, 12, 'F', '0', '0', 'mes:sal:order:accept', 'admin', sysdate()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:sal:order:accept')
  AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2922);

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT 2923, '销售订单取消', 2901, 13, 'F', '0', '0', 'mes:sal:order:cancel', 'admin', sysdate()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:sal:order:cancel')
  AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2923);

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT 2924, '销售订单结单', 2901, 14, 'F', '0', '0', 'mes:sal:order:close', 'admin', sysdate()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:sal:order:close')
  AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2924);

-- 打回：V181 因 menu_id 冲突未落库，本次用新 ID 补建（若已有同权限串菜单则跳过）
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT 2925, '销售订单打回', 2901, 10, 'F', '0', '0', 'mes:sal:order:reject', 'admin', sysdate()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:sal:order:reject')
  AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2925);

-- ============================================================
-- ② admin(role_id=1) 授权全部新增按钮
--    幂等：按 (role_id, menu_id, factory_id) 判重
-- ============================================================
INSERT INTO sys_role_menu (role_id, menu_id, factory_id)
SELECT 1, m.menu_id, 0
FROM sys_menu m
WHERE m.perms = 'mes:sal:order:accept'
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm
                  WHERE rm.role_id = 1 AND rm.menu_id = m.menu_id AND rm.factory_id = 0);

INSERT INTO sys_role_menu (role_id, menu_id, factory_id)
SELECT 1, m.menu_id, 0
FROM sys_menu m
WHERE m.perms = 'mes:sal:order:cancel'
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm
                  WHERE rm.role_id = 1 AND rm.menu_id = m.menu_id AND rm.factory_id = 0);

INSERT INTO sys_role_menu (role_id, menu_id, factory_id)
SELECT 1, m.menu_id, 0
FROM sys_menu m
WHERE m.perms = 'mes:sal:order:close'
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm
                  WHERE rm.role_id = 1 AND rm.menu_id = m.menu_id AND rm.factory_id = 0);

INSERT INTO sys_role_menu (role_id, menu_id, factory_id)
SELECT 1, m.menu_id, 0
FROM sys_menu m
WHERE m.perms = 'mes:sal:order:reject'
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm
                  WHERE rm.role_id = 1 AND rm.menu_id = m.menu_id AND rm.factory_id = 0);

-- ============================================================
-- ③ 现有「修改」角色继承接单/取消/结单权限（沿用原 factory_id）
-- ============================================================
INSERT INTO sys_role_menu (role_id, menu_id, factory_id)
SELECT rm.role_id, m.menu_id, rm.factory_id
FROM sys_role_menu rm
JOIN sys_menu m ON m.perms = 'mes:sal:order:accept'
WHERE rm.menu_id = 2904
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu x
                  WHERE x.role_id = rm.role_id AND x.menu_id = m.menu_id AND x.factory_id = rm.factory_id);

INSERT INTO sys_role_menu (role_id, menu_id, factory_id)
SELECT rm.role_id, m.menu_id, rm.factory_id
FROM sys_role_menu rm
JOIN sys_menu m ON m.perms = 'mes:sal:order:cancel'
WHERE rm.menu_id = 2904
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu x
                  WHERE x.role_id = rm.role_id AND x.menu_id = m.menu_id AND x.factory_id = rm.factory_id);

INSERT INTO sys_role_menu (role_id, menu_id, factory_id)
SELECT rm.role_id, m.menu_id, rm.factory_id
FROM sys_role_menu rm
JOIN sys_menu m ON m.perms = 'mes:sal:order:close'
WHERE rm.menu_id = 2904
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu x
                  WHERE x.role_id = rm.role_id AND x.menu_id = m.menu_id AND x.factory_id = rm.factory_id);
