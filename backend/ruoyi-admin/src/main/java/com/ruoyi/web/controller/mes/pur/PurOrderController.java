package com.ruoyi.web.controller.mes.pur;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.system.domain.mes.pur.PurOrder;
import com.ruoyi.system.domain.mes.pur.vo.PurOrderDetailVO;
import com.ruoyi.system.domain.mes.pur.vo.PurOrderVO;
import com.ruoyi.system.service.mes.pur.IPurOrderService;
import com.ruoyi.common.utils.file.FileUtils;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.web.controller.mes.pur.export.PurOrderDetailExcelExporter;
import com.ruoyi.web.controller.mes.pur.export.PurOrderPdfExporter;

/**
 * 采购订单头Controller
 * 
 * @author ruoyi
 * @date 2026-06-14
 */
@RestController
@RequestMapping("/mes/pur/order")
public class PurOrderController extends BaseController
{
    @Autowired
    private IPurOrderService purOrderService;

    @Autowired
    private PurOrderPdfExporter pdfExporter;

    @Autowired
    private PurOrderDetailExcelExporter excelExporter;

    @Autowired
    private com.ruoyi.system.service.mes.pro.IProWorkorderService proWorkorderService;

    /**
     * 查询采购订单头列表
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:list')")
    @GetMapping("/list")
    public TableDataInfo list(PurOrder purOrder)
    {
        startPage();
        List<PurOrderVO> list = purOrderService.selectPurOrderList(purOrder);
        return getDataTable(list);
    }

    /**
     * 导出采购订单头列表
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:export')")
    @Log(title = "采购订单头", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, PurOrder purOrder)
    {
        List<PurOrderVO> list = purOrderService.selectPurOrderList(purOrder);
        ExcelUtil<PurOrderVO> util = new ExcelUtil<PurOrderVO>(PurOrderVO.class);
        util.exportExcel(response, list, "采购订单头数据");
    }

    /**
     * 获取采购订单头详细信息（编辑表单用，返回头+行）
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:query')")
    @GetMapping(value = "/{orderId}")
    public AjaxResult getInfo(@PathVariable("orderId") Long orderId)
    {
        PurOrderDetailVO detail = purOrderService.getDetail(orderId);
        if (detail == null) {
            return error("采购订单不存在");
        }
        return success(detail);
    }

    /**
     * 按订单编码查询采购订单头+行（一次拿全，移动端扫码/搜索收货用）
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:query')")
    @GetMapping("/byCode")
    public AjaxResult getInfoByCode(@RequestParam("orderCode") String orderCode)
    {
        PurOrderDetailVO detail = purOrderService.selectPurOrderDetailByOrderCode(orderCode);
        if (detail == null) {
            return error("采购订单不存在");
        }
        return success(detail);
    }

    /**
     * 获取采购订单详情（头+行，供详情页/导出复用）
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:query')")
    @GetMapping("/detail/{orderId}")
    public AjaxResult getDetail(@PathVariable("orderId") Long orderId)
    {
        PurOrderDetailVO detail = purOrderService.getDetail(orderId);
        if (detail == null) {
            return error("采购订单不存在");
        }
        return success(detail);
    }

    /**
     * 导出采购订单详情为 PDF（对外版）
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:exportDetail')")
    @Log(title = "采购订单明细PDF", businessType = BusinessType.EXPORT)
    @PostMapping("/exportPdf/{orderId}")
    public void exportPdf(@PathVariable("orderId") Long orderId, HttpServletResponse response) throws IOException
    {
        PurOrderDetailVO detail = purOrderService.getDetail(orderId);
        if (detail == null) throw new ServiceException("采购订单不存在");
        FileUtils.setAttachmentResponseHeader(response, "采购订单_" + detail.getOrder().getOrderCode() + ".pdf");
        response.setContentType("application/pdf");
        response.setCharacterEncoding("utf-8");
        try
        {
            pdfExporter.write(detail, response.getOutputStream());
        }
        catch (Exception e)
        {
            throw new IOException("导出PDF失败", e);
        }
    }

    /**
     * 导出采购订单详情为 Excel（对内版）
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:exportDetail')")
    @Log(title = "采购订单明细Excel", businessType = BusinessType.EXPORT)
    @PostMapping("/exportExcel/{orderId}")
    public void exportExcel(@PathVariable("orderId") Long orderId, HttpServletResponse response) throws IOException
    {
        PurOrderDetailVO detail = purOrderService.getDetail(orderId);
        if (detail == null) throw new ServiceException("采购订单不存在");
        FileUtils.setAttachmentResponseHeader(response, "采购订单_" + detail.getOrder().getOrderCode() + ".xlsx");
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        try
        {
            excelExporter.write(detail, response.getOutputStream());
        }
        catch (Exception e)
        {
            throw new IOException("导出Excel失败", e);
        }
    }

    /**
     * 单据模板导出（开单页）：单张采购单 Excel
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:export')")
    @PostMapping("/doc/{orderId}/excel")
    public void exportDocExcel(@PathVariable Long orderId, HttpServletResponse response) throws IOException
    {
        PurOrderDetailVO detail = purOrderService.getDetail(orderId);
        if (detail == null) throw new ServiceException("采购订单不存在");
        com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model m = buildDocModel(detail);
        write(response, m, detail.getOrder().getOrderCode(), "xlsx");
    }

    /**
     * 单据模板导出（开单页）：单张采购单 PDF 打印
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:export')")
    @PostMapping("/doc/{orderId}/pdf")
    public void exportDocPdf(@PathVariable Long orderId, HttpServletResponse response) throws IOException
    {
        PurOrderDetailVO detail = purOrderService.getDetail(orderId);
        if (detail == null) throw new ServiceException("采购订单不存在");
        com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model m = buildDocModel(detail);
        write(response, m, detail.getOrder().getOrderCode(), "pdf");
    }

    /**
     * 同供应商多张采购单合并导出
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:export')")
    @PostMapping("/docMerge/{format}")
    public void exportDocMerge(@PathVariable String format, @RequestBody List<Long> orderIds,
                               HttpServletResponse response) throws IOException
    {
        if (orderIds == null || orderIds.isEmpty()) throw new ServiceException("请选择要合并的单据");
        com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model m = new com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model();
        m.title = "合并采购单";
        m.partyLabel = "供应商：";
        m.headers.add("产品名称");
        m.headers.add("业务单号");
        m.headers.add("产品尺寸");
        m.headers.add("材质及工艺");
        m.headers.add("数量");
        m.headers.add("单价");
        m.headers.add("总金额(元)");
        m.headers.add("送货日期");
        m.headers.add("备注");
        for (Long id : orderIds)
        {
            PurOrderDetailVO d = purOrderService.getDetail(id);
            if (d == null) continue;
            PurOrderVO o = d.getOrder();
            if (m.partyName == null) m.partyName = o.getVendorName();
            if (m.deliveryAddress == null) m.deliveryAddress = o.getDeliveryAddress();
            if (m.purchaser == null) m.purchaser = o.getPurchaser();
            if (m.orderDate == null) m.orderDate = com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmtDate(o.getOrderDate());
            java.util.List<String> row = new java.util.ArrayList<>();
            row.add(productNameOf(o.getWorkorderId(), o.getWorkorderCode()));
            row.add(o.getSourceOrderCode());
            java.math.BigDecimal qty = o.getTotalQuantity() == null ? java.math.BigDecimal.ZERO : o.getTotalQuantity();
            java.math.BigDecimal amt = o.getTotalAmount() == null ? java.math.BigDecimal.ZERO : o.getTotalAmount();
            row.add(workorderSize(o.getWorkorderId()));
            row.add(o.getOrderName());
            row.add(com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmt(qty));
            row.add(qty.signum() == 0 ? "" : amt.divide(qty, 4, java.math.RoundingMode.HALF_UP).toPlainString());
            row.add(com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmt(amt));
            row.add(d.getLines() != null && !d.getLines().isEmpty()
                    ? com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmtDate(d.getLines().get(0).getExpectedDate()) : "");
            row.add(o.getRemark());
            m.rows.add(row);
            m.total = m.total.add(amt);
        }
        m.docCode = "共 " + m.rows.size() + " 张";
        write(response, m, "合并采购单", format);
    }

    private com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model buildDocModel(PurOrderDetailVO detail)
    {
        PurOrderVO o = detail.getOrder();
        com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model m =
                new com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model();
        m.title = o.getDocTitle() != null ? o.getDocTitle() : purchaseTitle(o.getPurchaseType());
        m.partyName = o.getVendorName();
        m.bizNo = o.getSourceOrderCode();
        m.docCode = o.getOrderCode();
        m.deliveryAddress = o.getDeliveryAddress();
        m.purchaser = o.getPurchaser();
        m.orderDate = com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmtDate(o.getOrderDate());
        m.productImage = workorderImage(o.getWorkorderId());
        boolean rope = "AUX".equalsIgnoreCase(o.getPurchaseType());
        m.headers.add("产品名称");
        m.headers.add(rope ? "材料+工艺" : "材料名称");
        if (!rope) m.headers.add("品牌");
        m.headers.add("规格");
        m.headers.add("数量");
        m.headers.add("单位");
        m.headers.add("单价");
        m.headers.add("总金额(元）");
        m.headers.add("送货日期");
        m.headers.add("订单编号");
        m.headers.add("备注");
        String productName = productNameOf(o.getWorkorderId(), o.getWorkorderCode());
        for (com.ruoyi.system.domain.mes.pur.PurOrderLine l : detail.getLines())
        {
            java.util.List<String> row = new java.util.ArrayList<>();
            row.add(l.getProductName() != null && !l.getProductName().isBlank() ? l.getProductName() : productName);
            row.add(l.getItemName());
            if (!rope)
            {
                java.util.Map<String, Object> attrs =
                        com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.parseAttrs(null);
                if (l.getLineAttrs() != null && l.getLineAttrs().get("BRAND") != null)
                {
                    attrs.put("BRAND", l.getLineAttrs().get("BRAND"));
                }
                row.add(attrs.get("BRAND") == null ? "" : String.valueOf(attrs.get("BRAND")));
            }
            row.add(l.getSpecification());
            row.add(com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmt(l.getQuantityOrdered()));
            row.add(l.getUnitName());
            row.add(com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmt(l.getUnitPrice()));
            row.add(com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmt(l.getAmount()));
            row.add(com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmtDate(l.getExpectedDate()));
            row.add(l.getSourceOrderCode() != null ? l.getSourceOrderCode() : o.getSourceOrderCode());
            row.add(l.getRemark());
            m.rows.add(row);
            if (l.getAmount() != null) m.total = m.total.add(l.getAmount());
        }
        return m;
    }

    private String purchaseTitle(String type)
    {
        if ("PAPER".equalsIgnoreCase(type) || "RAW".equalsIgnoreCase(type)) return "原材料采购单";
        if ("AUX".equalsIgnoreCase(type)) return "绳子采购单";
        if ("PACK".equalsIgnoreCase(type)) return "包材采购单";
        return "采购单";
    }

    private String productNameOf(Long workorderId, String fallback)
    {
        if (workorderId == null) return fallback == null ? "" : fallback;
        com.ruoyi.system.domain.mes.pro.ProWorkorder wo = proWorkorderService.selectProWorkorderByWorkorderId(workorderId);
        return wo != null ? wo.getProductName() : (fallback == null ? "" : fallback);
    }

    private String workorderSize(Long workorderId)
    {
        if (workorderId == null) return "";
        com.ruoyi.system.domain.mes.pro.ProWorkorder wo = proWorkorderService.selectProWorkorderByWorkorderId(workorderId);
        return wo != null && wo.getProductSize() != null ? wo.getProductSize() : "";
    }

    private String workorderImage(Long workorderId)
    {
        if (workorderId == null) return null;
        com.ruoyi.system.domain.mes.pro.ProWorkorder wo = proWorkorderService.selectProWorkorderByWorkorderId(workorderId);
        return wo != null ? wo.getProductImage() : null;
    }

    private void write(HttpServletResponse response,
                       com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model m,
                       String code, String format) throws IOException
    {
        boolean excel = "excel".equalsIgnoreCase(format) || "xlsx".equalsIgnoreCase(format);
        String suffix = excel ? ".xlsx" : ".pdf";
        FileUtils.setAttachmentResponseHeader(response, "单据_" + code + suffix);
        response.setContentType(excel
                ? "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                : "application/pdf");
        response.setCharacterEncoding("utf-8");
        try
        {
            if (excel)
            {
                com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.writeExcel(m, response.getOutputStream());
            }
            else
            {
                com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.writePdf(m, response.getOutputStream());
            }
        }
        catch (Exception e)
        {
            throw new IOException("导出单据失败", e);
        }
    }

    /**
     * 新增采购订单头
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:add')")
    @Log(title = "采购订单头", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody PurOrder purOrder)
    {
        int rows = purOrderService.insertPurOrder(purOrder);
        return toAjax(rows, purOrder, "新增采购订单失败");
    }

    /**
     * 修改采购订单头
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:edit')")
    @Log(title = "采购订单头", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody PurOrder purOrder)
    {
        // 已下单/收货中/已收货等状态只读，避免下达后仍被篡改
        purOrderService.assertUserEditable(purOrder.getOrderId());
        return toAjax(purOrderService.updatePurOrder(purOrder));
    }

    /**
     * 删除采购订单头
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:remove')")
    @Log(title = "采购订单头", businessType = BusinessType.DELETE)
	@DeleteMapping("/{orderIds}")
    public AjaxResult remove(@PathVariable Long[] orderIds)
    {
        return toAjax(purOrderService.deletePurOrderByOrderIds(orderIds));
    }

    /**
     * 审批采购订单（DRAFT → APPROVED）
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:approve')")
    @Log(title = "采购订单审批", businessType = BusinessType.UPDATE)
    @PostMapping("/{orderId}/approve")
    public AjaxResult approve(@PathVariable Long orderId)
    {
        try {
            purOrderService.approvePurOrder(orderId);
            return success();
        } catch (RuntimeException e) {
            return error(e.getMessage());
        }
    }

    /**
     * 驳回采购订单（APPROVED/ORDERED → DRAFT），修改后可重新审批
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:approve')")
    @Log(title = "采购订单驳回", businessType = BusinessType.UPDATE)
    @PostMapping("/{orderId}/reject")
    public AjaxResult reject(@PathVariable Long orderId,
                             @RequestParam(value = "rejectReason") String rejectReason)
    {
        try {
            purOrderService.rejectPurOrder(orderId, rejectReason);
            return success();
        } catch (RuntimeException e) {
            return error(e.getMessage());
        }
    }

    /**
     * 下达采购订单（APPROVED → ORDERED）
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:order')")
    @Log(title = "采购订单下达", businessType = BusinessType.UPDATE)
    @PostMapping("/{orderId}/order")
    public AjaxResult order(@PathVariable Long orderId)
    {
        try {
            purOrderService.orderPurOrder(orderId);
            return success();
        } catch (RuntimeException e) {
            return error(e.getMessage());
        }
    }

    /**
     * 关闭采购订单（RECEIVED -> CLOSED 正常关闭，RECEIVING -> CLOSED 强制关闭）
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:close')")
    @Log(title = "采购订单关闭", businessType = BusinessType.UPDATE)
    @PostMapping("/{orderId}/close")
    public AjaxResult close(@PathVariable Long orderId,
                            @RequestParam(value = "closeReason", required = false) String closeReason)
    {
        try {
            purOrderService.closePurOrder(orderId, closeReason);
            return success();
        } catch (RuntimeException e) {
            return error(e.getMessage());
        }
    }

    /** 人工改采购单状态（一期弱化流程，不校验流转） */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:changeStatus')")
    @Log(title = "采购单改状态", businessType = BusinessType.UPDATE)
    @PutMapping("/changeStatus")
    public AjaxResult changeStatus(@RequestBody java.util.Map<String, Object> req)
    {
        Object orderId = req.get("orderId");
        Object status = req.get("targetStatus");
        Object reason = req.get("reason");
        if (orderId == null || status == null) return error("orderId 与 targetStatus 不能为空");
        try
        {
            purOrderService.changeStatus(Long.valueOf(orderId.toString()), status.toString(),
                    reason == null ? null : reason.toString());
            return success();
        }
        catch (RuntimeException e)
        {
            return error(e.getMessage());
        }
    }

    /**
     * 取消采购订单（DRAFT/APPROVED/ORDERED -> CANCEL）
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:cancel')")
    @Log(title = "采购订单取消", businessType = BusinessType.UPDATE)
    @PostMapping("/{orderId}/cancel")
    public AjaxResult cancel(@PathVariable Long orderId,
                             @RequestParam(value = "cancelReason", required = false) String cancelReason)
    {
        try {
            purOrderService.cancelPurOrder(orderId, cancelReason);
            return success();
        } catch (RuntimeException e) {
            return error(e.getMessage());
        }
    }

    /**
     * 取消采购订单行（ORDERED/RECEIVING -> CANCEL）
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:cancel')")
    @Log(title = "采购订单行取消", businessType = BusinessType.UPDATE)
    @PostMapping("/line/{lineId}/cancel")
    public AjaxResult cancelLine(@PathVariable Long lineId,
                                 @RequestParam(value = "cancelReason", required = false) String cancelReason)
    {
        try {
            purOrderService.cancelPurOrderLine(lineId, cancelReason);
            return success();
        } catch (RuntimeException e) {
            return error(e.getMessage());
        }
    }

    /**
     * 终止收货采购订单行（RECEIVING -> CLOSED）
     */
    @PreAuthorize("@ss.hasPermi('mes:pur:order:close')")
    @Log(title = "采购订单行终止收货", businessType = BusinessType.UPDATE)
    @PostMapping("/line/{lineId}/terminate")
    public AjaxResult terminateLine(@PathVariable Long lineId,
                                    @RequestParam(value = "closeReason", required = false) String closeReason)
    {
        try {
            purOrderService.terminatePurOrderLine(lineId, closeReason);
            return success();
        } catch (RuntimeException e) {
            return error(e.getMessage());
        }
    }
}
