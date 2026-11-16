-- ============================================================
-- V181: 工厂 MES 对接 ERP（销售订单接收 / 报价回传）
--
-- 背景：销售订单与报价单由 ERP（销售公司）发起，工厂 MES 接收并回写处理结果。
--   过渡期 ERP 侧保留 SRM，MES 与 SRM 并行，按“接单平台”路由。
--
-- 含：
--   ① qxx_sal_order 增加外部单据字段（来源系统/外部单号/接单状态/打回原因/回写状态）
--   ② qxx_sal_order_line 增加外部行号
--   ③ 报价需求单 qxx_sal_quote / qxx_sal_quote_line
--   ④ ERP 对接配置 qxx_sys_integration_endpoint
--   ⑤ 回写任务 qxx_sys_sync_task（失败重试 + 手动重推）
--   ⑥ 外部主数据映射 qxx_sys_external_mapping（ERP 客户/商品 → MES 客户/物料）
--   ⑦ 字典 mes_sal_order_status 增 REJECTED、mes_sal_order_source、mes_sal_quote_status
--   ⑧ 菜单：销售订单打回、报价单、ERP 对接
--
-- 幂等：表/列用 IF NOT EXISTS 不便，重复执行时由 Flyway 保证仅执行一次；
--      字典/菜单按业务键 WHERE NOT EXISTS。
-- 字符集：utf8mb4
-- 日期：2026-11-15
-- ============================================================

SET NAMES utf8mb4;

-- ① 销售订单外部单据字段
ALTER TABLE qxx_sal_order
    ADD COLUMN source_system     VARCHAR(32)  DEFAULT 'MANUAL' COMMENT '来源系统:MANUAL手工/CRM/ERP',
    ADD COLUMN external_order_id VARCHAR(64)  DEFAULT NULL COMMENT '外部系统单据ID(ERP采购单ID)',
    ADD COLUMN external_order_no VARCHAR(64)  DEFAULT NULL COMMENT '外部系统单据号(ERP采购单号)',
    ADD COLUMN external_version  INT          DEFAULT 1    COMMENT '外部单据版本(重发递增)',
    ADD COLUMN accept_status     VARCHAR(32)  DEFAULT NULL COMMENT '外部接单状态:PENDING/ACCEPTED/REJECTED',
    ADD COLUMN accept_time       DATETIME     DEFAULT NULL COMMENT '接单时间',
    ADD COLUMN reject_reason     VARCHAR(500) DEFAULT NULL COMMENT '打回原因',
    ADD COLUMN reject_by         VARCHAR(64)  DEFAULT NULL COMMENT '打回人',
    ADD COLUMN reject_time       DATETIME     DEFAULT NULL COMMENT '打回时间',
    ADD COLUMN sync_status       VARCHAR(32)  DEFAULT NULL COMMENT '回写ERP状态:PENDING/SUCCESS/FAILED',
    ADD COLUMN sync_time         DATETIME     DEFAULT NULL COMMENT '最近回写时间';

ALTER TABLE qxx_sal_order
    ADD UNIQUE KEY uk_sal_order_external (factory_id, source_system, external_order_no),
    ADD KEY idx_sal_order_source (factory_id, source_system, order_id);

-- ② 销售订单明细行外部行号
ALTER TABLE qxx_sal_order_line
    ADD COLUMN external_line_id VARCHAR(64) DEFAULT NULL COMMENT '外部系统明细行ID/行号';

ALTER TABLE qxx_sal_order_line
    ADD KEY idx_sal_order_line_ext (order_id, external_line_id);

-- ③ 报价需求单（ERP 发起，MES 报价后回传）
CREATE TABLE IF NOT EXISTS qxx_sal_quote (
    quote_id           BIGINT        NOT NULL AUTO_INCREMENT COMMENT '报价单ID',
    factory_id         BIGINT        NOT NULL                COMMENT '工厂ID',
    quote_code         VARCHAR(64)   NOT NULL                COMMENT 'MES报价单号',
    external_quote_id  VARCHAR(64)   DEFAULT NULL            COMMENT 'ERP报价单ID',
    external_quote_no  VARCHAR(64)   NOT NULL                COMMENT 'ERP报价单号',
    source_system      VARCHAR(32)   DEFAULT 'ERP'           COMMENT '来源系统',
    title              VARCHAR(200)  DEFAULT NULL            COMMENT '标题',
    client_code        VARCHAR(64)   DEFAULT NULL            COMMENT '客户编码',
    client_name        VARCHAR(200)  DEFAULT NULL            COMMENT '客户名称',
    goods_type         VARCHAR(64)   DEFAULT NULL            COMMENT '商品类型',
    inquiry_date       DATE          DEFAULT NULL            COMMENT '询价日期',
    budget             VARCHAR(64)   DEFAULT NULL            COMMENT '预算',
    attachment         VARCHAR(2000) DEFAULT NULL            COMMENT '附件',
    status             VARCHAR(32)   NOT NULL DEFAULT 'PENDING_QUOTE' COMMENT '状态:PENDING_QUOTE待报价/QUOTED已报价/RETURNED已退回/CANCEL已取消',
    quote_user         VARCHAR(64)   DEFAULT NULL            COMMENT '报价人',
    quote_time         DATETIME      DEFAULT NULL            COMMENT '报价时间',
    total_amount       DECIMAL(18,2) DEFAULT NULL            COMMENT '报价总额',
    return_reason      VARCHAR(500)  DEFAULT NULL            COMMENT '退回原因',
    return_time        DATETIME      DEFAULT NULL            COMMENT '退回时间',
    sync_status        VARCHAR(32)   DEFAULT NULL            COMMENT '回写ERP状态:PENDING/SUCCESS/FAILED',
    sync_time          DATETIME      DEFAULT NULL            COMMENT '最近回写时间',
    remark             VARCHAR(1000) DEFAULT NULL            COMMENT '备注',
    create_by          VARCHAR(64)   DEFAULT ''              COMMENT '创建者',
    create_time        DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_by          VARCHAR(64)   DEFAULT ''              COMMENT '更新者',
    update_time        DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (quote_id),
    UNIQUE KEY uk_quote_external (factory_id, external_quote_no),
    KEY idx_quote_status (factory_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='销售报价需求单(ERP下发)';

CREATE TABLE IF NOT EXISTS qxx_sal_quote_line (
    line_id           BIGINT        NOT NULL AUTO_INCREMENT COMMENT '明细ID',
    factory_id        BIGINT        NOT NULL                COMMENT '工厂ID',
    quote_id          BIGINT        NOT NULL                COMMENT '报价单ID',
    line_no           INT           DEFAULT NULL            COMMENT '行号',
    external_line_id  VARCHAR(64)   DEFAULT NULL            COMMENT 'ERP明细行ID',
    product_code      VARCHAR(64)   DEFAULT NULL            COMMENT '产品编码',
    product_name      VARCHAR(200)  DEFAULT NULL            COMMENT '产品名称',
    product_photo     VARCHAR(1000) DEFAULT NULL            COMMENT '产品图片',
    product_size      VARCHAR(200)  DEFAULT NULL            COMMENT '产品尺寸',
    structure         VARCHAR(200)  DEFAULT NULL            COMMENT '结构',
    material          VARCHAR(200)  DEFAULT NULL            COMMENT '材质',
    printing_mode     VARCHAR(200)  DEFAULT NULL            COMMENT '印刷方式',
    process_txt       VARCHAR(1000) DEFAULT NULL            COMMENT '工艺说明',
    accessory_txt     VARCHAR(1000) DEFAULT NULL            COMMENT '配件说明',
    quantity          DECIMAL(18,4) DEFAULT NULL            COMMENT '数量',
    unit              VARCHAR(32)   DEFAULT NULL            COMMENT '单位',
    price             DECIMAL(18,4) DEFAULT NULL            COMMENT '报价单价',
    quote_remark      VARCHAR(500)  DEFAULT NULL            COMMENT '报价备注',
    delivery_date     VARCHAR(100)  DEFAULT NULL            COMMENT '交期说明',
    quote_valid_date  DATE          DEFAULT NULL            COMMENT '报价有效期',
    remark            VARCHAR(500)  DEFAULT NULL            COMMENT '客户需求备注',
    create_by         VARCHAR(64)   DEFAULT ''              COMMENT '创建者',
    create_time       DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_by         VARCHAR(64)   DEFAULT ''              COMMENT '更新者',
    update_time       DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (line_id),
    KEY idx_quote_line (factory_id, quote_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='销售报价需求单明细';

-- ④ ERP 对接配置（每个工厂一条 ERP 端点）
CREATE TABLE IF NOT EXISTS qxx_sys_integration_endpoint (
    endpoint_id  BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
    factory_id   BIGINT        NOT NULL                COMMENT '工厂ID',
    system_code  VARCHAR(32)   NOT NULL DEFAULT 'ERP'  COMMENT '目标系统编码',
    system_name  VARCHAR(100)  DEFAULT NULL            COMMENT '目标系统名称',
    base_url     VARCHAR(500)  DEFAULT NULL            COMMENT '基地址,如 http://erp.example.com/prod-api',
    api_key      VARCHAR(200)  DEFAULT NULL            COMMENT '回调鉴权Key(X-API-Key)',
    enabled      CHAR(1)       DEFAULT '0'             COMMENT '是否启用(0启用,1停用)',
    remark       VARCHAR(500)  DEFAULT NULL            COMMENT '备注',
    create_by    VARCHAR(64)   DEFAULT ''              COMMENT '创建者',
    create_time  DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_by    VARCHAR(64)   DEFAULT ''              COMMENT '更新者',
    update_time  DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (endpoint_id),
    UNIQUE KEY uk_endpoint_factory_system (factory_id, system_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='外部系统对接配置';

-- ⑤ 回写任务（outbox，失败重试 + 手动重推）
CREATE TABLE IF NOT EXISTS qxx_sys_sync_task (
    task_id         BIGINT        NOT NULL AUTO_INCREMENT COMMENT '任务ID',
    factory_id      BIGINT        NOT NULL                COMMENT '工厂ID',
    biz_type        VARCHAR(32)   NOT NULL                COMMENT '业务类型:ORDER_ACCEPT/ORDER_REJECT/QUOTE_SUBMIT',
    biz_id          BIGINT        NOT NULL                COMMENT '业务主键(订单ID/报价ID)',
    biz_no          VARCHAR(64)   DEFAULT NULL            COMMENT '业务单号',
    target_system   VARCHAR(32)   NOT NULL DEFAULT 'ERP'  COMMENT '目标系统',
    callback_path   VARCHAR(200)  NOT NULL                COMMENT '回调路径',
    payload         TEXT                                  COMMENT '回调报文JSON',
    status          VARCHAR(32)   NOT NULL DEFAULT 'PENDING' COMMENT '状态:PENDING/RUNNING/SUCCESS/FAILED',
    retry_count     INT           DEFAULT 0               COMMENT '已重试次数',
    next_retry_time DATETIME      DEFAULT NULL            COMMENT '下次重试时间',
    last_error      VARCHAR(1000) DEFAULT NULL            COMMENT '最近错误',
    create_time     DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (task_id),
    KEY idx_sync_task_due (status, next_retry_time),
    KEY idx_sync_task_biz (factory_id, biz_type, biz_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='外部系统回写任务';

-- ⑥ 外部主数据映射（ERP 客户/商品 → MES 客户/物料）
CREATE TABLE IF NOT EXISTS qxx_sys_external_mapping (
    mapping_id    BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    factory_id    BIGINT       NOT NULL                COMMENT '工厂ID',
    system_code   VARCHAR(32)  NOT NULL DEFAULT 'ERP'  COMMENT '外部系统编码',
    entity_type   VARCHAR(32)  NOT NULL                COMMENT '实体类型:CLIENT客户/ITEM物料',
    external_id   VARCHAR(64)  DEFAULT NULL            COMMENT '外部ID',
    external_code VARCHAR(128) NOT NULL                COMMENT '外部编码',
    local_id      BIGINT       NOT NULL                COMMENT '本系统ID',
    create_by     VARCHAR(64)  DEFAULT ''              COMMENT '创建者',
    create_time   DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (mapping_id),
    UNIQUE KEY uk_ext_mapping (factory_id, system_code, entity_type, external_code),
    KEY idx_ext_mapping_local (factory_id, entity_type, local_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='外部系统主数据映射';

-- ⑦ 字典
-- 7.1 销售订单状态新增「已打回」
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 7, '已打回', 'REJECTED', 'mes_sal_order_status', '', 'danger', 'N', '0', 'admin', sysdate(), 'ERP下发订单被工厂打回,待ERP修改后重发'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_sal_order_status' AND dict_value = 'REJECTED');

-- 7.2 销售订单来源
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)
SELECT '销售订单来源', 'mes_sal_order_source', '0', 'admin', sysdate(), '销售订单来源:手工/CRM/ERP'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE dict_type = 'mes_sal_order_source');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 1, '直接新增', '1', 'mes_sal_order_source', '', 'info', 'Y', '0', 'admin', sysdate(), '系统内手工建单'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_sal_order_source' AND dict_value = '1');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 2, 'CRM系统', '2', 'mes_sal_order_source', '', 'warning', 'N', '0', 'admin', sysdate(), 'CRM推单'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_sal_order_source' AND dict_value = '2');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 3, 'ERP系统', '3', 'mes_sal_order_source', '', 'success', 'N', '0', 'admin', sysdate(), 'ERP下发采购单转销售订单'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_sal_order_source' AND dict_value = '3');

-- 7.3 报价单状态
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)
SELECT '报价需求状态', 'mes_sal_quote_status', '0', 'admin', sysdate(), '报价需求单状态:待报价/已报价/已退回'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE dict_type = 'mes_sal_quote_status');

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 1, '待报价', 'PENDING_QUOTE', 'mes_sal_quote_status', '', 'primary', 'Y', '0', 'admin', sysdate(), 'ERP已下发,等待工厂报价'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_sal_quote_status' AND dict_value = 'PENDING_QUOTE');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 2, '已报价', 'QUOTED', 'mes_sal_quote_status', '', 'success', 'N', '0', 'admin', sysdate(), '工厂已报价并回传ERP'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_sal_quote_status' AND dict_value = 'QUOTED');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 3, '已退回', 'RETURNED', 'mes_sal_quote_status', '', 'danger', 'N', '0', 'admin', sysdate(), 'ERP退回,需重新报价'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_sal_quote_status' AND dict_value = 'RETURNED');
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 4, '已取消', 'CANCEL', 'mes_sal_quote_status', '', 'info', 'N', '0', 'admin', sysdate(), 'ERP作废报价需求'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_sal_quote_status' AND dict_value = 'CANCEL');

-- ⑧ 菜单（sys_menu 为全局表,无 factory_id）
-- 8.1 销售订单打回按钮
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT 2917, '销售订单打回', 2901, 10, 'F', '0', '0', 'mes:sal:order:reject', 'admin', sysdate()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2917);

-- 8.2 报价单菜单 + 按钮
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time)
SELECT 2970, '报价单', 2900, 2, 'quote', 'mes/sal/quote/index', 1, 0, 'C', '0', '0', 'mes:sal:quote:list', 'money', 'admin', sysdate()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2970);

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT 2971, '报价单查询', 2970, 1, 'F', '0', '0', 'mes:sal:quote:query', 'admin', sysdate()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2971);
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT 2972, '报价录入', 2970, 2, 'F', '0', '0', 'mes:sal:quote:edit', 'admin', sysdate()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2972);
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT 2973, '报价提交', 2970, 3, 'F', '0', '0', 'mes:sal:quote:submit', 'admin', sysdate()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2973);

-- 8.3 ERP 对接（配置 + 同步记录）
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time)
SELECT 2980, 'ERP对接', 2900, 9, 'erp', 'mes/sal/erp/index', 1, 0, 'C', '0', '0', 'mes:sal:erp:list', 'link', 'admin', sysdate()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2980);

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT 2981, 'ERP配置保存', 2980, 1, 'F', '0', '0', 'mes:sal:erp:edit', 'admin', sysdate()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2981);
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, menu_type, visible, status, perms, create_by, create_time)
SELECT 2982, '同步任务重推', 2980, 2, 'F', '0', '0', 'mes:sal:erp:retry', 'admin', sysdate()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2982);
