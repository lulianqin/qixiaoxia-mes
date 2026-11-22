import request from '@/utils/request'
import type { ItemQueryParams, MdItem, AjaxResult, TableDataInfo } from '@/types'

// 查询物料列表
export function listItem(query: ItemQueryParams): Promise<TableDataInfo<MdItem[]>> {
  return request({ url: '/mes/md/item/list', method: 'get', params: query })
}

// 查询物料详细（含行业子表）
export function getItem(itemId: number): Promise<AjaxResult<MdItem>> {
  return request({ url: '/mes/md/item/' + itemId, method: 'get' })
}

// 新增物料
export function addItem(data: MdItem): Promise<AjaxResult> {
  return request({ url: '/mes/md/item', method: 'post', data })
}

// 修改物料
export function updateItem(data: MdItem): Promise<AjaxResult> {
  return request({ url: '/mes/md/item', method: 'put', data })
}

// 删除物料
export function delItem(itemId: number | number[]): Promise<AjaxResult> {
  return request({ url: '/mes/md/item/' + itemId, method: 'delete' })
}

// 接单按规格建档：同规格命中复用，未命中以 SPU 新建 SKU 变体
export function specVariantItem(data: Partial<MdItem>): Promise<AjaxResult<MdItem>> {
  return request({ url: '/mes/md/item/specVariant', method: 'post', data })
}
