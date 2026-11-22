-- ============================================================
-- V200: 备货需求与库存预占 + 物料规格指纹
--
-- 背景：
--   ① 定制产品（如柔印纸袋）规格组合在 MES 中不存在，接单需要按
--      “SPU + 规格组合”快速建档并避免同规格重复建档。
--   ② 现有库存只有 quantity_onhand / quantity_available，没有可
--      追溯“锁定属于哪个订单/工单”的预占明细，备货占用无法下钻。
--   ③ 备货不新增独立单据：由预占明细驱动领料（占库存）与采购（补缺）。
--
-- 含：
--   ① qxx_md_item 增加 spec_fingerprint + 唯一索引
--   ② qxx_wm_material_stock 增加 quantity_locked
--   ③ 新增 qxx_wm_stock_reservation 预占明细表
--
-- 字符集：utf8mb4
-- 日期：2026-11-20
-- ============================================================

SET NAMES utf8mb4;

-- ① 物料规格指纹：仅变体生成，SPU 为 NULL（唯一索引允许多个 NULL）
ALTER TABLE qxx_md_item
    ADD COLUMN spec_fingerprint VARCHAR(64) DEFAULT NULL COMMENT '规格指纹(SPU+规格属性SHA-256),用于同规格查重' AFTER ext_attrs,
    ADD UNIQUE KEY uk_item_spec_fingerprint (factory_id, spec_fingerprint);

-- ② 库存锁定量：预占未发料的主单位数量；可用量 = 现有量 - 锁定量
ALTER TABLE qxx_wm_material_stock
    ADD COLUMN quantity_locked DECIMAL(14,4) DEFAULT 0.0000 COMMENT '锁定量(主单位,已预占未发料)' AFTER quantity_available;

-- ③ 预占明细表：每一行代表“某个工单/销售单需要某物料，已从某库存行预占多少”
DROP TABLE IF EXISTS qxx_wm_stock_reservation;
CREATE TABLE qxx_wm_stock_reservation (
  reservation_id    BIGINT(20)      NOT NULL AUTO_INCREMENT COMMENT '预占明细ID',
  factory_id        BIGINT(20)      NOT NULL                COMMENT '工厂ID',
  material_stock_id BIGINT(20)      DEFAULT NULL            COMMENT '库存记录ID(关联qxx_wm_material_stock)',
  item_id           BIGINT(20)      NOT NULL                COMMENT '物料ID',
  item_code         VARCHAR(64)     NOT NULL                COMMENT '物料编码',
  item_name         VARCHAR(255)    NOT NULL                COMMENT '物料名称',
  specification     VARCHAR(500)    DEFAULT NULL            COMMENT '规格型号',
  unit_of_measure   VARCHAR(64)     NOT NULL                COMMENT '主单位编码',
  unit_name         VARCHAR(64)     NOT NULL                COMMENT '主单位名称',
  warehouse_id      BIGINT(20)      DEFAULT NULL            COMMENT '仓库ID',
  warehouse_code    VARCHAR(64)     DEFAULT NULL            COMMENT '仓库编码',
  warehouse_name    VARCHAR(255)    DEFAULT NULL            COMMENT '仓库名称',
  batch_id          BIGINT(20)      DEFAULT 0               COMMENT '批次ID(0=无批次)',
  batch_code        VARCHAR(64)     DEFAULT NULL            COMMENT '批次编码',
  workorder_id      BIGINT(20)      DEFAULT NULL            COMMENT '生产工单ID',
  workorder_code    VARCHAR(64)     DEFAULT NULL            COMMENT '生产工单编码',
  workorder_name    VARCHAR(255)    DEFAULT NULL            COMMENT '生产工单名称',
  sales_order_id    BIGINT(20)      DEFAULT NULL            COMMENT '销售订单ID',
  sales_order_line_id BIGINT(20)    DEFAULT NULL            COMMENT '销售订单行ID',
  issue_id          BIGINT(20)      DEFAULT NULL            COMMENT '已转入的领料单ID',
  issue_code        VARCHAR(64)     DEFAULT NULL            COMMENT '已转入的领料单编码',
  source_type       VARCHAR(32)     DEFAULT 'WORKORDER'     COMMENT '来源类型:WORKORDER/SALES_ORDER/OUTSOURCE',
  demand_qty        DECIMAL(14,4)   NOT NULL DEFAULT 0.0000 COMMENT '需求数量(主单位)',
  reserved_qty      DECIMAL(14,4)   NOT NULL DEFAULT 0.0000 COMMENT '当前有效预占数量(主单位)',
  consumed_qty      DECIMAL(14,4)   NOT NULL DEFAULT 0.0000 COMMENT '已消耗/已发料数量(主单位)',
  released_qty      DECIMAL(14,4)   NOT NULL DEFAULT 0.0000 COMMENT '已释放/已转移数量(主单位)',
  demand_date       DATETIME        DEFAULT NULL            COMMENT '需求日期(FIFO分配排序)',
  status            VARCHAR(32)     NOT NULL DEFAULT 'OPEN' COMMENT '状态:OPEN待占/PARTIAL部分预占/RESERVED已预占/TRANSFERRED已转领料单/CONSUMED已消耗/RELEASED已释放',
  remark            VARCHAR(500)    DEFAULT ''              COMMENT '备注',
  create_by         VARCHAR(64)     DEFAULT ''              COMMENT '创建者',
  create_time       DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by         VARCHAR(64)     DEFAULT ''              COMMENT '更新者',
  update_time       DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (reservation_id),
  KEY idx_res_item (factory_id, item_id, status),
  KEY idx_res_wo (factory_id, workorder_id),
  KEY idx_res_stock (factory_id, material_stock_id),
  KEY idx_res_issue (factory_id, issue_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存预占明细表(备货占用)';
