package com.ruoyi.system.domain.mes.wm;

import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 外协工序-扩展属性模板 qxx_wm_outsource_process_attr
 *
 * <p>复用 qxx_md_attr_def 属性字典，按工序绑定外协明细需要填写的字段。</p>
 *
 * @author qixiaoxia
 */
public class WmOutsourceProcessAttr extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long id;
    private Long factoryId;
    private Long processId;
    private Long attrId;
    /** 是否必填(1-是,0-否) */
    private String required;
    private Integer sortOrder;
    private String enableFlag;

    /** 属性定义（联查 qxx_md_attr_def，非持久字段） */
    private String attrCode;
    private String attrName;
    private String attrType;
    private String attrUnit;
    private String optionsJson;

    public Long getId() { return id; }
    public void setId(Long v) { this.id = v; }
    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long v) { this.factoryId = v; }
    public Long getProcessId() { return processId; }
    public void setProcessId(Long v) { this.processId = v; }
    public Long getAttrId() { return attrId; }
    public void setAttrId(Long v) { this.attrId = v; }
    public String getRequired() { return required; }
    public void setRequired(String v) { this.required = v; }
    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer v) { this.sortOrder = v; }
    public String getEnableFlag() { return enableFlag; }
    public void setEnableFlag(String v) { this.enableFlag = v; }
    public String getAttrCode() { return attrCode; }
    public void setAttrCode(String v) { this.attrCode = v; }
    public String getAttrName() { return attrName; }
    public void setAttrName(String v) { this.attrName = v; }
    public String getAttrType() { return attrType; }
    public void setAttrType(String v) { this.attrType = v; }
    public String getAttrUnit() { return attrUnit; }
    public void setAttrUnit(String v) { this.attrUnit = v; }
    public String getOptionsJson() { return optionsJson; }
    public void setOptionsJson(String v) { this.optionsJson = v; }
}
