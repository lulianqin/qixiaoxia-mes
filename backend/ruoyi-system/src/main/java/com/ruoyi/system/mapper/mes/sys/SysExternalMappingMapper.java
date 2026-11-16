package com.ruoyi.system.mapper.mes.sys;

import org.apache.ibatis.annotations.Param;
import com.ruoyi.common.annotation.SkipFactoryId;
import com.ruoyi.system.domain.mes.sys.SysExternalMapping;

/**
 * 外部系统主数据映射Mapper（factory_id 由拦截器注入）
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public interface SysExternalMappingMapper
{
    /** 按外部编码查本系统ID，未映射返回 null */
    public Long selectLocalId(@Param("systemCode") String systemCode,
                              @Param("entityType") String entityType,
                              @Param("externalCode") String externalCode);

    public int insertSysExternalMapping(SysExternalMapping mapping);

    /** 幂等写入映射：已存在则更新 local_id（显式写 factory_id，跳过拦截器改写） */
    @SkipFactoryId
    public int upsertExternalMapping(SysExternalMapping mapping);
}
