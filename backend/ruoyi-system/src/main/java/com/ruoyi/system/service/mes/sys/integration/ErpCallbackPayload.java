package com.ruoyi.system.service.mes.sys.integration;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.system.domain.mes.sal.SalOrder;
import com.ruoyi.system.domain.mes.sal.SalOrderLine;
import com.ruoyi.system.domain.mes.sal.SalQuote;
import com.ruoyi.system.domain.mes.sal.SalQuoteLine;

/**
 * ERP 回写报文构造器
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class ErpCallbackPayload
{
    private ErpCallbackPayload() { }

    /** 接单回写 */
    public static String orderAccept(SalOrder order, List<SalOrderLine> lines, String operator)
    {
        Map<String, Object> m = baseOrder(order, "ACCEPT", operator);
        m.put("acceptTime", DateUtils.parseDateToStr(DateUtils.YYYY_MM_DD_HH_MM_SS, new Date()));
        if (lines != null && !lines.isEmpty())
        {
            List<Map<String, Object>> rows = new ArrayList<>();
            for (SalOrderLine line : lines)
            {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("externalLineId", line.getExternalLineId());
                row.put("lineNo", line.getLineNo());
                row.put("requestDate", line.getRequestDate() == null ? null
                        : DateUtils.parseDateToStr(DateUtils.YYYY_MM_DD, line.getRequestDate()));
                rows.add(row);
            }
            m.put("lines", rows);
        }
        return JSON.toJSONString(m);
    }

    /** 打回回写 */
    public static String orderReject(SalOrder order, String reason, String operator)
    {
        Map<String, Object> m = baseOrder(order, "REJECT", operator);
        m.put("rejectTime", DateUtils.parseDateToStr(DateUtils.YYYY_MM_DD_HH_MM_SS, new Date()));
        m.put("rejectReason", reason);
        return JSON.toJSONString(m);
    }

    private static Map<String, Object> baseOrder(SalOrder order, String action, String operator)
    {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("externalOrderNo", order.getExternalOrderNo());
        m.put("externalOrderId", order.getExternalOrderId());
        m.put("mesOrderId", order.getOrderId());
        m.put("mesOrderCode", order.getOrderCode());
        m.put("action", action);
        m.put("requestDate", order.getRequestDate() == null ? null
                : DateUtils.parseDateToStr(DateUtils.YYYY_MM_DD, order.getRequestDate()));
        m.put("operator", operator);
        return m;
    }

    /** 出库结果回写 */
    public static String outboundResult(Long applyId, String applyCode, Long salesId, String salesCode,
                                        String status, List<Map<String, Object>> lines)
    {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("externalApplyNo", applyCode);
        m.put("mesApplyId", applyId);
        m.put("mesSalesId", salesId);
        m.put("mesSalesCode", salesCode);
        m.put("status", status);
        m.put("outboundTime", DateUtils.parseDateToStr(DateUtils.YYYY_MM_DD_HH_MM_SS, new Date()));
        m.put("lines", lines == null ? new ArrayList<>() : lines);
        return JSON.toJSONString(m);
    }

    /** 手工直开出库结果回写（旁路：无 ERP 出库申请，按采购单号/订单号回写） */
    public static String manualOutboundResult(String externalOrderNo, String orderNumber,
                                              Long salesId, String salesCode,
                                              String status, List<Map<String, Object>> lines)
    {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("externalOrderNo", externalOrderNo);
        m.put("orderNumber", orderNumber);
        m.put("mesSalesId", salesId);
        m.put("mesSalesCode", salesCode);
        m.put("status", status);
        m.put("outboundTime", DateUtils.parseDateToStr(DateUtils.YYYY_MM_DD_HH_MM_SS, new Date()));
        m.put("lines", lines == null ? new ArrayList<>() : lines);
        return JSON.toJSONString(m);
    }

    /** 报价回写 */
    public static String quoteSubmit(SalQuote quote, List<SalQuoteLine> lines)
    {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("externalQuoteNo", quote.getExternalQuoteNo());
        m.put("externalQuoteId", quote.getExternalQuoteId());
        m.put("mesQuoteId", quote.getQuoteId());
        m.put("mesQuoteCode", quote.getQuoteCode());
        m.put("action", "QUOTED");
        m.put("quoteTime", DateUtils.parseDateToStr(DateUtils.YYYY_MM_DD_HH_MM_SS, new Date()));
        m.put("quoteUser", quote.getQuoteUser());
        m.put("totalAmount", quote.getTotalAmount());
        m.put("remark", quote.getRemark());
        List<Map<String, Object>> rows = new ArrayList<>();
        if (lines != null)
        {
            for (SalQuoteLine line : lines)
            {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("externalLineId", line.getExternalLineId());
                row.put("lineNo", line.getLineNo());
                row.put("productCode", line.getProductCode());
                // price / quoteRemark 为旧字段名，保留兼容；ERP 回写按单价×数量算行金额
                row.put("price", line.getPrice());
                row.put("unitPrice", line.getPrice());
                row.put("quantity", line.getQuantity());
                row.put("unit", line.getUnit());
                BigDecimal qty = line.getQuantity() == null ? BigDecimal.ONE : line.getQuantity();
                row.put("totalPrice", line.getPrice() == null ? null : line.getPrice().multiply(qty));
                row.put("quoteRemark", line.getQuoteRemark());
                row.put("produceRemark", line.getQuoteRemark());
                row.put("deliveryDate", line.getDeliveryDate());
                row.put("quoteValidDate", line.getQuoteValidDate() == null ? null
                        : DateUtils.parseDateToStr(DateUtils.YYYY_MM_DD, line.getQuoteValidDate()));
                rows.add(row);
            }
        }
        m.put("lines", rows);
        return JSON.toJSONString(m);
    }
}
