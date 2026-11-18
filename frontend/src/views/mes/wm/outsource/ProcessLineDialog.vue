<template>
  <el-dialog :model-value="modelValue" :title="readonly ? '加工单工序（只读）' : '加工单工序'" width="860px" append-to-body
             @update:model-value="v => emit('update:modelValue', v)" @open="init">
    <el-alert type="info" :closable="false" show-icon style="margin-bottom:12px"
              title="一张加工单可包含多道工序；展开每行填写该工序的扩展属性。" />
    <el-table :data="rows" size="small" border>
      <el-table-column type="expand" width="40">
        <template #default="{ row }">
          <OutsourceProcessAttrFields :schema="row.attrSchema || []" :model-value="ensureAttrs(row)" />
        </template>
      </el-table-column>
      <el-table-column label="序号" type="index" width="60" align="center" />
      <el-table-column label="工序" min-width="180">
        <template #default="{ row }">
          <el-select v-model="row.processId" filterable placeholder="选择工序" style="width:100%"
            :disabled="readonly" @change="onProcessChange(row)">
            <el-option v-for="p in processOptions" :key="p.processId" :label="p.processName" :value="p.processId" />
          </el-select>
        </template>
      </el-table-column>
      <el-table-column label="计划数量" width="130">
        <template #default="{ row }">
          <el-input-number v-model="row.planQty" :min="0" :precision="4" controls-position="right"
            size="small" style="width:100%" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="完成数量" width="130">
        <template #default="{ row }">
          <el-input-number v-model="row.doneQty" :min="0" :precision="4" controls-position="right"
            size="small" style="width:100%" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="备注" min-width="120">
        <template #default="{ row }"><el-input v-model="row.remark" size="small" :disabled="readonly" /></template>
      </el-table-column>
      <el-table-column label="操作" width="70" align="center" v-if="!readonly">
        <template #default="{ $index }">
          <el-button link type="danger" icon="Delete" @click="rows.splice($index, 1)" />
        </template>
      </el-table-column>
    </el-table>
    <div style="margin-top:10px" v-if="!readonly">
      <el-button plain icon="Plus" size="small" @click="addRow">新增工序</el-button>
    </div>
    <template #footer>
      <el-button @click="emit('update:modelValue', false)">{{ readonly ? '关 闭' : '取 消' }}</el-button>
      <el-button v-if="!readonly" type="primary" :loading="saving" @click="save">保存</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { getProcessLines, saveProcessLines } from '@/api/mes/wm/outsource'
import { getWorkorderProcessInfo } from '@/api/mes/pro/workorder'
import { listAllProcess } from '@/api/mes/pro/process'
import OutsourceProcessAttrFields from './components/OutsourceProcessAttrFields.vue'

const props = defineProps<{ modelValue: boolean; orderId?: number; workorderId?: number; status?: string }>()
const emit = defineEmits(['update:modelValue', 'success'])

const rows = ref<any[]>([])
const processOptions = ref<any[]>([])
const saving = ref(false)
const readonly = ref(false)

function ensureAttrs(row: any) {
  if (!row._attrs) {
    try { row._attrs = row.extAttrs ? JSON.parse(row.extAttrs) : {} } catch { row._attrs = {} }
  }
  return row._attrs
}

async function init() {
  if (!props.orderId) return
  readonly.value = !!props.status && props.status !== 'DRAFT'
  await loadProcessOptions()
  getProcessLines(props.orderId).then((r: any) => {
    rows.value = (r.data || []).map((x: any) => {
      const row: any = { ...x, _attrs: {} }
      try { row._attrs = x.extAttrs ? JSON.parse(x.extAttrs) : {} } catch { row._attrs = {} }
      row.attrSchema = processOptions.value.find((p: any) => p.processId === x.processId)?.attrSchema || []
      return row
    })
  }).catch(() => { rows.value = [] })
}

/** 工序下拉：优先工单路线全部工序（含扩展属性模板），无工单时回退全量工序 */
async function loadProcessOptions() {
  processOptions.value = []
  if (props.workorderId) {
    try {
      const r: any = await getWorkorderProcessInfo(props.workorderId)
      processOptions.value = r.data?.processes || []
      return
    } catch (e) { /* 回退全量工序 */ }
  }
  const r: any = await listAllProcess().catch(() => null)
  processOptions.value = (r?.data || r?.rows || []).map((p: any) => ({ ...p, attrSchema: [] }))
}

function addRow() {
  rows.value.push({
    processId: null, processCode: null, processName: null,
    planQty: 0, doneQty: 0, remark: '', attrSchema: [], _attrs: {}
  })
}

function onProcessChange(row: any) {
  const p = processOptions.value.find(x => x.processId === row.processId)
  if (p) {
    row.processCode = p.processCode
    row.processName = p.processName
    row.attrSchema = p.attrSchema || []
    row._attrs = {}
  }
}

async function save() {
  if (!props.orderId) return
  if (rows.value.some(r => !r.processId)) { ElMessage.warning('请选择工序'); return }
  saving.value = true
  try {
    const payload = rows.value.map((r: any) => ({
      processId: r.processId, processCode: r.processCode, processName: r.processName,
      planQty: r.planQty, doneQty: r.doneQty, remark: r.remark,
      extAttrs: JSON.stringify(r._attrs || {})
    }))
    await saveProcessLines(props.orderId, payload)
    ElMessage.success('工序已保存')
    emit('success')
    emit('update:modelValue', false)
  } catch (e) {
    // 拦截器已提示
  } finally {
    saving.value = false
  }
}
</script>
