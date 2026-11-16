package com.ruoyi.system.domain.mes.sys;

import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 外部系统单据留痕 qxx_sys_external_doc
 *
 * <p>同一业务单据可对应 ERP / SRM 两套外部单据，各自保存单据 ID。</p>
 *
 * @author qixiaoxia
 */
public class SysExternalDoc extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long docId;
    private Long factoryId;
    private String systemCode;
    private String bizType;
    private Long bizId;
    private String bizNo;
    private String externalId;
    private String externalNo;
    private Integer externalVersion;
    private String syncStatus;
    private String remark;

    public Long getDocId() { return docId; }
    public void setDocId(Long v) { this.docId = v; }
    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long v) { this.factoryId = v; }
    public String getSystemCode() { return systemCode; }
    public void setSystemCode(String v) { this.systemCode = v; }
    public String getBizType() { return bizType; }
    public void setBizType(String v) { this.bizType = v; }
    public Long getBizId() { return bizId; }
    public void setBizId(Long v) { this.bizId = v; }
    public String getBizNo() { return bizNo; }
    public void setBizNo(String v) { this.bizNo = v; }
    public String getExternalId() { return externalId; }
    public void setExternalId(String v) { this.externalId = v; }
    public String getExternalNo() { return externalNo; }
    public void setExternalNo(String v) { this.externalNo = v; }
    public Integer getExternalVersion() { return externalVersion; }
    public void setExternalVersion(Integer v) { this.externalVersion = v; }
    public String getSyncStatus() { return syncStatus; }
    public void setSyncStatus(String v) { this.syncStatus = v; }
    public String getRemark() { return remark; }
    public void setRemark(String v) { this.remark = v; }
}
