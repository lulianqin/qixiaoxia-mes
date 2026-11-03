/**
 * 移动端工作台菜单。
 *
 * 菜单与角色授权仍以 PC 的 sys_menu / 角色-菜单为准：这里只维护
 * 「PC 权限标识 → 手机页面」的映射，登录后用 getInfo 返回的 permissions 过滤，
 * 管理员在 PC「角色管理」里勾选菜单即可控制手机入口，无需额外维护一套菜单表。
 *
 * perm 为空表示不校验权限；数组表示满足任意一个即可。
 */

const DEFAULT_ICON = 'list'

export const MOBILE_MENU_GROUPS = [
  {
    title: '仓储管理',
    items: [
      { key: 'issue-list', text: '领料单', icon: 'paperplane-filled', color: '#409eff', perm: 'mes:wm:issue:list', path: '/pages/mes/wm/issue/list' },
      { key: 'issue-scan', text: '扫码发料', icon: 'scan', color: '#67c23a', perm: 'mes:wm:issue:list', path: '/pages/mes/wm/issue/list', query: 'from=scan' },
      { key: 'stock-query', text: '扫码查库存', icon: 'search', color: '#e6a23c', perm: 'mes:wm:material_stock:query', path: '/pages/mes/wm/issue/scan-query' },
      { key: 'product-recpt', text: '产品入库', icon: 'checkbox-filled', color: '#67c23a', perm: 'mes:wm:product_recpt:list', path: '/pages/mes/wm/productrecpt/list' },
      { key: 'product-recpt-history', text: '入库记录', icon: 'list', color: '#409eff', perm: 'mes:wm:product_recpt:list', path: '/pages/mes/wm/productrecpt/list' },
      { key: 'sales-list', text: '销售出库', icon: 'shop-filled', color: '#e6a23c', perm: 'mes:wm:sales:list', path: '/pages/mes/wm/sales/list' }
    ]
  },
  {
    title: '采购管理',
    items: [
      { key: 'pur-receipt', text: '采购收货', icon: 'checkbox-filled', color: '#409eff', perm: 'mes:pur:order:list', path: '/pages/mes/pur/list' },
      { key: 'pur-history', text: '收货历史', icon: 'list', color: '#67c23a', perm: 'mes:wm:item_recpt:list', path: '/pages/mes/pur/history' }
    ]
  },
  {
    title: '生产管理',
    hideForVendor: true,
    items: [
      { key: 'pro-report', text: '生产报工', icon: 'compose', color: '#409eff', perm: 'mes:pro:task:list', path: '/pages/mes/pro/report-list' },
      { key: 'qc', text: '质检', icon: 'checkmarkempty', color: '#409eff', perm: ['mes:qc:ipqc:list', 'mes:qc:iqc:list', 'mes:qc:oqc:list', 'mes:qc:rqc:list'], path: '/pages/mes/qc/list' },
      { key: 'scan', text: '扫一扫', icon: 'scan', color: '#409eff', action: 'scan' },
      { key: 'feedback-history', text: '报工历史', icon: 'list', color: '#67c23a', perm: 'mes:pro:feedback:list', path: '/pages/mes/pro/history' },
      { key: 'clock', text: '工位打卡', icon: 'staff-filled', color: '#e6a23c', perm: 'mes:pro:workrecord:clock', path: '/pages/mes/pro/clock' },
      { key: 'clock-history', text: '打卡历史', icon: 'list', color: '#f56c6c', perm: 'mes:pro:workrecord:list', path: '/pages/mes/pro/clock-history' },
      { key: 'outsource-issue', text: '外协发料', icon: 'scissors', color: '#909399', perm: 'mes:wm:outsource:add', path: '/pages/mes/wm/outsource-issue-list' },
      { key: 'outsource-recpt', text: '外协收料', icon: 'download', color: '#67c23a', perm: 'mes:wm:outsource:receive', path: '/pages/mes/wm/outsource-recpt-list' },
      { key: 'outsource-list', text: '外协单', icon: 'paperplane', color: '#e6a23c', perm: 'mes:wm:outsource:list', path: '/pages/mes/wm/outsource-list' }
    ]
  },
  {
    title: '外协任务',
    vendorOnly: true,
    items: [
      { key: 'my-outsource', text: '我的外协任务', icon: 'scissors-filled', color: '#409eff', perm: 'mes:wm:outsource:list', path: '/pages/mes/wm/outsource-list' },
      { key: 'outsource-history', text: '外协历史', icon: 'list', color: '#67c23a', perm: 'mes:wm:outsource:list', path: '/pages/mes/wm/outsource-list' }
    ]
  }
  // 「系统管理」下均为 PC 功能，移动端尚未开发对应页面，暂不展示；
  // 后续开发后在此追加 items 即可，无需改动工作台页面。
]

/** 是否拥有权限：perm 为空不校验；数组为 OR；*:*:* 为超管 */
export function hasPermission(permissions, perm) {
  if (!perm) return true
  const owned = permissions || []
  if (owned.indexOf('*:*:*') !== -1) return true
  const required = Array.isArray(perm) ? perm : [perm]
  return required.some(p => owned.indexOf(p) !== -1)
}

/** 按角色权限与「我方员工/外协厂商」视角过滤菜单组 */
export function filterMenuGroups(groups, permissions, isVendor) {
  return groups
    .filter(group => !(group.vendorOnly && !isVendor))
    .filter(group => !(group.hideForVendor && isVendor))
    .map(group => ({
      title: group.title,
      items: group.items.filter(item => hasPermission(permissions, item.perm))
    }))
    .filter(group => group.items.length > 0)
}

/** 菜单项未配置 icon 时的兜底图标，保证宫格布局整齐 */
export function menuIcon(item) {
  return (item && item.icon) || DEFAULT_ICON
}
