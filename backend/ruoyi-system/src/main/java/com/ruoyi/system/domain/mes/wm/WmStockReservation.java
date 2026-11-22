package com.ruoyi.system.domain.mes.wm;

import com.ruoyi.common.core.domain.BaseEntity;

import java.math.BigDecimal;
import java.util.Date;

/**
 * 库存预占明细（备货占用）。
 *
 * <p>一行代表“某个工单/销售单需要某物料，已从某库存行预占多少”。
 * quantity_locked 由本表驱动，用于回答“锁定的库存分别属于哪些订单/工单”。</p>
 *
 * @author qixiaoxia
 * @date 2026-11-20
 */
public class WmStockReservation extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 预占明细ID */
    private Long reservationId;

    /** 工厂ID */
    private Long factoryId;

    /** 库存记录ID */
    private Long materialStockId;

    /** 物料ID */
    private Long itemId;

    /** 物料编码 */
    private String itemCode;

    /** 物料名称 */
    private String itemName;

    /** 规格型号 */
    private String specification;

    /** 主单位编码 */
    private String unitOfMeasure;

    /** 主单位名称 */
    private String unitName;

    /** 仓库ID */
    private Long warehouseId;

    /** 仓库编码 */
    private String warehouseCode;

    /** 仓库名称 */
    private String warehouseName;

    /** 批次ID */
    private Long batchId;

    /** 批次编码 */
    private String batchCode;

    /** 生产工单ID */
    private Long workorderId;

    /** 生产工单编码 */
    private String workorderCode;

    /** 生产工单名称 */
    private String workorderName;

    /** 销售订单ID */
    private Long salesOrderId;

    /** 销售订单行ID */
    private Long salesOrderLineId;

    /** 来源单据类型（PRODUCT_SALES 等） */
    private String sourceDocType;

    /** 来源单据ID */
    private Long sourceDocId;

    /** 来源单据编码 */
    private String sourceDocCode;

    /** 来源单据行ID */
    private Long sourceLineId;

    /** 已转入的领料单ID */
    private Long issueId;

    /** 已转入的领料单编码 */
    private String issueCode;

    /** 来源类型 */
    private String sourceType;

    /** 需求数量 */
    private BigDecimal demandQty;

    /** 当前有效预占数量 */
    private BigDecimal reservedQty;

    /** 已消耗/已发料数量 */
    private BigDecimal consumedQty;

    /** 已释放/已转移数量 */
    private BigDecimal releasedQty;

    /** 已转领料单未消耗数量 */
    private BigDecimal transferredQty;

    /** 需求日期 */
    private Date demandDate;

    /** 状态 */
    private String status;

    public Long getReservationId() { return reservationId; }
    public void setReservationId(Long reservationId) { this.reservationId = reservationId; }

    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long factoryId) { this.factoryId = factoryId; }

    public Long getMaterialStockId() { return materialStockId; }
    public void setMaterialStockId(Long materialStockId) { this.materialStockId = materialStockId; }

    public Long getItemId() { return itemId; }
    public void setItemId(Long itemId) { this.itemId = itemId; }

    public String getItemCode() { return itemCode; }
    public void setItemCode(String itemCode) { this.itemCode = itemCode; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public String getSpecification() { return specification; }
    public void setSpecification(String specification) { this.specification = specification; }

    public String getUnitOfMeasure() { return unitOfMeasure; }
    public void setUnitOfMeasure(String unitOfMeasure) { this.unitOfMeasure = unitOfMeasure; }

    public String getUnitName() { return unitName; }
    public void setUnitName(String unitName) { this.unitName = unitName; }

    public Long getWarehouseId() { return warehouseId; }
    public void setWarehouseId(Long warehouseId) { this.warehouseId = warehouseId; }

    public String getWarehouseCode() { return warehouseCode; }
    public void setWarehouseCode(String warehouseCode) { this.warehouseCode = warehouseCode; }

    public String getWarehouseName() { return warehouseName; }
    public void setWarehouseName(String warehouseName) { this.warehouseName = warehouseName; }

    public Long getBatchId() { return batchId; }
    public void setBatchId(Long batchId) { this.batchId = batchId; }

    public String getBatchCode() { return batchCode; }
    public void setBatchCode(String batchCode) { this.batchCode = batchCode; }

    public Long getWorkorderId() { return workorderId; }
    public void setWorkorderId(Long workorderId) { this.workorderId = workorderId; }

    public String getWorkorderCode() { return workorderCode; }
    public void setWorkorderCode(String workorderCode) { this.workorderCode = workorderCode; }

    public String getWorkorderName() { return workorderName; }
    public void setWorkorderName(String workorderName) { this.workorderName = workorderName; }

    public Long getSalesOrderId() { return salesOrderId; }
    public void setSalesOrderId(Long salesOrderId) { this.salesOrderId = salesOrderId; }

    public Long getSalesOrderLineId() { return salesOrderLineId; }
    public void setSalesOrderLineId(Long salesOrderLineId) { this.salesOrderLineId = salesOrderLineId; }

    public String getSourceDocType() { return sourceDocType; }
    public void setSourceDocType(String sourceDocType) { this.sourceDocType = sourceDocType; }

    public Long getSourceDocId() { return sourceDocId; }
    public void setSourceDocId(Long sourceDocId) { this.sourceDocId = sourceDocId; }

    public String getSourceDocCode() { return sourceDocCode; }
    public void setSourceDocCode(String sourceDocCode) { this.sourceDocCode = sourceDocCode; }

    public Long getSourceLineId() { return sourceLineId; }
    public void setSourceLineId(Long sourceLineId) { this.sourceLineId = sourceLineId; }

    public Long getIssueId() { return issueId; }
    public void setIssueId(Long issueId) { this.issueId = issueId; }

    public String getIssueCode() { return issueCode; }
    public void setIssueCode(String issueCode) { this.issueCode = issueCode; }

    public String getSourceType() { return sourceType; }
    public void setSourceType(String sourceType) { this.sourceType = sourceType; }

    public BigDecimal getDemandQty() { return demandQty; }
    public void setDemandQty(BigDecimal demandQty) { this.demandQty = demandQty; }

    public BigDecimal getReservedQty() { return reservedQty; }
    public void setReservedQty(BigDecimal reservedQty) { this.reservedQty = reservedQty; }

    public BigDecimal getConsumedQty() { return consumedQty; }
    public void setConsumedQty(BigDecimal consumedQty) { this.consumedQty = consumedQty; }

    public BigDecimal getReleasedQty() { return releasedQty; }
    public void setReleasedQty(BigDecimal releasedQty) { this.releasedQty = releasedQty; }

    public BigDecimal getTransferredQty() { return transferredQty; }
    public void setTransferredQty(BigDecimal transferredQty) { this.transferredQty = transferredQty; }

    public Date getDemandDate() { return demandDate; }
    public void setDemandDate(Date demandDate) { this.demandDate = demandDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
