package com.ruoyi.system.domain.mes.sal.dto;

import java.util.Date;
import java.util.List;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * ERP 下发报价需求 → MES 报价单请求
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class ErpQuoteReceiveRequest
{
    private String sourceSystem;
    private String externalQuoteId;

    @NotBlank(message = "ERP报价单号不能为空")
    private String externalQuoteNo;

    private String title;
    private String clientCode;
    private String clientName;
    private String goodsType;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date inquiryDate;

    private String budget;
    private String attachment;
    private String remark;

    @NotEmpty(message = "报价明细不能为空")
    @Valid
    private List<ErpQuoteLineRequest> lines;

    public String getSourceSystem() { return sourceSystem; }
    public void setSourceSystem(String v) { this.sourceSystem = v; }
    public String getExternalQuoteId() { return externalQuoteId; }
    public void setExternalQuoteId(String v) { this.externalQuoteId = v; }
    public String getExternalQuoteNo() { return externalQuoteNo; }
    public void setExternalQuoteNo(String v) { this.externalQuoteNo = v; }
    public String getTitle() { return title; }
    public void setTitle(String v) { this.title = v; }
    public String getClientCode() { return clientCode; }
    public void setClientCode(String v) { this.clientCode = v; }
    public String getClientName() { return clientName; }
    public void setClientName(String v) { this.clientName = v; }
    public String getGoodsType() { return goodsType; }
    public void setGoodsType(String v) { this.goodsType = v; }
    public Date getInquiryDate() { return inquiryDate; }
    public void setInquiryDate(Date v) { this.inquiryDate = v; }
    public String getBudget() { return budget; }
    public void setBudget(String v) { this.budget = v; }
    public String getAttachment() { return attachment; }
    public void setAttachment(String v) { this.attachment = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
    public List<ErpQuoteLineRequest> getLines() { return lines; }
    public void setLines(List<ErpQuoteLineRequest> v) { this.lines = v; }
}
