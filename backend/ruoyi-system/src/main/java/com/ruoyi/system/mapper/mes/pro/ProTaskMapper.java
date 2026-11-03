package com.ruoyi.system.mapper.mes.pro;

import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.math.BigDecimal;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.mes.pro.ProTask;

public interface ProTaskMapper {
    ProTask selectProTaskByTaskId(Long taskId);

    /** 按任务ID批量查（质检锁态批量查询消除 N+1）。factory_id 由拦截器注入 */
    List<ProTask> selectProTaskByTaskIds(@Param("taskIds") Collection<Long> taskIds);

    List<ProTask> selectProTaskList(ProTask task);

    /**
     * 查可报工任务：厂内 PRODUCING（workstation_code != 'VENDOR'）且所属工单处于
     * PREPARE/PRODUCING。JOIN qxx_pro_workorder 过滤工单状态，避免查出工单已完工/
     * 取消后仍残留在 PRODUCING 的僵尸任务（点进去会被 feedbackEntry 工单状态门控拦截）。
     * factory_id 由拦截器自动注入（主表别名 t）。
     */
    List<ProTask> selectReportableTaskList(ProTask task);

    /**
     * 移动端「我的工单」：当前用户派工（worker_id）或负责（leader_id）的生产中任务，
     * 含外协 VENDOR 任务与外协路线工序任务，用于定位其关联工单。factory_id 由拦截器注入（主表别名 t）。
     */
    List<ProTask> selectUserActiveTaskList(@Param("userId") Long userId);
    int insertProTask(ProTask task);
    int updateProTask(ProTask task);

    /**
     * 清空任务派工报工人/负责人快照（含 id 列）。
     * updateProTask 的 id 列是动态 {@code <if>}，无法把 id 更新成 NULL；
     * 手工编辑显式传 null 表示取消派人时，由 service 追加调用本语句。
     * factory_id 由拦截器自动注入。
     */
    int clearTaskAssignee(@Param("taskId") Long taskId,
                          @Param("clearWorker") boolean clearWorker,
                          @Param("clearLeader") boolean clearLeader);
    int deleteProTaskByTaskId(Long taskId);
    int deleteProTaskByTaskIds(Long[] taskIds);
    /** 审核报工时原子增量更新任务已生产数量 */
    int addQuantityProduced(@org.apache.ibatis.annotations.Param("taskId") Long taskId,
            @org.apache.ibatis.annotations.Param("deltaProduced") BigDecimal deltaProduced,
            @org.apache.ibatis.annotations.Param("deltaQualified") BigDecimal deltaQualified,
            @org.apache.ibatis.annotations.Param("deltaUnqualified") BigDecimal deltaUnqualified);

    /**
     * 工作站在 [startTime, endTime] 时段内、未结束（非 COMPLETED/CANCEL）的任务数。
     * 返回 >0 表示该时段已被占用（存在冲突）。factoryId 显式传入，因 @Param 多参时拦截器无法自动注入。
     */
    int countConflict(@Param("workstationId") Long workstationId,
                      @Param("startTime") Date startTime,
                      @Param("endTime") Date endTime,
                      @Param("factoryId") Long factoryId,
                      @Param("excludeTaskId") Long excludeTaskId);

    /**
     * 按工单 ID + 源状态批量更新任务状态（用于工单开工级联下发/取消级联取消）。
     * factory_id 由 MyBatis 拦截器自动注入。
     */
    int updateStatusByWorkorder(@Param("workorderId") Long workorderId,
                                @Param("fromStatuses") List<String> fromStatuses,
                                @Param("toStatus") String toStatus);

    /**
     * 条件完成任务：仅当任务当前为 PRODUCING 时置 COMPLETED，防止收货与工单取消并发时回退状态。
     * @return 影响行数；0 表示任务已被其他流程推进/取消
     */
    int completeTaskIfProducing(@Param("taskId") Long taskId, @Param("operator") String operator);

    /**
     * 外协收货完成任务：非终态任务置 COMPLETED，并把已生产量补齐到计划量
     * （外协产出单位与任务计划单位可能不同，不能用产量比计划量判断完成）。
     * @return 影响行数；0 表示任务已终态（被取消/已完成）
     */
    int completeTaskFromOutsource(@Param("taskId") Long taskId, @Param("operator") String operator);

    /**
     * 异常顺延改期：精准更新任务计划完成时间（异常模块 E3 RESCHEDULE 出口），
     * 不走全实体 update，避免覆盖并发状态变更。factory_id 由拦截器注入。
     */
    int updateTaskEndTime(@Param("taskId") Long taskId,
                          @Param("endTime") Date endTime,
                          @Param("operator") String operator);
}
