package com.ruoyi.system.mapper.mes.wm;

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
}
