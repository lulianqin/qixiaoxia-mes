import request from '@/utils/request'

// 库存现有量列表（按物料+批次+仓库等 6 元组汇总的库存桶）
export function listMaterialStock(params) {
  return request({ url: '/mes/wm/material_stock/list', method: 'get', params })
}
