-- ============================================================
-- V186: 加工单（原外协单）支持厂内加工 + 多工序合并
--
-- 背景：一期要求所有工序都能开加工单，内部加工与外协共用同一模板，
--       差别仅是供应商为空（厂内）；且多道工序可合并开一张加工单。
--       方案：扩展 qxx_wm_outsource_order，新增 supplier_type 与工序行子表，
--             复用现有发料/收货/来料检验链路。
--
-- 含：
--   ① qxx_wm_outsource_order 增加 supplier_type，vendor 三列允许为空
--   ② 工序行表 qxx_wm_outsource_process_line
--   ③ 字典 mes_outsource_supplier_type
--   ④ 菜单按钮：加工单导出、加工单改状态
--
-- 字符集：utf8mb4
-- 日期：2026-11-15
-- ============================================================

SET NAMES utf8mb4;

-- ① 单头：厂内/外协标识
ALTER TABLE qxx_wm_outsource_order
    ADD COLUMN supplier_type VARCHAR(16) DEFAULT 'OUTSIDE' COMMENT '加工类型:INSIDE-厂内/OUTSIDE-外协' AFTER order_code;

ALTER TABLE qxx_wm_outsource_order
    MODIFY COLUMN vendor_id   BIGINT       DEFAULT NULL COMMENT '加工商ID(qxx_md_vendor,厂内加工为空)',
    MODIFY COLUMN vendor_code VARCHAR(64)  DEFAULT NULL COMMENT '加工商编码',
    MODIFY COLUMN vendor_name VARCHAR(255) DEFAULT NULL COMMENT '加工商名称';

ALTER TABLE qxx_wm_outsource_order
    ADD KEY idx_supplier_type (supplier_type);

-- ② 工序行（一张加工单可含多道工序）
CREATE TABLE IF NOT EXISTS qxx_wm_outsource_process_line (
    line_id      BIGINT       NOT NULL AUTO_INCREMENT COMMENT '行ID',
    factory_id   BIGINT       NOT NULL                COMMENT '工厂ID',
    order_id     BIGINT       NOT NULL                COMMENT '加工单ID(qxx_wm_outsource_order)',
    seq          INT          DEFAULT 0               COMMENT '工序顺序',
    task_id      BIGINT       DEFAULT NULL            COMMENT '工序任务ID(qxx_pro_task)',
    process_id   BIGINT       DEFAULT NULL            COMMENT '工序ID(qxx_pro_process)',
    process_code VARCHAR(64)  DEFAULT NULL            COMMENT '工序编码',
    process_name VARCHAR(255) DEFAULT NULL            COMMENT '工序名称',
    plan_qty     DECIMAL(14,4) DEFAULT 0.0000         COMMENT '计划数量',
    done_qty     DECIMAL(14,4) DEFAULT 0.0000         COMMENT '完成数量',
    remark       VARCHAR(500) DEFAULT ''              COMMENT '备注',
    create_by    VARCHAR(64)  DEFAULT ''              COMMENT '创建者',
    create_time  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_by    VARCHAR(64)  DEFAULT ''              COMMENT '更新者',
    update_time  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (line_id),
    KEY idx_opline_order (factory_id, order_id),
    KEY idx_opline_task (task_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='加工单工序行';

-- ③ 字典：加工类型
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)
SELECT '加工类型', 'mes_outsource_supplier_type', '0', 'admin', sysdate(), '加工单类型:厂内/外协'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE dict_type = 'mes_outsource_supplier_type');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 1, '厂内加工', 'INSIDE', 'mes_outsource_supplier_type', '', 'primary', 'Y', '0', 'admin', sysdate(), '内部工序加工,无供应商'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_outsource_supplier_type' AND dict_value = 'INSIDE');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 2, '外协加工', 'OUTSIDE', 'mes_outsource_supplier_type', '', 'warning', 'N', '0', 'admin', sysdate(), '委外厂商加工'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_outsource_supplier_type' AND dict_value = 'OUTSIDE');

-- ④ 按钮权限
INSERT INTO sys_menu (menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT '加工单导出', p.menu_id, 20, 'F', '0', '0', 'mes:wm:outsource:export', 'admin', sysdate()
FROM (SELECT menu_id FROM sys_menu WHERE perms = 'mes:wm:outsource:list' ORDER BY menu_id LIMIT 1) p
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:outsource:export');

INSERT INTO sys_menu (menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT '加工单改状态', p.menu_id, 21, 'F', '0', '0', 'mes:wm:outsource:changeStatus', 'admin', sysdate()
FROM (SELECT menu_id FROM sys_menu WHERE perms = 'mes:wm:outsource:list' ORDER BY menu_id LIMIT 1) p
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms = 'mes:wm:outsource:changeStatus');
