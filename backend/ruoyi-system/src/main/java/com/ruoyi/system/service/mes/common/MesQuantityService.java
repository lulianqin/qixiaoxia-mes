package com.ruoyi.system.service.mes.common;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.system.domain.mes.md.MdItem;
import com.ruoyi.system.domain.mes.pro.ProWorkorderBom;
import com.ruoyi.system.domain.mes.wm.WmMaterialStock;
import com.ruoyi.system.mapper.mes.md.MdItemMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * MES 数量与单位统一计算服务（数据驱动，不写死任何物料/换算率）。
 *
 * <p>单位模型：物料主数据 {@code md_item} 的 unit_of_measure 为主单位（库存基准），
 * unit2 为辅助单位，conversion_rate 表示「1 主单位 = N 辅助单位」。
 *
 * <p>用量模型：工单 BOM 行 quantity_mode 为 PER_UNIT 时按件用量（× 工单数量），
 * 为 TOTAL 时直接使用整单总量；两者最终都按 (1 + 损耗率) 放大。
 * 最终用量允许人工覆盖（总用量已落库时直接采用）。
 */
@Service
public class MesQuantityService
{
    /** 按件用量：总需求 = 单位用量 × 工单数量 */
    public static final String MODE_PER_UNIT = "PER_UNIT";
    /** 整单总量：总需求 = 整单填写数量（不再乘工单数量） */
    public static final String MODE_TOTAL = "TOTAL";

    private static final int SCALE = 4;

    @Autowired
    private MdItemMapper mdItemMapper;

    /** 按物料ID集合批量加载（批量换算入口） */
    public Map<Long, MdItem> loadItems(Collection<Long> itemIds)
    {
        Map<Long, MdItem> map = new HashMap<>();
        if (itemIds == null || itemIds.isEmpty()) return map;
        Long[] ids = itemIds.stream().filter(java.util.Objects::nonNull).distinct().toArray(Long[]::new);
        if (ids.length == 0) return map;
        List<MdItem> items = mdItemMapper.selectMdItemByIds(ids);
        if (items != null)
        {
            for (MdItem item : items) map.put(item.getItemId(), item);
        }
        return map;
    }

    /**
     * 计算 BOM 行的整单需求（业务单位），包含损耗率。
     * 自动兼容历史数据：未设置用量方式时按 PER_UNIT。
     */
    public BigDecimal calcTotalQty(ProWorkorderBom bom, BigDecimal workorderQty)
    {
        if (bom == null) return BigDecimal.ZERO;
        BigDecimal qty = nvl(bom.getQuantity());
        BigDecimal total;
        if (MODE_TOTAL.equalsIgnoreCase(bom.getQuantityMode()))
        {
            total = qty;
        }
        else
        {
            total = qty.multiply(nvl(workorderQty));
        }
        BigDecimal scrap = nvl(bom.getScrapRate());
        return total.multiply(BigDecimal.ONE.add(scrap)).setScale(SCALE, RoundingMode.HALF_UP);
    }

    /**
     * 取得 BOM 行整单需求：已落库的总用量优先（人工可覆盖），否则按用量方式计算。
     */
    public BigDecimal requiredTotalQty(ProWorkorderBom bom, BigDecimal workorderQty)
    {
        if (bom == null) return BigDecimal.ZERO;
        // 仅正数视为「已落库的人工覆盖值」；0/NULL 多为历史默认值或未填写，回退到按用量方式计算
        if (bom.getTotalQuantity() != null
                && bom.getTotalQuantity().compareTo(BigDecimal.ZERO) > 0) {
            return bom.getTotalQuantity();
        }
        return calcTotalQty(bom, workorderQty);
    }

    /** 业务单位数量 → 库存基准单位（主单位） */
    public BigDecimal toBaseQty(BigDecimal qty, String fromUnit, MdItem item)
    {
        if (qty == null) return BigDecimal.ZERO;
        if (item == null) return qty;
        if (isBaseUnit(fromUnit, item)) return qty;
        if (isAuxUnit(fromUnit, item))
        {
            BigDecimal rate = item.getConversionRate();
            if (rate == null || rate.compareTo(BigDecimal.ZERO) <= 0)
            {
                throw new ServiceException(unitError(item, fromUnit, item.getUnitOfMeasure()));
            }
            return qty.divide(rate, 6, RoundingMode.HALF_UP).setScale(SCALE, RoundingMode.HALF_UP);
        }
        // 单位为空时按主单位处理（历史数据兼容）
        if (fromUnit == null || fromUnit.trim().isEmpty()) return qty;
        throw new ServiceException(unitError(item, fromUnit, item.getUnitOfMeasure()));
    }

    /** 业务单位数量 → 辅助单位 */
    public BigDecimal toAuxQty(BigDecimal qty, String fromUnit, MdItem item)
    {
        if (qty == null) return BigDecimal.ZERO;
        if (item == null) return qty;
        if (isAuxUnit(fromUnit, item)) return qty;
        if (isBaseUnit(fromUnit, item))
        {
            BigDecimal rate = item.getConversionRate();
            if (rate == null || rate.compareTo(BigDecimal.ZERO) <= 0)
            {
                throw new ServiceException(unitError(item, fromUnit, item.getUnit2()));
            }
            return qty.multiply(rate).setScale(SCALE, RoundingMode.HALF_UP);
        }
        if (fromUnit == null || fromUnit.trim().isEmpty()) return qty;
        throw new ServiceException(unitError(item, fromUnit, item.getUnit2()));
    }

    public boolean isBaseUnit(String unit, MdItem item)
    {
        return matches(unit, item.getUnitOfMeasure()) || matches(unit, item.getUnitName());
    }

    public boolean isAuxUnit(String unit, MdItem item)
    {
        if (item.getUnit2() == null || item.getUnit2().trim().isEmpty()) return false;
        return matches(unit, item.getUnit2()) || matches(unit, item.getUnit2Name());
    }

    /** 判断物料是否配置了可用的辅助单位与换算率 */
    public boolean hasAuxUnit(MdItem item)
    {
        return item != null && item.getUnit2() != null && !item.getUnit2().trim().isEmpty()
                && item.getConversionRate() != null && item.getConversionRate().compareTo(BigDecimal.ZERO) > 0;
    }

    private boolean matches(String a, String b)
    {
        return a != null && b != null && a.trim().equalsIgnoreCase(b.trim());
    }

    private String unitError(MdItem item, String fromUnit, String targetUnit)
    {
        String code = item.getItemCode() != null ? item.getItemCode() : String.valueOf(item.getItemId());
        return "物料[" + code + "]单位[" + fromUnit + "]无法换算到[" + targetUnit
                + "]，请检查物料主数据的单位/换算率";
    }

    private BigDecimal nvl(BigDecimal v)
    {
        return v == null ? BigDecimal.ZERO : v;
    }

    /**
     * 把库存行的数量归一到物料主单位（懒迁移）。
     * 历史行可能按辅助单位记录；在本次出库/入库写回前先换算，
     * 同时保留辅助单位数量供页面展示（部分卷场景由业务人工调整）。
     *
     * <p>本身即主单位的行不换算，但会刷新单位/换算率快照并补记辅助单位数量，
     * 未记录过辅助数量的历史行（onhand2=0）按主数据换算率折算一次；已记录的部分卷保持不变。
     *
     * @return true 表示已按主数据归一化（调用方应写回库存行）
     */
    public boolean normalizeStockRow(WmMaterialStock stock)
    {
        if (stock == null || stock.getItemId() == null) return false;
        MdItem item = mdItemMapper.selectMdItemById(stock.getItemId());
        if (item == null) return false;
        BigDecimal baseOnhand;
        BigDecimal baseAvail;
        BigDecimal auxOnhand;
        BigDecimal auxAvail;
        if (isBaseUnit(stock.getUnitOfMeasure(), item))
        {
            baseOnhand = nvl(stock.getQuantityOnhand());
            baseAvail = nvl(stock.getQuantityAvailable());
            auxOnhand = nvl(stock.getQuantityOnhand2());
            auxAvail = nvl(stock.getQuantityAvailable2());
            // 历史行未记录辅助单位数量时按主数据换算率补记；已记录的（部分卷）保持不动
            if (hasAuxUnit(item))
            {
                if (isZero(auxOnhand) && !isZero(baseOnhand))
                    auxOnhand = toAuxQty(baseOnhand, item.getUnitOfMeasure(), item);
                if (isZero(auxAvail) && !isZero(baseAvail))
                    auxAvail = toAuxQty(baseAvail, item.getUnitOfMeasure(), item);
            }
        }
        else
        {
            baseOnhand = toBaseQty(stock.getQuantityOnhand(), stock.getUnitOfMeasure(), item);
            baseAvail = toBaseQty(stock.getQuantityAvailable(), stock.getUnitOfMeasure(), item);
            auxOnhand = isAuxUnit(stock.getUnitOfMeasure(), item)
                    ? nvl(stock.getQuantityOnhand()) : nvl(stock.getQuantityOnhand2());
            auxAvail = isAuxUnit(stock.getUnitOfMeasure(), item)
                    ? nvl(stock.getQuantityAvailable()) : nvl(stock.getQuantityAvailable2());
        }
        stock.setQuantityOnhand(baseOnhand);
        stock.setQuantityAvailable(baseAvail);
        stock.setQuantityOnhand2(auxOnhand);
        stock.setQuantityAvailable2(auxAvail);
        stock.setUnitOfMeasure(item.getUnitOfMeasure());
        stock.setUnitName(item.getUnitName());
        stock.setUnit2(item.getUnit2());
        stock.setUnit2Name(item.getUnit2Name());
        stock.setConversionRate(item.getConversionRate());
        return true;
    }

    private boolean isZero(BigDecimal v)
    {
        return v == null || v.compareTo(BigDecimal.ZERO) == 0;
    }
}
