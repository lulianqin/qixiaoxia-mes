/**
 * 生产工单单据同步 — 以工序配置为准计算差异。
 *
 * 安全原则：
 * - 只补「新增/缺失」的明细；
 * - 只删「本次工序配置中已移除」的明细，且仅限草稿单据；
 * - 供应商/开单类型变更只提示，不自动增删或迁移；
 * - 手工物料行（processId 为空）永不参与匹配。
 *
 * 本模块不依赖 Vue，便于单测。
 */

export type DocKind = 'PURCHASE' | 'PROCESS'

export interface SyncContext {
  productName?: string | null
  unitOfMeasure?: string | null
  unitName?: string | null
  orderDate?: string | null
  purchaser?: string | null
  deliveryAddress?: string | null
}

export interface SyncAdditionGroup {
  kind: DocKind
  vendorId: any
  vendorCode?: string | null
  vendorName: string
  /** 追加到已有草稿单的下标；-1 表示新建单据 */
  docIndex: number
  docTitle: string
  orderCode: string
  lines: any[]
  /** 新建单据的单头（docIndex === -1 时使用） */
  docHeader?: any
}

export interface SyncRemovalGroup {
  kind: DocKind
  docIndex: number
  docTitle: string
  orderCode: string
  vendorName: string
  lineIndexes: number[]
  lines: Array<{ processName: string }>
  /** 明细删完后是否整单移除 */
  removeDoc: boolean
}

export interface SyncManualItem {
  processName: string
  reason: string
  docTitle?: string
  orderCode?: string
}

export interface DocSyncPlan {
  additions: SyncAdditionGroup[]
  removals: SyncRemovalGroup[]
  manual: SyncManualItem[]
  warnings: string[]
  stats: { addLines: number; addDocs: number; removeLines: number; removeDocs: number }
  isEmpty: boolean
}

/** 开单类型归一化：PURCHASE-采购单，其余-加工单 */
export function normDocType(t: any): DocKind {
  return String(t || '').toUpperCase() === 'PURCHASE' ? 'PURCHASE' : 'PROCESS'
}

/** 草稿单：页面新建（无 orderId）或状态为 DRAFT */
export function isDraftDoc(doc: any): boolean {
  if (!doc) return false
  if (!doc.orderId) return true
  return String(doc.status || 'DRAFT').toUpperCase() === 'DRAFT'
}

/** 已保存且非草稿：后端会原样保留，前端也应只读 */
export function isLockedDoc(doc: any): boolean {
  return !!doc?.orderId && String(doc.status || 'DRAFT').toUpperCase() !== 'DRAFT'
}

function sameId(a: any, b: any): boolean {
  return String(a ?? '') === String(b ?? '')
}

function toId(v: any): number {
  const n = Number(v)
  return Number.isFinite(n) ? n : 0
}

function hasIssueData(doc: any): boolean {
  return Number(doc?.issueTotalQty || 0) > 0 || !!doc?.issueTime
}

function buildPurLine(row: any, ctx: SyncContext): any {
  return {
    // 采购的是工序服务（非库存物料），用负数伪物料ID避免同一单据内物料重复校验
    itemId: -Math.abs(toId(row.processId) || 1),
    itemCode: 'PROC-' + (row.processCode || row.processId),
    itemName: row.processName,
    productName: ctx.productName || '',
    specification: '',
    unitOfMeasure: ctx.unitOfMeasure || '',
    unitName: ctx.unitName || '',
    quantity: row.planQty,
    unitPrice: row.unitPrice,
    expectedDate: row.expectedDate,
    processId: row.processId,
    processCode: row.processCode,
    processName: row.processName,
    lineAttrs: {},
    remark: ''
  }
}

function buildProcLine(row: any, ctx: SyncContext): any {
  return {
    processId: row.processId,
    processCode: row.processCode,
    processName: row.processName,
    productName: ctx.productName || '',
    planQty: row.planQty,
    unitPrice: row.unitPrice,
    expectedDate: row.expectedDate,
    vendorId: row.vendorId,
    vendorCode: row.vendorCode,
    vendorName: row.vendorName,
    extAttrs: {},
    attrSchema: [],
    remark: ''
  }
}

function buildNewDocHeader(kind: DocKind, row: any, ctx: SyncContext): any {
  const title = `${row.vendorName || ''}${kind === 'PURCHASE' ? '采购单' : '加工单'}`
  if (kind === 'PURCHASE') {
    return {
      docTitle: title,
      vendorId: row.vendorId,
      vendorCode: row.vendorCode || '',
      vendorName: row.vendorName || '',
      purchaseType: 'OTHER',
      orderDate: ctx.orderDate,
      purchaser: ctx.purchaser || '',
      deliveryAddress: ctx.deliveryAddress || '',
      remark: '',
      lines: []
    }
  }
  return {
    docTitle: title,
    supplierType: 'OUTSIDE',
    vendorId: row.vendorId,
    vendorCode: row.vendorCode || '',
    vendorName: row.vendorName || '',
    orderDate: ctx.orderDate,
    purchaser: ctx.purchaser || '',
    deliveryAddress: ctx.deliveryAddress || '',
    remark: '',
    lines: []
  }
}

/** 计算同步计划（不改动传入数据） */
export function buildDocSyncPlan(args: {
  routeProcesses: any[]
  purchaseDocs: any[]
  processDocs: any[]
  loadedProcessIds?: Set<number> | number[]
  ctx: SyncContext
}): DocSyncPlan {
  const rows = args.routeProcesses || []
  const ctx = args.ctx || {}
  const loaded = args.loadedProcessIds instanceof Set
    ? args.loadedProcessIds
    : new Set<number>(args.loadedProcessIds || [])
  const currentIds = new Set<number>()
  rows.forEach((r) => { const id = toId(r?.processId); if (id) currentIds.add(id) })
  const removedIds = new Set<number>()
  loaded.forEach((raw) => {
    const id = toId(raw)
    if (id && !currentIds.has(id)) removedIds.add(id)
  })

  const manual: SyncManualItem[] = []
  const existing = new Map<number, Array<{ kind: DocKind; docIndex: number; doc: any }>>()
  const collect = (kind: DocKind, docs: any[]) => {
    docs.forEach((doc, docIndex) => {
      ;(doc.lines || []).forEach((line: any) => {
        const id = toId(line?.processId)
        if (!id) return
        if (!existing.has(id)) existing.set(id, [])
        existing.get(id)!.push({ kind, docIndex, doc })
      })
    })
  }
  collect('PURCHASE', args.purchaseDocs || [])
  collect('PROCESS', args.processDocs || [])

  const additions = new Map<string, SyncAdditionGroup>()
  rows.forEach((row) => {
    const id = toId(row?.processId)
    if (!id) return
    const kind = normDocType(row.docType)
    const refs = existing.get(id) || []
    if (refs.length) {
      const matched = refs.some((r) => r.kind === kind && sameId(r.doc?.vendorId, row.vendorId))
      if (matched) return
      const ref = refs[0]
      manual.push({
        processName: row.processName || '',
        reason: `供应商或开单类型已变更（原单据：${ref.doc?.vendorName || ''} / ${ref.kind === 'PURCHASE' ? '采购单' : '加工单'}），未自动迁移`,
        docTitle: ref.doc?.docTitle,
        orderCode: ref.doc?.orderCode
      })
      return
    }
    if (!row.vendorId) {
      manual.push({ processName: row.processName || '', reason: '未选择供应商，未生成单据' })
      return
    }
    // 自动开单只服务外协工序；厂内工序需要单据时请在「单据配置」手工新增（含厂内加工单）
    if (String(row.isOutsource) !== '1') {
      manual.push({ processName: row.processName || '', reason: '厂内工序不自动生成单据，如需厂内加工单请在单据配置手工新增' })
      return
    }
    const docs = kind === 'PURCHASE' ? (args.purchaseDocs || []) : (args.processDocs || [])
    let docIndex = -1
    for (let i = 0; i < docs.length; i++) {
      const d = docs[i]
      if (isDraftDoc(d) && sameId(d.vendorId, row.vendorId)) { docIndex = i; break }
    }
    if (docIndex < 0) {
      const nonDraft = docs.find((d) => !isDraftDoc(d) && sameId(d.vendorId, row.vendorId))
      if (nonDraft) {
        manual.push({
          processName: row.processName || '',
          reason: `该供应商已有非草稿单据 ${nonDraft.orderCode || ''}，原单不变，本次将新建草稿单`,
          docTitle: nonDraft.docTitle,
          orderCode: nonDraft.orderCode
        })
      }
    }
    const key = `${kind}|${String(row.vendorId ?? '')}`
    let group = additions.get(key)
    if (!group) {
      const target = docIndex >= 0 ? docs[docIndex] : null
      group = {
        kind,
        vendorId: row.vendorId,
        vendorCode: row.vendorCode,
        vendorName: row.vendorName || '',
        docIndex,
        docTitle: target?.docTitle || '',
        orderCode: target?.orderCode || '',
        lines: [],
        docHeader: docIndex < 0 ? buildNewDocHeader(kind, row, ctx) : undefined
      }
      additions.set(key, group)
    }
    group.lines.push(kind === 'PURCHASE' ? buildPurLine(row, ctx) : buildProcLine(row, ctx))
  })

  const removals: SyncRemovalGroup[] = []
  const collectRemovals = (kind: DocKind, docs: any[]) => {
    docs.forEach((doc, docIndex) => {
      const lines = doc.lines || []
      const hitIndexes: number[] = []
      lines.forEach((line: any, li: number) => {
        const id = toId(line?.processId)
        if (id && removedIds.has(id)) hitIndexes.push(li)
      })
      if (!hitIndexes.length) return
      if (!isDraftDoc(doc)) {
        hitIndexes.forEach((li) => manual.push({
          processName: lines[li]?.processName || '',
          reason: '该单据非草稿状态，未自动删除对应明细，请到单据页面人工处理',
          docTitle: doc.docTitle,
          orderCode: doc.orderCode
        }))
        return
      }
      const removeAll = hitIndexes.length === lines.length
      if (removeAll && hasIssueData(doc)) {
        manual.push({
          processName: '',
          reason: `单据「${doc.docTitle || ''}」删除这些工序后会变空且已有发料数据，已保留，请人工处理`,
          docTitle: doc.docTitle,
          orderCode: doc.orderCode
        })
        return
      }
      removals.push({
        kind,
        docIndex,
        docTitle: doc.docTitle || (kind === 'PURCHASE' ? '采购单' : '加工单'),
        orderCode: doc.orderCode || '',
        vendorName: doc.vendorName || '',
        lineIndexes: hitIndexes,
        lines: hitIndexes.map((li) => ({ processName: lines[li]?.processName || '' })),
        removeDoc: removeAll
      })
    })
  }
  collectRemovals('PURCHASE', args.purchaseDocs || [])
  collectRemovals('PROCESS', args.processDocs || [])

  // 若某张单据已计划新增明细，则删空后也不会为空，取消整单移除
  const addGroups = Array.from(additions.values())
  const targeted = new Set(addGroups.filter((g) => g.docIndex >= 0).map((g) => `${g.kind}|${g.docIndex}`))
  removals.forEach((g) => {
    if (g.removeDoc && targeted.has(`${g.kind}|${g.docIndex}`)) g.removeDoc = false
  })

  const stats = {
    addLines: addGroups.reduce((s, g) => s + g.lines.length, 0),
    addDocs: addGroups.filter((g) => g.docIndex < 0).length,
    removeLines: removals.reduce((s, g) => s + g.lineIndexes.length, 0),
    removeDocs: removals.filter((g) => g.removeDoc).length
  }
  const warnings = [
    '非草稿单据不会被修改或删除',
    '已有明细的数量、单价、交期不会被覆盖'
  ]
  return {
    additions: addGroups,
    removals,
    manual,
    warnings,
    stats,
    isEmpty: !addGroups.length && !removals.length && !manual.length
  }
}

/** 应用同步计划，返回新的单据数组与统计 */
export function applyDocSyncPlan(
  plan: DocSyncPlan,
  purchaseDocs: any[],
  processDocs: any[]
): {
  purchaseDocs: any[]
  processDocs: any[]
  addedLines: number
  addedDocs: number
  removedLines: number
  removedDocs: number
} {
  const purchase = (purchaseDocs || []).slice()
  const proc = (processDocs || []).slice()
  const pick = (kind: DocKind) => (kind === 'PURCHASE' ? purchase : proc)

  // 1. 先删明细（按下标，不改变单据数量，下标稳定）
  plan.removals.forEach((g) => {
    const doc = pick(g.kind)[g.docIndex]
    if (!doc) return
    const drop = new Set(g.lineIndexes)
    doc.lines = (doc.lines || []).filter((_: any, i: number) => !drop.has(i))
  })

  // 2. 追加到已有草稿单
  plan.additions.filter((g) => g.docIndex >= 0).forEach((g) => {
    const doc = pick(g.kind)[g.docIndex]
    if (!doc) return
    doc.lines = [...(doc.lines || []), ...g.lines]
  })

  // 3. 新建草稿单
  let addedDocs = 0
  plan.additions.filter((g) => g.docIndex < 0).forEach((g) => {
    const doc = { ...(g.docHeader || {}), __docKey: `sync-${g.kind}-${Date.now()}-${addedDocs}`, lines: [...g.lines] }
    pick(g.kind).push(doc)
    addedDocs++
  })

  // 4. 删除整单（下标仍与计划一致）
  const dropPur = new Set(plan.removals.filter((g) => g.kind === 'PURCHASE' && g.removeDoc).map((g) => g.docIndex))
  const dropProc = new Set(plan.removals.filter((g) => g.kind === 'PROCESS' && g.removeDoc).map((g) => g.docIndex))
  return {
    purchaseDocs: purchase.filter((_: any, i: number) => !dropPur.has(i)),
    processDocs: proc.filter((_: any, i: number) => !dropProc.has(i)),
    addedLines: plan.stats.addLines,
    addedDocs,
    removedLines: plan.stats.removeLines,
    removedDocs: plan.stats.removeDocs
  }
}
