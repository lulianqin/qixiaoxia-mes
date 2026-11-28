package com.ruoyi.system.service.mes.wm;

import java.math.BigDecimal;
import java.util.List;
import com.ruoyi.system.domain.mes.wm.WmStockInstance;

/**
 * 库存实物实例服务（一卷 / 一根 / 一桶 …）
 *
 * @author qixiaoxia
 * @date 2026-11-27
 */
public interface IWmStockInstanceService
{
    public List<WmStockInstance> selectWmStockInstanceList(WmStockInstance entity);

    public List<WmStockInstance> selectWmStockInstanceAll();

    public WmStockInstance selectWmStockInstanceById(Long instanceId);

    /** 实例编号精确反查（扫码用），未找到抛业务异常 */
    public WmStockInstance scanByInstanceCode(String instanceCode);

    /** 按库存桶列出在库实例（库存现有量下钻） */
    public List<WmStockInstance> selectActiveByStockId(Long materialStockId);

    /** 按物料查可用实例（发料/退料选择：剩余量>0 且未报废） */
    public List<WmStockInstance> selectAvailableInstances(WmStockInstance query);

    /** 在库实例数（remaining > 0 且未报废） */
    public int countActiveByStockId(Long materialStockId);

    /** 实例剩余量合计（库存账对账用） */
    public BigDecimal sumRemainingByStockId(Long materialStockId);

    public int insertWmStockInstance(WmStockInstance entity);

    public int updateWmStockInstance(WmStockInstance entity);

    public int deleteWmStockInstanceById(Long instanceId);

    public int deleteWmStockInstanceByIds(Long[] instanceIds);

    /**
     * 增减实例剩余量。delta 为负表示领料出库，余额不足时抛 ServiceException。
     * 状态由剩余量自动推导：0=CONSUMED，小于原始量=PARTIAL，否则=IN_STOCK。
     */
    public WmStockInstance adjustRemaining(Long instanceId, BigDecimal delta,
                                           Long lastIssueId, Long lastWorkorderId, String lastWorkorderCode);
}
