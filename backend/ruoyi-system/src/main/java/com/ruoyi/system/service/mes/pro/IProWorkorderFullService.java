package com.ruoyi.system.service.mes.pro;

import com.ruoyi.system.domain.mes.pro.ProWorkorder;
import com.ruoyi.system.domain.mes.pro.WorkorderFullDetailVO;
import com.ruoyi.system.domain.mes.pro.WorkorderFullSubmitVO;

/**
 * 生产工单开单页 Service（主工单 + 工艺路线 + 采购单/加工单 一次性保存）
 *
 * @author qixiaoxia
 * @date 2026-11-17
 */
public interface IProWorkorderFullService
{
    /** 新增工单并一次性生成采购单/加工单草稿 */
    ProWorkorder createFull(WorkorderFullSubmitVO body);

    /** 修改工单并重建采购单/加工单草稿 */
    ProWorkorder updateFull(Long workorderId, WorkorderFullSubmitVO body);

    /** 开单页回显：主工单 + BOM + 参数 + 工序快照 + 已生成单据 */
    WorkorderFullDetailVO getFullDetail(Long workorderId);

    /** 复制模板：以已有工单为模板，清空单号/状态/执行数据，返回可直接再次提交的开单数据 */
    WorkorderFullDetailVO getCopyTemplate(Long workorderId);
}
