import request from '@/utils/request'

// 某物料可用实物实例（有剩余、未报废）：一卷 / 一根 / 一桶
export function availableInstances(itemId, params) {
  return request({ url: '/mes/wm/stock_instance/available', method: 'get', params: { itemId, ...(params || {}) } })
}

// 扫实例码反查（实例编号全局唯一）
export function scanInstance(instanceCode) {
  return request({ url: '/mes/wm/stock_instance/scan/' + encodeURIComponent(instanceCode), method: 'get' })
}

// 库存桶下的在库实例
export function listInstancesByStock(materialStockId) {
  return request({ url: '/mes/wm/stock_instance/byStock/' + materialStockId, method: 'get' })
}
