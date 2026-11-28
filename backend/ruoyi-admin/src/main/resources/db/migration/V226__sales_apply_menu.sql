-- ============================================================
-- V226: ERP 工厂出库申请单 —— 菜单与权限
--
-- 背景：
--   ERP 下发采购单后由 MES 接单生成只读「出库申请单」，仓库据此执行出库。
--   前端页面 src/views/mes/wm/sales_apply/index.vue 需要挂载到仓储管理菜单，
--   后端接口 /mes/wm/sales_apply/list、/detail/{applyId} 分别需要 list/query 权限。
--
-- 约定：
--   - sys_menu 为系统表，无 factory_id（同 V122/V154），不写 factory_id
--   - sys_menu 已有唯一约束 uk_parent_perms(parent_id, perms)，NOT EXISTS 保证幂等
--   - 不指定 menu_id，由自增分配，避免与历史迁移的硬编码 ID 冲突
--   - 授权给超管角色 role_id=1（factory_id=0）；其它角色在角色管理自行勾选
--   - Flyway 启动时自动执行，无需手工导库
-- ============================================================

SET NAMES utf8mb4;

-- 1. C 菜单：仓储管理(menu_id=2002) → 出库申请
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache,
                      menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '出库申请', 2002, 30, 'salesapply', 'mes/wm/sales_apply/index', 1, 0,
       'C', '0', '0', 'mes:wm:salesapply:list', 'documentation', 'admin', NOW(),
       'ERP下发的工厂出库申请（MES只读，仓库执行出库）'
FROM sys_menu m
WHERE m.menu_id = 2002
  AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:salesapply:list');

-- 2. F 按钮：查看（对应详情接口 /mes/wm/sales_apply/detail/{applyId}）
INSERT INTO sys_menu (menu_name, parent_id, order_num, menu_type, visible, status, perms,
                      icon, create_by, create_time, remark)
SELECT '查看出库申请', c.menu_id, 1, 'F', '0', '0', 'mes:wm:salesapply:query',
       '#', 'admin', NOW(), '查看ERP出库申请详情及明细'
FROM sys_menu c
WHERE c.perms = 'mes:wm:salesapply:list' AND c.menu_type = 'C'
  AND NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:salesapply:query');

-- 3. 授权给超级管理员角色（role_id=1, factory_id=0）
INSERT INTO sys_role_menu (role_id, menu_id, factory_id)
SELECT 1, sm.menu_id, 0
FROM sys_menu sm
WHERE sm.perms IN ('mes:wm:salesapply:list', 'mes:wm:salesapply:query')
  AND NOT EXISTS (
      SELECT 1 FROM sys_role_menu rm
      WHERE rm.role_id = 1 AND rm.menu_id = sm.menu_id AND rm.factory_id = 0
  );
