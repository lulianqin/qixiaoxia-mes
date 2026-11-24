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

    /** 新增物料（含行业子表联动 + 变体继承逻辑） */
        public int insertMdItem(MdItem mdItem);
    /** 更新物料（含行业子表联动） */
    public int updateMdItem(MdItem mdItem);

    public int deleteMdItemById(Long itemId);

    public int deleteMdItemByIds(Long[] itemIds);

    /** 导入物料数据 */
    public String importItem(List<MdItem> itemList, boolean updateSupport, String operName);
}
