package com.ruoyi.system.service.mes.wm;

import java.io.InputStream;
import com.ruoyi.system.domain.mes.wm.dto.StockImportResult;

/**
 * 库存 Excel 导入
 *
 * @author qixiaoxia
 */
public interface IWmStockImportService
{
    /**
     * 导入库存（COVER 覆盖：以 Excel 的剩余数量/剩余kg 直接置为系统库存）
     *
     * @param in           Excel 输入流
     * @param fileName     文件名（仅用于日志）
     * @param itemTypeId   物料分类ID（导入口径，替代原库存类型）
     * @param warehouseId  仓库ID
     * @param vendorId     供应商ID（可空，外采/来料）
     * @param clientId     客户ID（可空，订单成品）
     */
    StockImportResult importExcel(InputStream in, String fileName, Long itemTypeId, Long warehouseId,
                                  Long vendorId, Long clientId);
}
