package com.ruoyi.web.controller.mes.wm;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.mes.wm.WmOutsourceProcessAttr;
import com.ruoyi.system.service.mes.wm.IWmOutsourceProcessAttrService;

/**
 * 外协工序-扩展属性模板 Controller
 *
 * @author qixiaoxia
 */
@RestController
@RequestMapping("/mes/wm/outsource/processAttr")
public class WmOutsourceProcessAttrController extends BaseController
{
    @Autowired
    private IWmOutsourceProcessAttrService service;

    /** 查询工序绑定的字段模板（外协发货页动态渲染用） */
    @PreAuthorize("@ss.hasPermi('mes:wm:outsource:list')")
    @GetMapping("/{processId}")
    public AjaxResult getSchema(@PathVariable Long processId)
    {
        return success(service.selectByProcessId(processId));
    }

    /** 保存工序字段模板（工序页面配置用） */
    @PreAuthorize("@ss.hasPermi('mes:pro:process:attr')")
    @Log(title = "外协字段模板", businessType = BusinessType.UPDATE)
    @PutMapping("/{processId}")
    public AjaxResult save(@PathVariable Long processId,
                           @RequestBody List<WmOutsourceProcessAttr> attrs)
    {
        return toAjax(service.saveProcessAttrs(processId, attrs));
    }
}
