package com.ruoyi.system.service.mes.wm;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.mes.pro.ProWorkorder;
import com.ruoyi.system.domain.mes.sal.SalConstants;
import com.ruoyi.system.domain.mes.sal.SalOrder;
import com.ruoyi.system.domain.mes.sal.SalOrderLine;
import com.ruoyi.system.domain.mes.wm.WmProductRecpt;
import com.ruoyi.system.domain.mes.wm.WmProductRecptLine;
import com.ruoyi.system.mapper.mes.pro.ProWorkorderMapper;
import com.ruoyi.system.mapper.mes.sal.SalOrderLineMapper;
import com.ruoyi.system.mapper.mes.sal.SalOrderMapper;
import com.ruoyi.system.service.mes.sys.ISysSyncTaskService;
import com.ruoyi.system.service.mes.sys.integration.ErpCallbackPaths;

/**
 * 成品入库 → ERP 入库回写
 *
 * <p>仅处理来源为 ERP 采购单的 MES 销售订单。映射规则：</p>
 * <ul>
 *   <li>有工单：工单 → 销售订单行（salesOrderLineId）→ ERP 采购单行（externalLineId）</li>
 *   <li>无工单（成品采购入库）：按产品编码匹配最近一张 ERP 销售订单行</li>
 * </ul>
 * <p>入库确认后只落 outbox 任务，不阻塞仓库操作；失败由 SysSyncTask 自动重试。</p>
 *
 * @author qixiaoxia
 * @date 2026-11-23
 */
@Component
public class WmProductRecptInboundNotifier
{
    private static final Logger log = LoggerFactory.getLogger(WmProductRecptInboundNotifier.class);

    @Autowired
    private ProWorkorderMapper proWorkorderMapper;

    @Autowired
    private SalOrderLineMapper salOrderLineMapper;

    @Autowired
    private SalOrderMapper salOrderMapper;

    @Autowired
    private ISysSyncTaskService syncTaskService;

    /**
     * 入库确认后调用：若对应 ERP 销售订单，则回写入库数量。
     */
    public void notifyIfErpOrder(WmProductRecpt header, List<WmProductRecptLine> lines)
    {
        if (header == null || lines == null || lines.isEmpty())
        {
            return;
        }
        try
        {
            SalOrderLine salesLine = null;
            BigDecimal inboundQty = BigDecimal.ZERO;
            ProWorkorder workorder = null;

            if (header.getWorkorderId() != null)
            {
                workorder = proWorkorderMapper.selectProWorkorderByWorkorderId(header.getWorkorderId());
                if (workorder != null && workorder.getSalesOrderLineId() != null)
                {
                    salesLine = salOrderLineMapper.selectSalOrderLineByLineId(workorder.getSalesOrderLineId());
                }
                inboundQty = sumWorkorderProductQty(workorder, lines);
            }

            // 无工单或工单未关联订单：按产品编码回退匹配 ERP 订单行
            if (salesLine == null)
            {
                for (WmProductRecptLine line : lines)
                {
                    if (StringUtils.isEmpty(line.getItemCode())) continue;
                    SalOrderLine matched = salOrderLineMapper.selectLatestErpLineByProductCode(line.getItemCode());
                    if (matched != null)
                    {
                        salesLine = matched;
                        inboundQty = nz(line.getQuantityRecpt());
                        break;
                    }
                }
            }
            if (salesLine == null || StringUtils.isEmpty(salesLine.getExternalLineId()))
            {
                return;
            }
            SalOrder order = salOrderMapper.selectSalOrderByOrderId(salesLine.getOrderId());
            if (order == null || !SalConstants.SYSTEM_ERP.equals(order.getSourceSystem())
                    || StringUtils.isEmpty(order.getExternalOrderNo()))
            {
                return;
            }
            if (inboundQty.compareTo(BigDecimal.ZERO) <= 0)
            {
                return;
            }

            Map<String, Object> payload = new LinkedHashMap<>();
            payload.put("externalOrderNo", order.getExternalOrderNo());
            payload.put("mesOrderCode", order.getOrderCode());
            List<Map<String, Object>> payloadLines = new ArrayList<>();
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("externalLineId", salesLine.getExternalLineId());
            row.put("productCode", salesLine.getProductCode());
            row.put("inboundQty", inboundQty);
            row.put("recptCode", header.getRecptCode());
            row.put("inboundTime", DateUtils.parseDateToStr(DateUtils.YYYY_MM_DD_HH_MM_SS,
                    header.getRecptDate() == null ? new Date() : header.getRecptDate()));
            payloadLines.add(row);
            payload.put("lines", payloadLines);

            syncTaskService.enqueue(ErpCallbackPaths.BIZ_INBOUND_SYNC, header.getRecptId(),
                    header.getRecptCode(), ErpCallbackPaths.PURCHASE_INBOUND,
                    JSON.toJSONString(payload), ErpCallbackPaths.SYSTEM_ERP);
        }
        catch (Exception e)
        {
            // 不阻断入库：映射/投递异常只记日志
            log.warn("[入库回写] 生成ERP回写任务失败, recptCode={}, msg={}", header.getRecptCode(), e.getMessage());
        }
    }

    /** 工单成品数量：优先只统计工单主产品，取不到时回退所有入库行 */
    private BigDecimal sumWorkorderProductQty(ProWorkorder workorder, List<WmProductRecptLine> lines)
    {
        BigDecimal qty = BigDecimal.ZERO;
        if (workorder != null && workorder.getProductId() != null)
        {
            for (WmProductRecptLine line : lines)
            {
                if (workorder.getProductId().equals(line.getItemId()))
                {
                    qty = qty.add(nz(line.getQuantityRecpt()));
                }
            }
        }
        if (qty.compareTo(BigDecimal.ZERO) <= 0)
        {
            for (WmProductRecptLine line : lines)
            {
                qty = qty.add(nz(line.getQuantityRecpt()));
            }
        }
        return qty;
    }

    private BigDecimal nz(BigDecimal value)
    {
        return value == null ? BigDecimal.ZERO : value;
    }
}
