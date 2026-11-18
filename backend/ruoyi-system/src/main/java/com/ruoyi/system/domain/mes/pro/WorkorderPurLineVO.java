package com.ruoyi.system.domain.mes.pro;

import java.math.BigDecimal;
import java.util.Map;

/**
 * 生产工单开单页 — 采购单明细行提交体
 *
 * @author qixiaoxia
 * @date 2026-11-17
 */
public class WorkorderPurLineVO
{
    private Long itemId;
    private String itemCode;
    private String itemName;
    /** 产品名称（导出第一列，可编辑） */
    private String productName;
    private String specification;
    private String unitOfMeasure;
    private String unitName;
    private BigDecimal quantity;
    private BigDecimal unitPrice;
    private BigDecimal taxRate;
    private String expectedDate;
    /** 关联工序（可空：采购单可直接挂工单，不挂工序） */
    private Long processId;
    private String processCode;
    private String processName;
    /** 行扩展属性（品牌等） */
    private Map<String, Object> lineAttrs;
    private String remark;

    public Long getItemId() { return itemId; }
    public void setItemId(Long v) { this.itemId = v; }
    public String getItemCode() { return itemCode; }
    public void setItemCode(String v) { this.itemCode = v; }
    public String getItemName() { return itemName; }
    public void setItemName(String v) { this.itemName = v; }
    public String getProductName() { return productName; }
    public void setProductName(String v) { this.productName = v; }
    public String getSpecification() { return specification; }
    public void setSpecification(String v) { this.specification = v; }
    public String getUnitOfMeasure() { return unitOfMeasure; }
    public void setUnitOfMeasure(String v) { this.unitOfMeasure = v; }
    public String getUnitName() { return unitName; }
    public void setUnitName(String v) { this.unitName = v; }
    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal v) { this.quantity = v; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal v) { this.unitPrice = v; }
    public BigDecimal getTaxRate() { return taxRate; }
    public void setTaxRate(BigDecimal v) { this.taxRate = v; }
    public String getExpectedDate() { return expectedDate; }
    public void setExpectedDate(String v) { this.expectedDate = v; }
    public Long getProcessId() { return processId; }
    public void setProcessId(Long v) { this.processId = v; }
    public String getProcessCode() { return processCode; }
    public void setProcessCode(String v) { this.processCode = v; }
    public String getProcessName() { return processName; }
    public void setProcessName(String v) { this.processName = v; }
    public Map<String, Object> getLineAttrs() { return lineAttrs; }
    public void setLineAttrs(Map<String, Object> v) { this.lineAttrs = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
}
