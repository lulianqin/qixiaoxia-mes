package com.ruoyi.system.domain.mes.sal.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 销售订单打回请求
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class SalOrderRejectRequest
{
    @NotBlank(message = "打回原因不能为空")
    private String reason;

    public String getReason() { return reason; }
    public void setReason(String v) { this.reason = v; }
}
