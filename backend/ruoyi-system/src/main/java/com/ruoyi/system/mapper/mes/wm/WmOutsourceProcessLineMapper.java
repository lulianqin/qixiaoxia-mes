package com.ruoyi.system.mapper.mes.wm;

import java.math.BigDecimal;
import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.mes.wm.WmOutsourceProcessLine;

/**
 * 加工单工序行 Mapper
 *
 * @author qixiaoxia
 */
public interface WmOutsourceProcessLineMapper
{
    List<WmOutsourceProcessLine> selectByOrderId(@Param("orderId") Long orderId);

    int deleteByOrderId(@Param("orderId") Long orderId);

    int insertBatch(@Param("list") List<WmOutsourceProcessLine> list);

    /** 收货回写工序行完成数量 */
    int updateDoneQty(@Param("orderId") Long orderId, @Param("lineId") Long lineId,
                      @Param("doneQty") BigDecimal doneQty);

    /** 按工序录入加工结果时累加工序行完成数量 */
    int addDoneQty(@Param("orderId") Long orderId, @Param("lineId") Long lineId,
                   @Param("qty") BigDecimal qty);
}
