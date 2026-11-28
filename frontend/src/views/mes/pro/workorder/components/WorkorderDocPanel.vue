<template>
  <div>
    <el-row :gutter="10" class="mb8" v-if="!readonly">
      <el-col :span="1.5"><el-button type="primary" plain icon="Plus" size="small" @click="addPurDoc">新增采购单</el-button></el-col>
      <el-col :span="1.5"><el-button type="warning" plain icon="Plus" size="small" @click="addProcDoc">新增加工单</el-button></el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="Scissor" size="small" :disabled="!slittingProcesses.length"
          :title="slittingProcesses.length ? '' : '路线中没有业务类型为「分切」的工序'" @click="addSlittingDoc">新增分切单</el-button>
      </el-col>
      <el-col :span="10"><span class="tip">采购单可挂工序也可只挂工单；加工单每道工序可指定供应商与交期；分切单按「分切」工序开，母卷发料后可追溯子件</span></el-col>
    </el-row>

    <el-alert v-if="!purchaseDocs.length && !processDocs.length" type="info" :closable="false" show-icon
      title="暂未配置单据。可只保存工单，稍后在采购单/加工单页面单独开单。" class="mb8" />

    <PurchaseDocCard v-for="(d, i) in purchaseDocs" :key="d.__docKey || ('p' + i)" :model-value="d" :process-options="processOptions"
      :readonly="readonly || isLockedDoc(d)" @remove="purchaseDocs.splice(i, 1)" />

    <ProcessDocCard v-for="item in normalProcDocs" :key="item.doc.__docKey || ('o' + item.index)" :model-value="item.doc"
      :process-options="normalProcesses" :product-size="productSize" :printing-req="printingReq"
      :readonly="readonly || isLockedDoc(item.doc)" @remove="removeProcDoc(item.index)" />

    <SlittingDocCard v-for="item in slittingDocs" :key="item.doc.__docKey || ('s' + item.index)" :model-value="item.doc"
      :slitting-processes="slittingProcesses" :readonly="readonly || isLockedDoc(item.doc)"
      @remove="removeProcDoc(item.index)" />

    <el-divider v-if="savedDocs.length" content-position="left">已生成单据（导出 / 打印）</el-divider>
    <el-table v-if="savedDocs.length" :data="savedDocs" size="small" border>
      <el-table-column label="类型" width="90" align="center">
        <template #default="{ row }">
          <el-tag :type="row.type === 'PUR' ? 'primary' : (row.slitting ? 'success' : 'warning')" size="small">
            {{ row.type === 'PUR' ? '采购单' : (row.slitting ? '分切单' : '加工单') }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="单号" prop="orderCode" width="200" />
      <el-table-column label="单据标题" prop="docTitle" min-width="140" />
      <el-table-column label="供应商" prop="vendorName" min-width="160" />
      <el-table-column label="状态" width="100" align="center">
        <template #default="{ row }">
          <dict-tag :options="row.type === 'PUR' ? mes_order_status : mes_outsource_status" :value="row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="260" align="center">
        <template #default="{ row }">
          <el-button link type="primary" size="small" @click="doExport(row, 'excel')">导出Excel</el-button>
          <el-button link type="primary" size="small" @click="doExport(row, 'pdf')">打印PDF</el-button>
        </template>
      </el-table-column>
    </el-table>

    <div v-if="savedDocs.length" class="merge-bar">
      <span class="tip">同供应商多张单据的合并导出，请到采购单/加工单列表页勾选后操作。</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, getCurrentInstance } from 'vue'
import PurchaseDocCard from './PurchaseDocCard.vue'
import ProcessDocCard from './ProcessDocCard.vue'
import SlittingDocCard from './SlittingDocCard.vue'
import { isLockedDoc, docKindOf, isSlittingRow } from '../docSync'
import { printPdfBlob } from '@/utils/pdfPrint'
import {
  exportPurDocExcel, fetchPurDocPdf, exportProcessDocExcel, fetchProcessDocPdf
} from '@/api/mes/pro/workorderFull'

const { proxy } = getCurrentInstance() as any
const { mes_order_status, mes_outsource_status } = proxy.useDict('mes_order_status', 'mes_outsource_status')

const props = defineProps<{ purchaseDocs: any[]; processDocs: any[]; processOptions: any[]; productSize?: string; printingReq?: string; readonly?: boolean }>()
const emit = defineEmits<{ (e: 'update:purchaseDocs', v: any[]): void; (e: 'update:processDocs', v: any[]): void }>()

/** 工艺路线中的分切工序（业务类型=分切） */
const slittingProcesses = computed(() => (props.processOptions || []).filter((p: any) => isSlittingRow(p)))
/** 加工单卡片的工序下拉：分切工序只出现在分切单里 */
const normalProcesses = computed(() => (props.processOptions || []).filter((p: any) => !isSlittingRow(p)))
/** 加工单 / 分切单同存 processDocs，按 sourceType 拆开展示（保留原始下标用于删除） */
const normalProcDocs = computed(() =>
  (props.processDocs || []).map((doc: any, index: number) => ({ doc, index }))
    .filter((item: any) => docKindOf(item.doc) !== 'SLITTING'))
const slittingDocs = computed(() =>
  (props.processDocs || []).map((doc: any, index: number) => ({ doc, index }))
    .filter((item: any) => docKindOf(item.doc) === 'SLITTING'))

const savedDocs = computed(() => {
  const rows: any[] = []
  ;(props.purchaseDocs || []).forEach((d: any) => {
    if (d.orderId) rows.push({ type: 'PUR', orderId: d.orderId, orderCode: d.orderCode, docTitle: d.docTitle, vendorName: d.vendorName, status: d.status })
  })
  ;(props.processDocs || []).forEach((d: any) => {
    if (d.orderId) {
      const slitting = docKindOf(d) === 'SLITTING'
      rows.push({
        type: 'PROC', slitting, orderId: d.orderId, orderCode: d.orderCode,
        docTitle: d.docTitle, vendorName: d.vendorName, status: d.status
      })
    }
  })
  return rows
})

let docKeySeq = 0

function emptyPurDoc() {
  return {
    __docKey: 'p-new-' + (++docKeySeq),
    docTitle: '原材料采购单', vendorId: null, vendorCode: '', vendorName: '',
    purchaseType: 'PAPER', orderDate: today(), purchaser: '', deliveryAddress: '', remark: '', lines: []
  }
}

function emptyProcDoc() {
  return {
    __docKey: 'o-new-' + (++docKeySeq),
    docTitle: '印刷加工单', supplierType: 'OUTSIDE', vendorId: null, vendorCode: '', vendorName: '',
    orderDate: today(), purchaser: '', deliveryAddress: '', remark: '', lines: []
  }
}

/** 分切单：与加工单同表（外协单），用 sourceType=SLITTING 区分 */
function emptySlittingDoc(vendor?: any) {
  return {
    __docKey: 's-new-' + (++docKeySeq),
    docTitle: '分切单', sourceType: 'SLITTING', supplierType: 'OUTSIDE',
    vendorId: vendor?.vendorId ?? null, vendorCode: vendor?.vendorCode || '', vendorName: vendor?.vendorName || '',
    orderDate: today(), purchaser: '', deliveryAddress: '', remark: '',
    lines: [], issueLines: []
  }
}

function addPurDoc() { emit('update:purchaseDocs', [...props.purchaseDocs, emptyPurDoc()]) }
function addProcDoc() { emit('update:processDocs', [...props.processDocs, emptyProcDoc()]) }

function addSlittingDoc() {
  if (!slittingProcesses.value.length) return
  const doc = emptySlittingDoc()
  // 默认带上第一道未开单的分切工序及其供应商
  const used = new Set((props.processDocs || [])
    .filter((d: any) => docKindOf(d) === 'SLITTING')
    .flatMap((d: any) => (d.lines || []).map((l: any) => Number(l.processId))))
  const p = slittingProcesses.value.find((x: any) => !used.has(Number(x.processId))) || slittingProcesses.value[0]
  if (p?.vendorId) {
    doc.vendorId = p.vendorId
    doc.vendorCode = p.vendorCode || ''
    doc.vendorName = p.vendorName || ''
    doc.docTitle = `${p.vendorName || ''}分切单`
  }
  doc.lines.push({
    processId: p.processId, processCode: p.processCode, processName: p.processName,
    productName: '', planQty: Number(p.planQty || 0), unitPrice: Number(p.unitPrice || 0),
    vendorId: doc.vendorId, vendorCode: doc.vendorCode, vendorName: doc.vendorName,
    expectedDate: doc.orderDate, extAttrs: {}
  })
  emit('update:processDocs', [...props.processDocs, doc])
}

/** 删除加工单/分切单：按下标从 processDocs 移除 */
function removeProcDoc(index: number) {
  const next = (props.processDocs || []).slice()
  next.splice(index, 1)
  emit('update:processDocs', next)
}

function today() {
  const d = new Date()
  return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0')
}

/** 单张单据：Excel 下载文件名 = 供应商+单据名称+单号；PDF 直接调起系统打印 */
function doExport(row: any, format: 'excel' | 'pdf') {
  const filename = `${row.vendorName || ''}_${row.docTitle || (row.type === 'PUR' ? '采购单' : '加工单')}_${row.orderCode}.xlsx`
  if (format === 'excel') {
    row.type === 'PUR' ? exportPurDocExcel(row.orderId, filename) : exportProcessDocExcel(row.orderId, filename)
    return
  }
  const req = row.type === 'PUR' ? fetchPurDocPdf(row.orderId) : fetchProcessDocPdf(row.orderId)
  req.then((blob: Blob) => printPdfBlob(blob)).catch(() => {})
}
</script>

<style scoped>
.tip { color: #909399; font-size: 12px; }
.mb8 { margin-bottom: 8px; }
.merge-bar { margin-top: 12px; padding: 10px; background: #fafafa; border-radius: 4px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
</style>
