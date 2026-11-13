-- ============================================================
-- 外协按工序动态表单
-- 1) 工序-扩展属性绑定表（复用 qxx_md_attr_def 属性字典）
-- 2) 外协发料行增加单价/金额，扩展属性复用 ext_attrs
-- 3) 工序页面增加「外协字段」配置权限
-- ============================================================

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS qxx_wm_outsource_process_attr (
    id           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    factory_id   BIGINT       NOT NULL                COMMENT '工厂ID',
    process_id   BIGINT       NOT NULL                COMMENT '工序ID(关联qxx_pro_process)',
    attr_id      BIGINT       NOT NULL                COMMENT '属性ID(关联qxx_md_attr_def)',
    required     CHAR(1)      DEFAULT '0' NOT NULL    COMMENT '是否必填(1-是,0-否)',
    sort_order   INT          DEFAULT 0               COMMENT '排序号',
    enable_flag  CHAR(1)      DEFAULT '1' NOT NULL    COMMENT '是否启用(1-是,0-否)',
    create_by    VARCHAR(64)  DEFAULT ''              COMMENT '创建者',
    create_time  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_by    VARCHAR(64)  DEFAULT ''              COMMENT '更新者',
    update_time  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_process_attr (process_id, attr_id),
    KEY idx_factory_process (factory_id, process_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='外协工序-扩展属性模板';

ALTER TABLE qxx_wm_outsource_issue_line
    ADD COLUMN unit_price DECIMAL(14,4) DEFAULT NULL COMMENT '单价',
    ADD COLUMN amount DECIMAL(18,2) DEFAULT NULL COMMENT '金额=数量*单价';

ALTER TABLE qxx_wm_outsource_issue_line
    MODIFY COLUMN ext_attrs VARCHAR(2000) DEFAULT NULL COMMENT '工艺明细扩展属性(JSON扁平结构)';

-- 工序管理页面新增「外协字段」按钮权限（sys_menu 无 factory_id）
INSERT INTO sys_menu (menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT '外协字段模板', 2310, 9, 'F', '0', '0', 'mes:pro:process:attr', 'admin', sysdate()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:pro:process:attr');
