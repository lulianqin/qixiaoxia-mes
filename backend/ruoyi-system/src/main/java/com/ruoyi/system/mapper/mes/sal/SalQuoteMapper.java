package com.ruoyi.system.mapper.mes.sal;

import java.util.Date;
import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.common.annotation.SkipFactoryId;
import com.ruoyi.system.domain.mes.sal.SalQuote;
import com.ruoyi.system.domain.mes.sal.SalQuoteLine;

/**
 * 销售报价需求单Mapper接口（factory_id 由 FactoryIdInterceptor 自动注入）
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public interface SalQuoteMapper
{
    public SalQuote selectSalQuoteByQuoteId(Long quoteId);
    public SalQuote selectSalQuoteByExternalNo(String externalQuoteNo);
    public List<SalQuote> selectSalQuoteList(SalQuote salQuote);
    public int insertSalQuote(SalQuote salQuote);
    public int updateSalQuote(SalQuote salQuote);

    /** 软删除报价单（del_flag=2，明细保留） */
    public int deleteSalQuoteByQuoteId(Long quoteId);

    /** 回写任务更新同步状态（无登录上下文，显式 factoryId） */
    @SkipFactoryId
    int updateSyncStatus(@Param("quoteId") Long quoteId,
                         @Param("factoryId") Long factoryId,
                         @Param("syncStatus") String syncStatus,
                         @Param("syncTime") Date syncTime);

    public SalQuoteLine selectSalQuoteLineByLineId(Long lineId);
    public List<SalQuoteLine> selectSalQuoteLineByQuoteId(Long quoteId);
    public int insertSalQuoteLine(SalQuoteLine line);
    public int updateSalQuoteLine(SalQuoteLine line);
    public int deleteSalQuoteLineByQuoteId(Long quoteId);
}
