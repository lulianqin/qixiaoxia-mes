package com.ruoyi.web.controller.mes.wm;

import java.util.List;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.mes.wm.WmStockInstance;
import com.ruoyi.system.service.mes.wm.IWmStockInstanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * 库存实物实例Controller（一卷 / 一根 / 一桶 …，factory_id 由拦截器注入）
 *
 * @author qixiaoxia
 * @date 2026-11-27
 */
@RestController
@RequestMapping("/mes/wm/stock_instance")
public class WmStockInstanceController extends BaseController
{
    @Autowired
    private IWmStockInstanceService wmStockInstanceService;

    @PreAuthorize("@ss.hasPermi('mes:wm:stock_instance:list')")
    @GetMapping("/list")
    public TableDataInfo list(WmStockInstance entity)
    {
        startPage();
        List<WmStockInstance> list = wmStockInstanceService.selectWmStockInstanceList(entity);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:stock_instance:query')")
    @GetMapping("/listAll")
    public AjaxResult listAll()
    {
        return AjaxResult.success(wmStockInstanceService.selectWmStockInstanceAll());
    }

    /** 实例码精确反查（扫码用） */
    @PreAuthorize("@ss.hasPermi('mes:wm:stock_instance:query')")
    @GetMapping("/scan/{instanceCode}")
    public AjaxResult scan(@PathVariable("instanceCode") String instanceCode)
    {
        return AjaxResult.success(wmStockInstanceService.scanByInstanceCode(instanceCode));
    }

    /** 库存现有量下钻：某库存桶下的在库实例 */
    @PreAuthorize("@ss.hasPermi('mes:wm:stock_instance:query')")
    @GetMapping("/byStock/{materialStockId}")
    public AjaxResult byStock(@PathVariable("materialStockId") Long materialStockId)
    {
        return AjaxResult.success(wmStockInstanceService.selectActiveByStockId(materialStockId));
    }

    /** 发料/退料选择用：某物料有剩余的实例，可按批次/仓库/库存桶收窄 */
    @PreAuthorize("@ss.hasPermi('mes:wm:stock_instance:query')")
    @GetMapping("/available")
    public AjaxResult available(WmStockInstance query)
    {
        return AjaxResult.success(wmStockInstanceService.selectAvailableInstances(query));
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:stock_instance:query')")
    @GetMapping("/countByStock/{materialStockId}")
    public AjaxResult countByStock(@PathVariable("materialStockId") Long materialStockId)
    {
        return AjaxResult.success(wmStockInstanceService.countActiveByStockId(materialStockId));
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:stock_instance:query')")
    @GetMapping(value = "/{instanceId}")
    public AjaxResult getInfo(@PathVariable("instanceId") Long instanceId)
    {
        return AjaxResult.success(wmStockInstanceService.selectWmStockInstanceById(instanceId));
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:stock_instance:add')")
    @Log(title = "库存实物实例", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody WmStockInstance entity)
    {
        return toAjax(wmStockInstanceService.insertWmStockInstance(entity));
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:stock_instance:edit')")
    @Log(title = "库存实物实例", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody WmStockInstance entity)
    {
        return toAjax(wmStockInstanceService.updateWmStockInstance(entity));
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:stock_instance:remove')")
    @Log(title = "库存实物实例", businessType = BusinessType.DELETE)
    @DeleteMapping("/{instanceIds}")
    public AjaxResult remove(@PathVariable Long[] instanceIds)
    {
        return toAjax(wmStockInstanceService.deleteWmStockInstanceByIds(instanceIds));
    }
}
