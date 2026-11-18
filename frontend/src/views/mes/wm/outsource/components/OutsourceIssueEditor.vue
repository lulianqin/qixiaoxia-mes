<template>
  <div>
    <el-table :data="rows" border size="small" max-height="300">
      <el-table-column label="物料" align="center" min-width="180">
        <template #default="{ row }">
          <el-input v-model="row.itemName" placeholder="点击右侧选择" readonly size="small">
            <template #append>
              <el-button icon="Search" size="small" @click="pickItem(row)" />
            </template>
          </el-input>
        </template>
      </el-table-column>
      <el-table-column label="数量" align="center" width="140">
        <template #default="{ row }">
          <el-input-number v-model="row.quantity" :min="0" :precision="4" :controls="false"
            size="small" style="width:100%" placeholder="支持10万级数量" />
        </template>
      </el-table-column>
      <el-table-column label="单位" align="center" width="80">
        <template #default="{ row }">
          <span>{{ row.unitName || row.unitOfMeasure || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="单价" align="center" width="110">
        <template #default="{ row }">
          <el-input-number v-model="row.unitPrice" :min="0" :precision="4" :controls="false"
            size="small" style="width:100%" @change="recalcAmount(row)" />
        </template>
      </el-table-column>
      <el-table-column label="金额" align="center" width="110">
        <template #default="{ row }"><span>{{ money(row.amount) }}</span></template>
      </el-table-column>
      <el-table-column label="仓库" align="center" min-width="140">
        <template #default="{ row }">
          <el-input v-model="row.warehouseName" placeholder="点击右侧选择" readonly size="small">
            <template #append>
              <el-button icon="Search" size="small" @click="pickWarehouse(row)" />
            </template>
          </el-input>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="60">
        <template #default="{ $index }">
          <el-button link type="danger" size="small" icon="Delete" @click="removeLine($index)" />
        </template>
      </el-table-column>
    </el-table>
    <div class="line-actions">
      <el-button type="primary" plain icon="Plus" size="small" @click="addBlankLine">添加物料</el-button>
      <el-button v-if="product?.productId" plain icon="Box" size="small" @click="addProductLine">
        发产品本身
      </el-button>
      <el-button plain icon="Document" size="small" @click="addProductBomLines">加入产品BOM</el-button>
      <el-button plain icon="Document" size="small" :disabled="!processBomLines.length" @click="addProcessBomLines">
        加入选中工序BOM
      </el-button>
    </div>

    <ItemSelect ref="itemSelectRef" @onSelected="onItemSelected" />
    <WarehouseSelect ref="whSelectRef" @onSelected="onWarehouseSelected" />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import ItemSelect from '@/components/itemSelect/single.vue'
import WarehouseSelect from '@/components/warehouseSelect/single.vue'

const props = defineProps<{ rows: any[]; product?: any; productBomLines?: any[]; processBomLines?: any[] }>()

const itemSelectRef = ref()
const whSelectRef = ref()
const currentRow = ref<any>(null)

function pickItem(row: any) {
  currentRow.value = row
  itemSelectRef.value?.open()
}

function pickWarehouse(row: any) {
  currentRow.value = row
  whSelectRef.value?.open()
}

function onItemSelected(item: any) {
  if (!item || !currentRow.value) return
  currentRow.value.itemId = item.itemId
  currentRow.value.itemCode = item.itemCode
  currentRow.value.itemName = item.itemName
  currentRow.value.unitOfMeasure = item.unitOfMeasure || currentRow.value.unitOfMeasure || null
  currentRow.value.unitName = item.unitName || (item.unitOfMeasure ? null : currentRow.value.unitName)
}

function onWarehouseSelected(row: any) {
  if (!row || !currentRow.value) return
  currentRow.value.warehouseId = row.warehouseId
  currentRow.value.warehouseCode = row.warehouseCode
  currentRow.value.warehouseName = row.warehouseName
}

/** 任意物料加入发料明细：同物料累加数量（跨工序同物料合并为订单级发料） */
function addItemLine(item: any, qty: number) {
  if (!item?.itemId) return
  const exist = props.rows.find(l => l.itemId === item.itemId)
  if (exist) {
    exist.quantity = Number(exist.quantity || 0) + Number(qty || 0)
    return
  }
  props.rows.push({
    itemId: item.itemId, itemCode: item.itemCode, itemName: item.itemName,
    specification: item.specification || item.itemSpc,
    quantity: Number(qty || 0), unitOfMeasure: item.unitOfMeasure || null, unitName: item.unitName || null,
    batchId: null, batchCode: null,
    warehouseId: null, warehouseCode: '', warehouseName: '',
    unitPrice: null, amount: null
  })
}

function addBlankLine() {
  props.rows.push({
    itemId: null, itemCode: '', itemName: '', quantity: 0,
    unitOfMeasure: null, unitName: null, batchId: null,
    warehouseId: null, warehouseCode: '', warehouseName: '',
    unitPrice: null, amount: null
  })
}

function addProductLine() {
  const p = props.product
  if (!p?.productId) return
  addItemLine({
    itemId: p.productId, itemCode: p.productCode, itemName: p.productName,
    specification: p.productSpecification, unitOfMeasure: p.productUnitOfMeasure,
    unitName: p.productUnitName
  }, Number(p.productQuantity || 0))
}

function addProductBomLines() {
  const qty = Number(props.product?.productQuantity || 1)
  ;(props.productBomLines || []).forEach((b: any) => addItemLine(b, Number(b.quantity || 0) * qty))
}

function addProcessBomLines() {
  ;(props.processBomLines || []).forEach((b: any) => addItemLine(b, Number(b.quantity || 0)))
}

function removeLine(index: number) {
  props.rows.splice(index, 1)
}

function recalcAmount(row: any) {
  row.amount = row.unitPrice != null && row.quantity != null
    ? Number((Number(row.quantity) * Number(row.unitPrice)).toFixed(2)) : null
}

function money(v: any) {
  return v == null || v === '' ? '-' : Number(v).toFixed(2)
}

defineExpose({ addItemLine })
</script>

<style scoped>
.line-actions { display: flex; gap: 8px; margin-top: 8px; flex-wrap: wrap; }
</style>
