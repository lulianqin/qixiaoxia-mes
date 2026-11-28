import request from '@/utils/request'

// 物料批次配置（含 instanceFlag：是否逐实物管理）
export function getBatchConfigByItemId(itemId) {
  return request({ url: '/mes/md/batchconfig/byItem/' + itemId, method: 'get' })
}
