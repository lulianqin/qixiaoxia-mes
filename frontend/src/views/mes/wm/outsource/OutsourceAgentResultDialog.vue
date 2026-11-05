<template>
  <el-dialog v-model="visible" title="代厂商录入加工结果" width="900px" :close-on-click-modal="false" append-to-body @close="cancel">
    <el-form label-width="100px">
      <el-row>
        <el-col :span="8">
          <el-form-item label="外协单号">{{ order?.orderCode || '-' }}</el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="外协厂商">{{ order?.vendorName || '-' }}</el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="工序">{{ order?.processName || '-' }}</el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="12">
          <el-form-item label="发料明细">
            <span v-for="(l, i) in (order?.issueLines || [])" :key="i">
              {{ l.itemName }} × {{ l.quantity }}{{ l.unitName }}<span v-if="i < (order?.issueLines?.length || 0) - 1">；</span>
            </span>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="已录/应录">{{ order?.recptTotalQty || 0 }} / {{ order?.issueTotalQty || 0 }}</el-form-item>
        </el-col>
      </el-row>

      <el-divider content-position="left">本次产出明细</el-divider>
      <el-table :data="resultLines" border size="small" max-height="320">
        <el-table-column label="序号" type="index" width="60" align="center" />
        <el-table-column v-if="isSlitting" label="门幅(mm)" width="120" align="center">
          <template #default="{ row }">
            <el-input-number v-model="row.width" :min="0" :precision="0" size="small" style="width: 100%" />
          </template>
        </el-table-column>
        <el-table-column v-if="isSlitting" label="克重(g)" width="120" align="center">
          <template #default="{ row }">
            <el-input-number v-model="row.gsm" :min="0" :precision="0" size="small" style="width: 100%" />
          </template>
        </el-table-column>
        <el-table-column label="数量" width="140" align="center">
          <template #default="{ row }">
            <el-input-number v-model="row.quantity" :min="0" :precision="4" size="small" style="width: 100%" />
          </template>
        </el-table-column>
        <el-table-column label="生产批号" width="140" align="center">
          <template #default="{ row }">
            <el-input v-model="row.lotNumber" size="small" placeholder="选填" />
          </template>
        </el-table-column>
        <el-table-column label="生产日期" width="180" align="center">
          <template #default="{ row }">
            <el-date-picker v-model="row.produceDate" type="date" value-format="YYYY-MM-DD" size="small" placeholder="选填" style="width: 100%" />
          </template>
        </el-table-column>
        <el-table-column label="有效期" width="150" align="center">
          <template #default="{ row }">
            <el-date-picker v-model="row.expireDate" type="date" value-format="YYYY-MM-DD" size="small" placeholder="选填" style="width: 100%" />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="60" align="center">
          <template #default="{ $index }">
            <el-button link type="danger" size="small" icon="Delete" @click="removeLine($index)" />
          </template>
        </el-table-column>
      </el-table>
      <el-button type="primary" plain icon="Plus" size="small" class="mt8" @click="addLine">添加一行</el-button>
      <el-alert v-if="overReceipt" type="warning" :closable="false" show-icon class="mt8"
        title="本次录入累计量将超过发料量，提交会被拒绝" />
    </el-form>

    <template #footer>
      <el-button @click="cancel">取 消</el-button>
      <el-button type="primary" :loading="submitting" :disabled="!canSubmit" @click="submit">提交加工结果</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { computed, getCurrentInstance, ref } from 'vue'
import { recordOutsourceResult } from '@/api/mes/wm/outsource'
import type { OutsourceAgentOrder } from './types'

interface ResultLine {
  width?: number
  gsm?: number
  quantity?: number
  lotNumber?: string
  produceDate?: string
  expireDate?: string
}

const { proxy } = getCurrentInstance() as any
const emit = defineEmits<{ success: [] }>()
const visible = ref(false)
const submitting = ref(false)
const order = ref<OutsourceAgentOrder | null>(null)
const resultLines = ref<ResultLine[]>([])

const isSlitting = computed(() => order.value?.sourceType === 'SLITTING')
const overReceipt = computed(() => {
  if (!order.value || resultLines.value.length === 0) return false
  const issueQty = Number(order.value.issueTotalQty) || 0
  const already = Number(order.value.recptTotalQty) || 0
  const adding = resultLines.value.reduce((sum, l) => sum + (Number(l.quantity) || 0), 0)
  return already + adding > issueQty
})
const canSubmit = computed(() => {
  if (resultLines.value.length === 0 || overReceipt.value) return false
  return resultLines.value.every(l => {
    if (!l.quantity || Number(l.quantity) <= 0) return false
    if (isSlitting.value) {
      if (!l.width || Number(l.width) <= 0) return false
      if (!l.gsm || Number(l.gsm) <= 0) return false
    }
    return true
  })
})

function open(row: OutsourceAgentOrder) {
  order.value = row
  resultLines.value = []
  visible.value = true
}

function addLine() {
  resultLines.value.push({ quantity: undefined, lotNumber: '', produceDate: '', expireDate: '' })
}

function removeLine(index: number) {
  resultLines.value.splice(index, 1)
}

function cancel() {
  visible.value = false
  order.value = null
  resultLines.value = []
}

async function submit() {
  if (!order.value || !canSubmit.value) return
  submitting.value = true
  try {
    const payload = resultLines.value.map(l => {
      const line: Record<string, unknown> = { quantity: Number(l.quantity) }
      if (isSlitting.value) line.extAttrs = JSON.stringify({ width: Number(l.width) || 0, gsm: Number(l.gsm) || 0 })
      if (l.lotNumber) line.lotNumber = l.lotNumber
      if (l.produceDate) line.produceDate = l.produceDate
      if (l.expireDate) line.expireDate = l.expireDate
      return line
    })
    await recordOutsourceResult(order.value.orderId, payload)
    proxy.$modal.msgSuccess('加工结果已提交，可继续补录或点「完成」')
    visible.value = false
    emit('success')
  } finally {
    submitting.value = false
  }
}

defineExpose({ open })
</script>

<style scoped>
:deep(.el-form-item__label) { padding-right: 16px !important; }
.mt8 { margin-top: 8px; }
</style>
