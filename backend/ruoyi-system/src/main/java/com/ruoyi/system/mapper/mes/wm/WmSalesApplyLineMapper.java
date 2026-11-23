package com.ruoyi.system.mapper.mes.wm;

import java.math.BigDecimal;
import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.mes.wm.WmSalesApplyLine;

/**
 * ERP 工厂出库申请明细 Mapper
 *
 * @author qixiaoxia
 * @date 2026-11-23
 */
public interface WmSalesApplyLineMapper
{
    int insertWmSalesApplyLine(WmSalesApplyLine line);

    List<WmSalesApplyLine> selectLinesByApplyId(@Param("applyId") Long applyId,
                                                @Param("factoryId") Long factoryId);

    int updatePosted(@Param("applyId") Long applyId,
                     @Param("factoryId") Long factoryId,
                     @Param("externalLineId") String externalLineId,
                     @Param("postedQty") BigDecimal postedQty,
                     @Param("lineStatus") String lineStatus);
}
