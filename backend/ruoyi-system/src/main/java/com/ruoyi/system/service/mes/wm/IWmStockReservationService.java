package com.ruoyi.system.service.mes.wm;

import com.ruoyi.system.domain.mes.pro.ProWorkorder;
import com.ruoyi.system.domain.mes.pro.ProWorkorderBom;
import com.ruoyi.system.domain.mes.wm.WmProductSalesLine;
import com.ruoyi.system.domain.mes.wm.WmStockReservation;

import java.math.BigDecimal;
import java.util.List;

/**
 * 库存预占（备货占用）服务。
 *
 * <p>预占明细是“锁定库存属于哪个工单/订单”的唯一台账：
 * quantity_locked 由本服务维护，领料单确认/释放/出库、采购入库回补都经由本服务。</p>
 *
 * @author qixiaoxia
 * @date 2026-11-20
 */
public interface IWmStockReservationService
{
    /** 工单创建后按 BOM 预占库存，缺口保留为 OPEN 行 */
    void reserveForWorkorder(ProWorkorder workorder, List<ProWorkorderBom> boms);

    /** 工单 BOM 调整后重新对齐预占（释放旧预占，按新 BOM 减去已领/已耗后重占） */
    void resyncWorkorderReservations(ProWorkorder workorder, List<ProWorkorderBom> boms);

    /** 销售出库单保存后按行预占（开单即锁） */
    void reserveForProductSales(Long salesId, String salesCode, List<WmProductSalesLine> lines);

    /** 单据执行出库后，把该来源已预占的量转为已消耗 */
    void consumeBySource(String sourceDocType, Long sourceDocId, Long itemId, BigDecimal qty);

    /** 单据作废/删除时释放该来源的全部预占 */
    void releaseBySource(String sourceDocType, Long sourceDocId);

    /** 释放工单全部剩余预占（工单关闭/取消） */
    void releaseByWorkorder(Long workorderId);

    /** 领料单确认前，把该工单该物料的有效预占转出（释放库存锁，交给领料单占用） */
    BigDecimal transferToIssue(Long workorderId, Long itemId, BigDecimal qty, Long issueId, String issueCode);

    /** 领料单释放预占时，把已转出的预占归还给工单 */
    void restoreFromIssue(Long issueId);

    /** 领料单出库后，把已转出的量记为已消耗 */
    void consumeByIssue(Long issueId);

    /** 采购/其他入库后，按需求日期 FIFO 回补缺料预占 */
    void reallocateByItem(Long itemId);

    /** 查询预占明细（库存锁定下钻、工单看板） */
    List<WmStockReservation> selectList(WmStockReservation query);

    /** 某物料当前有效预占量 */
    BigDecimal sumActiveByItem(Long itemId);
}
