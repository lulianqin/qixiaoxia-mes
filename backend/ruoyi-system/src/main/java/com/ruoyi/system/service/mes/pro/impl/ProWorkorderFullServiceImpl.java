package com.ruoyi.system.service.mes.pro.impl;

import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.mes.pro.ProRouteProcess;
import com.ruoyi.system.domain.mes.pro.ProRouteProduct;
import com.ruoyi.system.domain.mes.pro.ProWorkorder;
import com.ruoyi.system.domain.mes.pro.ProWorkorderBom;
import com.ruoyi.system.domain.mes.pro.ProWorkorderParam;
import com.ruoyi.system.domain.mes.pro.ProWorkorderProcess;
import com.ruoyi.system.domain.mes.pro.WorkorderFullDetailVO;
import com.ruoyi.system.domain.mes.pro.WorkorderFullSubmitVO;
import com.ruoyi.system.domain.mes.pro.WorkorderProcDocVO;
import com.ruoyi.system.domain.mes.pro.WorkorderProcLineVO;
import com.ruoyi.system.domain.mes.pro.WorkorderPurDocVO;
import com.ruoyi.system.domain.mes.pro.WorkorderPurLineVO;
import com.ruoyi.system.domain.mes.pur.PurOrder;
import com.ruoyi.system.domain.mes.pur.PurOrderLine;
import com.ruoyi.system.domain.mes.pur.vo.PurOrderVO;
import com.ruoyi.system.domain.mes.wm.OutsourceRequest;
import com.ruoyi.system.domain.mes.wm.WmOutsourceOrder;
import com.ruoyi.system.domain.mes.wm.WmOutsourceProcessLine;
import com.ruoyi.system.mapper.mes.pro.ProWorkorderProcessMapper;
import com.ruoyi.system.mapper.mes.pur.PurOrderMapper;
import com.ruoyi.system.mapper.mes.wm.WmOutsourceOrderMapper;
import com.ruoyi.system.mapper.mes.wm.WmOutsourceProcessLineMapper;
import com.ruoyi.system.service.mes.pro.IProRouteProductService;
import com.ruoyi.system.service.mes.pro.IProWorkorderBomService;
import com.ruoyi.system.service.mes.pro.IProWorkorderFullService;
import com.ruoyi.system.service.mes.pro.IProWorkorderParamService;
import com.ruoyi.system.service.mes.pro.IProWorkorderService;
import com.ruoyi.system.service.mes.pur.IPurOrderLineService;
import com.ruoyi.system.service.mes.pur.IPurOrderService;
import com.ruoyi.system.service.mes.wm.IOutsourceService;
import com.alibaba.fastjson2.JSON;

/**
 * 生产工单开单页 Service 实现。
 * <p>一次事务内完成：主工单 + BOM + 工序参数 + 工序快照 + 采购单草稿 + 加工单草稿。</p>
 *
 * @author qixiaoxia
 * @date 2026-11-17
 */
@Service
public class ProWorkorderFullServiceImpl implements IProWorkorderFullService
{
    private static final String STATUS_DRAFT = "DRAFT";

    @Autowired private IProWorkorderService workorderService;
    @Autowired private IProWorkorderBomService bomService;
    @Autowired private IProWorkorderParamService paramService;
    @Autowired private IProRouteProductService routeProductService;
    @Autowired private ProWorkorderProcessMapper woProcessMapper;
    @Autowired private IPurOrderService purOrderService;
    @Autowired private IPurOrderLineService purOrderLineService;
    @Autowired private PurOrderMapper purOrderMapper;
    @Autowired private IOutsourceService outsourceService;
    @Autowired private WmOutsourceOrderMapper outsourceOrderMapper;
    @Autowired private WmOutsourceProcessLineMapper processLineMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ProWorkorder createFull(WorkorderFullSubmitVO body)
    {
        if (body == null || body.getWorkorder() == null)
        {
            throw new ServiceException("工单信息不能为空");
        }
        ensureRouteProductBinding(body.getWorkorder(), body.getRouteProcesses());
        ProWorkorder wo = workorderService.createWorkorderWithBom(
                body.getWorkorder(), body.getBomList(), body.getParamList());
        saveRouteSnapshot(wo.getWorkorderId(), body.getRouteProcesses());
        savePurchaseDocs(wo, body.getPurchaseDocs());
        saveProcessDocs(wo, body.getProcessDocs());
        return wo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ProWorkorder updateFull(Long workorderId, WorkorderFullSubmitVO body)
    {
        if (workorderId == null || body == null || body.getWorkorder() == null)
        {
            throw new ServiceException("工单信息不能为空");
        }
        ProWorkorder existing = workorderService.selectProWorkorderByWorkorderId(workorderId);
        if (existing == null)
        {
            throw new ServiceException("工单不存在");
        }
        if (!"PREPARE".equals(existing.getStatus()))
        {
            throw new ServiceException("仅待生产工单可修改");
        }
        body.getWorkorder().setWorkorderId(workorderId);
        ensureRouteProductBinding(body.getWorkorder(), body.getRouteProcesses());
        ProWorkorder wo = workorderService.updateWorkorderWithBom(
                body.getWorkorder(), body.getBomList(), body.getParamList());
        wo = workorderService.selectProWorkorderByWorkorderId(workorderId);
        woProcessMapper.deleteByWorkorderId(workorderId, SecurityUtils.getFactoryId());
        saveRouteSnapshot(workorderId, body.getRouteProcesses());
        removeDraftDocs(workorderId);
        savePurchaseDocs(wo, body.getPurchaseDocs());
        saveProcessDocs(wo, body.getProcessDocs());
        return wo;
    }

    @Override
    public WorkorderFullDetailVO getFullDetail(Long workorderId)
    {
        com.ruoyi.system.domain.mes.pro.ProWorkorderDetailVO detail = workorderService.getWorkorderDetail(workorderId);
        WorkorderFullDetailVO vo = new WorkorderFullDetailVO();
        vo.setWorkorder(detail.getWorkorder());
        vo.setBomList(detail.getBomList());
        vo.setParamList(detail.getParamList());
        // 工序快照优先（新增/编辑时增删过工序）
        List<ProWorkorderProcess> snapshot = woProcessMapper.selectByWorkorderId(workorderId, SecurityUtils.getFactoryId());
        if (snapshot != null && !snapshot.isEmpty())
        {
            List<ProRouteProcess> rps = new ArrayList<>();
            for (ProWorkorderProcess p : snapshot)
            {
                rps.add(toRouteProcess(p));
            }
            vo.setRouteProcesses(rps);
        }
        else
        {
            vo.setRouteProcesses(detail.getRouteProcesses());
        }
        vo.setPurchaseDocs(loadPurchaseDocs(workorderId));
        vo.setProcessDocs(loadProcessDocs(workorderId));
        return vo;
    }

    // ────────────────────────── 工序快照 ──────────────────────────

    /**
     * 产品未绑定该工艺路线时，按所选路线自动建立「路线-产品」绑定，
     * 保证排产能解析 routeId；已绑定则直接回填 recordId。
     */
    private void ensureRouteProductBinding(ProWorkorder wo, List<ProRouteProcess> routeProcesses)
    {
        if (wo == null || wo.getProductId() == null || wo.getRouteProductId() != null)
        {
            return;
        }
        Long routeId = null;
        if (routeProcesses != null)
        {
            for (ProRouteProcess rp : routeProcesses)
            {
                if (rp.getRouteId() != null)
                {
                    routeId = rp.getRouteId();
                    break;
                }
            }
        }
        if (routeId == null)
        {
            return;
        }
        ProRouteProduct q = new ProRouteProduct();
        q.setRouteId(routeId);
        q.setItemId(wo.getProductId());
        List<ProRouteProduct> exists = routeProductService.selectProRouteProductList(q);
        if (exists != null && !exists.isEmpty())
        {
            wo.setRouteProductId(exists.get(0).getRecordId());
            return;
        }
        ProRouteProduct binding = new ProRouteProduct();
        binding.setRouteId(routeId);
        binding.setItemId(wo.getProductId());
        binding.setItemCode(wo.getProductCode());
        binding.setItemName(wo.getProductName());
        binding.setSpecification(wo.getProductSpc());
        binding.setUnitOfMeasure(wo.getUnitOfMeasure());
        binding.setUnitName(wo.getUnitName());
        binding.setIsDefault("0");
        routeProductService.insertProRouteProduct(binding);
        wo.setRouteProductId(binding.getRecordId());
    }

    private void saveRouteSnapshot(Long workorderId, List<ProRouteProcess> routeProcesses)
    {
        if (routeProcesses == null || routeProcesses.isEmpty())
        {
            return;
        }
        Long factoryId = SecurityUtils.getFactoryId();
        String operator = SecurityUtils.getUsername();
        List<ProWorkorderProcess> rows = new ArrayList<>();
        int seq = 1;
        for (ProRouteProcess rp : routeProcesses)
        {
            if (rp.getProcessId() == null)
            {
                continue;
            }
            ProWorkorderProcess p = new ProWorkorderProcess();
            p.setFactoryId(factoryId);
            p.setWorkorderId(workorderId);
            p.setProcessId(rp.getProcessId());
            p.setProcessCode(rp.getProcessCode());
            p.setProcessName(rp.getProcessName());
            p.setOrderNum(seq++);
            p.setIsOutsource(rp.getIsOutsource() != null ? rp.getIsOutsource() : "0");
            p.setDocType(rp.getDocType() != null ? rp.getDocType() : "PROCESS");
            p.setVendorId(rp.getVendorId());
            p.setVendorCode(rp.getVendorCode());
            p.setVendorName(rp.getVendorName());
            p.setUnitPrice(rp.getUnitPrice());
            p.setPlanQty(rp.getPlanQty());
            p.setExpectedDate(rp.getExpectedDate());
            p.setCreateBy(operator);
            rows.add(p);
        }
        if (!rows.isEmpty())
        {
            woProcessMapper.insertBatch(rows);
        }
    }

    private ProRouteProcess toRouteProcess(ProWorkorderProcess p)
    {
        ProRouteProcess rp = new ProRouteProcess();
        rp.setProcessId(p.getProcessId());
        rp.setProcessCode(p.getProcessCode());
        rp.setProcessName(p.getProcessName());
        rp.setOrderNum(p.getOrderNum());
        rp.setIsOutsource(p.getIsOutsource());
        rp.setDocType(p.getDocType());
        rp.setVendorId(p.getVendorId());
        rp.setVendorCode(p.getVendorCode());
        rp.setVendorName(p.getVendorName());
        rp.setUnitPrice(p.getUnitPrice());
        rp.setPlanQty(p.getPlanQty());
        rp.setExpectedDate(p.getExpectedDate());
        return rp;
    }

    // ────────────────────────── 采购单 ──────────────────────────

    private void savePurchaseDocs(ProWorkorder wo, List<WorkorderPurDocVO> docs)
    {
        if (docs == null || docs.isEmpty())
        {
            return;
        }
        for (WorkorderPurDocVO doc : docs)
        {
            if (doc.getVendorId() == null)
            {
                throw new ServiceException("采购单[" + safe(doc.getDocTitle()) + "]请选择供应商");
            }
            if (doc.getLines() == null || doc.getLines().isEmpty())
            {
                throw new ServiceException("采购单[" + safe(doc.getDocTitle()) + "]至少需要一行明细");
            }
            PurOrder po = buildPurOrder(wo, doc);
            purOrderService.insertPurOrder(po);
            BigDecimal totalQty = BigDecimal.ZERO;
            BigDecimal totalAmount = BigDecimal.ZERO;
            for (WorkorderPurLineVO l : doc.getLines())
            {
                if (l.getItemId() == null)
                {
                    throw new ServiceException("采购单明细物料不能为空");
                }
                PurOrderLine line = buildPurLine(po.getOrderId(), l);
                purOrderLineService.insertPurOrderLine(line);
                totalQty = totalQty.add(nvl(line.getQuantityOrdered()));
                totalAmount = totalAmount.add(nvl(line.getAmount()));
            }
            po.setTotalQuantity(totalQty);
            po.setTotalAmount(totalAmount);
            purOrderService.updatePurOrder(po);
        }
    }

    private PurOrder buildPurOrder(ProWorkorder wo, WorkorderPurDocVO doc)
    {
        PurOrder po = new PurOrder();
        po.setOrderName(wo.getWorkorderName() + "-" + safe(doc.getDocTitle()));
        po.setDocTitle(doc.getDocTitle());
        po.setVendorId(doc.getVendorId());
        po.setVendorCode(doc.getVendorCode());
        po.setVendorName(doc.getVendorName());
        po.setPurchaseType(StringUtils.isEmpty(doc.getPurchaseType()) ? "OTHER" : doc.getPurchaseType());
        po.setOrderDate(parseDate(doc.getOrderDate(), new Date()));
        po.setExpectedDate(parseDate(doc.getExpectedDate(), null));
        po.setPurchaser(StringUtils.isEmpty(doc.getPurchaser()) ? SecurityUtils.getUsername() : doc.getPurchaser());
        po.setSourceOrderCode(StringUtils.isEmpty(doc.getSourceOrderCode())
                ? wo.getClientOrderCode() : doc.getSourceOrderCode());
        po.setDeliveryAddress(doc.getDeliveryAddress());
        po.setCurrency("CNY");
        po.setRemark(doc.getRemark());
        po.setWorkorderId(wo.getWorkorderId());
        po.setWorkorderCode(wo.getWorkorderCode());
        po.setStatus(STATUS_DRAFT);
        return po;
    }

    private PurOrderLine buildPurLine(Long orderId, WorkorderPurLineVO l)
    {
        PurOrderLine line = new PurOrderLine();
        line.setOrderId(orderId);
        line.setProcessId(l.getProcessId());
        line.setProcessCode(l.getProcessCode());
        line.setProcessName(l.getProcessName());
        line.setItemId(l.getItemId());
        line.setItemCode(l.getItemCode());
        line.setItemName(l.getItemName());
        line.setProductName(l.getProductName());
        line.setSpecification(l.getSpecification());
        line.setUnitOfMeasure(StringUtils.isEmpty(l.getUnitOfMeasure()) ? "PCS" : l.getUnitOfMeasure());
        line.setUnitName(StringUtils.isEmpty(l.getUnitName()) ? "个" : l.getUnitName());
        BigDecimal qty = nvl(l.getQuantity());
        BigDecimal price = nvl(l.getUnitPrice());
        line.setQuantityOrdered(qty);
        line.setUnitPrice(price);
        line.setTaxRate(nvl(l.getTaxRate()));
        line.setAmount(qty.multiply(price).setScale(2, java.math.RoundingMode.HALF_UP));
        line.setExpectedDate(parseDate(l.getExpectedDate(), null));
        line.setLineAttrs(l.getLineAttrs());
        line.setRemark(l.getRemark());
        line.setStatus("ORDERED");
        return line;
    }

    private void removeDraftDocs(Long workorderId)
    {
        PurOrder q = new PurOrder();
        q.setWorkorderId(workorderId);
        q.setStatus(STATUS_DRAFT);
        List<PurOrderVO> pos = purOrderMapper.selectPurOrderList(q);
        if (pos != null)
        {
            for (PurOrderVO po : pos)
            {
                purOrderLineService.deletePurOrderLineByOrderId(po.getOrderId());
                purOrderMapper.deletePurOrderByOrderId(po.getOrderId());
            }
        }
        List<WmOutsourceOrder> outs = outsourceOrderMapper.selectByWorkorderId(workorderId);
        if (outs != null)
        {
            for (WmOutsourceOrder o : outs)
            {
                if (!STATUS_DRAFT.equals(o.getStatus()))
                {
                    continue;
                }
                processLineMapper.deleteByOrderId(o.getOrderId());
                outsourceOrderMapper.deleteOutsourceOrderByOrderId(o.getOrderId());
            }
        }
    }

    private List<WorkorderFullDetailVO.PurchaseDoc> loadPurchaseDocs(Long workorderId)
    {
        List<WorkorderFullDetailVO.PurchaseDoc> result = new ArrayList<>();
        PurOrder q = new PurOrder();
        q.setWorkorderId(workorderId);
        List<PurOrderVO> pos = purOrderMapper.selectPurOrderList(q);
        if (pos == null)
        {
            return result;
        }
        for (PurOrderVO po : pos)
        {
            PurOrderLine lq = new PurOrderLine();
            lq.setOrderId(po.getOrderId());
            WorkorderFullDetailVO.PurchaseDoc doc = new WorkorderFullDetailVO.PurchaseDoc();
            doc.setOrder(po);
            doc.setLines(purOrderLineService.selectPurOrderLineList(lq));
            result.add(doc);
        }
        return result;
    }

    // ────────────────────────── 加工单 ──────────────────────────

    private void saveProcessDocs(ProWorkorder wo, List<WorkorderProcDocVO> docs)
    {
        if (docs == null || docs.isEmpty())
        {
            return;
        }
        for (WorkorderProcDocVO doc : docs)
        {
            if (doc.getLines() == null || doc.getLines().isEmpty())
            {
                throw new ServiceException("加工单[" + safe(doc.getDocTitle()) + "]至少需要一道工序");
            }
            boolean inside = "INSIDE".equalsIgnoreCase(doc.getSupplierType());
            if (!inside && doc.getVendorId() == null)
            {
                throw new ServiceException("加工单[" + safe(doc.getDocTitle()) + "]请选择加工商");
            }
            OutsourceRequest req = new OutsourceRequest();
            req.setDraft(true);
            req.setSupplierType(inside ? "INSIDE" : "OUTSIDE");
            req.setVendorId(doc.getVendorId());
            req.setVendorCode(doc.getVendorCode());
            req.setVendorName(doc.getVendorName());
            req.setWorkorderId(wo.getWorkorderId());
            req.setWorkorderCode(wo.getWorkorderCode());
            req.setRouteId(resolveRouteId(wo));
            req.setDocTitle(doc.getDocTitle());
            req.setOrderDate(parseDate(doc.getOrderDate(), new Date()));
            req.setExpectedDate(parseDate(doc.getExpectedDate(), null));
            req.setPurchaser(doc.getPurchaser());
            req.setSourceOrderCode(StringUtils.isEmpty(doc.getSourceOrderCode())
                    ? wo.getClientOrderCode() : doc.getSourceOrderCode());
            req.setDeliveryAddress(doc.getDeliveryAddress());
            req.setRemark(doc.getRemark());
            req.setProcessLines(buildProcLines(doc.getLines()));
            outsourceService.createOutsource(req);
        }
    }

    private List<WmOutsourceProcessLine> buildProcLines(List<WorkorderProcLineVO> lines)
    {
        List<WmOutsourceProcessLine> rows = new ArrayList<>();
        for (WorkorderProcLineVO l : lines)
        {
            if (l.getProcessId() == null)
            {
                throw new ServiceException("加工单工序不能为空");
            }
            WmOutsourceProcessLine line = new WmOutsourceProcessLine();
            line.setProcessId(l.getProcessId());
            line.setProcessCode(l.getProcessCode());
            line.setProcessName(l.getProcessName());
            line.setProductName(l.getProductName());
            BigDecimal qty = nvl(l.getPlanQty());
            BigDecimal price = nvl(l.getUnitPrice());
            line.setPlanQty(qty);
            line.setDoneQty(BigDecimal.ZERO);
            line.setUnitPrice(price);
            line.setAmount(qty.multiply(price).setScale(2, java.math.RoundingMode.HALF_UP));
            line.setExpectedDate(parseDate(l.getExpectedDate(), null));
            line.setVendorId(l.getVendorId());
            line.setVendorCode(l.getVendorCode());
            line.setVendorName(l.getVendorName());
            line.setExtAttrs(toJson(l.getExtAttrs()));
            line.setRemark(l.getRemark());
            rows.add(line);
        }
        return rows;
    }

    private String toJson(Map<String, Object> attrs)
    {
        if (attrs == null || attrs.isEmpty())
        {
            return null;
        }
        return JSON.toJSONString(attrs);
    }

    private List<WmOutsourceOrder> loadProcessDocs(Long workorderId)
    {
        List<WmOutsourceOrder> orders = outsourceOrderMapper.selectByWorkorderId(workorderId);
        if (orders == null)
        {
            return new ArrayList<>();
        }
        for (WmOutsourceOrder o : orders)
        {
            o.setProcessLines(processLineMapper.selectByOrderId(o.getOrderId()));
        }
        return orders;
    }

    private Long resolveRouteId(ProWorkorder wo)
    {
        if (wo == null || wo.getRouteProductId() == null)
        {
            return null;
        }
        ProRouteProduct rp = routeProductService.selectProRouteProductByRecordId(wo.getRouteProductId());
        return rp != null ? rp.getRouteId() : null;
    }

    // ────────────────────────── 工具 ──────────────────────────

    private String safe(String s)
    {
        return s == null ? "" : s;
    }

    private BigDecimal nvl(BigDecimal v)
    {
        return v == null ? BigDecimal.ZERO : v;
    }

    private Date parseDate(String s, Date fallback)
    {
        if (StringUtils.isEmpty(s))
        {
            return fallback;
        }
        try
        {
            if (s.length() > 10)
            {
                return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(s);
            }
            return new SimpleDateFormat("yyyy-MM-dd").parse(s);
        }
        catch (Exception e)
        {
            return fallback;
        }
    }
}
