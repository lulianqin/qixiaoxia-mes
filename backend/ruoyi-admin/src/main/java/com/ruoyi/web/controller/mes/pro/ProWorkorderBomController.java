package com.ruoyi.web.controller.mes.pro;

import java.util.List;
import java.util.HashSet;
import java.util.Set;
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
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.mes.pro.ProWorkorderBom;
import com.ruoyi.system.service.mes.pro.IProWorkorderBomService;
import com.ruoyi.system.service.mes.pro.IProWorkorderService;
import com.ruoyi.system.service.mes.wm.IWmStockReservationService;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 工单BOM组成Controller
 *
 * @author qixiaoxia
 * @date 2026-06-18
 */
@RestController
@RequestMapping("/mes/pro/workorderbom")
public class ProWorkorderBomController extends BaseController
{
    @Autowired
    private IProWorkorderBomService proWorkorderBomService;

    @Autowired
    private IProWorkorderService proWorkorderService;

    @Autowired
    private IWmStockReservationService stockReservationService;

    @Autowired
    private com.ruoyi.system.service.mes.common.MesQuantityService mesQuantityService;

    /**
     * 查询工单BOM组成列表
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:list')")
    @GetMapping("/list")
    public TableDataInfo list(ProWorkorderBom proWorkorderBom)
    {
        startPage();
        List<ProWorkorderBom> list = proWorkorderBomService.selectProWorkorderBomList(proWorkorderBom);
        return getDataTable(list);
    }

    /**
     * 根据工单ID查询BOM组成列表
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:query')")
    @GetMapping("/listByWorkorderId/{workorderId}")
    public AjaxResult listByWorkorderId(@PathVariable("workorderId") Long workorderId)
    {
        List<ProWorkorderBom> list = proWorkorderBomService.selectProWorkorderBomByWorkorderId(workorderId);
        return success(list);
    }

    /**
     * 导出工单BOM组成列表
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:export')")
    @Log(title = "工单BOM组成", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, ProWorkorderBom proWorkorderBom)
    {
        List<ProWorkorderBom> list = proWorkorderBomService.selectProWorkorderBomList(proWorkorderBom);
        ExcelUtil<ProWorkorderBom> util = new ExcelUtil<ProWorkorderBom>(ProWorkorderBom.class);
        util.exportExcel(response, list, "工单BOM组成数据");
    }

    /**
     * 获取工单BOM组成详细信息
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:query')")
    @GetMapping(value = "/{lineId}")
    public AjaxResult getInfo(@PathVariable("lineId") Long lineId)
    {
        return success(proWorkorderBomService.selectProWorkorderBomByLineId(lineId));
    }

    /**
     * 新增工单BOM组成
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:add')")
    @Log(title = "工单BOM组成", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody ProWorkorderBom proWorkorderBom)
    {
        recalcTotalOnAdd(proWorkorderBom);
        proWorkorderBomService.insertProWorkorderBom(proWorkorderBom);
        resyncReservation(proWorkorderBom.getWorkorderId());
        return success(proWorkorderBom);
    }

    /** 新增 BOM 行时按用量方式计算整单总量 */
    private void recalcTotalOnAdd(ProWorkorderBom bom)
    {
        if (bom == null || bom.getWorkorderId() == null || bom.getQuantity() == null) return;
        com.ruoyi.system.domain.mes.pro.ProWorkorder wo =
                proWorkorderService.selectProWorkorderByWorkorderId(bom.getWorkorderId());
        if (wo == null) return;
        bom.setTotalQuantity(mesQuantityService.calcTotalQty(bom, wo.getQuantity()));
    }

    /**
     * 修改工单BOM组成
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:edit')")
    @Log(title = "工单BOM组成", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody ProWorkorderBom proWorkorderBom)
    {
        ProWorkorderBom existing = proWorkorderBomService.selectProWorkorderBomByLineId(proWorkorderBom.getLineId());
        recalcTotalIfChanged(proWorkorderBom, existing);
        int rows = proWorkorderBomService.updateProWorkorderBom(proWorkorderBom);
        resyncReservation(existing != null ? existing.getWorkorderId() : proWorkorderBom.getWorkorderId());
        return toAjax(rows);
    }

    /** 用量/用量方式/损耗变更时重算整单总量，避免旧 total_quantity 覆盖新需求 */
    private void recalcTotalIfChanged(ProWorkorderBom patch, ProWorkorderBom existing)
    {
        if (patch == null || existing == null) return;
        boolean changed = patch.getQuantity() != null || patch.getQuantityMode() != null
                || patch.getScrapRate() != null || patch.getUnitOfMeasure() != null;
        if (!changed || existing.getWorkorderId() == null) return;
        com.ruoyi.system.domain.mes.pro.ProWorkorder wo =
                proWorkorderService.selectProWorkorderByWorkorderId(existing.getWorkorderId());
        if (wo == null) return;
        ProWorkorderBom calc = new ProWorkorderBom();
        calc.setQuantity(patch.getQuantity() != null ? patch.getQuantity() : existing.getQuantity());
        calc.setQuantityMode(patch.getQuantityMode() != null ? patch.getQuantityMode() : existing.getQuantityMode());
        calc.setScrapRate(patch.getScrapRate() != null ? patch.getScrapRate() : existing.getScrapRate());
        patch.setTotalQuantity(mesQuantityService.calcTotalQty(calc, wo.getQuantity()));
    }

    /**
     * 删除工单BOM组成
     */
    @PreAuthorize("@ss.hasPermi('mes:pro:workorder:remove')")
    @Log(title = "工单BOM组成", businessType = BusinessType.DELETE)
    @DeleteMapping("/{lineIds}")
    public AjaxResult remove(@PathVariable Long[] lineIds)
    {
        Set<Long> workorderIds = new HashSet<>();
        for (Long lineId : lineIds) {
            ProWorkorderBom line = proWorkorderBomService.selectProWorkorderBomByLineId(lineId);
            if (line != null && line.getWorkorderId() != null) workorderIds.add(line.getWorkorderId());
        }
        int rows = proWorkorderBomService.deleteProWorkorderBomByLineIds(lineIds);
        for (Long workorderId : workorderIds) resyncReservation(workorderId);
        return toAjax(rows);
    }

    /** BOM 调整后重新对齐工单预占（释放旧预占，按新 BOM 重占） */
    private void resyncReservation(Long workorderId)
    {
        if (workorderId == null) return;
        com.ruoyi.system.domain.mes.pro.ProWorkorder wo =
                proWorkorderService.selectProWorkorderByWorkorderId(workorderId);
        if (wo == null) return;
        stockReservationService.resyncWorkorderReservations(wo,
                proWorkorderBomService.selectProWorkorderBomByWorkorderId(workorderId));
    }
}
