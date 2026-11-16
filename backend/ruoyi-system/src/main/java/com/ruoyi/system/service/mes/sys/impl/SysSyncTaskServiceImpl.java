package com.ruoyi.system.service.mes.sys.impl;

import java.util.Date;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.mes.sys.SysIntegrationEndpoint;
import com.ruoyi.system.domain.mes.sys.SysSyncTask;
import com.ruoyi.system.mapper.mes.sal.SalOrderMapper;
import com.ruoyi.system.mapper.mes.sal.SalQuoteMapper;
import com.ruoyi.system.mapper.mes.sys.SysIntegrationEndpointMapper;
import com.ruoyi.system.mapper.mes.sys.SysSyncTaskMapper;
import com.ruoyi.system.service.mes.sys.ISysSyncTaskService;
import com.ruoyi.system.service.mes.sys.integration.ErpCallbackPaths;
import com.ruoyi.system.service.mes.sys.integration.ErpClient;

/**
 * 外部系统回写任务Service实现
 *
 * 设计：业务事务内只落任务（outbox），HTTP 调用在事务外执行；
 * 失败按 1/2/5/10/30 分钟退避重试，最多 10 次，可手动重推。
 *
 * @author qixiaoxia
 * @date 2026-11-15
 */
@Service
public class SysSyncTaskServiceImpl implements ISysSyncTaskService
{
    private static final Logger log = LoggerFactory.getLogger(SysSyncTaskServiceImpl.class);

    private static final int MAX_RETRY = 10;
    private static final int[] BACKOFF_MINUTES = { 1, 2, 5, 10, 30 };
    private static final String STATUS_PENDING = "PENDING";
    private static final String STATUS_SUCCESS = "SUCCESS";
    private static final String STATUS_FAILED = "FAILED";

    @Autowired
    private SysSyncTaskMapper syncTaskMapper;

    @Autowired
    private SysIntegrationEndpointMapper endpointMapper;

    @Autowired
    private SalOrderMapper salOrderMapper;

    @Autowired
    private SalQuoteMapper salQuoteMapper;

    @Autowired
    private ErpClient erpClient;

    @Override
    public Long enqueue(String bizType, Long bizId, String bizNo, String callbackPath, String payload, String targetSystem)
    {
        SysSyncTask task = new SysSyncTask();
        task.setFactoryId(SecurityUtils.getFactoryId());
        task.setBizType(bizType);
        task.setBizId(bizId);
        task.setBizNo(bizNo);
        task.setTargetSystem(StringUtils.isEmpty(targetSystem) ? ErpCallbackPaths.SYSTEM_ERP : targetSystem);
        task.setCallbackPath(callbackPath);
        task.setPayload(payload);
        task.setStatus(STATUS_PENDING);
        task.setRetryCount(0);
        task.setNextRetryTime(DateUtils.getNowDate());
        syncTaskMapper.insertSysSyncTask(task);
        return task.getTaskId();
    }

    @Override
    public void dispatch(Long taskId)
    {
        SysSyncTask task = syncTaskMapper.selectSysSyncTaskById(taskId);
        if (task == null)
        {
            log.warn("回写任务不存在, taskId={}", taskId);
            return;
        }
        doDispatch(task);
    }

    @Override
    public void retry(Long taskId)
    {
        syncTaskMapper.resetForRetry(taskId);
        dispatch(taskId);
    }

    @Override
    public List<SysSyncTask> selectSysSyncTaskList(SysSyncTask query)
    {
        return syncTaskMapper.selectSysSyncTaskList(query);
    }

    @Override
    public void retryDueTasks()
    {
        List<SysSyncTask> tasks = syncTaskMapper.selectDueTasks(DateUtils.getNowDate(), 50);
        if (tasks == null || tasks.isEmpty()) return;
        for (SysSyncTask task : tasks)
        {
            if (syncTaskMapper.markRunning(task.getTaskId()) != 1) continue;
            doDispatch(task);
        }
    }

    /** 执行回写：无登录上下文，全部使用 task.factoryId */
    private void doDispatch(SysSyncTask task)
    {
        int retry = task.getRetryCount() == null ? 0 : task.getRetryCount();
        try
        {
            SysIntegrationEndpoint endpoint =
                    endpointMapper.selectByFactoryAndSystem(task.getFactoryId(), task.getTargetSystem());
            if (endpoint == null)
            {
                throw new RuntimeException("未配置 " + task.getTargetSystem() + " 对接地址");
            }
            if (!"0".equals(endpoint.getEnabled()))
            {
                throw new RuntimeException(task.getTargetSystem() + " 对接已停用");
            }
            if (StringUtils.isEmpty(endpoint.getBaseUrl()))
            {
                throw new RuntimeException(task.getTargetSystem() + " 对接地址为空");
            }
            erpClient.post(endpoint.getBaseUrl(), task.getCallbackPath(), endpoint.getApiKey(), task.getPayload());
            syncTaskMapper.markResult(task.getTaskId(), task.getFactoryId(), STATUS_SUCCESS, retry, null, null);
            updateBizSyncStatus(task, STATUS_SUCCESS);
        }
        catch (Exception e)
        {
            retry++;
            boolean giveUp = retry >= MAX_RETRY;
            Date next = giveUp ? null : nextRetryTime(retry);
            String error = abbreviate(e.getMessage());
            syncTaskMapper.markResult(task.getTaskId(), task.getFactoryId(), STATUS_FAILED, retry, next, error);
            updateBizSyncStatus(task, STATUS_FAILED);
            log.warn("回写ERP失败, taskId={}, bizType={}, bizNo={}, retry={}, error={}",
                    task.getTaskId(), task.getBizType(), task.getBizNo(), retry, error, e);
        }
    }

    private Date nextRetryTime(int retry)
    {
        int idx = Math.min(retry - 1, BACKOFF_MINUTES.length - 1);
        return new Date(System.currentTimeMillis() + BACKOFF_MINUTES[idx] * 60_000L);
    }

    private void updateBizSyncStatus(SysSyncTask task, String syncStatus)
    {
        Date now = DateUtils.getNowDate();
        if (ErpCallbackPaths.BIZ_ORDER_ACCEPT.equals(task.getBizType())
                || ErpCallbackPaths.BIZ_ORDER_REJECT.equals(task.getBizType()))
        {
            salOrderMapper.updateSyncStatus(task.getBizId(), task.getFactoryId(), syncStatus, now);
        }
        else if (ErpCallbackPaths.BIZ_QUOTE_SUBMIT.equals(task.getBizType()))
        {
            salQuoteMapper.updateSyncStatus(task.getBizId(), task.getFactoryId(), syncStatus, now);
        }
    }

    private String abbreviate(String msg)
    {
        if (msg == null) return null;
        return msg.length() > 500 ? msg.substring(0, 500) : msg;
    }
}
