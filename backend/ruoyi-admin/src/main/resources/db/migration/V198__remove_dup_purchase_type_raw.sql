-- ============================================================
-- V198: 移除重复的采购类型「原料采购(RAW)」
--
-- 背景：字典 mes_purchase_type 中「纸张(PAPER)」与「原料采购(RAW)」语义重复，
--       纸张已覆盖原纸采购场景。经确认 RAW 历史单据为 0 条，直接删除字典项。
--
-- 字符集：utf8mb4
-- 日期：2026-11-18
-- ============================================================

SET NAMES utf8mb4;

DELETE FROM sys_dict_data
WHERE dict_type = 'mes_purchase_type' AND dict_value = 'RAW';
