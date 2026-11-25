package com.ruoyi.system.service.mes.sal.impl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.mes.md.MdItem;
import com.ruoyi.system.domain.mes.sal.SalConstants;
import com.ruoyi.system.domain.mes.sal.SalQuote;
import com.ruoyi.system.domain.mes.sal.SalQuoteLine;
import com.ruoyi.system.domain.mes.sal.dto.ErpQuoteLineRequest;
import com.ruoyi.system.domain.mes.sal.dto.ErpQuoteReceiveRequest;
import com.ruoyi.system.domain.mes.sal.dto.ErpQuoteReturnRequest;
import com.ruoyi.system.domain.mes.sal.dto.SalQuoteSubmitRequest;
import com.ruoyi.system.mapper.mes.sal.SalQuoteMapper;
import com.ruoyi.system.mapper.mes.md.MdItemMapper;
import com.ruoyi.system.service.mes.sal.ISalQuoteService;
import com.ruoyi.system.service.mes.sys.ISysSyncTaskService;
import com.ruoyi.system.service.mes.sys.generator.AutoCodeGenerator;
import com.ruoyi.system.service.mes.sys.integration.ErpCallbackPaths;
import com.ruoyi.system.service.mes.sys.integration.ErpCallbackPayload;

/**
 * 销售报价需求单Service实现
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
@Service
public class SalQuoteServiceImpl implements ISalQuoteService
{
    private static final String STATUS_PENDING = "PENDING_QUOTE";
    private static final String STATUS_QUOTED = "QUOTED";
    private static final String STATUS_RETURNED = "RETURNED";

    @Autowired
    private SalQuoteMapper salQuoteMapper;

    @Autowired
    private ISysSyncTaskService syncTaskService;

    @Autowired
    private AutoCodeGenerator autoCodeGenerator;

    @Autowired
    private com.ruoyi.system.service.mes.sys.SysExternalDocService externalDocService;

    @Autowired
    private MdItemMapper mdItemMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SalQuote receiveFromErp(ErpQuoteReceiveRequest req)
    {
        SalQuote existing = salQuoteMapper.selectSalQuoteByExternalNo(req.getExternalQuoteNo());
        SalQuote quote = existing == null ? new SalQuote() : existing;
        quote.setSourceSystem(StringUtils.isEmpty(req.getSourceSystem()) ? SalConstants.SYSTEM_ERP : req.getSourceSystem());
        quote.setExternalQuoteId(req.getExternalQuoteId());
        quote.setExternalQuoteNo(req.getExternalQuoteNo());
        quote.setTitle(req.getTitle());
        quote.setClientCode(req.getClientCode());
        quote.setClientName(req.getClientName());
        // 报价单只承接 ERP 的报价需求，不对接 MES 客户主数据（客户信息仅作参考文本）
        quote.setGoodsType(req.getGoodsType());
        // 询价日期为空时默认取接收到报价单的日期；已存在报价单保留原值，避免重复下发被覆盖
        Date inquiryDate = req.getInquiryDate();
        if (inquiryDate == null)
        {
            inquiryDate = existing != null && existing.getInquiryDate() != null
                    ? existing.getInquiryDate() : DateUtils.getNowDate();
        }
        quote.setInquiryDate(inquiryDate);
        quote.setBudget(req.getBudget());
        quote.setAttachment(req.getAttachment());
        quote.setRemark(req.getRemark());
        // 重新下发视为重新报价：重置状态与报价痕迹
        quote.setStatus(STATUS_PENDING);
        quote.setQuoteUser(null);
        quote.setQuoteTime(null);
        quote.setTotalAmount(null);
        quote.setReturnReason(null);
        quote.setReturnTime(null);
        quote.setUpdateBy(SecurityUtils.getUsername());
        quote.setUpdateTime(DateUtils.getNowDate());

        if (existing == null)
        {
            quote.setQuoteCode(generateQuoteCode());
            quote.setCreateBy(SecurityUtils.getUsername());
            quote.setCreateTime(DateUtils.getNowDate());
            salQuoteMapper.insertSalQuote(quote);
        }
        else
        {
            salQuoteMapper.updateSalQuote(quote);
            salQuoteMapper.deleteSalQuoteLineByQuoteId(quote.getQuoteId());
        }
        saveLines(quote, req.getLines());
        externalDocService.recordQuote(
                StringUtils.isEmpty(req.getSourceSystem()) ? SalConstants.SYSTEM_ERP : req.getSourceSystem(),
                quote);
        return quote;
    }

    @Override
    public List<SalQuote> selectSalQuoteList(SalQuote query)
    {
        return salQuoteMapper.selectSalQuoteList(query);
    }

    @Override
    public SalQuote getDetail(Long quoteId)
    {
        SalQuote quote = salQuoteMapper.selectSalQuoteByQuoteId(quoteId);
        if (quote == null) return null;
        quote.setLines(salQuoteMapper.selectSalQuoteLineByQuoteId(quoteId));
        return quote;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SalQuote saveQuote(SalQuoteSubmitRequest req)
    {
        SalQuote quote = mustEditable(req.getQuoteId());
        if (StringUtils.isNotEmpty(req.getRemark()))
        {
            quote.setRemark(req.getRemark());
        }
        applyLines(quote, req.getLines());
        quote.setUpdateBy(SecurityUtils.getUsername());
        quote.setUpdateTime(DateUtils.getNowDate());
        salQuoteMapper.updateSalQuote(quote);
        return getDetail(quote.getQuoteId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long submitQuote(SalQuoteSubmitRequest req)
    {
        SalQuote quote = mustEditable(req.getQuoteId());
        if (StringUtils.isNotEmpty(req.getRemark()))
        {
            quote.setRemark(req.getRemark());
        }
        applyLines(quote, req.getLines());
        List<SalQuoteLine> lines = salQuoteMapper.selectSalQuoteLineByQuoteId(quote.getQuoteId());
        List<String> missing = new ArrayList<>();
        BigDecimal total = BigDecimal.ZERO;
        for (SalQuoteLine line : lines)
        {
            String prefix = "第" + (line.getLineNo() == null ? "?" : line.getLineNo()) + "行";
            if (line.getPrice() == null || line.getPrice().compareTo(BigDecimal.ZERO) <= 0)
            {
                missing.add(prefix + "-报价单价");
                continue;
            }
            BigDecimal qty = line.getQuantity() == null ? BigDecimal.ONE : line.getQuantity();
            total = total.add(line.getPrice().multiply(qty));
        }
        if (!missing.isEmpty())
        {
            throw new ServiceException("报价提交失败，请填写：" + String.join("；", missing));
        }
        quote.setStatus(STATUS_QUOTED);
        quote.setQuoteUser(SecurityUtils.getUsername());
        quote.setQuoteTime(DateUtils.getNowDate());
        quote.setTotalAmount(total);
        quote.setUpdateBy(SecurityUtils.getUsername());
        quote.setUpdateTime(DateUtils.getNowDate());
        salQuoteMapper.updateSalQuote(quote);

        String payload = ErpCallbackPayload.quoteSubmit(quote, lines);
        return syncTaskService.enqueue(ErpCallbackPaths.BIZ_QUOTE_SUBMIT, quote.getQuoteId(),
                quote.getExternalQuoteNo(), ErpCallbackPaths.QUOTATION_QUOTE, payload, ErpCallbackPaths.SYSTEM_ERP);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void returnQuote(ErpQuoteReturnRequest req)
    {
        SalQuote quote = salQuoteMapper.selectSalQuoteByExternalNo(req.getExternalQuoteNo());
        if (quote == null)
        {
            throw new ServiceException("报价需求不存在: " + req.getExternalQuoteNo());
        }
        quote.setStatus(STATUS_RETURNED);
        quote.setReturnReason(req.getReason());
        quote.setReturnTime(DateUtils.getNowDate());
        quote.setUpdateBy(SecurityUtils.getUsername());
        quote.setUpdateTime(DateUtils.getNowDate());
        salQuoteMapper.updateSalQuote(quote);
    }

    // ==================== 私有辅助 ====================

    private SalQuote mustEditable(Long quoteId)
    {
        if (quoteId == null) throw new ServiceException("报价单ID不能为空");
        SalQuote quote = salQuoteMapper.selectSalQuoteByQuoteId(quoteId);
        if (quote == null) throw new ServiceException("报价单不存在");
        if (STATUS_QUOTED.equals(quote.getStatus()))
        {
            throw new ServiceException("报价单已提交，如需修改请等待ERP退回");
        }
        return quote;
    }

    private void applyLines(SalQuote quote, List<SalQuoteSubmitRequest.LineQuote> rows)
    {
        if (rows == null || rows.isEmpty()) return;
        for (SalQuoteSubmitRequest.LineQuote row : rows)
        {
            if (row.getLineId() == null) continue;
            SalQuoteLine line = salQuoteMapper.selectSalQuoteLineByLineId(row.getLineId());
            if (line == null || !quote.getQuoteId().equals(line.getQuoteId()))
            {
                throw new ServiceException("报价明细不属于当前报价单");
            }
            if (row.getPrice() != null) line.setPrice(row.getPrice());
            if (row.getQuoteRemark() != null) line.setQuoteRemark(row.getQuoteRemark());
            if (row.getDeliveryDate() != null) line.setDeliveryDate(row.getDeliveryDate());
            if (row.getQuoteValidDate() != null) line.setQuoteValidDate(row.getQuoteValidDate());
            line.setUpdateBy(SecurityUtils.getUsername());
            line.setUpdateTime(DateUtils.getNowDate());
            salQuoteMapper.updateSalQuoteLine(line);
        }
    }

    private void saveLines(SalQuote quote, List<ErpQuoteLineRequest> rows)
    {
        if (rows == null) return;
        int lineNo = 1;
        for (ErpQuoteLineRequest row : rows)
        {
            SalQuoteLine line = new SalQuoteLine();
            line.setQuoteId(quote.getQuoteId());
            line.setLineNo(lineNo++);
            line.setExternalLineId(row.getExternalLineId());
            line.setProductCode(row.getProductCode());
            line.setProductName(row.getProductName());
            // ERP 产品在 MES 不一定存在：按名称反查，匹配不到留空
            line.setProductId(resolveProductIdByName(row.getProductName()));
            line.setProductPhoto(row.getProductPhoto());
            line.setProductSize(row.getProductSize());
            line.setStructure(row.getStructure());
            line.setMaterial(row.getMaterial());
            line.setPrintingMode(row.getPrintingMode());
            line.setProcessTxt(row.getProcessTxt());
            line.setAccessoryTxt(row.getAccessoryTxt());
            line.setQuantity(row.getQuantity());
            line.setUnit(row.getUnit());
            line.setRemark(row.getRemark());
            line.setCreateBy(SecurityUtils.getUsername());
            line.setCreateTime(DateUtils.getNowDate());
            salQuoteMapper.insertSalQuoteLine(line);
        }
    }

    @Override
    public int deleteSalQuote(Long quoteId)
    {
        SalQuote exist = salQuoteMapper.selectSalQuoteByQuoteId(quoteId);
        if (exist == null)
        {
            throw new ServiceException("报价单不存在");
        }
        // 主表软删除，明细行保留；列表/详情查询均已过滤 del_flag
        return salQuoteMapper.deleteSalQuoteByQuoteId(quoteId);
    }

    /** 报价单号：优先自动编码规则，未配置时退化到时间戳编码 */
    private String generateQuoteCode()
    {
        try
        {
            return autoCodeGenerator.genSerialCode("QUOTE_NO", "");
        }
        catch (Exception e)
        {
            String ts = DateUtils.dateTimeNow("yyyyMMddHHmmss");
            String rand = String.format("%03d", (int) (Math.random() * 1000));
            return "SQ" + ts + rand;
        }
    }

    /** 产品名称精确匹配本地物料，未匹配返回 null（ERP 产品在 MES 不一定存在） */
    private Long resolveProductIdByName(String productName)
    {
        if (StringUtils.isEmpty(productName)) return null;
        String name = productName.trim();
        MdItem query = new MdItem();
        query.setItemName(name);
        List<MdItem> list = mdItemMapper.selectMdItemList(query);
        if (list != null)
        {
            for (MdItem item : list)
            {
                if (name.equals(item.getItemName())) return item.getItemId();
            }
        }
        return null;
    }
}
