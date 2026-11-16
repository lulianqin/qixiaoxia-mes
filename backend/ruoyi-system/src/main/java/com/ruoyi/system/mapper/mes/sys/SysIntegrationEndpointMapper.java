package com.ruoyi.system.mapper.mes.sys;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.common.annotation.SkipFactoryId;
import com.ruoyi.system.domain.mes.sys.SysIntegrationEndpoint;

/**
 * 外部系统对接配置Mapper
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public interface SysIntegrationEndpointMapper
{
    public List<SysIntegrationEndpoint> selectSysIntegrationEndpointList(SysIntegrationEndpoint endpoint);
    public SysIntegrationEndpoint selectSysIntegrationEndpointById(Long endpointId);
    public int insertSysIntegrationEndpoint(SysIntegrationEndpoint endpoint);
    public int updateSysIntegrationEndpoint(SysIntegrationEndpoint endpoint);

    /** 定时任务/无登录上下文按工厂+系统读取（显式 factoryId，跳过拦截器） */
    @SkipFactoryId
    public SysIntegrationEndpoint selectByFactoryAndSystem(@Param("factoryId") Long factoryId,
                                                           @Param("systemCode") String systemCode);
}
