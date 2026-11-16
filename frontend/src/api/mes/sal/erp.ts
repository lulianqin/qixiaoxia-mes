import request from '@/utils/request'
import type { AjaxResult, TableDataInfo } from '@/types'

export interface ErpEndpoint {
  endpointId?: number
  systemCode?: string
  systemName?: string
  baseUrl?: string
  apiKey?: string
  enabled?: string
  remark?: string
}

export interface ErpSyncTask {
  taskId?: number
  bizType?: string
  bizId?: number
  bizNo?: string
  targetSystem?: string
  callbackPath?: string
  status?: string
  retryCount?: number
  nextRetryTime?: string
  lastError?: string
  createTime?: string
  updateTime?: string
}

export function getErpEndpoint(): Promise<AjaxResult<ErpEndpoint>> {
  return request({ url: '/mes/sal/erp/endpoint', method: 'get' })
}
export function saveErpEndpoint(data: ErpEndpoint): Promise<AjaxResult<ErpEndpoint>> {
  return request({ url: '/mes/sal/erp/endpoint', method: 'put', data })
}
export function listSyncTask(params: any): Promise<TableDataInfo<ErpSyncTask[]>> {
  return request({ url: '/mes/sal/erp/syncTask/list', method: 'get', params })
}
export function retrySyncTask(taskId: number): Promise<AjaxResult> {
  return request({ url: '/mes/sal/erp/syncTask/retry/' + taskId, method: 'post' })
}
