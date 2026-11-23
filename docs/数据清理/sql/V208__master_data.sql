-- ============================================================
-- V208 主数据重建：物料分类 / 物料 / 工艺路线 / 工序
-- 幂等
-- ============================================================

SET @now = NOW();
SET @op = 'admin';
SET @u_kg   = (SELECT unit_id FROM qxx_md_unit_measure WHERE unit_code='KG'   AND factory_id=1 LIMIT 1);
SET @u_pcs  = (SELECT unit_id FROM qxx_md_unit_measure WHERE unit_code='PCS'  AND factory_id=1 LIMIT 1);
SET @u_pair = (SELECT unit_id FROM qxx_md_unit_measure WHERE unit_code='PAIR' AND factory_id=1 LIMIT 1);

-- ---------- 1. 纸张三级分类 ----------
SET @t_paper = (SELECT item_type_id FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER' AND factory_id=1 LIMIT 1);
SET @t_rope  = (SELECT item_type_id FROM qxx_md_item_type WHERE item_type_code='RAW-ROPE'  AND factory_id=1 LIMIT 1);

INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP','食品级白牛皮',@t_paper,'RAW',10,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-SPBNP' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP','食品级黄牛皮',@t_paper,'RAW',20,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-SPHNP' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ','白挂面纸',@t_paper,'RAW',30,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-BGMZ' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ','TC箱板纸',@t_paper,'RAW',40,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-TCXBZ' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ','灰底白板纸',@t_paper,'RAW',50,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-HDHBZ' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ','彩色双胶纸',@t_paper,'RAW',60,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-CSSJZ' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-CSHN','赤松黄牛',@t_paper,'RAW',70,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-CSHN' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-RDCN','瑞典赤牛',@t_paper,'RAW',80,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-RDCN' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ','箱板纸',@t_paper,'RAW',90,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-XBZ' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP','白牛皮',@t_paper,'RAW',100,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-BNP' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-WK','乌卡',@t_paper,'RAW',110,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-WK' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-JN','精牛',@t_paper,'RAW',120,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-JN' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ','特种纸',@t_paper,'RAW',130,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-TZZ' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-PAPER-MD','梦迪',@t_paper,'RAW',140,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-PAPER-MD' AND factory_id=1);

-- 绳子二级分类（圆纸绳 / 扁纸绳）
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-ROPE-YZ','圆纸绳',@t_rope,'RAW',10,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-ROPE-YZ' AND factory_id=1);
INSERT INTO qxx_md_item_type (factory_id,item_type_code,item_type_name,parent_type_id,item_or_product,order_num,enable_flag,create_by,create_time)
SELECT 1,'RAW-ROPE-BZ','扁纸绳',@t_rope,'RAW',20,'1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_md_item_type WHERE item_type_code='RAW-ROPE-BZ' AND factory_id=1);

-- ---------- 2. 建保留清单，清理清单外的原有物料 ----------
DROP TEMPORARY TABLE IF EXISTS tmp_keep_item;
CREATE TEMPORARY TABLE tmp_keep_item (item_code VARCHAR(64) COLLATE utf8mb4_unicode_ci NOT NULL PRIMARY KEY);
INSERT INTO tmp_keep_item (item_code) VALUES
('RAW-PAPER-BNP-50'),
('RAW-PAPER-BNP-55'),
('RAW-PAPER-BNP-60'),
('RAW-PAPER-BNP-70'),
('RAW-PAPER-BNP-80'),
('RAW-PAPER-BNP-90'),
('RAW-PAPER-BNP-100'),
('RAW-PAPER-BNP-110'),
('RAW-PAPER-BNP-115'),
('RAW-PAPER-BNP-120'),
('RAW-PAPER-BNP-125'),
('RAW-PAPER-BNP-130'),
('RAW-PAPER-BNP-140'),
('RAW-PAPER-BNP-150'),
('RAW-PAPER-BNP-250'),
('RAW-PAPER-BNP-300'),
('RAW-PAPER-BNP-350'),
('RAW-PAPER-BNP-400'),
('RAW-PAPER-WK-50'),
('RAW-PAPER-WK-55'),
('RAW-PAPER-WK-60'),
('RAW-PAPER-WK-70'),
('RAW-PAPER-WK-80'),
('RAW-PAPER-WK-90'),
('RAW-PAPER-WK-100'),
('RAW-PAPER-WK-110'),
('RAW-PAPER-WK-115'),
('RAW-PAPER-WK-120'),
('RAW-PAPER-WK-125'),
('RAW-PAPER-WK-130'),
('RAW-PAPER-WK-140'),
('RAW-PAPER-WK-150'),
('RAW-PAPER-WK-250'),
('RAW-PAPER-WK-300'),
('RAW-PAPER-WK-350'),
('RAW-PAPER-WK-400'),
('RAW-PAPER-SPBNP-50'),
('RAW-PAPER-SPBNP-55'),
('RAW-PAPER-SPBNP-60'),
('RAW-PAPER-SPBNP-70'),
('RAW-PAPER-SPBNP-80'),
('RAW-PAPER-SPBNP-90'),
('RAW-PAPER-SPBNP-100'),
('RAW-PAPER-SPBNP-110'),
('RAW-PAPER-SPBNP-115'),
('RAW-PAPER-SPBNP-120'),
('RAW-PAPER-SPBNP-125'),
('RAW-PAPER-SPBNP-130'),
('RAW-PAPER-SPBNP-140'),
('RAW-PAPER-SPBNP-150'),
('RAW-PAPER-SPBNP-250'),
('RAW-PAPER-SPBNP-300'),
('RAW-PAPER-SPBNP-350'),
('RAW-PAPER-SPBNP-400'),
('RAW-PAPER-SPHNP-50'),
('RAW-PAPER-SPHNP-55'),
('RAW-PAPER-SPHNP-60'),
('RAW-PAPER-SPHNP-70'),
('RAW-PAPER-SPHNP-80'),
('RAW-PAPER-SPHNP-90'),
('RAW-PAPER-SPHNP-100'),
('RAW-PAPER-SPHNP-110'),
('RAW-PAPER-SPHNP-115'),
('RAW-PAPER-SPHNP-120'),
('RAW-PAPER-SPHNP-125'),
('RAW-PAPER-SPHNP-130'),
('RAW-PAPER-SPHNP-140'),
('RAW-PAPER-SPHNP-150'),
('RAW-PAPER-SPHNP-250'),
('RAW-PAPER-SPHNP-300'),
('RAW-PAPER-SPHNP-350'),
('RAW-PAPER-SPHNP-400'),
('RAW-PAPER-JN-50'),
('RAW-PAPER-JN-55'),
('RAW-PAPER-JN-60'),
('RAW-PAPER-JN-70'),
('RAW-PAPER-JN-80'),
('RAW-PAPER-JN-90'),
('RAW-PAPER-JN-100'),
('RAW-PAPER-JN-110'),
('RAW-PAPER-JN-115'),
('RAW-PAPER-JN-120'),
('RAW-PAPER-JN-125'),
('RAW-PAPER-JN-130'),
('RAW-PAPER-JN-140'),
('RAW-PAPER-JN-150'),
('RAW-PAPER-JN-250'),
('RAW-PAPER-JN-300'),
('RAW-PAPER-JN-350'),
('RAW-PAPER-JN-400'),
('RAW-PAPER-XBZ-50'),
('RAW-PAPER-XBZ-55'),
('RAW-PAPER-XBZ-60'),
('RAW-PAPER-XBZ-70'),
('RAW-PAPER-XBZ-80'),
('RAW-PAPER-XBZ-90'),
('RAW-PAPER-XBZ-100'),
('RAW-PAPER-XBZ-110'),
('RAW-PAPER-XBZ-115'),
('RAW-PAPER-XBZ-120'),
('RAW-PAPER-XBZ-125'),
('RAW-PAPER-XBZ-130'),
('RAW-PAPER-XBZ-140'),
('RAW-PAPER-XBZ-150'),
('RAW-PAPER-XBZ-250'),
('RAW-PAPER-XBZ-300'),
('RAW-PAPER-XBZ-350'),
('RAW-PAPER-XBZ-400'),
('RAW-PAPER-TCXBZ-50'),
('RAW-PAPER-TCXBZ-55'),
('RAW-PAPER-TCXBZ-60'),
('RAW-PAPER-TCXBZ-70'),
('RAW-PAPER-TCXBZ-80'),
('RAW-PAPER-TCXBZ-90'),
('RAW-PAPER-TCXBZ-100'),
('RAW-PAPER-TCXBZ-110'),
('RAW-PAPER-TCXBZ-115'),
('RAW-PAPER-TCXBZ-120'),
('RAW-PAPER-TCXBZ-125'),
('RAW-PAPER-TCXBZ-130'),
('RAW-PAPER-TCXBZ-140'),
('RAW-PAPER-TCXBZ-150'),
('RAW-PAPER-TCXBZ-250'),
('RAW-PAPER-TCXBZ-300'),
('RAW-PAPER-TCXBZ-350'),
('RAW-PAPER-TCXBZ-400'),
('RAW-PAPER-BGMZ-50'),
('RAW-PAPER-BGMZ-55'),
('RAW-PAPER-BGMZ-60'),
('RAW-PAPER-BGMZ-70'),
('RAW-PAPER-BGMZ-80'),
('RAW-PAPER-BGMZ-90'),
('RAW-PAPER-BGMZ-100'),
('RAW-PAPER-BGMZ-110'),
('RAW-PAPER-BGMZ-115'),
('RAW-PAPER-BGMZ-120'),
('RAW-PAPER-BGMZ-125'),
('RAW-PAPER-BGMZ-130'),
('RAW-PAPER-BGMZ-140'),
('RAW-PAPER-BGMZ-150'),
('RAW-PAPER-BGMZ-250'),
('RAW-PAPER-BGMZ-300'),
('RAW-PAPER-BGMZ-350'),
('RAW-PAPER-BGMZ-400'),
('RAW-PAPER-CSSJZ-50'),
('RAW-PAPER-CSSJZ-55'),
('RAW-PAPER-CSSJZ-60'),
('RAW-PAPER-CSSJZ-70'),
('RAW-PAPER-CSSJZ-80'),
('RAW-PAPER-CSSJZ-90'),
('RAW-PAPER-CSSJZ-100'),
('RAW-PAPER-CSSJZ-110'),
('RAW-PAPER-CSSJZ-115'),
('RAW-PAPER-CSSJZ-120'),
('RAW-PAPER-CSSJZ-125'),
('RAW-PAPER-CSSJZ-130'),
('RAW-PAPER-CSSJZ-140'),
('RAW-PAPER-CSSJZ-150'),
('RAW-PAPER-CSSJZ-250'),
('RAW-PAPER-CSSJZ-300'),
('RAW-PAPER-CSSJZ-350'),
('RAW-PAPER-CSSJZ-400'),
('RAW-PAPER-TZZ-50'),
('RAW-PAPER-TZZ-55'),
('RAW-PAPER-TZZ-60'),
('RAW-PAPER-TZZ-70'),
('RAW-PAPER-TZZ-80'),
('RAW-PAPER-TZZ-90'),
('RAW-PAPER-TZZ-100'),
('RAW-PAPER-TZZ-110'),
('RAW-PAPER-TZZ-115'),
('RAW-PAPER-TZZ-120'),
('RAW-PAPER-TZZ-125'),
('RAW-PAPER-TZZ-130'),
('RAW-PAPER-TZZ-140'),
('RAW-PAPER-TZZ-150'),
('RAW-PAPER-TZZ-250'),
('RAW-PAPER-TZZ-300'),
('RAW-PAPER-TZZ-350'),
('RAW-PAPER-TZZ-400'),
('RAW-PAPER-HDHBZ-50'),
('RAW-PAPER-HDHBZ-55'),
('RAW-PAPER-HDHBZ-60'),
('RAW-PAPER-HDHBZ-70'),
('RAW-PAPER-HDHBZ-80'),
('RAW-PAPER-HDHBZ-90'),
('RAW-PAPER-HDHBZ-100'),
('RAW-PAPER-HDHBZ-110'),
('RAW-PAPER-HDHBZ-115'),
('RAW-PAPER-HDHBZ-120'),
('RAW-PAPER-HDHBZ-125'),
('RAW-PAPER-HDHBZ-130'),
('RAW-PAPER-HDHBZ-140'),
('RAW-PAPER-HDHBZ-150'),
('RAW-PAPER-HDHBZ-250'),
('RAW-PAPER-HDHBZ-300'),
('RAW-PAPER-HDHBZ-350'),
('RAW-PAPER-HDHBZ-400'),
('RAW-PAPER-BNP-97'),
('RAW-PAPER-BNP-127'),
('RAW-PAPER-BNP-117'),
('RAW-PAPER-BNP-147'),
('RAW-PAPER-CSHN-80'),
('RAW-PAPER-RDCN-100'),
('RAW-PAPER-MD-120'),
('RAW-PAPER-JN-95'),
('RAW-PAPER-JN-210'),
('RAW-PAPER-WK-80-1100'),
('RAW-PAPER-WK-100-500'),
('RAW-PAPER-WK-100-670'),
('RAW-PAPER-WK-100-865'),
('RAW-PAPER-WK-100-900'),
('RAW-PAPER-WK-100-910'),
('RAW-PAPER-WK-100-925'),
('RAW-PAPER-WK-115-480'),
('RAW-PAPER-WK-115-670'),
('RAW-PAPER-WK-115-675'),
('RAW-PAPER-WK-115-685'),
('RAW-PAPER-WK-115-725'),
('RAW-PAPER-WK-115-790'),
('RAW-PAPER-WK-115-800'),
('RAW-PAPER-WK-115-885'),
('RAW-PAPER-WK-115-995'),
('RAW-PAPER-WK-115-1000'),
('RAW-PAPER-WK-115-1025'),
('RAW-PAPER-WK-115-1100'),
('RAW-PAPER-WK-115-1030'),
('RAW-PAPER-WK-115-1050'),
('RAW-PAPER-WK-115-1175'),
('RAW-PAPER-WK-115-1185'),
('RAW-PAPER-WK-115-1200'),
('RAW-PAPER-WK-115-1235'),
('RAW-PAPER-WK-115-2350'),
('RAW-PAPER-WK-115-1027'),
('RAW-PAPER-WK-120-1032'),
('RAW-PAPER-WK-120-2100'),
('RAW-PAPER-WK-120-2200'),
('RAW-PAPER-WK-125-1165'),
('RAW-PAPER-WK-125-1185'),
('RAW-PAPER-WK-125-1200'),
('RAW-PAPER-WK-125-1300'),
('RAW-PAPER-WK-150-500'),
('RAW-PAPER-WK-150-485'),
('RAW-PAPER-WK-150-790'),
('RAW-PAPER-WK-150-980'),
('RAW-PAPER-WK-150-1042'),
('RAW-PAPER-WK-150-1210'),
('RAW-PAPER-WK-150-2100'),
('RAW-PAPER-WK-150-2400'),
('RAW-PAPER-XBZ-90-1720'),
('RAW-PAPER-XBZ-90-500'),
('RAW-PAPER-XBZ-90-490'),
('RAW-PAPER-XBZ-100-335'),
('RAW-PAPER-XBZ-100-675'),
('RAW-PAPER-XBZ-100-745'),
('RAW-PAPER-XBZ-100-755'),
('RAW-PAPER-XBZ-100-870'),
('RAW-PAPER-XBZ-100-1110'),
('RAW-PAPER-XBZ-100-1185'),
('RAW-PAPER-XBZ-100-1345'),
('RAW-PAPER-XBZ-110-490'),
('RAW-PAPER-XBZ-110-670'),
('RAW-PAPER-XBZ-110-680'),
('RAW-PAPER-XBZ-110-685'),
('RAW-PAPER-XBZ-110-730'),
('RAW-PAPER-XBZ-110-800'),
('RAW-PAPER-XBZ-110-810'),
('RAW-PAPER-XBZ-110-820'),
('RAW-PAPER-XBZ-110-950'),
('RAW-PAPER-XBZ-110-1070'),
('RAW-PAPER-XBZ-110-1225'),
('RAW-PAPER-XBZ-110-1250'),
('RAW-PAPER-XBZ-110-1300'),
('RAW-PAPER-XBZ-120-450'),
('RAW-PAPER-XBZ-120-485'),
('RAW-PAPER-XBZ-120-510'),
('RAW-PAPER-XBZ-120-500'),
('RAW-PAPER-XBZ-120-550'),
('RAW-PAPER-XBZ-120-560'),
('RAW-PAPER-XBZ-120-570'),
('RAW-PAPER-XBZ-120-685'),
('RAW-PAPER-XBZ-120-725'),
('RAW-PAPER-XBZ-120-730'),
('RAW-PAPER-XBZ-120-775'),
('RAW-PAPER-XBZ-120-785'),
('RAW-PAPER-XBZ-120-790'),
('RAW-PAPER-XBZ-120-800'),
('RAW-PAPER-XBZ-120-850'),
('RAW-PAPER-XBZ-120-900'),
('RAW-PAPER-XBZ-120-935'),
('RAW-PAPER-XBZ-120-915'),
('RAW-PAPER-XBZ-120-1000'),
('RAW-PAPER-XBZ-120-1025'),
('RAW-PAPER-XBZ-120-1040'),
('RAW-PAPER-XBZ-120-1050'),
('RAW-PAPER-XBZ-120-1100'),
('RAW-PAPER-XBZ-120-1150'),
('RAW-PAPER-XBZ-120-1250'),
('RAW-PAPER-XBZ-120-1450'),
('RAW-PAPER-XBZ-120-1500'),
('RAW-PAPER-XBZ-120-1800'),
('RAW-PAPER-XBZ-120-1600'),
('RAW-PAPER-XBZ-120-2000'),
('RAW-PAPER-XBZ-130-1000'),
('RAW-PAPER-XBZ-140-525'),
('RAW-PAPER-XBZ-140-670'),
('RAW-PAPER-XBZ-140-900'),
('RAW-PAPER-XBZ-140-1200'),
('RAW-PAPER-XBZ-150-800'),
('RAW-PAPER-XBZ-150-820'),
('RAW-PAPER-XBZ-150-950'),
('RAW-PAPER-XBZ-150-1045'),
('RAW-PAPER-XBZ-150-1150'),
('RAW-PAPER-XBZ-150-1250'),
('RAW-PAPER-BGMZ-125-530'),
('RAW-PAPER-BGMZ-125-540'),
('RAW-PAPER-BGMZ-125-675'),
('RAW-PAPER-BGMZ-125-900'),
('RAW-PAPER-TCXBZ-100-780'),
('RAW-PAPER-TCXBZ-100-830'),
('RAW-PAPER-TCXBZ-100-900'),
('RAW-PAPER-TCXBZ-100-1020'),
('RAW-PAPER-TCXBZ-100-1250'),
('RAW-PAPER-TCXBZ-120-525'),
('RAW-PAPER-TCXBZ-120-667'),
('RAW-PAPER-TCXBZ-120-675'),
('RAW-PAPER-TCXBZ-120-670'),
('RAW-PAPER-TCXBZ-120-800'),
('RAW-PAPER-TCXBZ-120-810'),
('RAW-PAPER-TCXBZ-120-900'),
('RAW-PAPER-TCXBZ-120-905'),
('RAW-PAPER-TCXBZ-120-950'),
('RAW-PAPER-TCXBZ-120-960'),
('RAW-PAPER-TCXBZ-120-1050'),
('RAW-PAPER-TCXBZ-120-1350'),
('RAW-PAPER-TCXBZ-120-1800'),
('RAW-PAPER-TCXBZ-120-1850'),
('RAW-PAPER-TCXBZ-120-2000'),
('RAW-PAPER-TCXBZ-130-860'),
('RAW-PAPER-BNP-80-1092'),
('RAW-PAPER-BNP-97-595'),
('RAW-PAPER-BNP-120-850'),
('RAW-PAPER-BNP-127-1005'),
('RAW-PAPER-BNP-117-980'),
('RAW-PAPER-BNP-117-1194'),
('RAW-PAPER-BNP-117-1000'),
('RAW-PAPER-BNP-150-597'),
('RAW-PAPER-BNP-97-485'),
('RAW-PAPER-BNP-97-670'),
('RAW-PAPER-BNP-97-820'),
('RAW-PAPER-BNP-97-787'),
('RAW-PAPER-BNP-97-910'),
('RAW-PAPER-BNP-97-1000'),
('RAW-PAPER-BNP-97-1013'),
('RAW-PAPER-BNP-97-1092'),
('RAW-PAPER-BNP-97-1190'),
('RAW-PAPER-BNP-97-1195'),
('RAW-PAPER-BNP-97-1294'),
('RAW-PAPER-BNP-117-485'),
('RAW-PAPER-BNP-117-630'),
('RAW-PAPER-BNP-117-877'),
('RAW-PAPER-BNP-117-889'),
('RAW-PAPER-BNP-117-1002'),
('RAW-PAPER-BNP-117-1030'),
('RAW-PAPER-BNP-117-1047'),
('RAW-PAPER-BNP-117-1050'),
('RAW-PAPER-BNP-117-1240'),
('RAW-PAPER-BNP-127-1025'),
('RAW-PAPER-BNP-147-889'),
('RAW-PAPER-BNP-147-1105'),
('RAW-PAPER-BNP-97-685'),
('RAW-PAPER-BNP-117-490'),
('RAW-PAPER-BNP-117-580'),
('RAW-PAPER-BNP-117-680'),
('RAW-PAPER-BNP-117-510'),
('RAW-PAPER-BNP-117-725'),
('RAW-PAPER-BNP-117-1255'),
('RAW-PAPER-BNP-117-787'),
('RAW-PAPER-BNP-117-481'),
('RAW-PAPER-BNP-117-665'),
('RAW-PAPER-CSHN-80-889'),
('RAW-PAPER-RDCN-100-830'),
('RAW-PAPER-RDCN-100-960'),
('RAW-PAPER-RDCN-100-1100'),
('RAW-PAPER-MD-120-900'),
('RAW-PAPER-MD-120-720'),
('RAW-PAPER-JN-80-850'),
('RAW-PAPER-JN-80-935'),
('RAW-PAPER-JN-95-889'),
('RAW-PAPER-JN-140-889'),
('RAW-PAPER-JN-210-1160'),
('RAW-EDGE-WK-115-45'),
('RAW-EDGE-WK-115-90'),
('RAW-EDGE-WK-120-90'),
('RAW-EDGE-WK-120-45'),
('RAW-EDGE-WK-125-90'),
('RAW-EDGE-WK-150-90'),
('RAW-EDGE-XBZ-90-80'),
('RAW-EDGE-XBZ-100-80'),
('RAW-EDGE-XBZ-100-90'),
('RAW-EDGE-XBZ-110-90'),
('RAW-EDGE-XBZ-120-80'),
('RAW-EDGE-XBZ-120-90'),
('RAW-EDGE-TCXBZ-120-90'),
('RAW-EDGE-BGMZ-125-90'),
('RAW-EDGE-BNP-97-90'),
('RAW-EDGE-BNP-100-86'),
('RAW-EDGE-BNP-110-90'),
('RAW-EDGE-BNP-117-45'),
('RAW-EDGE-BNP-127-90'),
('RAW-EDGE-RDCN-100-90'),
('AUX-ROPE-BNPY'),
('AUX-ROPE-HNPY'),
('AUX-ROPE-HSY'),
('AUX-ROPE-CSY'),
('AUX-ROPE-HNPB'),
('AUX-ROPE-BNPB'),
('AUX-ROPE-HSB'),
('AUX-ROPE-CSB'),
('FIN-SPOT-0001'),
('FIN-SPOT-0002'),
('FIN-SPOT-0003'),
('FIN-SPOT-0004'),
('FIN-SPOT-0005'),
('FIN-SPOT-0006'),
('FIN-SPOT-0007'),
('FIN-SPOT-0008'),
('FIN-SPOT-0009'),
('FIN-SPOT-0010'),
('FIN-SPOT-0011'),
('FIN-SPOT-0012'),
('FIN-SPOT-0013'),
('FIN-SPOT-0014'),
('FIN-SPOT-0015'),
('FIN-SPOT-0016'),
('FIN-SPOT-0017'),
('FIN-SPOT-0018'),
('FIN-SPOT-0019'),
('FIN-SPOT-0020'),
('FIN-SPOT-0021'),
('FIN-SPOT-0022'),
('FIN-SPOT-0023'),
('FIN-SPOT-0024'),
('FIN-SPOT-0025'),
('FIN-SPOT-0026'),
('FIN-SPOT-0027'),
('FIN-SPOT-0028'),
('FIN-SPOT-0029'),
('FIN-SPOT-0030'),
('FIN-SPOT-0031'),
('FIN-SPOT-0032'),
('FIN-SPOT-0033'),
('FIN-SPOT-0034'),
('FIN-SPOT-0035'),
('FIN-SPOT-0036'),
('FIN-SPOT-0037'),
('FIN-SPOT-0038'),
('FIN-SPOT-0039'),
('FIN-SPOT-0040'),
('FIN-SPOT-0041'),
('FIN-SPOT-0042'),
('FIN-SPOT-0043'),
('FIN-SPOT-0044'),
('FIN-SPOT-0045'),
('FIN-SPOT-0046'),
('FIN-SPOT-0047'),
('FIN-SPOT-0048'),
('FIN-SPOT-0049'),
('FIN-SPOT-0050'),
('FIN-SPOT-0051'),
('FIN-SPOT-0052'),
('FIN-SPOT-0053'),
('FIN-SPOT-0054'),
('FIN-SPOT-0055'),
('FIN-SPOT-0056'),
('FIN-SPOT-0057'),
('FIN-SPOT-0058'),
('FIN-SPOT-0059'),
('FIN-SPOT-0060'),
('FIN-SPOT-0061'),
('FIN-SPOT-0062'),
('FIN-SPOT-0063'),
('FIN-SPOT-0064'),
('FIN-SPOT-0065'),
('FIN-SPOT-0066'),
('FIN-SPOT-0067'),
('FIN-SPOT-0068'),
('FIN-SPOT-0069'),
('FIN-SPOT-0070'),
('FIN-WAI-0001'),
('FIN-WAI-0002'),
('FIN-WAI-0003'),
('FIN-WAI-0004'),
('FIN-WAI-0005'),
('FIN-WAI-0006'),
('FIN-WAI-0007'),
('FIN-WAI-0008'),
('FIN-WAI-0009'),
('FIN-WAI-0010'),
('FIN-WAI-0011'),
('FIN-WAI-0012'),
('FIN-WAI-0013'),
('FIN-WAI-0014'),
('FIN-WAI-0015'),
('FIN-WAI-0016'),
('FIN-WAI-0017'),
('FIN-WAI-0018'),
('FIN-WAI-0019'),
('FIN-WAI-0020'),
('FIN-WAI-0021'),
('FIN-ORD-0001'),
('FIN-ORD-0002'),
('FIN-ORD-0003'),
('FIN-ORD-0004'),
('FIN-ORD-0005'),
('FIN-ORD-0006'),
('FIN-ORD-0007'),
('FIN-ORD-0008'),
('FIN-ORD-0009'),
('FIN-ORD-0010'),
('FIN-ORD-0011'),
('FIN-ORD-0012'),
('FIN-ORD-0013'),
('FIN-ORD-0014'),
('FIN-ORD-0015'),
('FIN-ORD-0016'),
('FIN-ORD-0017'),
('FIN-ORD-0018'),
('FIN-ORD-0019'),
('FIN-ORD-0020'),
('FIN-ORD-0021'),
('FIN-ORD-0022'),
('FIN-ORD-0023'),
('FIN-ORD-0024'),
('FIN-ORD-0025'),
('FIN-ORD-0026'),
('FIN-ORD-0027'),
('FIN-ORD-0028'),
('FIN-ORD-0029'),
('FIN-ORD-0030'),
('FIN-ORD-0031'),
('FIN-ORD-0032'),
('FIN-ORD-0033'),
('FIN-ORD-0034'),
('FIN-ORD-0035'),
('FIN-ORD-0036'),
('FIN-ORD-0037'),
('FIN-ORD-0038'),
('FIN-ORD-0039'),
('FIN-ORD-0040'),
('FIN-ORD-0041'),
('FIN-ORD-0042'),
('FIN-ORD-0043'),
('FIN-ORD-0044'),
('FIN-ORD-0045'),
('FIN-ORD-0046'),
('FIN-ORD-0047'),
('FIN-ORD-0048'),
('FIN-ORD-0049'),
('FIN-ORD-0050'),
('FIN-ORD-0051'),
('FIN-ORD-0052'),
('FIN-ORD-0053'),
('FIN-ORD-0054'),
('FIN-ORD-0055'),
('FIN-ORD-0056'),
('FIN-ORD-0057'),
('FIN-ORD-0058'),
('FIN-ORD-0059'),
('FIN-ORD-0060'),
('FIN-ORD-0061'),
('FIN-ORD-0062'),
('FIN-ORD-0063'),
('FIN-ORD-0064'),
('FIN-ORD-0065'),
('FIN-ORD-0066'),
('FIN-ORD-0067'),
('FIN-ORD-0068'),
('FIN-ORD-0069'),
('FIN-ORD-0070'),
('FIN-ORD-0071'),
('FIN-ORD-0072'),
('FIN-ORD-0073'),
('FIN-ORD-0074'),
('FIN-ORD-0075'),
('FIN-ORD-0076'),
('FIN-ORD-0077'),
('FIN-ORD-0078'),
('FIN-ORD-0079'),
('FIN-ORD-0080'),
('FIN-ORD-0081'),
('FIN-ORD-0082'),
('FIN-ORD-0083'),
('FIN-ORD-0084'),
('FIN-ORD-0085'),
('FIN-ORD-0086'),
('FIN-ORD-0087'),
('FIN-ORD-0088'),
('FIN-ORD-0089'),
('FIN-ORD-0090'),
('FIN-ORD-0091'),
('FIN-ORD-0092'),
('FIN-ORD-0093'),
('FIN-ORD-0094'),
('FIN-ORD-0095'),
('FIN-ORD-0096'),
('FIN-ORD-0097'),
('FIN-ORD-0098'),
('FIN-ORD-0099'),
('FIN-ORD-0100'),
('FIN-ORD-0101'),
('FIN-ORD-0102'),
('FIN-ORD-0103'),
('FIN-ORD-0104'),
('FIN-ORD-0105'),
('FIN-ORD-0106'),
('FIN-ORD-0107'),
('FIN-ORD-0108'),
('FIN-ORD-0109'),
('FIN-ORD-0110'),
('FIN-ORD-0111'),
('FIN-ORD-0112'),
('FIN-ORD-0113'),
('FIN-ORD-0114'),
('FIN-ORD-0115'),
('FIN-ORD-0116'),
('FIN-ORD-0117'),
('FIN-ORD-0118'),
('FIN-ORD-0119'),
('FIN-ORD-0120'),
('FIN-ORD-0121'),
('FIN-ORD-0122'),
('FIN-ORD-0123'),
('FIN-ORD-0124'),
('FIN-ORD-0125'),
('FIN-ORD-0126'),
('FIN-ORD-0127'),
('FIN-ORD-0128'),
('FIN-ORD-0129'),
('FIN-ORD-0130'),
('FIN-ORD-0131'),
('FIN-ORD-0132'),
('FIN-ORD-0133'),
('FIN-ORD-0134'),
('FIN-ORD-0135'),
('FIN-ORD-0136'),
('FIN-ORD-0137'),
('FIN-ORD-0138'),
('FIN-ORD-0139'),
('FIN-ORD-0140'),
('FIN-ORD-0141'),
('FIN-ORD-0142'),
('FIN-ORD-0143'),
('FIN-ORD-0144'),
('FIN-ORD-0145'),
('FIN-ORD-0146'),
('FIN-ORD-0147'),
('FIN-ORD-0148'),
('FIN-ORD-0149'),
('FIN-ORD-0150'),
('FIN-ORD-0151'),
('FIN-ORD-0152'),
('FIN-ORD-0153'),
('FIN-ORD-0154'),
('FIN-ORD-0155'),
('FIN-ORD-0156'),
('FIN-ORD-0157'),
('FIN-ORD-0158'),
('FIN-ORD-0159'),
('FIN-ORD-0160'),
('FIN-ORD-0161'),
('FIN-ORD-0162'),
('FIN-ORD-0163'),
('FIN-ORD-0164'),
('FIN-ORD-0165'),
('FIN-ORD-0166'),
('FIN-ORD-0167'),
('FIN-ORD-0168'),
('FIN-ORD-0169'),
('FIN-ORD-0170'),
('FIN-ORD-0171'),
('FIN-ORD-0172'),
('FIN-ORD-0173'),
('FIN-ORD-0174'),
('FIN-ORD-0175'),
('FIN-ORD-0176'),
('FIN-ORD-0177'),
('FIN-ORD-0178'),
('FIN-ORD-0179'),
('FIN-ORD-0180'),
('FIN-ORD-0181'),
('FIN-ORD-0182'),
('FIN-ORD-0183'),
('FIN-ORD-0184'),
('FIN-ORD-0185'),
('FIN-ORD-0186'),
('FIN-ORD-0187'),
('FIN-ORD-0188'),
('FIN-ORD-0189'),
('FIN-ORD-0190'),
('FIN-ORD-0191'),
('FIN-ORD-0192'),
('FIN-ORD-0193'),
('FIN-ORD-0194'),
('FIN-ORD-0195'),
('FIN-ORD-0196'),
('FIN-ORD-0197'),
('FIN-ORD-0198'),
('FIN-ORD-0199'),
('FIN-ORD-0200'),
('FIN-ORD-0201'),
('FIN-ORD-0202'),
('FIN-ORD-0203'),
('FIN-ORD-0204'),
('FIN-ORD-0205'),
('FIN-ORD-0206'),
('FIN-ORD-0207'),
('FIN-ORD-0208'),
('FIN-ORD-0209'),
('FIN-ORD-0210'),
('FIN-ORD-0211'),
('FIN-ORD-0212'),
('FIN-ORD-0213'),
('FIN-ORD-0214'),
('FIN-ORD-0215'),
('FIN-ORD-0216'),
('FIN-ORD-0217'),
('FIN-ORD-0218'),
('FIN-ORD-0219'),
('FIN-ORD-0220'),
('FIN-ORD-0221'),
('FIN-ORD-0222'),
('FIN-ORD-0223'),
('FIN-ORD-0224'),
('FIN-ORD-0225'),
('FIN-ORD-0226'),
('FIN-ORD-0227'),
('FIN-ORD-0228'),
('FIN-ORD-0229'),
('FIN-ORD-0230'),
('FIN-ORD-0231'),
('FIN-ORD-0232'),
('FIN-ORD-0233');

-- 不在清单内的物料逻辑删除（含历史测试物料）
UPDATE qxx_md_item i LEFT JOIN tmp_keep_item k ON i.item_code=k.item_code
   SET i.del_flag='2', i.enable_flag='0', i.update_by=@op, i.update_time=@now
 WHERE i.factory_id=1 AND i.del_flag='0' AND k.item_code IS NULL;

-- ---------- 3. 纸张 SPU ----------
-- 柔印 11 种纸 x 18 种克重 全量 + 库存中出现的其他克重
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-50','50克白牛皮','50g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 50}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-50' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-55','55克白牛皮','55g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 55}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-55' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-60','60克白牛皮','60g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 60}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-60' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-70','70克白牛皮','70g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 70}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-70' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-80','80克白牛皮','80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 80}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-90','90克白牛皮','90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 90}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-100','100克白牛皮','100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 100}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-110','110克白牛皮','110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 110}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-110' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-115','115克白牛皮','115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 115}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-115' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-120','120克白牛皮','120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 120}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-120' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-125','125克白牛皮','125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 125}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-125' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-130','130克白牛皮','130g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 130}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-130' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-140','140克白牛皮','140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 140}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-140' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-150','150克白牛皮','150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 150}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-250','250克白牛皮','250g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 250}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-300','300克白牛皮','300g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 300}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-300' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-350','350克白牛皮','350g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 350}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-350' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-400','400克白牛皮','400g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 400}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-400' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-50','50克乌卡','50g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 50}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-50' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-55','55克乌卡','55g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 55}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-55' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-60','60克乌卡','60g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 60}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-60' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-70','70克乌卡','70g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 70}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-70' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-80','80克乌卡','80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 80}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-90','90克乌卡','90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 90}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-100','100克乌卡','100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 100}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-110','110克乌卡','110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 110}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-110' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115','115克乌卡','115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-120','120克乌卡','120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 120}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-120' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-125','125克乌卡','125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 125}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-125' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-130','130克乌卡','130g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 130}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-130' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-140','140克乌卡','140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 140}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-140' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-150','150克乌卡','150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 150}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-250','250克乌卡','250g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 250}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-300','300克乌卡','300g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 300}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-300' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-350','350克乌卡','350g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 350}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-350' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-400','400克乌卡','400g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 400}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-400' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-50','50克食品级白牛皮','50g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 50}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-50' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-55','55克食品级白牛皮','55g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 55}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-55' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-60','60克食品级白牛皮','60g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 60}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-60' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-70','70克食品级白牛皮','70g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 70}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-70' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-80','80克食品级白牛皮','80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 80}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-90','90克食品级白牛皮','90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 90}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-100','100克食品级白牛皮','100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 100}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-110','110克食品级白牛皮','110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 110}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-110' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-115','115克食品级白牛皮','115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 115}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-115' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-120','120克食品级白牛皮','120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 120}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-120' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-125','125克食品级白牛皮','125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 125}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-125' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-130','130克食品级白牛皮','130g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 130}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-130' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-140','140克食品级白牛皮','140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 140}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-140' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-150','150克食品级白牛皮','150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 150}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-250','250克食品级白牛皮','250g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 250}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-300','300克食品级白牛皮','300g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 300}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-300' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-350','350克食品级白牛皮','350g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 350}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-350' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPBNP-400','400克食品级白牛皮','400g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级白牛皮", "PAPER_WEIGHT": 400}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPBNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPBNP-400' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-50','50克食品级黄牛皮','50g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 50}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-50' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-55','55克食品级黄牛皮','55g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 55}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-55' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-60','60克食品级黄牛皮','60g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 60}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-60' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-70','70克食品级黄牛皮','70g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 70}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-70' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-80','80克食品级黄牛皮','80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 80}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-90','90克食品级黄牛皮','90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 90}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-100','100克食品级黄牛皮','100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 100}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-110','110克食品级黄牛皮','110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 110}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-110' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-115','115克食品级黄牛皮','115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 115}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-115' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-120','120克食品级黄牛皮','120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 120}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-120' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-125','125克食品级黄牛皮','125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 125}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-125' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-130','130克食品级黄牛皮','130g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 130}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-130' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-140','140克食品级黄牛皮','140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 140}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-140' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-150','150克食品级黄牛皮','150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 150}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-250','250克食品级黄牛皮','250g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 250}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-300','300克食品级黄牛皮','300g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 300}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-300' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-350','350克食品级黄牛皮','350g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 350}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-350' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-SPHNP-400','400克食品级黄牛皮','400g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "食品级黄牛皮", "PAPER_WEIGHT": 400}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-SPHNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-SPHNP-400' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-50','50克精牛','50g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 50}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-50' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-55','55克精牛','55g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 55}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-55' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-60','60克精牛','60g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 60}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-60' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-70','70克精牛','70g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 70}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-70' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-80','80克精牛','80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 80}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-90','90克精牛','90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 90}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-100','100克精牛','100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 100}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-110','110克精牛','110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 110}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-110' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-115','115克精牛','115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 115}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-115' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-120','120克精牛','120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 120}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-120' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-125','125克精牛','125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 125}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-125' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-130','130克精牛','130g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 130}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-130' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-140','140克精牛','140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 140}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-140' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-150','150克精牛','150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 150}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-250','250克精牛','250g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 250}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-300','300克精牛','300g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 300}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-300' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-350','350克精牛','350g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 350}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-350' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-400','400克精牛','400g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 400}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-400' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-50','50克箱板纸','50g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 50}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-50' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-55','55克箱板纸','55g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 55}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-55' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-60','60克箱板纸','60g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 60}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-60' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-70','70克箱板纸','70g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 70}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-70' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-80','80克箱板纸','80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 80}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-90','90克箱板纸','90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 90}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-100','100克箱板纸','100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 100}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110','110克箱板纸','110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-115','115克箱板纸','115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 115}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-115' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120','120克箱板纸','120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-125','125克箱板纸','125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 125}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-125' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-130','130克箱板纸','130g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 130}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-130' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-140','140克箱板纸','140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 140}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-140' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-150','150克箱板纸','150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 150}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-250','250克箱板纸','250g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 250}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-300','300克箱板纸','300g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 300}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-300' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-350','350克箱板纸','350g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 350}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-350' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-400','400克箱板纸','400g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 400}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-400' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-50','50克TC箱板纸','50g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 50}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-50' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-55','55克TC箱板纸','55g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 55}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-55' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-60','60克TC箱板纸','60g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 60}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-60' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-70','70克TC箱板纸','70g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 70}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-70' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-80','80克TC箱板纸','80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 80}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-90','90克TC箱板纸','90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 90}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-100','100克TC箱板纸','100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 100}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-110','110克TC箱板纸','110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 110}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-110' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-115','115克TC箱板纸','115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 115}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-115' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120','120克TC箱板纸','120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-125','125克TC箱板纸','125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 125}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-125' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-130','130克TC箱板纸','130g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 130}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-130' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-140','140克TC箱板纸','140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 140}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-140' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-150','150克TC箱板纸','150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 150}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-250','250克TC箱板纸','250g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 250}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-300','300克TC箱板纸','300g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 300}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-300' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-350','350克TC箱板纸','350g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 350}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-350' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-400','400克TC箱板纸','400g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 400}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-400' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-50','50克白挂面纸','50g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 50}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-50' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-55','55克白挂面纸','55g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 55}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-55' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-60','60克白挂面纸','60g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 60}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-60' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-70','70克白挂面纸','70g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 70}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-70' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-80','80克白挂面纸','80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 80}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-90','90克白挂面纸','90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 90}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-100','100克白挂面纸','100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 100}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-110','110克白挂面纸','110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 110}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-110' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-115','115克白挂面纸','115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 115}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-115' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-120','120克白挂面纸','120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 120}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-120' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-125','125克白挂面纸','125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 125}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-125' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-130','130克白挂面纸','130g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 130}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-130' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-140','140克白挂面纸','140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 140}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-140' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-150','150克白挂面纸','150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 150}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-250','250克白挂面纸','250g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 250}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-300','300克白挂面纸','300g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 300}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-300' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-350','350克白挂面纸','350g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 350}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-350' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-400','400克白挂面纸','400g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 400}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-400' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-50','50克彩色双胶纸','50g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 50}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-50' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-55','55克彩色双胶纸','55g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 55}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-55' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-60','60克彩色双胶纸','60g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 60}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-60' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-70','70克彩色双胶纸','70g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 70}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-70' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-80','80克彩色双胶纸','80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 80}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-90','90克彩色双胶纸','90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 90}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-100','100克彩色双胶纸','100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 100}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-110','110克彩色双胶纸','110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 110}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-110' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-115','115克彩色双胶纸','115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 115}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-115' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-120','120克彩色双胶纸','120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 120}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-120' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-125','125克彩色双胶纸','125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 125}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-125' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-130','130克彩色双胶纸','130g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 130}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-130' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-140','140克彩色双胶纸','140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 140}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-140' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-150','150克彩色双胶纸','150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 150}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-250','250克彩色双胶纸','250g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 250}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-300','300克彩色双胶纸','300g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 300}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-300' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-350','350克彩色双胶纸','350g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 350}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-350' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSSJZ-400','400克彩色双胶纸','400g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "彩色双胶纸", "PAPER_WEIGHT": 400}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSSJZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSSJZ-400' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-50','50克特种纸','50g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 50}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-50' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-55','55克特种纸','55g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 55}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-55' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-60','60克特种纸','60g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 60}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-60' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-70','70克特种纸','70g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 70}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-70' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-80','80克特种纸','80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 80}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-90','90克特种纸','90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 90}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-100','100克特种纸','100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 100}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-110','110克特种纸','110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 110}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-110' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-115','115克特种纸','115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 115}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-115' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-120','120克特种纸','120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 120}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-120' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-125','125克特种纸','125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 125}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-125' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-130','130克特种纸','130g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 130}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-130' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-140','140克特种纸','140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 140}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-140' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-150','150克特种纸','150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 150}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-250','250克特种纸','250g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 250}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-300','300克特种纸','300g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 300}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-300' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-350','350克特种纸','350g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 350}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-350' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-TZZ-400','400克特种纸','400g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "特种纸", "PAPER_WEIGHT": 400}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TZZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TZZ-400' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-50','50克灰底白板纸','50g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 50}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-50' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-55','55克灰底白板纸','55g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 55}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-55' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-60','60克灰底白板纸','60g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 60}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-60' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-70','70克灰底白板纸','70g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 70}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-70' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-80','80克灰底白板纸','80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 80}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-90','90克灰底白板纸','90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 90}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-100','100克灰底白板纸','100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 100}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-110','110克灰底白板纸','110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 110}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-110' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-115','115克灰底白板纸','115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 115}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-115' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-120','120克灰底白板纸','120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 120}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-120' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-125','125克灰底白板纸','125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 125}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-125' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-130','130克灰底白板纸','130g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 130}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-130' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-140','140克灰底白板纸','140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 140}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-140' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-150','150克灰底白板纸','150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 150}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-250','250克灰底白板纸','250g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 250}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-300','300克灰底白板纸','300g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 300}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-300' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-350','350克灰底白板纸','350g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 350}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-350' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-HDHBZ-400','400克灰底白板纸','400g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "灰底白板纸", "PAPER_WEIGHT": 400}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-HDHBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-HDHBZ-400' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97','97克白牛皮','97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-127','127克白牛皮','127g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 127}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-127' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117','117克白牛皮','117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-147','147克白牛皮','147g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 147}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-147' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-CSHN-80','80克赤松黄牛','80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "赤松黄牛", "PAPER_WEIGHT": 80}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSHN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSHN-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-RDCN-100','100克瑞典赤牛','100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "瑞典赤牛", "PAPER_WEIGHT": 100}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-RDCN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-RDCN-100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-MD-120','120克梦迪','120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "梦迪", "PAPER_WEIGHT": 120}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-MD' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-MD-120' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-95','95克精牛','95g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 95}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-95' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-210','210克精牛','210g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 210}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-210' AND i.factory_id=1);

-- ---------- 4. 纸张 SKU（按门幅） ----------
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-80-1100','80克乌卡 1100MM','1100mm*80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-80' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 80, "PAPER_WIDTH": 1100}','库存 1卷 / 652kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-80-1100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-100-500','100克乌卡 500MM','500mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 500}','库存 1卷 / 431kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-100-500' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-100-670','100克乌卡 670MM','670mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 670}','库存 1卷 / 194kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-100-670' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-100-865','100克乌卡 865MM','865mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 865}','库存 1卷 / 66kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-100-865' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-100-900','100克乌卡 900MM','900mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 900}','库存 2卷 / 280kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-100-900' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-100-910','100克乌卡 910MM','910mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 910}','库存 1卷 / 380kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-100-910' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-100-925','100克乌卡 925MM','925mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 925}','库存 1卷 / 81kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-100-925' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-480','115克乌卡 480MM','480mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 480}','库存 2卷 / 948kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-480' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-670','115克乌卡 670MM','670mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 670}','库存 1卷 / 511kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-670' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-675','115克乌卡 675MM','675mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 675}','库存 8卷 / 5155kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-675' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-685','115克乌卡 685MM','685mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 685}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-685' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-725','115克乌卡 725MM','725mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 725}','库存 3卷 / 1690kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-725' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-790','115克乌卡 790MM','790mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 790}','库存 1卷 / 198kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-790' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-800','115克乌卡 800MM','800mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 800}','库存 1卷 / 580kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-800' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-885','115克乌卡 885MM','885mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 885}','库存 1卷 / 419kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-885' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-995','115克乌卡 995MM','995mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 995}','库存 1卷 / 688kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-995' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-1000','115克乌卡 1000MM','1000mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 1000}','库存 3卷 / 2607kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-1000' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-1025','115克乌卡 1025MM','1025mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 1025}','库存 3卷 / 2903kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-1025' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-1100','115克乌卡 1100MM','1100mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 1100}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-1100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-1030','115克乌卡 1030MM','1030mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 1030}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-1030' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-1050','115克乌卡 1050MM','1050mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 1050}','库存 3卷 / 3115kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-1050' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-1175','115克乌卡 1175MM','1175mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 1175}','库存 1卷 / 478kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-1175' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-1185','115克乌卡 1185MM','1185mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 1185}','库存 1卷 / 668kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-1185' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-1200','115克乌卡 1200MM','1200mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 1200}','库存 1卷 / 993kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-1200' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-1235','115克乌卡 1235MM','1235mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 1235}','库存 1卷 / 106kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-1235' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-2350','115克乌卡 2350MM','2350mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 2350}','库存 1卷 / 1963kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-2350' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-115-1027','115克乌卡 1027MM','1027mm*115g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 1027}','库存 18卷 / 16348kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-115-1027' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-120-1032','120克乌卡 1032MM','1032mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1032}','库存 15卷 / 15725kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-120-1032' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-120-2100','120克乌卡 2100MM','2100mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 2100}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-120-2100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-120-2200','120克乌卡 2200MM','2200mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 2200}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-120-2200' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-125-1165','125克乌卡 1165MM','1165mm*125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-125' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 125, "PAPER_WIDTH": 1165}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-125-1165' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-125-1185','125克乌卡 1185MM','1185mm*125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-125' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 125, "PAPER_WIDTH": 1185}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-125-1185' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-125-1200','125克乌卡 1200MM','1200mm*125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-125' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 125, "PAPER_WIDTH": 1200}','库存 1卷 / 555kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-125-1200' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-125-1300','125克乌卡 1300MM','1300mm*125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-125' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 125, "PAPER_WIDTH": 1300}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-125-1300' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-150-500','150克乌卡 500MM','500mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 500}','库存 1卷 / 28kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-150-500' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-150-485','150克乌卡 485MM','485mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 485}','库存 1卷 / 37kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-150-485' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-150-790','150克乌卡 790MM','790mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 790}','库存 1卷 / 41kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-150-790' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-150-980','150克乌卡 980MM','980mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 980}','库存 1卷 / 198kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-150-980' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-150-1042','150克乌卡 1042MM','1042mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 1042}','库存 1卷 / 105kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-150-1042' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-150-1210','150克乌卡 1210MM','1210mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 1210}','库存 1卷 / 118kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-150-1210' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-150-2100','150克乌卡 2100MM','2100mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 2100}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-150-2100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-WK-150-2400','150克乌卡 2400MM','2400mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 2400}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-WK-150-2400' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-90-1720','90克箱板纸 1720MM','1720mm*90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-90' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 90, "PAPER_WIDTH": 1720}','库存 1卷 / 1312kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-90-1720' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-90-500','90克箱板纸 500MM','500mm*90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-90' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 90, "PAPER_WIDTH": 500}','库存 2卷 / 122kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-90-500' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-90-490','90克箱板纸 490MM','490mm*90g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-90' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 90, "PAPER_WIDTH": 490}','库存 1卷 / 208kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-90-490' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-100-335','100克箱板纸 335MM','335mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 335}','库存 2卷 / 631kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-100-335' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-100-675','100克箱板纸 675MM','675mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 675}','库存 1卷 / 147kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-100-675' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-100-745','100克箱板纸 745MM','745mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 745}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-100-745' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-100-755','100克箱板纸 755MM','755mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 755}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-100-755' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-100-870','100克箱板纸 870MM','870mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 870}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-100-870' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-100-1110','100克箱板纸 1110MM','1110mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 1110}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-100-1110' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-100-1185','100克箱板纸 1185MM','1185mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 1185}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-100-1185' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-100-1345','100克箱板纸 1345MM','1345mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 1345}','库存 1卷 / 710kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-100-1345' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110-490','110克箱板纸 490MM','490mm*110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 490}','库存 1卷 / 248kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110-490' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110-670','110克箱板纸 670MM','670mm*110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 670}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110-670' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110-680','110克箱板纸 680MM','680mm*110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 680}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110-680' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110-685','110克箱板纸 685MM','685mm*110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 685}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110-685' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110-730','110克箱板纸 730MM','730mm*110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 730}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110-730' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110-800','110克箱板纸 800MM','800mm*110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 800}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110-800' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110-810','110克箱板纸 810MM','810mm*110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 810}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110-810' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110-820','110克箱板纸 820MM','820mm*110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 820}','库存 1卷 / 181kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110-820' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110-950','110克箱板纸 950MM','950mm*110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 950}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110-950' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110-1070','110克箱板纸 1070MM','1070mm*110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 1070}','库存 1卷 / 140kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110-1070' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110-1225','110克箱板纸 1225MM','1225mm*110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 1225}','库存 1卷 / 113kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110-1225' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110-1250','110克箱板纸 1250MM','1250mm*110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 1250}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110-1250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-110-1300','110克箱板纸 1300MM','1300mm*110g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 1300}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-110-1300' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-450','120克箱板纸 450MM','450mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 450}','库存 1卷 / 440kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-450' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-485','120克箱板纸 485MM','485mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 485}','库存 1卷 / 40kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-485' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-510','120克箱板纸 510MM','510mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 510}','库存 3卷 / 779kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-510' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-500','120克箱板纸 500MM','500mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 500}','库存 1卷 / 15kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-500' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-550','120克箱板纸 550MM','550mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 550}','库存 1卷 / 534kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-550' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-560','120克箱板纸 560MM','560mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 560}','库存 1卷 / 550kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-560' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-570','120克箱板纸 570MM','570mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 570}','库存 1卷 / 156kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-570' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-685','120克箱板纸 685MM','685mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 685}','库存 1卷 / 77kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-685' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-725','120克箱板纸 725MM','725mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 725}','库存 3卷 / 1655kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-725' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-730','120克箱板纸 730MM','730mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 730}','库存 1卷 / 576kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-730' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-775','120克箱板纸 775MM','775mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 775}','库存 1卷 / 184kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-775' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-785','120克箱板纸 785MM','785mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 785}','库存 1卷 / 43kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-785' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-790','120克箱板纸 790MM','790mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 790}','库存 1卷 / 80kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-790' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-800','120克箱板纸 800MM','800mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 800}','库存 1卷 / 125kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-800' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-850','120克箱板纸 850MM','850mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 850}','库存 1卷 / 223kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-850' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-900','120克箱板纸 900MM','900mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 900}','库存 2卷 / 904kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-900' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-935','120克箱板纸 935MM','935mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 935}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-935' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-915','120克箱板纸 915MM','915mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 915}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-915' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-1000','120克箱板纸 1000MM','1000mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1000}','库存 1卷 / 929kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-1000' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-1025','120克箱板纸 1025MM','1025mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1025}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-1025' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-1040','120克箱板纸 1040MM','1040mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1040}','库存 1卷 / 320kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-1040' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-1050','120克箱板纸 1050MM','1050mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1050}','库存 5卷 / 4583kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-1050' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-1100','120克箱板纸 1100MM','1100mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1100}','库存 1卷 / 180kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-1100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-1150','120克箱板纸 1150MM','1150mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1150}','库存 1卷 / 740kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-1150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-1250','120克箱板纸 1250MM','1250mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1250}','库存 1卷 / 116kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-1250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-1450','120克箱板纸 1450MM','1450mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1450}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-1450' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-1500','120克箱板纸 1500MM','1500mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1500}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-1500' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-1800','120克箱板纸 1800MM','1800mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1800}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-1800' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-1600','120克箱板纸 1600MM','1600mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1600}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-1600' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-120-2000','120克箱板纸 2000MM','2000mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 2000}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-120-2000' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-130-1000','130克箱板纸 1000MM','1000mm*130g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-130' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 130, "PAPER_WIDTH": 1000}','库存 1卷 / 919kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-130-1000' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-140-525','140克箱板纸 525MM','525mm*140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-140' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 140, "PAPER_WIDTH": 525}','库存 2卷 / 942kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-140-525' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-140-670','140克箱板纸 670MM','670mm*140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-140' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 140, "PAPER_WIDTH": 670}','库存 2卷 / 32kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-140-670' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-140-900','140克箱板纸 900MM','900mm*140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-140' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 140, "PAPER_WIDTH": 900}','库存 1卷 / 505kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-140-900' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-140-1200','140克箱板纸 1200MM','1200mm*140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-140' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 140, "PAPER_WIDTH": 1200}','库存 1卷 / 313kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-140-1200' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-150-800','150克箱板纸 800MM','800mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 800}','库存 1卷 / 40kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-150-800' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-150-820','150克箱板纸 820MM','820mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 820}','库存 1卷 / 154kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-150-820' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-150-950','150克箱板纸 950MM','950mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 950}','库存 2卷 / 1902kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-150-950' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-150-1045','150克箱板纸 1045MM','1045mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 1045}','库存 2卷 / 1129kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-150-1045' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-150-1150','150克箱板纸 1150MM','1150mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 1150}','库存 1卷 / 430kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-150-1150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-XBZ-150-1250','150克箱板纸 1250MM','1250mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 1250}','库存 2卷 / 1398kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-XBZ-150-1250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-125-530','125白挂面箱板纸 530MM','530mm*125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BGMZ-125' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 125, "PAPER_WIDTH": 530}','库存 1卷 / 167kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-125-530' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-125-540','125白挂面箱板纸 540MM','540mm*125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BGMZ-125' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 125, "PAPER_WIDTH": 540}','库存 1卷 / 578kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-125-540' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-125-675','125白挂面箱板纸 675MM','675mm*125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BGMZ-125' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 125, "PAPER_WIDTH": 675}','库存 1卷 / 179kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-125-675' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BGMZ-125-900','125白挂面箱板纸 900MM','900mm*125g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BGMZ-125' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 125, "PAPER_WIDTH": 900}','库存 1卷 / 475kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BGMZ-125-900' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-100-780','100克TC箱板纸 780MM','780mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 780}','库存 1卷 / 270kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-100-780' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-100-830','100克TC箱板纸 830MM','830mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 830}','库存 1卷 / 563kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-100-830' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-100-900','100克TC箱板纸 900MM','900mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 900}','库存 1卷 / 82kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-100-900' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-100-1020','100克TC箱板纸 1020MM','1020mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 1020}','库存 1卷 / 225kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-100-1020' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-100-1250','100克TC箱板纸 1250MM','1250mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 1250}','库存 1卷 / 40kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-100-1250' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-525','120克TC箱板纸 525MM','525mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 525}','库存 20卷 / 829kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-525' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-667','120克TC箱板纸 667MM','667mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 667}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-667' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-675','120克TC箱板纸 675MM','675mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 675}','库存 9卷 / 4928kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-675' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-670','120克TC箱板纸 670MM','670mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 670}','库存 3卷 / 1280kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-670' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-800','120克TC箱板纸 800MM','800mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 800}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-800' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-810','120克TC箱板纸 810MM','810mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 810}','库存 2卷 / 1047kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-810' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-900','120克TC箱板纸 900MM','900mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 900}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-900' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-905','120克TC箱板纸 905MM','905mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 905}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-905' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-950','120克TC箱板纸 950MM','950mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 950}','库存 1卷 / 376kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-950' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-960','120克TC箱板纸 960MM','960mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 960}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-960' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-1050','120克TC箱板纸 1050MM','1050mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1050}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-1050' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-1350','120克TC箱板纸 1350MM','1350mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1350}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-1350' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-1800','120克TC箱板纸 1800MM','1800mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1800}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-1800' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-1850','120克TC箱板纸 1850MM','1850mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 1850}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-1850' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-120-2000','120克TC箱板纸 2000MM','2000mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 2000}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-120-2000' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-TCXBZ-130-860','130克TC箱板纸 860MM','860mm*130g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-130' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 130, "PAPER_WIDTH": 860}','库存 1卷 / 44kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-TCXBZ-130-860' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-80-1092','80克白牛皮 1092MM','1092mm*80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-80' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 80, "PAPER_WIDTH": 1092}','库存 1卷 / 520kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-80-1092' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97-595','97克白牛皮 595MM','595mm*97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 595}','库存 1卷 / 78kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97-595' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-120-850','120克白牛皮 850MM','850mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 850}','库存 2卷 / 127kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-120-850' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-127-1005','127克白牛皮 1005MM','1005mm*127g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-127' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 127, "PAPER_WIDTH": 1005}','库存 1卷 / 286kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-127-1005' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-980','117克白牛皮 980MM','980mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 980}','库存 2卷 / 1001kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-980' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-1194','117克白牛皮 1194MM','1194mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 1194}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-1194' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-1000','117克白牛皮 1000MM','1000mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 1000}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-1000' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-150-597','150克白牛皮 597MM','597mm*150g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 597}','库存 1卷 / 134kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-150-597' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97-485','97克金东白牛皮 485MM','485mm*97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 485, "PAPER_SOURCE": "金东"}','库存 1卷 / 456kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97-485' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97-670','97克金东白牛皮 670MM','670mm*97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 670, "PAPER_SOURCE": "金东"}','库存 1卷 / 316kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97-670' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97-820','97克金东白牛皮 820MM','820mm*97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 820, "PAPER_SOURCE": "金东"}','库存 2卷 / 458kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97-820' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97-787','97克金东白牛皮 787MM','787mm*97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 787, "PAPER_SOURCE": "金东"}','库存 1卷 / 358kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97-787' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97-910','97克金东白牛皮 910MM','910mm*97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 910, "PAPER_SOURCE": "金东"}','库存 1卷 / 188kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97-910' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97-1000','97克金东白牛皮 1000MM','1000mm*97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 1000, "PAPER_SOURCE": "金东"}','库存 2卷 / 469kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97-1000' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97-1013','97克金东白牛皮 1013MM','1013mm*97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 1013, "PAPER_SOURCE": "金东"}','库存 1卷 / 172kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97-1013' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97-1092','97克金东白牛皮 1092MM','1092mm*97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 1092, "PAPER_SOURCE": "金东"}','库存 1卷 / 462kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97-1092' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97-1190','97克金东白牛皮 1190MM','1190mm*97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 1190, "PAPER_SOURCE": "金东"}','库存 1卷 / 640kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97-1190' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97-1195','97克金东白牛皮 1195MM','1195mm*97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 1195, "PAPER_SOURCE": "金东"}','库存 1卷 / 213kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97-1195' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97-1294','97克金东白牛皮 1294MM','1294mm*97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 1294, "PAPER_SOURCE": "金东"}','库存 1卷 / 179kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97-1294' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-485','117克金东白牛皮 485MM','485mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 485, "PAPER_SOURCE": "金东"}','库存 1卷 / 51kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-485' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-630','117克金东白牛皮 630MM','630mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 630, "PAPER_SOURCE": "金东"}','库存 1卷 / 128kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-630' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-877','117克金东白牛皮 877MM','877mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 877, "PAPER_SOURCE": "金东"}','库存 1卷 / 120kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-877' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-889','117克金东白牛皮 889MM','889mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 889, "PAPER_SOURCE": "金东"}','库存 1卷 / 685kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-889' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-1002','117克金东白牛皮 1002MM','1002mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 1002, "PAPER_SOURCE": "金东"}','库存 1卷 / 189kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-1002' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-1030','117克金东白牛皮 1030MM','1030mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 1030, "PAPER_SOURCE": "金东"}','库存 1卷 / 81kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-1030' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-1047','117克金东白牛皮 1047MM','1047mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 1047, "PAPER_SOURCE": "金东"}','库存 1卷 / 204kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-1047' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-1050','117克金东白牛皮 1050MM','1050mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 1050, "PAPER_SOURCE": "金东"}','库存 1卷 / 155kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-1050' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-1240','117克金东白牛皮 1240MM','1240mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 1240, "PAPER_SOURCE": "金东"}','库存 1卷 / 312kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-1240' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-127-1025','127克金东白牛皮 1025MM','1025mm*127g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-127' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 127, "PAPER_WIDTH": 1025, "PAPER_SOURCE": "金东"}','库存 1卷 / 252kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-127-1025' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-147-889','147克金东白牛皮 889MM','889mm*147g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-147' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 147, "PAPER_WIDTH": 889, "PAPER_SOURCE": "金东"}','库存 2卷 / 897kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-147-889' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-147-1105','147克金东白牛皮 1105MM','1105mm*147g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-147' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 147, "PAPER_WIDTH": 1105, "PAPER_SOURCE": "金东"}','库存 1卷 / 334kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-147-1105' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-97-685','97克云轩白牛皮 685MM','685mm*97g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 685, "PAPER_SOURCE": "云轩"}','库存 1卷 / 195kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-97-685' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-490','117克云轩白牛皮 490MM','490mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 490, "PAPER_SOURCE": "云轩"}','库存 1卷 / 131kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-490' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-580','117克云轩白牛皮 580MM','580mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 580, "PAPER_SOURCE": "云轩"}','库存 1卷 / 131kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-580' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-680','117克云轩白牛皮 680MM','680mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 680, "PAPER_SOURCE": "云轩"}','库存 1卷 / 72kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-680' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-510','117克君茹白牛皮 510MM','510mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 510, "PAPER_SOURCE": "君茹"}','库存 1卷 / 475.6kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-510' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-725','117克君茹白牛皮 725MM','725mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 725, "PAPER_SOURCE": "君茹"}','库存 1卷 / 326kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-725' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-1255','117克君茹白牛皮 1255MM','1255mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 1255, "PAPER_SOURCE": "君茹"}','库存 1卷 / 252kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-1255' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-787','117克晨鸣白牛皮 787MM','787mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 787, "PAPER_SOURCE": "晨鸣"}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-787' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-481','117克仙鹤白牛皮 481MM','481mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 481, "PAPER_SOURCE": "仙鹤"}','库存 1卷 / 178kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-481' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-BNP-117-665','117克仙鹤白牛皮 665MM','665mm*117g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 665, "PAPER_SOURCE": "仙鹤"}','库存 1卷 / 503kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-BNP-117-665' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-CSHN-80-889','80克赤松黄牛 889MM','889mm*80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-CSHN-80' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "赤松黄牛", "PAPER_WEIGHT": 80, "PAPER_WIDTH": 889}','库存 1卷 / 259kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-CSHN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-CSHN-80-889' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-RDCN-100-830','100克瑞典赤牛 830MM','830mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-RDCN-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "瑞典赤牛", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 830}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-RDCN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-RDCN-100-830' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-RDCN-100-960','100克瑞典赤牛 960MM','960mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-RDCN-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "瑞典赤牛", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 960}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-RDCN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-RDCN-100-960' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-RDCN-100-1100','100克瑞典赤牛 1100MM','1100mm*100g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-RDCN-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "瑞典赤牛", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 1100}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-RDCN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-RDCN-100-1100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-MD-120-900','120克梦迪 900MM','900mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-MD-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "梦迪", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 900}','库存 1卷 / 689kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-MD' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-MD-120-900' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-MD-120-720','120克梦迪 720MM','720mm*120g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-MD-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "梦迪", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 720}','库存 1卷 / 651kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-MD' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-MD-120-720' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-80-850','80克精牛 850MM','850mm*80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-JN-80' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 80, "PAPER_WIDTH": 850}','库存 0卷 / 0kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-80-850' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-80-935','80克精牛 935MM','935mm*80g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-JN-80' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 80, "PAPER_WIDTH": 935}','库存 3卷 / 516kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-80-935' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-95-889','95克精牛 889MM','889mm*95g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-JN-95' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 95, "PAPER_WIDTH": 889}','库存 1卷 / 29kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-95-889' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-140-889','140克精牛 889MM','889mm*140g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-JN-140' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 140, "PAPER_WIDTH": 889}','库存 1卷 / 556kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-140-889' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-PAPER-JN-210-1160','210克GP 1160MM','1160mm*210g',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-JN-210' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "精牛", "PAPER_WEIGHT": 210, "PAPER_WIDTH": 1160}','库存 1卷 / 630kg',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-JN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-PAPER-JN-210-1160' AND i.factory_id=1);

-- ---------- 5. 纸边 SKU ----------
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-WK-115-45','115克乌卡 纸边 45MM','45mm*115g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 45}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-WK-115-45' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-WK-115-90','115克乌卡 纸边 90MM','90mm*115g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-115' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 115, "PAPER_WIDTH": 90}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-WK-115-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-WK-120-90','120乌卡 纸边 90MM','90mm*120g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 90}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-WK-120-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-WK-120-45','120乌卡 纸边 45MM','45mm*120g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 45}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-WK-120-45' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-WK-125-90','125克乌卡 纸边 90MM','90mm*125g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-125' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 125, "PAPER_WIDTH": 90}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-WK-125-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-WK-150-90','150克乌卡 纸边 90MM','90mm*150g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-WK-150' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "乌卡", "PAPER_WEIGHT": 150, "PAPER_WIDTH": 90}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-WK' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-WK-150-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-XBZ-90-80','90克箱板纸 纸边 80MM','80mm*90g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-90' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 90, "PAPER_WIDTH": 80}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-XBZ-90-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-XBZ-100-80','100克箱板纸 纸边 80MM','80mm*100g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 80}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-XBZ-100-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-XBZ-100-90','100克箱板纸 纸边 90MM','90mm*100g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 90}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-XBZ-100-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-XBZ-110-90','110克箱板纸 纸边 90MM','90mm*110g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 90}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-XBZ-110-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-XBZ-120-80','120克箱板纸 纸边 80MM','80mm*120g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 80}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-XBZ-120-80' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-XBZ-120-90','120克箱板纸 纸边 90MM','90mm*120g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-XBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 90}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-XBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-XBZ-120-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-TCXBZ-120-90','TC120克箱板纸 纸边 90MM','90mm*120g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-TCXBZ-120' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "TC箱板纸", "PAPER_WEIGHT": 120, "PAPER_WIDTH": 90}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-TCXBZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-TCXBZ-120-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-BGMZ-125-90','125白挂面箱板纸 纸边 90MM','90mm*125g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BGMZ-125' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白挂面纸", "PAPER_WEIGHT": 125, "PAPER_WIDTH": 90}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BGMZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-BGMZ-125-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-BNP-97-90','97克白牛皮 纸边 90MM','90mm*97g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-97' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 97, "PAPER_WIDTH": 90}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-BNP-97-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-BNP-100-86','100克白牛皮 纸边 86MM','86mm*100g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 86}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-BNP-100-86' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-BNP-110-90','110克白牛皮 纸边 90MM','90mm*110g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-110' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 110, "PAPER_WIDTH": 90}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-BNP-110-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-BNP-117-45','117克白牛皮 纸边 45MM','45mm*117g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-117' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 117, "PAPER_WIDTH": 45}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-BNP-117-45' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-BNP-127-90','127克金东白牛皮 纸边 90MM','90mm*127g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-BNP-127' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "白牛皮", "PAPER_WEIGHT": 127, "PAPER_WIDTH": 90, "PAPER_SOURCE": "金东"}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-BNP' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-BNP-127-90' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'RAW-EDGE-RDCN-100-90','100克瑞典赤牛 纸边 90MM','90mm*100g 纸边',@u_kg,'千克',t.item_type_id,t.item_type_code,t.item_type_name,
       (SELECT i2.item_id FROM (SELECT item_id FROM qxx_md_item WHERE item_code='RAW-PAPER-RDCN-100' AND factory_id=1) i2),
       '1','1','{"PAPER_TYPE": "瑞典赤牛", "PAPER_WEIGHT": 100, "PAPER_WIDTH": 90}','分切余料',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-PAPER-RDCN' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='RAW-EDGE-RDCN-100-90' AND i.factory_id=1);

-- ---------- 6. 辅料纸绳 ----------
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'AUX-ROPE-BNPY','白牛皮色圆纸绳','标准',@u_pair,'对',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-ROPE-YZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='AUX-ROPE-BNPY' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'AUX-ROPE-HNPY','黄牛皮色圆纸绳','标准',@u_pair,'对',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-ROPE-YZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='AUX-ROPE-HNPY' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'AUX-ROPE-HSY','黑色圆纸绳','标准',@u_pair,'对',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-ROPE-YZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='AUX-ROPE-HSY' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'AUX-ROPE-CSY','彩色圆纸绳','标准',@u_pair,'对',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-ROPE-YZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='AUX-ROPE-CSY' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'AUX-ROPE-HNPB','黄牛皮色扁纸绳','标准',@u_pair,'对',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-ROPE-BZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='AUX-ROPE-HNPB' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'AUX-ROPE-BNPB','白牛皮色扁纸绳','标准',@u_pair,'对',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-ROPE-BZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='AUX-ROPE-BNPB' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'AUX-ROPE-HSB','黑色扁纸绳','标准',@u_pair,'对',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-ROPE-BZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='AUX-ROPE-HSB' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,create_by,create_time)
SELECT 1,'AUX-ROPE-CSB','彩色扁纸绳','标准',@u_pair,'对',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='RAW-ROPE-BZ' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='AUX-ROPE-CSB' AND i.factory_id=1);

-- ---------- 7. 成品物料（扁平，parent_id=0） ----------
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0001','小小号本色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0001' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0002','小号黄牛皮-本色','15*8*21',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0002' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0003','小号黄牛皮-黑色','15*8*21',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0003' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0004','小号黄牛皮-深蓝','15*8*21',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0004' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0005','小号黄牛皮-深绿','15*8*21',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0005' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0006','小号黄牛皮-深红','15*8*21',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0006' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0007','小号白牛皮-白色','15*8*21',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0007' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0008','小号白牛皮-浅蓝','15*8*21',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0008' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0009','小号白牛皮-浅绿','15*8*21',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0009' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0010','小号白牛皮-浅紫','15*8*21',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0010' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0011','小号白牛皮-玫红','15*8*21',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0011' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0012','小号白牛皮-橘色','15*8*21',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0012' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0013','小号白牛皮-浅黄','15*8*21',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0013' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0014','小号白牛皮-宝蓝','15*8*21',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0014' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0015','中号黄牛皮-本色','21*11*27',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0015' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0016','中号黄牛皮-黑色','21*11*27',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0016' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0017','中号黄牛皮-深绿','21*11*27',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0017' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0018','中号黄牛皮-深红','21*11*27',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0018' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0019','中号白牛皮-白色','21*11*27',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0019' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0020','中号白牛皮-浅绿','21*11*27',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0020' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0021','中号白牛皮-玫红','21*11*27',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0021' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0022','中号白牛皮-浅蓝','21*11*27',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0022' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0023','中号白牛皮-大红','21*11*27',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0023' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0024','中号白牛皮-橘色','21*11*27',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0024' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0025','大号竖版黄牛皮-本色','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0025' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0026','大号竖版黄牛皮-黑色 黑绳','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0026' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0027','大号竖版黄牛皮-黑色 黄绳','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0027' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0028','大号竖版黄牛皮-深蓝','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0028' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0029','大号竖版黄牛皮-深红','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0029' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0030','大号竖版黄牛皮-深紫','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0030' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0031','大号竖版黄牛皮-咖啡','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0031' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0032','大号竖版白牛皮-白色','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0032' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0033','大号竖版白牛皮-橘色','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0033' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0034','大号竖版白牛皮-浅紫','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0034' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0035','大号竖版白牛皮-粉色','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0035' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0036','大号竖版白牛皮-浅绿','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0036' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0037','大号竖版白牛皮-果绿','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0037' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0038','大号竖版白牛皮-玫红','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0038' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0039','大号竖版白牛皮-大红','25.4*12.7*33',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0039' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0040','加大号竖版黄牛皮-本色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0040' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0041','大号横版黄牛皮-本色','32*11*25',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0041' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0042','大号横版黄牛皮-黑色','32*11*25',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0042' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0043','大号横版黄牛皮-深绿','32*11*25',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0043' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0044','大号横版黄牛皮-深蓝','32*11*25',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0044' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0045','大号横版白牛皮-白色','32*11*25',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0045' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0046','大号横版白牛皮-浅绿','32*11*25',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0046' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0047','大号横版白牛皮-浅蓝','32*11*25',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0047' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0048','大号横版白牛皮-玫红','32*11*25',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0048' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0049','加大号黄牛皮-深蓝','42*13*31',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0049' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0050','加大号黄牛皮-深绿','42*13*31',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0050' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0051','特大号白牛皮-白色','44*14.5*40',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0051' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0052','特大号黄牛皮-黑色','44*14.5*40',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0052' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0053','特大号黄牛皮-深蓝','44*14.5*40',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0053' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0054','特大号黄牛皮-深红','44*14.5*40',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0054' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0055','特大号黄牛皮-深绿','44*14.5*40',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0055' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0056','4号牛皮纸打包袋','21*14*27',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0056' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0057','5号牛皮色打包袋','21*14*24',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0057' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0058','6号牛皮色打包袋','22.5*12*28',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0058' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0059','7号牛皮色打包袋','23.5*18*29',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0059' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0060','10号牛皮纸打包袋','28*15*28',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0060' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0061','10号白色打包袋','28*15*28',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0061' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0062','12号牛皮纸打包袋','28*22*28',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0062' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0063','14号牛皮色打包袋','33*18*42',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0063' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0064','20号牛皮色打包袋','23*14*25',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0064' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0065','35号牛皮色打包袋','烧烤袋',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0065' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0066','单杯袋黄牛皮本色 （31号黄牛皮本色）','12*10*22',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0066' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0067','单杯袋白牛皮白色 （31号白牛皮白色）','12*10*22',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0067' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0068','双杯托','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0068' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0069','4号岛国白色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0069' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-SPOT-0070','2号岛国白色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','现货',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-SPOT-0070' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0001','中号黄牛皮-深蓝','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0001' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0002','大竖黄牛皮-深绿','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0002' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0003','大竖黄牛皮-深蓝','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0003' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0004','大竖白牛皮-浅紫','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0004' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0005','加大号白牛皮-白色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0005' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0006','中号白牛皮-浅紫色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0006' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0007','中号白牛皮-黄色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0007' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0008','加大号竖版黄牛皮-深蓝色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0008' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0009','加大号竖版黄牛皮-深红色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0009' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0010','加大号竖版黄牛皮-深绿色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0010' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0011','大号竖版黄牛皮-深蓝色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0011' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0012','大号竖版黄牛皮-深绿色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0012' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0013','加大号黄牛皮-深红','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0013' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0014','加大号黄牛皮-黑色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0014' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0015','大号横板黄牛皮-深红','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0015' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0016','大号竖版黄牛皮-深绿','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0016' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0017','中号白牛皮-浅紫','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0017' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0018','大号竖版白牛皮-浅蓝色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0018' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0019','大号竖版白牛皮-浅蓝','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0019' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0020','6号岛国-咖啡色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0020' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-WAI-0021','6号岛国-本色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','外采',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-WAI-0021' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0001','JASON纸袋-大号黑色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0001' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0002','JASON纸袋-中号黑色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0002' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0003','JASON纸袋-小号黑色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0003' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0004','心心纸袋-25款小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0004' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0005','心心纸袋-25款大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0005' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0006','心心纸袋-26款大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0006' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0007','心心纸袋-26款小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0007' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0008','BSBX0753A','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0008' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0009','AE大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0009' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0010','CO特小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0010' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0011','CO中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0011' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0012','CO小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0012' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0013','奔趣本色纸袋-特小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0013' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0014','奔趣绿色纸袋-中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0014' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0015','奔趣本色2024纸袋-中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0015' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0016','奔趣鞋袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0016' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0017','奔趣绿色纸袋特-小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0017' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0018','奔趣本色2026纸袋-小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0018' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0019','奔趣本色纸袋-小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0019' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0020','奔趣2026纸袋-大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0020' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0021','奔趣2026纸袋-小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0021' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0022','奔趣2026纸袋-鞋袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0022' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0023','奔趣2027纸袋-鞋袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0023' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0024','奔趣2026纸袋-中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0024' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0025','奔趣2026纸袋-特小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0025' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0026','奔趣2026尖底袋-小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0026' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0027','奔趣2026尖底袋-中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0027' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0028','奔趣2026尖底袋-大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0028' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0029','奔趣2026尖底袋-加大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0029' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0030','母爱纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0030' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0031','慧曼小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0031' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0032','慧曼中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0032' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0033','慧曼大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0033' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0034','哈利波特芝加哥中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0034' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0035','哈利波特芝加哥小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0035' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0036','哈利波特纽约大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0036' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0037','哈利波特纽约中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0037' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0038','哈利波特纽约小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0038' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0039','255纸质快递袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0039' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0040','美国快递袋325大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0040' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0041','325纸质快递袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0041' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0042','P家纸袋-中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0042' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0043','P家纸袋-小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0043' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0044','心心纸袋大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0044' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0045','心心纸袋小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0045' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0046','12号打包袋黄牛皮','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0046' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0047','小B纸袋中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0047' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0048','小B纸袋大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0048' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0049','小B纸袋鞋袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0049' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0050','小B尖底袋-小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0050' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0051','小B尖底袋-中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0051' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0052','小B尖底袋-大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0052' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0053','小B尖底袋-加大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0053' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0054','莫伊达纸袋-小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0054' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0055','铜版纸平张-复活节兔子+花朵+蛋+小鸡','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0055' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0056','39号黄牛皮打包袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0056' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0057','外贸41号打包袋白色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0057' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0058','外贸41号打包袋本色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0058' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0059','外贸7号白色打包袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0059' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0060','12号打包袋白牛皮白色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0060' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0061','定制19号打包袋-俄卡版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0061' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0062','2号黄牛皮打包袋本色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0062' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0063','火苗纸袋-俄卡-大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0063' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0064','汉堡黄色纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0064' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0065','定制4号打包袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0065' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0066','定制10号打包袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0066' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0067','10号打包袋白牛皮白色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0067' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0068','330*254*127白牛皮纸款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0068' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0069','330*254*127黄牛皮纸款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0069' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0070','210*150*80黄牛皮纸款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0070' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0071','210*150*80白牛皮纸款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0071' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0072','暗红波浪纸袋320','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0072' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0073','猫猫头305纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0073' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0074','汉堡黄色纸袋26版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0074' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0075','秦伟绿色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0075' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0076','芒果黄色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0076' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0077','RWA0414B 三角白牛皮小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0077' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0078','RWA0409B','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0078' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0079','红日纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0079' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0080','健康纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0080' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0081','王冠纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0081' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0082','12.19.20','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0082' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0083','12.26.08','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0083' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0084','360*180*320本色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0084' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0085','370*240*320本色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0085' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0086','355*220*370本色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0086' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0087','橙色苹果','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0087' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0088','绿枝纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0088' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0089','底部条码纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0089' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0090','SOS16号方底袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0090' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0091','2A1371319箱板纸款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0091' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0092','2A1191219箱板纸款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0092' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0093','2A0519箱板纸款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0093' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0094','2A0596白牛皮款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0094' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0095','现货小号玫红色打包袋-腰封包装','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0095' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0096','现货小号黑色打包袋-腰封打包袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0096' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0097','现货小号黑色打包袋-腰封打包袋2A0526','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0097' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0098','现货大号黑色打包袋-腰封打包袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0098' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0099','现货大号浅绿打包袋-腰封打包袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0099' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0100','现货小号浅绿打包袋-腰封打包袋2A0506','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0100' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0101','现货小号浅黄打包袋-腰封打包袋2A0505','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0101' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0102','2A0096白牛皮款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0102' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0103','2A0719','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0103' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0104','2A0796白牛皮款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0104' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0105','2A0896白牛皮款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0105' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0106','现货中号浅黄色打包袋-腰封包装','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0106' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0107','现货中号黑色打包袋-腰封包装2A0826','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0107' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0108','现货大号竖版深红色打包袋-腰封包装2A1013','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0108' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0109','2A1019箱板纸款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0109' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0110','2A1296白牛皮纸款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0110' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0111','2A1319','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0111' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0112','2A1396白牛皮款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0112' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0113','2A1419箱板纸款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0113' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0114','2A1496白牛皮款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0114' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0115','定制16英寸浅绿色纸袋-腰封包装','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0115' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0116','定制16英寸深红色纸袋-腰封包装','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0116' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0117','2A1619箱板纸款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0117' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0118','定制16英寸黑色纸袋-腰封包装','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0118' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0119','2AF121219箱板纸款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0119' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0120','现货中号橙色打包袋-腰封包装','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0120' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0121','底部横条纹纸袋小号-白色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0121' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0122','底部横条纹纸袋小号-灰色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0122' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0123','粉色方格纸袋小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0123' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0124','蓝色方格小号纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0124' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0125','优美世界纸袋小号26版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0125' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0126','好食纸袋-5寸','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0126' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0127','双B纸袋-小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0127' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0128','PICO纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0128' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0129','扩门16寸','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0129' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0130','好食8寸','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0130' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0131','圆圈朋友纸袋小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0131' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0132','CF黑色爱心','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0132' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0133','CF黑色-小号2022版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0133' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0134','CF白色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0134' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0135','CF玫红','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0135' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0136','CF本色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0136' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0137','CF白色爱心','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0137' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0138','CF假金色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0138' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0139','CF假金-小号2023版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0139' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0140','CF爱心纸袋白-小号2023版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0140' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0141','CF黑色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0141' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0142','CF灰色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0142' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0143','CF红色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0143' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0144','CF大红','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0144' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0145','CF黑色-中号2021版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0145' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0146','CF黑色-大号2021版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0146' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0147','CF玫红色大号-2021版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0147' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0148','CF大红色-大号2024版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0148' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0149','CF玫红色-中号2022版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0149' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0150','CF大红色-小号2021版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0150' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0151','CF玫红色-小号2021版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0151' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0152','巴福小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0152' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0153','巴福中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0153' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0154','巴福大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0154' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0155','花束纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0155' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0156','迈克尔斯纸袋-5寸','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0156' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0157','椭圆黑标纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0157' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0158','慕然纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0158' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0159','酷派纸袋中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0159' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0160','酷派纸袋小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0160' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0161','八角星星纸袋加大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0161' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0162','青蛙纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0162' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0163','八角星星纸袋26年版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0163' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0164','小号方格黄色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0164' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0165','小号方格蓝色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0165' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0166','小号方格粉色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0166' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0167','中号方格紫色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0167' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0168','中号方格蓝色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0168' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0169','中号方格黄色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0169' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0170','中号方格粉色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0170' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0171','贝克布勒纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0171' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0172','Jump纸袋25年版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0172' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0173','若可可纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0173' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0174','迈克尔斯纸袋10寸','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0174' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0175','迈克尔斯纸袋16寸','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0175' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0176','黑眼框纸袋6寸','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0176' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0177','黑色旗帜纸袋中号26新版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0177' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0178','爱丑纸袋大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0178' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0179','钻石纸袋小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0179' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0180','钻石纸袋特小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0180' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0181','椭圆纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0181' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0182','黑色旗帜纸袋2026小号新版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0182' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0183','花J餐具盒','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0183' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0184','悉尼咖啡吧纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0184' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0185','吐司麦克封套','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0185' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0186','圆圈朋友纸袋中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0186' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0187','万斯中号纸袋25年版','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0187' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0188','蓝色十字纸袋法文版大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0188' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0189','蓝色十字纸袋法文版小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0189' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0190','糖果店纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0190' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0191','蓝色烹饪纸袋小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0191' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0192','蓝色烹饪纸袋中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0192' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0193','蓝色烹饪纸袋大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0193' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0194','麦克纸袋小号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0194' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0195','麦克纸袋大号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0195' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0196','蓝框眼镜纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0196' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0197','餐具套-农民之家款','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0197' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0198','JUCE中号','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0198' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0199','上海松江酒店','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0199' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0200','上海野生动物园纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0200' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0201','别人家单杯袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0201' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0202','3210606礼品袋 (红色)','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0202' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0203','3210605礼品袋 (红色)','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0203' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0204','3210607礼品袋 (红色)','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0204' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0205','3210604礼品袋 (红色)','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0205' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0206','3210619礼品袋 (金色)','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0206' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0207','3210625礼品袋 (银色)','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0207' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0208','3210593礼品袋 (本色)','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0208' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0209','3210630礼品袋 (银色)','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0209' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0210','3210608礼品袋 (红色)','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0210' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0211','BLAVKCA5E单杯','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0211' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0212','空白袋-乌卡','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0212' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0213','黄牛皮纸袋黑色加工—陈孟高','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0213' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0214','黄牛皮纸袋加工—陈孟高','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0214' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0215','白牛皮纸袋加工—陈孟高','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0215' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0216','小号黄牛皮边框-黑色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0216' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0217','小号黄牛皮边框-深绿','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0217' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0218','小号黄牛皮边框-深红','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0218' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0219','中号黄牛皮边框-深绿','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0219' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0220','恰巴塔面包纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0220' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0221','GREEN纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0221' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0222','小号大红色纸袋 外加工','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0222' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0223','大号红色纸袋 外加工','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0223' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0224','特种纸食品袋加工','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0224' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0225','here纸袋','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0225' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0226','定制加大号横版黄牛皮-绿色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0226' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0227','定制加大号横版黄牛皮-红色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0227' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0228','定制加大号横版黄牛皮-黄色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0228' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0229','定制加大号横版黄牛皮-黑色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0229' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0230','定制加大号横版黄牛皮-深蓝','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0230' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0231','定制加大号横版黄牛皮-紫色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0231' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0232','定制加大号横版黄牛皮=黄绿色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0232' AND i.factory_id=1);
INSERT INTO qxx_md_item (factory_id,item_code,item_name,specification,unit_of_measure,unit_name,item_type_id,item_type_code,item_type_name,parent_id,enable_flag,batch_flag,ext_attrs,remark,create_by,create_time)
SELECT 1,'FIN-ORD-0233','定制加大号横版黄牛皮-粉色','',@u_pcs,'个',t.item_type_id,t.item_type_code,t.item_type_name,0,'1','1','{}','订单',@op,@now
  FROM qxx_md_item_type t WHERE t.item_type_code='FINISHED-BAG' AND t.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_md_item i WHERE i.item_code='FIN-ORD-0233' AND i.factory_id=1);

-- ---------- 8. 原有工艺路线 / 工序 逻辑删除（保留本次新建的） ----------
UPDATE qxx_pro_route SET del_flag='2', enable_flag='0', update_by=@op, update_time=@now
 WHERE factory_id=1 AND del_flag='0' AND route_code<>'ROUTE-KRAFT-BAG';
UPDATE qxx_pro_process SET del_flag='2', enable_flag='0', update_by=@op, update_time=@now
 WHERE factory_id=1 AND del_flag='0' AND process_code NOT LIKE 'PRC-BAG-%';
-- 路线-工序关联表无启用标志，随路线 del_flag 一起失效

-- ---------- 9. 卷筒牛皮纸袋生产工艺路线 + 8 道工序 ----------
INSERT INTO qxx_pro_process (factory_id,process_code,process_name,attention,enable_flag,create_by,create_time)
SELECT 1,'PRC-BAG-YL','原纸','','1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_pro_process WHERE process_code='PRC-BAG-YL' AND factory_id=1);
INSERT INTO qxx_pro_process (factory_id,process_code,process_name,attention,enable_flag,create_by,create_time)
SELECT 1,'PRC-BAG-FL','辅料','','1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_pro_process WHERE process_code='PRC-BAG-FL' AND factory_id=1);
INSERT INTO qxx_pro_process (factory_id,process_code,process_name,attention,enable_flag,create_by,create_time)
SELECT 1,'PRC-BAG-YS','印刷','','1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_pro_process WHERE process_code='PRC-BAG-YS' AND factory_id=1);
INSERT INTO qxx_pro_process (factory_id,process_code,process_name,attention,enable_flag,create_by,create_time)
SELECT 1,'PRC-BAG-ZD','制袋','','1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_pro_process WHERE process_code='PRC-BAG-ZD' AND factory_id=1);
INSERT INTO qxx_pro_process (factory_id,process_code,process_name,attention,enable_flag,create_by,create_time)
SELECT 1,'PRC-BAG-TS','贴绳','','1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_pro_process WHERE process_code='PRC-BAG-TS' AND factory_id=1);
INSERT INTO qxx_pro_process (factory_id,process_code,process_name,attention,enable_flag,create_by,create_time)
SELECT 1,'PRC-BAG-BZ','包装','','1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_pro_process WHERE process_code='PRC-BAG-BZ' AND factory_id=1);
INSERT INTO qxx_pro_process (factory_id,process_code,process_name,attention,enable_flag,create_by,create_time)
SELECT 1,'PRC-BAG-CPRK','产品入库','','1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_pro_process WHERE process_code='PRC-BAG-CPRK' AND factory_id=1);
INSERT INTO qxx_pro_process (factory_id,process_code,process_name,attention,enable_flag,create_by,create_time)
SELECT 1,'PRC-BAG-XSCK','销售出库','','1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_pro_process WHERE process_code='PRC-BAG-XSCK' AND factory_id=1);

INSERT INTO qxx_pro_route (factory_id,route_code,route_name,route_desc,enable_flag,create_by,create_time)
SELECT 1,'ROUTE-KRAFT-BAG','卷筒牛皮纸袋生产工艺路线','原纸-辅料-印刷-制袋-贴绳-包装-产品入库-销售出库','1',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM qxx_pro_route WHERE route_code='ROUTE-KRAFT-BAG' AND factory_id=1);
SET @rt_bag = (SELECT route_id FROM qxx_pro_route WHERE route_code='ROUTE-KRAFT-BAG' AND factory_id=1 LIMIT 1);

INSERT INTO qxx_pro_route_process (factory_id,route_id,process_id,process_code,process_name,order_num,next_process_id,next_process_code,next_process_name,link_type,key_flag,is_check,is_outsource,color_code)
SELECT 1,@rt_bag,p.process_id,p.process_code,p.process_name,10,NULL,NULL,NULL,'SS','N','N','0','#00AEF3'
  FROM qxx_pro_process p WHERE p.process_code='PRC-BAG-YL' AND p.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_pro_route_process rp WHERE rp.route_id=@rt_bag AND rp.process_code='PRC-BAG-YL' AND rp.factory_id=1);
INSERT INTO qxx_pro_route_process (factory_id,route_id,process_id,process_code,process_name,order_num,next_process_id,next_process_code,next_process_name,link_type,key_flag,is_check,is_outsource,color_code)
SELECT 1,@rt_bag,p.process_id,p.process_code,p.process_name,20,NULL,NULL,NULL,'SS','N','N','0','#00AEF3'
  FROM qxx_pro_process p WHERE p.process_code='PRC-BAG-FL' AND p.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_pro_route_process rp WHERE rp.route_id=@rt_bag AND rp.process_code='PRC-BAG-FL' AND rp.factory_id=1);
INSERT INTO qxx_pro_route_process (factory_id,route_id,process_id,process_code,process_name,order_num,next_process_id,next_process_code,next_process_name,link_type,key_flag,is_check,is_outsource,color_code)
SELECT 1,@rt_bag,p.process_id,p.process_code,p.process_name,30,NULL,NULL,NULL,'SS','N','N','0','#00AEF3'
  FROM qxx_pro_process p WHERE p.process_code='PRC-BAG-YS' AND p.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_pro_route_process rp WHERE rp.route_id=@rt_bag AND rp.process_code='PRC-BAG-YS' AND rp.factory_id=1);
INSERT INTO qxx_pro_route_process (factory_id,route_id,process_id,process_code,process_name,order_num,next_process_id,next_process_code,next_process_name,link_type,key_flag,is_check,is_outsource,color_code)
SELECT 1,@rt_bag,p.process_id,p.process_code,p.process_name,40,NULL,NULL,NULL,'SS','N','N','0','#00AEF3'
  FROM qxx_pro_process p WHERE p.process_code='PRC-BAG-ZD' AND p.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_pro_route_process rp WHERE rp.route_id=@rt_bag AND rp.process_code='PRC-BAG-ZD' AND rp.factory_id=1);
INSERT INTO qxx_pro_route_process (factory_id,route_id,process_id,process_code,process_name,order_num,next_process_id,next_process_code,next_process_name,link_type,key_flag,is_check,is_outsource,color_code)
SELECT 1,@rt_bag,p.process_id,p.process_code,p.process_name,50,NULL,NULL,NULL,'SS','N','N','0','#00AEF3'
  FROM qxx_pro_process p WHERE p.process_code='PRC-BAG-TS' AND p.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_pro_route_process rp WHERE rp.route_id=@rt_bag AND rp.process_code='PRC-BAG-TS' AND rp.factory_id=1);
INSERT INTO qxx_pro_route_process (factory_id,route_id,process_id,process_code,process_name,order_num,next_process_id,next_process_code,next_process_name,link_type,key_flag,is_check,is_outsource,color_code)
SELECT 1,@rt_bag,p.process_id,p.process_code,p.process_name,60,NULL,NULL,NULL,'SS','N','N','0','#00AEF3'
  FROM qxx_pro_process p WHERE p.process_code='PRC-BAG-BZ' AND p.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_pro_route_process rp WHERE rp.route_id=@rt_bag AND rp.process_code='PRC-BAG-BZ' AND rp.factory_id=1);
INSERT INTO qxx_pro_route_process (factory_id,route_id,process_id,process_code,process_name,order_num,next_process_id,next_process_code,next_process_name,link_type,key_flag,is_check,is_outsource,color_code)
SELECT 1,@rt_bag,p.process_id,p.process_code,p.process_name,70,NULL,NULL,NULL,'SS','N','N','0','#00AEF3'
  FROM qxx_pro_process p WHERE p.process_code='PRC-BAG-CPRK' AND p.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_pro_route_process rp WHERE rp.route_id=@rt_bag AND rp.process_code='PRC-BAG-CPRK' AND rp.factory_id=1);
INSERT INTO qxx_pro_route_process (factory_id,route_id,process_id,process_code,process_name,order_num,next_process_id,next_process_code,next_process_name,link_type,key_flag,is_check,is_outsource,color_code)
SELECT 1,@rt_bag,p.process_id,p.process_code,p.process_name,80,NULL,NULL,NULL,'SS','N','N','0','#00AEF3'
  FROM qxx_pro_process p WHERE p.process_code='PRC-BAG-XSCK' AND p.factory_id=1
   AND NOT EXISTS (SELECT 1 FROM qxx_pro_route_process rp WHERE rp.route_id=@rt_bag AND rp.process_code='PRC-BAG-XSCK' AND rp.factory_id=1);

-- 回填 next_process
UPDATE qxx_pro_route_process a JOIN qxx_pro_route_process b
  ON a.route_id=b.route_id AND a.factory_id=b.factory_id AND b.order_num=(
     SELECT MIN(c.order_num) FROM (SELECT route_id,factory_id,order_num FROM qxx_pro_route_process) c
      WHERE c.route_id=a.route_id AND c.factory_id=a.factory_id AND c.order_num>a.order_num)
   SET a.next_process_id=b.process_id, a.next_process_code=b.process_code, a.next_process_name=b.process_name
 WHERE a.route_id=@rt_bag AND a.factory_id=1;

-- ---------- 10. 清单内物料兜底复活（重复执行安全） ----------
UPDATE qxx_md_item i JOIN tmp_keep_item k ON i.item_code=k.item_code
   SET i.del_flag='0', i.enable_flag='1', i.update_by=@op, i.update_time=@now
 WHERE i.factory_id=1 AND (i.del_flag<>'0' OR i.enable_flag<>'1');

-- 兜底复活工艺路线/工序
UPDATE qxx_pro_route SET del_flag='0', enable_flag='1' WHERE factory_id=1 AND route_code='ROUTE-KRAFT-BAG' AND del_flag<>'0';
UPDATE qxx_pro_process SET del_flag='0', enable_flag='1' WHERE factory_id=1 AND process_code LIKE 'PRC-BAG-%' AND del_flag<>'0';

DROP TEMPORARY TABLE IF EXISTS tmp_keep_item;
