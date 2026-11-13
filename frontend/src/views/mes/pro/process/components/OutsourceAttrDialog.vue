<template>
  <el-dialog v-model="visible" :title="'外协字段模板 - ' + (processName || '')" width="760px" append-to-body @close="cancel">
    <el-alert title="勾选该工序外协发货明细需要填写的字段；分切工序保留原规格逻辑，不强制模板" type="info" :closable="false" show-icon style="margin-bottom:12px" />
    <el-table v-loading="loading" :data="rows" border size="small" max-height="420">
      <el-table-column label="启用" width="60" align="center">
        <template #default="{ row }"><el-checkbox v-model="row.checked" /></template>
      </el-table-column>
      <el-table-column label="字段名称" prop="attrName" min-width="140" :show-overflow-tooltip="true" />
      <el-table-column label="字段编码" prop="attrCode" width="140" :show-overflow-tooltip="true" />
      <el-table-column label="类型" prop="attrType" width="90" align="center" />
      <el-table-column label="单位" prop="attrUnit" width="80" align="center" />
      <el-table-column label="必填" width="80" align="center">
        <template #default="{ row }">
          <el-switch v-model="row.required" active-value="1" inactive-value="0" :disabled="!row.checked" />
        </template>
      </el-table-column>
      <el-table-column label="排序" width="90" align="center">
        <template #default="{ row }">
          <el-input-number v-model="row.sortOrder" :min="0" :controls="false" size="small" :disabled="!row.checked" style="width:100%" />
        </template>
      </el-table-column>
    </el-table>
    <template #footer>
      <el-button type="primary" :loading="saving" @click="save">保 存</el-button>
      <el-button @click="visible = false">取 消</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { listAttrDef } from '@/api/mes/md/attr'
import { getOutsourceProcessAttr, saveOutsourceProcessAttr } from '@/api/mes/wm/outsourceProcessAttr'

const visible = ref(false)
const loading = ref(false)
const saving = ref(false)
const processId = ref<number | null>(null)
const processName = ref('')
const rows = ref<any[]>([])

async function open(row: any) {
  processId.value = row.processId
  processName.value = row.processName || row.processCode || ''
  visible.value = true
  loading.value = true
  try {
    const [defRes, bindRes]: any = await Promise.all([
      listAttrDef({ pageSize: 999 } as any),
      getOutsourceProcessAttr(row.processId)
    ])
    const bound = new Map<number, any>((bindRes.data || []).map((b: any) => [b.attrId, b]))
    rows.value = (defRes.rows || []).map((d: any) => {
      const b = bound.get(d.attrId)
      return {
        attrId: d.attrId,
        attrCode: d.attrCode,
        attrName: d.attrName,
        attrType: d.attrType,
        attrUnit: d.attrUnit,
        checked: !!b,
        required: b?.required || '0',
        sortOrder: b?.sortOrder ?? d.sortOrder ?? 0
      }
    })
  } catch {
    rows.value = []
  } finally {
    loading.value = false
  }
}

function save() {
  if (!processId.value) return
  saving.value = true
  const data = rows.value
    .filter((r: any) => r.checked)
    .map((r: any, i: number) => ({ attrId: r.attrId, required: r.required, sortOrder: r.sortOrder ?? i + 1 }))
  saveOutsourceProcessAttr(processId.value, data).then(() => {
    ElMessage.success('保存成功')
    visible.value = false
  }).finally(() => { saving.value = false })
}

function cancel() { visible.value = false; rows.value = [] }

defineExpose({ open })
</script>
