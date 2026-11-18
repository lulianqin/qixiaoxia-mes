<template>
  <el-card shadow="never" class="doc-card">
    <template #header>
      <div class="doc-head">
        <span class="doc-title">
          <el-tag type="warning" size="small">加工单</el-tag>
          <span class="ml8">{{ form.docTitle || '加工单' }}</span>
          <el-tag v-if="form.orderCode" size="small" type="success" class="ml8">{{ form.orderCode }}</el-tag>
          <el-tag size="small" type="info" class="ml8">{{ form.supplierType === 'INSIDE' ? '厂内' : '外协' }}</el-tag>
        </span>
        <span v-if="!readonly">
          <el-button link type="primary" icon="Plus" @click="addLine">加工序</el-button>
          <el-button link type="danger" icon="Delete" @click="$emit('remove')">删除单据</el-button>
        </span>
      </div>
    </template>

    <el-form :model="form" label-width="90px" size="small" :disabled="readonly">
      <el-row :gutter="12">
        <el-col :span="8">
          <el-form-item label="单据标题">
            <el-input v-model="form.docTitle" placeholder="如 印刷加工单" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="加工类型">
            <el-radio-group v-model="form.supplierType">
              <el-radio value="OUTSIDE">外协</el-radio>
              <el-radio value="INSIDE">厂内</el-radio>
            </el-radio-group>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="加工商" :required="form.supplierType !== 'INSIDE'">
            <el-input v-model="form.vendorName" readonly placeholder="请选择加工商" :disabled="form.supplierType === 'INSIDE'">
              <template #append><el-button icon="Search" :disabled="form.supplierType === 'INSIDE'" @click="vendorRef?.open()" /></template>
            </el-input>
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
    </el-form>

    <el-table :data="form.lines" size="small" border class="mt8" row-key="__key"
      :expand-row-keys="expandedKeys" @expand-change="onExpandChange">
      <el-table-column type="expand" width="36">
        <template #default="{ row }">
          <div class="attr-wrap">
            <el-empty v-if="!row.attrSchema || !row.attrSchema.length" description="该工序未配置属性模板" :image-size="40" />
            <el-form v-else label-width="120px" size="small" :disabled="readonly">
              <el-row :gutter="12">
                <el-col v-for="a in row.attrSchema" :key="a.attrId" :span="8">
                  <el-form-item>
                    <template #label>
                      <span v-if="a.required === '1'" class="req">*</span>{{ a.attrName }}
                    </template>
                    <el-input :model-value="attrVal(row, a)" @update:model-value="(v: string) => setAttr(row, a, v)"
                      :placeholder="a.attrType === 'NUMBER' ? '数字' : '请输入'" />
                  </el-form-item>
                </el-col>
              </el-row>
            </el-form>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="产品名称" min-width="150">
        <template #default="{ row }"><el-input v-model="row.productName" /></template>
      </el-table-column>
      <el-table-column label="工序" min-width="160">
        <template #default="{ row }">
          <el-select v-model="row.processId" filterable placeholder="选择工序" style="width:100%" @change="onProcessChange(row)">
            <el-option v-for="p in processOptions" :key="p.processId" :label="p.processName" :value="p.processId" />
          </el-select>
        </template>
      </el-table-column>
      <el-table-column label="数量" width="120">
        <template #default="{ row }"><el-input-number v-model="row.planQty" :min="0" :precision="4" controls-position="right" style="width:100%" /></template>
      </el-table-column>
      <el-table-column label="单价" width="110">
        <template #default="{ row }"><el-input-number v-model="row.unitPrice" :min="0" :precision="4" controls-position="right" style="width:100%" /></template>
      </el-table-column>
      <el-table-column label="金额" width="100" align="right">
        <template #default="{ row }">{{ money(row.planQty, row.unitPrice) }}</template>
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
  </el-card>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import VendorSelect from '@/components/vendorSelect/single.vue'
import { getOutsourceProcessAttr } from '@/api/mes/wm/outsourceProcessAttr'

const props = defineProps<{ modelValue: any; processOptions: any[]; readonly?: boolean }>()
const emit = defineEmits<{ (e: 'update:modelValue', v: any): void; (e: 'remove'): void }>()

const form = props.modelValue
const vendorRef = ref()
/** 当前展开的明细行（受控，避免编辑属性后自动收起） */
const expandedKeys = ref<string[]>([])
let keySeq = 0

function hasAttrValue(row: any) {
  const attrs = row?.extAttrs || {}
  return Object.values(attrs).some((v: any) => v !== null && v !== undefined && String(v).trim() !== '')
}

/** 为每行生成稳定 row-key，并加载工序属性模板（生成单据时也能直接看到属性） */
function syncRows() {
  const lines = props.modelValue?.lines || []
  const autoExpand: string[] = []
  lines.forEach((l: any) => {
    if (!l.__key) l.__key = 'line-' + (++keySeq)
    if (!l.attrSchema || !l.attrSchema.length) {
      if (l.processId && !l.__schemaLoading) {
        l.__schemaLoading = true
        getOutsourceProcessAttr(l.processId)
          .then((r: any) => { l.attrSchema = r.data || [] })
          .catch(() => {})
          .finally(() => { l.__schemaLoading = false })
      }
    }
    if (hasAttrValue(l)) autoExpand.push(l.__key)
  })
  if (autoExpand.length) {
    expandedKeys.value = Array.from(new Set([...expandedKeys.value, ...autoExpand]))
  }
}

watch(() => props.modelValue?.lines, () => { syncRows() }, { immediate: true })

function onExpandChange(_row: any, expanded: any) {
  const rows = Array.isArray(expanded) ? expanded : [expanded]
  expandedKeys.value = rows.filter(Boolean).map((r: any) => r.__key)
}

function onVendorSelected(row: any) {
  if (!row) return
  form.vendorId = row.vendorId
  form.vendorCode = row.vendorCode
  form.vendorName = row.vendorName
  // 单头供应商回填到未单独指定供应商的工序行
  ;(form.lines || []).forEach((l: any) => {
    if (!l.vendorId) {
      l.vendorId = row.vendorId
      l.vendorCode = row.vendorCode
      l.vendorName = row.vendorName
    }
  })
}

function onProcessChange(row: any) {
  const p = props.processOptions.find((x: any) => x.processId === row.processId)
  row.processCode = p?.processCode || null
  row.processName = p?.processName || null
  row.extAttrs = {}
  row.attrSchema = []
  if (row.processId) {
    getOutsourceProcessAttr(row.processId).then((r: any) => { row.attrSchema = r.data || [] }).catch(() => {})
  }
  if (!row.vendorId && form.vendorId) {
    row.vendorId = form.vendorId
    row.vendorCode = form.vendorCode
    row.vendorName = form.vendorName
  }
}

function attrVal(row: any, a: any) {
  return row.extAttrs?.[a.attrCode] ?? ''
}

function setAttr(row: any, a: any, v: string) {
  if (!row.extAttrs) row.extAttrs = {}
  row.extAttrs[a.attrCode] = v
}

function addLine() {
  form.lines = form.lines || []
  form.lines.push({
    productName: '', planQty: 0, unitPrice: 0, vendorId: form.vendorId, vendorCode: form.vendorCode,
    vendorName: form.vendorName, extAttrs: {}, attrSchema: []
  })
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
.attr-wrap { padding: 8px 16px; background: #fafafa; }
.req { color: #f56c6c; margin-right: 2px; }
:deep(.el-form-item__label) { padding-right: 12px !important; }
</style>
