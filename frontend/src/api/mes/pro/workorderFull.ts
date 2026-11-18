import request from '@/utils/request'

// 新增生产工单（独立开单页）：主工单 + BOM + 参数 + 工序 + 采购单/加工单草稿
export function createWorkorderFull(data: any) {
  return request({ url: '/mes/pro/workorder/createFull', method: 'post', data })
}

// 修改生产工单（独立开单页）
export function updateWorkorderFull(workorderId: number, data: any) {
  return request({ url: '/mes/pro/workorder/updateFull/' + workorderId, method: 'put', data })
}

// 开单页回显
export function getWorkorderFullDetail(workorderId: number) {
  return request({ url: '/mes/pro/workorder/fullDetail/' + workorderId, method: 'get' })
}

// ─────────── 单据导出 / 打印 ───────────

function download(url: string, data: any, filename: string) {
  return request({ url, method: 'post', data, responseType: 'blob' }).then((blob: any) => {
    const href = URL.createObjectURL(new Blob([blob]))
    const a = document.createElement('a')
    a.href = href
    a.download = filename
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(href)
  })
}

/** 单张采购单导出 Excel / PDF 打印 */
export function exportPurDoc(orderId: number, format: 'excel' | 'pdf', orderCode = '') {
  return download(`/mes/pur/order/doc/${orderId}/${format}`, {}, `采购单_${orderCode || orderId}.${format === 'excel' ? 'xlsx' : 'pdf'}`)
}

/** 采购单合并导出（同供应商多单） */
export function exportPurDocsMerge(orderIds: number[], format: 'excel' | 'pdf') {
  return download(`/mes/pur/order/docMerge/${format}`, orderIds, `合并采购单.${format === 'excel' ? 'xlsx' : 'pdf'}`)
}

/** 单张加工单导出 Excel / PDF 打印 */
export function exportProcessDoc(orderId: number, format: 'excel' | 'pdf', orderCode = '') {
  return download(`/mes/wm/outsource/doc/${orderId}/${format}`, {}, `加工单_${orderCode || orderId}.${format === 'excel' ? 'xlsx' : 'pdf'}`)
}

/** 加工单合并导出（同供应商多单） */
export function exportProcessDocsMerge(orderIds: number[], format: 'excel' | 'pdf') {
  return download(`/mes/wm/outsource/docMerge/${format}`, orderIds, `合并加工单.${format === 'excel' ? 'xlsx' : 'pdf'}`)
}
