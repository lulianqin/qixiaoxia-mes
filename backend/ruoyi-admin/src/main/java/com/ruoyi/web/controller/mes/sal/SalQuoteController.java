package com.ruoyi.web.controller.mes.sal;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
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
import com.ruoyi.system.domain.mes.sal.SalQuote;
import com.ruoyi.system.domain.mes.sal.dto.SalQuoteSubmitRequest;
import com.ruoyi.system.service.mes.sal.ISalQuoteService;
import com.ruoyi.system.service.mes.sys.ISysSyncTaskService;

/**
 * 销售报价需求单Controller
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
@RestController
@RequestMapping("/mes/sal/quote")
public class SalQuoteController extends BaseController
{
    @Autowired
    private ISalQuoteService salQuoteService;

    @Autowired
    private ISysSyncTaskService syncTaskService;

    @PreAuthorize("@ss.hasPermi('mes:sal:quote:list')")
    @GetMapping("/list")
    public TableDataInfo list(SalQuote query)
    {
        startPage();
        List<SalQuote> list = salQuoteService.selectSalQuoteList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('mes:sal:quote:query')")
    @GetMapping("/{quoteId}")
    public AjaxResult getInfo(@PathVariable Long quoteId)
    {
        SalQuote quote = salQuoteService.getDetail(quoteId);
        if (quote == null) return error("报价单不存在");
        return AjaxResult.success(quote);
    }

    @PreAuthorize("@ss.hasPermi('mes:sal:quote:edit')")
    @Log(title = "报价录入", businessType = BusinessType.UPDATE)
    @PutMapping("/save")
    public AjaxResult save(@RequestBody SalQuoteSubmitRequest req)
    {
        return AjaxResult.success(salQuoteService.saveQuote(req));
    }

    @PreAuthorize("@ss.hasPermi('mes:sal:quote:submit')")
    @Log(title = "报价提交", businessType = BusinessType.UPDATE)
    @PostMapping("/submit")
    public AjaxResult submit(@RequestBody SalQuoteSubmitRequest req)
    {
        Long taskId = salQuoteService.submitQuote(req);
        if (taskId != null) syncTaskService.dispatch(taskId);
        return AjaxResult.success(taskId);
    }

    @PreAuthorize("@ss.hasPermi('mes:sal:quote:remove')")
    @Log(title = "报价单删除", businessType = BusinessType.DELETE)
    @DeleteMapping("/{quoteId}")
    public AjaxResult remove(@PathVariable Long quoteId)
    {
        return toAjax(salQuoteService.deleteSalQuote(quoteId));
    }
}
