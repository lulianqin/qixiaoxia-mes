-- ============================================================
-- 关闭登录验证码
--
-- 说明：
--   1. 复用 RuoYi 内置参数开关 sys.account.captchaEnabled，置为 false。
--   2. 生效后 /captchaImage 返回 captchaEnabled=false，前端登录/注册页
--      自动隐藏验证码输入框，后端 SysLoginService 跳过验证码校验。
--   3. 幂等：仅按 config_key 更新 value，可重复执行。
--   4. sys_config 为系统全局表，无 factory_id。
-- ============================================================

SET NAMES utf8mb4;

UPDATE sys_config
SET config_value = 'false',
    update_by    = 'admin',
    update_time  = sysdate()
WHERE config_key = 'sys.account.captchaEnabled';
