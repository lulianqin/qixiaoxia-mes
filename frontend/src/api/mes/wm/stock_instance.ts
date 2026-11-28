import request from '@/utils/request'
import type { WmStockInstanceQueryParams, WmStockInstance, AjaxResult, TableDataInfo } from '@/types'

/** 分页查询实物实例 */
export function listWmStockInstance(q: WmStockInstanceQueryParams): Promise<TableDataInfo<WmStockInstance[]>> {
  return request({ url: '/mes/wm/stock_instance/list', method: 'get', params: q })
}

export function getWmStockInstance(instanceId: number): Promise<AjaxResult<WmStockInstance>> {
  return request({ url: '/mes/wm/stock_instance/' + instanceId, method: 'get' })
}

/** 扫实例码反查（一卷/一根的唯一编号） */
export function scanWmStockInstance(instanceCode: string): Promise<AjaxResult<WmStockInstance>> {
  return request({ url: '/mes/wm/stock_instance/scan/' + encodeURIComponent(instanceCode), method: 'get' })
}

/** 库存现有量下钻：某库存桶下的在库实例 */
export function listInstancesByStock(materialStockId: number): Promise<AjaxResult<WmStockInstance[]>> {
  return request({ url: '/mes/wm/stock_instance/byStock/' + materialStockId, method: 'get' })
}

/** 某库存桶的在库实例数（辅助数量口径） */
export function countInstancesByStock(materialStockId: number): Promise<AjaxResult<number>> {
  return request({ url: '/mes/wm/stock_instance/countByStock/' + materialStockId, method: 'get' })
}

/** 某物料的可用实例（发料/退料选择用，只返回有剩余且未报废的） */
export function availableInstances(itemId: number, params?: { batchId?: number; warehouseId?: number; materialStockId?: number }): Promise<AjaxResult<WmStockInstance[]>> {
  return request({ url: '/mes/wm/stock_instance/available', method: 'get', params: { itemId, ...params } })
}

export function addWmStockInstance(d: WmStockInstance): Promise<AjaxResult> {
  return request({ url: '/mes/wm/stock_instance', method: 'post', data: d })
}

export function updateWmStockInstance(d: WmStockInstance): Promise<AjaxResult> {
  return request({ url: '/mes/wm/stock_instance', method: 'put', data: d })
}

export function delWmStockInstance(instanceId: number | number[]): Promise<AjaxResult> {
  return request({ url: '/mes/wm/stock_instance/' + instanceId, method: 'delete' })
}
