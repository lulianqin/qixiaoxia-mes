package com.ruoyi.system.domain.mes.sal.dto;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * ERP 出库申请下发 → MES 接单执行
 *
 * @author qixiaoxia
 * @date 2026-11-23
 */
public class ErpOutboundApplyRequest
{
    private String sourceSystem;

    /** ERP 出库申请单号（幂等键） */
    @NotBlank(message = "出库申请单号不能为空")
    private String externalApplyNo;

    /** SRM 采购单号（= MES 销售订单 externalOrderNo） */
    @NotBlank(message = "采购单号不能为空")
    private String externalOrderNo;

    private String externalOrderId;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date requestDate;

    private String receiverName;
    private String receiverTel;
    private String receiverAddress;
    private String remark;

    @NotEmpty(message = "出库明细不能为空")
    @Valid
    private List<ErpOutboundApplyLineRequest> lines;

    public String getSourceSystem() { return sourceSystem; }
    public void setSourceSystem(String v) { this.sourceSystem = v; }
    public String getExternalApplyNo() { return externalApplyNo; }
    public void setExternalApplyNo(String v) { this.externalApplyNo = v; }
    public String getExternalOrderNo() { return externalOrderNo; }
    public void setExternalOrderNo(String v) { this.externalOrderNo = v; }
    public String getExternalOrderId() { return externalOrderId; }
    public void setExternalOrderId(String v) { this.externalOrderId = v; }
    public Date getRequestDate() { return requestDate; }
    public void setRequestDate(Date v) { this.requestDate = v; }
    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String v) { this.receiverName = v; }
    public String getReceiverTel() { return receiverTel; }
    public void setReceiverTel(String v) { this.receiverTel = v; }
    public String getReceiverAddress() { return receiverAddress; }
    public void setReceiverAddress(String v) { this.receiverAddress = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
    public List<ErpOutboundApplyLineRequest> getLines() { return lines; }
    public void setLines(List<ErpOutboundApplyLineRequest> v) { this.lines = v; }
}
