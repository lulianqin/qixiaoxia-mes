<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" size="small" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="物料编码" prop="itemCode">
        <el-input v-model="queryParams.itemCode" placeholder="请输入物料编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="物料名称" prop="itemName">
        <el-input v-model="queryParams.itemName" placeholder="请输入物料名称" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="批次号" prop="batchCode">
        <el-input v-model="queryParams.batchCode" placeholder="请输入批次号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="物料分类" prop="itemTypeId">
        <el-tree-select v-model="queryParams.itemTypeId" :data="itemTypeTree" check-strictly node-key="id"
                        :props="{ value: 'id', label: 'label', children: 'children' }"
                        placeholder="请选择分类" clearable style="width:160px" />
      </el-form-item>
      <el-form-item label="仓库" prop="warehouseId">
        <el-select v-model="queryParams.warehouseId" placeholder="请选择仓库" clearable filterable>
          <el-option v-for="w in warehouseOptions" :key="w.warehouseId" :label="w.warehouseName" :value="w.warehouseId" />
        </el-select>
      </el-form-item>
      <el-form-item label="质量状态" prop="qualityStatus">
        <el-select v-model="queryParams.qualityStatus" placeholder="请选择" clearable style="width:110px">
          <el-option label="正常" value="NORMAL" />
          <el-option label="冻结" value="HOLD" />
          <el-option label="不合格" value="REJECT" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" size="small" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" size="small" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" size="small" @click="handleAdd" v-hasPermi="['mes:wm:material_stock:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="Edit" size="small" :disabled="ids.length !== 1" @click="handleEdit" v-hasPermi="['mes:wm:material_stock:edit']">编辑</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" size="small" :disabled="ids.length === 0" @click="handleDelete" v-hasPermi="['mes:wm:material_stock:remove']">删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Upload" size="small" @click="importVisible = true" v-hasPermi="['mes:wm:material_stock:import']">导入</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Download" size="small" @click="handleExport" v-hasPermi="['mes:wm:stock:export']">导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="stockList" @selection-change="handleSelectionChange" stripe border>
      <el-table-column type="selection" width="50" align="center" />
      <el-table-column label="物料分类" align="center" prop="itemTypeName" width="110">
        <template #default="scope">
          <el-tag size="small">{{ scope.row.itemTypeName || '-' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="物料编码" align="center" prop="itemCode" width="130" :show-overflow-tooltip="true" />
      <el-table-column label="物料名称" align="center" prop="itemName" :show-overflow-tooltip="true" min-width="150" />
      <el-table-column label="规格型号" align="center" prop="specification" :show-overflow-tooltip="true" width="120" />
      <el-table-column label="装箱规格" align="center" prop="packageSpec" width="110">
        <template #default="scope">{{ scope.row.packageSpec || '-' }}</template>
      </el-table-column>
      <el-table-column label="库存数量" align="center" prop="quantityOnhand" width="100" sortable :show-overflow-tooltip="true" />
      <el-table-column label="可用库存" align="center" prop="quantityAvailable" width="100" sortable :show-overflow-tooltip="true" />
      <el-table-column label="占用库存" align="center" width="100" sortable :sort-method="(a,b) => occupied(a) - occupied(b)">
        <template #default="scope">
          <span :class="{ 'occu-pending': occupied(scope.row) > 0 }">{{ occupied(scope.row) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="单位" align="center" prop="unitName" width="70" :show-overflow-tooltip="true" />
      <el-table-column label="辅助数量" align="center" width="100">
        <template #default="scope">
          {{ scope.row.quantityOnhand2 ?? '-' }}{{ scope.row.unit2Name ? ' ' + scope.row.unit2Name : '' }}
        </template>
      </el-table-column>
      <el-table-column label="物料属性" align="center" min-width="180">
        <template #default="scope">
          <span>{{ attrText(scope.row.itemExtAttrs) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="批次号" align="center" prop="batchCode" width="130">
        <template #default="scope">
          <el-button v-if="scope.row.batchCode" link type="primary" size="small" @click="handleBatchClick(scope.row)">
            {{ scope.row.batchCode }}
          </el-button>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="仓库" align="center" prop="warehouseName" width="120" :show-overflow-tooltip="true" />
      <el-table-column label="库区" align="center" prop="locationName" width="100">
        <template #default="scope">{{ scope.row.locationName || '-' }}</template>
      </el-table-column>
      <el-table-column label="库位" align="center" prop="areaName" width="100">
        <template #default="scope">{{ scope.row.areaName || '-' }}</template>
      </el-table-column>
      <el-table-column label="供应商" align="center" prop="vendorName" width="120" :show-overflow-tooltip="true">
        <template #default="scope">{{ scope.row.vendorName || '-' }}</template>
      </el-table-column>
      <el-table-column label="客户" align="center" prop="clientName" width="120" :show-overflow-tooltip="true">
        <template #default="scope">{{ scope.row.clientName || '-' }}</template>
      </el-table-column>
      <el-table-column label="质量状态" align="center" prop="qualityStatus" width="90">
        <template #default="scope">
          <el-tag :type="scope.row.qualityStatus === 'NORMAL' ? 'success' : scope.row.qualityStatus === 'HOLD' ? 'warning' : 'danger'" size="small">
            {{ scope.row.qualityStatus === 'NORMAL' ? '正常' : scope.row.qualityStatus === 'HOLD' ? '冻结' : '不合格' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="更新时间" align="center" prop="updateTime" width="180" :show-overflow-tooltip="true">
        <template #default="scope">
          <span>{{ scope.row.updateTime || '-' }}</span>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <StockEditDialog v-model="editVisible" :row="editRow" :warehouse-options="warehouseOptions" @success="getList" />
    <StockImportDialog v-model="importVisible" :warehouse-options="warehouseOptions" @success="getList" />
  </div>
</template>

<script setup lang="ts" name="WmMaterialStock">
import { ref, reactive, toRefs, getCurrentInstance, onMounted } from 'vue'
import type { WmMaterialStockQueryParams, WmMaterialStock } from '@/types/api/mes/wm/material_stock'
import type { WmWarehouse } from '@/types/api/mes/wm/warehouse'
import type { TreeSelect } from '@/types'
import { listWmMaterialStock, delWmMaterialStock } from '@/api/mes/wm/material_stock'
import { listAllWmWarehouse } from '@/api/mes/wm/warehouse'
import { treeselect } from '@/api/mes/md/itemtype'
import { listAttrDef } from '@/api/mes/md/attr'
import StockEditDialog from './StockEditDialog.vue'
import StockImportDialog from './StockImportDialog.vue'
import { useRouter } from 'vue-router'

const { proxy } = getCurrentInstance() as any
const router = useRouter()

const stockList = ref<WmMaterialStock[]>([])
const warehouseOptions = ref<WmWarehouse[]>([])
const itemTypeTree = ref<TreeSelect[]>([])
const attrMap = ref<Record<string, { attrName: string; attrUnit?: string }>>({})
const loading = ref(true)
const showSearch = ref(true)
const ids = ref<number[]>([])
const selectedRows = ref<WmMaterialStock[]>([])
const total = ref(0)
const editVisible = ref(false)
const editRow = ref<WmMaterialStock | null>(null)
const importVisible = ref(false)

const data = reactive({
  queryParams: { pageNum: 1, pageSize: 10 } as WmMaterialStockQueryParams
})
const { queryParams } = toRefs(data)

function getList() {
  loading.value = true
  listWmMaterialStock(queryParams.value).then(r => { stockList.value = r.rows; total.value = r.total; loading.value = false })
}
function loadWarehouseOptions() {
  listAllWmWarehouse().then((r: any) => {
    warehouseOptions.value = r?.data || r?.rows || []
  }).catch(() => {})
}
function handleQuery() { queryParams.value.pageNum = 1; getList() }
function resetQuery() { proxy.resetForm('queryRef'); handleQuery() }
function handleSelectionChange(s: any[]) { ids.value = s.map(i => i.materialStockId); selectedRows.value = s }
function handleAdd() { editRow.value = null; editVisible.value = true }
function handleEdit() {
  if (ids.value.length !== 1) return
  editRow.value = selectedRows.value[0]
  editVisible.value = true
}
function handleDelete() {
  proxy.$modal.confirm('确认删除选中的 ' + ids.value.length + ' 条库存记录？删除会写入库存流水。').then(() => {
    return delWmMaterialStock(ids.value)
  }).then(() => { getList(); proxy.$modal.msgSuccess('删除成功') }).catch(() => {})
}
/** 物料属性一行展示：中文名+单位:值（属性来自物料档案） */
function attrText(attrs?: Record<string, any>) {
  if (!attrs) return '-'
  const parts = Object.keys(attrs)
    .filter(k => attrs[k] !== null && attrs[k] !== undefined && attrs[k] !== '')
    .map(k => {
      const def = attrMap.value[k]
      const name = def?.attrName || k
      const unit = def?.attrUnit ? def.attrUnit : ''
      return `${name}:${attrs[k]}${unit}`
    })
  return parts.length ? parts.join(' / ') : '-'
}
function loadAttrMap() {
  listAttrDef({ enableFlag: '1' } as any).then((res: any) => {
    const map: Record<string, { attrName: string; attrUnit?: string }> = {}
    for (const a of (res.rows || [])) {
      map[a.attrCode] = { attrName: a.attrName, attrUnit: a.attrUnit }
    }
    attrMap.value = map
  }).catch(() => {})
}
function handleExport() { proxy.download('/mes/wm/material_stock/export', { ...queryParams.value }, `stock_${Date.now()}.xlsx`) }
function handleBatchClick(row: WmMaterialStock) {
  if (row.batchId && row.batchId > 0) {
    router.push({ path: '/mes/wm/batch', query: { batchId: row.batchId } })
  }
}

/** 占用库存 = 现有量 - 可用量（已预占未出库的部分） */
function occupied(row: WmMaterialStock): number {
  const onhand = Number(row.quantityOnhand) || 0
  const avail = Number(row.quantityAvailable) || 0
  return Math.max(0, onhand - avail)
}

onMounted(() => {
  loadWarehouseOptions()
  loadAttrMap()
  treeselect().then(r => { itemTypeTree.value = r.data || [] }).catch(() => {})
})
getList()
</script>

<style lang="scss" scoped>
.occu-pending {
  color: #e6a23c;
  font-weight: 600;
}
</style>
