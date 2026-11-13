package com.ruoyi.system.mapper.mes.wm;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.ruoyi.common.annotation.SkipFactoryId;
import com.ruoyi.system.domain.mes.wm.WmOutsourceProcessAttr;

/**
 * 外协工序-扩展属性模板 Mapper
 *
 * @author qixiaoxia
 */
public interface WmOutsourceProcessAttrMapper
{
    /** 查询工序绑定的属性（含属性定义）。@SkipFactoryId：显式按 factory_id 隔离 */
    @SkipFactoryId
    List<WmOutsourceProcessAttr> selectByProcessId(@Param("factoryId") Long factoryId,
                                                   @Param("processId") Long processId);

    /** 删除工序绑定。@SkipFactoryId：显式按 factory_id 隔离 */
    @SkipFactoryId
    int deleteByProcessId(@Param("factoryId") Long factoryId, @Param("processId") Long processId);

    /** 新增绑定。@SkipFactoryId：factory_id 显式写入列 */
    @SkipFactoryId
    int insertBind(WmOutsourceProcessAttr attr);
}
