package com.ruoyi.system.domain.mes.pro;

import java.util.List;

/**
 * 生产工单开单页 — 一张采购单提交体
 *
 * @author qixiaoxia
 * @date 2026-11-17
 */
public class WorkorderPurDocVO
{
    /** 已存在的采购单ID（草稿就地更新用；为空表示新增） */
    private Long orderId;
    private String docTitle;
    private Long vendorId;
    private String vendorCode;
    private String vendorName;
    private String purchaseType;
    private String orderDate;
    private String expectedDate;
    private String purchaser;
    private String sourceOrderCode;
    private String deliveryAddress;
    private String remark;
    private List<WorkorderPurLineVO> lines;

    public Long getOrderId() { return orderId; }
    public void setOrderId(Long v) { this.orderId = v; }
    public String getDocTitle() { return docTitle; }
    public void setDocTitle(String v) { this.docTitle = v; }
    public Long getVendorId() { return vendorId; }
    public void setVendorId(Long v) { this.vendorId = v; }
    public String getVendorCode() { return vendorCode; }
    public void setVendorCode(String v) { this.vendorCode = v; }
    public String getVendorName() { return vendorName; }
    public void setVendorName(String v) { this.vendorName = v; }
    public String getPurchaseType() { return purchaseType; }
    public void setPurchaseType(String v) { this.purchaseType = v; }
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
    public List<WorkorderPurLineVO> getLines() { return lines; }
    public void setLines(List<WorkorderPurLineVO> v) { this.lines = v; }
}
