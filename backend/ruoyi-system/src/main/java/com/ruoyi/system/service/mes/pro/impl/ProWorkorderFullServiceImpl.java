package com.ruoyi.system.service.mes.pro.impl;

import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
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
import com.ruoyi.system.domain.mes.sal.SalOrder;
import com.ruoyi.system.domain.mes.sal.SalOrderLine;
import com.ruoyi.system.domain.mes.pur.PurOrder;
import com.ruoyi.system.domain.mes.pur.PurOrderLine;
import com.ruoyi.system.domain.mes.pur.vo.PurOrderVO;
import com.ruoyi.system.domain.mes.wm.OutsourceRequest;
import com.ruoyi.system.domain.mes.wm.WmOutsourceOrder;
import com.ruoyi.system.domain.mes.wm.WmOutsourceProcessLine;
import com.ruoyi.system.mapper.mes.pro.ProWorkorderProcessMapper;
import com.ruoyi.system.mapper.mes.pur.PurOrderMapper;
import com.ruoyi.system.mapper.mes.sal.SalOrderLineMapper;
import com.ruoyi.system.mapper.mes.sal.SalOrderMapper;
import com.ruoyi.system.mapper.mes.wm.WmOutsourceLineMapper;
import com.ruoyi.system.mapper.mes.wm.WmOutsourceOrderMapper;
import com.ruoyi.system.mapper.mes.wm.WmOutsourceProcessLineMapper;
import com.ruoyi.system.service.mes.common.MesQuantityService;
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
    @Autowired private WmOutsourceLineMapper outsourceLineMapper;
    @Autowired private SalOrderLineMapper salOrderLineMapper;
    @Autowired private SalOrderMapper salOrderMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ProWorkorder createFull(WorkorderFullSubmitVO body)
    {
        if (body == null || body.getWorkorder() == null)
        {
            throw new ServiceException("工单信息不能为空");
        }
        if (body.getWorkorder().getOwnerId() == null)
        {
            throw new ServiceException("请选择工单负责人");
        }
        ensureRouteProductBinding(body.getWorkorder(), body.getRouteProcesses());
        validateSalesOrderLink(body.getWorkorder());
        ProWorkorder wo = workorderService.createWorkorderWithBom(
                body.getWorkorder(), body.getBomList(), body.getParamList());
        saveRouteSnapshot(wo.getWorkorderId(), body.getRouteProcesses());
        savePurchaseDocs(wo, body.getPurchaseDocs());
        saveProcessDocs(wo, body.getProcessDocs());
        return wo;
    }

    /** 复制/开单关联销售订单行时校验：行存在、来源订单一致、数量不超过可转量 */
    private void validateSalesOrderLink(ProWorkorder wo)
    {
        if (wo == null || wo.getSalesOrderLineId() == null)
        {
            return;
        }
        SalOrderLine line = salOrderLineMapper.selectSalOrderLineByLineId(wo.getSalesOrderLineId());
        if (line == null)
        {
            throw new ServiceException("销售订单明细行不存在");
        }
        if (StringUtils.isNotEmpty(wo.getSourceCode()))
        {
            SalOrder order = salOrderMapper.selectSalOrderByOrderId(line.getOrderId());
            if (order == null || !wo.getSourceCode().equals(order.getOrderCode()))
            {
                throw new ServiceException("来源销售订单与所选明细行不匹配");
            }
        }
        BigDecimal produced = salOrderLineMapper.sumProducedQtyByLineId(wo.getSalesOrderLineId());
        BigDecimal total = line.getQuantity() == null ? BigDecimal.ZERO : line.getQuantity();
        BigDecimal convertible = total.subtract(produced == null ? BigDecimal.ZERO : produced);
        if (wo.getQuantity() != null && wo.getQuantity().compareTo(convertible) > 0)
        {
            throw new ServiceException("工单数量超过销售订单可转数量(" + convertible + ")");
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ProWorkorder updateFull(Long workorderId, WorkorderFullSubmitVO body)
    {
        if (workorderId == null || body == null || body.getWorkorder() == null)
        {
            throw new ServiceException("工单信息不能为空");
        }
        if (body.getWorkorder().getOwnerId() == null)
        {
            throw new ServiceException("请选择工单负责人");
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

    // ────────────────────────── 复制模板 ──────────────────────────

    /**
     * 复制模板：只保留定义层数据（表头/BOM/工序/单据明细），清空主键、单号、
     * 状态与执行数据，前端微调后仍走 createFull 保存为新工单。
     */
    @Override
    public WorkorderFullDetailVO getCopyTemplate(Long workorderId)
    {
        if (workorderId == null)
        {
            throw new ServiceException("工单ID不能为空");
        }
        if (workorderService.selectProWorkorderByWorkorderId(workorderId) == null)
        {
            throw new ServiceException("工单不存在");
        }
        WorkorderFullDetailVO source = getFullDetail(workorderId);
        if (source == null || source.getWorkorder() == null)
        {
            throw new ServiceException("工单不存在");
        }
        WorkorderFullDetailVO copy = new WorkorderFullDetailVO();
        copy.setWorkorder(resetWorkorderForCopy(source.getWorkorder()));
        copy.setBomList(resetBomForCopy(source.getBomList()));
        copy.setParamList(resetParamForCopy(source.getParamList()));
        copy.setRouteProcesses(source.getRouteProcesses());
        copy.setPurchaseDocs(resetPurchaseDocsForCopy(source.getPurchaseDocs()));
        copy.setProcessDocs(resetProcessDocsForCopy(source.getProcessDocs()));
        return copy;
    }

    /** 表头：保留业务内容，重置单号/状态/数量进度/流转单生成字段 */
    private ProWorkorder resetWorkorderForCopy(ProWorkorder src)
    {
        ProWorkorder wo = new ProWorkorder();
        wo.setWorkorderName(src.getWorkorderName());
        wo.setWorkorderType(src.getWorkorderType());
        wo.setOrderSource(src.getOrderSource());
        wo.setSourceCode(src.getSourceCode());
        wo.setSalesOrderLineId(src.getSalesOrderLineId());
        wo.setProductId(src.getProductId());
        wo.setProductCode(src.getProductCode());
        wo.setProductName(src.getProductName());
        wo.setProductSpc(src.getProductSpc());
        wo.setRouteProductId(src.getRouteProductId());
        wo.setOwnerId(src.getOwnerId());
        wo.setOwnerName(src.getOwnerName());
        wo.setUnitOfMeasure(src.getUnitOfMeasure());
        wo.setUnitName(src.getUnitName());
        wo.setQuantity(src.getQuantity());
        wo.setClientId(src.getClientId());
        wo.setClientCode(src.getClientCode());
        wo.setClientName(src.getClientName());
        wo.setClientOrderCode(src.getClientOrderCode());
        wo.setProductSize(src.getProductSize());
        wo.setPrintingReq(src.getPrintingReq());
        wo.setRopeSpec(src.getRopeSpec());
        wo.setPackageReq(src.getPackageReq());
        wo.setShippingReq(src.getShippingReq());
        wo.setLineAttrs(src.getLineAttrs());
        wo.setOrderType(src.getOrderType());
        wo.setVendorId(src.getVendorId());
        wo.setVendorCode(src.getVendorCode());
        wo.setVendorName(src.getVendorName());
        wo.setOutsourceFactoryId(src.getOutsourceFactoryId());
        wo.setOrderDate(src.getOrderDate());
        wo.setTitle(src.getTitle());
        wo.setBagMouth(src.getBagMouth());
        wo.setBottomBoard(src.getBottomBoard());
        wo.setMaterial(src.getMaterial());
        wo.setMaterialGram(src.getMaterialGram());
        wo.setRollWidth(src.getRollWidth());
        wo.setLossRate(src.getLossRate());
        wo.setOrderWeight(src.getOrderWeight());
        wo.setPlateCircumference(src.getPlateCircumference());
        wo.setProcessFlow(src.getProcessFlow());
        wo.setProductImage(src.getProductImage());
        wo.setSalesperson(src.getSalesperson());
        wo.setRequestDate(src.getRequestDate());
        wo.setRemark(src.getRemark());
        wo.setStatus("PREPARE");
        return wo;
    }

    /** BOM：清主键/工单号；按件用量清空总量，交后端按新工单数量重算 */
    private List<ProWorkorderBom> resetBomForCopy(List<ProWorkorderBom> src)
    {
        List<ProWorkorderBom> rows = new ArrayList<>();
        if (src == null)
        {
            return rows;
        }
        for (ProWorkorderBom s : src)
        {
            ProWorkorderBom b = new ProWorkorderBom();
            b.setItemId(s.getItemId());
            b.setItemCode(s.getItemCode());
            b.setItemName(s.getItemName());
            b.setItemSpc(s.getItemSpc());
            b.setUnitOfMeasure(s.getUnitOfMeasure());
            b.setUnitName(s.getUnitName());
            b.setUnit2(s.getUnit2());
            b.setUnit2Name(s.getUnit2Name());
            b.setConversionRate(s.getConversionRate());
            b.setProcessId(s.getProcessId());
            b.setProcessName(s.getProcessName());
            b.setItemOrProduct(s.getItemOrProduct());
            b.setQuantity(s.getQuantity());
            b.setQuantityMode(s.getQuantityMode());
            b.setBomSource(s.getBomSource());
            b.setScrapRate(s.getScrapRate());
            if (!MesQuantityService.MODE_TOTAL.equals(s.getQuantityMode()))
            {
                b.setTotalQuantity(null);
                b.setTotalQuantity2(null);
            }
            else
            {
                b.setTotalQuantity(s.getTotalQuantity());
                b.setTotalQuantity2(s.getTotalQuantity2());
            }
            rows.add(b);
        }
        return rows;
    }

    /** 工序参数：清主键/工单号 */
    private List<Map<String, Object>> resetParamForCopy(List<Map<String, Object>> src)
    {
        List<Map<String, Object>> rows = new ArrayList<>();
        if (src == null)
        {
            return rows;
        }
        for (Map<String, Object> s : src)
        {
            Map<String, Object> p = new java.util.LinkedHashMap<>(s);
            p.remove("recordId");
            p.remove("workorderId");
            p.remove("factoryId");
            rows.add(p);
        }
        return rows;
    }

    /** 采购单：保留供应商/日期/明细，清空单号、状态与金额汇总 */
    private List<WorkorderFullDetailVO.PurchaseDoc> resetPurchaseDocsForCopy(
            List<WorkorderFullDetailVO.PurchaseDoc> src)
    {
        List<WorkorderFullDetailVO.PurchaseDoc> docs = new ArrayList<>();
        if (src == null)
        {
            return docs;
        }
        for (WorkorderFullDetailVO.PurchaseDoc s : src)
        {
            PurOrderVO o = s.getOrder();
            if (o == null)
            {
                continue;
            }
            PurOrderVO order = new PurOrderVO();
            order.setDocTitle(o.getDocTitle());
            order.setVendorId(o.getVendorId());
            order.setVendorCode(o.getVendorCode());
            order.setVendorName(o.getVendorName());
            order.setPurchaseType(o.getPurchaseType());
            order.setOrderDate(o.getOrderDate());
            order.setExpectedDate(o.getExpectedDate());
            order.setPurchaser(o.getPurchaser());
            order.setSourceOrderCode(o.getSourceOrderCode());
            order.setDeliveryAddress(o.getDeliveryAddress());
            order.setCurrency(o.getCurrency());
            order.setRemark(o.getRemark());
            WorkorderFullDetailVO.PurchaseDoc doc = new WorkorderFullDetailVO.PurchaseDoc();
            doc.setOrder(order);
            doc.setLines(resetPurLinesForCopy(s.getLines()));
            docs.add(doc);
        }
        return docs;
    }

    private List<PurOrderLine> resetPurLinesForCopy(List<PurOrderLine> src)
    {
        List<PurOrderLine> lines = new ArrayList<>();
        if (src == null)
        {
            return lines;
        }
        for (PurOrderLine s : src)
        {
            PurOrderLine l = new PurOrderLine();
            l.setItemId(s.getItemId());
            l.setItemCode(s.getItemCode());
            l.setItemName(s.getItemName());
            l.setProductName(s.getProductName());
            l.setSpecification(s.getSpecification());
            l.setUnitOfMeasure(s.getUnitOfMeasure());
            l.setUnitName(s.getUnitName());
            l.setUnit2(s.getUnit2());
            l.setUnit2Name(s.getUnit2Name());
            l.setConversionRate(s.getConversionRate());
            l.setProcessId(s.getProcessId());
            l.setProcessCode(s.getProcessCode());
            l.setProcessName(s.getProcessName());
            l.setQuantityOrdered(s.getQuantityOrdered());
            l.setQuantityOrdered2(s.getQuantityOrdered2());
            l.setUnitPrice(s.getUnitPrice());
            l.setAmount(s.getAmount());
            l.setTaxRate(s.getTaxRate());
            l.setLineAttrs(s.getLineAttrs());
            l.setExpectedDate(s.getExpectedDate());
            l.setRemark(s.getRemark());
            lines.add(l);
        }
        return lines;
    }

    /** 加工单：保留加工商/日期/工序明细，清空单号、状态与发料收货进度 */
    private List<WmOutsourceOrder> resetProcessDocsForCopy(List<WmOutsourceOrder> src)
    {
        List<WmOutsourceOrder> docs = new ArrayList<>();
        if (src == null)
        {
            return docs;
        }
        for (WmOutsourceOrder s : src)
        {
            WmOutsourceOrder o = new WmOutsourceOrder();
            o.setSupplierType(s.getSupplierType());
            o.setVendorId(s.getVendorId());
            o.setVendorCode(s.getVendorCode());
            o.setVendorName(s.getVendorName());
            o.setRouteId(s.getRouteId());
            o.setDocTitle(s.getDocTitle());
            o.setOrderDate(s.getOrderDate());
            o.setExpectedDate(s.getExpectedDate());
            o.setPurchaser(s.getPurchaser());
            o.setSourceOrderCode(s.getSourceOrderCode());
            o.setDeliveryAddress(s.getDeliveryAddress());
            o.setRemark(s.getRemark());
            o.setProcessLines(resetProcLinesForCopy(s.getProcessLines()));
            docs.add(o);
        }
        return docs;
    }

    private List<WmOutsourceProcessLine> resetProcLinesForCopy(List<WmOutsourceProcessLine> src)
    {
        List<WmOutsourceProcessLine> lines = new ArrayList<>();
        if (src == null)
        {
            return lines;
        }
        for (WmOutsourceProcessLine s : src)
        {
            WmOutsourceProcessLine l = new WmOutsourceProcessLine();
            l.setSeq(s.getSeq());
            l.setVendorId(s.getVendorId());
            l.setVendorCode(s.getVendorCode());
            l.setVendorName(s.getVendorName());
            l.setProcessId(s.getProcessId());
            l.setProcessCode(s.getProcessCode());
            l.setProcessName(s.getProcessName());
            l.setProductName(s.getProductName());
            l.setPlanQty(s.getPlanQty());
            l.setDoneQty(BigDecimal.ZERO);
            l.setUnitPrice(s.getUnitPrice());
            l.setAmount(s.getAmount());
            l.setExpectedDate(s.getExpectedDate());
            l.setExtAttrs(s.getExtAttrs());
            l.setRemark(s.getRemark());
            lines.add(l);
        }
        return lines;
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
        Set<Long> submitted = new HashSet<>();
        if (docs != null)
        {
            for (WorkorderPurDocVO doc : docs)
            {
                validatePurDoc(doc);
                if (doc.getOrderId() != null)
                {
                    PurOrderVO exist = purOrderMapper.selectPurOrderByOrderId(doc.getOrderId());
                    if (exist != null && wo.getWorkorderId().equals(exist.getWorkorderId()))
                    {
                        // 已审批/已下单等非草稿采购单保持原样，不参与重建，避免重复下单
                        if (!STATUS_DRAFT.equals(exist.getStatus()))
                        {
                            submitted.add(exist.getOrderId());
                            continue;
                        }
                        updateDraftPurOrder(wo, doc, exist.getOrderId());
                        submitted.add(exist.getOrderId());
                        continue;
                    }
                }
                PurOrder created = createPurDoc(wo, doc);
                // 新建的单据也要纳入“本次已提交”，否则会被后面的未提交草稿清理误删
                if (created != null && created.getOrderId() != null)
                {
                    submitted.add(created.getOrderId());
                }
            }
        }
        // 用户在开单页移除的单据：删除其草稿采购单
        removeUnsubmittedDraftPurchase(wo.getWorkorderId(), submitted);
    }

    private void validatePurDoc(WorkorderPurDocVO doc)
    {
        if (doc.getVendorId() == null)
        {
            throw new ServiceException("采购单[" + safe(doc.getDocTitle()) + "]请选择供应商");
        }
        if (doc.getLines() == null || doc.getLines().isEmpty())
        {
            throw new ServiceException("采购单[" + safe(doc.getDocTitle()) + "]至少需要一行明细");
        }
    }

    private PurOrder createPurDoc(ProWorkorder wo, WorkorderPurDocVO doc)
    {
        PurOrder po = buildPurOrder(wo, doc);
        purOrderService.insertPurOrder(po);
        replacePurLines(po, doc.getLines());
        return po;
    }

    /** 草稿采购单就地更新：保留单号与单头主键，仅刷新单头与明细 */
    private void updateDraftPurOrder(ProWorkorder wo, WorkorderPurDocVO doc, Long orderId)
    {
        PurOrder po = buildPurOrder(wo, doc);
        po.setOrderId(orderId);
        // 状态不走该路径变更
        po.setStatus(null);
        purOrderService.updatePurOrder(po);
        purOrderLineService.deletePurOrderLineByOrderId(orderId);
        replacePurLines(po, doc.getLines());
    }

    /** 明细全量重建（草稿单无下游单据引用行ID），并回写单头总数量/总金额 */
    private void replacePurLines(PurOrder po, List<WorkorderPurLineVO> lines)
    {
        BigDecimal totalQty = BigDecimal.ZERO;
        BigDecimal totalAmount = BigDecimal.ZERO;
        for (WorkorderPurLineVO l : lines)
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

    private void removeUnsubmittedDraftPurchase(Long workorderId, Set<Long> submitted)
    {
        PurOrder q = new PurOrder();
        q.setWorkorderId(workorderId);
        q.setStatus(STATUS_DRAFT);
        List<PurOrderVO> pos = purOrderMapper.selectPurOrderList(q);
        if (pos == null)
        {
            return;
        }
        for (PurOrderVO po : pos)
        {
            if (submitted.contains(po.getOrderId()))
            {
                continue;
            }
            purOrderLineService.deletePurOrderLineByOrderId(po.getOrderId());
            purOrderMapper.deletePurOrderByOrderId(po.getOrderId());
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
        // 先清空草稿单头工序ID：首道工序变更时避免 uk_wo_process 中间态冲突
        List<WmOutsourceOrder> existing = outsourceOrderMapper.selectByWorkorderId(wo.getWorkorderId());
        if (existing != null)
        {
            for (WmOutsourceOrder o : existing)
            {
                if (STATUS_DRAFT.equals(o.getStatus()))
                {
                    outsourceOrderMapper.clearDraftProcessId(o.getOrderId());
                }
            }
        }
        Set<Long> submitted = new HashSet<>();
        if (docs != null)
        {
            for (WorkorderProcDocVO doc : docs)
            {
                validateProcDoc(doc);
                if (doc.getOrderId() != null)
                {
                    WmOutsourceOrder exist = outsourceOrderMapper.selectOutsourceOrderByOrderId(doc.getOrderId());
                    if (exist != null && wo.getWorkorderId().equals(exist.getWorkorderId()))
                    {
                        // 已发料/已签收等非草稿加工单保持原样，不参与重建
                        if (!STATUS_DRAFT.equals(exist.getStatus()))
                        {
                            submitted.add(exist.getOrderId());
                            continue;
                        }
                        updateDraftProcDoc(wo, doc, exist.getOrderId());
                        submitted.add(exist.getOrderId());
                        continue;
                    }
                }
                WmOutsourceOrder created = createProcDoc(wo, doc);
                // 新建的单据也要纳入“本次已提交”，否则会被后面的未提交草稿清理误删
                if (created != null && created.getOrderId() != null)
                {
                    submitted.add(created.getOrderId());
                }
            }
        }
        // 用户在开单页移除的单据：删除其草稿加工单（保留发料行以外的工序行一并清理）
        removeUnsubmittedDraftProcess(wo.getWorkorderId(), submitted);
    }

    private void validateProcDoc(WorkorderProcDocVO doc)
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
    }

    private WmOutsourceOrder createProcDoc(ProWorkorder wo, WorkorderProcDocVO doc)
    {
        boolean inside = "INSIDE".equalsIgnoreCase(doc.getSupplierType());
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
        return outsourceService.createOutsource(req);
    }

    /**
     * 草稿加工单就地更新：保留单号与发料行，仅刷新单头与工序行。
     * 工序行全量重建（发料行只关联 order_id，不引用工序行ID）。
     */
    private void updateDraftProcDoc(ProWorkorder wo, WorkorderProcDocVO doc, Long orderId)
    {
        boolean inside = "INSIDE".equalsIgnoreCase(doc.getSupplierType());
        List<WmOutsourceProcessLine> lines = buildProcLines(doc.getLines());
        WmOutsourceProcessLine first = lines.get(0);
        WmOutsourceOrder patch = new WmOutsourceOrder();
        patch.setOrderId(orderId);
        patch.setSupplierType(inside ? "INSIDE" : "OUTSIDE");
        patch.setVendorId(inside ? null : doc.getVendorId());
        patch.setVendorCode(inside ? null : doc.getVendorCode());
        patch.setVendorName(inside ? null : doc.getVendorName());
        patch.setDocTitle(doc.getDocTitle());
        patch.setOrderDate(parseDate(doc.getOrderDate(), new Date()));
        patch.setExpectedDate(parseDate(doc.getExpectedDate(), null));
        patch.setPurchaser(StringUtils.isEmpty(doc.getPurchaser()) ? SecurityUtils.getUsername() : doc.getPurchaser());
        patch.setSourceOrderCode(StringUtils.isEmpty(doc.getSourceOrderCode())
                ? wo.getClientOrderCode() : doc.getSourceOrderCode());
        patch.setDeliveryAddress(doc.getDeliveryAddress());
        patch.setRemark(doc.getRemark());
        patch.setRouteId(resolveRouteId(wo));
        patch.setProcessId(first.getProcessId());
        patch.setProcessCode(first.getProcessCode());
        patch.setProcessName(first.getProcessName());
        patch.setUpdateBy(SecurityUtils.getUsername());
        patch.setUpdateTime(new Date());
        outsourceOrderMapper.updateDraftHeaderForWorkorder(patch);
        outsourceService.saveProcessLines(orderId, lines);
    }

    private void removeUnsubmittedDraftProcess(Long workorderId, Set<Long> submitted)
    {
        List<WmOutsourceOrder> outs = outsourceOrderMapper.selectByWorkorderId(workorderId);
        if (outs == null)
        {
            return;
        }
        for (WmOutsourceOrder o : outs)
        {
            if (!STATUS_DRAFT.equals(o.getStatus()) || submitted.contains(o.getOrderId()))
            {
                continue;
            }
            processLineMapper.deleteByOrderId(o.getOrderId());
            outsourceLineMapper.deleteIssueLinesByOrderId(o.getOrderId());
            outsourceOrderMapper.deleteOutsourceOrderHardByOrderId(o.getOrderId());
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
