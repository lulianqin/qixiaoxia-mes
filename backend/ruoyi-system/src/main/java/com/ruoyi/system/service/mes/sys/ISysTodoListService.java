package com.ruoyi.system.service.mes.sys;

import java.util.List;
import com.ruoyi.system.domain.mes.sys.SysTodoList;

/**
 * 通用待办事项Service接口
 *
 * @author qixiaoxia
 * @date 2025-06-11
 */
public interface ISysTodoListService
{
    public SysTodoList selectSysTodoListByTodoId(Long todoId);
    public List<SysTodoList> selectSysTodoListList(SysTodoList sysTodoList);
    public int insertSysTodoList(SysTodoList sysTodoList);
    public int updateSysTodoList(SysTodoList sysTodoList);
    public java.util.List<java.util.Map<String, Object>> countByStatus(Long userId);
    public int deleteSysTodoListByTodoIds(Long[] todoIds);
    public int deleteSysTodoListByTodoId(Long todoId);

    /**
     * 首页「我的待办」汇总：审批/生产/质检/采购仓库/外协代录 5 类待处理数量。
     *
     * @param factoryId 当前工厂ID
     * @param userId    当前用户ID
     * @param username  当前用户账号（create_by 口径）
     * @param vendorId  当前用户绑定的厂商ID（外协厂商账号隔离；我方员工为 null）
     * @return 各类数量及总数
     */
    public java.util.Map<String, Object> homeSummary(Long factoryId, Long userId, String username, Long vendorId);
}
