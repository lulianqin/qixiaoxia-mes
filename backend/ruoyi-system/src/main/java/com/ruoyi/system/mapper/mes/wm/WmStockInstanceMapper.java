package com.ruoyi.system.mapper.mes.wm;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.mes.wm.WmStockInstance;

/**
 * 库存实物实例 Mapper（factory_id 由 FactoryIdInterceptor 自动注入）
 *
 * @author qixiaoxia
 * @date 2026-11-27
 */
public interface WmStockInstanceMapper
{
    public List<WmStockInstance> selectWmStockInstanceList(WmStockInstance entity);

    public List<WmStockInstance> selectWmStockInstanceAll();

    public WmStockInstance selectWmStockInstanceById(Long instanceId);

    /** 实例编号精确反查（扫码用），factory_id 由拦截器注入 */
    public WmStockInstance selectWmStockInstanceByCode(@Param("instanceCode") String instanceCode);

    /** 按库存桶列出在库实例（供库存现有量下钻） */
    public List<WmStockInstance> selectActiveByStockId(@Param("materialStockId") Long materialStockId);

    /** 按物料查可用实例（发料/退料选择用：剩余量>0 且未报废） */
    public List<WmStockInstance> selectAvailableInstances(WmStockInstance query);

    /** 行锁读取实例（收发料并发控制） */
    public WmStockInstance selectWmStockInstanceForUpdate(@Param("instanceId") Long instanceId);

    /** 在库实例数：remaining_quantity > 0 且未报废 */
    public int countActiveByStockId(@Param("materialStockId") Long materialStockId);

    /** 实例剩余量合计，用于库存账对账 */
    public BigDecimal sumRemainingByStockId(@Param("materialStockId") Long materialStockId);

    public int insertWmStockInstance(WmStockInstance entity);

    public int updateWmStockInstance(WmStockInstance entity);

    /**
     * 增减实例剩余量（delta 正入负出）；余额不足时返回 0，不抛异常由 Service 判断。
     */
    public int adjustRemaining(@Param("instanceId") Long instanceId,
                               @Param("delta") BigDecimal delta,
                               @Param("status") String status,
                               @Param("lastIssueId") Long lastIssueId,
                               @Param("lastWorkorderId") Long lastWorkorderId,
                               @Param("lastWorkorderCode") String lastWorkorderCode,
                               @Param("operator") String operator,
                               @Param("now") Date now);

    public int deleteWmStockInstanceById(Long instanceId);

    public int deleteWmStockInstanceByIds(Long[] instanceIds);
}
