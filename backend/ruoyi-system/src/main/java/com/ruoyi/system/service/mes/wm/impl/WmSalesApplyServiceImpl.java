package com.ruoyi.system.service.mes.wm.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.mes.sal.SalOrder;
import com.ruoyi.system.domain.mes.sal.SalOrderLine;
import com.ruoyi.system.domain.mes.sal.dto.ErpOutboundApplyLineRequest;
import com.ruoyi.system.domain.mes.sal.dto.ErpOutboundApplyRequest;
import com.ruoyi.system.domain.mes.wm.WmProductSales;
import com.ruoyi.system.domain.mes.wm.WmProductSalesLine;
import com.ruoyi.system.domain.mes.wm.WmSalesApply;
import com.ruoyi.system.domain.mes.wm.WmSalesApplyLine;
import com.ruoyi.system.mapper.mes.sal.SalOrderMapper;
import com.ruoyi.system.mapper.mes.wm.WmSalesApplyLineMapper;
import com.ruoyi.system.mapper.mes.wm.WmSalesApplyMapper;
import com.ruoyi.system.service.mes.sal.ISalOrderService;
import com.ruoyi.system.service.mes.wm.IWmProductSalesService;
import com.ruoyi.system.service.mes.wm.IWmSalesApplyService;

/**
 * ERP 工厂出库申请 Service 实现
 *
 * <p>ERP 下发申请 → MES 落申请 + 生成销售出库草稿；仓库在 MES 分批过账后回写 ERP。</p>
 *
 * @author qixiaoxia
 * @date 2026-11-23
 */
@Service
public class WmSalesApplyServiceImpl implements IWmSalesApplyService
{
    private static final String ERP_SYSTEM = "ERP";
    private static final String STATUS_PENDING = "PENDING";
    private static final String STATUS_CANCELED = "CANCELED";
    private static final String SOURCE_ERP_APPLY = "ERP_APPLY";

    @Autowired
    private WmSalesApplyMapper applyMapper;

    @Autowired
    private WmSalesApplyLineMapper applyLineMapper;

    @Autowired
    private SalOrderMapper salOrderMapper;

    @Autowired
    private ISalOrderService salOrderService;

    @Autowired
    private IWmProductSalesService wmProductSalesService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public WmSalesApply receiveFromErp(ErpOutboundApplyRequest request)
    {
        if (request == null || StringUtils.isEmpty(request.getExternalApplyNo()))
        {
            throw new ServiceException("出库申请单号不能为空");
        }
        if (StringUtils.isEmpty(request.getExternalOrderNo()))
        {
            throw new ServiceException("采购单号不能为空");
        }
        Long factoryId = SecurityUtils.getFactoryId();

        // 幂等：同一 ERP 申请单号只接一次
        WmSalesApply existing = applyMapper.selectByApplyCode(request.getExternalApplyNo(), factoryId);
        if (existing != null)
        {
            existing.setLines(applyLineMapper.selectLinesByApplyId(existing.getApplyId(), factoryId));
            return existing;
        }

        SalOrder order = salOrderMapper.selectSalOrderByExternalNo(ERP_SYSTEM, request.getExternalOrderNo());
        if (order == null)
        {
            throw new ServiceException("未找到采购单[" + request.getExternalOrderNo() + "]对应的MES销售订单");
        }
        SalOrder detail = salOrderService.getDetail(order.getOrderId());
        Map<String, SalOrderLine> orderLineMap = new HashMap<>();
        if (detail != null && detail.getLines() != null)
        {
            for (SalOrderLine line : detail.getLines())
            {
                if (line.getExternalLineId() != null)
                {
                    orderLineMap.put(line.getExternalLineId(), line);
                }
            }
        }

        WmSalesApply apply = new WmSalesApply();
        apply.setFactoryId(factoryId);
        apply.setApplyCode(request.getExternalApplyNo());
        apply.setExternalApplyNo(request.getExternalApplyNo());
        apply.setExternalOrderNo(request.getExternalOrderNo());
        apply.setPurchaseOrderId(parseLong(request.getExternalOrderId()));
        apply.setSalesOrderId(order.getOrderId());
        apply.setSalesOrderCode(order.getOrderCode());
        apply.setRequestDate(request.getRequestDate());
        apply.setReceiverName(request.getReceiverName());
        apply.setReceiverTel(request.getReceiverTel());
        apply.setReceiverAddress(request.getReceiverAddress());
        apply.setRemark(request.getRemark());
        apply.setStatus(STATUS_PENDING);
        apply.setCreateBy(SecurityUtils.getUsername());
        apply.setCreateTime(DateUtils.getNowDate());
        applyMapper.insertWmSalesApply(apply);

        List<WmSalesApplyLine> applyLines = new ArrayList<>();
        for (ErpOutboundApplyLineRequest reqLine : request.getLines())
        {
            if (reqLine.getApplyQty() == null || reqLine.getApplyQty().compareTo(BigDecimal.ZERO) <= 0)
            {
                throw new ServiceException("明细[" + reqLine.getExternalLineId() + "]申请数量必须大于0");
            }
            SalOrderLine orderLine = orderLineMap.get(reqLine.getExternalLineId());
            if (orderLine == null)
            {
                throw new ServiceException("销售订单[" + order.getOrderCode() + "]中不存在采购单明细："
                        + reqLine.getExternalLineId());
            }
            WmSalesApplyLine line = new WmSalesApplyLine();
            line.setFactoryId(factoryId);
            line.setApplyId(apply.getApplyId());
            line.setExternalLineId(reqLine.getExternalLineId());
            line.setSalesOrderLineId(orderLine.getLineId());
            line.setItemId(orderLine.getProductId());
            line.setItemCode(orderLine.getProductCode());
            line.setItemName(orderLine.getProductName());
            line.setUnitOfMeasure(orderLine.getUnitOfMeasure());
            line.setUnitName(orderLine.getUnitName());
            line.setApplyQty(reqLine.getApplyQty());
            line.setPostedQty(BigDecimal.ZERO);
            line.setLineStatus(STATUS_PENDING);
            line.setRemark(reqLine.getRemark());
            line.setCreateTime(DateUtils.getNowDate());
            applyLineMapper.insertWmSalesApplyLine(line);
            applyLines.add(line);
        }

        // 生成销售出库草稿：按申请数量裁剪 FIFO 拆行
        WmProductSales draft = wmProductSalesService.buildFromSaleOrder(order.getOrderId());
        draft.setLines(adjustDraftLines(draft.getLines(), applyLines));
        draft.setApplyId(apply.getApplyId());
        draft.setApplyCode(apply.getApplyCode());
        draft.setSourceType(SOURCE_ERP_APPLY);
        wmProductSalesService.insertWmProductSales(draft);

        apply.setMesSalesId(draft.getSalesId());
        apply.setMesSalesCode(draft.getSalesCode());
        apply.setUpdateBy(SecurityUtils.getUsername());
        apply.setUpdateTime(new Date());
        applyMapper.updateWmSalesApplyResult(apply);
        apply.setLines(applyLines);
        return apply;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancelFromErp(String externalApplyNo)
    {
        if (StringUtils.isEmpty(externalApplyNo))
        {
            throw new ServiceException("出库申请单号不能为空");
        }
        Long factoryId = SecurityUtils.getFactoryId();
        WmSalesApply apply = applyMapper.selectByApplyCode(externalApplyNo, factoryId);
        if (apply == null)
        {
            return;
        }
        List<WmSalesApplyLine> lines = applyLineMapper.selectLinesByApplyId(apply.getApplyId(), factoryId);
        for (WmSalesApplyLine line : lines)
        {
            if (line.getPostedQty() != null && line.getPostedQty().compareTo(BigDecimal.ZERO) > 0)
            {
                throw new ServiceException("申请单已存在出库数量，不能撤回");
            }
        }
        if (apply.getMesSalesId() != null)
        {
            wmProductSalesService.deleteWmProductSalesBySalesId(apply.getMesSalesId());
        }
        for (WmSalesApplyLine line : lines)
        {
            applyLineMapper.updatePosted(apply.getApplyId(), factoryId, line.getExternalLineId(),
                    line.getPostedQty() == null ? BigDecimal.ZERO : line.getPostedQty(), STATUS_CANCELED);
        }
        WmSalesApply update = new WmSalesApply();
        update.setApplyId(apply.getApplyId());
        update.setFactoryId(factoryId);
        update.setStatus(STATUS_CANCELED);
        applyMapper.updateWmSalesApplyStatus(update);
    }

    @Override
    public WmSalesApply getDetail(Long applyId)
    {
        Long factoryId = SecurityUtils.getFactoryId();
        WmSalesApply apply = applyMapper.selectWmSalesApplyById(applyId, factoryId);
        if (apply == null)
        {
            throw new ServiceException("出库申请不存在");
        }
        apply.setLines(applyLineMapper.selectLinesByApplyId(applyId, factoryId));
        return apply;
    }

    @Override
    public List<WmSalesApply> selectWmSalesApplyList(WmSalesApply query)
    {
        return applyMapper.selectWmSalesApplyList(query);
    }

    /**
     * 用申请数量裁剪草稿行：同一销售订单行可能被 FIFO 拆成多行，按比例缩放并让最后一行承接尾差。
     */
    private List<WmProductSalesLine> adjustDraftLines(List<WmProductSalesLine> draftLines, List<WmSalesApplyLine> applyLines)
    {
        Map<Long, List<WmProductSalesLine>> byOrderLine = new HashMap<>();
        if (draftLines != null)
        {
            for (WmProductSalesLine line : draftLines)
            {
                if (line.getSalesOrderLineId() == null) continue;
                byOrderLine.computeIfAbsent(line.getSalesOrderLineId(), k -> new ArrayList<>()).add(line);
            }
        }
        List<WmProductSalesLine> result = new ArrayList<>();
        for (WmSalesApplyLine applyLine : applyLines)
        {
            List<WmProductSalesLine> group = byOrderLine.get(applyLine.getSalesOrderLineId());
            if (group == null || group.isEmpty())
            {
                result.add(buildNoStockLine(applyLine));
                continue;
            }
            BigDecimal total = BigDecimal.ZERO;
            for (WmProductSalesLine line : group)
            {
                if (line.getQuantitySales() != null) total = total.add(line.getQuantitySales());
            }
            BigDecimal allocated = BigDecimal.ZERO;
            for (int i = 0; i < group.size(); i++)
            {
                WmProductSalesLine line = group.get(i);
                BigDecimal qty;
                if (i == group.size() - 1)
                {
                    qty = applyLine.getApplyQty().subtract(allocated);
                }
                else if (total.compareTo(BigDecimal.ZERO) <= 0 || line.getQuantitySales() == null)
                {
                    qty = BigDecimal.ZERO;
                }
                else
                {
                    qty = applyLine.getApplyQty().multiply(line.getQuantitySales())
                            .divide(total, 4, RoundingMode.HALF_UP);
                }
                if (qty.compareTo(BigDecimal.ZERO) < 0) qty = BigDecimal.ZERO;
                allocated = allocated.add(qty);
                line.setQuantitySales(qty);
                line.setApplyLineId(applyLine.getLineId());
                if (qty.compareTo(BigDecimal.ZERO) > 0)
                {
                    result.add(line);
                }
            }
        }
        return result;
    }

    /** 无库存/无草稿行：按申请行生成一行，仓库留空由仓库选择 */
    private WmProductSalesLine buildNoStockLine(WmSalesApplyLine applyLine)
    {
        WmProductSalesLine line = new WmProductSalesLine();
        line.setSalesOrderLineId(applyLine.getSalesOrderLineId());
        line.setApplyLineId(applyLine.getLineId());
        line.setItemId(applyLine.getItemId());
        line.setItemCode(applyLine.getItemCode());
        line.setItemName(applyLine.getItemName());
        line.setUnitOfMeasure(applyLine.getUnitOfMeasure());
        line.setUnitName(applyLine.getUnitName());
        line.setQuantitySales(applyLine.getApplyQty());
        line.setQuantityPosted(BigDecimal.ZERO);
        line.setAvailableQty(BigDecimal.ZERO);
        return line;
    }

    private Long parseLong(String value)
    {
        if (StringUtils.isEmpty(value)) return null;
        try
        {
            return Long.valueOf(value.trim());
        }
        catch (NumberFormatException e)
        {
            return null;
        }
    }
}
