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

    /** 回写任务业务类型 */
    public static final String BIZ_ORDER_ACCEPT = "ORDER_ACCEPT";
    public static final String BIZ_ORDER_REJECT = "ORDER_REJECT";
    public static final String BIZ_QUOTE_SUBMIT = "QUOTE_SUBMIT";

    /** 目标系统 */
    public static final String SYSTEM_ERP = "ERP";
}
