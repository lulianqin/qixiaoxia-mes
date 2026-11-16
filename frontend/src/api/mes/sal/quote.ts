import request from '@/utils/request'
import type { AjaxResult, TableDataInfo, SalQuote, SalQuoteQueryParams, SalQuoteSubmitRequest } from '@/types'

export function listQuote(q: SalQuoteQueryParams): Promise<TableDataInfo<SalQuote[]>> {
  return request({ url: '/mes/sal/quote/list', method: 'get', params: q })
}
export function getQuote(id: number): Promise<AjaxResult<SalQuote>> {
  return request({ url: '/mes/sal/quote/' + id, method: 'get' })
}
export function saveQuote(data: SalQuoteSubmitRequest): Promise<AjaxResult<SalQuote>> {
  return request({ url: '/mes/sal/quote/save', method: 'put', data })
}
export function submitQuote(data: SalQuoteSubmitRequest): Promise<AjaxResult<number>> {
  return request({ url: '/mes/sal/quote/submit', method: 'post', data })
}
