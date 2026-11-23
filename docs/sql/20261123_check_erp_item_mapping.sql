-- =======================================================
-- ERP 产品「牛皮纸袋」→ MES 物料 FIN-BENQU-001 映射核查
-- 日期：2026-11-23
-- 背景：ERP 下发的采购单明细没有产品编码（SRM 明细 ProductCode 为空），
--       MES 只能按产品名称查 qxx_sys_external_mapping，命中后会用 MES 物料名称/编码覆盖行数据。
--       该映射建立于 2026-11-15 17:43:18（首次 ERP 采购单接单时人工关联），之后静默复用。
-- 说明：以下均为只读查询；如需清理/改绑，请人工确认后自行执行注释里的 DML。
-- =======================================================

-- 1. 现有 ERP 来源的产品映射（external_code 可能是编码，也可能是名称）
SELECT mapping_id, factory_id, system_code, entity_type, external_code, local_id, create_time
FROM qxx_sys_external_mapping
WHERE system_code = 'ERP' AND entity_type = 'ITEM'
ORDER BY mapping_id;

-- 2. 该映射指向的 MES 物料
SELECT item_id, item_code, item_name, specification, unit_of_measure, item_type_name
FROM qxx_md_item
WHERE item_id IN (
    SELECT local_id FROM qxx_sys_external_mapping
    WHERE system_code = 'ERP' AND entity_type = 'ITEM'
);

-- 3. 受影响的 ERP 来源订单行（名称被映射覆盖的历史单据）
SELECT o.order_code, o.external_order_no, l.line_no, l.product_code, l.product_name, l.create_time
FROM qxx_sal_order_line l
INNER JOIN qxx_sal_order o ON o.order_id = l.order_id
WHERE o.source_system = 'ERP'
ORDER BY o.order_id DESC, l.line_no;

-- 4.（可选，需人工确认后执行）解除该错误映射，让 MES 不再自动按名称改写产品
-- DELETE FROM qxx_sys_external_mapping
-- WHERE system_code = 'ERP' AND entity_type = 'ITEM' AND external_code = '牛皮纸袋';

-- 5.（可选）改为按产品编码映射后，ERP 侧需在采购明细上带 ProductCode，MES 会优先按编码匹配
