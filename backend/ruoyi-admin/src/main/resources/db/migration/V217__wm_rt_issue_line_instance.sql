-- ============================================================
-- V217: 生产退料行补实物实例字段
--
-- 背景：
--   V215 给 qxx_wm_rt_issue_detail 加了实例字段，但退料业务实际读写的是
--   qxx_wm_rt_issue_line（WmRtIssueLine / WmRtIssueLineMapper），
--   若不补列，退料保存与退回原实物实例会报 unknown column 'instance_id'。
--
-- 口径：与 V215 保持一致的列名与精度；仅加列，不动历史数据。
-- 字符集：utf8mb4    日期：2026-11-27
-- ============================================================

SET NAMES utf8mb4;

ALTER TABLE qxx_wm_rt_issue_line
  ADD COLUMN instance_id bigint(20) default null comment '实物实例ID（退回原卷/原根时写入）',
  ADD COLUMN instance_code varchar(64) default null comment '实物实例编号',
  ADD COLUMN instance_quantity decimal(18,4) default null comment '本次退回该实例的主单位数量';
