package com.ruoyi.system.mapper.mes.sys;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.mes.sys.SysTodoList;

/**
 * 通用待办事项Mapper接口（factory_id 由 FactoryIdInterceptor 自动注入，SQL 无需手写）
 *
 * @author qixiaoxia
 * @date 2025-06-11
 */
public interface SysTodoListMapper
{
    public SysTodoList selectSysTodoListByTodoId(Long todoId);
    public List<SysTodoList> selectSysTodoListList(SysTodoList sysTodoList);
    public int insertSysTodoList(SysTodoList sysTodoList);
    public int updateSysTodoList(SysTodoList sysTodoList);
    public List<Map<String, Object>> countByStatus(@Param("userId") Long userId);
    public int deleteSysTodoListByTodoId(Long todoId);
    public int deleteSysTodoListByTodoIds(Long[] todoIds);

    // ========== 首页我的待办：按业务待处理状态统计（当前工厂范围） ==========

    /** 审批-待审批采购单 */
    public int countHomePendingPurOrder(@Param("factoryId") Long factoryId);

    /** 生产-待审核报工 */
    public int countHomePendingFeedback(@Param("factoryId") Long factoryId);

    /** 质检-待检验过程检验单 */
    public int countHomePendingIpqc(@Param("factoryId") Long factoryId);

    /** 采购/仓库-待发料领料单 */
    public int countHomePendingIssue(@Param("factoryId") Long factoryId);

    /** 外协代录-待签收/待录结果/补录的外协单 */
    public int countHomePendingOutsource(@Param("factoryId") Long factoryId);

    /**
     * 按业务来源查待处理（PENDING/PROCESSING）待办（质检判定完成后回写用）
     *
     * @param sourceDocType 业务类型（IQC/IPQC/OQC/RQC）
     * @param sourceDocId   业务单据ID（检验单主键）
     * @return 待办列表
     */
    public List<SysTodoList> selectPendingBySource(@Param("sourceDocType") String sourceDocType,
                                                   @Param("sourceDocId") Long sourceDocId);

    /**
     * 按「来源类型 + 来源单据ID + 来源单据编码」四元组查一条 PENDING 待办
     * （PRO_QC_BLOCK 拦截待办幂等键：同一 IPQC 对同一任务只建一条）。
     */
    public SysTodoList selectPendingByDocAndCode(@Param("sourceDocType") String sourceDocType,
                                                 @Param("sourceDocId") Long sourceDocId,
                                                 @Param("sourceDocCode") String sourceDocCode);

    /**
     * 按同样四元组批量关闭 PENDING 待办（授权放行后联动）。
     *
     * @return 更新行数
     */
    public int completePendingByDocAndCode(@Param("sourceDocType") String sourceDocType,
                                           @Param("sourceDocId") Long sourceDocId,
                                           @Param("sourceDocCode") String sourceDocCode,
                                           @Param("handleTime") java.util.Date handleTime,
                                           @Param("handleResult") String handleResult,
                                           @Param("updateBy") String updateBy);
}
