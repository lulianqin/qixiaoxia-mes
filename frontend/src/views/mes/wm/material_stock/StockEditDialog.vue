<template>
  <el-dialog :model-value="modelValue" :title="isEdit ? '编辑库存' : '新增库存'" width="820px" append-to-body
             @update:model-value="v => emit('update:modelValue', v)" @open="init">
    <el-form ref="formRef" :model="form" :rules="rules" label-width="110px" size="small">
      <el-row :gutter="12">
        <el-col :span="12">
          <el-form-item label="物料" prop="itemId">
            <el-select v-model="form.itemId" filterable remote clearable placeholder="按编码/名称搜索"
                       :remote-method="searchItems" :loading="itemLoading" style="width:100%"
                       :disabled="isEdit" @change="onItemChange">
              <el-option v-for="it in itemOptions" :key="it.itemId"
                         :label="`${it.itemCode} ${it.itemName}`" :value="it.itemId" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="物料分类">
            <el-input :model-value="form.itemTypeName || '-'" disabled placeholder="选择物料后自动带出" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-row :gutter="12">
        <el-col :span="12">
          <el-form-item label="规格型号">
            <el-input :model-value="form.specification || '-'" disabled />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="装箱规格">
            <el-input :model-value="form.packageSpec || '-'" disabled placeholder="维护在物料档案" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-descriptions v-if="attrRows.length" :column="2" border size="small" class="mb8"
                       :title="`扩展属性（${form.itemTypeName || '物料分类'}）`">
        <el-descriptions-item v-for="a in attrRows" :key="a.code" :label="a.label">{{ a.value }}</el-descriptions-item>
      </el-descriptions>
      <el-row :gutter="12">
        <el-col :span="8">
          <el-form-item label="仓库" prop="warehouseId">
            <el-select v-model="form.warehouseId" filterable style="width:100%" placeholder="请选择" @change="onWarehouseChange">
              <el-option v-for="w in warehouseOptions" :key="w.warehouseId" :label="w.warehouseName" :value="w.warehouseId" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="库区">
            <el-select v-model="form.locationId" filterable clearable style="width:100%" placeholder="可空" @change="onLocationChange">
              <el-option v-for="l in locationOptions" :key="l.locationId" :label="l.locationName" :value="l.locationId" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="库位">
            <el-select v-model="form.areaId" filterable clearable style="width:100%" placeholder="可空">
              <el-option v-for="a in areaOptions" :key="a.areaId" :label="a.areaName" :value="a.areaId" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row :gutter="12">
        <el-col :span="8">
          <el-form-item label="供应商">
            <el-select v-model="form.vendorId" filterable clearable style="width:100%" placeholder="可空" @change="onVendorChange">
              <el-option v-for="v in vendorOptions" :key="v.vendorId" :label="v.vendorName" :value="v.vendorId" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="客户">
            <el-select v-model="form.clientId" filterable clearable style="width:100%" placeholder="订单成品可选" @change="onClientChange">
              <el-option v-for="c in clientOptions" :key="c.clientId" :label="c.clientName" :value="c.clientId" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="批次号"><el-input v-model="form.batchCode" placeholder="可空" /></el-form-item>
        </el-col>
      </el-row>
      <el-row :gutter="12">
        <el-col :span="8">
          <el-form-item label="盘点日期">
            <el-date-picker v-model="form.stocktakeDate" type="date" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="换算率">
            <el-input :model-value="form.conversionRate ?? '-'" disabled placeholder="维护在物料档案" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-divider content-position="left">库存数量</el-divider>
      <el-row :gutter="12">
        <el-col :span="12">
          <el-form-item :label="`数量（${form.unitName || '主单位'}）`" prop="quantityOnhand">
            <el-input-number v-model="form.quantityOnhand" :min="0" :precision="4" controls-position="right" style="width:100%" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item :label="`辅助数量（${form.unit2Name || '辅助单位'}）`">
            <el-input-number v-model="form.quantityOnhand2" :min="0" :precision="4" controls-position="right" style="width:100%" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="12" style="margin-top:8px">
        <el-col :span="24">
          <el-form-item label="备注"><el-input v-model="form.remark" placeholder="可空" /></el-form-item>
        </el-col>
      </el-row>
    </el-form>
    <template #footer>
      <el-button @click="emit('update:modelValue', false)">取消</el-button>
      <el-button type="primary" :loading="saving" @click="submit">保存</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { addWmMaterialStock, updateWmMaterialStock } from '@/api/mes/wm/material_stock'
import { listAllWmStorageLocation } from '@/api/mes/wm/storage_location'
import { listAllWmStorageArea } from '@/api/mes/wm/storage_area'
import { listAllVendor } from '@/api/mes/md/vendor'
import { listAllClient } from '@/api/mes/md/client'
import { listItem } from '@/api/mes/md/item'
import { listAttrDef } from '@/api/mes/md/attr'
import type { WmMaterialStock } from '@/types/api/mes/wm/material_stock'

const props = defineProps<{
  modelValue: boolean
  row?: WmMaterialStock | null
  warehouseOptions: any[]
}>()
const emit = defineEmits(['update:modelValue', 'success'])

const isEdit = computed(() => !!props.row?.materialStockId)

const formRef = ref()
const saving = ref(false)
const itemLoading = ref(false)
const itemOptions = ref<any[]>([])
const locationOptions = ref<any[]>([])
const areaOptions = ref<any[]>([])
const vendorOptions = ref<any[]>([])
const clientOptions = ref<any[]>([])
const attrMap = ref<Record<string, { attrName: string; attrUnit?: string }>>({})
const form = reactive<any>({})

/** 选中物料的扩展属性：翻译成「中文名(单位): 值」展示 */
const attrRows = computed(() => {
  const attrs = form.extAttrs || {}
  return Object.keys(attrs)
    .filter(k => attrs[k] !== null && attrs[k] !== undefined && attrs[k] !== '')
    .map(k => {
      const def = attrMap.value[k]
      const name = def?.attrName || k
      const unit = def?.attrUnit ? `(${def.attrUnit})` : ''
      return { code: k, label: `${name}${unit}`, value: Array.isArray(attrs[k]) ? attrs[k].join('、') : String(attrs[k]) }
    })
})

const rules = {
  itemId: [{ required: true, message: '请选择物料', trigger: 'change' }],
  warehouseId: [{ required: true, message: '请选择仓库', trigger: 'change' }],
  quantityOnhand: [{ required: true, message: '请输入库存数量', trigger: 'blur' }]
}

function init() {
  const r: any = props.row || {}
  Object.keys(form).forEach(k => delete form[k])
  Object.assign(form, {
    materialStockId: r.materialStockId,
    itemId: r.itemId,
    itemCode: r.itemCode,
    itemName: r.itemName,
    specification: r.specification,
    itemTypeName: r.itemTypeName,
    packageSpec: r.packageSpec,
    extAttrs: r.itemExtAttrs || {},
    unitOfMeasure: r.unitOfMeasure,
    unitName: r.unitName,
    unit2: r.unit2,
    unit2Name: r.unit2Name,
    conversionRate: r.conversionRate,
    quantityOnhand: r.quantityOnhand ?? 0,
    quantityOnhand2: r.quantityOnhand2 ?? 0,
    warehouseId: r.warehouseId,
    warehouseCode: r.warehouseCode,
    warehouseName: r.warehouseName,
    locationId: r.locationId,
    locationCode: r.locationCode,
    locationName: r.locationName,
    areaId: r.areaId,
    areaCode: r.areaCode,
    areaName: r.areaName,
    vendorId: r.vendorId,
    vendorCode: r.vendorCode,
    vendorName: r.vendorName,
    clientId: r.clientId,
    clientName: r.clientName,
    batchCode: r.batchCode,
    stocktakeDate: r.stocktakeDate,
    remark: r.remark
  })
  if (r.itemId) {
    itemOptions.value = [{ itemId: r.itemId, itemCode: r.itemCode, itemName: r.itemName }]
  } else {
    searchItems('')
  }
  loadLocationOptions()
  loadVendorOptions()
  loadClientOptions()
  loadAttrMap()
}

function loadAttrMap() {
  if (Object.keys(attrMap.value).length) return
  listAttrDef({ enableFlag: '1' } as any).then((res: any) => {
    const map: Record<string, { attrName: string; attrUnit?: string }> = {}
    for (const a of (res.rows || [])) map[a.attrCode] = { attrName: a.attrName, attrUnit: a.attrUnit }
    attrMap.value = map
  }).catch(() => {})
}

function loadLocationOptions() {
  listAllWmStorageLocation().then((r: any) => { locationOptions.value = r.data || r.rows || [] }).catch(() => {})
}
function loadVendorOptions() {
  listAllVendor().then((r: any) => { vendorOptions.value = r.data || r.rows || [] }).catch(() => {})
}
function loadClientOptions() {
  listAllClient().then((r: any) => { clientOptions.value = r.data || r.rows || [] }).catch(() => {})
}
function loadAreaOptions(locationId?: number) {
  listAllWmStorageArea().then((r: any) => {
    const all = r.data || r.rows || []
    areaOptions.value = locationId ? all.filter((a: any) => a.locationId === locationId) : all
  }).catch(() => {})
}

function searchItems(keyword: string) {
  itemLoading.value = true
  const kw = keyword || undefined
  // 编码/名称两路并发，支持按 PAPER-XBZ-A 这类编码搜索
  Promise.all([
    listItem({ pageNum: 1, pageSize: 30, itemCode: kw } as any),
    listItem({ pageNum: 1, pageSize: 30, itemName: kw } as any)
  ]).then(([byCode, byName]) => {
    const rows = [...(byCode.rows || []), ...(byName.rows || [])]
    itemOptions.value = rows.filter((r: any, i: number) => rows.findIndex((x: any) => x.itemId === r.itemId) === i)
  }).finally(() => { itemLoading.value = false })
}

/** 单位、换算率、装箱规格全部来自物料档案，库存不做行业假设 */
function onItemChange(itemId: number) {
  const it = itemOptions.value.find(x => x.itemId === itemId)
  if (!it) return
  form.itemCode = it.itemCode
  form.itemName = it.itemName
  form.specification = it.specification
  form.itemTypeName = it.itemTypeName
  form.packageSpec = it.packageSpec
  form.extAttrs = it.extAttrs || {}
  form.unitOfMeasure = it.unitOfMeasure
  form.unitName = it.unitName
  form.unit2 = it.unit2
  form.unit2Name = it.unit2Name
  form.conversionRate = it.conversionRate
}

function onWarehouseChange(id: number) {
  const w = props.warehouseOptions.find(x => x.warehouseId === id)
  if (w) { form.warehouseCode = w.warehouseCode; form.warehouseName = w.warehouseName }
}
function onLocationChange(id: number) {
  const l = locationOptions.value.find(x => x.locationId === id)
  if (l) { form.locationCode = l.locationCode; form.locationName = l.locationName }
  form.areaId = null
  loadAreaOptions(id)
}
function onVendorChange(id: number) {
  const v = vendorOptions.value.find(x => x.vendorId === id)
  if (v) { form.vendorCode = v.vendorCode; form.vendorName = v.vendorName }
}
function onClientChange(id: number) {
  const c = clientOptions.value.find(x => x.clientId === id)
  if (c) { form.clientName = c.clientName }
}

async function submit() {
  await formRef.value?.validate()
  saving.value = true
  try {
    const payload: any = { ...form }
    payload.quantityAvailable = payload.quantityOnhand
    payload.quantityAvailable2 = payload.quantityOnhand2
    const area = areaOptions.value.find(x => x.areaId === payload.areaId)
    if (area) { payload.areaCode = area.areaCode; payload.areaName = area.areaName }
    if (isEdit.value) await updateWmMaterialStock(payload)
    else await addWmMaterialStock(payload)
    ElMessage.success('保存成功')
    emit('update:modelValue', false)
    emit('success')
  } catch (e) {
    // 错误提示由 request 拦截器统一处理
  } finally {
    saving.value = false
  }
}
</script>
