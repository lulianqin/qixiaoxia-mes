package com.ruoyi.system.domain.mes.sal.dto;

import java.math.BigDecimal;

/**
 * ERP 报价需求明细行
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class ErpQuoteLineRequest
{
    private String externalLineId;
    private String productCode;
    private String productName;
    private String productPhoto;
    private String productSize;
    private String structure;
    private String material;
    private String printingMode;
    private String processTxt;
    private String accessoryTxt;
    private BigDecimal quantity;
    private String unit;
    private String remark;

    public String getExternalLineId() { return externalLineId; }
    public void setExternalLineId(String v) { this.externalLineId = v; }
    public String getProductCode() { return productCode; }
    public void setProductCode(String v) { this.productCode = v; }
    public String getProductName() { return productName; }
    public void setProductName(String v) { this.productName = v; }
    public String getProductPhoto() { return productPhoto; }
    public void setProductPhoto(String v) { this.productPhoto = v; }
    public String getProductSize() { return productSize; }
    public void setProductSize(String v) { this.productSize = v; }
    public String getStructure() { return structure; }
    public void setStructure(String v) { this.structure = v; }
    public String getMaterial() { return material; }
    public void setMaterial(String v) { this.material = v; }
    public String getPrintingMode() { return printingMode; }
    public void setPrintingMode(String v) { this.printingMode = v; }
    public String getProcessTxt() { return processTxt; }
    public void setProcessTxt(String v) { this.processTxt = v; }
    public String getAccessoryTxt() { return accessoryTxt; }
    public void setAccessoryTxt(String v) { this.accessoryTxt = v; }
    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal v) { this.quantity = v; }
    public String getUnit() { return unit; }
    public void setUnit(String v) { this.unit = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
}
