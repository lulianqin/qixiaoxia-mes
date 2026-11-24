package com.ruoyi.system.service.mes.sys.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.system.domain.mes.sys.SysTodoList;
import com.ruoyi.system.mapper.mes.sys.SysTodoListMapper;
import com.ruoyi.system.service.mes.sys.ISysTodoListService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * 通用待办事项Service实现
 *
 * @author qixiaoxia
 * @date 2025-06-11
 */
@Service
public class SysTodoListServiceImpl implements ISysTodoListService
{
    @Autowired
    private SysTodoListMapper sysTodoListMapper;

    @Override
    public SysTodoList selectSysTodoListByTodoId(Long todoId) {
        return sysTodoListMapper.selectSysTodoListByTodoId(todoId);
    }

    @Override
    public List<SysTodoList> selectSysTodoListList(SysTodoList sysTodoList) {
        return sysTodoListMapper.selectSysTodoListList(sysTodoList);
    }

    @Override
    public int insertSysTodoList(SysTodoList sysTodoList) {
        sysTodoList.setCreateTime(DateUtils.getNowDate());
        if (sysTodoList.getStatus() == null || sysTodoList.getStatus().isEmpty()) {
            sysTodoList.setStatus("PENDING");
        }
        return sysTodoListMapper.insertSysTodoList(sysTodoList);
    }

    @Override
    public int updateSysTodoList(SysTodoList sysTodoList) {
        sysTodoList.setUpdateTime(DateUtils.getNowDate());
        return sysTodoListMapper.updateSysTodoList(sysTodoList);
    }

    @Override
    public java.util.List<java.util.Map<String, Object>> countByStatus(Long userId) {
        return sysTodoListMapper.countByStatus(userId);
    }

    @Override
    public int deleteSysTodoListByTodoIds(Long[] todoIds) {
        return sysTodoListMapper.deleteSysTodoListByTodoIds(todoIds);
    }

    @Override
    public int deleteSysTodoListByTodoId(Long todoId) {
        return sysTodoListMapper.deleteSysTodoListByTodoId(todoId);
    }

    @Override
    public java.util.Map<String, Object> homeSummary(Long factoryId, Long userId, String username, Long vendorId) {
        int approval = sysTodoListMapper.countHomePendingPurOrder(factoryId, username);
        int production = sysTodoListMapper.countHomePendingFeedback(factoryId, userId);
        int quality = sysTodoListMapper.countHomePendingIpqc(factoryId, username);
        int purchase = sysTodoListMapper.countHomePendingIssue(factoryId, username);
        int outsource = sysTodoListMapper.countHomePendingOutsource(factoryId, vendorId, username);

        java.util.Map<String, Object> result = new java.util.LinkedHashMap<>();
        result.put("approval", approval);
        result.put("production", production);
        result.put("quality", quality);
        result.put("purchase", purchase);
        result.put("outsource", outsource);
        result.put("total", approval + production + quality + purchase + outsource);
        return result;
    }
}
