package com.ruoyi.system.service.mes.sys;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.mes.sal.SalOrder;
import com.ruoyi.system.domain.mes.sal.SalQuote;
import com.ruoyi.system.domain.mes.sys.SysExternalDoc;
import com.ruoyi.system.mapper.mes.sys.SysExternalDocMapper;

/**
 * 外部单据留痕服务：ERP / SRM 两端单据 ID 分别保存
 *
 * @author qixiaoxia
 */
@Service
public class SysExternalDocService
{
    public static final String BIZ_ORDER = "ORDER";
    public static final String BIZ_QUOTE = "QUOTE";

    @Autowired
    private SysExternalDocMapper externalDocMapper;

    /** 记录销售订单（采购单下发）在外部系统中的单据号 */
    public void recordOrder(String systemCode, SalOrder order)
    {
        if (order == null || order.getOrderId() == null) return;
        if (StringUtils.isEmpty(order.getExternalOrderNo())) return;
        SysExternalDoc doc = new SysExternalDoc();
        doc.setSystemCode(StringUtils.isEmpty(systemCode) ? "ERP" : systemCode);
        doc.setBizType(BIZ_ORDER);
        doc.setFactoryId(SecurityUtils.getFactoryId());
        doc.setBizId(order.getOrderId());
        doc.setBizNo(order.getOrderCode());
        doc.setExternalId(order.getExternalOrderId());
        doc.setExternalNo(order.getExternalOrderNo());
        doc.setExternalVersion(order.getExternalVersion());
        doc.setSyncStatus(order.getSyncStatus());
        doc.setCreateBy(SecurityUtils.getUsername());
        externalDocMapper.upsertExternalDoc(doc);
    }

    /** 记录报价单在外部系统中的单据号 */
    public void recordQuote(String systemCode, SalQuote quote)
    {
        if (quote == null || quote.getQuoteId() == null) return;
        if (StringUtils.isEmpty(quote.getExternalQuoteNo())) return;
        SysExternalDoc doc = new SysExternalDoc();
        doc.setSystemCode(StringUtils.isEmpty(systemCode) ? "ERP" : systemCode);
        doc.setBizType(BIZ_QUOTE);
        doc.setFactoryId(SecurityUtils.getFactoryId());
        doc.setBizId(quote.getQuoteId());
        doc.setBizNo(quote.getQuoteCode());
        doc.setExternalId(quote.getExternalQuoteId());
        doc.setExternalNo(quote.getExternalQuoteNo());
        doc.setExternalVersion(1);
        doc.setSyncStatus(quote.getSyncStatus());
        doc.setCreateBy(SecurityUtils.getUsername());
        externalDocMapper.upsertExternalDoc(doc);
    }

    public List<SysExternalDoc> list(String bizType, Long bizId)
    {
        return externalDocMapper.selectByBiz(bizType, bizId);
    }
}
