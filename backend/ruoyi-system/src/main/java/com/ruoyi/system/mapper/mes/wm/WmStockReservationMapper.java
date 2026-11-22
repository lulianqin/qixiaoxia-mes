package com.ruoyi.system.mapper.mes.wm;

import com.ruoyi.system.domain.mes.wm.WmStockReservation;

import java.math.BigDecimal;
import java.util.List;

/**
 * 库存预占明细 Mapper。
 *
 * @author qixiaoxia
 * @date 2026-11-20
 */
public interface WmStockReservationMapper
{
    List<WmStockReservation> selectWmStockReservationList(WmStockReservation query);

    WmStockReservation selectWmStockReservationById(Long reservationId);

    /** 查某物料仍有效的预占行（OPEN/PARTIAL/RESERVED），按需求日期 FIFO */
    List<WmStockReservation> selectActiveByItem(WmStockReservation query);

    /** 查某工单的预占行 */
    List<WmStockReservation> selectByWorkorder(WmStockReservation query);

    /** 查某领料单已转移的预占行 */
    List<WmStockReservation> selectByIssue(WmStockReservation query);

    /** 查某来源单据（销售出库等）的预占行 */
    List<WmStockReservation> selectBySource(WmStockReservation query);

    /** 汇总某物料有效预占量 */
    BigDecimal sumActiveByItem(WmStockReservation query);

    /** 汇总某工单某物料有效预占量 */
    BigDecimal sumActiveByWorkorderItem(WmStockReservation query);

    int insertWmStockReservation(WmStockReservation reservation);

    int updateWmStockReservation(WmStockReservation reservation);
}
