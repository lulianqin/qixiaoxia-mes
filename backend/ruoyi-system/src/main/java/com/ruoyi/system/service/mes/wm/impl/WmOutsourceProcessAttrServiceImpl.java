package com.ruoyi.system.service.mes.wm.impl;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.mes.wm.WmOutsourceProcessAttr;
import com.ruoyi.system.mapper.mes.wm.WmOutsourceProcessAttrMapper;
import com.ruoyi.system.service.mes.wm.IWmOutsourceProcessAttrService;

/**
 * 外协工序-扩展属性模板 Service 实现
 *
 * @author qixiaoxia
 */
@Service
public class WmOutsourceProcessAttrServiceImpl implements IWmOutsourceProcessAttrService
{
    @Autowired
    private WmOutsourceProcessAttrMapper mapper;

    @Override
    public List<WmOutsourceProcessAttr> selectByProcessId(Long processId)
    {
        if (processId == null) return new ArrayList<>();
        return mapper.selectByProcessId(SecurityUtils.getFactoryId(), processId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int saveProcessAttrs(Long processId, List<WmOutsourceProcessAttr> attrs)
    {
        if (processId == null) throw new ServiceException("工序不能为空");
        Long factoryId = SecurityUtils.getFactoryId();
        mapper.deleteByProcessId(factoryId, processId);
        if (attrs == null || attrs.isEmpty()) return 0;
        Set<Long> seen = new HashSet<>();
        int sort = 1;
        for (WmOutsourceProcessAttr attr : attrs)
        {
            if (attr.getAttrId() == null) throw new ServiceException("属性不能为空");
            if (!seen.add(attr.getAttrId())) continue;
            WmOutsourceProcessAttr row = new WmOutsourceProcessAttr();
            row.setFactoryId(factoryId);
            row.setProcessId(processId);
            row.setAttrId(attr.getAttrId());
            row.setRequired(attr.getRequired() == null ? "0" : attr.getRequired());
            row.setSortOrder(attr.getSortOrder() == null ? sort : attr.getSortOrder());
            row.setEnableFlag("1");
            row.setCreateBy(SecurityUtils.getUsername());
            mapper.insertBind(row);
            sort++;
        }
        return seen.size();
    }
}
