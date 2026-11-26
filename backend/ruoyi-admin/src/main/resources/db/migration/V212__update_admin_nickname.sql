-- ============================================================
-- V212: 将 admin 用户昵称改为「超级管理员」
--
-- 背景：
--   V01 初始化脚本中 admin 的 nick_name 为「若依」，与角色名及实际使用不符。
--   V01 已执行，不能直接修改（Flyway checksum），故以新迁移幂等更新。
-- 口径：
--   仅处理 user_id=1 且 user_name='admin' 的超级管理员账号，重复执行无副作用。
-- 字符集：utf8mb4
-- 日期：2026-11-26
-- ============================================================

SET NAMES utf8mb4;

UPDATE sys_user
SET nick_name = '超级管理员'
WHERE user_id = 1
  AND user_name = 'admin'
  AND (nick_name IS NULL OR nick_name <> '超级管理员');
