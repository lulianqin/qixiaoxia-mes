package com.ruoyi.system.domain.mes.wm;

import java.math.BigDecimal;
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
    private Long processId;
    private String processCode;
    private String processName;
    private BigDecimal planQty;
    private BigDecimal doneQty;
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
    public Long getProcessId() { return processId; }
    public void setProcessId(Long v) { this.processId = v; }
    public String getProcessCode() { return processCode; }
    public void setProcessCode(String v) { this.processCode = v; }
    public String getProcessName() { return processName; }
    public void setProcessName(String v) { this.processName = v; }
    public BigDecimal getPlanQty() { return planQty; }
    public void setPlanQty(BigDecimal v) { this.planQty = v; }
    public BigDecimal getDoneQty() { return doneQty; }
    public void setDoneQty(BigDecimal v) { this.doneQty = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
}
