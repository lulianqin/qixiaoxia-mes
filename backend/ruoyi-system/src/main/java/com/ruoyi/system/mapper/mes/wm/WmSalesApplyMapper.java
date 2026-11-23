package com.ruoyi.system.mapper.mes.wm;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.mes.wm.WmSalesApply;

/**
 * ERP 工厂出库申请 Mapper
 *
 * @author qixiaoxia
 * @date 2026-11-23
 */
public interface WmSalesApplyMapper
{
    WmSalesApply selectByApplyCode(@Param("applyCode") String applyCode,
                                   @Param("factoryId") Long factoryId);

    WmSalesApply selectWmSalesApplyById(@Param("applyId") Long applyId,
                                        @Param("factoryId") Long factoryId);

    List<WmSalesApply> selectWmSalesApplyList(WmSalesApply query);

    int insertWmSalesApply(WmSalesApply apply);

    int updateWmSalesApplyResult(WmSalesApply apply);

    int updateWmSalesApplyStatus(WmSalesApply apply);
}
