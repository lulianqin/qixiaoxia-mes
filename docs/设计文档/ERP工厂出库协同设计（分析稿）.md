# ERP 工厂出库协同设计（分析稿）

> 状态：**P2 已实施、P1（ERP/SRM 侧）已实施，P3-P6 待实施** ｜ 版本：v0.3 ｜ 日期：2026-11-23
> 范围：ERP 平台端（`qixiaoxia_store`）为主导，MES（`qixiaoxia-mes`）配合改造
> 目标流程：SRM 采购单（ERP 平台端）→ MES 生产/采购入库 → ERP 可见入库数量与状态 → ERP 提交出库申请（支持分批）→ MES 生成销售出库单并扣减库存 → 结果回写 ERP

---

## 1. 结论先行

1. **改造前链路是断的**：ERP 看不到 MES 的入库数量，MES 也收不到 ERP 的出库申请。目前 ① 入库回写已完成 ERP/SRM 接收端，②③ 仍待 P3。
2. **可申请量不以 ERP 自算为准**：以 SRM 实时入库量为基准，减去 ERP 出库申请行的有效占用；SRM 不可用时禁止建单。
3. **出库申请不能只挂 ERP 采购单**。采购单是「买」的关系，出库是「卖给终端客户」，必须同时挂内部销售订单（`sys_order`）与采购单（工厂）两条线，否则财务对账与履约状态会错。
4. 推荐把现有 `sys_ware_house_out_apply` 升级为**统一出库申请单**（区分来源：工厂 MES / 本地仓 / SRM），而不是再造一套。

---

## 2. 现状盘点（As-Is）

### 2.1 ERP 端（qixiaoxia_store）

| 能力 | 现状 | 位置 |
|------|------|------|
| 内部销售订单 | ✅ `sys_order` / `sys_order_goods`，有 `fulfill_status`、`fulfill_mode`、`shipped_qty`、`locked_qty` | `SysOrderController` `/system/order` |
| 采购单（下给工厂） | ⚠️ 平台端采购单存 **SRM** `Sys_PurchaseOrder`；ERP 本地 `sys_purchase_order` 仅合伙人端使用（暂不下发 MES） | SRM / `PurchaseOrderController` |
| 采购单入库数量 | ⚠️ 原无字段；已补 `inbound_status / inbound_qty / last_inbound_time / mes_order_code`（MES→ERP→SRM 回写） | `SysPurchaseOrderServiceImpl` |
| MES 协同台账 | ✅ `sys_mes_doc_sync` / `sys_mes_doc_push_log` / `sys_mes_factory_rule` / `_config` | `SysMesFactoryServiceImpl` |
| 下发给 MES | ✅ 仅 `PURCHASE`、`QUOTATION` 两类，`POST /open-api/sal/erp/order/receive` | `doPush` / `buildPurchasePayload` |
| MES 回调 | ✅ 「接单/打回」「报价」；已新增「入库回写」：`/open-api/factory/purchase/inbound-callback` | `MesFactoryCallbackController` |
| 出库申请单 | ⚠️ 改造前孤立：`sys_ware_house_out_apply` / `_list`，单号 `CKSQ+日期+序号`，有审核 | `SysWareHouseOutApplyController` `/system/wareHouseOutApply` |
| 出库申请关联 | ✅ 已补采购单、MES 订单/出库单、下发状态；**内部销售订单关联待 P4** | `SysWareHouseOutApplyList` |
| 本地库存 | ❌ 无仓库库存模块；明细里 `inventory_qty` 只是录入值 | — |
| 另一套出库申请 | ⚠️ SRM 专用：`/api/srm/wareHouseOutApply` 走 `SupplyChainClientService`；SRM 出库/库存已停用，仅历史数据 | `WareHouseOutApplyController` |

### 2.2 MES 端（qixiaoxia-mes）

| 能力 | 现状 | 位置 |
|------|------|------|
| 接收 ERP 采购单 | ✅ 落 `qxx_sal_order` / `qxx_sal_order_line`，`externalOrderNo` 幂等，`externalLineId` = ERP 采购单行 ID | `SalErpOpenController` / `SalOrderServiceImpl.receiveFromErp` |
| 接单/打回回写 | ✅ 队列化回写 ERP（`SysSyncTask` + `ErpClient`） | `ErpCallbackPayload` / `ErpCallbackPaths` |
| 成品入库 | ✅ `qxx_wm_product_recpt` / `_line`，有 `workorderId`（可经 `ProWorkorder.salesOrderLineId` 追到订单行） | `WmProductRecptServiceImpl.confirmProductRecpt` |
| 物料/采购入库 | ✅ `qxx_wm_item_recpt`，`purOrderId` 是 MES 自己的采购单 | `WmItemRecpt` |
| 销售出库单 | ✅ 头/行/明细/装箱/发运，状态 `DRAFT → PARTIAL_POSTED/POSTED → SHIPPED → CLOSED/CANCELED` | `WmProductSalesServiceImpl.postOut` |
| 分批出库 | ✅ 支持部分过账，累计 `quantityPosted` | 同上 |
| 扣减库存 | ✅ Redisson 锁 + 事务，FIFO 跨批次，写 `qxx_wm_transaction` | 同上 |
| 从销售订单生成出库草稿 | ✅ `GET /mes/wm/product_sales/fromSaleOrder/{orderId}` | `WmProductSalesController` |
| 库存预占 | ✅ `qxx_wm_stock_reservation` 已含 `salesOrderId/salesOrderLineId` | `WmStockReservation` |
| 出库申请概念 | ❌ 无 | — |
| 入库/出库回写 ERP | ⚠️ 入库：ERP 接收端已实现，**MES 发送端待实施**；出库回写待 P3 | — |

### 2.3 改造前链路结论

```
ERP采购单 ──✅下发──▶ MES销售订单(幂等) ──✅接单回写──▶ ERP
      │                        │
      │                        └──✅生产/入库──▶ qxx_wm_product_recpt
      │                                              │
      ✗ 无入库回写 ◀────────────────────────────────┘
      │
      ✗ ERP出库申请(sys_ware_house_out_apply) 孤立，不下发 MES
      │
      ✗ MES销售出库(postOut扣库存) 游离，不回写 ERP
```

**缺的三段接口（括号为当前进度）**：
- ① MES 入库结果 → ERP（入库数量、状态）—— ERP/SRM 接收端已实现，MES 发送端待实施
- ② ERP 出库申请 → MES（生成出库单）—— 待 P3
- ③ MES 出库结果 → ERP（已出库数量、状态；含手工直开旁路）—— 待 P3

---

## 3. 流程合理性评估

### 3.1 合理之处

- 工厂生产/存货，平台按客户订单指令发货，责任边界清晰。
- MES 已有分批过账 + FIFO 扣库存 + 预占表，执行侧无需重做。
- ERP 已有 `sys_mes_doc_sync` 台账 + 幂等键 + 重推机制，可复用于新单据类型。

### 3.2 必须修正的设计问题

| # | 问题 | 风险 | 建议 |
|---|------|------|------|
| P1 | ERP 看不到入库数量，却要按「已入库」申请出库 | 无依据可申请，必然超发/错发 | 先做①入库回写，再做② |
| P2 | 用 ERP 侧数据算可用量 | 与 SRM 入库量/ERP 申请占用不一致 | 可用量 = SRM 实时入库量 − ERP 出库申请行有效占用 |
| P3 | 出库申请只挂采购单 | 财务无法对应终端客户；销售订单履约不更新 | 申请单必须同时挂 `sys_order`/`sys_order_goods` + 采购单 + MES 订单行 |
| P4 | 无预占，仅按已出库比较 | 两张申请单并发超发 | 提交申请即占用申请行 `applied_qty`；MES 出库时累计 `posted_qty` |
| P5 | 旁路「业务直接找工厂开单」不闭环 | ERP 账实不符 | MES 手工出库单必须按 `externalOrderNo/clientOrderCode` 回写 ERP |
| P6 | 出库申请与出库单关系未定 | 分批执行时数量对不上 | 申请行 = 目标数量；MES 出库单可多次过账，累计回写；一张申请 1:N 出库单 |
| P7 | 回写失败无兜底 | 状态永久不一致 | 复用 MES `SysSyncTask` 重试队列 + ERP 台账 `writeback_status` |
| P8 | 出库类型混用 | 现有 `sys_ware_house_out_apply` 服务 SRM/本地仓 | 加 `source_type`（MES_FACTORY / LOCAL / SRM）区分，不混数据 |

### 3.3 状态机建议

**ERP 出库申请单**（`sys_ware_house_out_apply` 新增状态维度，与现有审核并存）

```
草稿 DRAFT → 待审核 PENDING → 已审核 APPROVED(待下发) → 已下发 PUSHED
   → 执行中 PARTIAL(部分出库) → 已完成 DONE
   ↘ 已驳回 REJECTED / 已撤回 CANCELED / 下发失败 PUSH_FAILED
```

**MES 出库申请（新增）**

```
待接收 → 待出库(库存足够) → 执行中(部分过账) → 已完成
        ↘ 已拒绝(库存不足/OQC未过) / 已取消
```

**ERP 采购单行入库状态**（派生字段，不手工改）

```
未入库 → 部分入库 → 已入库（inbound_qty 与采购数量比较）
```

> 当前已实现的状态口径：主表沿用 `audit_status`，另加 `sync_status`（NOT_PUSHED/PUSHING/PUSHED/PUSH_FAILED）；申请行用 `line_status`（PENDING/PARTIAL/DONE/REJECTED）。未新增独立的主表状态枚举，上面的 ERP 出库申请状态机是 P3 下发/撤回落地时的目标态。

---

## 4. 推荐方案（ERP 平台端为主）

### 4.1 总体时序

```
[ERP] SRM采购单下发 ──────────▶ [MES] 销售订单
                                      │ 生产/采购入库确认
                                      ▼
[ERP] 采购单行累计入库 ◀────── ①inbound-callback（按行汇总）
      │
      │ 业务/计划员在 ERP 建「出库申请单」（选 SRM 采购单 + 明细行，填申请数量）
      │ 内部销售订单关联待 P4 补齐
      │ 审核 → 下发
      ▼
[MES] 生成出库申请 + 销售出库草稿（复用 fromSaleOrder）
      │ 仓库确认 → postOut（分批）→ 扣库存
      ▼
[ERP] 申请行已出库量/状态 ◀── ③outbound-callback
      │ 同步更新 sys_order_goods.shipped_qty / fulfill_status
      ▼
   完结（DONE）
```

旁路：MES 手工建销售出库单 → 过账后按销售订单行汇总，携带 `externalOrderNo/orderNumber/mesSalesCode` 回写；ERP 按 `MES-{mesSalesCode}` 幂等生成一张已完成的出库申请，行 `applied_qty = posted_qty`，从而参与可申请量扣减与订单履约，避免绕过申请导致超发。

### 4.2 接口契约

#### ① MES → ERP 入库回写

`POST /open-api/factory/purchase/inbound-callback`（Header `X-API-Key`）

> 已实现（ERP 侧）。ERP 按 `recptCode + externalLineId` 幂等落 `sys_mes_inbound_log`，
> 汇总累计入库量后调用 SRM `POST /api/Sys_PurchaseOrder/WriteBackInbound` 回写。

```json
{
  "externalOrderNo": "CG202611001",
  "mesOrderCode": "SO202611001",
  "lines": [
    {
      "externalLineId": "10086",
      "productCode": "P-001",
      "inboundQty": 300,
      "inboundTime": "2026-11-23 10:00:00",
      "recptCode": "CPRK20261123001"
    }
  ]
}
```

ERP 处理：按 `recptCode + externalLineId` 幂等写入 `sys_mes_inbound_log`；再按该行累计入库量调用 SRM `WriteBackInbound`，更新采购单明细/主表入库状态。

#### ② ERP → MES 出库申请下发

`POST /open-api/sal/erp/outbound/apply`

```json
{
  "sourceSystem": "ERP",
  "externalApplyNo": "CKSQ20261123001",
  "externalOrderNo": "CG202611001",
  "externalOrderId": "5001",
  "requestDate": "2026-11-30",
  "receiver": { "name": "张三", "tel": "138...", "address": "..." },
  "lines": [
    {
      "externalApplyLineId": "1",
      "externalLineId": "10086",
      "itemCode": "P-001",
      "applyQty": 200,
      "warehouseCode": "FG01"
    }
  ]
}
```

MES 处理：
- 以 `externalApplyNo` 幂等；
- 校验 `applyQty ≤ 已入库 − 有效申请行占用`（已取消/已驳回释放，已完成仍占用）；
- 生成 MES 出库申请行 + 销售出库单草稿（`salesOrderId` 取自 `externalOrderNo` 对应订单），库存不足可部分接收并回状态。

#### ③ MES → ERP 出库结果回写

`POST /open-api/factory/sales/outbound-callback`

```json
{
  "externalApplyNo": "CKSQ20261123001",
  "mesSalesCode": "XSCK20261123001",
  "status": "PARTIAL_POSTED",
  "outboundTime": "2026-11-23 15:00:00",
  "lines": [
    {
      "externalApplyLineId": "1",
      "externalLineId": "10086",
      "postedQty": 120,
      "totalPostedQty": 120
    }
  ]
}
```

ERP 处理：按申请行回写 `posted_qty`/`line_status`；再按**销售订单编号**汇总所有 MES 出库申请已出库量，订单级更新 `sys_order.fulfill_status`（5 部分发货 / 6 已发货）与 `order_status`（40 已发货）。

#### ④ 可申请量查询（ERP 内部，已实现）

`GET /system/wareHouseOutApply/availableQty?purchaseOrderGoodsId=&purchaseOrderId=&purchaseOrderSource=SRM&excludeApplyId=`

- `purchaseOrderSource=SRM`：实时调 SRM 取 `InboundQty`，减 ERP 申请行占用；
- `LOCAL`：查本地 `sys_purchase_order_goods.inbound_qty`，减 ERP 申请行占用；
- 供建单页提交前逐行校验。

### 4.3 数据模型变更

**ERP（`qixiaoxia_store`）**

| 表 | 变更 |
|----|------|
| `sys_purchase_order`（合伙人端本地） | 新增 `inbound_status`、`inbound_qty`、`last_inbound_time`、`mes_order_code`（与 SRM 字段对齐，见 §4.3.1） |
| `sys_purchase_order_goods`（合伙人端本地） | 新增 `inbound_qty`、`mes_order_line_id`；**不冗余** `applied_qty/outbound_qty` |
| `sys_ware_house_out_apply` | 新增 `source_type`（MES_FACTORY/LOCAL/SRM）、`purchase_order_id`、`purchase_order_source`（LOCAL/SRM）、`purchase_order_no`、`external_apply_no`、`mes_sales_id`、`mes_sales_code`、`sync_status`、`sync_msg`、`version`、`push_time`、`writeback_time` |
| `sys_ware_house_out_apply_list` | 新增 `purchase_order_goods_id`、`mes_order_line_id`、`applied_qty`、`posted_qty`、`line_status` |
| `sys_mes_inbound_log`（已建） | 入库回写去重与审计：`external_order_no`、`external_line_id`、`recpt_code`、`inbound_qty`、`inbound_time`，唯一键 `(recpt_code, external_line_id)` |
| SRM `Sys_PurchaseOrder*` | 仅补入库字段（见 §4.3.1 对齐表），出库/库存表不动 |

**MES（`qixiaoxia-mes`）**

| 表 | 变更 |
|----|------|
| 新增 `qxx_wm_sales_apply` / `qxx_wm_sales_apply_line` | 出库申请，`external_apply_no` 幂等，行存 `external_line_id`、`apply_qty`、`posted_qty` |
| `qxx_wm_product_recpt` | 新增 `sales_order_id` / `sales_order_line_id`（或经 workorder 关联计算，二选一） |
| `qxx_wm_product_sales` | 新增 `apply_id` / `apply_code`、`source_type`（ERP_APPLY / MANUAL） |
| `qxx_wm_product_sales_line` | 新增 `apply_line_id`（回写行匹配） |
| `qxx_sys_sync_task` | 新增业务类型 `INBOUND_SYNC`、`OUTBOUND_RESULT` |

> 若不想新增申请表，可让 `qxx_wm_product_sales` 直接承载申请（`status` 前加 `APPLIED`），但会让「申请」与「出库」两个状态机耦合，**不推荐**。

### 4.3.1 系统职责与数据归属（2026-11-23 重新确认）

SRM 是 ERP 平台的历史/过渡系统，仅继续承载报价单、订单、采购单的保存；出库相关新能力全部落在 ERP + MES。

| 数据 | 归属系统 | 表 | 说明 |
|------|----------|----|------|
| 报价单 / 订单 / 采购单 | **SRM** | SRM `Sys_QuotationOrder` / `Sys_Order` / `Sys_PurchaseOrder` | ERP 平台端仍直接读写 SRM |
| 采购单看板副本 | ERP（只读同步） | `scm_purchase_order` / `scm_purchase_order_goods` | 每日/手动同步，**仅看板统计**，禁止作为实时业务依据 |
| 采购单入库数量/状态 | **SRM** | `Sys_PurchaseOrderGoods.InboundQty`、`Sys_PurchaseOrder.InboundStatus` | 由 MES→ERP→SRM 回写 |
| 出库申请 | **ERP** | `sys_ware_house_out_apply` / `_list` | 新能力，不再进 SRM |
| 出库单 / 出库登记 | **MES** | `qxx_wm_product_sales` / `_line` | ERP 只记录 MES 单号与已出库量 |
| 入库回写台账 | **ERP** | `sys_mes_inbound_log` | 幂等与审计，SRM 不再建同类表 |
| SRM 出库单 / 库存 | SRM（历史） | `Sys_WareHouseOutBill` / `Sys_ProductStock` | 已停用，仅保留历史数据，本次不动 |

对应 SQL：

| 系统 | 文件 | 作用 |
|------|------|------|
| ERP | `doc/sql/20261123_warehouse_out_apply_mes_factory.sql` | 出库申请/明细扩展 + 本地采购单（合伙人端）字段 + 入库回写台账 |
| ERP | `doc/sql/20261123_warehouse_out_apply_source.sql` | 出库申请增加 `purchase_order_source`（LOCAL/SRM） |
| ERP | `doc/sql/20261123_warehouse_out_apply_outbound_status.sql` | 出库申请增加 `outbound_status`（PENDING/PARTIAL/DONE） |
| ERP | `doc/sql/20261123_warehouse_out_apply_order_link.sql` | 出库申请增加 `order_id/order_number`（订单级关联） |
| MES | `backend/.../db/migration/V204__sales_apply_mes_outbound.sql` | 出库申请表/行 + 出库单来源申请字段 |
| SRM | `Vue.Net6/sql/20261123_mes_factory_writeback.sql` | 采购单主表/明细的入库数量与状态（T-SQL） |

**采购单字段对齐（ERP 本地 ↔ SRM）**

为避免未来 SRM 下线时再做结构迁移，两套采购单使用同一最小字段集：

| 表 | 字段 | ERP `sys_purchase_order*` | SRM `Sys_PurchaseOrder*` |
|----|------|:---:|:---:|
| 主表 | `inbound_status` | ✅ | ✅ |
| 主表 | `inbound_qty` | ✅ | ✅ |
| 主表 | `last_inbound_time` | ✅ | ✅ |
| 主表 | `mes_order_code` | ✅ | ✅ |
| 明细 | `inbound_qty` | ✅ | ✅ |
| 明细 | `mes_order_line_id` | ✅ | ✅ |

不在采购单行冗余 `applied_qty` / `outbound_qty`：出库申请中/已出库数量统一存于 ERP 出库申请行（`applied_qty` / `posted_qty`），可申请量由「采购单行入库量 − 有效申请行占用」实时计算，避免双份数据漂移。

**写入链路（强制）**：

```
MES 入库结果 ──▶ ERP（记 sys_mes_inbound_log）──▶ SRM（更新采购单 InboundQty/InboundStatus）
MES 出库结果 ──▶ ERP（更新出库申请行 posted_qty / 行状态）
                 └─ SRM 出库单/库存不再更新
```

- MES 只允许调用 ERP 的 `/open-api/factory/**`，绝不直连 SRM。
- 平台端「可申请量」**实时调用 SRM**：`可申请 = SRM.InboundQty − ERP 申请行 Σapplied_qty`（仅 CANCELED/REJECTED 行释放占用，DONE 行仍占用）。
- 已停用方案：不再在 `scm_purchase_*` 镜像表上增加业务数量字段（曾加过的字段已回滚删除）。

### 4.4 ERP 平台端页面改造

| 页面 | 改造 | 状态 |
|------|------|------|
| 采购单详情 | 明细新增「已入库 / 申请中 / 已出库 / 可申请」列；新增「发起出库申请」按钮（仅工厂MES下发开启时展示） | ✅ 已完成 |
| 出库申请列表/编辑（`views/system/order/wareHouseOut`） | 来源筛选；MES_FACTORY 场景选 SRM 采购单 → 明细行；销售订单号随采购单带出；下发状态/MES 单号/出库状态；下发/重推/撤回 | ✅ 已完成 |
| 销售订单详情 | 履约进度增加「工厂入库 / 已出库」汇总 | ⏳ 页面汇总待做（订单状态已联动） |
| MES 协同台账 | 新增 `docType` 支持 `SALES_OUT_APPLY`、`SALES_INBOUND`，可看下发/回写日志 | ⏳ 待 P3 |

### 4.5 分阶段实施

| 阶段 | 内容 | 依赖 |
|------|------|------|
| **P0 决策** | 确认 §5 的 6 个决策点 | — |
| **P1 入库回写** | MES 入库确认后回写 ERP；ERP 记 `sys_mes_inbound_log` 并中转回写 SRM 采购单入库量/状态 | — |
| **P2 ERP 申请单改造** | 表字段 + 关联选择 + 可申请量校验 + 审核 + 下发/撤回 | P1 |
| **P3 MES 接单执行** | 接收申请 → 生成申请/出库草稿 → 分批过账 → 回写 | P2 |
| **P4 ERP 结果落账** | 申请行已出库、销售订单履约更新、完结 | P3 |
| **P5 旁路与对账** | MES 手工出库回写；日终对账报表（ERP 已出库 vs MES 出库汇总） | P3 |
| **P6 页面与权限** | ERP 前端改造、权限点、打印/导出 | P2/P4 |

---

## 5. 已确认决策（2026-11-23）

| # | 决策点 | 结论 |
|---|--------|------|
| 1 | 申请单归属 | **升级现有 `sys_ware_house_out_apply`**，通过 `source_type` 区分 MES 工厂 / 本地仓 / SRM |
| 2 | 入库回写粒度 | **按采购单行汇总 + 保留入库明细**（新增 `sys_mes_inbound_log`，唯一键 `recpt_code + external_line_id`） |
| 3 | 出库执行模型 | **一张申请对应一张 MES 出库单，支持多次过账分批出库**，累计回写 |
| 4 | 旁路直开 | **MES 手工出库单必须回写 ERP**，按 `externalOrderNo`/客户 PO 号匹配 |
| 5 | 平台端可申请量 | **实时调用 SRM**：`SRM.InboundQty − ERP 申请行有效占用`，SRM 不可用禁止建单 |
| 6 | 采购单字段对齐 | ERP 本地与 SRM 使用同一最小字段集（见 §4.3.1），便于 SRM 下线时零迁移 |

---

## 6. 涉及文件清单（实施时参考）

**ERP**
- `ruoyi-system/.../domain/SysWareHouseOutApply.java`、`SysWareHouseOutApplyList.java`、`SysMesInboundLog.java`
- `ruoyi-system/.../mapper/SysWareHouseOutApplyMapper.java`、`SysMesInboundLogMapper.java`（含 XML）
- `ruoyi-system/.../service/impl/SysWareHouseOutApplyServiceImpl.java`、`SysMesFactoryServiceImpl.java`、`SupplyChainClientService.java`
- `ruoyi-admin/.../controller/system/SysWareHouseOutApplyController.java`
- `ruoyi-admin/.../controller/open/MesFactoryCallbackController.java`
- `ruoyi-arco/src/views/system/order/wareHouseOut/**`、`api/system/wareHouseOutApply*.ts`

**SRM**
- `VOL.System/Services/System/Partial/SrmPurchaseInboundWriteBack.cs`
- `VOL.WebApi/Controllers/System/Partial/Sys_PurchaseOrderController.cs`（`WriteBackInbound`）
- `VOL.Entity/DomainModels/System/Sys_PurchaseOrder.cs`、`Sys_PurchaseOrderGoods.cs`
- `sql/20261123_mes_factory_writeback.sql`

**MES**
- `backend/ruoyi-admin/.../controller/open/SalErpOpenController.java`
- `backend/ruoyi-system/.../service/mes/sal/impl/SalOrderServiceImpl.java`
- `backend/ruoyi-system/.../service/mes/wm/impl/WmProductSalesServiceImpl.java`、`WmProductRecptServiceImpl.java`
- `backend/ruoyi-system/.../service/mes/sys/impl/SysSyncTaskServiceImpl.java`
- `backend/ruoyi-system/.../service/mes/sys/integration/{ErpClient,ErpCallbackPayload,ErpCallbackPaths}.java`
- 前端 `frontend/src/views/mes/wm/product_sales/**`、`mes/sal/order/**`

---

## 7. 实施进度

| 阶段 | 状态 | 说明 |
|------|------|------|
| P2 ERP 申请单改造 | ✅ 已完成 | 表字段、Domain、Mapper、Service 校验、可申请量接口、前端页面（来源/采购单选择/明细列）；新增 `purchase_order_source`，SRM 来源实时查询 |
| P1 入库回写 | ✅ 已完成 | ERP 接收 + `sys_mes_inbound_log`；SRM `WriteBackInbound`；MES 成品入库确认后 `WmProductRecptInboundNotifier` 发送（有工单走工单→订单行，无工单按产品编码匹配） |
| P3 MES 接单执行 | ✅ 代码完成 | ERP 下发/撤回/重推 + MES 接单生成出库草稿 + 过账回写 ERP；待重启两端联调 |
| P4 ERP 结果落账 | ✅ 已完成（订单级） | 申请行 `posted_qty`/状态已回写；按销售订单编号汇总，更新 `sys_order.fulfill_status/order_status`（采购单行可新增、不依赖订单行） |
| P5 旁路与对账 | ⏳ 部分完成 | 旁路回写 ✅：MES 手工直开出库按订单行汇总回写，ERP 自动生成已完成申请（可申请量/履约不被绕过）；**日终对账口径待定义** |
| P6 页面与权限 | ✅ 已完成 | 出库申请下发/重推/撤回/出库状态；采购单详情「已入库/申请中/已出库/可申请」列 + 发起申请入口（仅工厂MES下发开启时展示） |

**变更清单**

- ERP SQL：`doc/sql/20261123_warehouse_out_apply_mes_factory.sql`、`doc/sql/20261123_warehouse_out_apply_source.sql`（已执行）
- SRM SQL：`Vue.Net6/sql/20261123_mes_factory_writeback.sql`（待维护窗口执行）
- ERP 后端：出库申请 Domain/Mapper/Service/Controller；`SysMesInboundLog` + Mapper；`SysMesFactoryServiceImpl.purchaseInboundCallback`；`MesFactoryCallbackController` 入库回调；`SupplyChainClientService.writeBackPurchaseInboundByUser`
- SRM 后端：`SrmPurchaseInboundWriteBack.cs`、`Sys_PurchaseOrder(Goods)` 实体字段、`Sys_PurchaseOrderController.WriteBackInbound`
- ERP 前端：`views/system/order/wareHouseOut/index.vue`、`EditRecord.vue`、`api/system/wareHouseOutApply*.ts`
- ERP P3：`SysMesFactoryServiceImpl.pushOutApply/cancelOutApply/outboundCallback`、`MesFactoryCallbackController` 出库回调、`SysWareHouseOutApplyMapper/ListMapper` 新增回写方法
- MES P3：`V204__sales_apply_mes_outbound.sql`、`WmSalesApply/Line` + Mapper、`WmSalesApplyService(Impl)`、`SalErpOpenController` 出库申请接收/撤回、`WmSalesOutboundNotifier`、`ErpCallbackPaths/Payload`

> 注意：SRM 来源的可申请量依赖 SRM `Sys_PurchaseOrderGoods.InboundQty`，需先执行 SRM 脚本并重新生成实体；LOCAL 来源依赖本地 `sys_purchase_order_goods.inbound_qty`。MES 侧入库回写未接入前，入库量为 0，工厂出库申请会被拦截，属预期行为。

---

## 8. 附：与已有设计文档的关系

- MES 侧出库执行细节（过账/拣货/装箱/发运/签收）见 [`销售出库-发货流程设计.md`](销售出库-发货流程设计.md)（评审中，拣货/装箱/签收尚未实现）。
- 本文档只解决「ERP ↔ MES 协同」部分，不重复出库内部流程设计。
