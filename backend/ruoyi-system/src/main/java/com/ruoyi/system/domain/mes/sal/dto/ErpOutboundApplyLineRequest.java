package com.ruoyi.system.domain.mes.sal.dto;

import java.math.BigDecimal;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * ERP 出库申请明细
 *
 * @author qixiaoxia
 * @date 2026-11-23
 */
public class ErpOutboundApplyLineRequest
{
    /** ERP 申请行号 */
    private String externalApplyLineId;

    /** ERP 采购单明细ID（= SRM PurchaseOrderGoodsId） */
    @NotBlank(message = "采购单明细ID不能为空")
    private String externalLineId;

    private String itemCode;

    @NotNull(message = "申请数量不能为空")
    private BigDecimal applyQty;

    private String warehouseCode;
    private String remark;

    public String getExternalApplyLineId() { return externalApplyLineId; }
    public void setExternalApplyLineId(String v) { this.externalApplyLineId = v; }
    public String getExternalLineId() { return externalLineId; }
    public void setExternalLineId(String v) { this.externalLineId = v; }
    public String getItemCode() { return itemCode; }
    public void setItemCode(String v) { this.itemCode = v; }
    public BigDecimal getApplyQty() { return applyQty; }
    public void setApplyQty(BigDecimal v) { this.applyQty = v; }
    public String getWarehouseCode() { return warehouseCode; }
    public void setWarehouseCode(String v) { this.warehouseCode = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
}
