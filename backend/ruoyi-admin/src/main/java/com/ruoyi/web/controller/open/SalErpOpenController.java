package com.ruoyi.web.controller.open;

import java.util.LinkedHashMap;
import java.util.Map;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.system.domain.mes.sal.SalOrder;
import com.ruoyi.system.domain.mes.sal.SalQuote;
import com.ruoyi.system.domain.mes.wm.WmSalesApply;
import com.ruoyi.system.domain.mes.sal.dto.ErpOrderCancelRequest;
import com.ruoyi.system.domain.mes.sal.dto.ErpOrderReceiveRequest;
import com.ruoyi.system.domain.mes.sal.dto.ErpOutboundApplyRequest;
import com.ruoyi.system.domain.mes.sal.dto.ErpQuoteReceiveRequest;
import com.ruoyi.system.domain.mes.sal.dto.ErpQuoteReturnRequest;
import com.ruoyi.system.service.mes.sal.ISalOrderService;
import com.ruoyi.system.service.mes.sal.ISalQuoteService;
import com.ruoyi.system.service.mes.wm.IWmSalesApplyService;

/**
 * ERP 对接开放接口（供 ERP 平台端调用）
 *
 * 认证：ApiKeyAuthenticationFilter 校验 Header X-API-Key，
 *      工厂归属由 API Key 绑定的 factory_id 决定（本 Controller 内无 @PreAuthorize）。
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
@RestController
@RequestMapping("/open-api/sal/erp")
public class SalErpOpenController extends BaseController
{
    @Autowired
    private ISalOrderService salOrderService;

    @Autowired
    private ISalQuoteService salQuoteService;

    @Autowired
    private IWmSalesApplyService wmSalesApplyService;

    /**
     * ERP 采购单下发（幂等：同外部单号覆盖；已投产拒绝变更）
     */
    @PostMapping("/order/receive")
    public AjaxResult receiveOrder(@Valid @RequestBody ErpOrderReceiveRequest req)
    {
        SalOrder order = salOrderService.receiveFromErp(req);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("orderId", order.getOrderId());
        data.put("orderCode", order.getOrderCode());
        data.put("status", order.getStatus());
        data.put("externalOrderNo", order.getExternalOrderNo());
        data.put("externalVersion", order.getExternalVersion());
        return AjaxResult.success(data);
    }

    /**
     * ERP 撤回下发：按外部单号作废销售订单（仅待接单可作废）
     */
    @PostMapping("/order/cancel")
    public AjaxResult cancelOrder(@Valid @RequestBody ErpOrderCancelRequest req)
    {
        SalOrder order = salOrderService.cancelFromErp(req);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("orderId", order.getOrderId());
        data.put("orderCode", order.getOrderCode());
        data.put("status", order.getStatus());
        data.put("externalOrderNo", order.getExternalOrderNo());
        return AjaxResult.success(data);
    }

    /**
     * ERP 报价需求下发（幂等：同外部报价单号覆盖）
     */
    @PostMapping("/quote/receive")
    public AjaxResult receiveQuote(@Valid @RequestBody ErpQuoteReceiveRequest req)
    {
        SalQuote quote = salQuoteService.receiveFromErp(req);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("quoteId", quote.getQuoteId());
        data.put("quoteCode", quote.getQuoteCode());
        data.put("status", quote.getStatus());
        data.put("externalQuoteNo", quote.getExternalQuoteNo());
        return AjaxResult.success(data);
    }

    /**
     * ERP 退回报价需求（允许工厂重新报价）
     */
    @PostMapping("/quote/return")
    public AjaxResult returnQuote(@Valid @RequestBody ErpQuoteReturnRequest req)
    {
        salQuoteService.returnQuote(req);
        return AjaxResult.success();
    }

    /**
     * ERP 出库申请下发（幂等：同外部申请单号只接一次，重复下发返回已有申请）
     */
    @PostMapping("/outbound/apply")
    public AjaxResult receiveOutboundApply(@Valid @RequestBody ErpOutboundApplyRequest req)
    {
        WmSalesApply apply = wmSalesApplyService.receiveFromErp(req);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("applyId", apply.getApplyId());
        data.put("applyCode", apply.getApplyCode());
        data.put("status", apply.getStatus());
        data.put("mesSalesId", apply.getMesSalesId());
        data.put("mesSalesCode", apply.getMesSalesCode());
        return AjaxResult.success(data);
    }

    /**
     * ERP 撤回出库申请（仅未出库时可撤回，会同步作废 MES 出库草稿）
     */
    @PostMapping("/outbound/apply/cancel")
    public AjaxResult cancelOutboundApply(@RequestBody Map<String, Object> body)
    {
        Object no = body == null ? null : body.get("externalApplyNo");
        if (no == null || String.valueOf(no).trim().isEmpty())
        {
            return AjaxResult.error("externalApplyNo不能为空");
        }
        wmSalesApplyService.cancelFromErp(String.valueOf(no));
        return AjaxResult.success();
    }
}
