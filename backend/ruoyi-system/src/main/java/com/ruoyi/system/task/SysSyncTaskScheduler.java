package com.ruoyi.system.task;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import com.ruoyi.system.service.mes.sys.ISysSyncTaskService;

/**
 * ERP 回写任务补偿调度
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
@Component
public class SysSyncTaskScheduler
{
    private static final Logger log = LoggerFactory.getLogger(SysSyncTaskScheduler.class);

    @Autowired
    private ISysSyncTaskService sysSyncTaskService;

    @Scheduled(initialDelay = 30_000, fixedDelay = 60_000)
    public void retryDueTasks()
    {
        try
        {
            sysSyncTaskService.retryDueTasks();
        }
        catch (Exception e)
        {
            log.error("ERP回写补偿任务执行失败", e);
        }
    }
}
