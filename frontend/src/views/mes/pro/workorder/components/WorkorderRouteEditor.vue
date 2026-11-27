<template>
  <div>
    <el-row :gutter="12" class="mb8">
      <el-col :span="8">
        <el-form-item label="产品名称" label-width="90px">
          <el-input v-model="config.productName" placeholder="默认取工单产品" :disabled="readonly" />
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="送货地址" label-width="90px">
          <el-input v-model="config.deliveryAddress" placeholder="送货地址" :disabled="readonly" />
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="下单日期" label-width="90px">
          <el-date-picker v-model="config.orderDate" type="date" value-format="YYYY-MM-DD"
            style="width:100%" :disabled="readonly" />
        </el-form-item>
      </el-col>
    </el-row>
    <el-row :gutter="12" class="mb8">
      <el-col :span="8">
        <el-form-item label="申购人" label-width="90px">
          <el-input v-model="config.purchaser" placeholder="默认当前操作人" :disabled="readonly" />
        </el-form-item>
      </el-col>
    </el-row>

    <el-row :gutter="10" class="mb8" v-if="!readonly">
      <el-col :span="1.5">
        <el-button type="success" plain icon="Plus" size="small" @click="openSelector">添加工序</el-button>
      </el-col>
      <el-col :span="18"><span class="tip">每道工序配置开单类型/供应商/交期/数量/单价，单据配置页可一键生成单据</span></el-col>
    </el-row>

    <el-table :data="list" size="small" border show-summary :summary-method="summary">
      <el-table-column label="序号" width="55" align="center">
        <template #default="{ $index }">{{ $index + 1 }}</template>
      </el-table-column>
      <el-table-column label="工序" min-width="140">
        <template #default="{ row }">{{ row.processName }}</template>
      </el-table-column>
      <el-table-column label="外协" width="70" align="center">
        <template #default="{ row }">
          <el-switch v-model="row.isOutsource" active-value="1" inactive-value="0" :disabled="readonly" size="small" />
        </template>
      </el-table-column>
      <el-table-column label="开单" width="110" align="center">
        <template #default="{ row }">
          <el-select v-model="row.docType" size="small" :disabled="readonly" style="width:100%">
            <el-option label="加工" value="PROCESS" />
            <el-option label="采购" value="PURCHASE" />
          </el-select>
        </template>
      </el-table-column>
      <el-table-column label="供应商" width="180">
        <template #default="{ row }">
          <el-input v-model="row.vendorName" readonly :placeholder="row.isOutsource === '1' ? '选择供应商' : '厂内工序无需供应商'" size="small">
            <template #append><el-button icon="Search" size="small" :disabled="readonly || row.isOutsource !== '1'" @click="pickVendor(row)" /></template>
          </el-input>
        </template>
      </el-table-column>
      <el-table-column label="送货日期" width="150">
        <template #default="{ row }">
          <el-date-picker v-model="row.expectedDate" type="date" value-format="YYYY-MM-DD" size="small"
            style="width:100%" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="数量" width="120">
        <template #default="{ row }">
          <el-input-number v-model="row.planQty" :min="0" :precision="4" controls-position="right"
            size="small" style="width:100%" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="单价" width="110">
        <template #default="{ row }">
          <el-input-number v-model="row.unitPrice" :min="0" :precision="4" controls-position="right"
            size="small" style="width:100%" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="金额" width="110" align="right">
        <template #default="{ row }">{{ money(row.planQty, row.unitPrice) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="110" align="center" v-if="!readonly">
        <template #default="{ $index }">
          <el-button link type="primary" icon="Top" size="small" :disabled="$index === 0" @click="move($index, -1)" />
          <el-button link type="primary" icon="Bottom" size="small" :disabled="$index === list.length - 1" @click="move($index, 1)" />
          <el-button link type="danger" icon="Delete" size="small" @click="list.splice($index, 1)" />
        </template>
      </el-table-column>
    </el-table>

    <el-dialog title="添加工序" v-model="selectorOpen" width="600px" append-to-body>
      <el-table :data="available" highlight-current-row @row-dblclick="addRow">
        <el-table-column label="工序编码" prop="processCode" width="130" />
        <el-table-column label="工序名称" prop="processName" />
      </el-table>
      <template #footer><el-button @click="selectorOpen = false">关 闭</el-button></template>
    </el-dialog>

    <VendorSelect ref="vendorRef" @onSelected="onVendorSelected" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import VendorSelect from '@/components/vendorSelect/single.vue'

const props = defineProps<{
  modelValue: any[]
  processOptions: any[]
  config: any
  defaultQty?: number
  readonly?: boolean
}>()
const emit = defineEmits<{ (e: 'update:modelValue', v: any[]): void }>()

const list = computed(() => props.modelValue)
const selectorOpen = ref(false)
const vendorRef = ref()
let currentRow: any = null

const available = computed(() => {
  const used = new Set((props.modelValue || []).map((p: any) => p.processId))
  return (props.processOptions || []).filter((p: any) => !used.has(p.processId))
})

function openSelector() { selectorOpen.value = true }

function addRow(row: any) {
  if (!row || !row.processId) return
  props.modelValue.push({
    processId: row.processId, processCode: row.processCode, processName: row.processName,
    isOutsource: row.isOutsource || '0', docType: 'PROCESS', orderNum: props.modelValue.length + 1,
    vendorId: row.vendorId || null, vendorCode: row.vendorCode || null, vendorName: row.vendorName || null,
    planQty: props.defaultQty || 0, unitPrice: 0, expectedDate: props.config?.orderDate || null
  })
  selectorOpen.value = false
}

function move(idx: number, dir: number) {
  const arr = props.modelValue
  const target = idx + dir
  if (target < 0 || target >= arr.length) return
  const [item] = arr.splice(idx, 1)
  arr.splice(target, 0, item)
  arr.forEach((p: any, i: number) => { p.orderNum = i + 1 })
}

function pickVendor(row: any) {
  if (props.readonly) return
  currentRow = row
  vendorRef.value?.open()
}

function onVendorSelected(row: any) {
  if (!row || !currentRow) return
  currentRow.vendorId = row.vendorId
  currentRow.vendorCode = row.vendorCode
  currentRow.vendorName = row.vendorName
}

function money(q: any, p: any) {
  return (Number(q || 0) * Number(p || 0)).toFixed(2)
}

function summary({ columns }: any) {
  const rows = props.modelValue || []
  const total = rows.reduce((s: number, r: any) => s + Number(r.planQty || 0) * Number(r.unitPrice || 0), 0)
  const sums: string[] = []
  columns.forEach((_c: any, i: number) => {
    if (i === 0) sums[i] = '合计'
    else if (i === columns.length - 2) sums[i] = total.toFixed(2)
    else sums[i] = ''
  })
  return sums
}
</script>

<style scoped>
.tip { color: #909399; font-size: 12px; }
.mb8 { margin-bottom: 8px; }
:deep(.el-form-item) { margin-bottom: 8px; }
</style>
