-- ============================================================
-- V182: 报价单接收时回填客户/产品 id
--
-- 背景：ERP 下发的报价单只带文本（客户名称、产品名称），MES 侧需要按名称反查
--       本地主数据并回填 id；匹配不到保持 NULL，绝不携带 ERP 侧 id。
--
-- 含：
--   ① qxx_sal_quote 增加 client_id
--   ② qxx_sal_quote_line 增加 product_id
--
-- 字符集：utf8mb4
-- 日期：2026-11-15
-- ============================================================

SET NAMES utf8mb4;

-- ① 报价单：客户ID
ALTER TABLE qxx_sal_quote
    ADD COLUMN client_id BIGINT DEFAULT NULL COMMENT '客户ID(按名称匹配qxx_md_client,未匹配为空)' AFTER client_name;

ALTER TABLE qxx_sal_quote
    ADD KEY idx_quote_client (factory_id, client_id);

-- ② 报价明细：产品（物料）ID
ALTER TABLE qxx_sal_quote_line
    ADD COLUMN product_id BIGINT DEFAULT NULL COMMENT '物料ID(按名称匹配qxx_md_item,未匹配为空)' AFTER product_name;

ALTER TABLE qxx_sal_quote_line
    ADD KEY idx_quote_line_product (factory_id, product_id);
