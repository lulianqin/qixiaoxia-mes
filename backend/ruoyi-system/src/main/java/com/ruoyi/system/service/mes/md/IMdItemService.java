package com.ruoyi.system.service.mes.md;

import java.util.List;
import com.ruoyi.system.domain.mes.md.MdItem;

/**
 * 物料产品Service接口
 *
 * @author qixiaoxia
 * @date 2026-06-10
 */
public interface IMdItemService
{
    public List<MdItem> selectMdItemAllEnabled();

    public List<MdItem> selectMdItemList(MdItem mdItem);

    /**
     * 将 itemTypeId 展开为「自身+所有子分类」的 itemTypeIds（内部有 DB 查询）。
     * 必须在 startPage() 之前调用，否则会消费 PageHelper 的分页参数导致列表不分页。
     */
    public void expandItemTypeFilter(MdItem mdItem);

    /** 查询物料详情（含行业子表数据） */
    public MdItem selectMdItemById(Long itemId);

    public boolean checkItemCodeUnique(MdItem mdItem);

    /**
     * 按规格查找或创建 SKU 变体。
     * 指纹命中直接复用；未命中以 parentId 为 SPU 新建变体。
     *
     * @param spec 规格信息（parentId 必填，extAttrs/productSize/printingReq/packageSpec 参与指纹）
     * @return 命中的既有变体或新建变体
     */
    public MdItem findOrCreateSpecVariant(MdItem spec);

    /**
     * 统一物料同一性判定：编码 → 分类(双方有) → 父产品(双方有) → 名称(双方有)
     * → 规格型号(精确) → 产品尺寸(精确) → 扩展属性。
     * 装箱规格、印刷要求、单位不参与身份判定。
     */
    public boolean isSameItem(MdItem a, MdItem b);

    /**
     * 同上；strictAttrs=true 时扩展属性要求全量一致（用于库存手工新增），
     * false 时只校验双方都有的 key（用于导入/外部单据等属性可能不全的场景）。
     */
    public boolean isSameItem(MdItem a, MdItem b, boolean strictAttrs);

    /**
     * 统一物料匹配：先按编码精确匹配，再按名称/规格候选逐一用 {@link #isSameItem} 判定。
     *
     * @return 命中的既有物料，未命中返回 null
     */
    public MdItem matchItem(MdItem spec);

    /** 同 {@link #matchItem(MdItem)}，可指定扩展属性是否严格比较 */
    public MdItem matchItem(MdItem spec, boolean strictAttrs);

    /**
     * 库存新增时按统一匹配规则查找物料，命中直接复用，未命中自动建档。
     *
     * @param spec 物料信息（itemName、itemTypeId 必填）
     * @return 命中的既有物料或新建物料
     */
    public MdItem findOrCreateForStock(MdItem spec);

    /** 新增物料（含行业子表联动 + 变体继承逻辑） */
        public int insertMdItem(MdItem mdItem);
    /** 更新物料（含行业子表联动） */
    public int updateMdItem(MdItem mdItem);

    public int deleteMdItemById(Long itemId);

    public int deleteMdItemByIds(Long[] itemIds);

    /** 导入物料数据 */
    public String importItem(List<MdItem> itemList, boolean updateSupport, String operName);
}
