package com.ruoyi.system.domain.mes.sys;

import java.util.Date;

/**
 * 外部系统主数据映射对象 qxx_sys_external_mapping
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class SysExternalMapping
{
    private Long mappingId;
    private Long factoryId;
    private String systemCode;
    private String entityType;
    private String externalId;
    private String externalCode;
    private Long localId;
    private Date createTime;

    public Long getMappingId() { return mappingId; }
    public void setMappingId(Long v) { this.mappingId = v; }
    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long v) { this.factoryId = v; }
    public String getSystemCode() { return systemCode; }
    public void setSystemCode(String v) { this.systemCode = v; }
    public String getEntityType() { return entityType; }
    public void setEntityType(String v) { this.entityType = v; }
    public String getExternalId() { return externalId; }
    public void setExternalId(String v) { this.externalId = v; }
    public String getExternalCode() { return externalCode; }
    public void setExternalCode(String v) { this.externalCode = v; }
    public Long getLocalId() { return localId; }
    public void setLocalId(Long v) { this.localId = v; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date v) { this.createTime = v; }
}
