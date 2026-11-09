-- ============================================================
-- V176: 调整一级菜单顺序，并重命名“日历管理”为“排班管理”
--
-- 首页、组织管理、主数据管理、仓库管理保持最前，其后顺序：
--   生产管理 → 排班管理 → 质量管理 → 设备工具管理 → 销售管理 → 采购管理 → 系统管理
--
-- 说明：
--   1. 仅调整 order_num 与菜单名称，path/perms 不变，前端 URL 不受影响。
--   2. 幂等：全部按 menu_id 更新，可重复执行。
-- ============================================================

SET NAMES utf8mb4;

UPDATE sys_menu SET menu_name = '排班管理', order_num = 6 WHERE menu_id = 2007; -- 原日历管理

UPDATE sys_menu SET order_num = 5  WHERE menu_id = 2003; -- 生产管理
UPDATE sys_menu SET order_num = 7  WHERE menu_id = 28900; -- 质量管理
UPDATE sys_menu SET order_num = 8  WHERE menu_id = 2005; -- 设备工具管理
UPDATE sys_menu SET order_num = 9  WHERE menu_id = 2900; -- 销售管理
UPDATE sys_menu SET order_num = 10 WHERE menu_id = 2006; -- 采购管理
UPDATE sys_menu SET order_num = 11 WHERE menu_id = 2009; -- 系统管理
