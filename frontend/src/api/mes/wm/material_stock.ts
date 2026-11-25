import request from '@/utils/request'
import type { WmMaterialStockQueryParams, WmMaterialStock, AjaxResult, TableDataInfo } from '@/types'

export function listWmMaterialStock(q: WmMaterialStockQueryParams): Promise<TableDataInfo<WmMaterialStock[]>> {
  return request({ url: '/mes/wm/material_stock/list', method: 'get', params: q })
}

export function listAllWmMaterialStock(): Promise<AjaxResult<WmMaterialStock[]>> {
  return request({ url: '/mes/wm/material_stock/listAll', method: 'get' })
}

export function getWmMaterialStock(materialStockId: number): Promise<AjaxResult<WmMaterialStock>> {
  return request({ url: '/mes/wm/material_stock/' + materialStockId, method: 'get' })
}

/**
 * 新增库存前解析物料：按名称+分类+规格型号+装箱规格+产品尺寸+扩展属性匹配，
 * 命中复用，未命中自动建档（先建物料，再保存库存）。
 */
export function resolveStockItem(spec: any): Promise<AjaxResult<any>> {
  return request({ url: '/mes/wm/material_stock/resolveItem', method: 'post', data: spec })
}

export function addWmMaterialStock(d: WmMaterialStock): Promise<AjaxResult> {
  return request({ url: '/mes/wm/material_stock', method: 'post', data: d })
}

export function updateWmMaterialStock(d: WmMaterialStock): Promise<AjaxResult> {
  return request({ url: '/mes/wm/material_stock', method: 'put', data: d })
}

export function delWmMaterialStock(materialStockId: number | number[]): Promise<AjaxResult> {
  return request({ url: '/mes/wm/material_stock/' + materialStockId, method: 'delete' })
}

/**
 * 查可用批次列表（发料弹窗批次下拉用）：按 itemId 查所有 onhand>0 的批次记录。
 * 不传 warehouseId 时跨仓返回，前端可用 warehouseName 区分。
 * 返回字段含 materialStockId/batchId/batchCode/warehouseId/warehouseName/quantityAvailable/quantityOnhand 等。
 */
export function availableBatches(itemId: number, warehouseId?: number | null): Promise<AjaxResult<any[]>> {
  const params: Record<string, any> = { itemId }
  if (warehouseId != null) params.warehouseId = warehouseId
  return request({ url: '/mes/wm/material_stock/availableBatches', method: 'get', params })
}

/**
 * 批次码反查库存（扫码枪/手输批次码识别用）：按 batchCode 查该批次的库存行。
 * 返回行含 itemCode/itemId/batchId/batchCode/materialStockId/warehouseId/quantityOnhand。
 */
export function getStockByBatchCode(batchCode: string): Promise<AjaxResult<WmMaterialStock[]>> {
  return request({ url: '/mes/wm/material_stock/scan/' + encodeURIComponent(batchCode), method: 'get' })
}

/** 库存 Excel 导入（COVER 覆盖，按物料分类+仓库，匹配不到自动建物料） */
export function importMaterialStock(file: File, itemTypeId: number, warehouseId: number,
                                    vendorId?: number | null, clientId?: number | null) {
  const fd = new FormData()
  fd.append('file', file)
  fd.append('itemTypeId', String(itemTypeId))
  fd.append('warehouseId', String(warehouseId))
  if (vendorId != null) fd.append('vendorId', String(vendorId))
  if (clientId != null) fd.append('clientId', String(clientId))
  return request({
    url: '/mes/wm/material_stock/import',
    method: 'post',
    data: fd,
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

/** 下载导入模板：type=RAW 物料类模板，其它为成品模板 */
export function downloadStockTemplate(type: string, fileName?: string) {
  return request({
    url: '/mes/wm/material_stock/importTemplate',
    method: 'get',
    params: { type },
    responseType: 'blob'
  }).then((blob: any) => {
    const url = window.URL.createObjectURL(new Blob([blob]))
    const a = document.createElement('a')
    a.href = url
    a.download = fileName || (type === 'RAW' ? '物料库存导入模板.xlsx' : '成品库存导入模板.xlsx')
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
  })
}