-- ============================================================
-- V204：ERP 工厂出库申请（MES 侧）与出库单来源
-- 用途：
--   1. 承接 ERP 下发的出库申请（qxx_wm_sales_apply / _line）
--   2. 出库单记录来源申请，过账后回写 ERP
-- 说明：ERP 平台端出库申请为唯一申请源，MES 只执行；SRM 不参与。
-- ============================================================

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `qxx_wm_sales_apply` (
  `apply_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '申请ID',
  `factory_id` bigint(20) NOT NULL COMMENT '工厂ID',
  `apply_code` varchar(64) NOT NULL COMMENT 'ERP出库申请单号（幂等键）',
  `external_apply_no` varchar(64) DEFAULT NULL COMMENT 'ERP外部申请单号',
  `external_order_no` varchar(64) DEFAULT NULL COMMENT 'SRM采购单号（MES销售订单外部单号）',
  `purchase_order_id` bigint(20) DEFAULT NULL COMMENT 'SRM采购单ID',
  `sales_order_id` bigint(20) DEFAULT NULL COMMENT 'MES销售订单ID',
  `sales_order_code` varchar(64) DEFAULT NULL COMMENT 'MES销售订单号',
  `request_date` date DEFAULT NULL COMMENT '要求出库日期',
  `receiver_name` varchar(64) DEFAULT NULL COMMENT '收货人',
  `receiver_tel` varchar(32) DEFAULT NULL COMMENT '收货电话',
  `receiver_address` varchar(255) DEFAULT NULL COMMENT '收货地址',
  `status` varchar(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态：PENDING/PARTIAL/DONE/CANCELED/REJECTED',
  `mes_sales_id` bigint(20) DEFAULT NULL COMMENT 'MES销售出库单ID',
  `mes_sales_code` varchar(64) DEFAULT NULL COMMENT 'MES销售出库单号',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_by` varchar(64) DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`apply_id`),
  UNIQUE KEY `uk_sales_apply_code` (`factory_id`, `apply_code`),
  KEY `idx_sales_apply_order` (`external_order_no`),
  KEY `idx_sales_apply_sales` (`mes_sales_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP工厂出库申请';

CREATE TABLE IF NOT EXISTS `qxx_wm_sales_apply_line` (
  `line_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '行ID',
  `factory_id` bigint(20) NOT NULL COMMENT '工厂ID',
  `apply_id` bigint(20) NOT NULL COMMENT '申请ID',
  `external_line_id` varchar(64) NOT NULL COMMENT 'ERP采购单明细ID（=SRM PurchaseOrderGoodsId）',
  `sales_order_line_id` bigint(20) DEFAULT NULL COMMENT 'MES销售订单行ID',
  `item_id` bigint(20) DEFAULT NULL COMMENT '物料ID',
  `item_code` varchar(64) DEFAULT NULL COMMENT '物料编码',
  `item_name` varchar(200) DEFAULT NULL COMMENT '物料名称',
  `unit_of_measure` varchar(32) DEFAULT NULL COMMENT '单位编码',
  `unit_name` varchar(32) DEFAULT NULL COMMENT '单位名称',
  `apply_qty` decimal(18,4) NOT NULL DEFAULT 0 COMMENT '申请数量',
  `posted_qty` decimal(18,4) NOT NULL DEFAULT 0 COMMENT '已出库数量',
  `line_status` varchar(20) NOT NULL DEFAULT 'PENDING' COMMENT '行状态：PENDING/PARTIAL/DONE/CANCELED/REJECTED',
  `remark` varchar(255) DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`line_id`),
  UNIQUE KEY `uk_sales_apply_line` (`apply_id`, `external_line_id`),
  KEY `idx_sales_apply_line_order` (`sales_order_line_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP工厂出库申请明细';

-- 出库单记录来源申请（幂等，重复执行安全）
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'qxx_wm_product_sales' AND column_name = 'apply_id');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE qxx_wm_product_sales ADD COLUMN apply_id bigint(20) DEFAULT NULL COMMENT ''来源出库申请ID'' AFTER sales_order_code, ADD COLUMN apply_code varchar(64) DEFAULT NULL COMMENT ''来源出库申请单号'' AFTER apply_id, ADD COLUMN source_type varchar(20) DEFAULT NULL COMMENT ''来源：ERP_APPLY/MANUAL'' AFTER apply_code',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 行上记录来源申请行（回写按申请行匹配）
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'qxx_wm_product_sales_line' AND column_name = 'apply_line_id');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE qxx_wm_product_sales_line ADD COLUMN apply_line_id bigint(20) DEFAULT NULL COMMENT ''来源出库申请行ID'' AFTER sales_order_line_id',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
