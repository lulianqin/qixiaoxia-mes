-- ============================================================
-- V190: 外部单据双系统留痕 + 库存分类扩展属性
--
-- 背景：
--   ① ERP 之外还有老的 SRM，报价单/采购单可能来自任一系统，
--      MES 需分别保存两端的单据 ID，便于各自回写与追溯。
--   ② 库存需要按物料分类填写不同属性（门幅/材质/克重/纸张来源等），
--      复用 qxx_md_attr_def + qxx_md_item_type_attr 分类属性模板。
--
-- 字符集：utf8mb4
-- 日期：2026-11-16
-- ============================================================

SET NAMES utf8mb4;

-- ① 外部单据留痕（一个业务单据可对应 ERP / SRM 多条记录）
CREATE TABLE IF NOT EXISTS qxx_sys_external_doc (
    doc_id           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    factory_id       BIGINT       NOT NULL                COMMENT '工厂ID',
    system_code      VARCHAR(32)  NOT NULL                COMMENT '外部系统:ERP-新ERP,SRM-老SRM',
    biz_type         VARCHAR(32)  NOT NULL                COMMENT '业务类型:ORDER-销售订单,QUOTE-报价单',
    biz_id           BIGINT       NOT NULL                COMMENT '本系统单据ID',
    biz_no           VARCHAR(64)  DEFAULT NULL            COMMENT '本系统单据号',
    external_id      VARCHAR(64)  DEFAULT NULL            COMMENT '外部单据ID',
    external_no      VARCHAR(64)  NOT NULL                COMMENT '外部单据号',
    external_version INT          DEFAULT 1               COMMENT '外部单据版本',
    sync_status      VARCHAR(32)  DEFAULT NULL            COMMENT '回写状态:PENDING/SUCCESS/FAILED',
    remark           VARCHAR(500) DEFAULT NULL            COMMENT '备注',
    create_by        VARCHAR(64)  DEFAULT ''              COMMENT '创建者',
    create_time      DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_by        VARCHAR(64)  DEFAULT ''              COMMENT '更新者',
    update_time      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (doc_id),
    UNIQUE KEY uk_ext_doc (factory_id, system_code, biz_type, external_no),
    KEY idx_ext_doc_biz (factory_id, biz_type, biz_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='外部系统单据留痕';

-- ② 库存扩展属性（按物料分类动态填写）
ALTER TABLE qxx_wm_material_stock
    ADD COLUMN ext_attrs VARCHAR(2000) DEFAULT NULL COMMENT '分类扩展属性(JSON扁平结构)';

-- ③ 物料分类属性补齐：原料/纸边常用库存属性
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)
SELECT '外部系统', 'mes_external_system', '0', 'admin', sysdate(), '外部单据来源系统:ERP/SRM'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE dict_type = 'mes_external_system');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 1, 'ERP', 'ERP', 'mes_external_system', '', 'primary', 'Y', '0', 'admin', sysdate(), '新 ERP 系统'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_external_system' AND dict_value = 'ERP');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 2, 'SRM', 'SRM', 'mes_external_system', '', 'warning', 'N', '0', 'admin', sysdate(), '老 SRM 系统'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_external_system' AND dict_value = 'SRM');
