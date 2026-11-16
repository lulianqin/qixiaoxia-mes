package com.ruoyi.system.domain.mes.sal.dto;

/**
 * 销售订单人工改状态请求（一期弱化流程）
 *
 * @author qixiaoxia
 */
public class SalOrderChangeStatusRequest
{
    /** 销售订单ID */
    private Long orderId;

    /** 目标状态，取值见 SalOrderStatus */
    private String targetStatus;

    /** 变更原因（可空） */
    private String reason;

    public Long getOrderId() { return orderId; }
    public void setOrderId(Long v) { this.orderId = v; }
    public String getTargetStatus() { return targetStatus; }
    public void setTargetStatus(String v) { this.targetStatus = v; }
    public String getReason() { return reason; }
    public void setReason(String v) { this.reason = v; }
}
