package com.ruoyi.system.domain.mes.pro;

/**
 * 工艺路线复制请求体：sourceRouteId 为被复制路线，其余字段为新路线的基本信息。
 * 与实体 ProRoute 的主键语义不同，单独定义请求对象避免歧义。
 *
 * @author qixiaoxia
 * @date 2026-11-26
 */
public class ProRouteCopyRequest
{
    /** 源工艺路线ID */
    private Long sourceRouteId;

    /** 新路线编码（必填，全局唯一） */
    private String routeCode;

    /** 新路线名称（必填） */
    private String routeName;

    /** 新路线备注（可选） */
    private String remark;

    public Long getSourceRouteId()
    {
        return sourceRouteId;
    }

    public void setSourceRouteId(Long sourceRouteId)
    {
        this.sourceRouteId = sourceRouteId;
    }

    public String getRouteCode()
    {
        return routeCode;
    }

    public void setRouteCode(String routeCode)
    {
        this.routeCode = routeCode;
    }

    public String getRouteName()
    {
        return routeName;
    }

    public void setRouteName(String routeName)
    {
        this.routeName = routeName;
    }

    public String getRemark()
    {
        return remark;
    }

    public void setRemark(String remark)
    {
        this.remark = remark;
    }
}
