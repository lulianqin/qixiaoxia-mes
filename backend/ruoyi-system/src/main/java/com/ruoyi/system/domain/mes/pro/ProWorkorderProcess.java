package com.ruoyi.system.domain.mes.pro;

import java.math.BigDecimal;
import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 工单工艺路线工序快照 qxx_pro_workorder_process
 *
 * <p>新增/编辑工单时允许增删调整工序，快照只影响本工单排产与开单，不改工艺路线主数据。</p>
 *
 * @author qixiaoxia
 * @date 2026-11-17
 */
public class ProWorkorderProcess extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long recordId;
    private Long factoryId;
    private Long workorderId;
    private Long processId;
    private String processCode;
    private String processName;
    private Integer orderNum;
    private String isOutsource;
    /** 开单类型：PROCESS-加工 / PURCHASE-采购 */
    private String docType;
    private Long vendorId;
    private String vendorCode;
    private String vendorName;
    private BigDecimal unitPrice;
    /** 计划数量 */
    private BigDecimal planQty;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date expectedDate;

    public Long getRecordId() { return recordId; }
    public void setRecordId(Long v) { this.recordId = v; }
    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long v) { this.factoryId = v; }
    public Long getWorkorderId() { return workorderId; }
    public void setWorkorderId(Long v) { this.workorderId = v; }
    public Long getProcessId() { return processId; }
    public void setProcessId(Long v) { this.processId = v; }
    public String getProcessCode() { return processCode; }
    public void setProcessCode(String v) { this.processCode = v; }
    public String getProcessName() { return processName; }
    public void setProcessName(String v) { this.processName = v; }
    public Integer getOrderNum() { return orderNum; }
    public void setOrderNum(Integer v) { this.orderNum = v; }
    public String getIsOutsource() { return isOutsource; }
    public void setIsOutsource(String v) { this.isOutsource = v; }
    public String getDocType() { return docType; }
    public void setDocType(String v) { this.docType = v; }
    public Long getVendorId() { return vendorId; }
    public void setVendorId(Long v) { this.vendorId = v; }
    public String getVendorCode() { return vendorCode; }
    public void setVendorCode(String v) { this.vendorCode = v; }
    public String getVendorName() { return vendorName; }
    public void setVendorName(String v) { this.vendorName = v; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal v) { this.unitPrice = v; }
    public BigDecimal getPlanQty() { return planQty; }
    public void setPlanQty(BigDecimal v) { this.planQty = v; }
    public Date getExpectedDate() { return expectedDate; }
    public void setExpectedDate(Date v) { this.expectedDate = v; }
}
