package com.ruoyi.system.service.mes.wm.impl;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.mes.wm.WmMaterialStock;
import com.ruoyi.system.domain.mes.wm.WmTransaction;
import com.ruoyi.system.domain.mes.md.MdItem;
import com.ruoyi.system.mapper.mes.md.MdItemMapper;
import com.ruoyi.system.mapper.mes.wm.WmMaterialStockMapper;
import com.ruoyi.system.mapper.mes.wm.WmTransactionMapper;
import com.ruoyi.system.service.mes.common.MesQuantityService;
import com.ruoyi.system.service.mes.wm.IWmTransactionService;
import com.ruoyi.common.core.redis.RedisLockTemplate;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * 库存事务Service（先锁后事务：Redisson 分布式锁 → TransactionTemplate 显式开事务）
 *
 * @author qixiaoxia
 * @date 2026-06-12
 */
@Service
public class WmTransactionServiceImpl implements IWmTransactionService
{
    @Autowired
    private WmTransactionMapper wmTransactionMapper;

    @Autowired
    private WmMaterialStockMapper wmMaterialStockMapper;

    @Autowired
    private MdItemMapper mdItemMapper;

    @Autowired
    private MesQuantityService mesQuantityService;

    @Autowired
    private RedisLockTemplate lockTemplate;

    @Autowired
    private PlatformTransactionManager transactionManager;

    /** 缓存单例，线程安全 — 锁内事务超时 30s，防止 DB 死锁时长时间阻塞 */
    private TransactionTemplate txTemplate;

    private static final String LOCK_PREFIX = "wm:stock:lock:";

    @PostConstruct
    void initTx() {
        this.txTemplate = new TransactionTemplate(transactionManager);
        this.txTemplate.setTimeout(30);  // DB 事务最长 30s
    }

    /**
     * 处理库存事务（先锁后事务 — 锁内显式开 TX，确保快照在锁之后）
     *
     * 顺序：validate → initStock → 🔒拿锁 → BEGIN TX → stock UPSERT → insert tx → COMMIT → 🔓放锁
     */
    @Override
    public WmTransaction processTransaction(WmTransaction transaction) {
        validate(transaction);
        MdItem item = transaction.getItemId() != null
                ? mdItemMapper.selectMdItemById(transaction.getItemId()) : null;
        // 所有库存变动统一折算到物料主单位（基准单位），并按换算率维护辅助单位数量
        normalizeUnit(transaction, item);
        WmMaterialStock stock = initStock(transaction, item);
        return lockTemplate.execute(buildLockKey(stock),
                () -> txTemplate.execute(status -> doProcessTransaction(transaction, stock, item)));
    }

    /** 业务单位 → 物料主单位；同时写入辅助单位数量与单位快照 */
    private void normalizeUnit(WmTransaction tx, MdItem item) {
        if (item == null) return;
        BigDecimal baseQty = mesQuantityService.toBaseQty(tx.getQuantity(), tx.getUnitOfMeasure(), item);
        if (mesQuantityService.hasAuxUnit(item)) {
            BigDecimal auxQty = mesQuantityService.toAuxQty(baseQty, item.getUnitOfMeasure(), item);
            tx.setUnit2(item.getUnit2());
            tx.setUnit2Name(item.getUnit2Name());
            tx.setQuantity2(auxQty);
        }
        tx.setQuantity(baseQty);
        tx.setUnitOfMeasure(item.getUnitOfMeasure());
        tx.setUnitName(item.getUnitName());
    }

    private WmTransaction doProcessTransaction(WmTransaction transaction, WmMaterialStock stock, MdItem item) {
        // 幂等检查：同一来源单据行已处理过 → 直接返回已有记录
        WmTransaction existingTx = wmTransactionMapper.selectExistingTransaction(transaction);
        if (existingTx != null) {
            return existingTx;
        }

        WmMaterialStock existing = wmMaterialStockMapper.loadMaterialStockForUpdate(stock);
        BigDecimal delta = transaction.getQuantity();

        if (StringUtils.isNotNull(existing)) {
            // 历史库存行可能按辅助单位记录，先折算到主单位再运算（行会在本次写回时归一到主单位）
            BigDecimal onhandBase = mesQuantityService.toBaseQty(
                    existing.getQuantityOnhand(), existing.getUnitOfMeasure(), item);
            BigDecimal availBase = mesQuantityService.toBaseQty(
                    existing.getQuantityAvailable(), existing.getUnitOfMeasure(), item);
            BigDecimal result = onhandBase.add(delta);
            if (result.compareTo(BigDecimal.ZERO) < 0) {
                throw new ServiceException("库存数量不足！当前库存：" + onhandBase
                        + "，变动：" + delta);
            }
            stock.setQuantityOnhand(result);
            if (delta.compareTo(BigDecimal.ZERO) > 0) {
                stock.setQuantityAvailable(availBase.add(delta));
            } else {
                stock.setQuantityAvailable(availBase.min(result));
            }
            applyAuxQuantity(existing, stock, item, delta, onhandBase, availBase, result, transaction.getQuantity2());
            stock.setMaterialStockId(existing.getMaterialStockId());
            stock.setUpdateTime(new Date());
            wmMaterialStockMapper.updateWmMaterialStock(stock);
        } else {
            if (delta.compareTo(BigDecimal.ZERO) < 0) {
                throw new ServiceException("库存记录不存在，不能执行出库操作");
            }
            stock.setQuantityOnhand(delta);
            stock.setQuantityAvailable(delta);
            BigDecimal auxQty = transaction.getQuantity2() != null ? transaction.getQuantity2() : BigDecimal.ZERO;
            stock.setQuantityOnhand2(auxQty);
            stock.setQuantityAvailable2(auxQty);
            stock.setCreateTime(new Date());
            stock.setUpdateTime(new Date());
            wmMaterialStockMapper.insertWmMaterialStock(stock);
        }

        transaction.setMaterialStockId(stock.getMaterialStockId());
        transaction.setCreateTime(DateUtils.getNowDate());
        transaction.setCreateBy(SecurityUtils.getUsername());
        wmTransactionMapper.insertWmTransaction(transaction);
        return transaction;
    }

    /**
     * 维护辅助单位数量：
     * 入库按换算率累加；出库时部分卷场景保持辅单位不变，库存清零时才归零。
     */
    private void applyAuxQuantity(WmMaterialStock existing, WmMaterialStock stock, MdItem item,
                                  BigDecimal delta, BigDecimal onhandBase, BigDecimal availBase,
                                  BigDecimal resultBase, BigDecimal auxQty) {
        if (item == null || !mesQuantityService.hasAuxUnit(item)) return;
        // 历史行未记录辅助数量时，先按「变动前」的主单位数量折算，避免入库时重复加一次
        BigDecimal existingAux = nvl(existing.getQuantityOnhand2());
        if (existingAux.compareTo(BigDecimal.ZERO) == 0) {
            existingAux = mesQuantityService.isAuxUnit(existing.getUnitOfMeasure(), item)
                    ? nvl(existing.getQuantityOnhand())
                    : mesQuantityService.toAuxQty(onhandBase, item.getUnitOfMeasure(), item);
        }
        BigDecimal aux = delta.compareTo(BigDecimal.ZERO) > 0
                ? existingAux.add(nvl(auxQty))
                : (resultBase.compareTo(BigDecimal.ZERO) == 0 ? BigDecimal.ZERO : existingAux);
        stock.setQuantityOnhand2(aux);

        BigDecimal existingAvail2 = nvl(existing.getQuantityAvailable2());
        if (existingAvail2.compareTo(BigDecimal.ZERO) == 0) {
            existingAvail2 = mesQuantityService.isAuxUnit(existing.getUnitOfMeasure(), item)
                    ? nvl(existing.getQuantityAvailable())
                    : mesQuantityService.toAuxQty(availBase, item.getUnitOfMeasure(), item);
        }
        BigDecimal avail2 = delta.compareTo(BigDecimal.ZERO) > 0
                ? existingAvail2.add(nvl(auxQty))
                : (resultBase.compareTo(BigDecimal.ZERO) == 0 ? BigDecimal.ZERO : existingAvail2);
        stock.setQuantityAvailable2(avail2);
    }

    private BigDecimal nvl(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }

    private String buildLockKey(WmMaterialStock stock) {
        return LOCK_PREFIX + stock.getItemId() + ":" + stock.getBatchId() + ":"
                + stock.getWarehouseId() + ":" + stock.getVendorId() + ":"
                + stock.getWorkorderId() + ":" + stock.getQualityStatus();
    }

    private void validate(WmTransaction tx) {
        if (StringUtils.isNull(tx.getTransactionType())) {
            throw new ServiceException("库存事务类型不能为空");
        }
        if (StringUtils.isNull(tx.getQuantity())) {
            throw new ServiceException("事务数量不能为空");
        }
        if (StringUtils.isNull(tx.getSourceDocCode())) {
            throw new ServiceException("来源单据号不能为空");
        }
        if (StringUtils.isNull(tx.getTransactionTime())) {
            tx.setTransactionTime(new Date());
        }
    }

    private WmMaterialStock initStock(WmTransaction tx, MdItem item) {
        WmMaterialStock stock = new WmMaterialStock();
        stock.setItemId(tx.getItemId());
        stock.setItemCode(tx.getItemCode());
        stock.setItemName(tx.getItemName());
        stock.setSpecification(tx.getSpecification());
        stock.setUnitOfMeasure(tx.getUnitOfMeasure());
        stock.setUnitName(tx.getUnitName());
        if (item != null) {
            stock.setUnit2(item.getUnit2());
            stock.setUnit2Name(item.getUnit2Name());
            stock.setConversionRate(item.getConversionRate());
        }
        stock.setBatchId(tx.getBatchId() != null ? tx.getBatchId() : 0L);
        stock.setBatchCode(tx.getBatchCode());
        stock.setWarehouseId(tx.getWarehouseId());
        stock.setWarehouseCode(tx.getWarehouseCode());
        stock.setWarehouseName(tx.getWarehouseName());
        stock.setLocationId(tx.getLocationId());
        if (StringUtils.isNotNull(tx.getAreaId())) {
            stock.setAreaId(tx.getAreaId());
        }
        stock.setVendorId(tx.getVendorId() != null ? tx.getVendorId() : 0L);
        stock.setWorkorderId(tx.getWorkorderId() != null ? tx.getWorkorderId() : 0L);
        stock.setQualityStatus("NORMAL");
        return stock;
    }

    // ── 标准 CRUD ──

    @Override
    public List<WmTransaction> selectWmTransactionList(WmTransaction entity) {
        return wmTransactionMapper.selectWmTransactionList(entity);
    }

    @Override
    public List<WmTransaction> selectWmTransactionAll() {
        return wmTransactionMapper.selectWmTransactionAll();
    }

    @Override
    public WmTransaction selectWmTransactionByTransactionId(Long transactionId) {
        return wmTransactionMapper.selectWmTransactionByTransactionId(transactionId);
    }

    @Override
    @Transactional
    public int insertWmTransaction(WmTransaction entity) {
        entity.setCreateTime(DateUtils.getNowDate());
        return wmTransactionMapper.insertWmTransaction(entity);
    }

    @Override
    @Transactional
    public int updateWmTransaction(WmTransaction entity) {
        entity.setUpdateTime(DateUtils.getNowDate());
        return wmTransactionMapper.updateWmTransaction(entity);
    }

    @Override
    @Transactional
    public int deleteWmTransactionByTransactionId(Long transactionId) {
        return wmTransactionMapper.deleteWmTransactionByTransactionId(transactionId);
    }

    @Override
    @Transactional
    public int deleteWmTransactionByTransactionIds(Long[] transactionIds) {
        return wmTransactionMapper.deleteWmTransactionByTransactionIds(transactionIds);
    }
}
