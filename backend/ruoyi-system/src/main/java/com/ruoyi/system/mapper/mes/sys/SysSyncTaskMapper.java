package com.ruoyi.system.mapper.mes.sys;

import java.util.Date;
import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.common.annotation.SkipFactoryId;
import com.ruoyi.system.domain.mes.sys.SysSyncTask;

/**
 * 外部系统回写任务Mapper
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
public interface SysSyncTaskMapper
{
    public int insertSysSyncTask(SysSyncTask task);
    public SysSyncTask selectSysSyncTaskById(Long taskId);
    public List<SysSyncTask> selectSysSyncTaskList(SysSyncTask task);

    /** 定时任务：扫描到期待重试任务（跨工厂，显式无 factory 过滤） */
    @SkipFactoryId
    public List<SysSyncTask> selectDueTasks(@Param("now") Date now, @Param("limit") int limit);

    /** 定时任务：抢占任务（PENDING/FAILED → RUNNING），返回 1 表示抢占成功 */
    @SkipFactoryId
    public int markRunning(@Param("taskId") Long taskId);

    /** 定时任务：写回执行结果（显式 factoryId，避免拦截器注入依赖登录上下文） */
    @SkipFactoryId
    public int markResult(@Param("taskId") Long taskId,
                          @Param("factoryId") Long factoryId,
                          @Param("status") String status,
                          @Param("retryCount") Integer retryCount,
                          @Param("nextRetryTime") Date nextRetryTime,
                          @Param("lastError") String lastError);

    /** 手动重推：把失败任务重置为待执行 */
    public int resetForRetry(Long taskId);
}
