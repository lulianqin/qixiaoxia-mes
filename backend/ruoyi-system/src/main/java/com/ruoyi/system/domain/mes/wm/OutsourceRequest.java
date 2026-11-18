package com.ruoyi.system.domain.mes.wm;

import java.math.BigDecimal;
import java.util.List;

/**
 * 通用外协请求 DTO（创建外协发货单时用）
 *
 * 不依赖任何具体业务领域（不碰 WmRollDetail），
 * 分切/印刷等业务在前端组装好 issueLines 传入。
 *
 * @author qixiaoxia
 */
public class OutsourceRequest
{
    /** 加工类型：INSIDE-厂内 / OUTSIDE-外协 */
    private String supplierType = "OUTSIDE";
    /** 外协厂商ID（OUTSIDE 时必填） */
    private Long vendorId;
    private String vendorCode;
    private String vendorName;

    /** 工单ID（可选，独立外协可不填） */
    private Long workorderId;
    private String workorderCode;
    /** 流转卡ID（可选，联动 OUTSOURCING 状态） */
    private Long cardId;
    /** 工艺路线ID（可选，判断末工序用） */
    private Long routeId;
    /** 外协工序ID（可选） */
    private Long processId;
    private String processCode;
    private String processName;

    /** 来源类型：GENERIC/SLITTING/PRINTING */
    private String sourceType = "GENERIC";
    /** 来源业务单ID（如 slitting_record.slit_id） */
    private Long sourceRefId;

    /** 单据标题（如 印刷加工单/后道加工单） */
    private String docTitle;
    /** 下单日期 */
    private java.util.Date orderDate;
    /** 交货日期 */
    private java.util.Date expectedDate;
    /** 申购人 */
    private String purchaser;
    /** 业务单号（客户订单号） */
    private String sourceOrderCode;
    /** 送货地址 */
    private String deliveryAddress;

    /** 发料行（必填，至少一行） */
    private List<WmOutsourceIssueLine> issueLines;

    /** 工序明细行（多工序加工单；为空时按旧单工序流程处理） */
    private List<WmOutsourceProcessLine> processLines;

    private String remark;

    /** 草稿模式：true=只建单不扣料（DRAFT），false=直接发料扣料（ISSUED） */
    private boolean draft = false;

    public String getSupplierType() { return supplierType; }
    public void setSupplierType(String v) { this.supplierType = v; }
    public Long getVendorId() { return vendorId; }
    public void setVendorId(Long v) { this.vendorId = v; }
    public String getVendorCode() { return vendorCode; }
    public void setVendorCode(String v) { this.vendorCode = v; }
    public String getVendorName() { return vendorName; }
    public void setVendorName(String v) { this.vendorName = v; }
    public Long getWorkorderId() { return workorderId; }
    public void setWorkorderId(Long v) { this.workorderId = v; }
    public String getWorkorderCode() { return workorderCode; }
    public void setWorkorderCode(String v) { this.workorderCode = v; }
    public Long getCardId() { return cardId; }
    public void setCardId(Long v) { this.cardId = v; }
    public Long getRouteId() { return routeId; }
    public void setRouteId(Long v) { this.routeId = v; }
    public Long getProcessId() { return processId; }
    public void setProcessId(Long v) { this.processId = v; }
    public String getProcessCode() { return processCode; }
    public void setProcessCode(String v) { this.processCode = v; }
    public String getProcessName() { return processName; }
    public void setProcessName(String v) { this.processName = v; }
    public String getSourceType() { return sourceType; }
    public void setSourceType(String v) { this.sourceType = v; }
    public Long getSourceRefId() { return sourceRefId; }
    public void setSourceRefId(Long v) { this.sourceRefId = v; }
    public String getDocTitle() { return docTitle; }
    public void setDocTitle(String v) { this.docTitle = v; }
    public java.util.Date getOrderDate() { return orderDate; }
    public void setOrderDate(java.util.Date v) { this.orderDate = v; }
    public java.util.Date getExpectedDate() { return expectedDate; }
    public void setExpectedDate(java.util.Date v) { this.expectedDate = v; }
    public String getPurchaser() { return purchaser; }
    public void setPurchaser(String v) { this.purchaser = v; }
    public String getSourceOrderCode() { return sourceOrderCode; }
    public void setSourceOrderCode(String v) { this.sourceOrderCode = v; }
    public String getDeliveryAddress() { return deliveryAddress; }
    public void setDeliveryAddress(String v) { this.deliveryAddress = v; }
    public List<WmOutsourceIssueLine> getIssueLines() { return issueLines; }
    public void setIssueLines(List<WmOutsourceIssueLine> v) { this.issueLines = v; }
    public List<WmOutsourceProcessLine> getProcessLines() { return processLines; }
    public void setProcessLines(List<WmOutsourceProcessLine> v) { this.processLines = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
    public boolean isDraft() { return draft; }
    public void setDraft(boolean v) { this.draft = v; }
}
