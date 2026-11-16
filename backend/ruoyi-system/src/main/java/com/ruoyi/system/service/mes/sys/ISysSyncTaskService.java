package com.ruoyi.system.service.mes.sys;

import java.util.List;
import com.ruoyi.system.domain.mes.sys.SysSyncTask;

/**
 * 外部系统回写任务Service
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public interface ISysSyncTaskService
{
    /** 业务事务内落任务（同一事务） */
    Long enqueue(String bizType, Long bizId, String bizNo, String callbackPath, String payload, String targetSystem);

    /** 立即执行一次（失败仅记录，不抛出） */
    void dispatch(Long taskId);

    /** 手动重推 */
    void retry(Long taskId);

    List<SysSyncTask> selectSysSyncTaskList(SysSyncTask query);

    /** 定时补偿：扫描到期待重试任务 */
    void retryDueTasks();
}
