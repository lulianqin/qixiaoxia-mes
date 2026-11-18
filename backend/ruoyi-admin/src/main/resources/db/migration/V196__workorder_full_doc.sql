-- ============================================================
-- V196: 生产工单独立开单页 — 采购单/加工单导出与合并打印字段
--
-- 背景：新增生产工单改为独立页面，一页内同时配置主工单 + 工艺路线 + 全部
--       采购单/加工单（草稿）。单据需支持按模板导出 Excel / 打印 PDF，
--       并支持同供应商多单合并打印，因此补齐单据抬头与工序行字段。
--
-- 含：
--   ① qxx_pur_order 增加 单据标题 / 送货地址
--   ② qxx_wm_outsource_order 增加 下单日期 / 交期 / 申购人 / 业务单号 / 送货地址 / 单据标题
--   ③ qxx_wm_outsource_process_line 增加 供应商快照 / 单价 / 金额 / 交期
--
-- 字符集：utf8mb4
-- 日期：2026-11-17
-- ============================================================

SET NAMES utf8mb4;

-- ① 采购单抬头
ALTER TABLE qxx_pur_order
    ADD COLUMN doc_title        VARCHAR(100) DEFAULT NULL COMMENT '单据标题(如 纸张采购单/绳子采购单,空则按采购类型推导)' AFTER order_name,
    ADD COLUMN delivery_address VARCHAR(500) DEFAULT NULL COMMENT '送货地址' AFTER source_order_code;

-- ② 加工单抬头
ALTER TABLE qxx_wm_outsource_order
    ADD COLUMN doc_title        VARCHAR(100) DEFAULT NULL COMMENT '单据标题(如 印刷加工单/后道加工单)' AFTER source_type,
    ADD COLUMN order_date       DATETIME     DEFAULT NULL COMMENT '下单日期' AFTER doc_title,
    ADD COLUMN expected_date    DATETIME     DEFAULT NULL COMMENT '交货日期' AFTER order_date,
    ADD COLUMN purchaser        VARCHAR(64)  DEFAULT NULL COMMENT '申购人' AFTER expected_date,
    ADD COLUMN source_order_code VARCHAR(64) DEFAULT NULL COMMENT '业务单号(客户订单号)' AFTER purchaser,
    ADD COLUMN delivery_address VARCHAR(500) DEFAULT NULL COMMENT '送货地址' AFTER source_order_code;

-- ③ 加工单工序行
ALTER TABLE qxx_wm_outsource_process_line
    ADD COLUMN vendor_id     BIGINT       DEFAULT NULL COMMENT '工序供应商ID(qxx_md_vendor)' AFTER task_id,
    ADD COLUMN vendor_code   VARCHAR(64)  DEFAULT NULL COMMENT '工序供应商编码' AFTER vendor_id,
    ADD COLUMN vendor_name   VARCHAR(255) DEFAULT NULL COMMENT '工序供应商名称' AFTER vendor_code,
    ADD COLUMN unit_price    DECIMAL(14,4) DEFAULT NULL COMMENT '工序单价' AFTER done_qty,
    ADD COLUMN amount        DECIMAL(18,2) DEFAULT NULL COMMENT '工序金额=计划数量*单价' AFTER unit_price,
    ADD COLUMN expected_date DATETIME     DEFAULT NULL COMMENT '送货日期' AFTER amount;

ALTER TABLE qxx_wm_outsource_process_line
    ADD KEY idx_opline_vendor (vendor_id);

-- ④ 工单级工艺路线工序快照（支持新增/编辑工单时增删调整工序，不影响工艺路线主数据）
CREATE TABLE IF NOT EXISTS qxx_pro_workorder_process (
    record_id    BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    factory_id   BIGINT       NOT NULL                COMMENT '工厂ID',
    workorder_id BIGINT       NOT NULL                COMMENT '工单ID(qxx_pro_workorder)',
    process_id   BIGINT       NOT NULL                COMMENT '工序ID(qxx_pro_process)',
    process_code VARCHAR(64)  DEFAULT NULL            COMMENT '工序编码',
    process_name VARCHAR(255) DEFAULT NULL            COMMENT '工序名称',
    order_num    INT          DEFAULT 0               COMMENT '工序顺序',
    is_outsource CHAR(1)      DEFAULT '0'             COMMENT '是否外协(1-是,0-否)',
    vendor_id    BIGINT       DEFAULT NULL            COMMENT '默认供应商ID',
    vendor_code  VARCHAR(64)  DEFAULT NULL            COMMENT '默认供应商编码',
    vendor_name  VARCHAR(255) DEFAULT NULL            COMMENT '默认供应商名称',
    unit_price   DECIMAL(14,4) DEFAULT NULL           COMMENT '工序单价',
    expected_date DATETIME    DEFAULT NULL            COMMENT '送货日期',
    remark       VARCHAR(500) DEFAULT ''              COMMENT '备注',
    create_by    VARCHAR(64)  DEFAULT ''              COMMENT '创建者',
    create_time  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_by    VARCHAR(64)  DEFAULT ''              COMMENT '更新者',
    update_time  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (record_id),
    UNIQUE KEY uk_wo_process (factory_id, workorder_id, process_id),
    KEY idx_woprocess_wo (workorder_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='工单工艺路线工序快照';
