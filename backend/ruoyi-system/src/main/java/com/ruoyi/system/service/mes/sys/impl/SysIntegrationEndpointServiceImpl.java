package com.ruoyi.system.service.mes.sys.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.mes.sys.SysIntegrationEndpoint;
import com.ruoyi.system.mapper.mes.sys.SysIntegrationEndpointMapper;
import com.ruoyi.system.service.mes.sys.ISysIntegrationEndpointService;
import com.ruoyi.system.service.mes.sys.integration.ErpCallbackPaths;

/**
 * 外部系统对接配置Service实现
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
@Service
public class SysIntegrationEndpointServiceImpl implements ISysIntegrationEndpointService
{
    @Autowired
    private SysIntegrationEndpointMapper endpointMapper;

    @Override
    public SysIntegrationEndpoint getErpEndpoint()
    {
        SysIntegrationEndpoint query = new SysIntegrationEndpoint();
        query.setSystemCode(ErpCallbackPaths.SYSTEM_ERP);
        List<SysIntegrationEndpoint> list = endpointMapper.selectSysIntegrationEndpointList(query);
        if (list != null && !list.isEmpty()) return list.get(0);
        SysIntegrationEndpoint empty = new SysIntegrationEndpoint();
        empty.setSystemCode(ErpCallbackPaths.SYSTEM_ERP);
        empty.setSystemName("ERP系统");
        empty.setEnabled("0");
        return empty;
    }

    @Override
    public SysIntegrationEndpoint saveErpEndpoint(SysIntegrationEndpoint endpoint)
    {
        endpoint.setSystemCode(ErpCallbackPaths.SYSTEM_ERP);
        if (endpoint.getSystemName() == null) endpoint.setSystemName("ERP系统");
        if (endpoint.getEnabled() == null) endpoint.setEnabled("0");
        endpoint.setUpdateBy(SecurityUtils.getUsername());
        endpoint.setUpdateTime(DateUtils.getNowDate());
        if (endpoint.getEndpointId() == null)
        {
            endpoint.setCreateBy(SecurityUtils.getUsername());
            endpoint.setCreateTime(DateUtils.getNowDate());
            endpointMapper.insertSysIntegrationEndpoint(endpoint);
        }
        else
        {
            endpointMapper.updateSysIntegrationEndpoint(endpoint);
        }
        return endpoint;
    }
}
