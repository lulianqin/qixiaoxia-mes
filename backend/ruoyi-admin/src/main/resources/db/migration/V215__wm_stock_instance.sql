-- ============================================================
-- V215: 通用库存实物实例（一卷 / 一根 / 一桶 …）
--
-- 背景：
--   纸张按卷、钢管按根、油墨按桶，每件实物的主单位数量（kg / m）各不相同。
--   原 qxx_wm_roll_detail 是纸张专用表，无法扩展到其他行业属性。
--
-- 设计：
--   qxx_md_item          = 标准规格（主单位 kg/m；辅助单位 卷/根/桶）
--   qxx_wm_stock_instance = 一件实物（instance_code 唯一，remaining_quantity 随收发变化）
--   qxx_wm_material_stock = 库存桶（主单位数量汇总；辅助数量 = 在库实例数）
--   行业属性（门幅/克重、外径/壁厚/定尺 …）走 qxx_md_attr_def 的 STOCK_INSTANCE 域，
--   实例表只存 ext_attrs JSON，新增物料类型不需要改表。
-- ============================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

CREATE TABLE IF NOT EXISTS qxx_wm_stock_instance (
  instance_id        bigint(20)      not null auto_increment    comment '库存实物实例ID',
  factory_id         bigint(20)      not null                   comment '工厂ID',
  instance_code      varchar(64)     not null                   comment '实例编号(一卷/一根/一桶唯一编号,可贴条码)',
  instance_type      varchar(32)     default null               comment '实例类型:ROLL卷/BAR根/DRUM桶等,由物料辅助单位决定',
  item_id            bigint(20)      not null                   comment '物料ID',
  item_code          varchar(64)     not null                   comment '物料编码',
  item_name          varchar(255)    not null                   comment '物料名称',
  specification      varchar(500)    default null               comment '规格型号',
  batch_id           bigint(20)      default null               comment '批次ID',
  batch_code         varchar(64)     default null               comment '批次编码',
  recpt_id           bigint(20)      default null               comment '来源入库单ID(期初/退料新建时为空)',
  recpt_detail_id    bigint(20)      default null               comment '来源入库明细ID',
  vendor_id          bigint(20)      default null               comment '供应商ID',
  vendor_code        varchar(64)     default null               comment '供应商编码',
  vendor_name        varchar(255)    default null               comment '供应商名称',
  vendor_instance_no varchar(64)     default null               comment '供应商原始实例号(卷号/根号)',
  parent_instance_id bigint(20)      default null               comment '父实例ID(分切场景:子卷/子段→母卷)',
  original_quantity  decimal(18,4)   not null default 0.0000    comment '入库时主单位数量',
  remaining_quantity decimal(18,4)   not null default 0.0000    comment '剩余主单位数量(权威值)',
  quantity_uom       varchar(64)     not null                   comment '主单位编码(同物料 unit_of_measure)',
  warehouse_id       bigint(20)      default null               comment '仓库ID',
  warehouse_code     varchar(64)     default null               comment '仓库编码',
  warehouse_name     varchar(255)    default null               comment '仓库名称',
  location_id        bigint(20)      default null               comment '库区ID',
  area_id            bigint(20)      default null               comment '库位ID',
  material_stock_id  bigint(20)      default null               comment '所属库存桶ID(qxx_wm_material_stock)',
  last_issue_id      bigint(20)      default null               comment '最近领料单ID',
  last_workorder_id  bigint(20)      default null               comment '最近工单ID',
  last_workorder_code varchar(64)    default null               comment '最近工单编码',
  status             varchar(50)     default 'IN_STOCK'         comment '状态:IN_STOCK/PARTIAL/CONSUMED/RETURNED/SCRAPPED/OUTSOURCED',
  ext_attrs          json            default null               comment '实例级动态属性(JSON扁平结构):{INST_PAPER_WIDTH:770,...}',
  remark             varchar(500)    default ''                 comment '备注',
  create_by          varchar(64)     default ''                 comment '创建者',
  create_time        datetime        default current_timestamp  comment '创建时间',
  update_by          varchar(64)     default ''                 comment '更新者',
  update_time        datetime        default current_timestamp on update current_timestamp comment '更新时间',
  primary key (instance_id),
  unique key uk_factory_instance_code (factory_id, instance_code),
  key idx_stock_instance_item (factory_id, item_id),
  key idx_stock_instance_stock (material_stock_id),
  key idx_stock_instance_batch (factory_id, batch_id)
) engine=innodb DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci comment = '库存实物实例表(通用一卷/一根/一桶)';

-- ---------- 单据明细与库存流水携带实例维度 ----------
ALTER TABLE qxx_wm_issue_detail
  ADD COLUMN instance_id bigint(20) default null comment '实物实例ID',
  ADD COLUMN instance_code varchar(64) default null comment '实物实例编号',
  ADD COLUMN instance_quantity decimal(18,4) default null comment '本次从该实例收发的主单位数量';

ALTER TABLE qxx_wm_rt_issue_detail
  ADD COLUMN instance_id bigint(20) default null comment '实物实例ID',
  ADD COLUMN instance_code varchar(64) default null comment '实物实例编号',
  ADD COLUMN instance_quantity decimal(18,4) default null comment '本次从该实例收发的主单位数量';

ALTER TABLE qxx_wm_item_recpt_detail
  ADD COLUMN instance_id bigint(20) default null comment '实物实例ID',
  ADD COLUMN instance_code varchar(64) default null comment '实物实例编号',
  ADD COLUMN instance_quantity decimal(18,4) default null comment '本次入库的主单位数量';

ALTER TABLE qxx_wm_transaction
  ADD COLUMN instance_id bigint(20) default null comment '实物实例ID',
  ADD COLUMN instance_code varchar(64) default null comment '实物实例编号';

-- ---------- 通用实例管理开关（保留纸专用字段兼容旧数据） ----------
ALTER TABLE qxx_md_item_batch_config
  ADD COLUMN instance_flag char(1) default '0' comment '是否逐实物实例管理(1-是,0-否)';

-- ---------- 实例级动态属性字典（属性域 STOCK_INSTANCE） ----------
INSERT INTO qxx_md_attr_def
  (factory_id, attr_code, attr_name, attr_type, attr_scope, widget_type, attr_unit, sort_order, enable_flag, create_by, create_time)
SELECT 0, 'INST_PAPER_WIDTH', '实测门幅', 'NUMBER', 'STOCK_INSTANCE', 'NUMBER', 'mm', 10, '1', 'admin', sysdate()
  FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM qxx_md_attr_def WHERE attr_code = 'INST_PAPER_WIDTH');

INSERT INTO qxx_md_attr_def
  (factory_id, attr_code, attr_name, attr_type, attr_scope, widget_type, attr_unit, sort_order, enable_flag, create_by, create_time)
SELECT 0, 'INST_PAPER_WEIGHT', '实测克重', 'NUMBER', 'STOCK_INSTANCE', 'NUMBER', 'g', 20, '1', 'admin', sysdate()
  FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM qxx_md_attr_def WHERE attr_code = 'INST_PAPER_WEIGHT');

INSERT INTO qxx_md_attr_def
  (factory_id, attr_code, attr_name, attr_type, attr_scope, widget_type, attr_unit, sort_order, enable_flag, create_by, create_time)
SELECT 0, 'INST_LENGTH', '实测长度', 'NUMBER', 'STOCK_INSTANCE', 'NUMBER', 'm', 30, '1', 'admin', sysdate()
  FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM qxx_md_attr_def WHERE attr_code = 'INST_LENGTH');

INSERT INTO qxx_md_attr_def
  (factory_id, attr_code, attr_name, attr_type, attr_scope, widget_type, attr_unit, sort_order, enable_flag, create_by, create_time)
SELECT 0, 'INST_STEEL_OD', '外径', 'NUMBER', 'STOCK_INSTANCE', 'NUMBER', 'mm', 40, '1', 'admin', sysdate()
  FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM qxx_md_attr_def WHERE attr_code = 'INST_STEEL_OD');

INSERT INTO qxx_md_attr_def
  (factory_id, attr_code, attr_name, attr_type, attr_scope, widget_type, attr_unit, sort_order, enable_flag, create_by, create_time)
SELECT 0, 'INST_STEEL_WALL', '壁厚', 'NUMBER', 'STOCK_INSTANCE', 'NUMBER', 'mm', 50, '1', 'admin', sysdate()
  FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM qxx_md_attr_def WHERE attr_code = 'INST_STEEL_WALL');

-- 绑定纸张实测属性到原材料-纸张分类（factory_id 取分类自身，Flyway 显式写值）
INSERT INTO qxx_md_item_type_attr
  (factory_id, item_type_id, attr_id, required, sort_order, enable_flag, create_by, create_time)
SELECT t.factory_id, t.item_type_id, d.attr_id, '0', 200 + d.sort_order, '1', 'admin', sysdate()
  FROM qxx_md_item_type t
  JOIN qxx_md_attr_def d
 WHERE t.item_type_code = 'RAW-PAPER'
   AND d.attr_code IN ('INST_PAPER_WIDTH', 'INST_PAPER_WEIGHT', 'INST_LENGTH')
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item_type_attr ta
                    WHERE ta.item_type_id = t.item_type_id AND ta.attr_id = d.attr_id);
