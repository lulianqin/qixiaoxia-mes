package com.ruoyi.system.service.mes.sal;

import java.util.List;
import com.ruoyi.system.domain.mes.sal.SalQuote;
import com.ruoyi.system.domain.mes.sal.dto.ErpQuoteReceiveRequest;
import com.ruoyi.system.domain.mes.sal.dto.ErpQuoteReturnRequest;
import com.ruoyi.system.domain.mes.sal.dto.SalQuoteSubmitRequest;

/**
 * 销售报价需求单Service
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public interface ISalQuoteService
{
    /** ERP 下发报价需求（幂等：同一 ERP 报价单号覆盖更新） */
    SalQuote receiveFromErp(ErpQuoteReceiveRequest req);

    List<SalQuote> selectSalQuoteList(SalQuote query);

    SalQuote getDetail(Long quoteId);

    /** 保存报价草稿（不改变状态） */
    SalQuote saveQuote(SalQuoteSubmitRequest req);

    /**
     * 提交报价并生成回写任务
     *
     * @return 回写任务ID（调用方在事务外执行 dispatch）
     */
    Long submitQuote(SalQuoteSubmitRequest req);

    /** ERP 退回报价需求，允许重新报价 */
    void returnQuote(ErpQuoteReturnRequest req);

    /** 软删除报价单（明细保留，列表不再展示） */
    int deleteSalQuote(Long quoteId);
}
