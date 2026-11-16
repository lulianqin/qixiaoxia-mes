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
import com.ruoyi.system.domain.mes.sal.dto.ErpOrderReceiveRequest;
import com.ruoyi.system.domain.mes.sal.dto.ErpQuoteReceiveRequest;
import com.ruoyi.system.domain.mes.sal.dto.ErpQuoteReturnRequest;
import com.ruoyi.system.service.mes.sal.ISalOrderService;
import com.ruoyi.system.service.mes.sal.ISalQuoteService;

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
}
