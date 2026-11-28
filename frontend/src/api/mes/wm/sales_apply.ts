import request from '@/utils/request'
import type { WmSalesApplyQueryParams, WmSalesApply, AjaxResult, TableDataInfo } from '@/types'

/** 出库申请列表（ERP 下发的工厂出库申请） */
export function listWmSalesApply(q: WmSalesApplyQueryParams): Promise<TableDataInfo<WmSalesApply[]>> {
  return request({ url: '/mes/wm/sales_apply/list', method: 'get', params: q })
}

/** 出库申请详情（含明细行） */
export function getWmSalesApply(applyId: number): Promise<AjaxResult<WmSalesApply>> {
  return request({ url: '/mes/wm/sales_apply/detail/' + applyId, method: 'get' })
}
