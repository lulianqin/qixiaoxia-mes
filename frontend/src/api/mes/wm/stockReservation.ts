import request from '@/utils/request'
import type { AxiosPromise } from 'axios'

export interface StockReservation {
  reservationId?: number
  materialStockId?: number
  itemId?: number
  itemCode?: string
  itemName?: string
  specification?: string
  unitName?: string
  warehouseId?: number
  warehouseName?: string
  batchId?: number
  batchCode?: string
  workorderId?: number
  workorderCode?: string
  workorderName?: string
  salesOrderId?: number
  salesOrderLineId?: number
  issueId?: number
  issueCode?: string
  sourceType?: string
  demandQty?: number
  reservedQty?: number
  consumedQty?: number
  releasedQty?: number
  demandDate?: string
  status?: string
}

/** 查询库存预占明细（锁定下钻） */
export function listStockReservation(query?: Record<string, any>): AxiosPromise<any> {
  return request({
    url: '/mes/wm/stock-reservation/list',
    method: 'get',
    params: query
  })
}
