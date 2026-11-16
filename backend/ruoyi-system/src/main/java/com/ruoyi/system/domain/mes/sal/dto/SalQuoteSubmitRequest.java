package com.ruoyi.system.domain.mes.sal.dto;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * 报价录入/提交请求
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class SalQuoteSubmitRequest
{
    private Long quoteId;
    private String remark;
    private List<LineQuote> lines;

    public Long getQuoteId() { return quoteId; }
    public void setQuoteId(Long v) { this.quoteId = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
    public List<LineQuote> getLines() { return lines; }
    public void setLines(List<LineQuote> v) { this.lines = v; }

    public static class LineQuote
    {
        private Long lineId;
        private BigDecimal price;
        private String quoteRemark;
        private String deliveryDate;

        @JsonFormat(pattern = "yyyy-MM-dd")
        private Date quoteValidDate;

        public Long getLineId() { return lineId; }
        public void setLineId(Long v) { this.lineId = v; }
        public BigDecimal getPrice() { return price; }
        public void setPrice(BigDecimal v) { this.price = v; }
        public String getQuoteRemark() { return quoteRemark; }
        public void setQuoteRemark(String v) { this.quoteRemark = v; }
        public String getDeliveryDate() { return deliveryDate; }
        public void setDeliveryDate(String v) { this.deliveryDate = v; }
        public Date getQuoteValidDate() { return quoteValidDate; }
        public void setQuoteValidDate(Date v) { this.quoteValidDate = v; }
    }
}
