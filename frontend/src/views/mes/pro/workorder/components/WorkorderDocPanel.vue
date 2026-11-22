<template>
  <div>
    <el-row :gutter="10" class="mb8" v-if="!readonly">
      <el-col :span="1.5"><el-button type="primary" plain icon="Plus" size="small" @click="addPurDoc">新增采购单</el-button></el-col>
      <el-col :span="1.5"><el-button type="warning" plain icon="Plus" size="small" @click="addProcDoc">新增加工单</el-button></el-col>
      <el-col :span="12"><span class="tip">采购单可挂工序也可只挂工单；加工单每道工序可指定供应商与交期</span></el-col>
    </el-row>

    <el-alert v-if="!purchaseDocs.length && !processDocs.length" type="info" :closable="false" show-icon
      title="暂未配置单据。可只保存工单，稍后在采购单/加工单页面单独开单。" class="mb8" />

    <PurchaseDocCard v-for="(d, i) in purchaseDocs" :key="'p' + i" :model-value="d" :process-options="processOptions"
      :readonly="readonly" @remove="purchaseDocs.splice(i, 1)" />

    <ProcessDocCard v-for="(d, i) in processDocs" :key="'o' + i" :model-value="d" :process-options="processOptions"
      :readonly="readonly" @remove="processDocs.splice(i, 1)" />

    <el-divider v-if="savedDocs.length" content-position="left">已生成单据（导出 / 打印）</el-divider>
    <el-table v-if="savedDocs.length" :data="savedDocs" size="small" border>
      <el-table-column label="类型" width="90" align="center">
        <template #default="{ row }">
          <el-tag :type="row.type === 'PUR' ? 'primary' : 'warning'" size="small">{{ row.type === 'PUR' ? '采购单' : '加工单' }}</el-tag>
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
import { printPdfBlob } from '@/utils/pdfPrint'
import {
  exportPurDocExcel, fetchPurDocPdf, exportProcessDocExcel, fetchProcessDocPdf
} from '@/api/mes/pro/workorderFull'

const { proxy } = getCurrentInstance() as any
const { mes_order_status, mes_outsource_status } = proxy.useDict('mes_order_status', 'mes_outsource_status')

const props = defineProps<{ purchaseDocs: any[]; processDocs: any[]; processOptions: any[]; readonly?: boolean }>()
const emit = defineEmits<{ (e: 'update:purchaseDocs', v: any[]): void; (e: 'update:processDocs', v: any[]): void }>()

const savedDocs = computed(() => {
  const rows: any[] = []
  ;(props.purchaseDocs || []).forEach((d: any) => {
    if (d.orderId) rows.push({ type: 'PUR', orderId: d.orderId, orderCode: d.orderCode, docTitle: d.docTitle, vendorName: d.vendorName, status: d.status })
  })
  ;(props.processDocs || []).forEach((d: any) => {
    if (d.orderId) rows.push({ type: 'PROC', orderId: d.orderId, orderCode: d.orderCode, docTitle: d.docTitle, vendorName: d.vendorName, status: d.status })
  })
  return rows
})

function emptyPurDoc() {
  return {
    docTitle: '原材料采购单', vendorId: null, vendorCode: '', vendorName: '',
    purchaseType: 'PAPER', orderDate: today(), purchaser: '', deliveryAddress: '', remark: '', lines: []
  }
}

function emptyProcDoc() {
  return {
    docTitle: '印刷加工单', supplierType: 'OUTSIDE', vendorId: null, vendorCode: '', vendorName: '',
    orderDate: today(), purchaser: '', deliveryAddress: '', remark: '', lines: []
  }
}

function addPurDoc() { emit('update:purchaseDocs', [...props.purchaseDocs, emptyPurDoc()]) }
function addProcDoc() { emit('update:processDocs', [...props.processDocs, emptyProcDoc()]) }

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
