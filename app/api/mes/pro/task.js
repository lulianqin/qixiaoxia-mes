import request from '@/utils/request'

// 移动端开工（仅工单负责人/当前工序负责人）
export function startTask(taskId) {
  return request({
    url: '/mes/pro/task/mobileStart/' + taskId,
    method: 'put'
  })
}

// 质检不合格放行（需 mes:pro:task:release 权限，理由必填）
export function releaseQcBlock(taskId, reason) {
  return request({
    url: '/mes/pro/task/releaseQcBlock/' + taskId,
    method: 'put',
    params: { reason }
  })
}
