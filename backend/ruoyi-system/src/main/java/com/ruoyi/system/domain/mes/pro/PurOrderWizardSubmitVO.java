package com.ruoyi.system.domain.mes.pro;

import java.util.Date;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * 采购单快捷创建向导提交体 — 采购单主表信息 + 物料行（统一供应商，生成一张采购单）
 *
 * @author qixiaoxia
 * @date 2026-11-17
 */
public class PurOrderWizardSubmitVO
{
    /** 单据编号（为空时后端自动生成） */
    private String orderCode;
    /** 单据名称 */
    private String orderName;
    /** 供应商 */
    private Long vendorId;
    private String vendorCode;
    private String vendorName;
    /** 采购类型 */
    private String purchaseType;
    /** 下单日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date orderDate;
    /** 预计到货日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date expectedDate;
    /** 采购人 */
    private String purchaser;
    /** 关联客户订单号 */
    private String sourceOrderCode;
    /** 币种 */
    private String currency;
    /** 备注 */
    private String remark;
    /** 物料行 */
    private List<PurOrderWizardLineVO> lines;

    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String v) { this.orderCode = v; }
    public String getOrderName() { return orderName; }
    public void setOrderName(String v) { this.orderName = v; }
    public Long getVendorId() { return vendorId; }
    public void setVendorId(Long v) { this.vendorId = v; }
    public String getVendorCode() { return vendorCode; }
    public void setVendorCode(String v) { this.vendorCode = v; }
    public String getVendorName() { return vendorName; }
    public void setVendorName(String v) { this.vendorName = v; }
    public String getPurchaseType() { return purchaseType; }
    public void setPurchaseType(String v) { this.purchaseType = v; }
    public Date getOrderDate() { return orderDate; }
    public void setOrderDate(Date v) { this.orderDate = v; }
    public Date getExpectedDate() { return expectedDate; }
    public void setExpectedDate(Date v) { this.expectedDate = v; }
    public String getPurchaser() { return purchaser; }
    public void setPurchaser(String v) { this.purchaser = v; }
    public String getSourceOrderCode() { return sourceOrderCode; }
    public void setSourceOrderCode(String v) { this.sourceOrderCode = v; }
    public String getCurrency() { return currency; }
    public void setCurrency(String v) { this.currency = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
    public List<PurOrderWizardLineVO> getLines() { return lines; }
    public void setLines(List<PurOrderWizardLineVO> v) { this.lines = v; }
}
