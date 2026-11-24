# MES 数据清理与初始化（2026-11-23）

承接 ERP 下发的报价单/采购单（转 MES 销售订单）之前，对 MES 做一次数据重置。

## 0. 备份（已执行）

| 环境 | 文件 | 时间 | 大小 |
|---|---|---|---|
| 本地 | `backup/mes_local_20261123_232822.sql` | 23:28 | 2.8 MB / 185 表 |
| 线上 | `backup/mes_online_20261123_233017.sql.gz`（服务器同存 `/root/db_backup/`） | 23:30 | 309 KB / 183 表 |

回滚：

```bash
# 本地
mysql -h127.0.0.1 -P3307 -uroot -proot < backup/mes_local_20261123_232822.sql
# 线上
zcat backup/mes_online_20261123_233017.sql.gz | docker exec -i qxx-mysql mysql -uroot -pqxx123456
```

## 1. 脚本

| 文件 | 内容 |
|---|---|
| `sql/V206__add_del_flag.sql` | 8 张业务表加 `del_flag` + 索引（幂等，存储过程判存在） |
| `sql/V207__org_restructure.sql` | 部门树 / 岗位 / 16 个用户 / 8 个角色 / 菜单授权 |
| `sql/V208__master_data.sql` | 纸张三级分类 / 743 条物料 / 工艺路线 + 8 道工序 |
| `sql/V209__business_reset.sql` | 单据软删 / 客户停用 / 供应商补充 / 282 条期初库存 |
| `sql/V210__fix_stock_units.sql` | 修正 V209 缺陷：单位存成 unit_id、缺装箱规格/箱数/PO号 |
| `sql/V211__cleanup_business_docs.sql` | 15 张业务主表逻辑删除 + 操作/登录日志物理清空 |
| `sql/V212__cleanup_wm_transaction.sql` | 库存事务物理删除（150 条 + 指向它的物料追溯 64 条），库存现有量不动 |

### V211 清理了哪些页面

| 页面 | 表 | 结果 |
|---|---|---|
| 客户 /mes/md/client | qxx_md_client | 9 → 软删 |
| 加工单 /mes/pro/outsource | qxx_wm_outsource_order | 21 → 软删 |
| 排产任务 /mes/pro/task | qxx_pro_task | 212 → 软删 |
| 生产报工 /mes/pro/feedback | qxx_pro_feedback | 70 → 软删 |
| 异常台账 /mes/pro/exception | qxx_pro_exception | 4 → 软删 |
| 采购入库 /mes/wm/item_recpt | qxx_wm_item_recpt | 22 → 软删 |
| 采购退货 /mes/wm/rt_vendor | qxx_wm_rt_vendor | 2 → 软删 |
| 产品入库 /mes/wm/product_recpt | qxx_wm_product_recpt | 15 → 软删 |
| 生产领料 /mes/wm/issue | qxx_wm_issue_header | 51 → 软删 |
| 生产退料 /mes/wm/rtissue | qxx_wm_rt_issue | 3 → 软删 |
| 销售出库 /mes/wm/product_sales | qxx_wm_product_sales | 17 → 软删 |
| 来料检验 /mes/qc/qciqc | qxx_qc_iqc | 10 → 软删 |
| 过程检验 /mes/qc/qcipqc | qxx_qc_ipqc | 4 → 软删 |
| 编码记录 /mes/sys/autocoderesult | sys_auto_code_result | 137 → 软删 |
| 待办事项 /mes/sys/todolist | sys_todo_list | 17 → 软删 |
| 操作日志 /mes/sys/log/operlog | sys_oper_log | **物理删除**（1370 条） |
| 登录日志 /mes/sys/log/logininfor | sys_logininfor | **物理删除**（955 条） |

配套改动：15 个 Mapper 共 51 处查询补 `del_flag='0'`，覆盖列表、详情、`/listAll` 全量接口、唯一校验、报工可选任务、移动端我的工单、异常完工硬拦、首页待办角标统计。

两个刻意例外：
- `selectSysAutoCodeResultForUpdate`（编码取号）**不过滤**，否则已删记录代表号段被跳过会导致重号
- `WmProductRecptMapper` 的客户左连接把 `c.del_flag='0'` 放在 **ON** 上，放 WHERE 会让左连接退化为内连接、客户被删的入库单整行消失


### V210 修正了什么

V209 有两处导入缺陷，V210 全部纠正（幂等，可重复执行）：

1. **`unit_of_measure` 误写为 `unit_id`**（200/201/204），应为单位编码。已改为 `PCS`(324 成品) / `KG`(411 纸张) / `PAIR`(8 辅料绳)；库存行按物料回填，成品库存从错误的 `KG` 修正为 `PCS`。
2. **未导入装箱规格与订单信息**，现已补：
   - 物料：`unit2='BOX'`、`unit2_name='箱'`、`conversion_rate`=每箱数量、`package_spec`="200个/箱"
   - 库存：`quantity_onhand2`=剩余箱数、`quantity_available2` 同步、`conversion_rate`=该批次装箱数
   - 库存新增 `po_no`（客户PO号）、`source_order_code`（系统订单号）两列并落值


生成器：`gen_reset_sql.py`（读 `.tmp_mes_clean/` 下三个 Excel，可重跑）
执行器：`exec_sql.py local` / `exec_sql.py <env> V207`（支持 DELIMITER，逐条报错即停）

所有脚本幂等，可重复执行。

## 2. 处理结果

### 组织

```
全印家供应链
├── 生产质检部          负责人 陈广奇
│   ├── 生产部门        陈广奇 / 鞠阳 / 褚茂利 / 黄孝奔 / 方飞锋 / 邹瑜 / 欧阳斌
│   ├── 质检部门        李伟 / 蔡玲
│   └── 仓库            叶崇忠(负责人) / 江刘治 / 胡小国 / 钟万明 / 刘忆
├── 财务部门            陈慧琳
├── 人事行政            卢姿姿
├── 制袋车间
└── 包装车间
```

原若依默认部门（深圳总公司、长沙分公司及其下 7 个部门，含两个重名"财务部门"）全部 `del_flag='2'`。

### 用户

16 个新账号，账号=姓名全拼，密码统一 `12345678`（BCrypt `$2a$10$`）。历史账号（admin、ry、luheng、姚晓翔、5 个分切厂商）保留不动，指向已删部门的 `dept_id` 置 NULL。

### 角色

| 角色 | 人员 | 菜单范围 |
|---|---|---|
| 生产主管 | 鞠阳 | 报价 + 采购 + 工单 + 工艺路线 + 库存 |
| 跟单主管 | 陈广奇 | 销售管理 + 生产管理（全盘） |
| 外发主管 | 褚茂利 | 销售 + 工单/变更/工艺路线 |
| 跟单QC | 黄孝奔 | 报工 + 排产任务 + 工单 |
| 综合查看 | 卢姿姿 | 主数据/仓库/生产/采购/销售/质量/设备 全盘只读 |
| 仓库管理 | 叶崇忠 | 仓库模块 + 物料主数据 |
| 采购文员 | 陈慧琳 | 采购 + 库存查询 |
| 生产员工 | 方飞锋、邹瑜、欧阳斌、李伟、蔡玲、江刘治、胡小国、钟万明、刘忆 | 报工 + 工单 |

### 物料（743 条）

| 类别 | 数量 | 说明 |
|---|---|---|
| 纸张 SPU | 207 | 柔印表 11 纸种 × 18 克重 = 198，加库存中独有的 9 个克重组合 |
| 纸张 SKU | 184 | 按门幅展开，品牌（金东/云轩/茹君/晨鸣/仙鹤）写入 `ext_attrs.PAPER_SOURCE` |
| 纸边 SKU | 20 | 分切余料，独立编码 `RAW-EDGE-*` |
| 辅料纸绳 | 8 | 圆纸绳 4 + 扁纸绳 4（RAW-ROPE 下新建二级分类） |
| 成品 | 324 | 现货 70 + 外采新增 21 + 订单定制 233，全部扁平 `parent_id=0` |

编码规则：

- 纸张 SPU `RAW-PAPER-{纸种}-{克重}`，如 `RAW-PAPER-WK-80`（80克乌卡）
- 纸张 SKU `RAW-PAPER-{纸种}-{克重}-{门幅}`，如 `RAW-PAPER-WK-80-1100`
- 成品 `FIN-SPOT-0001` / `FIN-WAI-0001` / `FIN-ORD-0001`

纸张下新建 14 个三级分类：白牛皮、乌卡、食品级白牛皮、食品级黄牛皮、精牛、箱板纸、TC箱板纸、白挂面纸、彩色双胶纸、特种纸、灰底白板纸、赤松黄牛、瑞典赤牛、梦迪。原有分类与分类扩展（`qxx_md_item_type_attr`、`qxx_md_attr_def`）未改动。

### 工艺

- 原 13 条路线、17 道工序 `del_flag='2'`
- 新建 `ROUTE-KRAFT-BAG` 卷筒牛皮纸袋生产工艺路线
- 8 道工序 `PRC-BAG-*`：原纸 → 辅料 → 印刷 → 制袋 → 贴绳 → 包装 → 产品入库 → 销售出库（`next_process` 已串联）

### 业务数据

| 对象 | 结果 |
|---|---|
| 工单 46 / 销售订单 30 / 采购单 15 / 报价单 6 | 全部 `del_flag='2'` |
| 库存 34 条历史 | `del_flag='2'` |
| 客户 9 个 | `enable_flag='0'`（无 del_flag 列） |
| 供应商 | 保留 13 个，新增长九、义乌民邦纸制品厂、瑞禾、徐伟商 4 个（浩卓已存在） |
| 期初库存 | 282 条（原料 152 / 成品 130），原料按 kg 入原料仓，成品按个入成品仓 |

成品只有备注为"库存货/库存"的订单行计入期初数量，其余订单行数量为 0。

## 3. Mapper 改造（软删除生效）

8 个 Mapper、33 处查询已加 `del_flag = '0'`：

`MdItemMapper`(5) `ProRouteMapper`(4) `ProProcessMapper`(4) `ProWorkorderMapper`(5) `SalOrderMapper`(6) `SalQuoteMapper`(3) `PurOrderMapper`(2) `WmMaterialStockMapper`(4)

覆盖列表、详情、唯一校验（`checkItemCodeUnique` / `checkOrderCodeUnique` 等）、移动端 count。

**未改**：跨表 left join（BOM、工位、报表统计、物料追溯）——已删数据不参与业务，left join 保留主行语义正确；写侧 `delete` 语句仍是物理删除，本次清理由 SQL 完成，不影响日常删除。

## 4. 本地验证结果

```
物料   743 有效 / 33 已删      工序  8 有效 / 17 已删
路线     1 有效 / 13 已删      库存 282 有效 / 34 已删
SKU 挂父级 204（184 纸张 + 20 纸边）
工单/订单/采购/报价/客户 全部软删
```

Mapper 改造后按生成 SQL 实测（含 `del_flag='0'` 与拦截器注入的 `factory_id`）：

| 查询 | 结果 | 期望 |
|---|---|---|
| 物料列表 | 743 | 743 |
| 物料详情（已删 ID） | 0 | 0 |
| 编码唯一校验（已删物料） | 0 | 0 |
| 工艺路线列表 | 1 | 1 |
| 工序列表 | 8 | 8 |
| 工单 / 销售订单 / 报价单 / 采购单列表 | 0 / 0 / 0 / 0 | 0 |
| 库存列表 / 全量导出 | 282 / 282 | 282 |

后端已 `mvn package` 并启动成功（MyBatis 解析全部 Mapper 无报错）。

> 接口级 E2E 未在本机完成：当前会话的后台进程会在命令结束时被回收，无法保持服务常驻做 curl 验证。**上线前请在本机手动 `java -jar` 启动，登录后逐页确认列表条数。**


## 5. 线上迁移步骤

1. 再次备份线上库
2. 上传 `sql/` 与 `exec_sql.py` 到服务器
3. 依次执行 V206 → V207 → V208 → V209（执行器逐条校验，失败即停）
4. 上传新 `ruoyi-admin.jar`，重启后端
5. 实测：物料列表 743 条、工艺路线 1 条、工单列表 0 条、库存列表 282 条

## 5.1 线上执行结果（2026-11-24 00:22~00:40 已完成）

线上库备份：`/root/db_backup/mes_before_reset_20261124_002123.sql.gz`

| 步骤 | 结果 |
|---|---|
| V206 加列 | 8 张业务表 `del_flag` + 索引全部创建 |
| V207 组织 | 部门 9 个（根 200 → 生产质检部 201 → 生产/质检/仓库）、16 用户、8 角色、菜单授权完成 |
| V208 主数据 | 物料 743 有效 / 30 已删，工艺路线 1 条 + 8 道工序 |
| V209 业务 | 工单 47 / 订单 31 / 采购 16 / 报价 1 全部软删；期初库存 282 条（原料 152 / 成品 130） |
| 后端部署 | 编译成功，systemd 重启，`Started RuoYiApplication in 64.21s`，Flyway 应用 V203~V205 至 205 |
| 前端部署 | dist 已 scp，`nginx -s reload` 成功 |

**接口实测**（线上 admin 账号）：

```
后端页面      200
物料列表      total = 743   ✅
工单列表      total = 0     ✅（软删除生效）
工艺路线      total = 1     ✅
前端页面      200
Nginx prod-api 200
```

### ⚠️ 发布时踩到的配置坑（已修）

线上后端由 **systemd（`qxx-backend.service`）** 托管，不是 nohup。本地开发用的 `application.yml` / `application-druid.yml` 含本地库配置（DB `root/root`、Redis `6377/Asdf1234567!`），推到线上后服务连不上库和缓存。已做如下处理：

1. `application-druid.yml` 的账号密码改为 `${QXX_DB_USERNAME:root}` / `${QXX_DB_PASSWORD:root}`
2. `qxx-backend.service` 的 ExecStart 补上线上参数：
   `-DQXX_DB_USERNAME=root -DQXX_DB_PASSWORD=qxx123456 -Dspring.data.redis.port=6380 -Dspring.data.redis.password=qxx123456`
3. `deploy` skill 已同步更新（改为 `systemctl restart`、记录参数与 60~70 秒启动时长）


## 6. 待确认

1. **陈广奇 / 陈光奇**：需求里出现两种写法，脚本按"陈广奇"处理。
2. **"开单"** 权能按"销售订单 + 生产工单"理解，若仅指工单需调整角色菜单。
3. **纸边库存** 单独建了物料与分类，若只想作为余料台账可去掉。
4. **成品订单定制款** 233 个全部建为物料；若担心一次性 SKU 污染主数据，可改为按需创建。
5. **报价单/采购单** 是 ERP 下发入口，清理后 MES 侧无历史单，ERP 重推会重新生成。
