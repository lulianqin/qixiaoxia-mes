package com.ruoyi.system.service.mes.wm;

import java.util.List;
import com.ruoyi.system.domain.mes.sal.dto.ErpOutboundApplyRequest;
import com.ruoyi.system.domain.mes.wm.WmSalesApply;

/**
 * ERP 工厂出库申请 Service
 *
 * @author qixiaoxia
 * @date 2026-11-23
 */
public interface IWmSalesApplyService
{
    /** ERP 下发接单：幂等创建申请 + 生成销售出库草稿 */
    WmSalesApply receiveFromErp(ErpOutboundApplyRequest request);

    /** ERP 撤回申请：仅未出库时可撤销草稿 */
    void cancelFromErp(String externalApplyNo);

    /** 详情（含明细） */
    WmSalesApply getDetail(Long applyId);

    /** 列表 */
    List<WmSalesApply> selectWmSalesApplyList(WmSalesApply query);
}
