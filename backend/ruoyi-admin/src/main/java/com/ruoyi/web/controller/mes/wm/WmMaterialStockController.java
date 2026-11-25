package com.ruoyi.web.controller.mes.wm;

import java.util.List;
import jakarta.servlet.http.HttpServletResponse;
import com.ruoyi.system.service.mes.wm.IWmMaterialStockService;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.system.domain.mes.md.MdItem;
import com.ruoyi.system.domain.mes.wm.WmMaterialStock;
import com.ruoyi.system.service.mes.md.IMdItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.ruoyi.system.service.mes.wm.IWmStockImportService;

/**
 * 库存记录表Controller（factory_id 由 FactoryIdInterceptor 自动注入）
 * 
 * @author qixiaoxia
 * @date 2026-06-12
 */
@RestController
@RequestMapping("/mes/wm/material_stock")
public class WmMaterialStockController extends BaseController
{
    @Autowired
    private IWmMaterialStockService wmMaterialStockService;

    @Autowired
    private IWmStockImportService wmStockImportService;

    @Autowired
    private IMdItemService mdItemService;

    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:list')")
    @GetMapping("/list")
    public TableDataInfo list(WmMaterialStock entity)
    {
        startPage();
        List<WmMaterialStock> list = wmMaterialStockService.selectWmMaterialStockList(entity);
        return getDataTable(list);
    }

    /**
     * 查可用批次列表（发料弹窗批次下拉用）：按 itemId 查所有 onhand>0 的批次记录。
     * 返回字段含 batchId/batchCode/quantityAvailable/quantityOnhand/warehouseId 等。
     */
    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:list')")
    @GetMapping("/availableBatches")
    public AjaxResult availableBatches(@RequestParam("itemId") Long itemId,
                                       @RequestParam(value = "warehouseId", required = false) Long warehouseId)
    {
        return AjaxResult.success(wmMaterialStockService.selectAvailableBatches(itemId, warehouseId));
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:query')")
    @GetMapping("/listAll")
    public AjaxResult listAll()
    {
        List<WmMaterialStock> list = wmMaterialStockService.selectWmMaterialStockAll();
        return AjaxResult.success(list);
    }

    /**
     * 批次码精确反查库存（扫码用）：batch_code 精确匹配，返回该批次全部库存行（可跨仓/库位）。
     */
    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:query')")
    @GetMapping("/scan/{batchCode}")
    public AjaxResult scan(@PathVariable("batchCode") String batchCode)
    {
        return AjaxResult.success(wmMaterialStockService.scanByBatchCode(batchCode));
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:export')")
    @Log(title = "库存记录表", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, WmMaterialStock entity)
    {
        List<WmMaterialStock> list = wmMaterialStockService.selectWmMaterialStockList(entity);
        ExcelUtil<WmMaterialStock> util = new ExcelUtil<WmMaterialStock>(WmMaterialStock.class);
        util.exportExcel(response, list, "库存记录表数据");
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:query')")
    @GetMapping(value = "/{materialStockId}")
    public AjaxResult getInfo(@PathVariable("materialStockId") Long materialStockId)
    {
        return AjaxResult.success(wmMaterialStockService.selectWmMaterialStockByMaterialStockId(materialStockId));
    }

    /**
     * 新增库存前解析物料：按名称+分类+规格型号+装箱规格+产品尺寸+扩展属性匹配，
     * 命中直接复用，未命中自动建档（先建物料，再保存库存）。
     */
    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:add')")
    @PostMapping("/resolveItem")
    public AjaxResult resolveItem(@RequestBody MdItem spec)
    {
        return AjaxResult.success(mdItemService.findOrCreateForStock(spec));
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:add')")
    @Log(title = "库存记录表", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody WmMaterialStock entity)
    {
        return toAjax(wmMaterialStockService.insertWmMaterialStock(entity));
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:edit')")
    @Log(title = "库存记录表", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody WmMaterialStock entity)
    {
        return toAjax(wmMaterialStockService.updateWmMaterialStock(entity));
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:import')")
    @Log(title = "库存Excel导入", businessType = BusinessType.IMPORT)
    @PostMapping("/import")
    public AjaxResult importData(@RequestParam("file") MultipartFile file,
                                 @RequestParam("itemTypeId") Long itemTypeId,
                                 @RequestParam("warehouseId") Long warehouseId,
                                 @RequestParam(value = "vendorId", required = false) Long vendorId,
                                 @RequestParam(value = "clientId", required = false) Long clientId) throws Exception
    {
        if (file == null || file.isEmpty()) return error("请上传 Excel 文件");
        return AjaxResult.success(wmStockImportService.importExcel(
                file.getInputStream(), file.getOriginalFilename(), itemTypeId, warehouseId, vendorId, clientId));
    }

    /** 导入模板下载：type=RAW 物料类模板，其它为成品模板 */
    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:import')")
    @GetMapping("/importTemplate")
    public void importTemplate(HttpServletResponse response,
                               @RequestParam(value = "type", required = false) String type) throws Exception
    {
        boolean raw = "RAW".equalsIgnoreCase(type);
        String[] headers = raw
                ? new String[]{"物料名称", "规格门幅", "材质", "数量单位", "剩余数量", "辅助单位", "剩余辅助数量"}
                : new String[]{"产品名称", "规格尺寸", "装箱数量", "数量单位", "剩余数量", "剩余箱数"};
        try (org.apache.poi.xssf.usermodel.XSSFWorkbook wb = new org.apache.poi.xssf.usermodel.XSSFWorkbook())
        {
            var sheet = wb.createSheet("库存导入");
            var row = sheet.createRow(0);
            var style = wb.createCellStyle();
            var font = wb.createFont();
            font.setBold(true);
            style.setFont(font);
            for (int i = 0; i < headers.length; i++)
            {
                var cell = row.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(style);
                sheet.setColumnWidth(i, 20 * 256);
            }
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("utf-8");
            String fileName = java.net.URLEncoder.encode(raw ? "物料库存导入模板" : "成品库存导入模板", "UTF-8");
            response.setHeader("Content-Disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");
            wb.write(response.getOutputStream());
        }
    }

    @PreAuthorize("@ss.hasPermi('mes:wm:material_stock:remove')")
    @Log(title = "库存记录表", businessType = BusinessType.DELETE)
    @DeleteMapping("/{materialStockIds}")
    public AjaxResult remove(@PathVariable Long[] materialStockIds)
    {
        return toAjax(wmMaterialStockService.deleteWmMaterialStockByMaterialStockIds(materialStockIds));
    }
}