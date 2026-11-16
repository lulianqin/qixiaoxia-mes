<template>
  <el-dialog :model-value="modelValue" title="加工单工序" width="760px" append-to-body
             @update:model-value="v => emit('update:modelValue', v)" @open="init">
    <el-alert type="info" :closable="false" show-icon style="margin-bottom:12px"
              title="一张加工单可包含多道工序；工序属性模板仍按各自工序取值。" />
    <el-table :data="rows" size="small" border>
      <el-table-column label="序号" type="index" width="60" align="center" />
      <el-table-column label="工序" min-width="180">
        <template #default="{ row }">
          <el-select v-model="row.processId" filterable placeholder="选择工序" style="width:100%" @change="onProcessChange(row)">
            <el-option v-for="p in processOptions" :key="p.processId" :label="p.processName" :value="p.processId" />
          </el-select>
        </template>
      </el-table-column>
      <el-table-column label="计划数量" width="140">
        <template #default="{ row }">
          <el-input-number v-model="row.planQty" :min="0" :precision="4" controls-position="right" size="small" style="width:100%" />
        </template>
      </el-table-column>
      <el-table-column label="完成数量" width="140">
        <template #default="{ row }">
          <el-input-number v-model="row.doneQty" :min="0" :precision="4" controls-position="right" size="small" style="width:100%" />
        </template>
      </el-table-column>
      <el-table-column label="备注" min-width="140">
        <template #default="{ row }"><el-input v-model="row.remark" size="small" /></template>
      </el-table-column>
      <el-table-column label="操作" width="70" align="center">
        <template #default="{ $index }">
          <el-button link type="danger" icon="Delete" @click="rows.splice($index, 1)" />
        </template>
      </el-table-column>
    </el-table>
    <div style="margin-top:10px">
      <el-button plain icon="Plus" size="small" @click="addRow">新增工序</el-button>
    </div>
    <template #footer>
      <el-button @click="emit('update:modelValue', false)">取消</el-button>
      <el-button type="primary" :loading="saving" @click="save">保存</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { getProcessLines, saveProcessLines } from '@/api/mes/wm/outsource'
import { listAllProcess } from '@/api/mes/pro/process'

const props = defineProps<{ modelValue: boolean; orderId?: number }>()
const emit = defineEmits(['update:modelValue', 'success'])

const rows = ref<any[]>([])
const processOptions = ref<any[]>([])
const saving = ref(false)

function init() {
  if (!props.orderId) return
  listAllProcess().then((r: any) => { processOptions.value = r.data || r.rows || [] }).catch(() => {})
  getProcessLines(props.orderId).then((r: any) => {
    rows.value = (r.data || []).map((x: any) => ({ ...x }))
  }).catch(() => { rows.value = [] })
}

function addRow() {
  rows.value.push({ processId: null, processCode: null, processName: null, planQty: 0, doneQty: 0, remark: '' })
}

function onProcessChange(row: any) {
  const p = processOptions.value.find(x => x.processId === row.processId)
  if (p) { row.processCode = p.processCode; row.processName = p.processName }
}

async function save() {
  if (!props.orderId) return
  saving.value = true
  try {
    await saveProcessLines(props.orderId, rows.value)
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
