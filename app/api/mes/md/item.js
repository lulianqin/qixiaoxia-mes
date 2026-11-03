import request from '@/utils/request'

// 分页查询物料主数据（外协发料手动添加物料行等场景）
export function listItem(query) {
  return request({ url: '/mes/md/item/list', method: 'get', params: query })
}
