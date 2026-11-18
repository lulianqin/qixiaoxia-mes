<template>
  <div>
    <el-table :data="modelValue" size="small" border row-key="processId" @selection-change="onSelectionChange">
      <el-table-column type="selection" width="45" />
      <el-table-column type="expand" width="40">
        <template #default="{ row }">
          <OutsourceProcessAttrFields :schema="row.attrSchema || []" :model-value="ensureAttrs(row)" />
        </template>
      </el-table-column>
      <el-table-column label="工序" min-width="200">
        <template #default="{ row }">
          <el-select v-model="row.processId" filterable placeholder="选择工序" style="width:100%"
            :disabled="readonly" @change="onProcessChange(row)">
            <el-option v-for="p in processOptions" :key="p.processId" :value="p.processId"
              :label="p.processName + (p.isOutsource === '1' ? '（外协）' : '')"
              :disabled="!!p.existingOrderCode && p.processId !== row.processId">
              <span>{{ p.processName }}{{ p.isOutsource === '1' ? '（外协）' : '' }}</span>
              <el-tag v-if="p.existingOrderCode" size="small" type="info" style="margin-left:6px">
                已有加工单
              </el-tag>
            </el-option>
          </el-select>
        </template>
      </el-table-column>
      <el-table-column label="计划数量" width="140">
        <template #default="{ row }">
          <el-input-number v-model="row.planQty" :min="0" :precision="4" controls-position="right"
            size="small" style="width:100%" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="备注" min-width="140">
        <template #default="{ row }">
          <el-input v-model="row.remark" size="small" :disabled="readonly" />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="70" align="center">
        <template #default="{ $index }">
          <el-button v-if="!readonly" link type="danger" icon="Delete" @click="removeRow($index)" />
        </template>
      </el-table-column>
    </el-table>
    <div style="margin-top:10px" v-if="!readonly">
      <el-button plain icon="Plus" size="small" @click="addRow">新增工序</el-button>
      <span class="tip">展开行可填写该工序的扩展属性；已有加工单的工序不可重复选择</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import OutsourceProcessAttrFields from './OutsourceProcessAttrFields.vue'

const props = defineProps<{ modelValue: any[]; processOptions: any[]; readonly?: boolean }>()
const emit = defineEmits<{ (e: 'update:modelValue', v: any[]): void; (e: 'selection-change', v: any[]): void; (e: 'process-change', row: any): void }>()

function ensureAttrs(row: any) {
  if (!row._attrs) row._attrs = {}
  return row._attrs
}

function addRow() {
  props.modelValue.push({
    processId: null, processCode: null, processName: null,
    planQty: 0, doneQty: 0, remark: '', attrSchema: [], _attrs: {}
  })
  emit('update:modelValue', props.modelValue)
}

function removeRow(index: number) {
  props.modelValue.splice(index, 1)
  emit('update:modelValue', props.modelValue)
}

function onProcessChange(row: any) {
  const p = props.processOptions.find(x => x.processId === row.processId)
  if (p) {
    row.processCode = p.processCode
    row.processName = p.processName
    row.attrSchema = p.attrSchema || []
    row._attrs = {}
  }
  emit('process-change', row)
}

function onSelectionChange(rows: any[]) {
  emit('selection-change', rows)
}
</script>

<style scoped>
.tip { color: #909399; font-size: 12px; margin-left: 8px; }
</style>
