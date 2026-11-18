package com.ruoyi.system.domain.mes.pro;

import java.math.BigDecimal;
import java.util.Map;

/**
 * 生产工单开单页 — 加工单工序行提交体
 *
 * @author qixiaoxia
 * @date 2026-11-17
 */
public class WorkorderProcLineVO
{
    private Long processId;
    private String processCode;
    private String processName;
    private BigDecimal planQty;
    private BigDecimal unitPrice;
    private String expectedDate;
    private Long vendorId;
    private String vendorCode;
    private String vendorName;
    /** 工序扩展属性（按工序属性模板） */
    private Map<String, Object> extAttrs;
    private String remark;

    public Long getProcessId() { return processId; }
    public void setProcessId(Long v) { this.processId = v; }
    public String getProcessCode() { return processCode; }
    public void setProcessCode(String v) { this.processCode = v; }
    public String getProcessName() { return processName; }
    public void setProcessName(String v) { this.processName = v; }
    public BigDecimal getPlanQty() { return planQty; }
    public void setPlanQty(BigDecimal v) { this.planQty = v; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal v) { this.unitPrice = v; }
    public String getExpectedDate() { return expectedDate; }
    public void setExpectedDate(String v) { this.expectedDate = v; }
    public Long getVendorId() { return vendorId; }
    public void setVendorId(Long v) { this.vendorId = v; }
    public String getVendorCode() { return vendorCode; }
    public void setVendorCode(String v) { this.vendorCode = v; }
    public String getVendorName() { return vendorName; }
    public void setVendorName(String v) { this.vendorName = v; }
    public Map<String, Object> getExtAttrs() { return extAttrs; }
    public void setExtAttrs(Map<String, Object> v) { this.extAttrs = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
}
