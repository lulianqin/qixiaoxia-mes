import request from '@/utils/request'

// 可退料领料单预览：分页查 ISSUED 领料单，每行带可退量(returnableQty)
export function returnablePreview(query) {
  return request({ url: '/mes/wm/rtissue/returnablePreview', method: 'get', params: query })
}

// 从领料单生成退料单草稿（不落库，差额退料）
export function buildRtIssueFromIssue(issueId) {
  return request({ url: '/mes/wm/rtissue/buildFromIssue/' + issueId, method: 'get' })
}

// 新建退料单（头+行一次性提交，草稿）
export function addRtIssue(data) {
  return request({ url: '/mes/wm/rtissue', method: 'post', data })
}

// 退料单列表（可按 issueId/workorderId/status 过滤）
export function listRtIssue(query) {
  return request({ url: '/mes/wm/rtissue/list', method: 'get', params: query })
}

// 执行退库（草稿 → 已退库，加库存；需 RQC 检验通过）
export function executeRtIssue(rtId) {
  return request({ url: '/mes/wm/rtissue/execute/' + rtId, method: 'put' })
}
