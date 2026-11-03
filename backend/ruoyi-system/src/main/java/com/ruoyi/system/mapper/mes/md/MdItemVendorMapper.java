package com.ruoyi.system.mapper.mes.md;

import java.util.List;
import com.ruoyi.system.domain.mes.md.MdItemVendor;

/**
 * 物料供应商关系Mapper接口
 *
 * @author qixiaoxia
 * @date 2026-07-01
 */
public interface MdItemVendorMapper
{
    MdItemVendor selectByRecordId(Long recordId);
    List<MdItemVendor> selectList(MdItemVendor query);
    List<MdItemVendor> selectByVendorId(Long vendorId);
    List<MdItemVendor> selectByItemId(Long itemId);
    /** 批量查询多个物料下已启用的供应商（采购向导候选供应商） */
    List<MdItemVendor> selectEnabledByItemIds(Long[] itemIds);
    int insert(MdItemVendor entity);
    int update(MdItemVendor entity);
    int deleteByRecordId(Long recordId);
    int deleteByRecordIds(Long[] recordIds);
}
