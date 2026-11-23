package com.ruoyi.system.domain.mes.wm;

import java.math.BigDecimal;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * ERP 工厂出库申请明细 qxx_wm_sales_apply_line
 *
 * @author qixiaoxia
 * @date 2026-11-23
 */
public class WmSalesApplyLine extends BaseEntity
{
    private Long lineId;
    private Long factoryId;
    private Long applyId;

    /** ERP采购单明细ID（=SRM PurchaseOrderGoodsId，也等于 MES 销售订单行 externalLineId） */
    private String externalLineId;

    private Long salesOrderLineId;
    private Long itemId;
    private String itemCode;
    private String itemName;
    private String unitOfMeasure;
    private String unitName;
    private BigDecimal applyQty;
    private BigDecimal postedQty;
    private String lineStatus;
    private String remark;

    public Long getLineId() { return lineId; }
    public void setLineId(Long v) { this.lineId = v; }
    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long v) { this.factoryId = v; }
    public Long getApplyId() { return applyId; }
    public void setApplyId(Long v) { this.applyId = v; }
    public String getExternalLineId() { return externalLineId; }
    public void setExternalLineId(String v) { this.externalLineId = v; }
    public Long getSalesOrderLineId() { return salesOrderLineId; }
    public void setSalesOrderLineId(Long v) { this.salesOrderLineId = v; }
    public Long getItemId() { return itemId; }
    public void setItemId(Long v) { this.itemId = v; }
    public String getItemCode() { return itemCode; }
    public void setItemCode(String v) { this.itemCode = v; }
    public String getItemName() { return itemName; }
    public void setItemName(String v) { this.itemName = v; }
    public String getUnitOfMeasure() { return unitOfMeasure; }
    public void setUnitOfMeasure(String v) { this.unitOfMeasure = v; }
    public String getUnitName() { return unitName; }
    public void setUnitName(String v) { this.unitName = v; }
    public BigDecimal getApplyQty() { return applyQty; }
    public void setApplyQty(BigDecimal v) { this.applyQty = v; }
    public BigDecimal getPostedQty() { return postedQty; }
    public void setPostedQty(BigDecimal v) { this.postedQty = v; }
    public String getLineStatus() { return lineStatus; }
    public void setLineStatus(String v) { this.lineStatus = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
}
