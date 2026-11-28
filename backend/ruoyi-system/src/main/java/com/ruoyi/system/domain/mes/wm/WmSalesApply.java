package com.ruoyi.system.domain.mes.wm;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * ERP 工厂出库申请 qxx_wm_sales_apply
 *
 * <p>ERP 下发、MES 执行。applyCode 为 ERP 申请单号，作为幂等键。</p>
 *
 * @author qixiaoxia
 * @date 2026-11-23
 */
public class WmSalesApply extends BaseEntity
{
    private Long applyId;
    private Long factoryId;
    private String applyCode;
    private String externalApplyNo;
    private String externalOrderNo;
    private Long purchaseOrderId;
    private Long salesOrderId;
    private String salesOrderCode;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date requestDate;

    private String receiverName;
    private String receiverTel;
    private String receiverAddress;
    private String status;
    private Long mesSalesId;
    private String mesSalesCode;
    private String remark;

    /** 申请明细（详情/下发时填充，非DB字段） */
    private transient List<WmSalesApplyLine> lines;

    /** 明细数量（列表展示，非DB字段） */
    private transient Integer lineCount;

    /** 申请总量（列表汇总，非DB字段） */
    private transient BigDecimal totalApplyQty;

    /** 已出库总量（列表汇总，非DB字段） */
    private transient BigDecimal totalPostedQty;

    public Long getApplyId() { return applyId; }
    public void setApplyId(Long v) { this.applyId = v; }
    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long v) { this.factoryId = v; }
    public String getApplyCode() { return applyCode; }
    public void setApplyCode(String v) { this.applyCode = v; }
    public String getExternalApplyNo() { return externalApplyNo; }
    public void setExternalApplyNo(String v) { this.externalApplyNo = v; }
    public String getExternalOrderNo() { return externalOrderNo; }
    public void setExternalOrderNo(String v) { this.externalOrderNo = v; }
    public Long getPurchaseOrderId() { return purchaseOrderId; }
    public void setPurchaseOrderId(Long v) { this.purchaseOrderId = v; }
    public Long getSalesOrderId() { return salesOrderId; }
    public void setSalesOrderId(Long v) { this.salesOrderId = v; }
    public String getSalesOrderCode() { return salesOrderCode; }
    public void setSalesOrderCode(String v) { this.salesOrderCode = v; }
    public Date getRequestDate() { return requestDate; }
    public void setRequestDate(Date v) { this.requestDate = v; }
    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String v) { this.receiverName = v; }
    public String getReceiverTel() { return receiverTel; }
    public void setReceiverTel(String v) { this.receiverTel = v; }
    public String getReceiverAddress() { return receiverAddress; }
    public void setReceiverAddress(String v) { this.receiverAddress = v; }
    public String getStatus() { return status; }
    public void setStatus(String v) { this.status = v; }
    public Long getMesSalesId() { return mesSalesId; }
    public void setMesSalesId(Long v) { this.mesSalesId = v; }
    public String getMesSalesCode() { return mesSalesCode; }
    public void setMesSalesCode(String v) { this.mesSalesCode = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
    public List<WmSalesApplyLine> getLines() { return lines; }
    public void setLines(List<WmSalesApplyLine> v) { this.lines = v; }
    public Integer getLineCount() { return lineCount; }
    public void setLineCount(Integer v) { this.lineCount = v; }
    public BigDecimal getTotalApplyQty() { return totalApplyQty; }
    public void setTotalApplyQty(BigDecimal v) { this.totalApplyQty = v; }
    public BigDecimal getTotalPostedQty() { return totalPostedQty; }
    public void setTotalPostedQty(BigDecimal v) { this.totalPostedQty = v; }

    /** 累计已出库比例 0-100（列表计算列） */
    public Integer getProgressPercent()
    {
        if (lines == null || lines.isEmpty()) return 0;
        BigDecimal apply = BigDecimal.ZERO;
        BigDecimal posted = BigDecimal.ZERO;
        for (WmSalesApplyLine line : lines)
        {
            if (line.getApplyQty() != null) apply = apply.add(line.getApplyQty());
            if (line.getPostedQty() != null) posted = posted.add(line.getPostedQty());
        }
        if (apply.compareTo(BigDecimal.ZERO) <= 0) return 0;
        int pct = posted.multiply(new BigDecimal("100"))
                .divide(apply, 0, java.math.RoundingMode.DOWN).intValue();
        return Math.min(pct, 100);
    }
}
