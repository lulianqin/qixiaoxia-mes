-- ============================================================
-- 过程检验单工序归属修正
--
-- 背景：
--   1. 历史单 IPQC20261016003 的 process_name 为加工工序，但 process_id
--      误挂到了下游包装工序，导致「按被检工序顺序拦截下游」判定失效。
--      按工单工艺路线中的同名工序反查正确 process_id。
--   2. 成品入库自动生成的完工检属于工单级检验，不参与报工拦截；
--      历史数据若残留 process_id，统一置空（process_code/name 同步清空）。
--
-- 幂等：均为条件 UPDATE，重复执行结果不变。
-- ============================================================

SET NAMES utf8mb4;

-- ---------- 1. 修正历史工序检的工序归属 ----------
UPDATE qxx_qc_ipqc i
JOIN qxx_pro_workorder wo
  ON wo.workorder_id = i.workorder_id
 AND wo.factory_id = i.factory_id
JOIN qxx_pro_route_product rp
  ON rp.record_id = wo.route_product_id
 AND rp.factory_id = wo.factory_id
JOIN qxx_pro_route_process rpp
  ON rpp.route_id = rp.route_id
 AND rpp.factory_id = rp.factory_id
SET i.process_id = rpp.process_id,
    i.process_code = rpp.process_code,
    i.process_name = rpp.process_name
WHERE i.ipqc_code = 'IPQC20261016003'
  AND i.process_id IS NOT NULL
  AND i.process_id <> rpp.process_id
  AND i.process_name = rpp.process_name;

-- ---------- 2. 入库完工检回归工单级（不参与报工拦截） ----------
UPDATE qxx_qc_ipqc
SET process_id = NULL,
    process_code = NULL,
    process_name = NULL
WHERE source_doc_type = 'wm_product_recpt'
  AND process_id IS NOT NULL;
