package com.ruoyi.system.domain.mes.sal.dto;

import java.math.BigDecimal;
import java.util.Date;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * ERP 采购单明细行
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class ErpOrderLineRequest
{
    /** ERP 明细行ID/行号 */
    private String externalLineId;

    /** ERP 产品编码 */
    private String productCode;

    /** MES 物料编码(优先使用,其次走映射表) */
    private String mesItemCode;

    private String productName;
    private String productSpec;

    /** 产品图片（ERP 采购单明细 ProductPhoto，已由 ERP 补齐完整域名） */
    private String productPhoto;

    /** 材质及工艺（ERP Material），映射到 MES 印刷要求 */
    private String material;

    /** 包装方式（ERP PackingModeTxt），映射到 MES 包装要求 */
    private String packingModeTxt;

    private String unit;

    @NotNull(message = "明细数量不能为空")
    @DecimalMin(value = "0.0001", message = "明细数量必须大于0")
    private BigDecimal quantity;

    private BigDecimal unitPrice;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date requestDate;

    private String productSize;
    private String printingReq;
    private String packageReq;
    private String shippingReq;
    private String remark;

    public String getExternalLineId() { return externalLineId; }
    public void setExternalLineId(String v) { this.externalLineId = v; }
    public String getProductCode() { return productCode; }
    public void setProductCode(String v) { this.productCode = v; }
    public String getMesItemCode() { return mesItemCode; }
    public void setMesItemCode(String v) { this.mesItemCode = v; }
    public String getProductName() { return productName; }
    public void setProductName(String v) { this.productName = v; }
    public String getProductSpec() { return productSpec; }
    public void setProductSpec(String v) { this.productSpec = v; }
    public String getProductPhoto() { return productPhoto; }
    public void setProductPhoto(String v) { this.productPhoto = v; }
    public String getMaterial() { return material; }
    public void setMaterial(String v) { this.material = v; }
    public String getPackingModeTxt() { return packingModeTxt; }
    public void setPackingModeTxt(String v) { this.packingModeTxt = v; }
    public String getUnit() { return unit; }
    public void setUnit(String v) { this.unit = v; }
    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal v) { this.quantity = v; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal v) { this.unitPrice = v; }
    public Date getRequestDate() { return requestDate; }
    public void setRequestDate(Date v) { this.requestDate = v; }
    public String getProductSize() { return productSize; }
    public void setProductSize(String v) { this.productSize = v; }
    public String getPrintingReq() { return printingReq; }
    public void setPrintingReq(String v) { this.printingReq = v; }
    public String getPackageReq() { return packageReq; }
    public void setPackageReq(String v) { this.packageReq = v; }
    public String getShippingReq() { return shippingReq; }
    public void setShippingReq(String v) { this.shippingReq = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
}
