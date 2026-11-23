-- ============================================================
-- V207 组织架构 / 岗位 / 用户 / 角色 重建
-- 幂等：重复执行不会产生重复数据
-- ============================================================

SET @now = NOW();
SET @op = 'admin';

-- ---------- 1. 部门 ----------
-- 先全量软删，再按名称+父级复活（已存在）或新建（不存在），保证可重复执行
UPDATE sys_dept SET del_flag='2', update_by=@op, update_time=@now
 WHERE factory_id=1 AND del_flag='0';

-- 根部门：按名称复活（多条同名取最小 dept_id），不存在则创建
UPDATE sys_dept SET del_flag='0', parent_id=0, ancestors='0', order_num=0,
       leader='陈总', status='0', update_by=@op, update_time=@now
 WHERE factory_id=1 AND dept_name='全印家供应链' ORDER BY dept_id LIMIT 1;
INSERT INTO sys_dept (factory_id,parent_id,ancestors,dept_name,order_num,leader,status,del_flag,create_by,create_time)
SELECT 1,0,'0','全印家供应链',0,'陈总','0','0',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_dept WHERE factory_id=1 AND dept_name='全印家供应链' AND del_flag='0');
SET @d_root = (SELECT dept_id FROM sys_dept WHERE factory_id=1 AND dept_name='全印家供应链' AND del_flag='0' ORDER BY dept_id LIMIT 1);

-- 生产质检部
UPDATE sys_dept SET del_flag='0', parent_id=@d_root, ancestors=CONCAT('0,', @d_root), order_num=1, leader='陈广奇', status='0', update_by=@op, update_time=@now
 WHERE factory_id=1 AND dept_name='生产质检部' AND parent_id=@d_root ORDER BY dept_id LIMIT 1;
INSERT INTO sys_dept (factory_id,parent_id,ancestors,dept_name,order_num,leader,status,del_flag,create_by,create_time)
SELECT 1,@d_root,CONCAT('0,', @d_root),'生产质检部',1,'陈广奇','0','0',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_dept WHERE factory_id=1 AND dept_name='生产质检部' AND parent_id=@d_root AND del_flag='0');
SET @d_pq = (SELECT dept_id FROM sys_dept WHERE factory_id=1 AND dept_name='生产质检部' AND parent_id=@d_root AND del_flag='0' ORDER BY dept_id LIMIT 1);

-- 生产部门
UPDATE sys_dept SET del_flag='0', parent_id=@d_pq, ancestors=CONCAT('0,', @d_root, ',', @d_pq), order_num=1, leader='陈广奇', status='0', update_by=@op, update_time=@now
 WHERE factory_id=1 AND dept_name='生产部门' AND parent_id=@d_pq ORDER BY dept_id LIMIT 1;
INSERT INTO sys_dept (factory_id,parent_id,ancestors,dept_name,order_num,leader,status,del_flag,create_by,create_time)
SELECT 1,@d_pq,CONCAT('0,', @d_root, ',', @d_pq),'生产部门',1,'陈广奇','0','0',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_dept WHERE factory_id=1 AND dept_name='生产部门' AND parent_id=@d_pq AND del_flag='0');
SET @d_prod = (SELECT dept_id FROM sys_dept WHERE factory_id=1 AND dept_name='生产部门' AND parent_id=@d_pq AND del_flag='0' ORDER BY dept_id LIMIT 1);

-- 质检部门
UPDATE sys_dept SET del_flag='0', parent_id=@d_pq, ancestors=CONCAT('0,', @d_root, ',', @d_pq), order_num=2, leader='', status='0', update_by=@op, update_time=@now
 WHERE factory_id=1 AND dept_name='质检部门' AND parent_id=@d_pq ORDER BY dept_id LIMIT 1;
INSERT INTO sys_dept (factory_id,parent_id,ancestors,dept_name,order_num,leader,status,del_flag,create_by,create_time)
SELECT 1,@d_pq,CONCAT('0,', @d_root, ',', @d_pq),'质检部门',2,'','0','0',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_dept WHERE factory_id=1 AND dept_name='质检部门' AND parent_id=@d_pq AND del_flag='0');
SET @d_qc = (SELECT dept_id FROM sys_dept WHERE factory_id=1 AND dept_name='质检部门' AND parent_id=@d_pq AND del_flag='0' ORDER BY dept_id LIMIT 1);

-- 仓库
UPDATE sys_dept SET del_flag='0', parent_id=@d_pq, ancestors=CONCAT('0,', @d_root, ',', @d_pq), order_num=3, leader='叶崇忠', status='0', update_by=@op, update_time=@now
 WHERE factory_id=1 AND dept_name='仓库' AND parent_id=@d_pq ORDER BY dept_id LIMIT 1;
INSERT INTO sys_dept (factory_id,parent_id,ancestors,dept_name,order_num,leader,status,del_flag,create_by,create_time)
SELECT 1,@d_pq,CONCAT('0,', @d_root, ',', @d_pq),'仓库',3,'叶崇忠','0','0',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_dept WHERE factory_id=1 AND dept_name='仓库' AND parent_id=@d_pq AND del_flag='0');
SET @d_wh = (SELECT dept_id FROM sys_dept WHERE factory_id=1 AND dept_name='仓库' AND parent_id=@d_pq AND del_flag='0' ORDER BY dept_id LIMIT 1);

-- 财务部门
UPDATE sys_dept SET del_flag='0', parent_id=@d_root, ancestors=CONCAT('0,', @d_root), order_num=2, leader='', status='0', update_by=@op, update_time=@now
 WHERE factory_id=1 AND dept_name='财务部门' AND parent_id=@d_root ORDER BY dept_id LIMIT 1;
INSERT INTO sys_dept (factory_id,parent_id,ancestors,dept_name,order_num,leader,status,del_flag,create_by,create_time)
SELECT 1,@d_root,CONCAT('0,', @d_root),'财务部门',2,'','0','0',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_dept WHERE factory_id=1 AND dept_name='财务部门' AND parent_id=@d_root AND del_flag='0');
SET @d_fin = (SELECT dept_id FROM sys_dept WHERE factory_id=1 AND dept_name='财务部门' AND parent_id=@d_root AND del_flag='0' ORDER BY dept_id LIMIT 1);

-- 人事行政
UPDATE sys_dept SET del_flag='0', parent_id=@d_root, ancestors=CONCAT('0,', @d_root), order_num=3, leader='', status='0', update_by=@op, update_time=@now
 WHERE factory_id=1 AND dept_name='人事行政' AND parent_id=@d_root ORDER BY dept_id LIMIT 1;
INSERT INTO sys_dept (factory_id,parent_id,ancestors,dept_name,order_num,leader,status,del_flag,create_by,create_time)
SELECT 1,@d_root,CONCAT('0,', @d_root),'人事行政',3,'','0','0',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_dept WHERE factory_id=1 AND dept_name='人事行政' AND parent_id=@d_root AND del_flag='0');
SET @d_hr = (SELECT dept_id FROM sys_dept WHERE factory_id=1 AND dept_name='人事行政' AND parent_id=@d_root AND del_flag='0' ORDER BY dept_id LIMIT 1);

-- 制袋车间
UPDATE sys_dept SET del_flag='0', parent_id=@d_root, ancestors=CONCAT('0,', @d_root), order_num=4, leader='', status='0', update_by=@op, update_time=@now
 WHERE factory_id=1 AND dept_name='制袋车间' AND parent_id=@d_root ORDER BY dept_id LIMIT 1;
INSERT INTO sys_dept (factory_id,parent_id,ancestors,dept_name,order_num,leader,status,del_flag,create_by,create_time)
SELECT 1,@d_root,CONCAT('0,', @d_root),'制袋车间',4,'','0','0',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_dept WHERE factory_id=1 AND dept_name='制袋车间' AND parent_id=@d_root AND del_flag='0');
SET @d_bag = (SELECT dept_id FROM sys_dept WHERE factory_id=1 AND dept_name='制袋车间' AND parent_id=@d_root AND del_flag='0' ORDER BY dept_id LIMIT 1);

-- 包装车间
UPDATE sys_dept SET del_flag='0', parent_id=@d_root, ancestors=CONCAT('0,', @d_root), order_num=5, leader='', status='0', update_by=@op, update_time=@now
 WHERE factory_id=1 AND dept_name='包装车间' AND parent_id=@d_root ORDER BY dept_id LIMIT 1;
INSERT INTO sys_dept (factory_id,parent_id,ancestors,dept_name,order_num,leader,status,del_flag,create_by,create_time)
SELECT 1,@d_root,CONCAT('0,', @d_root),'包装车间',5,'','0','0',@op,@now FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_dept WHERE factory_id=1 AND dept_name='包装车间' AND parent_id=@d_root AND del_flag='0');
SET @d_pack = (SELECT dept_id FROM sys_dept WHERE factory_id=1 AND dept_name='包装车间' AND parent_id=@d_root AND del_flag='0' ORDER BY dept_id LIMIT 1);

-- ---------- 2. 岗位 ----------
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'FGZB','完稿制版',20,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='FGZB');
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'GYZG','工艺主管',21,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='GYZG');
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'WFZG','外发主管',22,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='WFZG');
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'WXGDQC','外协跟单QC',23,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='WXGDQC');
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'GJQC','跟单QC',24,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='GJQC');
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'YSJZ','印刷机长',25,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='YSJZ');
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'NPJPJ','牛皮袋品检',26,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='NPJPJ');
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'BZLPJ','包装类品检',27,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='BZLPJ');
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'CKWLY','仓库物料员',28,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='CKWLY');
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'CCSJ','叉车司机',29,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='CCSJ');
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'PHY','配货员',30,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='PHY');
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'CG','仓管',31,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='CG');
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'SJWY','数据文员',32,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='SJWY');
INSERT INTO sys_post (post_code,post_name,post_sort,status,create_by,create_time,remark)
SELECT 'RSXZ','人事行政',33,'0',@op,@now,'' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE post_code='RSXZ');

-- ---------- 3. 用户 ----------
-- 密码统一 12345678（BCrypt）
-- 方飞锋
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_prod,'fangfeifeng','方飞锋','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'FGZB' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='fangfeifeng' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_prod, nick_name='方飞锋', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='fangfeifeng' AND factory_id=1;
SET @u_fangfeifeng = (SELECT user_id FROM sys_user WHERE user_name='fangfeifeng' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_fangfeifeng AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_fangfeifeng, post_id, 1 FROM sys_post WHERE post_code='FGZB';

-- 鞠阳
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_prod,'juyang','鞠阳','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'GYZG' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='juyang' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_prod, nick_name='鞠阳', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='juyang' AND factory_id=1;
SET @u_juyang = (SELECT user_id FROM sys_user WHERE user_name='juyang' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_juyang AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_juyang, post_id, 1 FROM sys_post WHERE post_code='GYZG';

-- 褚茂利
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_prod,'chumaoli','褚茂利','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'WFZG' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='chumaoli' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_prod, nick_name='褚茂利', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='chumaoli' AND factory_id=1;
SET @u_chumaoli = (SELECT user_id FROM sys_user WHERE user_name='chumaoli' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_chumaoli AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_chumaoli, post_id, 1 FROM sys_post WHERE post_code='WFZG';

-- 黄孝奔
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_prod,'huangxiaoben','黄孝奔','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'WXGDQC' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='huangxiaoben' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_prod, nick_name='黄孝奔', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='huangxiaoben' AND factory_id=1;
SET @u_huangxiaoben = (SELECT user_id FROM sys_user WHERE user_name='huangxiaoben' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_huangxiaoben AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_huangxiaoben, post_id, 1 FROM sys_post WHERE post_code='WXGDQC';

-- 陈广奇
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_prod,'chenguangqi','陈广奇','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'GJQC' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='chenguangqi' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_prod, nick_name='陈广奇', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='chenguangqi' AND factory_id=1;
SET @u_chenguangqi = (SELECT user_id FROM sys_user WHERE user_name='chenguangqi' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_chenguangqi AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_chenguangqi, post_id, 1 FROM sys_post WHERE post_code='GJQC';

-- 邹瑜
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_prod,'zouyu','邹瑜','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'YSJZ' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='zouyu' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_prod, nick_name='邹瑜', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='zouyu' AND factory_id=1;
SET @u_zouyu = (SELECT user_id FROM sys_user WHERE user_name='zouyu' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_zouyu AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_zouyu, post_id, 1 FROM sys_post WHERE post_code='YSJZ';

-- 欧阳斌
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_prod,'ouyangbin','欧阳斌','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'YSJZ' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='ouyangbin' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_prod, nick_name='欧阳斌', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='ouyangbin' AND factory_id=1;
SET @u_ouyangbin = (SELECT user_id FROM sys_user WHERE user_name='ouyangbin' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_ouyangbin AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_ouyangbin, post_id, 1 FROM sys_post WHERE post_code='YSJZ';

-- 李伟
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_qc,'liwei','李伟','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'NPJPJ' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='liwei' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_qc, nick_name='李伟', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='liwei' AND factory_id=1;
SET @u_liwei = (SELECT user_id FROM sys_user WHERE user_name='liwei' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_liwei AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_liwei, post_id, 1 FROM sys_post WHERE post_code='NPJPJ';

-- 蔡玲
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_qc,'cailing','蔡玲','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'BZLPJ' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='cailing' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_qc, nick_name='蔡玲', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='cailing' AND factory_id=1;
SET @u_cailing = (SELECT user_id FROM sys_user WHERE user_name='cailing' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_cailing AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_cailing, post_id, 1 FROM sys_post WHERE post_code='BZLPJ';

-- 叶崇忠
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_wh,'yechongzhong','叶崇忠','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'CKWLY' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='yechongzhong' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_wh, nick_name='叶崇忠', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='yechongzhong' AND factory_id=1;
SET @u_yechongzhong = (SELECT user_id FROM sys_user WHERE user_name='yechongzhong' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_yechongzhong AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_yechongzhong, post_id, 1 FROM sys_post WHERE post_code='CKWLY';

-- 江刘治
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_wh,'jiangliuzhi','江刘治','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'CCSJ' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='jiangliuzhi' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_wh, nick_name='江刘治', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='jiangliuzhi' AND factory_id=1;
SET @u_jiangliuzhi = (SELECT user_id FROM sys_user WHERE user_name='jiangliuzhi' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_jiangliuzhi AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_jiangliuzhi, post_id, 1 FROM sys_post WHERE post_code='CCSJ';

-- 胡小国
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_wh,'huxiaoguo','胡小国','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'PHY' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='huxiaoguo' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_wh, nick_name='胡小国', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='huxiaoguo' AND factory_id=1;
SET @u_huxiaoguo = (SELECT user_id FROM sys_user WHERE user_name='huxiaoguo' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_huxiaoguo AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_huxiaoguo, post_id, 1 FROM sys_post WHERE post_code='PHY';

-- 钟万明
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_wh,'zhongwanming','钟万明','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'CG' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='zhongwanming' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_wh, nick_name='钟万明', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='zhongwanming' AND factory_id=1;
SET @u_zhongwanming = (SELECT user_id FROM sys_user WHERE user_name='zhongwanming' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_zhongwanming AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_zhongwanming, post_id, 1 FROM sys_post WHERE post_code='CG';

-- 刘忆
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_wh,'liuyi','刘忆','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'CG' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='liuyi' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_wh, nick_name='刘忆', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='liuyi' AND factory_id=1;
SET @u_liuyi = (SELECT user_id FROM sys_user WHERE user_name='liuyi' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_liuyi AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_liuyi, post_id, 1 FROM sys_post WHERE post_code='CG';

-- 陈慧琳
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_fin,'chenhuilin','陈慧琳','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'SJWY' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='chenhuilin' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_fin, nick_name='陈慧琳', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='chenhuilin' AND factory_id=1;
SET @u_chenhuilin = (SELECT user_id FROM sys_user WHERE user_name='chenhuilin' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_chenhuilin AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_chenhuilin, post_id, 1 FROM sys_post WHERE post_code='SJWY';

-- 卢姿姿
INSERT INTO sys_user (factory_id,dept_id,user_name,nick_name,user_type,password,status,del_flag,create_by,create_time,remark)
SELECT 1,@d_hr,'luzizi','卢姿姿','00','$2a$10$Ba01BrE0vtmEa8Ikl3AbkOZzyEF6lavTB3IX2Z1skRNRmxxy6hTAO','0','0',@op,@now,'RSXZ' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE user_name='luzizi' AND factory_id=1);
UPDATE sys_user SET dept_id=@d_hr, nick_name='卢姿姿', status='0', del_flag='0', update_by=@op, update_time=@now
 WHERE user_name='luzizi' AND factory_id=1;
SET @u_luzizi = (SELECT user_id FROM sys_user WHERE user_name='luzizi' AND factory_id=1 LIMIT 1);
DELETE FROM sys_user_post WHERE user_id=@u_luzizi AND factory_id=1;
INSERT INTO sys_user_post (user_id,post_id,factory_id)
SELECT @u_luzizi, post_id, 1 FROM sys_post WHERE post_code='RSXZ';

-- 陈广奇设为生产质检部/生产部门负责人
UPDATE sys_dept SET leader='陈广奇' WHERE factory_id=1 AND dept_name IN ('生产质检部','生产部门') AND del_flag='0';
UPDATE sys_dept SET leader='叶崇忠' WHERE factory_id=1 AND dept_name='仓库' AND del_flag='0';

-- 残留用户的部门指向已删部门时置空（admin/ry/luheng 等历史账号）
UPDATE sys_user SET dept_id=NULL
 WHERE factory_id=1 AND dept_id IS NOT NULL
   AND dept_id NOT IN (SELECT dept_id FROM (SELECT dept_id FROM sys_dept WHERE del_flag='0') x);

-- ---------- 4. 角色 ----------
-- 生产主管
INSERT INTO sys_role (factory_id,role_name,role_key,role_sort,data_scope,menu_check_strictly,dept_check_strictly,status,del_flag,create_by,create_time,remark)
SELECT 1,'生产主管','prod_mgr',30,'1',1,1,'0','0',@op,@now,'报价+采购+开单+工艺路线+仓库库存' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_key='prod_mgr' AND factory_id=1);
SET @r_prod_mgr = (SELECT role_id FROM sys_role WHERE role_key='prod_mgr' AND factory_id=1 AND del_flag='0' LIMIT 1);
DELETE FROM sys_role_menu WHERE role_id=@r_prod_mgr AND factory_id=1;
INSERT INTO sys_role_menu (role_id,menu_id,factory_id)
SELECT DISTINCT @r_prod_mgr, m.menu_id, 1 FROM sys_menu m
 WHERE m.menu_id IN (2900,2970,2006,2002,23360,23190,2003,2300,2305,2301)
    OR m.parent_id IN (2900,2970,2006,2002,23360,23190,2003,2300,2305,2301)
    OR m.parent_id IN (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE parent_id IN (2900,2970,2006,2002,23360,23190,2003,2300,2305,2301)) x);

-- 跟单主管
INSERT INTO sys_role (factory_id,role_name,role_key,role_sort,data_scope,menu_check_strictly,dept_check_strictly,status,del_flag,create_by,create_time,remark)
SELECT 1,'跟单主管','follow_mgr',31,'1',1,1,'0','0',@op,@now,'开单+工艺路线+全盘跟单查看' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_key='follow_mgr' AND factory_id=1);
SET @r_follow_mgr = (SELECT role_id FROM sys_role WHERE role_key='follow_mgr' AND factory_id=1 AND del_flag='0' LIMIT 1);
DELETE FROM sys_role_menu WHERE role_id=@r_follow_mgr AND factory_id=1;
INSERT INTO sys_role_menu (role_id,menu_id,factory_id)
SELECT DISTINCT @r_follow_mgr, m.menu_id, 1 FROM sys_menu m
 WHERE m.menu_id IN (2900,2003)
    OR m.parent_id IN (2900,2003)
    OR m.parent_id IN (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE parent_id IN (2900,2003)) x);

-- 外发主管
INSERT INTO sys_role (factory_id,role_name,role_key,role_sort,data_scope,menu_check_strictly,dept_check_strictly,status,del_flag,create_by,create_time,remark)
SELECT 1,'外发主管','out_mgr',32,'1',1,1,'0','0',@op,@now,'开单+工艺路线+跟单查看' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_key='out_mgr' AND factory_id=1);
SET @r_out_mgr = (SELECT role_id FROM sys_role WHERE role_key='out_mgr' AND factory_id=1 AND del_flag='0' LIMIT 1);
DELETE FROM sys_role_menu WHERE role_id=@r_out_mgr AND factory_id=1;
INSERT INTO sys_role_menu (role_id,menu_id,factory_id)
SELECT DISTINCT @r_out_mgr, m.menu_id, 1 FROM sys_menu m
 WHERE m.menu_id IN (2900,2003,2300,2305,2301)
    OR m.parent_id IN (2900,2003,2300,2305,2301)
    OR m.parent_id IN (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE parent_id IN (2900,2003,2300,2305,2301)) x);

-- 跟单QC
INSERT INTO sys_role (factory_id,role_name,role_key,role_sort,data_scope,menu_check_strictly,dept_check_strictly,status,del_flag,create_by,create_time,remark)
SELECT 1,'跟单QC','qc_follow',33,'3',1,1,'0','0',@op,@now,'跟单+报工' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_key='qc_follow' AND factory_id=1);
SET @r_qc_follow = (SELECT role_id FROM sys_role WHERE role_key='qc_follow' AND factory_id=1 AND del_flag='0' LIMIT 1);
DELETE FROM sys_role_menu WHERE role_id=@r_qc_follow AND factory_id=1;
INSERT INTO sys_role_menu (role_id,menu_id,factory_id)
SELECT DISTINCT @r_qc_follow, m.menu_id, 1 FROM sys_menu m
 WHERE m.menu_id IN (2003,2303,2302,2300)
    OR m.parent_id IN (2003,2303,2302,2300)
    OR m.parent_id IN (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE parent_id IN (2003,2303,2302,2300)) x);

-- 综合查看
INSERT INTO sys_role (factory_id,role_name,role_key,role_sort,data_scope,menu_check_strictly,dept_check_strictly,status,del_flag,create_by,create_time,remark)
SELECT 1,'综合查看','admin_view',34,'1',1,1,'0','0',@op,@now,'全盘只读查看' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_key='admin_view' AND factory_id=1);
SET @r_admin_view = (SELECT role_id FROM sys_role WHERE role_key='admin_view' AND factory_id=1 AND del_flag='0' LIMIT 1);
DELETE FROM sys_role_menu WHERE role_id=@r_admin_view AND factory_id=1;
INSERT INTO sys_role_menu (role_id,menu_id,factory_id)
SELECT DISTINCT @r_admin_view, m.menu_id, 1 FROM sys_menu m
 WHERE m.menu_id IN (2001,2002,2003,2006,2900,28900,2005)
    OR m.parent_id IN (2001,2002,2003,2006,2900,28900,2005)
    OR m.parent_id IN (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE parent_id IN (2001,2002,2003,2006,2900,28900,2005)) x);

-- 仓库管理
INSERT INTO sys_role (factory_id,role_name,role_key,role_sort,data_scope,menu_check_strictly,dept_check_strictly,status,del_flag,create_by,create_time,remark)
SELECT 1,'仓库管理','wh_mgr',35,'3',1,1,'0','0',@op,@now,'仓库模块' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_key='wh_mgr' AND factory_id=1);
SET @r_wh_mgr = (SELECT role_id FROM sys_role WHERE role_key='wh_mgr' AND factory_id=1 AND del_flag='0' LIMIT 1);
DELETE FROM sys_role_menu WHERE role_id=@r_wh_mgr AND factory_id=1;
INSERT INTO sys_role_menu (role_id,menu_id,factory_id)
SELECT DISTINCT @r_wh_mgr, m.menu_id, 1 FROM sys_menu m
 WHERE m.menu_id IN (2002,2001,2101)
    OR m.parent_id IN (2002,2001,2101)
    OR m.parent_id IN (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE parent_id IN (2002,2001,2101)) x);

-- 采购文员
INSERT INTO sys_role (factory_id,role_name,role_key,role_sort,data_scope,menu_check_strictly,dept_check_strictly,status,del_flag,create_by,create_time,remark)
SELECT 1,'采购文员','pur_clerk',36,'3',1,1,'0','0',@op,@now,'采购+库存查询' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_key='pur_clerk' AND factory_id=1);
SET @r_pur_clerk = (SELECT role_id FROM sys_role WHERE role_key='pur_clerk' AND factory_id=1 AND del_flag='0' LIMIT 1);
DELETE FROM sys_role_menu WHERE role_id=@r_pur_clerk AND factory_id=1;
INSERT INTO sys_role_menu (role_id,menu_id,factory_id)
SELECT DISTINCT @r_pur_clerk, m.menu_id, 1 FROM sys_menu m
 WHERE m.menu_id IN (2006,2002,23360,23190)
    OR m.parent_id IN (2006,2002,23360,23190)
    OR m.parent_id IN (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE parent_id IN (2006,2002,23360,23190)) x);

-- 生产员工
INSERT INTO sys_role (factory_id,role_name,role_key,role_sort,data_scope,menu_check_strictly,dept_check_strictly,status,del_flag,create_by,create_time,remark)
SELECT 1,'生产员工','emp',37,'3',1,1,'0','0',@op,@now,'报工' FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_key='emp' AND factory_id=1);
SET @r_emp = (SELECT role_id FROM sys_role WHERE role_key='emp' AND factory_id=1 AND del_flag='0' LIMIT 1);
DELETE FROM sys_role_menu WHERE role_id=@r_emp AND factory_id=1;
INSERT INTO sys_role_menu (role_id,menu_id,factory_id)
SELECT DISTINCT @r_emp, m.menu_id, 1 FROM sys_menu m
 WHERE m.menu_id IN (2003,2303,2300)
    OR m.parent_id IN (2003,2303,2300)
    OR m.parent_id IN (SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE parent_id IN (2003,2303,2300)) x);

-- ---------- 5. 用户角色绑定 ----------
DELETE FROM sys_user_role WHERE user_id=@u_fangfeifeng AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_fangfeifeng, @r_emp, 1);
DELETE FROM sys_user_role WHERE user_id=@u_juyang AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_juyang, @r_prod_mgr, 1);
DELETE FROM sys_user_role WHERE user_id=@u_chumaoli AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_chumaoli, @r_out_mgr, 1);
DELETE FROM sys_user_role WHERE user_id=@u_huangxiaoben AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_huangxiaoben, @r_qc_follow, 1);
DELETE FROM sys_user_role WHERE user_id=@u_chenguangqi AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_chenguangqi, @r_follow_mgr, 1);
DELETE FROM sys_user_role WHERE user_id=@u_zouyu AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_zouyu, @r_emp, 1);
DELETE FROM sys_user_role WHERE user_id=@u_ouyangbin AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_ouyangbin, @r_emp, 1);
DELETE FROM sys_user_role WHERE user_id=@u_liwei AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_liwei, @r_emp, 1);
DELETE FROM sys_user_role WHERE user_id=@u_cailing AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_cailing, @r_emp, 1);
DELETE FROM sys_user_role WHERE user_id=@u_yechongzhong AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_yechongzhong, @r_wh_mgr, 1);
DELETE FROM sys_user_role WHERE user_id=@u_jiangliuzhi AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_jiangliuzhi, @r_emp, 1);
DELETE FROM sys_user_role WHERE user_id=@u_huxiaoguo AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_huxiaoguo, @r_emp, 1);
DELETE FROM sys_user_role WHERE user_id=@u_zhongwanming AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_zhongwanming, @r_emp, 1);
DELETE FROM sys_user_role WHERE user_id=@u_liuyi AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_liuyi, @r_emp, 1);
DELETE FROM sys_user_role WHERE user_id=@u_chenhuilin AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_chenhuilin, @r_pur_clerk, 1);
DELETE FROM sys_user_role WHERE user_id=@u_luzizi AND factory_id=1;
INSERT INTO sys_user_role (user_id,role_id,factory_id) VALUES (@u_luzizi, @r_admin_view, 1);
