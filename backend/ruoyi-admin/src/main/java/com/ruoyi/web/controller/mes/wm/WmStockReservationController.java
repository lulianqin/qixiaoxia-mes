package com.ruoyi.web.controller.mes.wm;

import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.system.domain.mes.wm.WmStockReservation;
import com.ruoyi.system.service.mes.wm.IWmStockReservationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 库存预占（备货占用）查询接口。
 *
 * <p>用于库存列表“锁定量”下钻：回答锁定库存分别属于哪些工单/订单。</p>
 *
 * @author qixiaoxia
 * @date 2026-11-20
 */
@RestController
@RequestMapping("/mes/wm/stock-reservation")
public class WmStockReservationController extends BaseController
{
    @Autowired
    private IWmStockReservationService stockReservationService;

    /** 预占明细列表（支持 itemId / materialStockId / workorderId / status 过滤） */
    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:list')")
    @GetMapping("/list")
    public TableDataInfo list(WmStockReservation query)
    {
        startPage();
        return getDataTable(stockReservationService.selectList(query));
    }

    /** 按库存行下钻锁定明细 */
    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:list')")
    @GetMapping("/lockedDetail")
    public AjaxResult lockedDetail(WmStockReservation query)
    {
        return success(stockReservationService.selectList(query));
    }
}
