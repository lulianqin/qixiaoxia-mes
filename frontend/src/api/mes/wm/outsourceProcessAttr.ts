import request from '@/utils/request'
import type { AjaxResult } from '@/types'

export interface OutsourceProcessAttr {
  id?: number
  processId?: number
  attrId?: number
  required?: string
  sortOrder?: number
  enableFlag?: string
  attrCode?: string
  attrName?: string
  attrType?: string
  attrUnit?: string
  optionsJson?: string
}

/** 查工序绑定的外协字段模板 */
export function getOutsourceProcessAttr(processId: number): Promise<AjaxResult<OutsourceProcessAttr[]>> {
  return request({ url: '/mes/wm/outsource/processAttr/' + processId, method: 'get' })
}

/** 全量保存工序字段模板 */
export function saveOutsourceProcessAttr(processId: number, data: OutsourceProcessAttr[]): Promise<AjaxResult> {
  return request({ url: '/mes/wm/outsource/processAttr/' + processId, method: 'put', data })
}
