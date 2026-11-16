package com.ruoyi.system.service.mes.wm.impl;

import java.math.BigDecimal;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.mes.wm.WmMaterialStock;
import com.ruoyi.system.domain.mes.wm.WmTransaction;
import com.ruoyi.system.mapper.mes.wm.WmMaterialStockMapper;
import com.ruoyi.system.mapper.mes.wm.WmTransactionMapper;
import com.ruoyi.system.service.mes.wm.IWmMaterialStockService;

@Service
public class WmMaterialStockServiceImpl implements IWmMaterialStockService
{
    /** 库存手工维护的来源单类型 */
    private static final String SOURCE_DOC_TYPE = "wm_material_stock";

    @Autowired
    private WmMaterialStockMapper wmMaterialStockMapper;

    @Autowired
    private WmTransactionMapper wmTransactionMapper;

    @Override
    public List<WmMaterialStock> selectWmMaterialStockList(WmMaterialStock entity) {
        return wmMaterialStockMapper.selectWmMaterialStockList(entity);
    }

    @Override
    public List<WmMaterialStock> selectWmMaterialStockAll() {
        return wmMaterialStockMapper.selectWmMaterialStockAll();
    }

    @Override
    public WmMaterialStock selectWmMaterialStockByMaterialStockId(Long materialStockId) {
        return wmMaterialStockMapper.selectWmMaterialStockByMaterialStockId(materialStockId);
    }

    @Override
    @Transactional
    public int insertWmMaterialStock(WmMaterialStock entity) {
        entity.setCreateTime(DateUtils.getNowDate());
        if (entity.getCreateBy() == null) entity.setCreateBy(SecurityUtils.getUsername());
        int rows = wmMaterialStockMapper.insertWmMaterialStock(entity);
        // 手工新增留痕：前值 0 → 后值
        writeTxn(entity, "MANUAL_IN", BigDecimal.ZERO,
                nvl(entity.getQuantityOnhand()), "MANUAL", null, "手工新增库存");
        return rows;
    }

    @Override
    @Transactional
    public int updateWmMaterialStock(WmMaterialStock entity) {
        WmMaterialStock before = wmMaterialStockMapper
                .selectWmMaterialStockByMaterialStockId(entity.getMaterialStockId());
        entity.setUpdateTime(DateUtils.getNowDate());
        if (entity.getUpdateBy() == null) entity.setUpdateBy(SecurityUtils.getUsername());
        int rows = wmMaterialStockMapper.updateWmMaterialStock(entity);
        WmMaterialStock after = before == null ? entity : merge(before, entity);
        writeTxn(after, "MANUAL_ADJUST",
                before == null ? null : nvl(before.getQuantityOnhand()),
                nvl(after.getQuantityOnhand()), "MANUAL", null, "手工编辑库存");
        return rows;
    }

    @Override
    @Transactional
    public int deleteWmMaterialStockByMaterialStockId(Long materialStockId) {
        WmMaterialStock before = wmMaterialStockMapper
                .selectWmMaterialStockByMaterialStockId(materialStockId);
        int rows = wmMaterialStockMapper.deleteWmMaterialStockByMaterialStockId(materialStockId);
        if (before != null)
        {
            writeTxn(before, "MANUAL_OUT", nvl(before.getQuantityOnhand()),
                    BigDecimal.ZERO, "MANUAL", null, "手工删除库存");
        }
        return rows;
    }

    @Override
    @Transactional
    public int deleteWmMaterialStockByMaterialStockIds(Long[] materialStockIds) {
        int rows = 0;
        for (Long id : materialStockIds)
        {
            rows += deleteWmMaterialStockByMaterialStockId(id);
        }
        return rows;
    }

    /** 查可用批次列表（发料弹窗批次下拉用）：NORMAL 质量、onhand>0，按入库时间升序 */
    @Override
    public List<WmMaterialStock> selectAvailableBatches(Long itemId, Long warehouseId) {
        return wmMaterialStockMapper.selectAvailableBatches(itemId, warehouseId, "NORMAL");
    }

    /** 批次码精确反查（扫码用）：同批次可分布在多仓/多库位，返回全部库存行 */
    @Override
    public List<WmMaterialStock> scanByBatchCode(String batchCode) {
        String code = batchCode == null ? "" : batchCode.trim();
        if (code.isEmpty()) {
            throw new ServiceException("批次码不能为空");
        }
        return wmMaterialStockMapper.selectWmMaterialStockByExactBatchCode(code);
    }

    /**
     * 写库存流水（手工新增/编辑/删除/导入共用）。
     * 数量 = 后值 - 前值；前值为空时按变动量记正数。
     */
    void writeTxn(WmMaterialStock stock, String type, BigDecimal before, BigDecimal after,
                  String source, String importBatchNo, String remark)
    {
        if (stock == null || stock.getMaterialStockId() == null) return;
        BigDecimal qty = after == null ? BigDecimal.ZERO
                : (before == null ? after : after.subtract(before));
        WmTransaction txn = new WmTransaction();
        txn.setTransactionType(type);
        txn.setSourceDocType(SOURCE_DOC_TYPE);
        txn.setSourceDocId(stock.getMaterialStockId());
        txn.setSourceDocCode(stock.getItemCode());
        txn.setMaterialStockId(stock.getMaterialStockId());
        txn.setItemId(stock.getItemId());
        txn.setItemCode(stock.getItemCode());
        txn.setItemName(stock.getItemName());
        txn.setSpecification(stock.getSpecification());
        txn.setUnitOfMeasure(stock.getUnitOfMeasure());
        txn.setUnitName(stock.getUnitName());
        txn.setQuantity(qty);
        txn.setUnit2(stock.getUnit2());
        txn.setUnit2Name(stock.getUnit2Name());
        txn.setQuantity2(stock.getQuantityOnhand2());
        txn.setBatchId(stock.getBatchId());
        txn.setBatchCode(stock.getBatchCode());
        txn.setWarehouseId(stock.getWarehouseId());
        txn.setWarehouseCode(stock.getWarehouseCode());
        txn.setWarehouseName(stock.getWarehouseName());
        txn.setLocationId(stock.getLocationId());
        txn.setAreaId(stock.getAreaId());
        txn.setBeforeQuantity(before);
        txn.setAfterQuantity(after);
        txn.setImportBatchNo(importBatchNo);
        txn.setOperationSource(source);
        txn.setTransactionTime(DateUtils.getNowDate());
        txn.setRemark(remark);
        txn.setCreateBy(SecurityUtils.getUsername());
        txn.setCreateTime(DateUtils.getNowDate());
        wmTransactionMapper.insertWmTransaction(txn);
    }

    private WmMaterialStock merge(WmMaterialStock before, WmMaterialStock patch)
    {
        if (patch.getQuantityOnhand() == null) patch.setQuantityOnhand(before.getQuantityOnhand());
        if (patch.getQuantityOnhand2() == null) patch.setQuantityOnhand2(before.getQuantityOnhand2());
        // 流水需要完整的物料/仓库信息，补全入参未携带的身份字段
        if (patch.getItemId() == null) patch.setItemId(before.getItemId());
        if (patch.getItemCode() == null) patch.setItemCode(before.getItemCode());
        if (patch.getItemName() == null) patch.setItemName(before.getItemName());
        if (patch.getSpecification() == null) patch.setSpecification(before.getSpecification());
        if (patch.getUnitOfMeasure() == null) patch.setUnitOfMeasure(before.getUnitOfMeasure());
        if (patch.getUnitName() == null) patch.setUnitName(before.getUnitName());
        if (patch.getUnit2() == null) patch.setUnit2(before.getUnit2());
        if (patch.getUnit2Name() == null) patch.setUnit2Name(before.getUnit2Name());
        if (patch.getWarehouseId() == null) patch.setWarehouseId(before.getWarehouseId());
        if (patch.getWarehouseCode() == null) patch.setWarehouseCode(before.getWarehouseCode());
        if (patch.getWarehouseName() == null) patch.setWarehouseName(before.getWarehouseName());
        if (patch.getBatchId() == null) patch.setBatchId(before.getBatchId());
        if (patch.getBatchCode() == null) patch.setBatchCode(before.getBatchCode());
        if (patch.getLocationId() == null) patch.setLocationId(before.getLocationId());
        if (patch.getAreaId() == null) patch.setAreaId(before.getAreaId());
        return patch;
    }

    private BigDecimal nvl(BigDecimal v)
    {
        return v == null ? BigDecimal.ZERO : v;
    }
}
