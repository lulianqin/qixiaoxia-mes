package com.ruoyi.system.domain.mes.sys;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * 外部系统回写任务对象 qxx_sys_sync_task
 * outbox 模式: 业务事务内落任务, 事务外/定时任务执行 HTTP 回写
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public class SysSyncTask
{
    private Long taskId;
    private Long factoryId;
    private String bizType;
    private Long bizId;
    private String bizNo;
    private String targetSystem;
    private String callbackPath;
    private String payload;
    private String status;
    private Integer retryCount;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date nextRetryTime;

    private String lastError;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date createTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date updateTime;

    public Long getTaskId() { return taskId; }
    public void setTaskId(Long v) { this.taskId = v; }
    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long v) { this.factoryId = v; }
    public String getBizType() { return bizType; }
    public void setBizType(String v) { this.bizType = v; }
    public Long getBizId() { return bizId; }
    public void setBizId(Long v) { this.bizId = v; }
    public String getBizNo() { return bizNo; }
    public void setBizNo(String v) { this.bizNo = v; }
    public String getTargetSystem() { return targetSystem; }
    public void setTargetSystem(String v) { this.targetSystem = v; }
    public String getCallbackPath() { return callbackPath; }
    public void setCallbackPath(String v) { this.callbackPath = v; }
    public String getPayload() { return payload; }
    public void setPayload(String v) { this.payload = v; }
    public String getStatus() { return status; }
    public void setStatus(String v) { this.status = v; }
    public Integer getRetryCount() { return retryCount; }
    public void setRetryCount(Integer v) { this.retryCount = v; }
    public Date getNextRetryTime() { return nextRetryTime; }
    public void setNextRetryTime(Date v) { this.nextRetryTime = v; }
    public String getLastError() { return lastError; }
    public void setLastError(String v) { this.lastError = v; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date v) { this.createTime = v; }
    public Date getUpdateTime() { return updateTime; }
    public void setUpdateTime(Date v) { this.updateTime = v; }
}
