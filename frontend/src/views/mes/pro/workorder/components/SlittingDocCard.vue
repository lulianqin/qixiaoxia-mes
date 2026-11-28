<template>
  <el-card shadow="never" class="doc-card slitting-card">
    <template #header>
      <div class="doc-head">
        <span class="doc-title">
          <el-tag type="success" size="small">分切单</el-tag>
          <span class="ml8">{{ form.docTitle || '分切单' }}</span>
          <el-tag v-if="form.orderCode" size="small" type="success" class="ml8">{{ form.orderCode }}</el-tag>
          <span class="ml8 tip">母卷发料 → 厂商录子件规格 → 收货入实物实例</span>
        </span>
        <span v-if="!readonly">
          <el-button link type="primary" icon="Plus" @click="addLine">加分切工序</el-button>
          <el-button link type="danger" icon="Delete" @click="$emit('remove')">删除单据</el-button>
        </span>
      </div>
    </template>

    <el-form :model="form" label-width="90px" :disabled="readonly" @submit.prevent>
      <el-row :gutter="12">
        <el-col :span="8">
          <el-form-item label="单据标题">
            <el-input v-model="form.docTitle" placeholder="如 张三分切单" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="分切商" required>
            <el-input v-model="form.vendorName" readonly placeholder="请选择分切厂商">
              <template #append><el-button icon="Search" :disabled="readonly" @click="vendorRef?.open()" /></template>
            </el-input>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="下单日期">
            <el-date-picker v-model="form.orderDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-row :gutter="12">
        <el-col :span="8">
          <el-form-item label="申购人">
            <el-input v-model="form.purchaser" placeholder="默认当前用户" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="送货地址">
            <el-input v-model="form.deliveryAddress" placeholder="送货地址" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="备注">
            <el-input v-model="form.remark" placeholder="备注" />
          </el-form-item>
        </el-col>
      </el-row>
    </el-form>

    <el-divider content-position="left">分切工序</el-divider>
    <el-table :data="form.lines" size="small" border>
      <el-table-column label="工序" min-width="160">
        <template #default="{ row }">
          <el-select v-model="row.processId" filterable placeholder="选择分切工序" style="width:100%"
            :disabled="readonly" @change="onProcessChange(row)">
            <el-option v-for="p in slittingOptions" :key="p.processId" :label="p.processName" :value="p.processId" />
          </el-select>
        </template>
      </el-table-column>
      <el-table-column label="产品名称" min-width="150">
        <template #default="{ row }">
          <el-input v-model="row.productName" type="textarea" :autosize="{ minRows: 1, maxRows: 4 }" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column width="120">
        <template #header><span class="req">*</span>数量</template>
        <template #default="{ row }">
          <el-input-number v-model="row.planQty" :min="0" :precision="4" controls-position="right"
            :class="{ 'qty-invalid': Number(row.planQty || 0) <= 0 }" style="width:100%" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="单价" width="110">
        <template #default="{ row }">
          <el-input-number v-model="row.unitPrice" :min="0" :precision="4" controls-position="right"
            style="width:100%" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="金额" width="100" align="right">
        <template #default="{ row }">{{ money(row.planQty, row.unitPrice) }}</template>
      </el-table-column>
      <el-table-column label="送货日期" width="140">
        <template #default="{ row }">
          <el-date-picker v-model="row.expectedDate" type="date" value-format="YYYY-MM-DD" style="width:100%" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="备注" min-width="120">
        <template #default="{ row }">
          <el-input v-model="row.remark" type="textarea" :autosize="{ minRows: 1, maxRows: 4 }" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="60" align="center" v-if="!readonly">
        <template #default="{ $index }">
          <el-button link type="danger" icon="Delete" @click="form.lines.splice($index, 1)" />
        </template>
      </el-table-column>
    </el-table>
    <el-alert v-if="!slittingOptions.length" type="warning" :closable="false" show-icon class="mt8"
      title="当前路线没有「分切」工序。请到 工艺路线/工序管理 把对应工序的业务类型设为「分切」。" />

    <el-divider content-position="left">发料明细（母卷）</el-divider>
    <el-table :data="issueLines" size="small" border>
      <el-table-column label="物料" min-width="180">
        <template #default="{ row }">
          <el-input v-model="row.itemName" readonly placeholder="选择母卷物料">
            <template #append><el-button icon="Search" :disabled="readonly" @click="pickItem(row)" /></template>
          </el-input>
        </template>
      </el-table-column>
      <el-table-column label="母卷实例" min-width="200">
        <template #default="{ row }">
          <el-select v-model="row.instanceId" filterable clearable size="small"
            :placeholder="row.itemId ? '选母卷编号' : '先选物料'" :disabled="readonly || !row.itemId"
            style="width:100%" @change="() => onInstanceChange(row)">
            <el-option v-for="inst in instanceOf(row)" :key="inst.instanceId"
              :label="`${inst.instanceCode}（余${inst.remainingQuantity}${unitNameOf(inst.quantityUom)}）`"
              :value="inst.instanceId" />
          </el-select>
        </template>
      </el-table-column>
      <el-table-column label="数量" width="120">
        <template #default="{ row }">
          <el-input-number v-model="row.quantity" :min="0" :precision="4" controls-position="right"
            :max="row.instanceId ? remainingOf(row) : undefined"
            :class="{ 'qty-invalid': row.instanceId && Number(row.quantity || 0) > remainingOf(row) }"
            style="width:100%" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="单位" width="90">
        <template #default="{ row }">
          <el-select v-model="row.unitName" size="small" :disabled="readonly" style="width:100%" clearable>
            <el-option v-for="u in unitOptions" :key="u.unitCode" :label="u.unitName" :value="u.unitName" />
          </el-select>
        </template>
      </el-table-column>
      <el-table-column label="批次" width="170">
        <template #default="{ row }">
          <el-select v-model="row.batchId" size="small" clearable filterable placeholder="自动取最早批次"
            :disabled="readonly || !row.itemId" style="width:100%" @change="(v: any) => onBatchChange(row, v)">
            <el-option v-for="b in batchOf(row)" :key="b.batchId" :label="`${b.batchCode}（余${b.quantityOnhand}）`" :value="b.batchId" />
          </el-select>
        </template>
      </el-table-column>
      <el-table-column label="仓库" min-width="140">
        <template #default="{ row }">
          <el-input v-model="row.warehouseName" readonly placeholder="发料时补录">
            <template #append><el-button icon="Search" :disabled="readonly" @click="pickWarehouse(row)" /></template>
          </el-input>
        </template>
      </el-table-column>
      <el-table-column label="单价" width="110">
        <template #default="{ row }">
          <el-input-number v-model="row.unitPrice" :min="0" :precision="4" controls-position="right"
            style="width:100%" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="60" align="center" v-if="!readonly">
        <template #default="{ $index }">
          <el-button link type="danger" icon="Delete" @click="issueLines.splice($index, 1)" />
        </template>
      </el-table-column>
    </el-table>
    <el-row :gutter="10" class="mt8" v-if="!readonly">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" size="small" @click="addIssueLine">加发料物料</el-button>
      </el-col>
      <el-col :span="16">
        <span class="tip">一行一个母卷：选母卷实例后数量默认取该卷剩余、批次仓库自动带出；数量可改小做部分分切。不选实例时发料按批次 FIFO（物料已有实物实例时会要求先选母卷）。</span>
      </el-col>
    </el-row>

    <VendorSelect ref="vendorRef" @onSelected="onVendorSelected" />
    <ItemSelect ref="itemRef" @onSelected="onItemSelected" />
    <WarehouseSelect ref="whRef" @onSelected="onWarehouseSelected" />
  </el-card>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import VendorSelect from '@/components/vendorSelect/single.vue'
import ItemSelect from '@/components/itemSelect/single.vue'
import WarehouseSelect from '@/components/warehouseSelect/single.vue'
import { availableBatches } from '@/api/mes/wm/material_stock'
import { availableInstances } from '@/api/mes/wm/stock_instance'
import { listAllUnitmeasure } from '@/api/mes/md/unitmeasure'

const props = defineProps<{
  modelValue: any
  /** 工艺路线中的全部分切工序（已按 bizType=SLITTING 过滤） */
  slittingProcesses: any[]
  readonly?: boolean
}>()
defineEmits<{ (e: 'update:modelValue', v: any): void; (e: 'remove'): void }>()

const form = props.modelValue
const vendorRef = ref()
const itemRef = ref()
const whRef = ref()
const unitOptions = ref<any[]>([])
const batchCache = ref<Record<number, any[]>>({})
const instanceCache = ref<Record<number, any[]>>({})
let currentIssueRow: any = null

const slittingOptions = computed(() => props.slittingProcesses || [])
/** 母卷发料明细（与单据同生命周期，直接改数组） */
if (!form.issueLines) form.issueLines = []
const issueLines = form.issueLines as any[]

if (!unitOptions.value.length) {
  listAllUnitmeasure().then((r: any) => { unitOptions.value = r.data || [] }).catch(() => {})
}

function onVendorSelected(row: any) {
  if (!row) return
  form.vendorId = row.vendorId
  form.vendorCode = row.vendorCode
  form.vendorName = row.vendorName
}

function pickItem(row: any) {
  currentIssueRow = row
  itemRef.value?.open()
}

function onItemSelected(row: any) {
  if (!row || !currentIssueRow) return
  currentIssueRow.itemId = row.itemId
  currentIssueRow.itemCode = row.itemCode
  currentIssueRow.itemName = row.itemName
  currentIssueRow.specification = row.specification || currentIssueRow.specification
  currentIssueRow.unitOfMeasure = row.unitOfMeasure
  currentIssueRow.unitName = row.unitName
  // 换物料后原母卷作废，重新拉可用实例
  currentIssueRow.instanceId = null
  currentIssueRow.instanceCode = null
  loadBatches(currentIssueRow)
  loadInstances(currentIssueRow)
}

function pickWarehouse(row: any) {
  currentIssueRow = row
  whRef.value?.open()
}

function onWarehouseSelected(row: any) {
  if (!row || !currentIssueRow) return
  currentIssueRow.warehouseId = row.warehouseId
  currentIssueRow.warehouseCode = row.warehouseCode
  currentIssueRow.warehouseName = row.warehouseName
}

function loadBatches(row: any) {
  if (!row?.itemId) return
  availableBatches(row.itemId).then((r: any) => {
    batchCache.value = { ...batchCache.value, [row.itemId]: r.data || [] }
  }).catch(() => {})
}

function loadInstances(row: any) {
  if (!row?.itemId) return
  availableInstances(row.itemId).then((r: any) => {
    instanceCache.value = { ...instanceCache.value, [row.itemId]: r.data || [] }
  }).catch(() => {})
}

function instanceOf(row: any) {
  if (!row?.itemId) return []
  if (!instanceCache.value[row.itemId]) loadInstances(row)
  return instanceCache.value[row.itemId] || []
}

function remainingOf(row: any) {
  const inst = instanceOf(row).find((x: any) => x.instanceId === row.instanceId)
  return Number(inst?.remainingQuantity || 0)
}

function unitNameOf(unitCode: any) {
  return unitOptions.value.find((u: any) => u.unitCode === unitCode)?.unitName || ''
}

/** 选母卷：数量默认该卷剩余，批次/仓库/单位跟随实例，避免按别的桶发料 */
function onInstanceChange(row: any) {
  const inst = instanceOf(row).find((x: any) => x.instanceId === row.instanceId)
  if (!inst) {
    row.instanceCode = null
    return
  }
  row.instanceCode = inst.instanceCode
  row.quantity = Number(inst.remainingQuantity || 0)
  if (inst.batchId) {
    row.batchId = inst.batchId
    row.batchCode = inst.batchCode
  }
  row.warehouseId = inst.warehouseId ?? row.warehouseId
  row.warehouseCode = inst.warehouseCode ?? row.warehouseCode
  row.warehouseName = inst.warehouseName ?? row.warehouseName
  if (inst.quantityUom) {
    row.unitOfMeasure = inst.quantityUom
    row.unitName = unitNameOf(inst.quantityUom) || row.unitName
  }
}

function batchOf(row: any) {
  if (!row?.itemId) return []
  if (!batchCache.value[row.itemId]) loadBatches(row)
  return batchCache.value[row.itemId] || []
}

function onBatchChange(row: any, batchId: any) {
  const b = batchOf(row).find((x: any) => x.batchId === batchId)
  if (!b) return
  row.batchCode = b.batchCode
  if (!row.warehouseId) {
    row.warehouseId = b.warehouseId
    row.warehouseCode = b.warehouseCode
    row.warehouseName = b.warehouseName
  }
}

function onProcessChange(row: any) {
  const p = slittingOptions.value.find((x: any) => x.processId === row.processId)
  row.processCode = p?.processCode || null
  row.processName = p?.processName || null
}

function addLine() {
  if (!form.lines) form.lines = []
  form.lines.push({
    processId: null, processCode: null, processName: null,
    productName: '', planQty: 0, unitPrice: 0,
    vendorId: form.vendorId, vendorCode: form.vendorCode, vendorName: form.vendorName,
    expectedDate: form.orderDate, extAttrs: {}
  })
}

function addIssueLine() {
  if (!form.issueLines) form.issueLines = []
  form.issueLines.push({
    itemId: null, itemCode: '', itemName: '', specification: '',
    instanceId: null, instanceCode: null,
    quantity: 0, unitOfMeasure: null, unitName: null,
    batchId: null, batchCode: null, warehouseId: null, warehouseCode: '', warehouseName: '',
    unitPrice: null, amount: null
  })
}

function money(q: any, p: any) {
  return (Number(q || 0) * Number(p || 0)).toFixed(2)
}
</script>

<style scoped>
.doc-card { margin-bottom: 12px; }
.slitting-card :deep(.el-card__header) { background: #f0f9eb; }
.doc-head { display: flex; align-items: center; justify-content: space-between; }
.doc-title { display: flex; align-items: center; font-weight: 600; }
.ml8 { margin-left: 8px; }
.mt8 { margin-top: 8px; }
.tip { color: #909399; font-size: 12px; font-weight: normal; }
.req { color: #f56c6c; margin-right: 2px; }
.qty-invalid :deep(.el-input__wrapper) { box-shadow: 0 0 0 1px #f56c6c inset; }
:deep(.el-form-item__label) { padding-right: 12px !important; }
</style>
