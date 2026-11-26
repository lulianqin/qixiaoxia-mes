package com.ruoyi.web.controller.mes.wm;

import java.util.List;
import jakarta.servlet.http.HttpServletResponse;
import com.ruoyi.web.controller.mes.wm.export.WmOutsourceExporter;
import com.ruoyi.system.domain.mes.wm.WmOutsourceProcessLine;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.mes.wm.OutsourceRequest;
import com.ruoyi.system.domain.mes.wm.OutsourceResultRequest;
import com.ruoyi.system.domain.mes.wm.WmOutsourceIssueLine;
import com.ruoyi.system.domain.mes.wm.WmOutsourceOrder;
import com.ruoyi.system.domain.mes.wm.WmOutsourceRecptLine;
import com.ruoyi.system.service.mes.wm.IOutsourceService;

/**
 * 通用外协管理 Controller
 *
 * 三步流程统一入口：发货→厂商录结果→收货。
 * 分切/印刷等业务通过 sourceType 区分，领域逻辑由 Strategy 处理。
 *
 * @author qixiaoxia
 */
@RestController
@RequestMapping("/mes/wm/outsource")
public class WmOutsourceController extends BaseController
{
    @Autowired
    private IOutsourceService outsourceService;

    @Autowired
    private com.ruoyi.system.service.mes.pro.IProWorkorderService proWorkorderService;

    @Autowired
    private com.ruoyi.system.mapper.mes.wm.WmOutsourceProcessAttrMapper processAttrMapper;

    /** 外协单列表（厂商账号自动按 vendorId 过滤） */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:list')")
    @GetMapping("/list")
    public TableDataInfo list(WmOutsourceOrder query)
    {
        startPage();
        List<WmOutsourceOrder> list = outsourceService.selectList(query);
        return getDataTable(list);
    }

    /** 外协单详情（含发料行+收货行） */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:query')")
    @GetMapping("/{orderId}")
    public AjaxResult getInfo(@PathVariable Long orderId)
    {
        return success(outsourceService.selectByOrderId(orderId));
    }

    /** 人工改加工单状态（一期弱化流程） */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:changeStatus')")
    @Log(title = "加工单改状态", businessType = BusinessType.UPDATE)
    @PutMapping("/changeStatus")
    public AjaxResult changeStatus(@RequestBody WmOutsourceOrder req)
    {
        return success(outsourceService.changeStatus(req.getOrderId(), req.getStatus(), req.getRemark()));
    }

    /** 加工单工序行（多工序合并一张单） */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:query')")
    @GetMapping("/{orderId}/processLines")
    public AjaxResult processLines(@PathVariable Long orderId)
    {
        return success(outsourceService.selectProcessLines(orderId));
    }

    /** 覆盖保存加工单工序行 */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:edit')")
    @Log(title = "加工单工序行", businessType = BusinessType.UPDATE)
    @PutMapping("/{orderId}/processLines")
    public AjaxResult saveProcessLines(@PathVariable Long orderId,
                                       @RequestBody List<WmOutsourceProcessLine> lines)
    {
        outsourceService.saveProcessLines(orderId, lines);
        return success();
    }

    /** 导出加工单（Excel 套打，可直接打印） */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:export')")
    @Log(title = "加工单导出", businessType = BusinessType.EXPORT)
    @PostMapping("/export/{orderId}")
    public void exportOrder(HttpServletResponse response, @PathVariable Long orderId) throws Exception
    {
        WmOutsourceOrder order = outsourceService.selectByOrderId(orderId);
        if (order == null)
        {
            response.sendError(404, "加工单不存在");
            return;
        }
        WmOutsourceExporter.export(response, order);
    }

    /** 单据模板导出：单张加工单 Excel */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:export')")
    @PostMapping("/doc/{orderId}/excel")
    public void exportDocExcel(@PathVariable Long orderId, HttpServletResponse response) throws Exception
    {
        WmOutsourceOrder order = outsourceService.selectByOrderId(orderId);
        if (order == null) throw new com.ruoyi.common.exception.ServiceException("加工单不存在");
        writeDoc(response, buildDocModel(order), order.getOrderCode(), true);
    }

    /** 单据模板导出：单张加工单 PDF 打印 */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:export')")
    @PostMapping("/doc/{orderId}/pdf")
    public void exportDocPdf(@PathVariable Long orderId, HttpServletResponse response) throws Exception
    {
        WmOutsourceOrder order = outsourceService.selectByOrderId(orderId);
        if (order == null) throw new com.ruoyi.common.exception.ServiceException("加工单不存在");
        writeDoc(response, buildDocModel(order), order.getOrderCode(), false);
    }

    /** 同加工商多张加工单合并导出 */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:export')")
    @PostMapping("/docMerge/{format}")
    public void exportDocMerge(@PathVariable String format, @RequestBody List<Long> orderIds,
                               HttpServletResponse response) throws Exception
    {
        if (orderIds == null || orderIds.isEmpty())
            throw new com.ruoyi.common.exception.ServiceException("请选择要合并的单据");
        com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model m =
                new com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model();
        m.title = "合并加工单";
        m.partyLabel = "加工商：";
        m.showBizNo = false;
        m.headers.add("产品名称");
        m.headers.add("业务单号");
        m.headers.add("产品尺寸");
        m.headers.add("工序");
        m.headers.add("数量");
        m.headers.add("单价");
        m.headers.add("总金额(元)");
        m.headers.add("送货日期");
        m.headers.add("备注");
        for (Long id : orderIds)
        {
            WmOutsourceOrder o = outsourceService.selectByOrderId(id);
            if (o == null) continue;
            if (m.partyName == null) m.partyName = o.getVendorName();
            if (m.deliveryAddress == null) m.deliveryAddress = o.getDeliveryAddress();
            if (m.purchaser == null) m.purchaser = o.getPurchaser();
            if (m.orderDate == null) m.orderDate = com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmtDate(o.getOrderDate());
            List<WmOutsourceProcessLine> lines = o.getProcessLines() != null ? o.getProcessLines()
                    : outsourceService.selectProcessLines(id);
            java.math.BigDecimal qty = java.math.BigDecimal.ZERO;
            java.math.BigDecimal amt = java.math.BigDecimal.ZERO;
            StringBuilder names = new StringBuilder();
            for (WmOutsourceProcessLine l : lines)
            {
                if (l.getPlanQty() != null) qty = qty.add(l.getPlanQty());
                if (l.getAmount() != null) amt = amt.add(l.getAmount());
                if (names.length() > 0) names.append("、");
                names.append(l.getProcessName() == null ? "" : l.getProcessName());
            }
            java.util.List<String> row = new java.util.ArrayList<>();
            row.add(productName(o.getWorkorderId()));
            row.add(o.getSourceOrderCode());
            row.add(productSize(o.getWorkorderId()));
            row.add(names.toString());
            row.add(com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmt(qty));
            row.add(qty.signum() == 0 ? "" : amt.divide(qty, 4, java.math.RoundingMode.HALF_UP).toPlainString());
            row.add(com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmt(amt));
            row.add(com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmtDate(o.getExpectedDate()));
            row.add(o.getRemark());
            m.rows.add(row);
            m.total = m.total.add(amt);
        }
        m.docCode = "共 " + m.rows.size() + " 张";
        writeDoc(response, m, "合并加工单", "excel".equalsIgnoreCase(format));
    }

    @SuppressWarnings("unchecked")
    private com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model buildDocModel(WmOutsourceOrder o)
    {
        com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model m =
                new com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model();
        m.title = o.getDocTitle() != null ? o.getDocTitle() : "加工单";
        m.partyLabel = "加工商：";
        m.partyName = o.getVendorName();
        m.bizNo = o.getSourceOrderCode();
        m.docCode = o.getOrderCode();
        m.deliveryAddress = o.getDeliveryAddress();
        m.purchaser = o.getPurchaser();
        m.orderDate = com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmtDate(o.getOrderDate());
        m.productImage = productImage(o.getWorkorderId());

        List<WmOutsourceProcessLine> lines = o.getProcessLines() != null ? o.getProcessLines()
                : outsourceService.selectProcessLines(o.getOrderId());
        // 工序属性列（取所有工序属性模板的并集，标签用属性名）
        java.util.LinkedHashMap<String, String> attrCols = new java.util.LinkedHashMap<>();
        for (WmOutsourceProcessLine l : lines)
        {
            if (l.getProcessId() == null) continue;
            List<com.ruoyi.system.domain.mes.wm.WmOutsourceProcessAttr> schema =
                    processAttrMapper.selectByProcessId(com.ruoyi.common.utils.SecurityUtils.getFactoryId(), l.getProcessId());
            if (schema == null) continue;
            for (com.ruoyi.system.domain.mes.wm.WmOutsourceProcessAttr a : schema)
            {
                if (a.getAttrCode() != null) attrCols.put(a.getAttrCode(),
                        a.getAttrName() != null ? a.getAttrName() : a.getAttrCode());
            }
        }
        // 多工序加工单在「产品名称」后追加「工序」列（每行显示本行工序名），单工序单据不显示
        boolean showProcessCol = lines != null && lines.size() > 1;
        m.headers.add("产品名称");
        if (showProcessCol) m.headers.add("工序");
        m.headers.add("材料+工艺");
        m.headers.add("成品尺寸mm");
        m.headers.add("数量");
        for (String label : attrCols.values()) m.headers.add(label);
        m.headers.add("单价");
        m.headers.add("总金额(元）");
        m.headers.add("送货日期");
        m.headers.add("备注");
        String pname = productName(o.getWorkorderId());
        String psize = productSize(o.getWorkorderId());
        String printingReq = productPrintingReq(o.getWorkorderId());
        for (WmOutsourceProcessLine l : lines)
        {
            java.util.Map<String, Object> attrs =
                    com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.parseAttrs(l.getExtAttrs());
            java.util.List<String> row = new java.util.ArrayList<>();
            row.add(l.getProductName() != null && !l.getProductName().isBlank() ? l.getProductName() : pname);
            if (showProcessCol) row.add(l.getProcessName() == null ? "" : l.getProcessName());
            // 材料+工艺 / 成品尺寸：优先取单据配置页填写值，未填回退工单印刷要求与产品尺寸
            row.add(docField(attrs, "MATERIAL_CRAFT", printingReq));
            row.add(docField(attrs, "FINISHED_SIZE", psize));
            row.add(com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmt(l.getPlanQty()));
            for (String code : attrCols.keySet())
            {
                Object v = attrs.get(code);
                row.add(v == null ? "" : String.valueOf(v));
            }
            row.add(com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmt(l.getUnitPrice()));
            row.add(com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmt(l.getAmount()));
            row.add(com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.fmtDate(l.getExpectedDate()));
            row.add(l.getRemark());
            m.rows.add(row);
            if (l.getAmount() != null) m.total = m.total.add(l.getAmount());
        }
        return m;
    }

    /** 单据固定列取值：优先取明细扩展属性里的配置值，为空回退默认值 */
    private String docField(java.util.Map<String, Object> attrs, String key, String fallback)
    {
        Object v = attrs == null ? null : attrs.get(key);
        if (v != null && !String.valueOf(v).isBlank())
        {
            return String.valueOf(v);
        }
        return fallback == null ? "" : fallback;
    }

    private String productName(Long workorderId)
    {        if (workorderId == null) return "";
        com.ruoyi.system.domain.mes.pro.ProWorkorder wo = proWorkorderService.selectProWorkorderByWorkorderId(workorderId);
        return wo != null && wo.getProductName() != null ? wo.getProductName() : "";
    }

    private String productSize(Long workorderId)
    {
        if (workorderId == null) return "";
        com.ruoyi.system.domain.mes.pro.ProWorkorder wo = proWorkorderService.selectProWorkorderByWorkorderId(workorderId);
        return wo != null && wo.getProductSize() != null ? wo.getProductSize() : "";
    }

    private String productPrintingReq(Long workorderId)
    {
        if (workorderId == null) return "";
        com.ruoyi.system.domain.mes.pro.ProWorkorder wo = proWorkorderService.selectProWorkorderByWorkorderId(workorderId);
        return wo != null && wo.getPrintingReq() != null ? wo.getPrintingReq() : "";
    }

    private String productImage(Long workorderId)
    {
        if (workorderId == null) return null;
        com.ruoyi.system.domain.mes.pro.ProWorkorder wo = proWorkorderService.selectProWorkorderByWorkorderId(workorderId);
        return wo != null ? wo.getProductImage() : null;
    }

    private void writeDoc(HttpServletResponse response,
                          com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.Model m,
                          String code, boolean excel) throws Exception
    {
        com.ruoyi.common.utils.file.FileUtils.setAttachmentResponseHeader(response,
                "单据_" + code + (excel ? ".xlsx" : ".pdf"));
        response.setContentType(excel
                ? "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                : "application/pdf");
        response.setCharacterEncoding("utf-8");
        if (excel)
        {
            com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.writeExcel(m, response.getOutputStream());
        }
        else
        {
            com.ruoyi.web.controller.mes.export.WorkOrderDocExporter.writePdf(m, response.getOutputStream());
        }
    }

    /** Step1 创建外协发货单（我方操作，草稿模式不扣料） */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:add')")
    @Log(title = "外协发货", businessType = BusinessType.INSERT)
    @PostMapping("/create")
    public AjaxResult create(@RequestBody OutsourceRequest req)
    {
        return AjaxResult.success(outsourceService.createOutsource(req));
    }

    /** 修改草稿单发料行（仓库/批次/数量，仅 DRAFT 状态） */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:add')")
    @Log(title = "外协发料行", businessType = BusinessType.UPDATE)
    @PutMapping("/{orderId}/issueLines")
    public AjaxResult updateIssueLines(@PathVariable Long orderId,
                                       @RequestBody List<WmOutsourceIssueLine> lines)
    {
        outsourceService.updateIssueLines(orderId, lines);
        return AjaxResult.success();
    }

    /** 删除草稿外协单（仅 DRAFT 状态，未扣库存，主表软删除，发料行保留） */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:remove')")
    @Log(title = "外协发货", businessType = BusinessType.DELETE)
    @DeleteMapping("/{orderId}")
    public AjaxResult remove(@PathVariable Long orderId)
    {
        outsourceService.deleteOutsource(orderId);
        return AjaxResult.success();
    }

    /** 执行发料（草稿 DRAFT → 已发料 ISSUED，扣库存） */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:execute')")
    @Log(title = "外协执行发料", businessType = BusinessType.UPDATE)
    @PostMapping("/{orderId}/execute")
    public AjaxResult execute(@PathVariable Long orderId)
    {
        return AjaxResult.success(outsourceService.executeOutsource(orderId));
    }

    /** 批量执行发料（逐张草稿单扣库存发料，单条失败不影响其他单） */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:execute')")
    @Log(title = "外协批量执行发料", businessType = BusinessType.UPDATE)
    @PostMapping("/batchExecute")
    public AjaxResult batchExecute(@RequestBody List<Long> orderIds)
    {
        return AjaxResult.success(outsourceService.batchExecuteOutsource(orderIds));
    }

    /** Step1.5 厂商签收（ISSUED → VENDOR_RCVD，厂商操作） */
    @PreAuthorize("@ss.hasAnyPermi('mes:wm:outsource:vendorReceive,mes:wm:outsource:agentOps')")
    @Log(title = "外协厂商签收", businessType = BusinessType.UPDATE)
    @PostMapping("/{orderId}/vendorReceive")
    public AjaxResult vendorReceive(@PathVariable Long orderId)
    {
        return AjaxResult.success(outsourceService.vendorReceive(orderId));
    }

    /** Step2 厂商录加工结果（厂商操作，支持分批补录；录满自动完成） */
    @PreAuthorize("@ss.hasAnyPermi('mes:wm:outsource:result,mes:wm:outsource:agentOps')")
    @Log(title = "外协录结果", businessType = BusinessType.UPDATE)
    @PostMapping("/{orderId}/result")
    public AjaxResult recordResult(@PathVariable Long orderId,
                                   @RequestBody List<WmOutsourceRecptLine> resultLines)
    {
        return AjaxResult.success(outsourceService.recordResult(orderId, resultLines));
    }

    /** Step2 厂商录加工结果（按工序）：产出明细入库口径 + 工序完成数量回写 */
    @PreAuthorize("@ss.hasAnyPermi('mes:wm:outsource:result,mes:wm:outsource:agentOps')")
    @Log(title = "外协录结果(按工序)", businessType = BusinessType.UPDATE)
    @PostMapping("/{orderId}/processResult")
    public AjaxResult recordProcessResult(@PathVariable Long orderId,
                                          @RequestBody OutsourceResultRequest req)
    {
        return AjaxResult.success(outsourceService.recordProcessResult(orderId, req));
    }

    /** Step2.5 厂商手动完成（PROCESSING → FINISHED，允许短交，厂商操作） */
    @PreAuthorize("@ss.hasAnyPermi('mes:wm:outsource:complete,mes:wm:outsource:agentOps')")
    @Log(title = "外协加工完成", businessType = BusinessType.UPDATE)
    @PostMapping("/{orderId}/complete")
    public AjaxResult complete(@PathVariable Long orderId)
    {
        return AjaxResult.success(outsourceService.complete(orderId));
    }

    /** Step2.6 厂商发货（FINISHED → SHIPPED，厂商操作） */
    @PreAuthorize("@ss.hasAnyPermi('mes:wm:outsource:ship,mes:wm:outsource:agentOps')")
    @Log(title = "外协厂商发货", businessType = BusinessType.UPDATE)
    @PostMapping("/{orderId}/ship")
    public AjaxResult ship(@PathVariable Long orderId)
    {
        return AjaxResult.success(outsourceService.ship(orderId));
    }

    /** Step3 我方收货（SHIPPED → RECEIVED，我方操作） */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:receive')")
    @Log(title = "外协收货", businessType = BusinessType.UPDATE)
    @PostMapping("/{orderId}/receive")
    public AjaxResult receive(@PathVariable Long orderId)
    {
        return AjaxResult.success(outsourceService.receiveOutsource(orderId));
    }

    /** 批量收货（逐单入库收货，单条失败不影响其他单） */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:receive')")
    @Log(title = "外协批量收货", businessType = BusinessType.UPDATE)
    @PostMapping("/batchReceive")
    public AjaxResult batchReceive(@RequestBody List<Long> orderIds)
    {
        return AjaxResult.success(outsourceService.batchReceiveOutsource(orderIds));
    }
}
