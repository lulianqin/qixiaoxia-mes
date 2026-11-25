-- ============================================================
-- V207: 统一仓储菜单权限串，与后端 @PreAuthorize / 前端 v-hasPermi 对齐
--
-- 背景：早期菜单 seed 使用 mes:wm:stock / mes:wm:itemrecpt / mes:wm:rtvendor
--       等缩写，而后端 Controller 使用 mes:wm:material_stock / item_recpt /
--       rt_vendor。角色按菜单授权后，页面能进入但接口 403。
--
-- 说明：只改 perms 字符串，menu_id 不变，sys_role_menu 授权关系自动保留。
--       执行后用户需重新登录，使 LoginUser 权限缓存刷新。
-- ============================================================

-- 物料库存：mes:wm:stock:* → mes:wm:material_stock:*
UPDATE sys_menu
SET perms = REPLACE(perms, 'mes:wm:stock:', 'mes:wm:material_stock:')
WHERE perms LIKE 'mes:wm:stock:%';

-- 物料入库行：mes:wm:itemrecptline:* → mes:wm:item_recpt_line:*
UPDATE sys_menu
SET perms = REPLACE(perms, 'mes:wm:itemrecptline:', 'mes:wm:item_recpt_line:')
WHERE perms LIKE 'mes:wm:itemrecptline:%';

-- 物料入库：mes:wm:itemrecpt:* → mes:wm:item_recpt:*
UPDATE sys_menu
SET perms = REPLACE(perms, 'mes:wm:itemrecpt:', 'mes:wm:item_recpt:')
WHERE perms LIKE 'mes:wm:itemrecpt:%';

-- 采购退货：mes:wm:rtvendor:* → mes:wm:rt_vendor:*
UPDATE sys_menu
SET perms = REPLACE(perms, 'mes:wm:rtvendor:', 'mes:wm:rt_vendor:')
WHERE perms LIKE 'mes:wm:rtvendor:%';
