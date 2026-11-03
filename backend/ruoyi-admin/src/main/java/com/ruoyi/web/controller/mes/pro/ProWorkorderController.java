package com.ruoyi.web.controller.mes.pro;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.mes.pro.ProWorkorder;
import com.ruoyi.system.domain.mes.pro.ProTask;
import com.ruoyi.system.domain.mes.pro.ProWorkorderCreateRequest;
import com.ruoyi.system.domain.mes.pro.ProWorkorderDetailVO;
import com.ruoyi.system.domain.mes.pro.ProWorkorderDeviationVO;
import com.ruoyi.system.service.mes.pro.IProWorkorderService;
import com.ruoyi.system.service.mes.pro.IProTaskService;
import com.ruoyi.system.service.mes.pro.IScheduleService;
import com.ruoyi.system.service.mes.pro.IProFeedbackService;
import com.ruoyi.system.service.mes.pro.IProWorkorderDocService;
import com.ruoyi.system.service.mes.pro.TaskReportDefaultsApplier;
import com.ruoyi.system.domain.mes.pro.ProDocGenerationRequestVO;
import com.ruoyi.system.domain.mes.pro.ProDocGenerationResultVO;
import com.ruoyi.system.domain.mes.pro.ProWorkorderKitDashboardVO;
import com.ruoyi.system.domain.mes.pro.ProOutsourceWorkorderInfoVO;
import com.ruoyi.system.domain.mes.pro.ProConstants;
import com.ruoyi.system.domain.mes.pro.ProRouteProcess;
import com.ruoyi.system.mapper.mes.pro.ProRouteProcessMapper;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 生产工单Controller
 *
 * @author qixiaoxia
 * @date 2026-06-18
 */
@RestController
@RequestMapping("/mes/pro/workorder")
public class ProWorkorderController extends BaseController
{
    private static final Logger log = LoggerFactory.getLogger(ProWorkorderController.class);

    @Autowired
    private IProWorkorderService proWorkorderService;

    @Autowired
    private IScheduleService scheduleService;
    @Autowired
    private IProWorkorderDocService proWorkorderDocService;
    @Autowired
    private IProTaskService proTaskService;

    @Autowired
    private IProFeedbackService proFeedbackService;

    @Autowired
    private TaskReportDefaultsApplier defaultsApplier;

    @Autowired
    private ProRouteProcessMapper proRouteProcessMapper;

    /**
     * 查询生产工单列表
     *
     * @param includeProgress 为 true 时回填在制进度字段（完成率、当前工序、预计完工等），
     *                        仅工单列表页使用，避免影响其他复用 /list 的下拉/看板。
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:list')")
    @GetMapping("/list")
    public TableDataInfo list(ProWorkorder proWorkorder,
            @RequestParam(required = false, defaultValue = "false") boolean includeProgress)
    {
        startPage();
        List<ProWorkorder> list = proWorkorderService.selectProWorkorderList(proWorkorder);
        if (includeProgress)
        {
            proWorkorderService.enrichProgress(list);
        }
        return getDataTable(list);
    }

    /**
     * 查询所有生产工单列表
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:list')")
    @GetMapping("/listAll")
    public AjaxResult listAll()
    {
        List<ProWorkorder> list = proWorkorderService.selectAll();
        return success(list);
    }

    /**
     * 导出生产工单列表
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:export')")
    @Log(title = "生产工单", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, ProWorkorder proWorkorder)
    {
        List<ProWorkorder> list = proWorkorderService.selectProWorkorderList(proWorkorder);
        ExcelUtil<ProWorkorder> util = new ExcelUtil<ProWorkorder>(ProWorkorder.class);
        util.exportExcel(response, list, "生产工单数据");
    }

    /**
     * 获取生产工单详细信息
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:query')")
    @GetMapping(value = "/{workorderId}")
    public AjaxResult getInfo(@PathVariable("workorderId") Long workorderId)
    {
        return success(proWorkorderService.selectProWorkorderByWorkorderId(workorderId));
    }

    /**
     * 获取生产工单详情（含BOM和工序参数，合并返回）
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:query')")
    @GetMapping(value = "/detail/{workorderId}")
    public AjaxResult getDetail(@PathVariable("workorderId") Long workorderId)
    {
        ProWorkorderDetailVO vo = proWorkorderService.getWorkorderDetail(workorderId);
        return success(vo);
    }

    /**
     * 新增生产工单
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:add')")
    @Log(title = "生产工单", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody ProWorkorder proWorkorder)
    {
        proWorkorderService.checkWorkorderCodeUnique(proWorkorder);
        proWorkorderService.insertProWorkorder(proWorkorder);
        return success(proWorkorder);
    }

    /**
     * 新增生产工单（含BOM和工序参数）
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:add')")
    @Log(title = "生产工单(含BOM)", businessType = BusinessType.INSERT)
    @PostMapping("/createWithBom")
    public AjaxResult createWithBom(@RequestBody ProWorkorderCreateRequest request)
    {
        ProWorkorder workorder = proWorkorderService.createWorkorderWithBom(
            request.getWorkorder(), request.getBomList(), request.getParamList());
        // 自动排产：工单创建后自动生成工序任务
        try { scheduleService.scheduleWorkOrder(workorder.getWorkorderId()); } catch (Exception e) { log.warn("自动排产失败: workorderId={}, error={}", workorder.getWorkorderId(), e.toString()); }
        return success(workorder);
    }

    /**
     * 偏离检测：比较提交的 BOM/参数 与 路线标准。
     * 纯计算，不持久化。前端据此弹窗询问用户是否创建变体。
     * 新增/编辑向导共用此接口，add 或 edit 权限任一即可（手工新增入口回收后，
     * 仅有 edit 权限的角色编辑工单时偏离检测不能 403）。
     */
    @PreAuthorize("@ss.hasAnyPermi('mes:pro:workorder:add,mes:pro:workorder:edit')")
    @PostMapping("/checkDeviation")
    public AjaxResult checkDeviation(@RequestBody ProWorkorderCreateRequest request)
    {
        ProWorkorderDeviationVO result = proWorkorderService.checkDeviation(
            request.getWorkorder(), request.getBomList(), request.getParamList());
        return success(result);
    }

    /**
     * 修改生产工单
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:edit')")
    @Log(title = "生产工单", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody ProWorkorder proWorkorder)
    {
        return toAjax(proWorkorderService.updateProWorkorder(proWorkorder));
    }

    /**
     * 修改生产工单（含BOM和工序参数）
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:edit')")
    @Log(title = "生产工单(含BOM)", businessType = BusinessType.UPDATE)
    @PutMapping("/updateWithBom")
    public AjaxResult updateWithBom(@RequestBody ProWorkorderCreateRequest request)
    {
        ProWorkorder workorder = proWorkorderService.updateWorkorderWithBom(
            request.getWorkorder(), request.getBomList(), request.getParamList());
        // 自动排产：工单修改后重新生成工序任务
        try { scheduleService.scheduleWorkOrder(workorder.getWorkorderId()); } catch (Exception e) { log.warn("自动排产失败: workorderId={}", e.getMessage()); }
        return success(workorder);
    }

    /**
     * 删除生产工单
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:remove')")
    @Log(title = "生产工单", businessType = BusinessType.DELETE)
    @DeleteMapping("/{workorderIds}")
    public AjaxResult remove(@PathVariable Long[] workorderIds)
    {
        return toAjax(proWorkorderService.deleteProWorkorderByWorkorderIds(workorderIds));
    }

    /**
     * 开工前检查 + 自动生成领料单 + 开工
     * 四步：物料齐套检查 → 排产检查 → 按工序生成领料单 → 开工
     * 排产检查FAIL时，有 mes:pro:workorder:override 权限可传 force=true 豁免开工（需填 reason）
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:edit') and (!#force or @ss.hasPermi('mes:pro:workorder:override'))")
    @Log(title = "生产工单开工检查", businessType = BusinessType.UPDATE)
    @PutMapping("/startWithCheck/{workorderId}")
    public AjaxResult startWithCheck(@PathVariable Long workorderId,
                                     @RequestParam(defaultValue = "false") boolean force,
                                     @RequestParam(required = false) String reason)
    {
        List<java.util.Map<String, Object>> steps = proWorkorderService.preStartCheck(workorderId, force, reason);
        return success(steps);
    }

    /**
     * 物料齐套检查（实时计算，不持久化）
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:query')")
    @GetMapping("/checkMaterial/{workorderId}")
    public AjaxResult checkMaterial(@PathVariable Long workorderId)
    {
        return success(proWorkorderService.checkMaterialReadiness(workorderId));
    }

    /**
     * 取消工单：PREPARE/PRODUCING → CANCEL
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:edit')")
    @Log(title = "生产工单取消", businessType = BusinessType.UPDATE)
    @PutMapping("/cancel/{workorderId}")
    public AjaxResult cancel(@PathVariable Long workorderId)
    {
        return toAjax(proWorkorderService.cancelWorkorder(workorderId));
    }

    /**
     * 加载工单齐套看板 — 汇总物料分析及领料/采购/退料/入库四类单据状态
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:query')")
    @GetMapping("/kitDashboard/{workorderId}")
    public AjaxResult kitDashboard(@PathVariable Long workorderId)
    {
        ProWorkorderKitDashboardVO vo = proWorkorderDocService.loadKitDashboard(workorderId);
        return success(vo);
    }

    /**
     * 一键批量生成单据（齐套看板内操作）
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:edit')")
    @Log(title = "工单齐套文档生成", businessType = BusinessType.INSERT)
    @PostMapping("/generateDocs")
    public AjaxResult generateDocs(@RequestBody ProDocGenerationRequestVO request)
    {
        ProDocGenerationResultVO result = proWorkorderDocService.generateDocuments(request);
        return success(result);
    }

    /**
     * 单独生成产品入库单
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:edit')")
    @Log(title = "生成产品入库单", businessType = BusinessType.INSERT)
    @PostMapping("/generateReceipt/{workorderId}")
    public AjaxResult generateReceipt(@PathVariable Long workorderId)
    {
        return success(proWorkorderDocService.generateProductReceipt(workorderId));
    }

    /**
     * 单独生成退料单
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:edit')")
    @Log(title = "生成退料单", businessType = BusinessType.INSERT)
    @PostMapping("/generateReturn/{workorderId}")
    public AjaxResult generateReturn(@PathVariable Long workorderId)
    {
        return success(proWorkorderDocService.generateMaterialReturn(workorderId));
    }

    /**
     * 单独生成采购单
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:edit')")
    @Log(title = "生成采购单", businessType = BusinessType.INSERT)
    @PostMapping("/generatePurOrder/{workorderId}")
    public AjaxResult generatePurOrder(@PathVariable Long workorderId)
    {
        java.util.Map<String, Object> result = proWorkorderDocService.generatePurchaseOrder(workorderId);
        return success(result);
    }

    /**
     * 采购单快捷创建向导 — 返回推荐数据（供应商、数量），不写库
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:query')")
    @GetMapping("/purOrderWizard/{workorderId}")
    public AjaxResult purOrderWizard(@PathVariable Long workorderId)
    {
        return success(proWorkorderDocService.buildPurOrderWizard(workorderId));
    }

    /**
     * 采购向导弹窗确认提交 — 接收用户勾选/修改后的物料行，按供应商分组生成采购单
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:edit')")
    @Log(title = "采购向导生成采购单", businessType = BusinessType.INSERT)
    @PostMapping("/purOrderWizard/{workorderId}/submit")
    public AjaxResult submitPurOrderWizard(@PathVariable Long workorderId,
            @RequestBody java.util.List<com.ruoyi.system.domain.mes.pro.PurOrderWizardLineVO> lines)
    {
        return success(proWorkorderDocService.submitPurOrderWizard(workorderId, lines));
    }

    /**
     * 移动端报工入口：按工单编码一次查询工单 + 可报工任务列表（PRODUCING 状态）。
     * 替代移动端原先的两次请求（先查工单列表再查任务列表）。
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:query')")
    @GetMapping("/feedbackEntry/{workorderCode}")
    public AjaxResult feedbackEntry(@PathVariable String workorderCode)
    {
        ProWorkorder wo = proWorkorderService.selectProWorkorderByWorkorderCode(workorderCode);
        if (wo == null) {
            return error("未找到工单：" + workorderCode);
        }
        if (!"PREPARE".equals(wo.getStatus()) && !"PRODUCING".equals(wo.getStatus())) {
            return error("该工单状态为「" + wo.getStatus() + "」，仅待生产/生产中可报工");
        }
        // 查该工单的任务：外协任务(workstation_code=VENDOR 或 路线工序标记外协)打标，前端分流引导
        ProTask taskQuery = new ProTask();
        taskQuery.setWorkorderId(wo.getWorkorderId());
        List<ProTask> allTasks = proTaskService.selectProTaskList(taskQuery);
        // 全部任务按工艺路线顺序（order_num）排序并标记外协
        List<ProTask> sortedTasks = sortAndMarkTasks(allTasks, allTasks);
        // 可报工任务：PRODUCING 状态全部展示（含外协工序，前端打"外协"标签并引导转外协发货）
        List<ProTask> reportableTasks = sortedTasks.stream()
                .filter(t -> "PRODUCING".equals(t.getStatus()))
                .collect(Collectors.toList());
        // 外协任务：展示在"外协"区域（派工工作站=VENDOR 或 路线工序标记外协）
        List<ProTask> outsourceTasks = sortedTasks.stream()
                .filter(t -> "1".equals(t.getIsOutsource()))
                .collect(Collectors.toList());
        fillPendingFeedbackCount(allTasks);
        // 工单维度报工入口：富化上机数量默认值与质检锁态
        defaultsApplier.apply(reportableTasks);

        Map<String, Object> result = new HashMap<>();
        result.put("workorder", wo);
        result.put("tasks", reportableTasks);
        result.put("outsourceTasks", outsourceTasks);
        return success(result);
    }

    /**
     * 移动端首页「我的工单」：当前用户派工/负责的生产中任务所关联的工单，
     * 每个工单携带全部工序任务（按工艺顺序，含未开工/已完成）。
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:task:list')")
    @GetMapping("/myWorkorders")
    public AjaxResult myWorkorders()
    {
        List<ProTask> myTasks = proTaskService.selectUserActiveTaskList(getUserId());
        Map<Long, ProWorkorder> woMap = new LinkedHashMap<>();
        for (ProTask t : myTasks)
        {
            if (woMap.containsKey(t.getWorkorderId())) {
                continue;
            }
            ProWorkorder wo = proWorkorderService.selectProWorkorderByWorkorderId(t.getWorkorderId());
            if (wo != null) {
                woMap.put(t.getWorkorderId(), wo);
            }
        }
        List<Map<String, Object>> result = new ArrayList<>();
        for (ProWorkorder wo : woMap.values())
        {
            result.add(buildWorkorderEntry(wo));
        }
        return success(result);
    }

    /**
     * 工单全部工序任务（按工艺顺序，含状态/负责人/报工人/时间节点），
     * 供移动端工单详情/工序详情页。
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:task:list')")
    @GetMapping("/workorderTasks/{workorderCode}")
    public AjaxResult workorderTasks(@PathVariable String workorderCode)
    {
        ProWorkorder wo = proWorkorderService.selectProWorkorderByWorkorderCode(workorderCode);
        if (wo == null) {
            return error("未找到工单：" + workorderCode);
        }
        return success(buildWorkorderEntry(wo));
    }

    /** 工单详情数据装配：工单 + 全部工序任务（按工艺顺序、标记外协、富化待确认报工数与质检锁态） */
    private Map<String, Object> buildWorkorderEntry(ProWorkorder wo)
    {
        ProTask taskQuery = new ProTask();
        taskQuery.setWorkorderId(wo.getWorkorderId());
        List<ProTask> allTasks = proTaskService.selectProTaskList(taskQuery);
        List<ProTask> sortedTasks = sortAndMarkTasks(allTasks, allTasks);
        fillPendingFeedbackCount(sortedTasks);
        defaultsApplier.apply(sortedTasks);
        Map<String, Object> result = new HashMap<>();
        result.put("workorder", wo);
        result.put("tasks", sortedTasks);
        return result;
    }

    /**
     * 按工艺路线顺序（order_num）排序并标记外协（isOutsource：派工工作站=VENDOR 或 路线工序标记外协）。
     * base 用于取路线ID（任务上冗余值），tasks 为待排序标记的子集/全集。
     */
    private List<ProTask> sortAndMarkTasks(List<ProTask> base, List<ProTask> tasks)
    {
        Long routeId = base.stream().map(ProTask::getRouteId)
                .filter(Objects::nonNull).findFirst().orElse(null);
        List<ProRouteProcess> routeProcesses = routeId == null
                ? Collections.emptyList() : proRouteProcessMapper.selectProRouteProcessByRouteId(routeId);
        Map<Long, ProRouteProcess> rpByProcess = routeProcesses.stream()
                .filter(rp -> rp.getProcessId() != null)
                .collect(Collectors.toMap(ProRouteProcess::getProcessId, rp -> rp, (a, b) -> a));
        List<ProTask> sorted = tasks.stream()
                .sorted(Comparator.comparingInt(t -> routeOrderNum(rpByProcess, t)))
                .collect(Collectors.toList());
        for (ProTask t : sorted)
        {
            boolean outsource = ProConstants.WS_CODE_VENDOR.equals(t.getWorkstationCode())
                    || isOutsourceProcess(rpByProcess.get(t.getProcessId()));
            t.setIsOutsource(outsource ? "1" : "0");
        }
        return sorted;
    }

    /** 路线工序标记为外协（is_outsource='1'）即外协工序 */
    private boolean isOutsourceProcess(ProRouteProcess rp)
    {
        return rp != null && "1".equals(rp.getIsOutsource());
    }

    /** 工艺顺序号，未配置路线工序时排最后 */
    private int routeOrderNum(Map<Long, ProRouteProcess> rpByProcess, ProTask t)
    {
        ProRouteProcess rp = rpByProcess.get(t.getProcessId());
        return (rp == null || rp.getOrderNum() == null) ? Integer.MAX_VALUE : rp.getOrderNum();
    }

    /**
     * 移动端外协发料入口：按工单编码一次查询外协工序、BOM 发料行、默认厂商、已有外协单（防重）。
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:query')")
    @GetMapping("/outsourceInfo")
    public AjaxResult outsourceInfo(@RequestParam String workorderCode)
    {
        ProOutsourceWorkorderInfoVO info = proWorkorderService.getOutsourceInfoByCode(workorderCode);
        return success(info);
    }

    /** 批量查询每个 task 的待审核(PREPARE)报工数，设置到 pendingFeedbackCount */
    private void fillPendingFeedbackCount(List<ProTask> tasks) {
        if (tasks == null || tasks.isEmpty()) return;
        List<Long> taskIds = tasks.stream().map(ProTask::getTaskId).collect(Collectors.toList());
        Map<Long, Integer> countMap = proFeedbackService.countPendingByTaskIds(taskIds);
        for (ProTask t : tasks) {
            Integer c = countMap != null ? countMap.get(t.getTaskId()) : null;
            t.setPendingFeedbackCount(c != null ? c : 0);
        }
    }
}
