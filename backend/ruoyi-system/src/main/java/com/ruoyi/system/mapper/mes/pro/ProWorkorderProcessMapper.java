package com.ruoyi.system.mapper.mes.pro;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.mes.pro.ProWorkorderProcess;

/**
 * 工单工序快照 Mapper
 *
 * @author qixiaoxia
 */
public interface ProWorkorderProcessMapper
{
    List<ProWorkorderProcess> selectByWorkorderId(@Param("workorderId") Long workorderId,
                                                  @Param("factoryId") Long factoryId);

    int deleteByWorkorderId(@Param("workorderId") Long workorderId,
                            @Param("factoryId") Long factoryId);

    int insertBatch(List<ProWorkorderProcess> list);
}
