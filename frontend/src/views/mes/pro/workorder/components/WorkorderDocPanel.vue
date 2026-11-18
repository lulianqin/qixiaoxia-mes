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

    <el-divider v-if="savedDocs.length" content-position="left">已生成单据（导出 / 合并打印）</el-divider>
    <el-table v-if="savedDocs.length" :data="savedDocs" size="small" border>
      <el-table-column label="类型" width="90" align="center">
        <template #default="{ row }">
          <el-tag :type="row.type === 'PUR' ? 'primary' : 'warning'" size="small">{{ row.type === 'PUR' ? '采购单' : '加工单' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="单号" prop="orderCode" width="200" />
      <el-table-column label="单据标题" prop="docTitle" min-width="140" />
      <el-table-column label="供应商" prop="vendorName" min-width="160" />
      <el-table-column label="状态" prop="status" width="100" align="center" />
      <el-table-column label="操作" width="260" align="center">
        <template #default="{ row }">
          <el-button link type="primary" size="small" @click="doExport(row, 'excel')">导出Excel</el-button>
          <el-button link type="primary" size="small" @click="doExport(row, 'pdf')">打印PDF</el-button>
        </template>
      </el-table-column>
    </el-table>

    <div v-if="savedDocs.length" class="merge-bar">
      <span class="tip">勾选同供应商的多张单据可合并打印：</span>
      <el-checkbox-group v-model="mergeSelected">
        <el-checkbox v-for="d in savedDocs" :key="d.type + d.orderId" :value="d.type + ':' + d.orderId" :label="d.type + ':' + d.orderId">
          {{ d.orderCode }}
        </el-checkbox>
      </el-checkbox-group>
      <el-button type="primary" size="small" :disabled="mergeSelected.length < 2" @click="doMerge('excel')">合并导出</el-button>
      <el-button type="primary" size="small" :disabled="mergeSelected.length < 2" plain @click="doMerge('pdf')">合并打印</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import PurchaseDocCard from './PurchaseDocCard.vue'
import ProcessDocCard from './ProcessDocCard.vue'
import {
  exportPurDoc, exportPurDocsMerge, exportProcessDoc, exportProcessDocsMerge
} from '@/api/mes/pro/workorderFull'

const props = defineProps<{ purchaseDocs: any[]; processDocs: any[]; processOptions: any[]; readonly?: boolean }>()
const emit = defineEmits<{ (e: 'update:purchaseDocs', v: any[]): void; (e: 'update:processDocs', v: any[]): void }>()

const mergeSelected = ref<string[]>([])

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

function doExport(row: any, format: 'excel' | 'pdf') {
  const fn = row.type === 'PUR' ? exportPurDoc : exportProcessDoc
  fn(row.orderId, format, row.orderCode)
}

function doMerge(format: 'excel' | 'pdf') {
  const purIds = mergeSelected.value.filter((k: string) => k.startsWith('PUR:')).map((k: string) => Number(k.split(':')[1]))
  const procIds = mergeSelected.value.filter((k: string) => k.startsWith('PROC:')).map((k: string) => Number(k.split(':')[1]))
  if (purIds.length >= 2) exportPurDocsMerge(purIds, format)
  if (procIds.length >= 2) exportProcessDocsMerge(procIds, format)
}
</script>

<style scoped>
.tip { color: #909399; font-size: 12px; }
.mb8 { margin-bottom: 8px; }
.merge-bar { margin-top: 12px; padding: 10px; background: #fafafa; border-radius: 4px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
</style>
