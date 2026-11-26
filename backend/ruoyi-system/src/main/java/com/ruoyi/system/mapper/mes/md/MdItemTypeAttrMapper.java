package com.ruoyi.system.mapper.mes.md;

import java.util.List;
import com.ruoyi.common.annotation.SkipFactoryId;
import com.ruoyi.system.domain.mes.md.MdItemTypeAttr;

/**
 * 物料分类-扩展属性绑定Mapper接口
 *
 * <p>有效属性查询 {@link #selectEffAttrSchema} 用递归 CTE 沿父链聚合，实现继承。
 * 由于 CTE 内部子查询拦截器无法正确注入 factory_id，该方法标注 {@link SkipFactoryId}，
 * 由 SQL 内部三处显式 factory_id 条件自行隔离（设计文档 6.3）。
 *
 * @author qixiaoxia
 * @date 2026-08-01
 */
public interface MdItemTypeAttrMapper
{
    /**
     * 查某分类直接绑定的属性（不含继承，配置页用）。
     * 显式按 query.factoryId 隔离，不依赖拦截器（防异步/无上下文场景漏隔离）。
     */
    @SkipFactoryId
    public List<MdItemTypeAttr> selectBindByTypeId(MdItemTypeAttr query);

    /** 查某分类有效属性（含继承，沿父链聚合；子类覆盖父类按 inherit_depth 取最近） */
    @SkipFactoryId
    public List<MdItemTypeAttr> selectEffAttrSchema(MdItemTypeAttr query);

    /**
     * 全量替换某分类的绑定（先删后插由 Service 控制，此处提供单条增/删）。
     * factory_id 从参数对象读取并显式写入（不依赖拦截器注入）。
     */
    @SkipFactoryId
    public int insertItemTypeAttr(MdItemTypeAttr mdItemTypeAttr);

    /** 按主键删单条（依赖拦截器按 factory_id 隔离） */
    public int deleteItemTypeAttrById(Long id);
    @SkipFactoryId
    public int deleteBindByTypeId(MdItemTypeAttr query);

    /**
     * 按属性ID删除全部分类绑定（属性字典物理删除时级联清理）。
     * attr_def 为全局字典，绑定可能散落在多个工厂，故不加 factory_id 条件。
     */
    @SkipFactoryId
    public int deleteBindByAttrId(Long attrId);

    /** 列出引用了某属性的分类名称（删除前影响面提示用），跨工厂 */
    @SkipFactoryId
    public List<String> selectTypeNamesByAttrId(Long attrId);
}
