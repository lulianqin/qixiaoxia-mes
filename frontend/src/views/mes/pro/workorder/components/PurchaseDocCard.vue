<template>
  <el-card shadow="never" class="doc-card">
    <template #header>
      <div class="doc-head">
        <span class="doc-title">
          <el-tag type="primary" size="small">采购单</el-tag>
          <span class="ml8">{{ form.docTitle || '采购单' }}</span>
          <el-tag v-if="form.orderCode" size="small" type="success" class="ml8">{{ form.orderCode }}</el-tag>
        </span>
        <span v-if="!readonly">
          <el-button link type="primary" icon="Plus" @click="addLine">加明细</el-button>
          <el-button link type="danger" icon="Delete" @click="$emit('remove')">删除单据</el-button>
        </span>
      </div>
    </template>

    <el-form :model="form" label-width="90px" size="small" :disabled="readonly">
      <el-row :gutter="12">
        <el-col :span="8">
          <el-form-item label="单据标题">
            <el-select v-model="form.docTitle" style="width:100%" filterable allow-create default-first-option>
              <el-option v-for="t in titles" :key="t" :label="t" :value="t" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="供应商" required>
            <el-input v-model="form.vendorName" readonly placeholder="请选择供应商">
              <template #append><el-button icon="Search" @click="vendorRef?.open()" /></template>
            </el-input>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="采购类型">
            <el-select v-model="form.purchaseType" style="width:100%">
              <el-option v-for="d in purchaseTypes" :key="d.value" :label="d.label" :value="d.value" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row :gutter="12">
        <el-col :span="8">
          <el-form-item label="下单日期">
            <el-date-picker v-model="form.orderDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
          </el-form-item>
        </el-col>
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
      </el-row>
      <el-row :gutter="12">
        <el-col :span="24">
          <el-form-item label="备注">
            <el-input v-model="form.remark" placeholder="备注" />
          </el-form-item>
        </el-col>
      </el-row>
    </el-form>

    <el-table :data="form.lines" size="small" border class="mt8">
      <el-table-column label="物料" min-width="180">
        <template #default="{ row }">
          <el-input v-model="row.itemName" readonly placeholder="选择物料">
            <template #append><el-button icon="Search" @click="pickItem(row)" /></template>
          </el-input>
        </template>
      </el-table-column>
      <el-table-column label="关联工序" width="150">
        <template #default="{ row }">
          <el-select v-model="row.processId" clearable placeholder="不关联" style="width:100%" @change="onProcessChange(row)">
            <el-option v-for="p in processOptions" :key="p.processId" :label="p.processName" :value="p.processId" />
          </el-select>
        </template>
      </el-table-column>
      <el-table-column label="规格" width="140">
        <template #default="{ row }"><el-input v-model="row.specification" /></template>
      </el-table-column>
      <el-table-column label="品牌" width="110">
        <template #default="{ row }">
          <el-input :model-value="brandOf(row)" @update:model-value="(v: string) => setBrand(row, v)" />
        </template>
      </el-table-column>
      <el-table-column label="数量" width="120">
        <template #default="{ row }"><el-input-number v-model="row.quantity" :min="0" :precision="4" controls-position="right" style="width:100%" /></template>
      </el-table-column>
      <el-table-column label="单位" width="80">
        <template #default="{ row }"><el-input v-model="row.unitName" /></template>
      </el-table-column>
      <el-table-column label="单价" width="110">
        <template #default="{ row }"><el-input-number v-model="row.unitPrice" :min="0" :precision="4" controls-position="right" style="width:100%" /></template>
      </el-table-column>
      <el-table-column label="金额" width="100" align="right">
        <template #default="{ row }">{{ money(row.quantity, row.unitPrice) }}</template>
      </el-table-column>
      <el-table-column label="送货日期" width="140">
        <template #default="{ row }">
          <el-date-picker v-model="row.expectedDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="60" align="center" v-if="!readonly">
        <template #default="{ $index }">
          <el-button link type="danger" icon="Delete" @click="form.lines.splice($index, 1)" />
        </template>
      </el-table-column>
    </el-table>

    <VendorSelect ref="vendorRef" @onSelected="onVendorSelected" />
    <ItemSelect ref="itemRef" @onSelected="onItemSelected" />
  </el-card>
</template>

<script setup lang="ts">
import { ref, getCurrentInstance } from 'vue'
import VendorSelect from '@/components/vendorSelect/single.vue'
import ItemSelect from '@/components/itemSelect/single.vue'

const props = defineProps<{ modelValue: any; processOptions: any[]; readonly?: boolean }>()
const emit = defineEmits<{ (e: 'update:modelValue', v: any): void; (e: 'remove'): void }>()

const { proxy } = getCurrentInstance() as any
const { mes_purchase_type } = proxy.useDict('mes_purchase_type')
const purchaseTypes = mes_purchase_type
const titles = ['纸张采购单', '绳子采购单', '包材采购单', '辅料采购单', '原材料采购单']

const form = props.modelValue
const vendorRef = ref()
const itemRef = ref()
let currentRow: any = null

function onVendorSelected(row: any) {
  if (!row) return
  form.vendorId = row.vendorId
  form.vendorCode = row.vendorCode
  form.vendorName = row.vendorName
}

function pickItem(row: any) {
  currentRow = row
  itemRef.value?.open()
}

function onItemSelected(row: any) {
  if (!row || !currentRow) return
  currentRow.itemId = row.itemId
  currentRow.itemCode = row.itemCode
  currentRow.itemName = row.itemName
  currentRow.unitOfMeasure = row.unitOfMeasure
  currentRow.unitName = row.unitName
  currentRow.specification = row.specification || currentRow.specification
}

function onProcessChange(row: any) {
  const p = props.processOptions.find((x: any) => x.processId === row.processId)
  row.processCode = p?.processCode || null
  row.processName = p?.processName || null
}

function addLine() {
  form.lines = form.lines || []
  form.lines.push({ quantity: 1, unitPrice: 0, unitName: '个', lineAttrs: {} })
}

function brandOf(row: any) {
  if (!row.lineAttrs) row.lineAttrs = {}
  return row.lineAttrs.BRAND || ''
}

function setBrand(row: any, v: string) {
  if (!row.lineAttrs) row.lineAttrs = {}
  row.lineAttrs.BRAND = v
}

function money(q: any, p: any) {
  return (Number(q || 0) * Number(p || 0)).toFixed(2)
}
</script>

<style scoped>
.doc-card { margin-bottom: 12px; }
.doc-head { display: flex; align-items: center; justify-content: space-between; }
.doc-title { display: flex; align-items: center; font-weight: 600; }
.ml8 { margin-left: 8px; }
.mt8 { margin-top: 8px; }
:deep(.el-form-item__label) { padding-right: 12px !important; }
</style>
