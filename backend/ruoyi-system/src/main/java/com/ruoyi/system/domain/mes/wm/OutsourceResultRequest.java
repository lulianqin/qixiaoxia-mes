package com.ruoyi.system.domain.mes.wm;

import java.math.BigDecimal;
import java.util.List;

/**
 * 代厂商录入加工结果请求
 *
 * <p>产出明细用于收货入库；工序完成进度用于回写加工单工序行 done_qty。</p>
 *
 * @author qixiaoxia
 */
public class OutsourceResultRequest
{
    /** 本次产出明细（走原有收货/库存口径） */
    private List<WmOutsourceRecptLine> lines;

    /** 本次各工序完成数量（仅记录工序进度，不参与库存累加） */
    private List<ProcessResult> processResults;

    public List<WmOutsourceRecptLine> getLines() { return lines; }
    public void setLines(List<WmOutsourceRecptLine> v) { this.lines = v; }
    public List<ProcessResult> getProcessResults() { return processResults; }
    public void setProcessResults(List<ProcessResult> v) { this.processResults = v; }

    /** 单道工序本次完成数量 */
    public static class ProcessResult
    {
        private Long processLineId;
        private BigDecimal quantity;

        public Long getProcessLineId() { return processLineId; }
        public void setProcessLineId(Long v) { this.processLineId = v; }
        public BigDecimal getQuantity() { return quantity; }
        public void setQuantity(BigDecimal v) { this.quantity = v; }
    }
}
