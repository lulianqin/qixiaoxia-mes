package com.ruoyi.system.service.mes.sys;

import com.ruoyi.system.domain.mes.sys.SysIntegrationEndpoint;

/**
 * 外部系统对接配置Service
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public interface ISysIntegrationEndpointService
{
    /** 当前工厂的 ERP 端点（无则返回空对象） */
    SysIntegrationEndpoint getErpEndpoint();

    /** 保存 ERP 端点（存在则更新） */
    SysIntegrationEndpoint saveErpEndpoint(SysIntegrationEndpoint endpoint);
}
