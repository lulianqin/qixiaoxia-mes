package com.ruoyi.system.service.mes.md;

import java.util.List;
import java.util.Map;
import com.ruoyi.system.domain.mes.md.MdAttrDef;

/**
 * 物料扩展属性字典Service接口
 *
 * @author qixiaoxia
 * @date 2026-08-01
 */
public interface IMdAttrDefService
{
    public MdAttrDef selectMdAttrDefByAttrId(Long attrId);

    public List<MdAttrDef> selectMdAttrDefList(MdAttrDef mdAttrDef);

    public boolean checkAttrCodeUnique(MdAttrDef mdAttrDef);

    public int insertMdAttrDef(MdAttrDef mdAttrDef);

    public int updateMdAttrDef(MdAttrDef mdAttrDef);

    public int deleteMdAttrDefByAttrIds(Long[] attrIds);

    /**
     * 查询属性被引用情况（分类/工序模板/物料填写数），供删除前提示。
     *
     * @return typeNames 分类名称列表、processNames 工序名称列表、itemCount 物料填写数
     */
    public Map<String, Object> selectAttrUsage(Long attrId);
}
