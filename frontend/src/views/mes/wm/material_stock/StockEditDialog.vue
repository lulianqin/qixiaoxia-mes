<template>
  <el-dialog :model-value="modelValue" :title="isEdit ? '编辑库存' : '新增库存'" width="1040px" append-to-body
             @update:model-value="(v: boolean) => emit('update:modelValue', v)" @open="init">
    <el-form ref="formRef" :model="form" :rules="rules" label-width="110px" size="small">
      <StockItemFields ref="itemRef" :form="form" :is-edit="isEdit" />

      <el-divider content-position="left">库存信息</el-divider>
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
        <el-col :span="12">
          <el-form-item label="客户PO号"><el-input v-model="form.poNo" placeholder="客户下单PO号，可空" clearable /></el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="系统订单号"><el-input v-model="form.sourceOrderCode" placeholder="来源系统订单号，可空" clearable /></el-form-item>
        </el-col>
      </el-row>
      <el-row :gutter="12">
        <el-col :span="8">
          <el-form-item label="盘点日期">
            <el-date-picker v-model="form.stocktakeDate" type="date" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" />
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
import { addWmMaterialStock, updateWmMaterialStock, resolveStockItem } from '@/api/mes/wm/material_stock'
import { listAllWmStorageLocation } from '@/api/mes/wm/storage_location'
import { listAllWmStorageArea } from '@/api/mes/wm/storage_area'
import { listAllVendor } from '@/api/mes/md/vendor'
import { listAllClient } from '@/api/mes/md/client'
import { getItem } from '@/api/mes/md/item'
import type { WmMaterialStock } from '@/types/api/mes/wm/material_stock'
import StockItemFields from './StockItemFields.vue'

const props = defineProps<{
  modelValue: boolean
  row?: WmMaterialStock | null
  warehouseOptions: any[]
}>()
const emit = defineEmits(['update:modelValue', 'success'])

const isEdit = computed(() => !!props.row?.materialStockId)

const formRef = ref()
const itemRef = ref()
const saving = ref(false)
const locationOptions = ref<any[]>([])
const areaOptions = ref<any[]>([])
const vendorOptions = ref<any[]>([])
const clientOptions = ref<any[]>([])
const form = reactive<any>({})

const rules = computed(() => isEdit.value
  ? {
      warehouseId: [{ required: true, message: '请选择仓库', trigger: 'change' }],
      quantityOnhand: [{ required: true, message: '请输入库存数量', trigger: 'blur' }]
    }
  : {
      itemName: [{ required: true, message: '请输入物料名称', trigger: 'blur' }],
      itemTypeId: [{ required: true, message: '请选择物料分类', trigger: 'change' }],
      unitOfMeasure: [{ required: true, message: '请选择主单位', trigger: 'change' }],
      warehouseId: [{ required: true, message: '请选择仓库', trigger: 'change' }],
      quantityOnhand: [{ required: true, message: '请输入库存数量', trigger: 'blur' }]
    })

function init() {
  const r: any = props.row || {}
  Object.keys(form).forEach(k => delete form[k])
  Object.assign(form, {
    materialStockId: r.materialStockId,
    itemId: r.itemId ?? null,
    itemCode: r.itemCode,
    itemName: r.itemName || '',
    itemTypeId: r.itemTypeId ?? null,
    itemTypeCode: r.itemTypeCode,
    itemTypeName: r.itemTypeName,
    specification: r.specification || '',
    packageSpec: r.packageSpec || '',
    productSize: '',
    extAttrs: r.itemExtAttrs || {},
    unitOfMeasure: r.unitOfMeasure || 'PCS',
    unitName: r.unitName || '个',
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
    poNo: r.poNo,
    sourceOrderCode: r.sourceOrderCode,
    stocktakeDate: r.stocktakeDate,
    remark: r.remark
  })
  loadLocationOptions()
  loadVendorOptions()
  loadClientOptions()
  // 编辑态：补全物料档案里的产品尺寸/扩展属性/辅单位
  if (isEdit.value && r.itemId) {
    getItem(r.itemId).then((res: any) => {
      const it = res?.data
      if (!it) return
      form.itemTypeId = it.itemTypeId ?? form.itemTypeId
      form.productSize = it.productSize || form.productSize
      form.extAttrs = it.extAttrs || form.extAttrs
      form.unit2 = it.unit2
      form.unit2Name = it.unit2Name
      form.conversionRate = it.conversionRate
    }).catch(() => {})
  }
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

function onWarehouseChange(id: number) {
  const w = props.warehouseOptions.find((x: any) => x.warehouseId === id)
  if (w) { form.warehouseCode = w.warehouseCode; form.warehouseName = w.warehouseName }
}
function onLocationChange(id: number) {
  const l = locationOptions.value.find((x: any) => x.locationId === id)
  if (l) { form.locationCode = l.locationCode; form.locationName = l.locationName }
  form.areaId = null
  loadAreaOptions(id)
}
function onVendorChange(id: number) {
  const v = vendorOptions.value.find((x: any) => x.vendorId === id)
  if (v) { form.vendorCode = v.vendorCode; form.vendorName = v.vendorName }
}
function onClientChange(id: number) {
  const c = clientOptions.value.find((x: any) => x.clientId === id)
  if (c) { form.clientName = c.clientName }
}

async function submit() {
  await formRef.value?.validate()
  try {
    await itemRef.value?.validate()
  } catch (e: any) {
    ElMessage.warning(e?.message || '请完善扩展属性')
    return
  }
  saving.value = true
  try {
    const payload: any = { ...form }
    payload.itemExtAttrs = form.extAttrs || {}
    delete payload.extAttrs
    payload.quantityAvailable = payload.quantityOnhand
    payload.quantityAvailable2 = payload.quantityOnhand2
    const area = areaOptions.value.find((x: any) => x.areaId === payload.areaId)
    if (area) { payload.areaCode = area.areaCode; payload.areaName = area.areaName }

    if (isEdit.value) {
      await updateWmMaterialStock(payload)
    } else {
      // 先按最终填写值解析物料：同规格命中复用，否则自动建档
      const res: any = await resolveStockItem({
        itemName: form.itemName,
        itemTypeId: form.itemTypeId,
        specification: form.specification,
        packageSpec: form.packageSpec,
        productSize: form.productSize,
        unitOfMeasure: form.unitOfMeasure,
        unitName: form.unitName,
        unit2: form.unit2,
        unit2Name: form.unit2Name,
        conversionRate: form.conversionRate,
        extAttrs: form.extAttrs || {}
      })
      const item = res?.data || res
      Object.assign(payload, {
        itemId: item.itemId,
        itemCode: item.itemCode,
        itemName: item.itemName,
        itemTypeId: item.itemTypeId,
        itemTypeCode: item.itemTypeCode,
        itemTypeName: item.itemTypeName,
        specification: item.specification,
        packageSpec: item.packageSpec,
        unitOfMeasure: item.unitOfMeasure,
        unitName: item.unitName,
        unit2: item.unit2,
        unit2Name: item.unit2Name,
        conversionRate: item.conversionRate,
        itemExtAttrs: item.extAttrs || form.extAttrs || {}
      })
      await addWmMaterialStock(payload)
    }
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
