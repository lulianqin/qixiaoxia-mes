package com.ruoyi.system.domain.mes.sal;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 销售报价需求单对象 qxx_sal_quote
 * 用途: ERP 下发报价需求, 工厂报价员录入价格后回传 ERP
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class SalQuote extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long quoteId;
    private Long factoryId;

    @Excel(name = "MES报价单号")
    private String quoteCode;

    @Excel(name = "ERP报价单号")
    private String externalQuoteNo;

    private String externalQuoteId;
    private String sourceSystem;

    @Excel(name = "标题")
    private String title;

    @Excel(name = "客户编码")
    private String clientCode;

    @Excel(name = "客户名称")
    private String clientName;

    /** 客户ID（按名称匹配 md_client，未匹配为空） */
    private Long clientId;

    @Excel(name = "商品类型")
    private String goodsType;

    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "询价日期", width = 30, dateFormat = "yyyy-MM-dd")
    private Date inquiryDate;

    @Excel(name = "预算")
    private String budget;

    private String attachment;

    @Excel(name = "状态")
    private String status;

    @Excel(name = "报价人")
    private String quoteUser;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "报价时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date quoteTime;

    @Excel(name = "报价总额")
    private BigDecimal totalAmount;

    @Excel(name = "退回原因")
    private String returnReason;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date returnTime;

    private String syncStatus;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date syncTime;

    /** 明细行(详情接口返回时填充,非DB字段) */
    private transient List<SalQuoteLine> lines;

    /** 列表查询：多状态过滤(非DB字段) */
    private transient List<String> statusList;

    public Long getQuoteId() { return quoteId; }
    public void setQuoteId(Long v) { this.quoteId = v; }
    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long v) { this.factoryId = v; }
    public String getQuoteCode() { return quoteCode; }
    public void setQuoteCode(String v) { this.quoteCode = v; }
    public String getExternalQuoteNo() { return externalQuoteNo; }
    public void setExternalQuoteNo(String v) { this.externalQuoteNo = v; }
    public String getExternalQuoteId() { return externalQuoteId; }
    public void setExternalQuoteId(String v) { this.externalQuoteId = v; }
    public String getSourceSystem() { return sourceSystem; }
    public void setSourceSystem(String v) { this.sourceSystem = v; }
    public String getTitle() { return title; }
    public void setTitle(String v) { this.title = v; }
    public String getClientCode() { return clientCode; }
    public void setClientCode(String v) { this.clientCode = v; }
    public String getClientName() { return clientName; }
    public void setClientName(String v) { this.clientName = v; }
    public Long getClientId() { return clientId; }
    public void setClientId(Long v) { this.clientId = v; }
    public String getGoodsType() { return goodsType; }
    public void setGoodsType(String v) { this.goodsType = v; }
    public Date getInquiryDate() { return inquiryDate; }
    public void setInquiryDate(Date v) { this.inquiryDate = v; }
    public String getBudget() { return budget; }
    public void setBudget(String v) { this.budget = v; }
    public String getAttachment() { return attachment; }
    public void setAttachment(String v) { this.attachment = v; }
    public String getStatus() { return status; }
    public void setStatus(String v) { this.status = v; }
    public String getQuoteUser() { return quoteUser; }
    public void setQuoteUser(String v) { this.quoteUser = v; }
    public Date getQuoteTime() { return quoteTime; }
    public void setQuoteTime(Date v) { this.quoteTime = v; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal v) { this.totalAmount = v; }
    public String getReturnReason() { return returnReason; }
    public void setReturnReason(String v) { this.returnReason = v; }
    public Date getReturnTime() { return returnTime; }
    public void setReturnTime(Date v) { this.returnTime = v; }
    public String getSyncStatus() { return syncStatus; }
    public void setSyncStatus(String v) { this.syncStatus = v; }
    public Date getSyncTime() { return syncTime; }
    public void setSyncTime(Date v) { this.syncTime = v; }
    public List<SalQuoteLine> getLines() { return lines; }
    public void setLines(List<SalQuoteLine> v) { this.lines = v; }
    public List<String> getStatusList() { return statusList; }
    public void setStatusList(List<String> v) { this.statusList = v; }
}
