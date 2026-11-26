package com.ruoyi.system.service.mes.md.impl;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.constant.UserConstants;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.mes.md.MdAttrDef;
import com.ruoyi.system.mapper.mes.md.MdAttrDefMapper;
import com.ruoyi.system.mapper.mes.md.MdItemTypeAttrMapper;
import com.ruoyi.system.mapper.mes.wm.WmOutsourceProcessAttrMapper;
import com.ruoyi.system.service.mes.md.IMdAttrDefService;

/**
 * 物料扩展属性字典Service业务层
 *
 * @author qixiaoxia
 * @date 2026-08-01
 */
@Service
public class MdAttrDefServiceImpl implements IMdAttrDefService
{
    @Autowired
    private MdAttrDefMapper mdAttrDefMapper;

    @Autowired
    private MdItemTypeAttrMapper mdItemTypeAttrMapper;

    @Autowired
    private WmOutsourceProcessAttrMapper wmOutsourceProcessAttrMapper;

    @Override
    public MdAttrDef selectMdAttrDefByAttrId(Long attrId)
    {
        return mdAttrDefMapper.selectMdAttrDefByAttrId(attrId);
    }

    @Override
    public List<MdAttrDef> selectMdAttrDefList(MdAttrDef mdAttrDef)
    {
        return mdAttrDefMapper.selectMdAttrDefList(mdAttrDef);
    }

    @Override
    public boolean checkAttrCodeUnique(MdAttrDef mdAttrDef)
    {
        MdAttrDef exist = mdAttrDefMapper.checkAttrCodeUnique(mdAttrDef);
        Long attrId = mdAttrDef.getAttrId() == null ? -1L : mdAttrDef.getAttrId();
        if (StringUtils.isNotNull(exist) && exist.getAttrId().longValue() != attrId.longValue())
        {
            return UserConstants.NOT_UNIQUE;
        }
        return UserConstants.UNIQUE;
    }

    @Override
    public int insertMdAttrDef(MdAttrDef mdAttrDef)
    {
        // 全局属性字典，factory_id 恒为 0（不随工厂隔离）
        mdAttrDef.setFactoryId(0L);
        mdAttrDef.setCreateTime(DateUtils.getNowDate());
        return mdAttrDefMapper.insertMdAttrDef(mdAttrDef);
    }

    @Override
    public int updateMdAttrDef(MdAttrDef mdAttrDef)
    {
        mdAttrDef.setUpdateTime(DateUtils.getNowDate());
        return mdAttrDefMapper.updateMdAttrDef(mdAttrDef);
    }

    /**
     * 彻底删除属性字典记录。
     * <p>qxx_md_item_type_attr（分类绑定）和 qxx_wm_outsource_process_attr（工序模板绑定）
     * 都与 attr_def 无外键约束，必须在这里手动级联清理，否则会残留悬空绑定行。
     * 历史业务数据（各表 ext_attrs/line_attrs 里的 JSON 值）不做改动，保留原值。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteMdAttrDefByAttrIds(Long[] attrIds)
    {
        int count = 0;
        for (Long attrId : attrIds)
        {
            if (attrId == null)
            {
                continue;
            }
            mdItemTypeAttrMapper.deleteBindByAttrId(attrId);
            wmOutsourceProcessAttrMapper.deleteByAttrId(attrId);
            count += mdAttrDefMapper.deleteMdAttrDefByAttrId(attrId);
        }
        return count;
    }

    @Override
    public Map<String, Object> selectAttrUsage(Long attrId)
    {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("typeNames", mdItemTypeAttrMapper.selectTypeNamesByAttrId(attrId));
        result.put("processNames", wmOutsourceProcessAttrMapper.selectProcessNamesByAttrId(attrId));
        MdAttrDef def = mdAttrDefMapper.selectMdAttrDefByAttrId(attrId);
        int itemCount = 0;
        if (def != null && StringUtils.isNotEmpty(def.getAttrCode()))
        {
            try
            {
                itemCount = mdAttrDefMapper.countItemUsage(def.getAttrCode());
            }
            catch (Exception e)
            {
                // 统计失败不影响删除流程，按 0 处理
                itemCount = 0;
            }
        }
        result.put("itemCount", itemCount);
        return result;
    }
}
