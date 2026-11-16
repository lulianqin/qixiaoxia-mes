<template>
  <el-dialog :model-value="modelValue" title="库存 Excel 导入" width="640px" append-to-body
             @update:model-value="v => emit('update:modelValue', v)" @open="init">
    <el-alert type="info" :closable="false" show-icon style="margin-bottom:12px"
              title="覆盖导入：以 Excel 的「剩余数量」置为系统库存；单位与换算率取自物料档案，物料匹配不到会按所选分类自动建档。" />
    <el-form label-width="90px" size="small">
      <el-form-item label="物料分类" required>
        <el-tree-select v-model="itemTypeId" :data="itemTypeTree" check-strictly node-key="id"
                        :props="{ value: 'id', label: 'label', children: 'children' }"
                        placeholder="请选择分类" clearable style="width:100%" />
      </el-form-item>
      <el-form-item label="仓库" required>
        <el-select v-model="warehouseId" filterable style="width:100%" placeholder="请选择">
          <el-option v-for="w in warehouseOptions" :key="w.warehouseId" :label="w.warehouseName" :value="w.warehouseId" />
        </el-select>
      </el-form-item>
      <el-form-item label="供应商">
        <el-select v-model="vendorId" filterable clearable style="width:100%" placeholder="外采/来料可选">
          <el-option v-for="v in vendorOptions" :key="v.vendorId" :label="v.vendorName" :value="v.vendorId" />
        </el-select>
      </el-form-item>
      <el-form-item label="客户">
        <el-select v-model="clientId" filterable clearable style="width:100%" placeholder="订单成品可选">
          <el-option v-for="c in clientOptions" :key="c.clientId" :label="c.clientName" :value="c.clientId" />
        </el-select>
      </el-form-item>
      <el-form-item label="模板">
        <el-button link type="primary" @click="downloadStockTemplate('RAW')">下载物料类模板</el-button>
        <el-button link type="primary" @click="downloadStockTemplate('PRODUCT')">下载成品模板</el-button>
      </el-form-item>
      <el-form-item label="Excel 文件" required>
        <el-upload ref="uploadRef" :auto-upload="false" :limit="1" accept=".xlsx,.xls"
                   :on-change="onFileChange" :on-remove="() => (file = null)">
          <el-button icon="Upload">选择文件</el-button>
        </el-upload>
      </el-form-item>
    </el-form>

    <div v-if="result" class="import-result">
      <el-divider content-position="left">导入结果</el-divider>
      <p>批次号：{{ result.importBatchNo }}</p>
      <p>成功 <b>{{ result.successCount }}</b> 条，跳过 {{ result.skipCount }} 条，自动新建物料 <b>{{ result.createdItemCount }}</b> 条</p>
      <el-alert v-if="result.errors && result.errors.length" type="error" :closable="false"
                :title="`失败 ${result.errors.length} 条`">
        <div v-for="(e, i) in result.errors" :key="i">{{ e }}</div>
      </el-alert>
    </div>

    <template #footer>
      <el-button @click="emit('update:modelValue', false)">关闭</el-button>
      <el-button type="primary" :loading="uploading" @click="submit">开始导入</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { importMaterialStock, downloadStockTemplate } from '@/api/mes/wm/material_stock'
import { treeselect } from '@/api/mes/md/itemtype'
import { listAllVendor } from '@/api/mes/md/vendor'
import { listAllClient } from '@/api/mes/md/client'
import type { TreeSelect } from '@/types'

const props = defineProps<{
  modelValue: boolean
  warehouseOptions: any[]
}>()
const emit = defineEmits(['update:modelValue', 'success'])

const uploadRef = ref()
const itemTypeId = ref<number>()
const warehouseId = ref<number>()
const vendorId = ref<number>()
const clientId = ref<number>()
const itemTypeTree = ref<TreeSelect[]>([])
const vendorOptions = ref<any[]>([])
const clientOptions = ref<any[]>([])
const file = ref<File | null>(null)
const uploading = ref(false)
const result = ref<any>(null)

function init() {
  result.value = null
  file.value = null
  uploadRef.value?.clearFiles()
  treeselect().then(r => { itemTypeTree.value = r.data || [] }).catch(() => {})
  listAllVendor().then((r: any) => { vendorOptions.value = r.data || r.rows || [] }).catch(() => {})
  listAllClient().then((r: any) => { clientOptions.value = r.data || r.rows || [] }).catch(() => {})
}

function onFileChange(f: any) {
  file.value = f.raw
}

async function submit() {
  if (!file.value) return ElMessage.warning('请选择 Excel 文件')
  if (!itemTypeId.value) return ElMessage.warning('请选择物料分类')
  if (!warehouseId.value) return ElMessage.warning('请选择仓库')
  uploading.value = true
  try {
    const res: any = await importMaterialStock(file.value, itemTypeId.value, warehouseId.value,
      vendorId.value, clientId.value)
    result.value = res.data
    ElMessage.success('导入完成')
    emit('success')
  } catch (e) {
    // 拦截器已提示
  } finally {
    uploading.value = false
  }
}
</script>

<style scoped>
.import-result { font-size: 13px; color: #606266; }
.import-result p { margin: 6px 0; }
</style>
