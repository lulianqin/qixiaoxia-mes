package com.ruoyi.system.service.mes.wm;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.mes.sal.SalConstants;
import com.ruoyi.system.domain.mes.sal.SalOrder;
import com.ruoyi.system.domain.mes.sal.SalOrderLine;
import com.ruoyi.system.domain.mes.wm.WmProductSales;
import com.ruoyi.system.domain.mes.wm.WmProductSalesLine;
import com.ruoyi.system.domain.mes.wm.WmSalesApply;
import com.ruoyi.system.domain.mes.wm.WmSalesApplyLine;
import com.ruoyi.system.mapper.mes.sal.SalOrderLineMapper;
import com.ruoyi.system.mapper.mes.sal.SalOrderMapper;
import com.ruoyi.system.mapper.mes.wm.WmProductSalesLineMapper;
import com.ruoyi.system.mapper.mes.wm.WmProductSalesMapper;
import com.ruoyi.system.mapper.mes.wm.WmSalesApplyLineMapper;
import com.ruoyi.system.mapper.mes.wm.WmSalesApplyMapper;
import com.ruoyi.system.service.mes.sys.ISysSyncTaskService;
import com.ruoyi.system.service.mes.sys.integration.ErpCallbackPaths;
import com.ruoyi.system.service.mes.sys.integration.ErpCallbackPayload;

/**
 * 销售出库结果 → ERP 回写
 *
 * <p>两种来源都要回写：</p>
 * <ul>
 *   <li>ERP 出库申请：按申请行累计已出库量（applyId 非空）</li>
 *   <li>MES 手工直开：按销售订单行汇总，携带订单号/采购单号回写（旁路）</li>
 * </ul>
 *
 * @author qixiaoxia
 * @date 2026-11-23
 */
@Component
public class WmSalesOutboundNotifier
{
    @Autowired
    private WmProductSalesMapper salesMapper;

    @Autowired
    private WmProductSalesLineMapper salesLineMapper;

    @Autowired
    private WmSalesApplyMapper applyMapper;

    @Autowired
    private WmSalesApplyLineMapper applyLineMapper;

    @Autowired
    private SalOrderMapper salOrderMapper;

    @Autowired
    private SalOrderLineMapper salOrderLineMapper;

    @Autowired
    private ISysSyncTaskService syncTaskService;

    /**
     * 出库确认后调用：
     * - 来自 ERP 申请：按申请行回写；
     * - 手工直开且销售订单来自 ERP：按订单行汇总旁路回写。
     */
    public void notifyIfErpApply(Long salesId)
    {
        WmProductSales header = salesMapper.selectWmProductSalesBySalesId(salesId);
        if (header == null)
        {
            return;
        }
        if (header.getApplyId() != null)
        {
            notifyApplyOutbound(header);
            return;
        }
        notifyManualOutbound(header);
    }

    // ==================== ERP 出库申请 ====================

    private void notifyApplyOutbound(WmProductSales header)
    {
        Long factoryId = SecurityUtils.getFactoryId();
        WmSalesApply apply = applyMapper.selectWmSalesApplyById(header.getApplyId(), factoryId);
        if (apply == null)
        {
            return;
        }
        List<WmSalesApplyLine> applyLines = applyLineMapper.selectLinesByApplyId(apply.getApplyId(), factoryId);
        List<WmProductSalesLine> salesLines = salesLineMapper.selectLinesBySalesId(header.getSalesId());

        Map<Long, BigDecimal> postedByApplyLine = new HashMap<>();
        if (salesLines != null)
        {
            for (WmProductSalesLine salesLine : salesLines)
            {
                if (salesLine.getApplyLineId() == null) continue;
                postedByApplyLine.merge(salesLine.getApplyLineId(),
                        nz(salesLine.getQuantityPosted()), BigDecimal::add);
            }
        }

        List<Map<String, Object>> payloadLines = new ArrayList<>();
        boolean allDone = applyLines != null && !applyLines.isEmpty();
        boolean anyPosted = false;
        if (applyLines != null)
        {
            for (WmSalesApplyLine applyLine : applyLines)
            {
                BigDecimal posted = postedByApplyLine.getOrDefault(applyLine.getLineId(), BigDecimal.ZERO);
                BigDecimal target = nz(applyLine.getApplyQty());
                if (posted.compareTo(target) > 0) posted = target;
                String lineStatus = posted.compareTo(target) >= 0 ? "DONE"
                        : (posted.signum() > 0 ? "PARTIAL" : "PENDING");
                if (!"DONE".equals(lineStatus)) allDone = false;
                if (posted.signum() > 0) anyPosted = true;
                applyLineMapper.updatePosted(apply.getApplyId(), factoryId, applyLine.getExternalLineId(), posted, lineStatus);
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("externalLineId", applyLine.getExternalLineId());
                row.put("postedQty", posted);
                payloadLines.add(row);
            }
        }

        String status = allDone ? "DONE" : (anyPosted ? "PARTIAL" : "PENDING");
        WmSalesApply update = new WmSalesApply();
        update.setApplyId(apply.getApplyId());
        update.setFactoryId(factoryId);
        update.setStatus(status);
        applyMapper.updateWmSalesApplyStatus(update);

        String payload = ErpCallbackPayload.outboundResult(apply.getApplyId(), apply.getApplyCode(),
                header.getSalesId(), header.getSalesCode(), status, payloadLines);
        syncTaskService.enqueue(ErpCallbackPaths.BIZ_OUTBOUND_RESULT, apply.getApplyId(),
                apply.getApplyCode(), ErpCallbackPaths.SALES_OUTBOUND, payload, ErpCallbackPaths.SYSTEM_ERP);
    }

    // ==================== MES 手工直开（旁路） ====================

    private void notifyManualOutbound(WmProductSales header)
    {
        if (header.getSalesOrderId() == null)
        {
            return;
        }
        SalOrder order = salOrderMapper.selectSalOrderByOrderId(header.getSalesOrderId());
        if (order == null || !SalConstants.SYSTEM_ERP.equals(order.getSourceSystem())
                || isBlank(order.getExternalOrderNo()))
        {
            return;
        }
        List<SalOrderLine> orderLines = salOrderLineMapper.selectSalOrderLineByOrderId(order.getOrderId());
        Map<Long, SalOrderLine> orderLineMap = new HashMap<>();
        if (orderLines != null)
        {
            for (SalOrderLine line : orderLines)
            {
                orderLineMap.put(line.getLineId(), line);
            }
        }
        List<WmProductSalesLine> salesLines = salesLineMapper.selectLinesBySalesId(header.getSalesId());
        Map<Long, BigDecimal> postedByOrderLine = new LinkedHashMap<>();
        BigDecimal totalPosted = BigDecimal.ZERO;
        if (salesLines != null)
        {
            for (WmProductSalesLine salesLine : salesLines)
            {
                if (salesLine.getSalesOrderLineId() == null) continue;
                BigDecimal posted = nz(salesLine.getQuantityPosted());
                if (posted.signum() <= 0) continue;
                postedByOrderLine.merge(salesLine.getSalesOrderLineId(), posted, BigDecimal::add);
                totalPosted = totalPosted.add(posted);
            }
        }
        if (totalPosted.signum() <= 0)
        {
            return;
        }

        List<Map<String, Object>> payloadLines = new ArrayList<>();
        BigDecimal wantedTotal = BigDecimal.ZERO;
        for (SalOrderLine orderLine : orderLines == null ? new ArrayList<SalOrderLine>() : orderLines)
        {
            if (orderLine.getQuantity() != null) wantedTotal = wantedTotal.add(orderLine.getQuantity());
        }
        for (Map.Entry<Long, BigDecimal> entry : postedByOrderLine.entrySet())
        {
            SalOrderLine orderLine = orderLineMap.get(entry.getKey());
            if (orderLine == null || isBlank(orderLine.getExternalLineId())) continue;
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("externalLineId", orderLine.getExternalLineId());
            row.put("postedQty", entry.getValue());
            row.put("productCode", orderLine.getProductCode());
            row.put("productName", orderLine.getProductName());
            row.put("unit", orderLine.getUnitOfMeasure());
            payloadLines.add(row);
        }
        if (payloadLines.isEmpty())
        {
            return;
        }
        String status = wantedTotal.signum() > 0 && totalPosted.compareTo(wantedTotal) >= 0 ? "DONE" : "PARTIAL";
        String payload = ErpCallbackPayload.manualOutboundResult(order.getExternalOrderNo(),
                order.getClientOrderCode(), header.getSalesId(), header.getSalesCode(), status, payloadLines);
        syncTaskService.enqueue(ErpCallbackPaths.BIZ_OUTBOUND_RESULT, header.getSalesId(),
                header.getSalesCode(), ErpCallbackPaths.SALES_OUTBOUND, payload, ErpCallbackPaths.SYSTEM_ERP);
    }

    private BigDecimal nz(BigDecimal value)
    {
        return value == null ? BigDecimal.ZERO : value;
    }

    private boolean isBlank(String value)
    {
        return value == null || value.trim().isEmpty();
    }
}
