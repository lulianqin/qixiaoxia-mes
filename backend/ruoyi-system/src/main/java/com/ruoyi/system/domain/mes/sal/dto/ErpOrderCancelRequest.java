package com.ruoyi.system.domain.mes.sal.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * ERP 撤回下发 → MES 作废销售订单请求
 *
 * @author qixiaoxia
 * @date 2026-11-23
 */
public class ErpOrderCancelRequest
{
    /** ERP 采购单号（幂等键，与下发时一致） */
    @NotBlank(message = "ERP采购单号不能为空")
    private String externalOrderNo;

    /** 撤回原因（写入状态变更留痕） */
    private String reason;

    public String getExternalOrderNo() { return externalOrderNo; }
    public void setExternalOrderNo(String v) { this.externalOrderNo = v; }
    public String getReason() { return reason; }
    public void setReason(String v) { this.reason = v; }
}
