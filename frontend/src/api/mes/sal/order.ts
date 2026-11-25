import request from '@/utils/request'
import type { SalOrderQueryParams, SalOrder, SalOrderCreateRequest, SalOrderToWorkorderRequest, AjaxResult, TableDataInfo } from '@/types'

export function listOrder(q: SalOrderQueryParams): Promise<TableDataInfo<SalOrder[]>> {
  return request({ url: '/mes/sal/order/list', method: 'get', params: q })
}
// 可转生产/采购关联的销售订单下拉选项（免授权，任意登录用户可访问）
export async function listAllOrder(): Promise<AjaxResult<SalOrder[]>> {
  const res: any = await request({
    url: '/mes/sal/order/options',
    method: 'get',
    params: { statusList: ['CONFIRMED', 'PRODUCING'] }
  })
  return { code: res.code, msg: res.msg, data: res.rows || [] } as AjaxResult<SalOrder[]>
}
// 销售订单下拉选项（任意登录用户可访问，供销售出库等页面选择）
export function listOrderOptions(q: SalOrderQueryParams): Promise<TableDataInfo<SalOrder[]>> {
  return request({ url: '/mes/sal/order/options', method: 'get', params: q })
}
export function getOrder(id: number): Promise<AjaxResult<SalOrder>> {
  return request({ url: '/mes/sal/order/' + id, method: 'get' })
}
export function getOrderDetail(id: number): Promise<AjaxResult<SalOrder>> {
  return request({ url: '/mes/sal/order/detail/' + id, method: 'get' })
}
// 销售订单看板：订单详情 + 其下生产工单（富化工序进度）
export function getOrderBoard(id: number): Promise<AjaxResult<any>> {
  return request({ url: '/mes/sal/order/board/' + id, method: 'get' })
}
export function createOrderWithLines(data: SalOrderCreateRequest): Promise<AjaxResult<SalOrder>> {
  return request({ url: '/mes/sal/order/createWithLines', method: 'post', data })
}
export function updateOrderWithLines(data: SalOrderCreateRequest): Promise<AjaxResult<SalOrder>> {
  return request({ url: '/mes/sal/order/updateWithLines', method: 'put', data })
}
export function closeOrder(id: number): Promise<AjaxResult> {
  return request({ url: '/mes/sal/order/close/' + id, method: 'put' })
}
export function cancelOrder(id: number): Promise<AjaxResult> {
  return request({ url: '/mes/sal/order/cancel/' + id, method: 'put' })
}
export function acceptOrder(id: number, data?: {
  requestDate?: string
  clientId?: number
  salesperson?: string
  signCompany?: string
  lines?: Array<{ lineId: number; requestDate?: string; productId?: number }>
}): Promise<AjaxResult<number>> {
  return request({ url: '/mes/sal/order/accept/' + id, method: 'put', data: data || {} })
}
/** 接单默认关联：按已记录的两系统映射回填 MES 客户/产品建议 */
export function getAcceptDefaults(id: number): Promise<AjaxResult<any>> {
  return request({ url: '/mes/sal/order/acceptDefaults/' + id, method: 'get' })
}
export function rejectOrder(id: number, reason: string): Promise<AjaxResult<number>> {
  return request({ url: '/mes/sal/order/reject/' + id, method: 'put', data: { reason } })
}
export function toWorkorder(data: SalOrderToWorkorderRequest): Promise<AjaxResult<SalOrder>> {
  return request({ url: '/mes/sal/order/toWorkorder', method: 'post', data })
}
export function delOrder(id: number | number[]): Promise<AjaxResult> {
  return request({ url: '/mes/sal/order/' + id, method: 'delete' })
}
/** 销售订单 PDF（返回 blob，用于浏览器打印，不下载） */
export function fetchOrderPdf(id: number): Promise<Blob> {
  return request({ url: '/mes/sal/order/exportPdf/' + id, method: 'post', responseType: 'blob' }) as unknown as Promise<Blob>
}
export function changeOrderStatus(data: { orderId: number; targetStatus: string; reason?: string }): Promise<AjaxResult<SalOrder>> {
  return request({ url: '/mes/sal/order/changeStatus', method: 'put', data })
}
