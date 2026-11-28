package com.ruoyi.web.controller.mes.wm;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.system.domain.mes.wm.WmSalesApply;
import com.ruoyi.system.service.mes.wm.IWmSalesApplyService;

/**
 * ERP 工厂出库申请Controller（只读：申请由 ERP 下发、MES 仓库执行出库）
 *
 * <p>factory_id 由 FactoryIdInterceptor 自动注入。</p>
 *
 * @author qixiaoxia
 * @date 2026-11-28
 */
@RestController
@RequestMapping("/mes/wm/sales_apply")
public class WmSalesApplyController extends BaseController
{
    @Autowired
    private IWmSalesApplyService wmSalesApplyService;

    @PreAuthorize("@ss.hasPermi('mes:wm:salesapply:list')")
    @GetMapping("/list")
    public TableDataInfo list(WmSalesApply query)
    {
        startPage();
        List<WmSalesApply> list = wmSalesApplyService.selectWmSalesApplyList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:salesapply:query')")
    @GetMapping("/detail/{applyId}")
    public AjaxResult detail(@PathVariable("applyId") Long applyId)
    {
        return success(wmSalesApplyService.getDetail(applyId));
    }
}
