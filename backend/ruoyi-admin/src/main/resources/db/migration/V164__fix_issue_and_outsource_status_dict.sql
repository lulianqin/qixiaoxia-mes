-- ============================================================
-- 补全领料单 / 外协单状态字典
--
-- 背景：
--   1. mes_wm_issue_status 只有 V136 补的 DRAFT/PENDING 两条，
--      实际数据还有 APPROVED/ALLOCATED/PARTIAL_ISSUED/ISSUED/CLOSED/CANCELED，
--      列表页 dict-tag 无法翻译，显示原始英文。
--   2. mes_wm_outsource_status 在 sys_dict_data 中一条数据都没有，
--      齐套看板外协单状态同样显示原始英文。
--   3. 两个字典在 sys_dict_type 中也缺少类型行（字典管理页不可见）。
--
-- 幂等：全部 WHERE NOT EXISTS；dict_code 为 auto_increment，
--       不显式指定（482-487 已被其它字典占用，写死会冲突）。
-- 注：sys_dict_type / sys_dict_data 无 factory_id 字段，不适用多工厂规则。
-- ============================================================

SET NAMES utf8mb4;

-- ---------- 1. 字典类型 ----------
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)
SELECT '领料单状态', 'mes_wm_issue_status', '0', 'admin', NOW(), '生产领料单生命周期状态'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_type WHERE dict_type = 'mes_wm_issue_status'
);

INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)
SELECT '外协单状态', 'mes_wm_outsource_status', '0', 'admin', NOW(), '外协订单生命周期状态'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_type WHERE dict_type = 'mes_wm_outsource_status'
);

-- ---------- 2. 领料单状态（DRAFT/PENDING 已存在，补齐其余 6 条） ----------
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 3, '已下达', 'APPROVED', 'mes_wm_issue_status', '', 'primary', 'N', '0', 'admin', NOW(), '审核通过，仓库可见，未预占库存'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_issue_status' AND dict_value = 'APPROVED'
);

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 4, '已预占', 'ALLOCATED', 'mes_wm_issue_status', '', 'info', 'N', '0', 'admin', NOW(), '已扣减可用库存，等待发料出库'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_issue_status' AND dict_value = 'ALLOCATED'
);

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 5, '部分发料', 'PARTIAL_ISSUED', 'mes_wm_issue_status', '', 'warning', 'N', '0', 'admin', NOW(), '分批发料中，已扣减部分现有库存'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_issue_status' AND dict_value = 'PARTIAL_ISSUED'
);

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 6, '已发料', 'ISSUED', 'mes_wm_issue_status', '', 'success', 'N', '0', 'admin', NOW(), '全量出库完成'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_issue_status' AND dict_value = 'ISSUED'
);

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 7, '已关闭', 'CLOSED', 'mes_wm_issue_status', '', 'info', 'N', '0', 'admin', NOW(), '产线收料确认或手工关闭（终态）'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_issue_status' AND dict_value = 'CLOSED'
);

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 8, '已作废', 'CANCELED', 'mes_wm_issue_status', '', 'danger', 'N', '0', 'admin', NOW(), '作废（终态），可删除'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_issue_status' AND dict_value = 'CANCELED'
);

-- ---------- 3. 外协单状态（全量 8 条） ----------
INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 1, '草稿', 'DRAFT', 'mes_wm_outsource_status', '', 'info', 'Y', '0', 'admin', NOW(), '外协单制单中'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_outsource_status' AND dict_value = 'DRAFT'
);

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 2, '已发料', 'ISSUED', 'mes_wm_outsource_status', '', 'warning', 'N', '0', 'admin', NOW(), '物料已发往厂商'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_outsource_status' AND dict_value = 'ISSUED'
);

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 3, '厂商已签收', 'VENDOR_RCVD', 'mes_wm_outsource_status', '', 'primary', 'N', '0', 'admin', NOW(), '厂商确认收到物料'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_outsource_status' AND dict_value = 'VENDOR_RCVD'
);

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 4, '加工中', 'PROCESSING', 'mes_wm_outsource_status', '', 'warning', 'N', '0', 'admin', NOW(), '厂商加工中'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_outsource_status' AND dict_value = 'PROCESSING'
);

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 5, '已完工', 'FINISHED', 'mes_wm_outsource_status', '', 'primary', 'N', '0', 'admin', NOW(), '厂商加工完成，待发货'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_outsource_status' AND dict_value = 'FINISHED'
);

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 6, '已发货', 'SHIPPED', 'mes_wm_outsource_status', '', 'primary', 'N', '0', 'admin', NOW(), '厂商已发货，可录入收货'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_outsource_status' AND dict_value = 'SHIPPED'
);

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 7, '已收货', 'RECEIVED', 'mes_wm_outsource_status', '', 'success', 'N', '0', 'admin', NOW(), '我方已收货入库'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_outsource_status' AND dict_value = 'RECEIVED'
);

INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
SELECT 8, '已关闭', 'CLOSED', 'mes_wm_outsource_status', '', 'info', 'N', '0', 'admin', NOW(), '外协单关闭（终态）'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_dict_data WHERE dict_type = 'mes_wm_outsource_status' AND dict_value = 'CLOSED'
);
