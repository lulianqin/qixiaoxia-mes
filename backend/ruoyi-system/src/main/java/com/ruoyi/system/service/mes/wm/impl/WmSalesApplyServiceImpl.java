package com.ruoyi.system.service.mes.wm.impl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.enums.WmProductSalesConstants;
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
        validateRequest(request);
        Long factoryId = SecurityUtils.getFactoryId();

        // 幂等：同一 ERP 申请单号只接一次；ERP 撤回后重新下发时复活原申请单并重建草稿
        WmSalesApply existing = applyMapper.selectByApplyCode(request.getExternalApplyNo(), factoryId);
        if (existing != null)
        {
            if (STATUS_CANCELED.equals(existing.getStatus()) || isDraftMissing(existing))
            {
                return reviveFromErp(existing, request, factoryId);
            }
            existing.setLines(applyLineMapper.selectLinesByApplyId(existing.getApplyId(), factoryId));
            return existing;
        }

        SalOrder order = resolveSalesOrder(request);
        Map<String, SalOrderLine> orderLineMap = indexOrderLines(order);
        Map<Long, BigDecimal> usedByOrderLine = loadUsedQtyByOrderLine(request.getExternalOrderNo(), factoryId, null);

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

        List<WmSalesApplyLine> applyLines = createApplyLines(apply, request, orderLineMap, usedByOrderLine, factoryId);
        bindDraft(apply, order, applyLines);
        return apply;
    }

    /**
     * ERP 撤回后重新下发：作废旧草稿与旧申请行，按最新报文重建。
     * 原逻辑直接返回已作废申请，会导致 ERP 显示已下发但 MES 无单可出的断点。
     */
    private WmSalesApply reviveFromErp(WmSalesApply apply, ErpOutboundApplyRequest request, Long factoryId)
    {
        List<WmSalesApplyLine> oldLines = applyLineMapper.selectLinesByApplyId(apply.getApplyId(), factoryId);
        for (WmSalesApplyLine line : oldLines)
        {
            if (line.getPostedQty() != null && line.getPostedQty().compareTo(BigDecimal.ZERO) > 0)
            {
                throw new ServiceException("申请单[" + apply.getApplyCode() + "]已存在出库数量，不能重新下发");
            }
        }
        removeDraftQuietly(apply.getMesSalesId());
        applyLineMapper.deleteLinesByApplyId(apply.getApplyId(), factoryId);

        SalOrder order = resolveSalesOrder(request);
        Map<String, SalOrderLine> orderLineMap = indexOrderLines(order);
        Map<Long, BigDecimal> usedByOrderLine = loadUsedQtyByOrderLine(request.getExternalOrderNo(), factoryId,
                apply.getApplyId());

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
        apply.setMesSalesId(null);
        apply.setMesSalesCode(null);
        apply.setUpdateBy(SecurityUtils.getUsername());
        apply.setUpdateTime(DateUtils.getNowDate());
        applyMapper.reviveFromErp(apply);

        List<WmSalesApplyLine> applyLines = createApplyLines(apply, request, orderLineMap, usedByOrderLine, factoryId);
        bindDraft(apply, order, applyLines);
        return apply;
    }

    /**
     * 申请仍是待出库、但绑定的 MES 出库草稿已不存在（如 ERP 撤回超时残留）时，需要重建，
     * 否则会一直返回一张没有可执行出库单的申请。
     */
    private boolean isDraftMissing(WmSalesApply apply)
    {
        if (apply.getMesSalesId() == null || !STATUS_PENDING.equals(apply.getStatus()))
        {
            return false;
        }
        return wmProductSalesService.selectWmProductSalesBySalesId(apply.getMesSalesId()) == null;
    }

    private void validateRequest(ErpOutboundApplyRequest request)
    {
        if (request == null || StringUtils.isEmpty(request.getExternalApplyNo()))
        {
            throw new ServiceException("出库申请单号不能为空");
        }
        if (StringUtils.isEmpty(request.getExternalOrderNo()))
        {
            throw new ServiceException("采购单号不能为空");
        }
        if (request.getLines() == null || request.getLines().isEmpty())
        {
            throw new ServiceException("出库申请明细不能为空");
        }
    }

    private SalOrder resolveSalesOrder(ErpOutboundApplyRequest request)
    {
        SalOrder order = salOrderMapper.selectSalOrderByExternalNo(ERP_SYSTEM, request.getExternalOrderNo());
        if (order == null)
        {
            throw new ServiceException("未找到采购单[" + request.getExternalOrderNo() + "]对应的MES销售订单");
        }
        return order;
    }

    private Map<String, SalOrderLine> indexOrderLines(SalOrder order)
    {
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
        return orderLineMap;
    }

    private List<WmSalesApplyLine> createApplyLines(WmSalesApply apply, ErpOutboundApplyRequest request,
                                                    Map<String, SalOrderLine> orderLineMap,
                                                    Map<Long, BigDecimal> usedByOrderLine, Long factoryId)
    {
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
                throw new ServiceException("销售订单[" + apply.getSalesOrderCode() + "]中不存在采购单明细："
                        + reqLine.getExternalLineId());
            }
            assertApplyQtyWithinOrderLine(orderLine, reqLine.getApplyQty(), usedByOrderLine);
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
        return applyLines;
    }

    /**
     * 接单二次校验：同一销售订单行的累计有效申请量不得超过订单需求量。
     * <p>ERP 建单已按「入库量 − 占用」校验，此处兜底 ERP 之外的直连接口调用与并发重复下发。</p>
     */
    private void assertApplyQtyWithinOrderLine(SalOrderLine orderLine, BigDecimal applyQty,
                                               Map<Long, BigDecimal> usedByOrderLine)
    {
        BigDecimal orderQty = orderLine.getQuantity();
        if (orderQty == null)
        {
            return;
        }
        BigDecimal already = usedByOrderLine.getOrDefault(orderLine.getLineId(), BigDecimal.ZERO);
        BigDecimal after = already.add(applyQty);
        usedByOrderLine.put(orderLine.getLineId(), after);
        if (after.compareTo(orderQty) > 0)
        {
            String product = StringUtils.isEmpty(orderLine.getProductName())
                    ? orderLine.getProductCode() : orderLine.getProductName();
            throw new ServiceException("明细[" + product + "]可申请量不足：订单需求 " + plain(orderQty)
                    + "，已申请 " + plain(already) + "，本次 " + plain(applyQty));
        }
    }

    private Map<Long, BigDecimal> loadUsedQtyByOrderLine(String externalOrderNo, Long factoryId, Long excludeApplyId)
    {
        Map<Long, BigDecimal> used = new HashMap<>();
        List<WmSalesApplyLine> rows = applyLineMapper.selectUsedQtyByOrderLine(externalOrderNo, factoryId,
                excludeApplyId);
        if (rows == null)
        {
            return used;
        }
        for (WmSalesApplyLine row : rows)
        {
            if (row.getSalesOrderLineId() == null)
            {
                continue;
            }
            used.put(row.getSalesOrderLineId(),
                    row.getApplyQty() == null ? BigDecimal.ZERO : row.getApplyQty());
        }
        return used;
    }

    private String plain(BigDecimal value)
    {
        return value == null ? "0" : value.stripTrailingZeros().toPlainString();
    }

    /** 按申请数量裁剪生成销售出库草稿，并回填 MES 出库单号 */
    private void bindDraft(WmSalesApply apply, SalOrder order, List<WmSalesApplyLine> applyLines)
    {
        WmProductSales draft = wmProductSalesService.buildFromSaleOrder(order.getOrderId());
        draft.setLines(adjustDraftLines(draft.getLines(), applyLines));
        draft.setApplyId(apply.getApplyId());
        draft.setApplyCode(apply.getApplyCode());
        draft.setSourceType(SOURCE_ERP_APPLY);
        wmProductSalesService.insertWmProductSales(draft);

        apply.setMesSalesId(draft.getSalesId());
        apply.setMesSalesCode(draft.getSalesCode());
        apply.setUpdateBy(SecurityUtils.getUsername());
        apply.setUpdateTime(DateUtils.getNowDate());
        applyMapper.updateWmSalesApplyResult(apply);
        apply.setLines(applyLines);
    }

    /** 作废旧草稿：仅草稿态可删，已过账/发运的保留（由已出库量校验拦截） */
    private void removeDraftQuietly(Long salesId)
    {
        if (salesId == null) return;
        WmProductSales draft = wmProductSalesService.selectWmProductSalesBySalesId(salesId);
        if (draft == null) return;
        if (!WmProductSalesConstants.isEditable(draft.getStatus())) return;
        wmProductSalesService.deleteWmProductSalesBySalesId(salesId);
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
     * 用申请数量裁剪草稿行：同一销售订单行可能被 FIFO 拆成多行（含无库存的尾量行），
     * 按行序依次吃满（每行上限为其原需求），剩余量落最后一行。
     * <p>不做按比例缩放：成品按件出库，比例缩放会拆出 0.24 这种不可执行的数量。</p>
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
            BigDecimal remaining = applyLine.getApplyQty();
            for (int i = 0; i < group.size(); i++)
            {
                WmProductSalesLine line = group.get(i);
                BigDecimal qty;
                if (i == group.size() - 1)
                {
                    qty = remaining;
                }
                else if (remaining.compareTo(BigDecimal.ZERO) <= 0 || line.getQuantitySales() == null)
                {
                    qty = BigDecimal.ZERO;
                }
                else
                {
                    qty = remaining.min(line.getQuantitySales());
                }
                if (qty.compareTo(BigDecimal.ZERO) < 0) qty = BigDecimal.ZERO;
                remaining = remaining.subtract(qty);
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

    /**
     * 无库存/无草稿行：按申请行生成一行，仓库留空（待定仓）。
     * <p>仓库由库存决定，ERP 出库申请下单时并不知道仓库；行仓为空是合法状态，
     * 前端按“无库存/未选仓”红标提示，出库确认时再指定仓库（后端做强制校验）。</p>
     */
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
