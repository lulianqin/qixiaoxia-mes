package com.ruoyi.web.controller.mes.sal;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.mes.sys.SysIntegrationEndpoint;
import com.ruoyi.system.domain.mes.sys.SysSyncTask;
import com.ruoyi.system.service.mes.sys.ISysIntegrationEndpointService;
import com.ruoyi.system.service.mes.sys.ISysSyncTaskService;

/**
 * ERP 对接配置与回写记录Controller
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
@RestController
@RequestMapping("/mes/sal/erp")
public class SalErpIntegrationController extends BaseController
{
    @Autowired
    private ISysIntegrationEndpointService endpointService;

    @Autowired
    private ISysSyncTaskService syncTaskService;

    @PreAuthorize("@ss.hasPermi('mes:sal:erp:list')")
    @GetMapping("/endpoint")
    public AjaxResult getEndpoint()
    {
        return AjaxResult.success(endpointService.getErpEndpoint());
    }

    @PreAuthorize("@ss.hasPermi('mes:sal:erp:edit')")
    @Log(title = "ERP对接配置", businessType = BusinessType.UPDATE)
    @PutMapping("/endpoint")
    public AjaxResult saveEndpoint(@RequestBody SysIntegrationEndpoint endpoint)
    {
        return AjaxResult.success(endpointService.saveErpEndpoint(endpoint));
    }

    @PreAuthorize("@ss.hasPermi('mes:sal:erp:list')")
    @GetMapping("/syncTask/list")
    public TableDataInfo listSyncTask(SysSyncTask query)
    {
        startPage();
        List<SysSyncTask> list = syncTaskService.selectSysSyncTaskList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('mes:sal:erp:retry')")
    @Log(title = "ERP回写重推", businessType = BusinessType.UPDATE)
    @PostMapping("/syncTask/retry/{taskId}")
    public AjaxResult retry(@PathVariable Long taskId)
    {
        syncTaskService.retry(taskId);
        return AjaxResult.success();
    }
}
