package com.ruoyi.system.service.mes.wm;

import java.util.List;
import com.ruoyi.system.domain.mes.wm.WmTransaction;

public interface IWmTransactionService
{
    /**
     * 处理库存事务（UPSERT）：查重→更新或新增库存→记录事务日志
     * 方法为 synchronized，防止并发库存不一致
     */
    WmTransaction processTransaction(WmTransaction wmTransaction);

    /**
     * 刷新库存桶的辅助单位数量：对开启实例管理的物料，辅助数量 = 在库实例数，
     * 不再由 conversionRate 推算。实例创建/领料完成后调用。
     */
    void refreshInstanceAuxQuantity(Long materialStockId);

    public List<WmTransaction> selectWmTransactionList(WmTransaction entity);
    public List<WmTransaction> selectWmTransactionAll();
    public WmTransaction selectWmTransactionByTransactionId(Long transactionId);
    public int insertWmTransaction(WmTransaction entity);
    public int updateWmTransaction(WmTransaction entity);
    public int deleteWmTransactionByTransactionId(Long transactionId);
    public int deleteWmTransactionByTransactionIds(Long[] transactionIds);
}