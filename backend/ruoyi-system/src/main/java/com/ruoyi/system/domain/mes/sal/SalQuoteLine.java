package com.ruoyi.system.domain.mes.sal;

import java.math.BigDecimal;
import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 销售报价需求单明细对象 qxx_sal_quote_line
 * 报价商品可能尚未建立 MES 物料档案, 因此产品信息以文本快照保存
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class SalQuoteLine extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long lineId;
    private Long factoryId;
    private Long quoteId;
    private Integer lineNo;
    private String externalLineId;

    @Excel(name = "产品编码")
    private String productCode;

    @Excel(name = "产品名称")
    private String productName;

    /** 物料ID（按名称匹配 md_item，未匹配为空） */
    private Long productId;

    private String productPhoto;
    private String productSize;
    private String structure;
    private String material;
    private String printingMode;
    private String processTxt;
    private String accessoryTxt;

    @Excel(name = "数量")
    private BigDecimal quantity;

    @Excel(name = "单位")
    private String unit;

    @Excel(name = "报价单价")
    private BigDecimal price;

    @Excel(name = "报价备注")
    private String quoteRemark;

    @Excel(name = "交期说明")
    private String deliveryDate;

    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "报价有效期", width = 30, dateFormat = "yyyy-MM-dd")
    private Date quoteValidDate;

    /** 客户需求备注(ERP下发) */
    private String remark;

    public Long getLineId() { return lineId; }
    public void setLineId(Long v) { this.lineId = v; }
    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long v) { this.factoryId = v; }
    public Long getQuoteId() { return quoteId; }
    public void setQuoteId(Long v) { this.quoteId = v; }
    public Integer getLineNo() { return lineNo; }
    public void setLineNo(Integer v) { this.lineNo = v; }
    public String getExternalLineId() { return externalLineId; }
    public void setExternalLineId(String v) { this.externalLineId = v; }
    public String getProductCode() { return productCode; }
    public void setProductCode(String v) { this.productCode = v; }
    public String getProductName() { return productName; }
    public void setProductName(String v) { this.productName = v; }
    public Long getProductId() { return productId; }
    public void setProductId(Long v) { this.productId = v; }
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
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal v) { this.price = v; }
    public String getQuoteRemark() { return quoteRemark; }
    public void setQuoteRemark(String v) { this.quoteRemark = v; }
    public String getDeliveryDate() { return deliveryDate; }
    public void setDeliveryDate(String v) { this.deliveryDate = v; }
    public Date getQuoteValidDate() { return quoteValidDate; }
    public void setQuoteValidDate(Date v) { this.quoteValidDate = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
}
