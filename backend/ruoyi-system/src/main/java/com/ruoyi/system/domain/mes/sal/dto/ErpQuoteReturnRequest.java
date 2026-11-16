package com.ruoyi.system.domain.mes.sal.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * ERP 退回报价需求请求
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class ErpQuoteReturnRequest
{
    @NotBlank(message = "ERP报价单号不能为空")
    private String externalQuoteNo;

    private String reason;

    public String getExternalQuoteNo() { return externalQuoteNo; }
    public void setExternalQuoteNo(String v) { this.externalQuoteNo = v; }
    public String getReason() { return reason; }
    public void setReason(String v) { this.reason = v; }
}
