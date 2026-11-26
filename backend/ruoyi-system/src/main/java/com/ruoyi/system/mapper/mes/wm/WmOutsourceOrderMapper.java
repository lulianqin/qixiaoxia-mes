package com.ruoyi.system.mapper.mes.wm;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.mes.wm.WmOutsourceOrder;

/**
 * 外协订单 Mapper
 * @author qixiaoxia
 */
public interface WmOutsourceOrderMapper
{
    List<WmOutsourceOrder> selectOutsourceOrderList(WmOutsourceOrder query);

    /** 按工单ID查全部外协单（避免 N+1，一次查全后按 processId 分组） */
    List<WmOutsourceOrder> selectByWorkorderId(Long workorderId);

    WmOutsourceOrder selectOutsourceOrderByOrderId(Long orderId);

    int insertOutsourceOrder(WmOutsourceOrder order);

    int updateOutsourceOrder(WmOutsourceOrder order);

    /** 删除外协单头（仅 DRAFT 状态，由 Service 层校验状态后调用） */
    int deleteOutsourceOrderByOrderId(Long orderId);

    /**
     * 物理删除外协单头。
     * <p>仅用于工单开单页保存时重建草稿单：软删除会继续占用
     * uk_wo_process(workorder_id, process_id) 唯一键，导致同工序无法重新建单。</p>
     */
    int deleteOutsourceOrderHardByOrderId(Long orderId);

    /** 工单开单页保存：先清空草稿单头工序ID，避免首道工序变更时唯一键中间态冲突 */
    int clearDraftProcessId(Long orderId);

    /** 工单开单页保存：就地更新草稿单头（保留单号与发料行，显式覆盖可空字段） */
    int updateDraftHeaderForWorkorder(WmOutsourceOrder order);

    /** 仅回写 IQC 挂点两列（工厂生成检验单后回填，避免并发覆盖整头） */
    int updateOutsourceOrderHeaderRefs(@Param("orderId") Long orderId,
                                       @Param("iqcId") Long iqcId,
                                       @Param("iqcCode") String iqcCode);
}
