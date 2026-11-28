-- ============================================================
-- V218: 菜单「纸卷明细」→「库存实物实例」
--
-- 背景：
--   旧 qxx_wm_roll_detail 是纸张专用表，正式环境未投用。V215 起实物统一由
--   qxx_wm_stock_instance 承载（一卷纸 / 一根钢管 / 一桶油墨），分切外协
--   也改为写实例表（SlittingResultStrategy）。原菜单仍指向旧表的 CRUD 页面，
--   继续保留会让人误以为旧表还在用，且新增/修改会写脏数据。
--
-- 本迁移只改菜单指向与权限串，不动业务数据，也不删旧表。
--   1. 仓库管理 → 纸卷明细：改名为「库存实物实例」，组件指向新页面，
--      权限串换为 mes:wm:stock_instance:list（按钮权限见 V216）；
--   2. 旧 mes:wm:roll_detail:* 按钮权限置为停用（status='1'），避免角色配置时误勾。
--
-- 幂等：可重复执行。字符集：utf8mb4    日期：2026-11-27
-- ============================================================

SET NAMES utf8mb4;

-- 1. 主菜单指向通用实例列表页
UPDATE sys_menu
   SET menu_name = '库存实物实例',
       component = 'mes/wm/stock_instance/index',
       perms     = 'mes:wm:stock_instance:list',
       icon      = 'Box',
       remark    = 'V218 纸卷明细→通用实物实例（qxx_wm_stock_instance）'
 WHERE parent_id = 2002
   AND path = 'roll_detail';

-- 2. 旧纸卷明细按钮权限停用（不删除，保留历史角色关联不受影响）
UPDATE sys_menu
   SET status = '1',
       remark = 'V218 已停用：纸卷明细改为通用实物实例'
 WHERE perms LIKE 'mes:wm:roll_detail:%'
   AND (status IS NULL OR status <> '1');
