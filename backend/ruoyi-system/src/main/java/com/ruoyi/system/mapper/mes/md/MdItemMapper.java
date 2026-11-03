package com.ruoyi.system.mapper.mes.md;

import java.util.List;
import com.ruoyi.system.domain.mes.md.MdItem;

/**
 * 物料产品Mapper接口（factory_id 由 FactoryIdInterceptor 自动注入）
 *
 * @author qixiaoxia
 * @date 2026-06-10
 */
public interface MdItemMapper
{
    public List<MdItem> selectMdItemList(MdItem mdItem);

    public MdItem selectMdItemById(Long itemId);

    /** 按物料ID集合批量查询（单位换算批量化，避免逐行 N+1） */
    public List<MdItem> selectMdItemByIds(Long[] itemIds);

    public MdItem checkItemCodeUnique(MdItem mdItem);

    public int insertMdItem(MdItem mdItem);

    public int updateMdItem(MdItem mdItem);

    public int deleteMdItemById(Long itemId);

    public int deleteMdItemByIds(Long[] itemIds);
}
