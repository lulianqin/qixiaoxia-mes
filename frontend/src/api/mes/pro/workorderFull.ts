import request from '@/utils/request'

// 开单页内置：生成工单编码（WORKORDER_NO）
export function genWorkorderCode(): Promise<any> {
  return request({ url: '/mes/pro/workorder/nextCode', method: 'post' })
}

// 开单页内置：按产品查询产品级 BOM（预填工单物料明细）
export function listWorkorderBom(query: any): Promise<any> {
  return request({ url: '/mes/pro/workorder/bomList', method: 'get', params: query })
}

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

// 复制工单模板：清空单号/状态/执行数据，微调后走 createFull 保存为新工单
export function getWorkorderCopyTemplate(workorderId: number) {
  return request({ url: '/mes/pro/workorder/copyTemplate/' + workorderId, method: 'get' })
}

// ─────────── 单据导出 / 打印 ───────────

function fetchBlob(url: string, data: any) {
  return request({ url, method: 'post', data, responseType: 'blob' })
}

function saveBlob(blob: any, filename: string) {
  const href = URL.createObjectURL(new Blob([blob]))
  const a = document.createElement('a')
  a.href = href
  a.download = filename
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(href)
}

/** 单张采购单 Excel 导出 */
export function exportPurDocExcel(orderId: number, filename = '') {
  return fetchBlob(`/mes/pur/order/doc/${orderId}/excel`, {})
    .then(b => saveBlob(b, filename || `采购单_${orderId}.xlsx`))
}

/** 单张采购单 PDF（返回 blob，用于打印预览） */
export function fetchPurDocPdf(orderId: number) {
  return fetchBlob(`/mes/pur/order/doc/${orderId}/pdf`, {}) as Promise<Blob>
}

/** 采购单合并导出 Excel（同供应商多单） */
export function exportPurDocsMergeExcel(orderIds: number[], filename = '') {
  return fetchBlob(`/mes/pur/order/docMerge/excel`, orderIds)
    .then(b => saveBlob(b, filename || '合并采购单.xlsx'))
}

/** 采购单合并 PDF（返回 blob，用于打印预览） */
export function fetchPurDocsMergePdf(orderIds: number[]) {
  return fetchBlob(`/mes/pur/order/docMerge/pdf`, orderIds) as Promise<Blob>
}

/** 单张加工单 Excel 导出 */
export function exportProcessDocExcel(orderId: number, filename = '') {
  return fetchBlob(`/mes/wm/outsource/doc/${orderId}/excel`, {})
    .then(b => saveBlob(b, filename || `加工单_${orderId}.xlsx`))
}

/** 单张加工单 PDF（返回 blob，用于打印预览） */
export function fetchProcessDocPdf(orderId: number) {
  return fetchBlob(`/mes/wm/outsource/doc/${orderId}/pdf`, {}) as Promise<Blob>
}

/** 加工单合并导出 Excel（同供应商多单） */
export function exportProcessDocsMergeExcel(orderIds: number[], filename = '') {
  return fetchBlob(`/mes/wm/outsource/docMerge/excel`, orderIds)
    .then(b => saveBlob(b, filename || '合并加工单.xlsx'))
}

/** 加工单合并 PDF（返回 blob，用于打印预览） */
export function fetchProcessDocsMergePdf(orderIds: number[]) {
  return fetchBlob(`/mes/wm/outsource/docMerge/pdf`, orderIds) as Promise<Blob>
}
