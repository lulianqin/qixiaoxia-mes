package com.ruoyi.system.domain.mes.sal.dto;

import java.util.Date;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * 销售订单接单请求(所有来源均可在接单时调整交期)
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class SalOrderAcceptRequest
{
    /** 调整后的整单需求交期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date requestDate;

    /** 接单时确认的 MES 客户ID（ERP/SRM 订单必填，首次接单会记录映射） */
    private Long clientId;

    /** 接单时确认的 MES 业务员账号（ERP 采购单未提供下单人时必填） */
    private String salesperson;

    /** 行级交期调整 + 产品映射 */
    private List<LineDate> lines;

    public Date getRequestDate() { return requestDate; }
    public void setRequestDate(Date v) { this.requestDate = v; }
    public Long getClientId() { return clientId; }
    public void setClientId(Long v) { this.clientId = v; }
    public String getSalesperson() { return salesperson; }
    public void setSalesperson(String v) { this.salesperson = v; }
    public List<LineDate> getLines() { return lines; }
    public void setLines(List<LineDate> v) { this.lines = v; }

    public static class LineDate
    {
        private Long lineId;

        @JsonFormat(pattern = "yyyy-MM-dd")
        private Date requestDate;

        /** 接单时确认的 MES 物料ID（首次接单会记录映射） */
        private Long productId;

        public Long getLineId() { return lineId; }
        public void setLineId(Long v) { this.lineId = v; }
        public Date getRequestDate() { return requestDate; }
        public void setRequestDate(Date v) { this.requestDate = v; }
        public Long getProductId() { return productId; }
        public void setProductId(Long v) { this.productId = v; }
    }
}
