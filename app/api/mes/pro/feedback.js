import request from '@/utils/request'

// 新增报工（POST /mes/pro/feedback）
export function addFeedback(data) {
  return request({ url: '/mes/pro/feedback', method: 'post', data: data })
}

// 报工列表（分页，支持按状态/工单过滤）
export function listFeedback(query) {
  return request({ url: '/mes/pro/feedback/list', method: 'get', params: query })
}

// 报工详情
export function getFeedback(recordId) {
  return request({ url: '/mes/pro/feedback/' + recordId, method: 'get' })
}

// 按工单编码搜索工单
export function getWorkorderByCode(workorderCode) {
  return request({ url: '/mes/pro/workorder/list', method: 'get', params: { workorderCode } })
}

// 工单详情
export function getWorkorderDetail(workorderId) {
  return request({ url: '/mes/pro/workorder/' + workorderId, method: 'get' })
}

// 按工单ID查询任务列表（每个任务对应一个工序）
export function listTaskByWorkorder(workorderId) {
  return request({ url: '/mes/pro/task/list', method: 'get', params: { workorderId } })
}

// 可报工任务分页列表（后端已过滤：厂内 PRODUCING + 工单 PREPARE/PRODUCING，排除外协 VENDOR）
export function listReportableTask(query) {
  return request({ url: '/mes/pro/task/reportableList', method: 'get', params: query })
}

// 移动端报工入口：一次请求返回工单 + 可报工任务列表（PRODUCING 状态）
export function getFeedbackEntry(workorderCode) {
  return request({ url: '/mes/pro/workorder/feedbackEntry/' + encodeURIComponent(workorderCode), method: 'get' })
}

// 移动端首页工单列表（分页，按工单状态过滤：PREPARE/PRODUCING/COMPLETED，不传为全部）
export function getMobileWorkorders(query) {
  return request({ url: '/mes/pro/workorder/mobileList', method: 'get', params: query })
}

// 移动端首页顶部汇总：工单数量 + 待办任务数量
export function getMobileHomeSummary(query) {
  return request({ url: '/mes/pro/workorder/mobileSummary', method: 'get', params: query })
}

// 工单全部工序任务（工单详情/工序详情页用）
export function getWorkorderTasks(workorderCode) {
  return request({ url: '/mes/pro/workorder/workorderTasks/' + encodeURIComponent(workorderCode), method: 'get' })
}

// 工单看板：工单头 + 工序任务 + 关联单据（报工/检验/外协/领料/收料/入库）汇总与明细
export function getWorkorderBoard(workorderId) {
  return request({ url: '/mes/pro/workorder/board/' + workorderId, method: 'get' })
}

// 工序看板：工序任务 + 关联单据（报工/检验/外协/领料）汇总与明细
export function getProcessBoard(taskId) {
  return request({ url: '/mes/pro/workorder/board/process/' + taskId, method: 'get' })
}
