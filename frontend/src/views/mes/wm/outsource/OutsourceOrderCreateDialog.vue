<template>
  <el-dialog v-model="visible" title="新增加工单" width="1150px" :close-on-click-modal="false"
    append-to-body @open="load" @close="reset">
    <el-form label-width="100px" size="small">
      <el-row>
        <el-col :span="8">
          <el-form-item label="生产工单">
            <el-input :model-value="info.workorderCode" readonly placeholder="看板带入" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="加工类型">
            <el-radio-group v-model="form.supplierType" @change="onSupplierTypeChange">
              <el-radio value="OUTSIDE">外协加工</el-radio>
              <el-radio value="INSIDE">厂内加工</el-radio>
            </el-radio-group>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="外协厂商" :required="form.supplierType === 'OUTSIDE'">
            <el-select v-model="form.vendorId" placeholder="请选择外协厂商" filterable clearable
              style="width:100%" :disabled="form.supplierType === 'INSIDE'" @change="onVendorChange">
              <el-option v-for="v in vendorOptions" :key="v.vendorId" :label="v.vendorName" :value="v.vendorId" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="8">
          <el-form-item label="流转卡">
            <el-select v-model="form.cardId" placeholder="可选" filterable clearable style="width:100%">
              <el-option v-for="c in cardOptions" :key="c.cardId" :label="c.cardCode" :value="c.cardId" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="来源类型">
            <el-select v-model="form.sourceType" placeholder="请选择" style="width:100%">
              <el-option v-for="d in (mes_outsource_type || [])" :key="d.value" :label="d.label" :value="d.value" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="备注">
            <el-input v-model="form.remark" placeholder="备注" maxlength="500" />
          </el-form-item>
        </el-col>
      </el-row>
    </el-form>

    <el-divider content-position="left">工序明细</el-divider>
    <OutsourceProcessLineEditor :model-value="form.processLines" :process-options="processOptions"
      @selection-change="rows => selectedProcessRows = rows" @process-change="onProcessChange" />

    <el-divider content-position="left">发料明细</el-divider>
    <OutsourceIssueEditor ref="issueRef" :rows="form.issueLines" :product="info"
      :product-bom-lines="productBomLines" :process-bom-lines="selectedProcessBomLines" />

    <template #footer>
      <el-button @click="visible = false">取 消</el-button>
      <el-button type="primary" :loading="submitting" @click="submit">保存草稿</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch, getCurrentInstance } from 'vue'
import { createOutsource } from '@/api/mes/wm/outsource'
import { getWorkorderProcessInfo } from '@/api/mes/pro/workorder'
import { listBomByWorkorderId } from '@/api/mes/pro/workorderbom'
import { listAllVendor } from '@/api/mes/md/vendor'
import { listProcard } from '@/api/mes/pro/procard'
import OutsourceProcessLineEditor from './components/OutsourceProcessLineEditor.vue'
import OutsourceIssueEditor from './components/OutsourceIssueEditor.vue'

const props = defineProps<{ modelValue: boolean; workorderId: number | null }>()
const emit = defineEmits(['update:modelValue', 'success'])

const { proxy } = getCurrentInstance() as any
const { mes_outsource_type } = proxy.useDict('mes_outsource_type')

const visible = ref(false)
const submitting = ref(false)
const info = ref<any>({})
const processOptions = ref<any[]>([])
const vendorOptions = ref<any[]>([])
const cardOptions = ref<any[]>([])
const productBomLines = ref<any[]>([])
const selectedProcessRows = ref<any[]>([])
const issueRef = ref()

const form = reactive<any>({
  supplierType: 'OUTSIDE', vendorId: null, vendorCode: '', vendorName: '',
  routeId: null, cardId: null, sourceType: 'GENERIC', remark: '',
  processLines: [], issueLines: []
})

watch(() => props.modelValue, (v: boolean) => { visible.value = v })
watch(visible, (v: boolean) => { emit('update:modelValue', v) })

const selectedProcessBomLines = computed(() => {
  const rows = selectedProcessRows.value.length ? selectedProcessRows.value : form.processLines
  return rows.flatMap((r: any) => r.bomLines || [])
})

function reset() {
  Object.assign(form, {
    supplierType: 'OUTSIDE', vendorId: null, vendorCode: '', vendorName: '',
    routeId: null, cardId: null, sourceType: 'GENERIC', remark: '',
    processLines: [], issueLines: []
  })
  info.value = {}
  processOptions.value = []
  cardOptions.value = []
  productBomLines.value = []
  selectedProcessRows.value = []
}

function open() { visible.value = true }

async function load() {
  reset()
  if (!props.workorderId) return
  await Promise.all([loadProcessInfo(), loadVendors()])
}

async function loadProcessInfo() {
  try {
    const r: any = await getWorkorderProcessInfo(props.workorderId as number)
    info.value = r.data || {}
    form.routeId = info.value.routeId || null
    form.cardId = info.value.activeCardId || null
    processOptions.value = info.value.processes || []
    loadCards()
    listBomByWorkorderId(props.workorderId as number).then((res: any) => {
      productBomLines.value = (res.data || res.rows || []).filter((b: any) => !b.processId)
    }).catch(() => { productBomLines.value = [] })
    // 默认带出第一道未建单的工序
    const first = processOptions.value.find((p: any) => !p.existingOrderCode)
    if (first) addProcessRow(first)
  } catch (e) { /* 拦截器已提示 */ }
}

async function loadVendors() {
  if (vendorOptions.value.length) return
  try {
    const res: any = await listAllVendor()
    vendorOptions.value = (res.data || []).filter((v: any) => v.vendorType === 'OUTSOURCE' || v.vendorType === 'BOTH')
  } catch (e) { vendorOptions.value = [] }
}

async function loadCards() {
  try {
    const res: any = await listProcard({ workorderId: props.workorderId, status: 'ACTIVE' })
    cardOptions.value = res.rows || []
  } catch (e) { cardOptions.value = [] }
}

function addProcessRow(p: any) {
  const row = {
    processId: p.processId, processCode: p.processCode, processName: p.processName,
    planQty: Number(info.value.productQuantity || 0), doneQty: 0, remark: '',
    bomLines: p.bomLines || [], attrSchema: p.attrSchema || [], _attrs: {}
  }
  form.processLines.push(row)
  onProcessChange(row)
}

function onSupplierTypeChange() {
  if (form.supplierType === 'INSIDE') {
    form.vendorId = null
    form.vendorCode = ''
    form.vendorName = ''
  }
}

function onVendorChange(vendorId: number) {
  const v = vendorOptions.value.find(x => x.vendorId === vendorId)
  form.vendorCode = v?.vendorCode || ''
  form.vendorName = v?.vendorName || ''
}

/** 选中工序后，默认把该工序 BOM 加入发料明细 */
function onProcessChange(row: any) {
  ;(row.bomLines || []).forEach((b: any) => issueRef.value?.addItemLine(b, Number(b.quantity || 0)))
}

function validate(): boolean {
  if (!props.workorderId) { proxy.$modal.msgWarning('缺少生产工单'); return false }
  if (form.supplierType === 'OUTSIDE' && !form.vendorId) {
    proxy.$modal.msgWarning('外协加工请选择外协厂商')
    return false
  }
  if (!form.processLines.length || form.processLines.some((r: any) => !r.processId)) {
    proxy.$modal.msgWarning('请至少添加一道工序')
    return false
  }
  const processes = new Set<number>()
  for (const r of form.processLines) {
    if (processes.has(r.processId)) { proxy.$modal.msgWarning('工序不能重复添加'); return false }
    processes.add(r.processId)
  }
  if (!form.issueLines.length || form.issueLines.some((l: any) => !l.itemId || Number(l.quantity) <= 0)) {
    proxy.$modal.msgWarning('请完善发料明细（可点击「发产品本身」快速补充）')
    return false
  }
  return true
}

function buildPayload() {
  return {
    supplierType: form.supplierType,
    vendorId: form.vendorId,
    vendorCode: form.vendorCode,
    vendorName: form.vendorName,
    workorderId: props.workorderId,
    workorderCode: info.value.workorderCode,
    routeId: form.routeId,
    cardId: form.cardId,
    sourceType: form.sourceType,
    remark: form.remark,
    draft: true,
    processLines: form.processLines.map((r: any) => ({
      processId: r.processId, processCode: r.processCode, processName: r.processName,
      planQty: r.planQty, doneQty: 0, remark: r.remark,
      extAttrs: JSON.stringify(r._attrs || {})
    })),
    issueLines: form.issueLines.map((l: any) => {
      const amount = l.unitPrice != null && l.quantity != null
        ? Number((Number(l.quantity) * Number(l.unitPrice)).toFixed(2)) : null
      return {
        itemId: l.itemId, itemCode: l.itemCode, itemName: l.itemName,
        specification: l.specification, quantity: l.quantity,
        unitOfMeasure: l.unitOfMeasure, unitName: l.unitName,
        batchId: l.batchId, warehouseId: l.warehouseId,
        warehouseCode: l.warehouseCode, warehouseName: l.warehouseName,
        unitPrice: l.unitPrice, amount
      }
    })
  }
}

async function submit() {
  if (!validate()) return
  submitting.value = true
  try {
    await createOutsource(buildPayload())
    proxy.$modal.msgSuccess('已保存为草稿，请在加工单列表执行发料')
    visible.value = false
    emit('success')
  } catch (e) { /* 拦截器已提示 */ } finally { submitting.value = false }
}

defineExpose({ open })
</script>
