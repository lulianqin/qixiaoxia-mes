package com.ruoyi.system.domain.mes.wm;

import java.math.BigDecimal;
import java.util.Date;
import java.util.Map;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 库存实物实例对象 qxx_wm_stock_instance
 *
 * 一件实物 = 一卷纸 / 一根钢管 / 一桶油墨；每件按主单位计量时数量可以各不相同。
 * 行业属性（门幅/克重、外径/壁厚…）存 ext_attrs，由分类绑定的 STOCK_INSTANCE 属性定义驱动。
 *
 * @author qixiaoxia
 * @date 2026-11-27
 */
public class WmStockInstance extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    @Excel(name = "ID")
    private Long instanceId;

    @Excel(name = "工厂ID")
    private Long factoryId;

    @Excel(name = "实物实例编号")
    private String instanceCode;

    @Excel(name = "实例类型")
    private String instanceType;

    @Excel(name = "物料ID")
    private Long itemId;

    @Excel(name = "物料编码")
    private String itemCode;

    @Excel(name = "物料名称")
    private String itemName;

    @Excel(name = "规格型号")
    private String specification;

    @Excel(name = "批次ID")
    private Long batchId;

    @Excel(name = "批次编码")
    private String batchCode;

    @Excel(name = "来源入库单ID")
    private Long recptId;

    @Excel(name = "来源入库明细ID")
    private Long recptDetailId;

    @Excel(name = "供应商ID")
    private Long vendorId;

    @Excel(name = "供应商编码")
    private String vendorCode;

    @Excel(name = "供应商名称")
    private String vendorName;

    @Excel(name = "供应商原始编号")
    private String vendorInstanceNo;

    @Excel(name = "父实例ID")
    private Long parentInstanceId;

    @Excel(name = "原始数量")
    private BigDecimal originalQuantity;

    @Excel(name = "剩余数量")
    private BigDecimal remainingQuantity;

    @Excel(name = "主单位")
    private String quantityUom;

    @Excel(name = "仓库ID")
    private Long warehouseId;

    @Excel(name = "仓库编码")
    private String warehouseCode;

    @Excel(name = "仓库名称")
    private String warehouseName;

    @Excel(name = "库区ID")
    private Long locationId;

    @Excel(name = "库位ID")
    private Long areaId;

    @Excel(name = "库存记录ID")
    private Long materialStockId;

    @Excel(name = "最近领料单ID")
    private Long lastIssueId;

    @Excel(name = "最近工单ID")
    private Long lastWorkorderId;

    @Excel(name = "最近工单编码")
    private String lastWorkorderCode;

    @Excel(name = "状态")
    private String status;

    /** 实例级动态属性（扁平 {attrCode:value}） */
    private Map<String, Object> extAttrs;

    @Excel(name = "备注")
    private String remark;

    @Excel(name = "创建者")
    private String createBy;

    @Excel(name = "创建时间")
    private Date createTime;

    @Excel(name = "更新者")
    private String updateBy;

    @Excel(name = "更新时间")
    private Date updateTime;

    public Long getInstanceId() { return instanceId; }
    public void setInstanceId(Long v) { this.instanceId = v; }
    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long v) { this.factoryId = v; }
    public String getInstanceCode() { return instanceCode; }
    public void setInstanceCode(String v) { this.instanceCode = v; }
    public String getInstanceType() { return instanceType; }
    public void setInstanceType(String v) { this.instanceType = v; }
    public Long getItemId() { return itemId; }
    public void setItemId(Long v) { this.itemId = v; }
    public String getItemCode() { return itemCode; }
    public void setItemCode(String v) { this.itemCode = v; }
    public String getItemName() { return itemName; }
    public void setItemName(String v) { this.itemName = v; }
    public String getSpecification() { return specification; }
    public void setSpecification(String v) { this.specification = v; }
    public Long getBatchId() { return batchId; }
    public void setBatchId(Long v) { this.batchId = v; }
    public String getBatchCode() { return batchCode; }
    public void setBatchCode(String v) { this.batchCode = v; }
    public Long getRecptId() { return recptId; }
    public void setRecptId(Long v) { this.recptId = v; }
    public Long getRecptDetailId() { return recptDetailId; }
    public void setRecptDetailId(Long v) { this.recptDetailId = v; }
    public Long getVendorId() { return vendorId; }
    public void setVendorId(Long v) { this.vendorId = v; }
    public String getVendorCode() { return vendorCode; }
    public void setVendorCode(String v) { this.vendorCode = v; }
    public String getVendorName() { return vendorName; }
    public void setVendorName(String v) { this.vendorName = v; }
    public String getVendorInstanceNo() { return vendorInstanceNo; }
    public void setVendorInstanceNo(String v) { this.vendorInstanceNo = v; }
    public Long getParentInstanceId() { return parentInstanceId; }
    public void setParentInstanceId(Long v) { this.parentInstanceId = v; }
    public BigDecimal getOriginalQuantity() { return originalQuantity; }
    public void setOriginalQuantity(BigDecimal v) { this.originalQuantity = v; }
    public BigDecimal getRemainingQuantity() { return remainingQuantity; }
    public void setRemainingQuantity(BigDecimal v) { this.remainingQuantity = v; }
    public String getQuantityUom() { return quantityUom; }
    public void setQuantityUom(String v) { this.quantityUom = v; }
    public Long getWarehouseId() { return warehouseId; }
    public void setWarehouseId(Long v) { this.warehouseId = v; }
    public String getWarehouseCode() { return warehouseCode; }
    public void setWarehouseCode(String v) { this.warehouseCode = v; }
    public String getWarehouseName() { return warehouseName; }
    public void setWarehouseName(String v) { this.warehouseName = v; }
    public Long getLocationId() { return locationId; }
    public void setLocationId(Long v) { this.locationId = v; }
    public Long getAreaId() { return areaId; }
    public void setAreaId(Long v) { this.areaId = v; }
    public Long getMaterialStockId() { return materialStockId; }
    public void setMaterialStockId(Long v) { this.materialStockId = v; }
    public Long getLastIssueId() { return lastIssueId; }
    public void setLastIssueId(Long v) { this.lastIssueId = v; }
    public Long getLastWorkorderId() { return lastWorkorderId; }
    public void setLastWorkorderId(Long v) { this.lastWorkorderId = v; }
    public String getLastWorkorderCode() { return lastWorkorderCode; }
    public void setLastWorkorderCode(String v) { this.lastWorkorderCode = v; }
    public String getStatus() { return status; }
    public void setStatus(String v) { this.status = v; }
    public Map<String, Object> getExtAttrs() { return extAttrs; }
    public void setExtAttrs(Map<String, Object> v) { this.extAttrs = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
    public String getCreateBy() { return createBy; }
    public void setCreateBy(String v) { this.createBy = v; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date v) { this.createTime = v; }
    public String getUpdateBy() { return updateBy; }
    public void setUpdateBy(String v) { this.updateBy = v; }
    public Date getUpdateTime() { return updateTime; }
    public void setUpdateTime(Date v) { this.updateTime = v; }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("instanceId", getInstanceId())
            .append("instanceCode", getInstanceCode())
            .append("itemId", getItemId())
            .append("remainingQuantity", getRemainingQuantity())
            .append("materialStockId", getMaterialStockId())
            .toString();
    }
}
