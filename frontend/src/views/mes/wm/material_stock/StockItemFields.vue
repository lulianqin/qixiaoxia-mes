<template>
  <div>
    <el-row v-if="!isEdit" :gutter="12">
      <el-col :span="24">
        <el-form-item label="已有物料">
          <el-select v-model="form.itemId" filterable remote clearable placeholder="按编码/名称搜索；选中后自动带入，可直接改字段作为新物料"
                     :remote-method="searchItems" :loading="itemLoading" style="width:100%" @change="onItemChange">
            <el-option v-for="it in itemOptions" :key="it.itemId"
                       :label="`${it.itemCode} ${it.itemName}`" :value="it.itemId" />
          </el-select>
        </el-form-item>
      </el-col>
    </el-row>
    <el-row :gutter="12">
      <el-col :span="12">
        <el-form-item label="物料名称" prop="itemName">
          <el-input v-model="form.itemName" placeholder="选择已有物料自动带入，也可直接填写新物料" :disabled="isEdit" />
        </el-form-item>
      </el-col>
      <el-col :span="12">
        <el-form-item label="物料分类" prop="itemTypeId">
          <el-tree-select v-model="form.itemTypeId" :data="itemTypeTree" check-strictly node-key="id"
                          :props="{ value: 'id', label: 'label', children: 'children' }"
                          placeholder="请选择分类" clearable style="width:100%"
                          :disabled="isEdit" @change="onTypeChange" />
        </el-form-item>
      </el-col>
    </el-row>
    <el-row :gutter="12">
      <el-col :span="8">
        <el-form-item label="主单位" prop="unitOfMeasure">
          <el-select v-model="form.unitOfMeasure" filterable style="width:100%" :disabled="isEdit" @change="onUnitChange">
            <el-option v-for="u in unitOptions" :key="u.unitCode" :label="`${u.unitName} (${u.unitCode})`" :value="u.unitCode" />
          </el-select>
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="辅助单位">
          <el-select v-model="form.unit2" filterable clearable style="width:100%" placeholder="可空" :disabled="isEdit" @change="onUnit2Change">
            <el-option v-for="u in unitOptions" :key="u.unitCode" :label="`${u.unitName} (${u.unitCode})`" :value="u.unitCode" />
          </el-select>
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="换算率">
          <el-input-number v-model="form.conversionRate" :precision="4" :min="0" :disabled="isEdit || !form.unit2"
                           controls-position="right" placeholder="1辅助单位=多少主单位" style="width:100%" />
        </el-form-item>
      </el-col>
    </el-row>
    <el-row :gutter="12">
      <el-col :span="8">
        <el-form-item :label="`主单位数量（${form.unitName || '主单位'}）`" prop="quantityOnhand">
          <el-input-number v-model="form.quantityOnhand" :min="0" :precision="4" controls-position="right" style="width:100%" />
        </el-form-item>
      </el-col>
      <el-col v-if="form.unit2" :span="8">
        <el-form-item :label="`辅助单位数量（${form.unit2Name || form.unit2}）`">
          <el-input-number v-model="form.quantityOnhand2" :min="0" :precision="4" controls-position="right" style="width:100%" />
        </el-form-item>
      </el-col>
    </el-row>
    <el-row :gutter="12">
      <el-col :span="8">
        <el-form-item label="规格型号">
          <el-input v-model="form.specification" placeholder="可空" :disabled="isEdit" />
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="装箱规格">
          <el-input v-model="form.packageSpec" placeholder="可空" :disabled="isEdit" />
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="产品尺寸">
          <el-input v-model="form.productSize" placeholder="可空" :disabled="isEdit" />
        </el-form-item>
      </el-col>
    </el-row>

    <template v-if="attrSchema.length">
      <el-divider content-position="left">扩展属性</el-divider>
      <ExtAttrForm :key="`${form.itemId ?? 'new'}-${form.itemTypeId ?? 0}`" ref="extAttrRef"
                   v-model="form.extAttrs" :schema="attrSchema" :readonly="isEdit" :columns="2" />
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { listItem } from '@/api/mes/md/item'
import { treeselect } from '@/api/mes/md/itemtype'
import { getEffAttrSchema } from '@/api/mes/md/attr'
import { listAllUnitmeasure } from '@/api/mes/md/unitmeasure'
import ExtAttrForm from '@/components/ExtAttrForm/index.vue'

/** 物料的展示/编辑字段由父弹窗统一维护，子组件只负责交互与下拉数据 */
const props = defineProps<{
  form: any
  isEdit: boolean
}>()

const itemLoading = ref(false)
const itemOptions = ref<any[]>([])
const itemTypeTree = ref<any[]>([])
const unitOptions = ref<any[]>([])
const attrSchema = ref<any[]>([])
const extAttrRef = ref()

watch(() => props.form.itemTypeId, (id: number | null) => loadAttrSchema(id), { immediate: true })
watch(() => props.form.itemId, (id: number | null) => {
  if (id && !itemOptions.value.some((x: any) => x.itemId === id)) {
    itemOptions.value = [{ itemId: id, itemCode: props.form.itemCode, itemName: props.form.itemName }]
  }
}, { immediate: true })

treeselect().then((r: any) => { itemTypeTree.value = r.data || r.rows || [] }).catch(() => {})
listAllUnitmeasure().then((r: any) => { unitOptions.value = r.data || r.rows || [] }).catch(() => {})
if (!props.isEdit) searchItems('')

function loadAttrSchema(typeId?: number | null) {
  attrSchema.value = []
  if (!typeId) return
  getEffAttrSchema(typeId).then((r: any) => { attrSchema.value = r.data || [] }).catch(() => {})
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

/** 选中已有物料：带入全部字段，用户可继续修改（保存时按最终值匹配或新建） */
function onItemChange(itemId: number | null) {
  if (!itemId) return
  const it = itemOptions.value.find((x: any) => x.itemId === itemId)
  if (!it) return
  Object.assign(props.form, {
    itemCode: it.itemCode,
    itemName: it.itemName,
    itemTypeId: it.itemTypeId ?? null,
    itemTypeCode: it.itemTypeCode,
    itemTypeName: it.itemTypeName,
    specification: it.specification || '',
    packageSpec: it.packageSpec || '',
    productSize: it.productSize || '',
    extAttrs: it.extAttrs || {},
    unitOfMeasure: it.unitOfMeasure || 'PCS',
    unitName: it.unitName || '个',
    unit2: it.unit2,
    unit2Name: it.unit2Name,
    conversionRate: it.conversionRate
  })
}

/** 切换分类：属性结构随之变化，清空旧值后重新加载 schema */
function onTypeChange() {
  props.form.extAttrs = {}
}

function onUnitChange(code: string) {
  const u = unitOptions.value.find((x: any) => x.unitCode === code)
  if (u) props.form.unitName = u.unitName
}

function onUnit2Change(code: string) {
  if (!code) {
    props.form.unit2Name = ''
    props.form.conversionRate = null
    return
  }
  const u = unitOptions.value.find((x: any) => x.unitCode === code)
  if (u) props.form.unit2Name = u.unitName
}

/** 校验必填扩展属性（供父弹窗提交前调用） */
function validate() {
  return extAttrRef.value?.validate ? extAttrRef.value.validate() : Promise.resolve()
}

defineExpose({ validate })
</script>
