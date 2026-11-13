<template>
  <el-dialog v-model="visible" title="外协发货" width="1100px" :close-on-click-modal="false" append-to-body @close="cancel">
    <el-form label-width="100px">
      <el-row>
        <el-col :span="12">
          <el-form-item label="生产工单">
            <el-input v-model="form.workorderCode" placeholder="可选，点击右侧选择" readonly>
              <template #append>
                <el-button icon="Search" @click="woSelectRef?.open()" />
              </template>
            </el-input>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="外协厂商" required>
            <el-select v-model="form.vendorId" placeholder="请选择外协厂商" filterable style="width: 100%" @change="onVendorChange">
              <el-option v-for="v in vendorOptions" :key="v.vendorId" :label="v.vendorName" :value="v.vendorId" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="12" v-if="form.workorderId">
          <el-form-item label="外协工序">
            <el-select v-model="form.processId" placeholder="请选择外协工序" filterable clearable style="width: 100%" @change="onProcessChange">
              <el-option v-for="p in processOptions" :key="p.processId" :label="p.processName" :value="p.processId" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="12" v-if="form.workorderId">
          <el-form-item label="流转卡">
            <el-select v-model="form.cardId" placeholder="可选" filterable clearable style="width: 100%" @change="onCardChange">
              <el-option v-for="c in cardOptions" :key="c.cardId" :label="c.cardCode" :value="c.cardId" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="来源类型">
            <el-select v-model="form.sourceType" placeholder="请选择" style="width: 100%">
              <el-option v-for="d in mes_outsource_type" :key="d.value" :label="d.label" :value="d.value" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>

      <!-- 发料物料行 -->
      <el-divider content-position="left">发料明细</el-divider>
      <el-table :data="form.issueLines" border size="small" max-height="320">
        <el-table-column label="物料" align="center" min-width="180">
          <template #default="{ row }">
            <el-input v-model="row.itemName" placeholder="点击右侧选择" readonly size="small">
              <template #append>
                <el-button icon="Search" size="small" @click="currentItemIdx = form.issueLines.indexOf(row); itemSelectRef?.open()" />
              </template>
            </el-input>
          </template>
        </el-table-column>
        <el-table-column label="数量" align="center" width="150">
          <template #default="{ row }">
            <el-input-number v-model="row.quantity" :min="0" :precision="4" :controls="false" size="small" style="width: 100%" placeholder="支持10万级数量" />
          </template>
        </el-table-column>
        <el-table-column label="单位" align="center" width="80">
          <template #default="{ row }">
            <span>{{ row.unitName || row.unitOfMeasure || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column v-for="attr in attrSchema" :key="attr.attrCode" :label="attr.attrName + (attr.attrUnit ? '(' + attr.attrUnit + ')' : '')" align="center" width="140">
          <template #default="{ row }">
            <el-select v-if="attr.attrType === 'SELECT'" v-model="row._attrs[attr.attrCode]" size="small" clearable style="width:100%">
              <el-option v-for="opt in parseOptions(attr.optionsJson)" :key="opt" :label="opt" :value="opt" />
            </el-select>
            <el-input-number v-else-if="attr.attrType === 'NUMBER'" v-model="row._attrs[attr.attrCode]" :controls="false" size="small" style="width:100%" />
            <el-switch v-else-if="attr.attrType === 'BOOL'" v-model="row._attrs[attr.attrCode]" />
            <el-date-picker v-else-if="attr.attrType === 'DATE'" v-model="row._attrs[attr.attrCode]" type="date" value-format="YYYY-MM-DD" size="small" style="width:100%" />
            <el-input v-else v-model="row._attrs[attr.attrCode]" size="small" />
          </template>
        </el-table-column>
        <el-table-column label="单价" align="center" width="120">
          <template #default="{ row }">
            <el-input-number v-model="row.unitPrice" :min="0" :precision="4" :controls="false" size="small" style="width:100%" @change="recalcAmount(row)" />
          </template>
        </el-table-column>
        <el-table-column label="金额" align="center" width="120">
          <template #default="{ row }"><span>{{ money(row.amount) }}</span></template>
        </el-table-column>
        <el-table-column label="仓库" align="center" min-width="140">
          <template #default="{ row }">
            <el-input v-model="row.warehouseName" placeholder="点击右侧选择" readonly size="small">
              <template #append>
                <el-button icon="Search" size="small" @click="currentItemIdx = form.issueLines.indexOf(row); whSelectRef?.open()" />
              </template>
            </el-input>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" width="60">
          <template #default="{ $index }">
            <el-button link type="danger" size="small" icon="Delete" @click="removeLine($index)" />
          </template>
        </el-table-column>
      </el-table>
      <div class="mt8 line-actions">
        <el-button type="primary" plain icon="Plus" size="small" @click="addLine">添加物料</el-button>
        <el-button v-if="outsourceInfo?.productId" plain icon="Box" size="small" @click="addProductLine">发产品本身（{{ outsourceInfo.productName }}）</el-button>
      </div>
    </el-form>

    <ItemSelect ref="itemSelectRef" @onSelected="onItemSelected" />
    <WorkorderSelect ref="woSelectRef" @onSelected="onWorkorderSelected" />
    <WarehouseSelect ref="whSelectRef" @onSelected="onWarehouseSelected" />

    <template #footer>
      <el-button @click="cancel">取消</el-button>
      <el-button type="primary" :loading="submitting" :disabled="!canSubmit" @click="submit">确认发货</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, computed, getCurrentInstance } from 'vue'
import { createOutsource } from '@/api/mes/wm/outsource'
import { getOutsourceProcessAttr } from '@/api/mes/wm/outsourceProcessAttr'
import { getOutsourceInfo } from '@/api/mes/pro/workorder'
import { listAllVendor } from '@/api/mes/md/vendor'
import { listProcard } from '@/api/mes/pro/procard'
import ItemSelect from '@/components/itemSelect/single.vue'
import WorkorderSelect from '@/components/workorderSelect/single.vue'
import WarehouseSelect from '@/components/warehouseSelect/single.vue'

const { proxy } = getCurrentInstance() as any
const { mes_outsource_type } = proxy.useDict('mes_outsource_type')
const emit = defineEmits(['success'])

const visible = ref(false)
const submitting = ref(false)
const itemSelectRef = ref()
const woSelectRef = ref()
const whSelectRef = ref()
const currentItemIdx = ref(0)
const vendorOptions = ref<any[]>([])
const cardOptions = ref<any[]>([])
const processOptions = ref<any[]>([])
// 工单外协信息（外协工序/默认厂商/BOM发料行/产品本身）
const outsourceInfo = ref<any>(null)

const form = reactive<any>({
  vendorId: null, vendorCode: '', vendorName: '',
  sourceType: 'GENERIC',
  workorderId: null, workorderCode: '',
  cardId: null, routeId: null,
  processId: null, processCode: '', processName: '',
  issueLines: []
})

const canSubmit = computed(() => {
  return form.vendorId != null && form.issueLines.length > 0
    && form.issueLines.every((l: any) => l.itemId && l.quantity > 0 && l.warehouseId && attrReady(l))
})
// 外协工序字段模板：选择工序后按模板动态渲染明细列（分切保留原逻辑）
const attrSchema = ref<any[]>([])
function parseOptions(json?: string) {
  if (!json) return []
  try { const arr = JSON.parse(json); return Array.isArray(arr) ? arr : [] } catch { return [] }
}
function attrReady(line: any) {
  return (attrSchema.value || []).every((a: any) =>
    a.required !== '1' || (line._attrs && String(line._attrs[a.attrCode] ?? '').trim() !== ''))
}
function recalcAmount(line: any) {
  line.amount = line.unitPrice != null && line.quantity != null
    ? Number((Number(line.quantity) * Number(line.unitPrice)).toFixed(2)) : null
}
function money(v: any) {
  return v == null || v === '' ? '-' : Number(v).toFixed(2)
}

async function open() {
  visible.value = true
  resetForm()
  if (vendorOptions.value.length === 0) {
    const res = await listAllVendor()
    vendorOptions.value = (res.data || []).filter((v: any) => v.vendorType === 'OUTSOURCE' || v.vendorType === 'BOTH')
  }
}

function resetForm() {
  Object.assign(form, {
    vendorId: null, vendorCode: '', vendorName: '',
    sourceType: 'GENERIC',
    workorderId: null, workorderCode: '',
    cardId: null, routeId: null,
    processId: null, processCode: '', processName: '',
    issueLines: []
  })
  attrSchema.value = []
  cardOptions.value = []
  processOptions.value = []
  outsourceInfo.value = null
}

function onVendorChange(vendorId: number) {
  const v = vendorOptions.value.find((x: any) => x.vendorId === vendorId)
  if (v) { form.vendorCode = v.vendorCode; form.vendorName = v.vendorName }
}

async function onWorkorderSelected(row: any) {
  if (!row) return
  form.workorderId = row.workorderId
  form.workorderCode = row.workorderCode
  form.routeId = row.routeId || null
  form.processId = null
  form.processCode = ''
  form.processName = ''
  form.cardId = null
  form.issueLines = []
  processOptions.value = []
  loadCards(row.workorderId)
  // 工单联动：只展示该工单的外协工序，默认选中第一道并带出厂商与发料明细
  try {
    const res = await getOutsourceInfo(row.workorderCode)
    outsourceInfo.value = res.data || null
    processOptions.value = outsourceInfo.value?.outsourceProcesses || []
    if (processOptions.value.length > 0) {
      onProcessChange(processOptions.value[0].processId)
    }
  } catch (e) {
    outsourceInfo.value = null
  }
}

async function loadCards(workorderId: number) {
  cardOptions.value = []
  form.cardId = null
  try {
    const res = await listProcard({ workorderId, status: 'ACTIVE' })
    cardOptions.value = res.rows || []
  } catch (e) {}
}

function onCardChange(cardId: number) {
  const c = cardOptions.value.find((x: any) => x.cardId === cardId)
  if (c && c.routeId) form.routeId = c.routeId
}

function onProcessChange(processId: number) {
  const p = processOptions.value.find((x: any) => x.processId === processId)
  if (p) {
    form.processId = p.processId
    form.processCode = p.processCode
    form.processName = p.processName
    // 默认选中工单工序对应的供应商（路线工序配置的默认厂商）
    if (p.vendorId != null) {
      form.vendorId = p.vendorId
      form.vendorCode = p.vendorCode || ''
      form.vendorName = p.vendorName || ''
    }
    // 选工序时自动派生来源类型：分切工序→SLITTING，其余→GENERIC（后端 resolveSourceType 为权威）
    form.sourceType = p.processCode === 'SLITTING' ? 'SLITTING' : 'GENERIC'
    attrSchema.value = []
    // 发料明细默认填充：该工序 BOM 发料行；无 BOM 时不强制，可手动添加或发产品本身
    form.issueLines = (p.bomLines || []).map((b: any) => ({
      itemId: b.itemId, itemCode: b.itemCode, itemName: b.itemName,
      specification: b.specification,
      quantity: Number(b.quantity || 0),
      unitOfMeasure: b.unitOfMeasure || null, unitName: b.unitName || null,
      batchId: null, batchCode: null,
      warehouseId: null, warehouseCode: '', warehouseName: '',
      unitPrice: null, amount: null, _attrs: {}
    }))
    if (form.sourceType !== 'SLITTING') {
      getOutsourceProcessAttr(p.processId).then((r: any) => { attrSchema.value = r.data || [] }).catch(() => { attrSchema.value = [] })
    }
  } else {
    form.processId = null
    form.processCode = ''
    form.processName = ''
    form.sourceType = 'GENERIC'
  }
}

/** 发产品本身：工单产品（含在制半成品，如印刷后半成品）作为发料行，尚未入库也可发（后端自动虚拟入库） */
function addProductLine() {
  const info = outsourceInfo.value
  if (!info?.productId) return
  form.issueLines.push({
    itemId: info.productId, itemCode: info.productCode, itemName: info.productName,
    specification: info.productSpecification,
    quantity: Number(info.productQuantity || 0),
    unitOfMeasure: info.productUnitOfMeasure || null, unitName: info.productUnitName || null,
    batchId: null, batchCode: null,
    warehouseId: null, warehouseCode: '', warehouseName: '',
    unitPrice: null, amount: null, _attrs: {}
  })
}

function onItemSelected(row: any) {
  if (!row) return
  const line = form.issueLines[currentItemIdx.value]
  if (line) {
    line.itemId = row.itemId
    line.itemCode = row.itemCode
    line.itemName = row.itemName
    // 单位跟随物料主数据，与物料匹配
    line.unitOfMeasure = row.unitOfMeasure || line.unitOfMeasure || null
    line.unitName = row.unitName || (row.unitOfMeasure ? null : line.unitName)
  }
}

function onWarehouseSelected(row: any) {
  if (!row) return
  const line = form.issueLines[currentItemIdx.value]
  if (line) {
    line.warehouseId = row.warehouseId
    line.warehouseCode = row.warehouseCode
    line.warehouseName = row.warehouseName
  }
}

function addLine() {
  form.issueLines.push({ itemId: null, itemCode: '', itemName: '', quantity: 0, unitOfMeasure: null, unitName: null, batchId: null, warehouseId: null, warehouseCode: '', warehouseName: '', unitPrice: null, amount: null, _attrs: {} })
}

function removeLine(idx: number) {
  form.issueLines.splice(idx, 1)
}

async function submit() {
  if (!form.vendorId) { proxy.$modal.msgWarning('请选择外协厂商'); return }
  if (form.issueLines.length === 0) { proxy.$modal.msgWarning('请添加发料物料'); return }
  if (!form.issueLines.every(attrReady)) { proxy.$modal.msgWarning('请填写外协工序的必填工艺字段'); return }
  submitting.value = true
  try {
    const payload = {
      ...form,
      issueLines: form.issueLines.map((l: any) => {
        const { _attrs, ...rest } = l
        recalcAmount(rest)
        return { ...rest, extAttrs: JSON.stringify(_attrs || {}) }
      })
    }
    await createOutsource(payload)
    proxy.$modal.msgSuccess('外协发货成功')
    visible.value = false
    emit('success')
  } catch (e) {} finally { submitting.value = false }
}

function cancel() { visible.value = false; resetForm() }

defineExpose({ open })
</script>

<style scoped>
.mt8 { margin-top: 8px; }
.line-actions { display: flex; gap: 8px; }
</style>
