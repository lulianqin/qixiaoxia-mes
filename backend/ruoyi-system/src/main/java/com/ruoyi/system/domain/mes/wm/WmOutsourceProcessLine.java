package com.ruoyi.system.domain.mes.wm;

import java.math.BigDecimal;
import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 加工单工序行 qxx_wm_outsource_process_line
 *
 * <p>一张加工单可包含多道工序；厂内/外协共用同一模板。</p>
 *
 * @author qixiaoxia
 */
public class WmOutsourceProcessLine extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long lineId;
    private Long factoryId;
    private Long orderId;
    private Integer seq;
    private Long taskId;
    private Long vendorId;
    private String vendorCode;
    private String vendorName;
    private Long processId;
    private String processCode;
    private String processName;
    /** 产品名称快照（开单页配置，导出用） */
    private String productName;
    private BigDecimal planQty;
    private BigDecimal doneQty;
    /** 工序单价 */
    private BigDecimal unitPrice;
    /** 工序金额 = 计划数量 × 单价 */
    private BigDecimal amount;
    /** 送货日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date expectedDate;
    /** 工序扩展属性(JSON扁平结构，按工序属性模板) */
    private String extAttrs;
    private String remark;

    public Long getLineId() { return lineId; }
    public void setLineId(Long v) { this.lineId = v; }
    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long v) { this.factoryId = v; }
    public Long getOrderId() { return orderId; }
    public void setOrderId(Long v) { this.orderId = v; }
    public Integer getSeq() { return seq; }
    public void setSeq(Integer v) { this.seq = v; }
    public Long getTaskId() { return taskId; }
    public void setTaskId(Long v) { this.taskId = v; }
    public Long getVendorId() { return vendorId; }
    public void setVendorId(Long v) { this.vendorId = v; }
    public String getVendorCode() { return vendorCode; }
    public void setVendorCode(String v) { this.vendorCode = v; }
    public String getVendorName() { return vendorName; }
    public void setVendorName(String v) { this.vendorName = v; }
    public Long getProcessId() { return processId; }
    public void setProcessId(Long v) { this.processId = v; }
    public String getProcessCode() { return processCode; }
    public void setProcessCode(String v) { this.processCode = v; }
    public String getProcessName() { return processName; }
    public void setProcessName(String v) { this.processName = v; }
    public String getProductName() { return productName; }
    public void setProductName(String v) { this.productName = v; }
    public BigDecimal getPlanQty() { return planQty; }
    public void setPlanQty(BigDecimal v) { this.planQty = v; }
    public BigDecimal getDoneQty() { return doneQty; }
    public void setDoneQty(BigDecimal v) { this.doneQty = v; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal v) { this.unitPrice = v; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal v) { this.amount = v; }
    public Date getExpectedDate() { return expectedDate; }
    public void setExpectedDate(Date v) { this.expectedDate = v; }
    public String getExtAttrs() { return extAttrs; }
    public void setExtAttrs(String v) { this.extAttrs = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
}
