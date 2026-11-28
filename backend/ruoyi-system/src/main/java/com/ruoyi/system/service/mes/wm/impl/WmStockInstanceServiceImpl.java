package com.ruoyi.system.service.mes.wm.impl;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.mes.wm.WmStockInstance;
import com.ruoyi.system.mapper.mes.wm.WmStockInstanceMapper;
import com.ruoyi.system.service.mes.wm.IWmStockInstanceService;

/**
 * 库存实物实例服务实现
 *
 * @author qixiaoxia
 * @date 2026-11-27
 */
@Service
public class WmStockInstanceServiceImpl implements IWmStockInstanceService
{
    private static final String STATUS_CONSUMED = "CONSUMED";
    private static final String STATUS_PARTIAL = "PARTIAL";
    private static final String STATUS_IN_STOCK = "IN_STOCK";

    @Autowired
    private WmStockInstanceMapper wmStockInstanceMapper;

    @Override
    public List<WmStockInstance> selectWmStockInstanceList(WmStockInstance entity) {
        return wmStockInstanceMapper.selectWmStockInstanceList(entity);
    }

    @Override
    public List<WmStockInstance> selectWmStockInstanceAll() {
        return wmStockInstanceMapper.selectWmStockInstanceAll();
    }

    @Override
    public WmStockInstance selectWmStockInstanceById(Long instanceId) {
        return wmStockInstanceMapper.selectWmStockInstanceById(instanceId);
    }

    @Override
    public WmStockInstance scanByInstanceCode(String instanceCode) {
        String code = instanceCode == null ? "" : instanceCode.trim();
        WmStockInstance instance = wmStockInstanceMapper.selectWmStockInstanceByCode(code);
        if (instance == null) {
            throw new ServiceException("未找到实物实例：" + code);
        }
        return instance;
    }

    @Override
    public List<WmStockInstance> selectActiveByStockId(Long materialStockId) {
        if (materialStockId == null) {
            return List.of();
        }
        return wmStockInstanceMapper.selectActiveByStockId(materialStockId);
    }

    @Override
    public int countActiveByStockId(Long materialStockId) {
        if (materialStockId == null) {
            return 0;
        }
        return wmStockInstanceMapper.countActiveByStockId(materialStockId);
    }

    @Override
    public List<WmStockInstance> selectAvailableInstances(WmStockInstance query) {
        if (query == null || query.getItemId() == null) {
            return List.of();
        }
        return wmStockInstanceMapper.selectAvailableInstances(query);
    }

    @Override
    public BigDecimal sumRemainingByStockId(Long materialStockId) {
        if (materialStockId == null) {
            return BigDecimal.ZERO;
        }
        BigDecimal sum = wmStockInstanceMapper.sumRemainingByStockId(materialStockId);
        return sum == null ? BigDecimal.ZERO : sum;
    }

    @Override
    @Transactional
    public int insertWmStockInstance(WmStockInstance entity) {
        entity.setCreateTime(DateUtils.getNowDate());
        return wmStockInstanceMapper.insertWmStockInstance(entity);
    }

    @Override
    @Transactional
    public int updateWmStockInstance(WmStockInstance entity) {
        entity.setUpdateTime(DateUtils.getNowDate());
        return wmStockInstanceMapper.updateWmStockInstance(entity);
    }

    @Override
    @Transactional
    public int deleteWmStockInstanceById(Long instanceId) {
        return wmStockInstanceMapper.deleteWmStockInstanceById(instanceId);
    }

    @Override
    @Transactional
    public int deleteWmStockInstanceByIds(Long[] instanceIds) {
        return wmStockInstanceMapper.deleteWmStockInstanceByIds(instanceIds);
    }

    @Override
    @Transactional
    public WmStockInstance adjustRemaining(Long instanceId, BigDecimal delta,
                                           Long lastIssueId, Long lastWorkorderId, String lastWorkorderCode) {
        if (instanceId == null || delta == null || delta.compareTo(BigDecimal.ZERO) == 0) {
            throw new ServiceException("实例调整参数不完整");
        }
        WmStockInstance locked = wmStockInstanceMapper.selectWmStockInstanceForUpdate(instanceId);
        if (locked == null) {
            throw new ServiceException("实物实例不存在：" + instanceId);
        }
        BigDecimal result = nvl(locked.getRemainingQuantity()).add(delta);
        if (result.compareTo(BigDecimal.ZERO) < 0) {
            throw new ServiceException("实例[" + locked.getInstanceCode() + "]剩余量不足，当前剩余："
                    + locked.getRemainingQuantity() + "，本次变动：" + delta);
        }
        String status = deriveStatus(result, locked.getOriginalQuantity());
        String operator = currentUsername();
        Date now = DateUtils.getNowDate();
        int rows = wmStockInstanceMapper.adjustRemaining(instanceId, delta, status,
                lastIssueId, lastWorkorderId, lastWorkorderCode, operator, now);
        if (rows <= 0) {
            throw new ServiceException("实例[" + locked.getInstanceCode() + "]剩余量不足，请刷新后重试");
        }
        locked.setRemainingQuantity(result);
        locked.setStatus(status);
        locked.setLastIssueId(lastIssueId != null ? lastIssueId : locked.getLastIssueId());
        locked.setLastWorkorderId(lastWorkorderId != null ? lastWorkorderId : locked.getLastWorkorderId());
        locked.setLastWorkorderCode(lastWorkorderCode != null ? lastWorkorderCode : locked.getLastWorkorderCode());
        return locked;
    }

    /** 剩余量推导状态：0=CONSUMED，小于原始量=PARTIAL，否则=IN_STOCK */
    private String deriveStatus(BigDecimal remaining, BigDecimal original) {
        if (remaining.compareTo(BigDecimal.ZERO) <= 0) {
            return STATUS_CONSUMED;
        }
        BigDecimal base = original == null ? remaining : original;
        return remaining.compareTo(base) < 0 ? STATUS_PARTIAL : STATUS_IN_STOCK;
    }

    private BigDecimal nvl(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }

    private String currentUsername() {
        try {
            String username = SecurityUtils.getUsername();
            return username == null || username.isEmpty() ? "system" : username;
        } catch (Exception e) {
            return "system";
        }
    }
}
