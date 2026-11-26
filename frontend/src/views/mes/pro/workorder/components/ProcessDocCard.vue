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

    <el-form :model="form" label-width="90px" :disabled="readonly" @submit.prevent>
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
            <el-form v-else label-width="120px" :disabled="readonly" @submit.prevent>
              <el-row :gutter="12">
                <el-col v-for="a in row.attrSchema" :key="a.attrId" :span="8">
                  <el-form-item>
                    <template #label>
                      <span v-if="a.required === '1'" class="req">*</span>{{ a.attrName }}
                    </template>
                    <el-input v-if="widgetOf(a) === 'TEXTAREA'" :model-value="attrVal(row, a)"
                      @update:model-value="(v: string) => setAttr(row, a, v)" type="textarea"
                      :autosize="{ minRows: 2, maxRows: 6 }" placeholder="请输入" />
                    <el-input v-else :model-value="attrVal(row, a)" @update:model-value="(v: string) => setAttr(row, a, v)"
                      :placeholder="a.attrType === 'NUMBER' ? '数字' : '请输入'" />
                  </el-form-item>
                </el-col>
              </el-row>
            </el-form>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="产品名称" min-width="150">
        <template #default="{ row }">
          <el-input v-model="row.productName" type="textarea" :autosize="{ minRows: 1, maxRows: 4 }" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="工序" min-width="160">
        <template #default="{ row }">
          <el-select v-model="row.processId" filterable placeholder="选择工序" style="width:100%" :disabled="readonly" @change="onProcessChange(row)">
            <el-option v-for="p in processOptions" :key="p.processId" :label="p.processName" :value="p.processId" />
          </el-select>
        </template>
      </el-table-column>
      <el-table-column label="材料+工艺" min-width="150">
        <template #default="{ row }">
          <el-input :model-value="craftOf(row)" @update:model-value="(v: string) => setCraft(row, v)"
            type="textarea" :autosize="{ minRows: 1, maxRows: 6 }" placeholder="材料+工艺" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="成品尺寸mm" width="140">
        <template #default="{ row }">
          <el-input :model-value="sizeOf(row)" @update:model-value="(v: string) => setSize(row, v)"
            type="textarea" :autosize="{ minRows: 1, maxRows: 4 }" placeholder="成品尺寸" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="数量" width="120">
        <template #default="{ row }"><el-input-number v-model="row.planQty" :min="0" :precision="4" controls-position="right" style="width:100%" :disabled="readonly" /></template>
      </el-table-column>
      <el-table-column label="单价" width="110">
        <template #default="{ row }"><el-input-number v-model="row.unitPrice" :min="0" :precision="4" controls-position="right" style="width:100%" :disabled="readonly" /></template>
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

    <VendorSelect ref="vendorRef" @onSelected="onVendorSelected" />
  </el-card>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import VendorSelect from '@/components/vendorSelect/single.vue'
import { getOutsourceProcessAttr } from '@/api/mes/wm/outsourceProcessAttr'

const props = defineProps<{ modelValue: any; processOptions: any[]; productSize?: string; printingReq?: string; readonly?: boolean }>()
const emit = defineEmits<{ (e: 'update:modelValue', v: any): void; (e: 'remove'): void }>()

/** 单据固定列在 extAttrs 中的保留键（与后端 WmOutsourceController 保持一致） */
const CRAFT_KEY = 'MATERIAL_CRAFT'
const SIZE_KEY = 'FINISHED_SIZE'

const form = props.modelValue
const vendorRef = ref()
/** 当前展开的明细行（受控，避免编辑属性后自动收起） */
const expandedKeys = ref<string[]>([])
let keySeq = 0

function hasAttrValue(row: any) {
  const attrs = row?.extAttrs || {}
  // 固定列（材料+工艺/成品尺寸）不属于动态属性，不计入展开判断
  return Object.entries(attrs).some(([k, v]) =>
    k !== CRAFT_KEY && k !== SIZE_KEY && v !== null && v !== undefined && String(v).trim() !== '')
}

/** 服务端回显的 extAttrs 是 JSON 字符串，统一转成对象，避免回显丢失与提交类型不匹配 */
function normalizeAttrs(l: any) {
  if (typeof l.extAttrs !== 'string') {
    if (!l.extAttrs) l.extAttrs = {}
    return
  }
  try {
    l.extAttrs = l.extAttrs.trim() ? JSON.parse(l.extAttrs) : {}
  } catch (e) {
    l.extAttrs = {}
  }
}

/** 为每行生成稳定 row-key，并加载工序属性模板（生成单据时也能直接看到属性） */
function syncRows() {
  const lines = props.modelValue?.lines || []
  const autoExpand: string[] = []
  lines.forEach((l: any) => {
    normalizeAttrs(l)
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
  // 切换工序只重置动态属性模板值，保留单据固定列（材料+工艺/成品尺寸）手填内容
  const keep: any = {}
  if (row.extAttrs?.[CRAFT_KEY] != null) keep[CRAFT_KEY] = row.extAttrs[CRAFT_KEY]
  if (row.extAttrs?.[SIZE_KEY] != null) keep[SIZE_KEY] = row.extAttrs[SIZE_KEY]
  row.extAttrs = keep
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

/** 材料+工艺默认取主工单印刷要求，成品尺寸默认取产品尺寸，均直接展示为可编辑内容 */
function craftOf(row: any) {
  return row.extAttrs?.[CRAFT_KEY] ?? (props.printingReq ?? '')
}

function setCraft(row: any, v: string) {
  if (!row.extAttrs) row.extAttrs = {}
  row.extAttrs[CRAFT_KEY] = v
}

function sizeOf(row: any) {
  return row.extAttrs?.[SIZE_KEY] ?? (props.productSize ?? '')
}

function setSize(row: any, v: string) {
  if (!row.extAttrs) row.extAttrs = {}
  row.extAttrs[SIZE_KEY] = v
}

/** 优先用控件类型；历史数据没有 widgetType 时兼容 attrType */
function widgetOf(a: any) {
  return String(a.widgetType || a.attrType || 'TEXT').toUpperCase()
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
