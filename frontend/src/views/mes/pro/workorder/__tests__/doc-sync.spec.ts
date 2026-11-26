import { describe, it, expect } from 'vitest'
import { buildDocSyncPlan, applyDocSyncPlan, isDraftDoc, isLockedDoc } from '../docSync'

const ctx = {
  productName: '牛皮纸袋', unitOfMeasure: 'PCS', unitName: '个',
  orderDate: '2026-01-01', purchaser: 'admin', deliveryAddress: '工厂'
}

function purDoc(overrides: any = {}) {
  return {
    docTitle: '德欣采购单', vendorId: 202, vendorName: '德欣', status: 'DRAFT',
    orderId: 10, orderCode: 'PO1', lines: [], ...overrides
  }
}

function procDoc(overrides: any = {}) {
  return {
    docTitle: '万隆加工单', vendorId: 208, vendorName: '万隆', status: 'DRAFT',
    orderId: 20, orderCode: 'OS1', lines: [], ...overrides
  }
}

function routeRow(overrides: any = {}) {
  return {
    processId: 217, processName: '原纸', docType: 'PURCHASE', vendorId: 202,
    vendorName: '德欣', vendorCode: 'V202', planQty: 100, unitPrice: 5,
    expectedDate: '2026-01-01', ...overrides
  }
}

describe('docSync', () => {
  it('草稿/非草稿单据判定', () => {
    expect(isDraftDoc({})).toBe(true)
    expect(isDraftDoc({ orderId: 1, status: 'DRAFT' })).toBe(true)
    expect(isDraftDoc({ orderId: 1, status: 'ORDERED' })).toBe(false)
    expect(isLockedDoc({})).toBe(false)
    expect(isLockedDoc({ orderId: 1, status: 'DRAFT' })).toBe(false)
    expect(isLockedDoc({ orderId: 1, status: 'ORDERED' })).toBe(true)
  })
  it('新增工序补进同供应商草稿采购单', () => {
    const plan = buildDocSyncPlan({
      routeProcesses: [routeRow()],
      purchaseDocs: [purDoc()],
      processDocs: [],
      loadedProcessIds: [],
      ctx
    })
    expect(plan.additions).toHaveLength(1)
    expect(plan.additions[0].docIndex).toBe(0)
    expect(plan.additions[0].lines[0].itemName).toBe('原纸')
    expect(plan.stats.addLines).toBe(1)
    expect(plan.stats.addDocs).toBe(0)
    expect(plan.isEmpty).toBe(false)
  })

  it('无草稿单时新建草稿单', () => {
    const plan = buildDocSyncPlan({
      routeProcesses: [routeRow()],
      purchaseDocs: [],
      processDocs: [],
      loadedProcessIds: [],
      ctx
    })
    expect(plan.additions[0].docIndex).toBe(-1)
    expect(plan.additions[0].docHeader.docTitle).toBe('德欣采购单')
    expect(plan.stats.addDocs).toBe(1)
  })

  it('供应商变更只提示，不自动增删', () => {
    const doc = purDoc({ lines: [{ processId: 217, processName: '原纸' }] })
    const plan = buildDocSyncPlan({
      routeProcesses: [routeRow({ vendorId: 203, vendorName: '新供应商' })],
      purchaseDocs: [doc],
      processDocs: [],
      loadedProcessIds: [217],
      ctx
    })
    expect(plan.additions).toHaveLength(0)
    expect(plan.removals).toHaveLength(0)
    expect(plan.manual).toHaveLength(1)
    expect(plan.manual[0].reason).toContain('供应商或开单类型已变更')
  })

  it('开单类型变更只提示', () => {
    const doc = purDoc({ lines: [{ processId: 217, processName: '原纸' }] })
    const plan = buildDocSyncPlan({
      routeProcesses: [routeRow({ docType: 'PROCESS' })],
      purchaseDocs: [doc],
      processDocs: [],
      loadedProcessIds: [217],
      ctx
    })
    expect(plan.additions).toHaveLength(0)
    expect(plan.manual).toHaveLength(1)
  })

  it('删除工序：草稿单明细删除，删空则整单移除', () => {
    const doc = purDoc({ lines: [{ processId: 217, processName: '原纸' }] })
    const plan = buildDocSyncPlan({
      routeProcesses: [],
      purchaseDocs: [doc],
      processDocs: [],
      loadedProcessIds: [217],
      ctx
    })
    expect(plan.removals).toHaveLength(1)
    expect(plan.removals[0].lineIndexes).toEqual([0])
    expect(plan.removals[0].removeDoc).toBe(true)
    expect(plan.stats.removeDocs).toBe(1)
  })

  it('草稿单有发料数据时保留，不自动删除', () => {
    const doc = purDoc({ issueTotalQty: 50, lines: [{ processId: 217, processName: '原纸' }] })
    const plan = buildDocSyncPlan({
      routeProcesses: [],
      purchaseDocs: [doc],
      processDocs: [],
      loadedProcessIds: [217],
      ctx
    })
    expect(plan.removals).toHaveLength(0)
    expect(plan.manual).toHaveLength(1)
    expect(plan.manual[0].reason).toContain('已保留')
  })

  it('非草稿单命中删除时只提示，不删除', () => {
    const doc = purDoc({ status: 'ORDERED', lines: [{ processId: 217, processName: '原纸' }] })
    const plan = buildDocSyncPlan({
      routeProcesses: [],
      purchaseDocs: [doc],
      processDocs: [],
      loadedProcessIds: [217],
      ctx
    })
    expect(plan.removals).toHaveLength(0)
    expect(plan.manual).toHaveLength(1)
    expect(plan.manual[0].reason).toContain('非草稿')
  })

  it('已存在的明细不重复添加', () => {
    const doc = purDoc({ status: 'ORDERED', lines: [{ processId: 217, processName: '原纸' }] })
    const plan = buildDocSyncPlan({
      routeProcesses: [routeRow()],
      purchaseDocs: [doc],
      processDocs: [],
      loadedProcessIds: [217],
      ctx
    })
    expect(plan.additions).toHaveLength(0)
    expect(plan.removals).toHaveLength(0)
  })

  it('未选供应商的工序只提示', () => {
    const plan = buildDocSyncPlan({
      routeProcesses: [routeRow({ vendorId: null, vendorName: null })],
      purchaseDocs: [],
      processDocs: [],
      loadedProcessIds: [],
      ctx
    })
    expect(plan.additions).toHaveLength(0)
    expect(plan.manual[0].reason).toContain('未选择供应商')
  })

  it('processId 为空的手工物料行不会被删除', () => {
    const doc = purDoc({ lines: [{ processId: null, itemName: '手工物料' }] })
    const plan = buildDocSyncPlan({
      routeProcesses: [],
      purchaseDocs: [doc],
      processDocs: [],
      loadedProcessIds: [217],
      ctx
    })
    expect(plan.removals).toHaveLength(0)
  })

  it('apply：删行、追加到已有单据、新建单据', () => {
    const purchase = [purDoc({
      lines: [
        { processId: 217, processName: '原纸' },
        { processId: 218, processName: '辅料' }
      ]
    })]
    const plan = buildDocSyncPlan({
      routeProcesses: [
        routeRow({ processId: 218, processName: '辅料' }),
        routeRow({ processId: 219, processName: '印刷', vendorId: 209, vendorName: '新厂' })
      ],
      purchaseDocs: purchase,
      processDocs: [],
      loadedProcessIds: [217, 218],
      ctx
    })
    const res = applyDocSyncPlan(plan, purchase, [])
    expect(res.purchaseDocs).toHaveLength(2)
    expect(res.purchaseDocs[0].lines.map((l: any) => l.processName)).toEqual(['辅料'])
    expect(res.purchaseDocs[1].vendorName).toBe('新厂')
    expect(res.addedLines).toBe(1)
    expect(res.addedDocs).toBe(1)
    expect(res.removedLines).toBe(1)
  })

  it('apply：整单删除', () => {
    const purchase = [purDoc({ lines: [{ processId: 217, processName: '原纸' }] })]
    const plan = buildDocSyncPlan({
      routeProcesses: [],
      purchaseDocs: purchase,
      processDocs: [],
      loadedProcessIds: [217],
      ctx
    })
    const res = applyDocSyncPlan(plan, purchase, [])
    expect(res.purchaseDocs).toHaveLength(0)
    expect(res.removedDocs).toBe(1)
  })
})
