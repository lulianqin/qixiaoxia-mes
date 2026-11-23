package com.ruoyi.system.service.mes.sys.integration;

/**
 * ERP 回写接口路径常量
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class ErpCallbackPaths
{
    /** 采购单接单/打回回写 */
    public static final String PURCHASE_ACCEPT = "/open-api/factory/purchase/accept-callback";

    /** 报价单报价回写 */
    public static final String QUOTATION_QUOTE = "/open-api/factory/quotation/quote-callback";

    /** 采购单入库回写 */
    public static final String PURCHASE_INBOUND = "/open-api/factory/purchase/inbound-callback";

    /** 销售出库结果回写 */
    public static final String SALES_OUTBOUND = "/open-api/factory/sales/outbound-callback";

    /** 回写任务业务类型 */
    public static final String BIZ_ORDER_ACCEPT = "ORDER_ACCEPT";
    public static final String BIZ_ORDER_REJECT = "ORDER_REJECT";
    public static final String BIZ_QUOTE_SUBMIT = "QUOTE_SUBMIT";
    /** 入库回写（预留，MES 侧发送时使用） */
    public static final String BIZ_INBOUND_SYNC = "INBOUND_SYNC";
    /** 出库结果回写 */
    public static final String BIZ_OUTBOUND_RESULT = "OUTBOUND_RESULT";

    /** 目标系统 */
    public static final String SYSTEM_ERP = "ERP";
}
