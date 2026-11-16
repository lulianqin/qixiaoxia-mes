package com.ruoyi.system.service.mes.wm.impl;

import java.io.InputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.mes.md.MdClient;
import com.ruoyi.system.domain.mes.md.MdItem;
import com.ruoyi.system.domain.mes.md.MdItemType;
import com.ruoyi.system.domain.mes.md.MdVendor;
import com.ruoyi.system.domain.mes.wm.WmMaterialStock;
import com.ruoyi.system.domain.mes.wm.dto.StockImportResult;
import com.ruoyi.system.mapper.mes.md.MdClientMapper;
import com.ruoyi.system.mapper.mes.md.MdItemMapper;
import com.ruoyi.system.mapper.mes.md.MdItemTypeMapper;
import com.ruoyi.system.mapper.mes.md.MdVendorMapper;
import com.ruoyi.system.mapper.mes.wm.WmMaterialStockMapper;
import com.ruoyi.system.service.mes.wm.IWmStockImportService;

/**
 * 库存 Excel 导入（COVER 覆盖）
 *
 * 口径：按「物料分类 + 仓库」入库，不再使用库存类型。
 * 数量单位取物料档案的主单位/辅助单位/换算率（装箱规格）；
 * 物料档案缺单位时，按 Excel 表头或单位列补齐后回写物料档案。
 * 匹配不到物料时按物料分类自动建档（门幅/材质写入物料扩展属性）。
 *
 * @author qixiaoxia
 */
@Service
public class WmStockImportServiceImpl implements IWmStockImportService
{
    private static final String[] ITEM_COL_KEYS = {"产品名称", "物料名称", "材料名称", "辅料名称", "原纸名称", "产品品类"};
    private static final String[] QTY_COL_KEYS = {"剩余kg", "剩余/kg", "剩余重量", "剩余数量", "库存数量"};
    private static final String[] AUX_QTY_COL_KEYS = {"剩余卷", "剩余箱数", "剩余辅助数量", "辅助数量", "剩余辅助"};
    private static final String[] PACK_COL_KEYS = {"装箱数量", "换算率", "箱规"};
    private static final String[] MAIN_UNIT_COL_KEYS = {"数量单位", "主单位"};
    private static final String[] AUX_UNIT_COL_KEYS = {"辅助单位", "辅单位"};

    private static final String UNIT_KG = "kg";
    private static final String UNIT_KG_NAME = "千克";
    private static final String UNIT_BOX = "BOX";
    private static final String UNIT_BOX_NAME = "箱";
    private static final String UNIT_ROLL = "ROLL";
    private static final String UNIT_ROLL_NAME = "卷";

    @Autowired
    private MdItemMapper mdItemMapper;

    @Autowired
    private MdItemTypeMapper mdItemTypeMapper;

    @Autowired
    private MdVendorMapper mdVendorMapper;

    @Autowired
    private MdClientMapper mdClientMapper;

    @Autowired
    private WmMaterialStockMapper wmMaterialStockMapper;

    @Autowired
    private WmMaterialStockServiceImpl stockService;

    @Override
    @Transactional
    public StockImportResult importExcel(InputStream in, String fileName, Long itemTypeId, Long warehouseId,
                                         Long vendorId, Long clientId)
    {
        if (itemTypeId == null) throw new ServiceException("请选择物料分类");
        if (warehouseId == null) throw new ServiceException("请选择仓库");

        ImportContext ctx = new ImportContext();
        ctx.type = mdItemTypeMapper.selectMdItemTypeById(itemTypeId);
        if (ctx.type == null) throw new ServiceException("物料分类不存在");
        ctx.warehouseId = warehouseId;
        ctx.vendor = vendorId == null ? null : mdVendorMapper.selectMdVendorByVendorId(vendorId);
        ctx.client = clientId == null ? null : mdClientMapper.selectMdClientByClientId(clientId);

        StockImportResult result = new StockImportResult();
        result.setImportBatchNo("IMP" + DateUtils.dateTimeNow("yyyyMMddHHmmss"));

        try (Workbook wb = WorkbookFactory.create(in))
        {
            Sheet sheet = wb.getSheetAt(0);
            int headerRowIdx = findHeaderRow(sheet);
            if (headerRowIdx < 0) throw new ServiceException("未识别到表头，请使用系统模板");
            Row header = sheet.getRow(headerRowIdx);

            int colName = findColumn(header, ITEM_COL_KEYS);
            int colQty = findColumn(header, QTY_COL_KEYS);
            if (colName < 0 || colQty < 0) throw new ServiceException("模板缺少「名称」或「剩余数量/剩余kg」列");

            int colSize = findColumn(header, new String[]{"尺寸"});
            int colWidth = findColumn(header, new String[]{"门幅", "规格"});
            int colMat = findColumn(header, new String[]{"材料种类", "材质"});
            int colPack = findColumn(header, PACK_COL_KEYS);
            int colAuxQty = findColumn(header, AUX_QTY_COL_KEYS);
            int colMainUnit = findColumn(header, MAIN_UNIT_COL_KEYS);
            int colAuxUnit = findColumn(header, AUX_UNIT_COL_KEYS);
            String qtyHeader = str(header.getCell(colQty));
            String auxHeader = colAuxQty >= 0 ? str(header.getCell(colAuxQty)) : "";

            for (int i = headerRowIdx + 1; i <= sheet.getLastRowNum(); i++)
            {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                String name = str(row.getCell(colName));
                BigDecimal qty = num(row.getCell(colQty));
                if (StringUtils.isEmpty(name) || qty == null)
                {
                    result.setSkipCount(result.getSkipCount() + 1);
                    continue;
                }
                try
                {
                    RowValues rv = buildRowValues(row, colSize, colWidth, colMat, colPack, colAuxQty,
                            colMainUnit, colAuxUnit, qtyHeader, auxHeader);
                    rv.name = name;
                    rv.qty = qty;
                    MdItem item = findOrCreateItem(result, ctx, rv);
                    upsertStock(result, ctx, item, rv);
                    result.setSuccessCount(result.getSuccessCount() + 1);
                }
                catch (Exception e)
                {
                    result.getErrors().add("第" + (i + 1) + "行: " + e.getMessage());
                }
            }
        }
        catch (ServiceException e)
        {
            throw e;
        }
        catch (Exception e)
        {
            throw new ServiceException("Excel 解析失败：" + e.getMessage());
        }
        return result;
    }

    private RowValues buildRowValues(Row row, int colSize, int colWidth, int colMat, int colPack, int colAuxQty,
                                     int colMainUnit, int colAuxUnit, String qtyHeader, String auxHeader)
    {
        RowValues rv = new RowValues();
        rv.size = colSize >= 0 ? str(row.getCell(colSize)) : "";
        rv.width = colWidth >= 0 ? str(row.getCell(colWidth)) : "";
        rv.matType = colMat >= 0 ? str(row.getCell(colMat)) : "";
        rv.packQty = colPack >= 0 ? num(row.getCell(colPack)) : null;
        rv.auxQty = colAuxQty >= 0 ? num(row.getCell(colAuxQty)) : null;
        String unitCell = colMainUnit >= 0 ? str(row.getCell(colMainUnit)) : "";
        rv.mainUnitName = StringUtils.isNotEmpty(unitCell) ? unitCell : unitNameOf(qtyHeader);
        String auxUnitCell = colAuxUnit >= 0 ? str(row.getCell(colAuxUnit)) : "";
        rv.auxUnitName = StringUtils.isNotEmpty(auxUnitCell) ? auxUnitCell : auxUnitNameOf(auxHeader);
        return rv;
    }

    /** 物料匹配：分类内按 名称 + 门幅/尺寸；匹配不到按分类自动建档 */
    private MdItem findOrCreateItem(StockImportResult result, ImportContext ctx, RowValues rv)
    {
        MdItem query = new MdItem();
        query.setItemName(rv.name);
        query.setItemTypeId(ctx.type.getItemTypeId());
        List<MdItem> list = mdItemMapper.selectMdItemList(query);

        MdItem matched = matchItem(list, rv);
        if (matched != null)
        {
            if (fillMissingUnits(matched, rv)) mdItemMapper.updateMdItem(matched);
            return matched;
        }

        MdItem item = buildItem(ctx, rv);
        mdItemMapper.insertMdItem(item);
        result.setCreatedItemCount(result.getCreatedItemCount() + 1);
        return item;
    }

    private MdItem matchItem(List<MdItem> list, RowValues rv)
    {
        if (list == null) return null;
        String key = StringUtils.isNotEmpty(rv.width) ? rv.width : rv.size;
        for (MdItem item : list)
        {
            if (!rv.name.equals(item.getItemName())) continue;
            if (StringUtils.isEmpty(key)) return item;
            String spec = item.getSpecification();
            if (spec != null && spec.contains(key)) return item;
        }
        return null;
    }

    private MdItem buildItem(ImportContext ctx, RowValues rv)
    {
        MdItem item = new MdItem();
        item.setItemCode(generateItemCode(ctx.type));
        item.setItemName(rv.name);
        item.setSpecification(StringUtils.isNotEmpty(rv.width) ? rv.width : rv.size);
        item.setUnitOfMeasure(unitCode(rv.mainUnitName));
        item.setUnitName(rv.mainUnitName);
        applyAuxUnits(item, rv);
        item.setItemTypeId(ctx.type.getItemTypeId());
        item.setItemTypeCode(ctx.type.getItemTypeCode());
        item.setItemTypeName(ctx.type.getItemTypeName());
        item.setExtAttrs(buildItemAttrs(rv));
        item.setEnableFlag("1");
        item.setCreateBy(SecurityUtils.getUsername());
        item.setCreateTime(DateUtils.getNowDate());
        item.setRemark("库存导入自动建档");
        return item;
    }

    /** 物料档案缺主/辅单位时按 Excel 补齐，避免库存单位与物料档案脱节 */
    private boolean fillMissingUnits(MdItem item, RowValues rv)
    {
        boolean changed = false;
        if (StringUtils.isEmpty(item.getUnitOfMeasure()))
        {
            item.setUnitOfMeasure(unitCode(rv.mainUnitName));
            item.setUnitName(rv.mainUnitName);
            changed = true;
        }
        if (StringUtils.isEmpty(item.getUnit2()) || item.getConversionRate() == null)
        {
            changed |= applyAuxUnits(item, rv);
        }
        return changed;
    }

    /** 辅单位与换算率：成品按装箱数量，物料类按 数量/辅助数量 */
    private boolean applyAuxUnits(MdItem item, RowValues rv)
    {
        if (rv.packQty != null && rv.packQty.compareTo(BigDecimal.ZERO) > 0)
        {
            item.setUnit2(UNIT_BOX);
            item.setUnit2Name(UNIT_BOX_NAME);
            item.setConversionRate(rv.packQty);
            String per = StringUtils.isEmpty(rv.mainUnitName) ? "" : rv.mainUnitName;
            item.setPackageSpec(plain(rv.packQty) + per + "/" + UNIT_BOX_NAME);
            return true;
        }
        if (StringUtils.isNotEmpty(rv.auxUnitName) && rv.auxQty != null
                && rv.auxQty.compareTo(BigDecimal.ZERO) > 0 && rv.qty != null
                && rv.qty.compareTo(BigDecimal.ZERO) > 0)
        {
            item.setUnit2(auxUnitCode(rv.auxUnitName));
            item.setUnit2Name(rv.auxUnitName);
            item.setConversionRate(rv.qty.divide(rv.auxQty, 4, RoundingMode.HALF_UP));
            return true;
        }
        return false;
    }

    private Map<String, Object> buildItemAttrs(RowValues rv)
    {
        Map<String, Object> attrs = new HashMap<>();
        if (StringUtils.isNotEmpty(rv.width)) attrs.put("PAPER_WIDTH", rv.width);
        if (StringUtils.isNotEmpty(rv.matType)) attrs.put("PAPER_TYPE", rv.matType);
        return attrs.isEmpty() ? null : attrs;
    }

    /** 覆盖式写入库存：存在则置为 Excel 数量，不存在则新增；单位取物料档案 */
    private void upsertStock(StockImportResult result, ImportContext ctx, MdItem item, RowValues rv)
    {
        WmMaterialStock query = new WmMaterialStock();
        query.setItemId(item.getItemId());
        query.setWarehouseId(ctx.warehouseId);
        query.setBatchId(0L);
        query.setVendorId(ctx.vendor == null ? 0L : ctx.vendor.getVendorId());
        query.setWorkorderId(0L);
        query.setQualityStatus("NORMAL");
        List<WmMaterialStock> stocks = wmMaterialStockMapper.selectWmMaterialStockList(query);

        WmMaterialStock stock = (stocks == null || stocks.isEmpty()) ? new WmMaterialStock() : stocks.get(0);
        BigDecimal before = stock.getQuantityOnhand();

        applyItemSnapshot(stock, item);
        applyParty(stock, ctx);
        stock.setWarehouseId(ctx.warehouseId);
        stock.setQuantityOnhand(rv.qty);
        stock.setQuantityAvailable(rv.qty);
        stock.setQuantityOnhand2(rv.auxQty);
        stock.setQuantityAvailable2(rv.auxQty);
        stock.setStocktakeDate(DateUtils.getNowDate());
        stock.setQualityStatus("NORMAL");
        stock.setStatus("NORMAL");
        stock.setEnableFlag("1");
        stock.setRemark("Excel导入:" + result.getImportBatchNo());

        if (stock.getMaterialStockId() == null)
        {
            stock.setCreateBy(SecurityUtils.getUsername());
            stock.setCreateTime(DateUtils.getNowDate());
            wmMaterialStockMapper.insertWmMaterialStock(stock);
            stockService.writeTxn(stock, "IMPORT", BigDecimal.ZERO, rv.qty, "EXCEL",
                    result.getImportBatchNo(), "Excel导入新增");
        }
        else
        {
            stock.setUpdateBy(SecurityUtils.getUsername());
            stock.setUpdateTime(DateUtils.getNowDate());
            wmMaterialStockMapper.updateWmMaterialStock(stock);
            stockService.writeTxn(stock, "IMPORT", before, rv.qty, "EXCEL",
                    result.getImportBatchNo(), "Excel导入覆盖");
        }
    }

    private void applyItemSnapshot(WmMaterialStock stock, MdItem item)
    {
        stock.setItemId(item.getItemId());
        stock.setItemCode(item.getItemCode());
        stock.setItemName(item.getItemName());
        stock.setSpecification(item.getSpecification());
        stock.setUnitOfMeasure(item.getUnitOfMeasure());
        stock.setUnitName(item.getUnitName());
        stock.setUnit2(item.getUnit2());
        stock.setUnit2Name(item.getUnit2Name());
        stock.setConversionRate(item.getConversionRate());
    }

    private void applyParty(WmMaterialStock stock, ImportContext ctx)
    {
        if (ctx.vendor != null)
        {
            stock.setVendorId(ctx.vendor.getVendorId());
            stock.setVendorCode(ctx.vendor.getVendorCode());
            stock.setVendorName(ctx.vendor.getVendorName());
        }
        if (ctx.client != null)
        {
            stock.setClientId(ctx.client.getClientId());
            stock.setClientName(ctx.client.getClientName());
        }
    }

    private String unitNameOf(String headerText)
    {
        String h = headerText == null ? "" : headerText.toLowerCase();
        if (h.contains("kg") || h.contains("千克")) return UNIT_KG_NAME;
        if (h.contains("吨")) return "吨";
        if (h.contains("根")) return "根";
        if (h.contains("米")) return "米";
        if (h.contains("张")) return "张";
        return "个";
    }

    private String unitCode(String unitName)
    {
        if (UNIT_KG_NAME.equals(unitName) || "kg".equalsIgnoreCase(unitName)) return UNIT_KG;
        if ("吨".equals(unitName)) return "t";
        return unitName;
    }

    private String auxUnitNameOf(String headerText)
    {
        String h = headerText == null ? "" : headerText;
        if (h.contains(UNIT_ROLL_NAME)) return UNIT_ROLL_NAME;
        if (h.contains(UNIT_BOX_NAME)) return UNIT_BOX_NAME;
        if (h.contains("包")) return "包";
        if (h.contains("托")) return "托";
        return "";
    }

    private String auxUnitCode(String auxUnitName)
    {
        if (UNIT_ROLL_NAME.equals(auxUnitName)) return UNIT_ROLL;
        if (UNIT_BOX_NAME.equals(auxUnitName)) return UNIT_BOX;
        return auxUnitName;
    }

    private String generateItemCode(MdItemType type)
    {
        String prefix = type.getItemTypeCode() == null ? "IMP"
                : type.getItemTypeCode().toUpperCase().replaceAll("[^A-Z0-9-]", "");
        return prefix + "-" + DateUtils.dateTimeNow("yyyyMMddHHmmssSSS");
    }

    private String plain(BigDecimal v)
    {
        return v.stripTrailingZeros().toPlainString();
    }

    private int findHeaderRow(Sheet sheet)
    {
        int last = Math.min(sheet.getLastRowNum(), 20);
        for (int i = 0; i <= last; i++)
        {
            Row row = sheet.getRow(i);
            if (row == null) continue;
            if (findColumn(row, ITEM_COL_KEYS) >= 0) return i;
        }
        return -1;
    }

    private int findColumn(Row header, String[] keys)
    {
        if (header == null) return -1;
        org.apache.poi.ss.usermodel.DataFormatter fmt = new org.apache.poi.ss.usermodel.DataFormatter();
        short last = header.getLastCellNum();
        for (int c = 0; c < last; c++)
        {
            String text = fmt.formatCellValue(header.getCell(c))
                    .replace("\n", "").replace(" ", "").trim();
            if (text.isEmpty()) continue;
            for (String key : keys)
            {
                if (text.contains(key)) return c;
            }
        }
        return -1;
    }

    private String str(Cell cell)
    {
        if (cell == null) return "";
        org.apache.poi.ss.usermodel.DataFormatter fmt = new org.apache.poi.ss.usermodel.DataFormatter();
        String v = fmt.formatCellValue(cell);
        return v == null ? "" : v.trim();
    }

    private BigDecimal num(Cell cell)
    {
        if (cell == null) return null;
        try
        {
            if (cell.getCellType() == CellType.NUMERIC) return BigDecimal.valueOf(cell.getNumericCellValue());
            String s = str(cell).replace(",", "");
            if (s.isEmpty()) return null;
            return new BigDecimal(s);
        }
        catch (Exception e)
        {
            return null;
        }
    }

    /** 一次导入共享的上下文：分类 + 仓库 + 供应商/客户 */
    private static class ImportContext
    {
        private MdItemType type;
        private Long warehouseId;
        private MdVendor vendor;
        private MdClient client;
    }

    /** Excel 单行解析结果 */
    private static class RowValues
    {
        private String name;
        private String size;
        private String width;
        private String matType;
        private BigDecimal qty;
        private BigDecimal auxQty;
        private BigDecimal packQty;
        private String mainUnitName;
        private String auxUnitName;
    }
}
