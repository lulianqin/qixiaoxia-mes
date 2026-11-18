package com.ruoyi.system.domain.mes.pro;

import java.util.List;

/**
 * 生产工单开单页 — 一张加工单提交体
 *
 * @author qixiaoxia
 * @date 2026-11-17
 */
public class WorkorderProcDocVO
{
    private String docTitle;
    /** INSIDE-厂内 / OUTSIDE-外协 */
    private String supplierType;
    private Long vendorId;
    private String vendorCode;
    private String vendorName;
    private String orderDate;
    private String expectedDate;
    private String purchaser;
    private String sourceOrderCode;
    private String deliveryAddress;
    private String remark;
    private List<WorkorderProcLineVO> lines;

    public String getDocTitle() { return docTitle; }
    public void setDocTitle(String v) { this.docTitle = v; }
    public String getSupplierType() { return supplierType; }
    public void setSupplierType(String v) { this.supplierType = v; }
    public Long getVendorId() { return vendorId; }
    public void setVendorId(Long v) { this.vendorId = v; }
    public String getVendorCode() { return vendorCode; }
    public void setVendorCode(String v) { this.vendorCode = v; }
    public String getVendorName() { return vendorName; }
    public void setVendorName(String v) { this.vendorName = v; }
    public String getOrderDate() { return orderDate; }
    public void setOrderDate(String v) { this.orderDate = v; }
    public String getExpectedDate() { return expectedDate; }
    public void setExpectedDate(String v) { this.expectedDate = v; }
    public String getPurchaser() { return purchaser; }
    public void setPurchaser(String v) { this.purchaser = v; }
    public String getSourceOrderCode() { return sourceOrderCode; }
    public void setSourceOrderCode(String v) { this.sourceOrderCode = v; }
    public String getDeliveryAddress() { return deliveryAddress; }
    public void setDeliveryAddress(String v) { this.deliveryAddress = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
    public List<WorkorderProcLineVO> getLines() { return lines; }
    public void setLines(List<WorkorderProcLineVO> v) { this.lines = v; }
}
