package com.ruoyi.system.service.mes.wm.impl;

import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.mes.md.MdItem;
import com.ruoyi.system.domain.mes.pro.ProWorkorder;
import com.ruoyi.system.domain.mes.pro.ProWorkorderBom;
import com.ruoyi.system.domain.mes.wm.WmMaterialStock;
import com.ruoyi.system.domain.mes.wm.WmProductSalesLine;
import com.ruoyi.system.domain.mes.wm.WmStockReservation;
import com.ruoyi.system.mapper.mes.wm.WmMaterialStockMapper;
import com.ruoyi.system.mapper.mes.wm.WmStockReservationMapper;
import com.ruoyi.system.service.mes.common.MesQuantityService;
import com.ruoyi.system.service.mes.wm.IWmStockReservationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 库存预占（备货占用）服务实现。
 *
 * <p>数量口径统一为主单位。预占行按库存行拆分，保证释放/消耗能精确回到原库存行。
 * 锁定量 quantity_locked 与可用量 quantity_available 同步维护：
 * 预占 → available 减、locked 加；释放 → available 加、locked 减；
 * 出库 → onhand 减、locked 减。</p>
 *
 * @author qixiaoxia
 * @date 2026-11-20
 */
@Service
public class WmStockReservationServiceImpl implements IWmStockReservationService
{
    private static final String Q_NORMAL = "NORMAL";
    private static final String ST_OPEN = "OPEN";
    private static final String ST_PARTIAL = "PARTIAL";
    private static final String ST_RESERVED = "RESERVED";
    private static final String ST_TRANSFERRED = "TRANSFERRED";
    private static final String ST_CONSUMED = "CONSUMED";
    private static final String ST_RELEASED = "RELEASED";
    private static final String SOURCE_SALES = "PRODUCT_SALES";

    @Autowired private WmStockReservationMapper reservationMapper;
    @Autowired private WmMaterialStockMapper stockMapper;
    @Autowired private MesQuantityService mesQuantityService;

    // ==================== 工单预占 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void reserveForWorkorder(ProWorkorder workorder, List<ProWorkorderBom> boms)
    {
        if (workorder == null || workorder.getWorkorderId() == null || boms == null || boms.isEmpty()) return;
        Map<Long, MdItem> items = mesQuantityService.loadItems(collectItemIds(boms));
        for (ProWorkorderBom bom : boms)
        {
            if (bom.getItemId() == null) continue;
            MdItem item = items.get(bom.getItemId());
            BigDecimal need = mesQuantityService.toBaseQty(
                    mesQuantityService.requiredTotalQty(bom, workorder.getQuantity()),
                    bom.getUnitOfMeasure(), item);
            if (need == null || need.signum() <= 0) continue;
            reserveOne(workorder, bom, item, need);
        }
    }

    private void reserveOne(ProWorkorder workorder, ProWorkorderBom bom, MdItem item, BigDecimal need)
    {
        WmStockReservation q = new WmStockReservation();
        q.setWorkorderId(workorder.getWorkorderId());
        q.setItemId(bom.getItemId());
        if (!reservationMapper.selectByWorkorder(q).isEmpty()) return; // 工单已预占过，幂等跳过

        List<StockTake> takes = takeFromFifo(bom.getItemId(), need);
        BigDecimal taken = sumTakes(takes);
        for (StockTake take : takes) {
            insertReservedRow(workorder, bom, item, take);
        }
        BigDecimal residual = need.subtract(taken);
        if (residual.signum() > 0) {
            insertOpenRow(workorder, bom, item, residual);
        }
    }

    // ==================== 释放 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void releaseByWorkorder(Long workorderId)
    {
        if (workorderId == null) return;
        WmStockReservation q = new WmStockReservation();
        q.setWorkorderId(workorderId);
        for (WmStockReservation row : reservationMapper.selectByWorkorder(q)) {
            if (ST_OPEN.equals(row.getStatus())) {
                row.setStatus(ST_RELEASED);
                touch(row);
                reservationMapper.updateWmStockReservation(row);
                continue;
            }
            releaseRow(row, nvl(row.getReservedQty()));
        }
    }

    // ==================== 工单 BOM 调整重对齐 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void resyncWorkorderReservations(ProWorkorder workorder, List<ProWorkorderBom> boms)
    {
        if (workorder == null || workorder.getWorkorderId() == null) return;
        Map<Long, BigDecimal> processed = loadProcessedByItem(workorder.getWorkorderId());
        releaseByWorkorder(workorder.getWorkorderId());
        if (boms == null || boms.isEmpty()) return;
        Map<Long, MdItem> items = mesQuantityService.loadItems(collectItemIds(boms));
        for (ProWorkorderBom bom : boms) {
            if (bom.getItemId() == null) continue;
            MdItem item = items.get(bom.getItemId());
            BigDecimal need = mesQuantityService.toBaseQty(
                    mesQuantityService.requiredTotalQty(bom, workorder.getQuantity()),
                    bom.getUnitOfMeasure(), item);
            BigDecimal remain = nvl(need).subtract(processed.getOrDefault(bom.getItemId(), BigDecimal.ZERO));
            if (remain.signum() <= 0) continue;
            reserveDirect(workorder, bom, item, remain);
        }
    }

    /** 已领/已耗量：consumed + 已转领料单的 released */
    private Map<Long, BigDecimal> loadProcessedByItem(Long workorderId)
    {
        Map<Long, BigDecimal> map = new HashMap<>();
        WmStockReservation q = new WmStockReservation();
        q.setWorkorderId(workorderId);
        for (WmStockReservation row : reservationMapper.selectByWorkorder(q)) {
            if (row.getItemId() == null) continue;
            BigDecimal done = nvl(row.getConsumedQty()).add(nvl(row.getTransferredQty()));
            map.merge(row.getItemId(), done, BigDecimal::add);
        }
        return map;
    }

    private void reserveDirect(ProWorkorder wo, ProWorkorderBom bom, MdItem item, BigDecimal need)
    {
        List<StockTake> takes = takeFromFifo(bom.getItemId(), need, null);
        BigDecimal taken = sumTakes(takes);
        for (StockTake take : takes) insertReservedRow(wo, bom, item, take);
        BigDecimal residual = need.subtract(taken);
        if (residual.signum() > 0) insertOpenRow(wo, bom, item, residual);
    }

    // ==================== 销售出库：开单即锁 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void reserveForProductSales(Long salesId, String salesCode, List<WmProductSalesLine> lines)
    {
        if (salesId == null) return;
        releaseBySource(SOURCE_SALES, salesId);
        if (lines == null || lines.isEmpty()) return;
        Set<Long> ids = new HashSet<>();
        for (WmProductSalesLine line : lines) {
            if (line.getItemId() != null) ids.add(line.getItemId());
        }
        Map<Long, MdItem> items = mesQuantityService.loadItems(ids);
        for (WmProductSalesLine line : lines) {
            if (line.getItemId() == null) continue;
            BigDecimal qty = nvl(line.getQuantitySales()).subtract(nvl(line.getQuantityPosted()));
            if (qty.signum() <= 0) continue;
            MdItem item = items.get(line.getItemId());
            BigDecimal need = mesQuantityService.toBaseQty(qty, line.getUnitOfMeasure(), item);
            reserveSalesLine(salesId, salesCode, line, item, need);
        }
    }

    private void reserveSalesLine(Long salesId, String salesCode, WmProductSalesLine line,
                                  MdItem item, BigDecimal need)
    {
        List<StockTake> takes = takeFromFifo(line.getItemId(), need, line.getWarehouseId());
        BigDecimal taken = sumTakes(takes);
        for (StockTake take : takes) {
            WmStockReservation row = newSalesRow(salesId, salesCode, line, item, take.getQty());
            applyTake(row, take);
            row.setDemandQty(take.getQty());
            row.setReservedQty(take.getQty());
            row.setStatus(ST_RESERVED);
            reservationMapper.insertWmStockReservation(row);
        }
        BigDecimal residual = need.subtract(taken);
        if (residual.signum() > 0) {
            WmStockReservation row = newSalesRow(salesId, salesCode, line, item, residual);
            row.setDemandQty(residual);
            row.setReservedQty(BigDecimal.ZERO);
            row.setStatus(ST_OPEN);
            reservationMapper.insertWmStockReservation(row);
        }
    }

    private WmStockReservation newSalesRow(Long salesId, String salesCode, WmProductSalesLine line,
                                           MdItem item, BigDecimal qty)
    {
        WmStockReservation row = new WmStockReservation();
        row.setItemId(line.getItemId());
        row.setItemCode(line.getItemCode());
        row.setItemName(line.getItemName());
        row.setSpecification(line.getSpecification());
        row.setUnitOfMeasure(item != null ? item.getUnitOfMeasure() : line.getUnitOfMeasure());
        row.setUnitName(item != null ? item.getUnitName() : line.getUnitName());
        row.setSourceDocType(SOURCE_SALES);
        row.setSourceDocId(salesId);
        row.setSourceDocCode(salesCode);
        row.setSourceLineId(line.getLineId());
        row.setSourceType("SALES_OUT");
        row.setConsumedQty(BigDecimal.ZERO);
        row.setReleasedQty(BigDecimal.ZERO);
        row.setTransferredQty(BigDecimal.ZERO);
        row.setDemandDate(DateUtils.getNowDate());
        row.setCreateBy(SecurityUtils.getUsername());
        row.setCreateTime(DateUtils.getNowDate());
        return row;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void consumeBySource(String sourceDocType, Long sourceDocId, Long itemId, BigDecimal qty)
    {
        if (sourceDocType == null || sourceDocId == null || itemId == null || qty == null || qty.signum() <= 0) return;
        WmStockReservation q = new WmStockReservation();
        q.setSourceDocType(sourceDocType);
        q.setSourceDocId(sourceDocId);
        q.setItemId(itemId);
        BigDecimal remaining = qty;
        for (WmStockReservation row : reservationMapper.selectBySource(q)) {
            if (remaining.signum() <= 0) break;
            if (!isActive(row) || nvl(row.getReservedQty()).signum() <= 0) continue;
            BigDecimal take = nvl(row.getReservedQty()).min(remaining);
            returnStock(row, take, false); // 出库只减锁定量，可用量在开单时已扣
            row.setReservedQty(nvl(row.getReservedQty()).subtract(take));
            row.setConsumedQty(nvl(row.getConsumedQty()).add(take));
            row.setStatus(nvl(row.getReservedQty()).signum() > 0 ? ST_PARTIAL : ST_CONSUMED);
            touch(row);
            reservationMapper.updateWmStockReservation(row);
            remaining = remaining.subtract(take);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void releaseBySource(String sourceDocType, Long sourceDocId)
    {
        if (sourceDocType == null || sourceDocId == null) return;
        WmStockReservation q = new WmStockReservation();
        q.setSourceDocType(sourceDocType);
        q.setSourceDocId(sourceDocId);
        for (WmStockReservation row : reservationMapper.selectBySource(q)) {
            if (ST_OPEN.equals(row.getStatus()) || ST_CONSUMED.equals(row.getStatus())) {
                row.setStatus(ST_RELEASED);
                touch(row);
                reservationMapper.updateWmStockReservation(row);
                continue;
            }
            releaseRow(row, nvl(row.getReservedQty()));
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public BigDecimal transferToIssue(Long workorderId, Long itemId, BigDecimal qty, Long issueId, String issueCode)
    {
        if (workorderId == null || itemId == null || qty == null || qty.signum() <= 0) return BigDecimal.ZERO;
        WmStockReservation q = new WmStockReservation();
        q.setWorkorderId(workorderId);
        q.setItemId(itemId);
        BigDecimal remaining = qty;
        for (WmStockReservation row : reservationMapper.selectByWorkorder(q)) {
            if (remaining.signum() <= 0) break;
            if (!isActive(row) || nvl(row.getReservedQty()).signum() <= 0) continue;
            remaining = transferRow(row, remaining, issueId, issueCode);
        }
        return qty.subtract(remaining);
    }

    private BigDecimal transferRow(WmStockReservation row, BigDecimal remaining, Long issueId, String issueCode)
    {
        BigDecimal take = nvl(row.getReservedQty()).min(remaining);
        returnStock(row, take, true);
        row.setReservedQty(nvl(row.getReservedQty()).subtract(take));
        row.setTransferredQty(nvl(row.getTransferredQty()).add(take));
        row.setIssueId(issueId);
        row.setIssueCode(issueCode);
        row.setStatus(nvl(row.getReservedQty()).signum() > 0 ? ST_PARTIAL : ST_TRANSFERRED);
        touch(row);
        reservationMapper.updateWmStockReservation(row);
        return remaining.subtract(take);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void restoreFromIssue(Long issueId)
    {
        if (issueId == null) return;
        WmStockReservation q = new WmStockReservation();
        q.setIssueId(issueId);
        for (WmStockReservation row : reservationMapper.selectByIssue(q)) {
            BigDecimal back = nvl(row.getTransferredQty());
            if (back.signum() <= 0) continue;
            List<StockTake> takes = takeFromFifo(row.getItemId(), back);
            BigDecimal taken = sumTakes(takes);
            row.setReservedQty(nvl(row.getReservedQty()).add(taken));
            row.setTransferredQty(back.subtract(taken));
            row.setIssueId(null);
            row.setIssueCode(null);
            row.setStatus(resolveActiveStatus(row));
            touch(row);
            reservationMapper.updateWmStockReservation(row);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void consumeByIssue(Long issueId)
    {
        if (issueId == null) return;
        WmStockReservation q = new WmStockReservation();
        q.setIssueId(issueId);
        for (WmStockReservation row : reservationMapper.selectByIssue(q)) {
            BigDecimal consumed = nvl(row.getTransferredQty());
            if (consumed.signum() <= 0) continue;
            row.setConsumedQty(nvl(row.getConsumedQty()).add(consumed));
            row.setTransferredQty(BigDecimal.ZERO);
            if (nvl(row.getReservedQty()).signum() <= 0) row.setStatus(ST_CONSUMED);
            touch(row);
            reservationMapper.updateWmStockReservation(row);
        }
    }

    // ==================== 采购到货回补 ====================

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void reallocateByItem(Long itemId)
    {
        if (itemId == null) return;
        WmStockReservation q = new WmStockReservation();
        q.setItemId(itemId);
        List<WmStockReservation> rows = reservationMapper.selectActiveByItem(q);
        for (WmStockReservation row : rows) {
            BigDecimal open = nvl(row.getDemandQty())
                    .subtract(nvl(row.getReservedQty())).subtract(nvl(row.getConsumedQty()));
            if (open.signum() <= 0) continue;
            allocateToOpenRow(row, open);
        }
    }

    /** 把缺口行按 FIFO 补足；不足部分保留为该行剩余需求 */
    private void allocateToOpenRow(WmStockReservation row, BigDecimal open)
    {
        List<StockTake> takes = takeFromFifo(row.getItemId(), open);
        BigDecimal taken = sumTakes(takes);
        if (taken.signum() <= 0) return;
        if (takes.size() == 1 && taken.compareTo(open) == 0) {
            applyTake(row, takes.get(0));
            row.setReservedQty(nvl(row.getReservedQty()).add(taken));
            row.setStatus(ST_RESERVED);
            touch(row);
            reservationMapper.updateWmStockReservation(row);
            return;
        }
        splitAndApply(row, takes, open);
    }

    /** 从缺口行拆出已满足部分，剩余需求留在原行 */
    private void splitAndApply(WmStockReservation row, List<StockTake> takes, BigDecimal open)
    {
        BigDecimal taken = sumTakes(takes);
        for (StockTake take : takes) {
            WmStockReservation allocated = copyRow(row);
            applyTake(allocated, take);
            allocated.setDemandQty(take.getQty());
            allocated.setReservedQty(take.getQty());
            allocated.setConsumedQty(BigDecimal.ZERO);
            allocated.setReleasedQty(BigDecimal.ZERO);
            allocated.setStatus(ST_RESERVED);
            allocated.setReservationId(null);
            reservationMapper.insertWmStockReservation(allocated);
        }
        row.setDemandQty(nvl(row.getDemandQty()).subtract(taken));
        row.setStatus(resolveActiveStatus(row));
        touch(row);
        reservationMapper.updateWmStockReservation(row);
        if (row.getDemandQty().signum() < 0) throw new ServiceException("预占回补数量异常");
    }

    // ==================== 查询 ====================

    @Override
    public List<WmStockReservation> selectList(WmStockReservation query)
    {
        return reservationMapper.selectWmStockReservationList(query);
    }

    @Override
    public BigDecimal sumActiveByItem(Long itemId)
    {
        WmStockReservation q = new WmStockReservation();
        q.setItemId(itemId);
        BigDecimal sum = reservationMapper.sumActiveByItem(q);
        return sum == null ? BigDecimal.ZERO : sum;
    }

    // ==================== 库存分配 ====================

    /** FIFO 占用可用库存，返回每次实际占用的库存行与数量 */
    private List<StockTake> takeFromFifo(Long itemId, BigDecimal need)
    {
        return takeFromFifo(itemId, need, null);
    }

    /** FIFO 占用可用库存（可限定仓库；warehouseId=null 表示跨仓） */
    private List<StockTake> takeFromFifo(Long itemId, BigDecimal need, Long warehouseId)
    {
        List<StockTake> takes = new ArrayList<>();
        BigDecimal remaining = need;
        if (need == null || need.signum() <= 0) return takes;
        List<WmMaterialStock> stocks = stockMapper.selectAvailableStocksForFifo(itemId, warehouseId, Q_NORMAL);
        for (WmMaterialStock stock : stocks) {
            if (remaining.signum() <= 0) break;
            mesQuantityService.normalizeStockRow(stock);
            BigDecimal avail = nvl(stock.getQuantityAvailable());
            if (avail.signum() <= 0) continue;
            BigDecimal take = avail.min(remaining);
            lockStock(stock, take);
            takes.add(new StockTake(stock, take));
            remaining = remaining.subtract(take);
        }
        return takes;
    }

    private void lockStock(WmMaterialStock stock, BigDecimal take)
    {
        stock.setQuantityAvailable(nvl(stock.getQuantityAvailable()).subtract(take));
        stock.setQuantityLocked(nvl(stock.getQuantityLocked()).add(take));
        stock.setUpdateBy(SecurityUtils.getUsername());
        stock.setUpdateTime(new Date());
        stockMapper.updateWmMaterialStock(stock);
    }

    /** 归还库存锁（release=true 时同时归还可用量；内部转移时仅调整锁定量） */
    private void returnStock(WmStockReservation row, BigDecimal qty, boolean restoreAvailable)
    {
        if (row.getMaterialStockId() == null || qty.signum() <= 0) return;
        WmMaterialStock stock = stockMapper.selectMaterialStockForUpdateById(row.getMaterialStockId());
        if (stock == null) return;
        stock.setQuantityLocked(nvl(stock.getQuantityLocked()).subtract(qty).max(BigDecimal.ZERO));
        if (restoreAvailable) {
            stock.setQuantityAvailable(nvl(stock.getQuantityAvailable()).add(qty));
        }
        stock.setUpdateBy(SecurityUtils.getUsername());
        stock.setUpdateTime(new Date());
        stockMapper.updateWmMaterialStock(stock);
    }

    /** 释放一行预占：库存归还可用量，行状态置 RELEASED */
    private void releaseRow(WmStockReservation row, BigDecimal qty)
    {
        if (!isActive(row) || qty.signum() <= 0) return;
        returnStock(row, qty, true);
        row.setReservedQty(nvl(row.getReservedQty()).subtract(qty).max(BigDecimal.ZERO));
        row.setReleasedQty(nvl(row.getReleasedQty()).add(qty));
        row.setStatus(ST_RELEASED);
        touch(row);
        reservationMapper.updateWmStockReservation(row);
    }

    // ==================== 行构造 ====================

    private void insertReservedRow(ProWorkorder wo, ProWorkorderBom bom, MdItem item, StockTake take)
    {
        WmStockReservation row = newRow(wo, bom, item, take.getQty());
        applyTake(row, take);
        row.setDemandQty(take.getQty());
        row.setReservedQty(take.getQty());
        row.setStatus(ST_RESERVED);
        reservationMapper.insertWmStockReservation(row);
    }

    private void insertOpenRow(ProWorkorder wo, ProWorkorderBom bom, MdItem item, BigDecimal qty)
    {
        WmStockReservation row = newRow(wo, bom, item, qty);
        row.setDemandQty(qty);
        row.setReservedQty(BigDecimal.ZERO);
        row.setStatus(ST_OPEN);
        reservationMapper.insertWmStockReservation(row);
    }

    private WmStockReservation newRow(ProWorkorder wo, ProWorkorderBom bom, MdItem item, BigDecimal qty)
    {
        WmStockReservation row = new WmStockReservation();
        row.setItemId(bom.getItemId());
        row.setItemCode(bom.getItemCode());
        row.setItemName(bom.getItemName());
        row.setSpecification(bom.getItemSpc());
        row.setUnitOfMeasure(item != null ? item.getUnitOfMeasure() : bom.getUnitOfMeasure());
        row.setUnitName(item != null ? item.getUnitName() : bom.getUnitName());
        row.setWorkorderId(wo.getWorkorderId());
        row.setWorkorderCode(wo.getWorkorderCode());
        row.setWorkorderName(wo.getWorkorderName());
        row.setSalesOrderLineId(wo.getSalesOrderLineId());
        row.setSourceType("WORKORDER");
        row.setConsumedQty(BigDecimal.ZERO);
        row.setReleasedQty(BigDecimal.ZERO);
        row.setTransferredQty(BigDecimal.ZERO);
        row.setDemandDate(wo.getRequestDate() != null ? wo.getRequestDate() : DateUtils.getNowDate());
        row.setCreateBy(SecurityUtils.getUsername());
        row.setCreateTime(DateUtils.getNowDate());
        return row;
    }

    private WmStockReservation copyRow(WmStockReservation src)
    {
        WmStockReservation row = new WmStockReservation();
        row.setItemId(src.getItemId());
        row.setItemCode(src.getItemCode());
        row.setItemName(src.getItemName());
        row.setSpecification(src.getSpecification());
        row.setUnitOfMeasure(src.getUnitOfMeasure());
        row.setUnitName(src.getUnitName());
        row.setWorkorderId(src.getWorkorderId());
        row.setWorkorderCode(src.getWorkorderCode());
        row.setWorkorderName(src.getWorkorderName());
        row.setSalesOrderId(src.getSalesOrderId());
        row.setSalesOrderLineId(src.getSalesOrderLineId());
        row.setSourceType(src.getSourceType());
        row.setDemandDate(src.getDemandDate());
        row.setCreateBy(SecurityUtils.getUsername());
        row.setCreateTime(DateUtils.getNowDate());
        return row;
    }

    private void applyTake(WmStockReservation row, StockTake take)
    {
        applyStock(row, take.getStock());
    }

    private void applyStock(WmStockReservation row, WmMaterialStock stock)
    {
        row.setMaterialStockId(stock.getMaterialStockId());
        row.setWarehouseId(stock.getWarehouseId());
        row.setWarehouseCode(stock.getWarehouseCode());
        row.setWarehouseName(stock.getWarehouseName());
        row.setBatchId(stock.getBatchId());
        row.setBatchCode(stock.getBatchCode());
    }

    private void touch(WmStockReservation row)
    {
        row.setUpdateBy(SecurityUtils.getUsername());
        row.setUpdateTime(DateUtils.getNowDate());
    }

    // ==================== 工具 ====================

    private boolean isActive(WmStockReservation row)
    {
        String s = row.getStatus();
        return ST_OPEN.equals(s) || ST_PARTIAL.equals(s) || ST_RESERVED.equals(s);
    }

    private String resolveActiveStatus(WmStockReservation row)
    {
        BigDecimal reserved = nvl(row.getReservedQty());
        BigDecimal demand = nvl(row.getDemandQty());
        if (demand.signum() <= 0) return ST_RELEASED;
        if (reserved.signum() <= 0) return ST_OPEN;
        return reserved.compareTo(demand) >= 0 ? ST_RESERVED : ST_PARTIAL;
    }

    private Set<Long> collectItemIds(List<ProWorkorderBom> boms)
    {
        Set<Long> ids = new HashSet<>();
        for (ProWorkorderBom bom : boms) {
            if (bom.getItemId() != null) ids.add(bom.getItemId());
        }
        return ids;
    }

    private BigDecimal sumTakes(List<StockTake> takes)
    {
        BigDecimal sum = BigDecimal.ZERO;
        for (StockTake take : takes) sum = sum.add(take.getQty());
        return sum;
    }

    private BigDecimal nvl(BigDecimal v) { return v == null ? BigDecimal.ZERO : v; }

    /** 一次库存分配结果 */
    private static class StockTake
    {
        private final WmMaterialStock stock;
        private final BigDecimal qty;

        StockTake(WmMaterialStock stock, BigDecimal qty)
        {
            this.stock = stock;
            this.qty = qty;
        }

        WmMaterialStock getStock() { return stock; }
        BigDecimal getQty() { return qty; }
    }
}
