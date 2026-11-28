<template>
  <div>
    <el-form :model="form" label-width="140px">
      <el-row>
        <el-col :span="8"><el-form-item label="生产日期"><el-switch v-model="form.produceDateFlag" active-value="1" inactive-value="0" /></el-form-item></el-col>
        <el-col :span="8"><el-form-item label="有效期"><el-switch v-model="form.expireDateFlag" active-value="1" inactive-value="0" /></el-form-item></el-col>
        <el-col :span="8"><el-form-item label="入库日期"><el-switch v-model="form.recptDateFlag" active-value="1" inactive-value="0" /></el-form-item></el-col>
      </el-row>
      <el-row>
        <el-col :span="8"><el-form-item label="供应商"><el-switch v-model="form.vendorFlag" active-value="1" inactive-value="0" /></el-form-item></el-col>
        <el-col :span="8"><el-form-item label="生产工单"><el-switch v-model="form.workorderFlag" active-value="1" inactive-value="0" /></el-form-item></el-col>
        <el-col :span="8"><el-form-item label="生产批号"><el-switch v-model="form.lotNumberFlag" active-value="1" inactive-value="0" /></el-form-item></el-col>
      </el-row>
      <el-row>
        <el-col :span="8"><el-form-item label="质量状态"><el-switch v-model="form.qualityStatusFlag" active-value="1" inactive-value="0" /></el-form-item></el-col>
        <el-col :span="10">
          <el-form-item label="逐实物管理">
            <el-switch v-model="form.instanceFlag" active-value="1" inactive-value="0" />
            <span class="inst-tip">开启后按辅助单位（卷/根/桶）逐件登记收发，库存辅助数量=在库件数</span>
          </el-form-item>
        </el-col>
      </el-row>
      <!-- 仅保留 qxx_wm_batch 有对应列的批次属性，无落库字段的属性已移除 -->
      <!-- 批次配置随物料编辑弹窗的【确认】统一保存，不再单独提供保存按钮 -->
    </el-form>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, toRefs } from 'vue'
import { getCurrentInstance } from 'vue'
import type { MdItemBatchConfig } from '@/types/api/mes/md/batchconfig'
import { getBatchConfigByItemId, addBatchConfig, updateBatchConfig } from '@/api/mes/md/batchconfig'

const props = defineProps<{ itemId: number }>()
const { proxy } = getCurrentInstance() as any

/** 默认配置：仅包含 qxx_wm_batch 有对应列的批次属性 */
function emptyForm(itemId: number): MdItemBatchConfig {
  return {
    itemId,
    produceDateFlag: '0', expireDateFlag: '0', recptDateFlag: '0',
    vendorFlag: '0', workorderFlag: '0', lotNumberFlag: '0',
    qualityStatusFlag: '0', instanceFlag: '0', enableFlag: '1'
  } as MdItemBatchConfig
}

const data = reactive({
  form: emptyForm(props.itemId)
})

const { form } = toRefs(data)

async function load(itemId: number) {
  try {
    const r = await getBatchConfigByItemId(itemId)
    form.value = r.data || { configId: undefined, ...emptyForm(itemId) }
  } catch (e) { /* ignore */ }
}

async function save(silent = true) {
  if (form.value.configId) {
    await updateBatchConfig(form.value)
  } else {
    await addBatchConfig(form.value)
  }
  if (!silent) proxy.$modal.msgSuccess('批次配置保存成功')
}

defineExpose({ load, save })
</script>

<style scoped>
.inst-tip {
  margin-left: 10px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
  line-height: 1.4;
}
</style>
