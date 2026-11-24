package com.ruoyi.system.domain.mes.sal.dto;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * ERP 下发采购单 → MES 销售订单请求
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class ErpOrderReceiveRequest
{
    /** 来源系统,默认 ERP */
    private String sourceSystem;

    /** ERP 采购单ID */
    private String externalOrderId;

    /** ERP 采购单号(幂等键) */
    @NotBlank(message = "ERP采购单号不能为空")
    private String externalOrderNo;

    /** 外部单据版本,重发时递增 */
    private Integer externalVersion;

    /** 源订单类型（SRM 订单 Type，字典 sys订单类型：0未知 1新单 2翻单 3异常单 4打样） */
    private String sourceOrderType;

    @NotBlank(message = "订单名称不能为空")
    private String orderName;

    /** 客户编码(ERP) */
    private String clientCode;

    @NotBlank(message = "客户名称不能为空")
    private String clientName;

    /** 客户PO号 */
    private String clientOrderCode;

    /** ERP 采购单供方名称（用于匹配 MES 签约主体 sys_company） */
    private String supplierName;

    private String salesperson;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date orderDate;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date requestDate;

    private BigDecimal totalAmount;

    private String paymentMethod;

    private String remark;

    @NotEmpty(message = "明细行不能为空")
    @Valid
    private List<ErpOrderLineRequest> lines;

    public String getSourceSystem() { return sourceSystem; }
    public void setSourceSystem(String v) { this.sourceSystem = v; }
    public String getExternalOrderId() { return externalOrderId; }
    public void setExternalOrderId(String v) { this.externalOrderId = v; }
    public String getExternalOrderNo() { return externalOrderNo; }
    public void setExternalOrderNo(String v) { this.externalOrderNo = v; }
    public Integer getExternalVersion() { return externalVersion; }
    public void setExternalVersion(Integer v) { this.externalVersion = v; }
    public String getSourceOrderType() { return sourceOrderType; }
    public void setSourceOrderType(String v) { this.sourceOrderType = v; }
    public String getOrderName() { return orderName; }
    public void setOrderName(String v) { this.orderName = v; }
    public String getClientCode() { return clientCode; }
    public void setClientCode(String v) { this.clientCode = v; }
    public String getClientName() { return clientName; }
    public void setClientName(String v) { this.clientName = v; }
    public String getClientOrderCode() { return clientOrderCode; }
    public void setClientOrderCode(String v) { this.clientOrderCode = v; }
    public String getSupplierName() { return supplierName; }
    public void setSupplierName(String v) { this.supplierName = v; }
    public String getSalesperson() { return salesperson; }
    public void setSalesperson(String v) { this.salesperson = v; }
    public Date getOrderDate() { return orderDate; }
    public void setOrderDate(Date v) { this.orderDate = v; }
    public Date getRequestDate() { return requestDate; }
    public void setRequestDate(Date v) { this.requestDate = v; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal v) { this.totalAmount = v; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String v) { this.paymentMethod = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
    public List<ErpOrderLineRequest> getLines() { return lines; }
    public void setLines(List<ErpOrderLineRequest> v) { this.lines = v; }
}
