package com.ruoyi.system.domain.mes.sys;

import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 外部系统对接配置对象 qxx_sys_integration_endpoint
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class SysIntegrationEndpoint extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long endpointId;
    private Long factoryId;
    private String systemCode;
    private String systemName;
    private String baseUrl;
    private String apiKey;
    private String enabled;

    public Long getEndpointId() { return endpointId; }
    public void setEndpointId(Long v) { this.endpointId = v; }
    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long v) { this.factoryId = v; }
    public String getSystemCode() { return systemCode; }
    public void setSystemCode(String v) { this.systemCode = v; }
    public String getSystemName() { return systemName; }
    public void setSystemName(String v) { this.systemName = v; }
    public String getBaseUrl() { return baseUrl; }
    public void setBaseUrl(String v) { this.baseUrl = v; }
    public String getApiKey() { return apiKey; }
    public void setApiKey(String v) { this.apiKey = v; }
    public String getEnabled() { return enabled; }
    public void setEnabled(String v) { this.enabled = v; }
}
