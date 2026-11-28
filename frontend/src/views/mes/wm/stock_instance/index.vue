<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="实例编号" prop="instanceCode">
        <el-input v-model="queryParams.instanceCode" placeholder="扫/输实例码" clearable style="width:190px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="物料编码" prop="itemCode">
        <el-input v-model="queryParams.itemCode" placeholder="请输入" clearable style="width:150px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="物料名称" prop="itemName">
        <el-input v-model="queryParams.itemName" placeholder="请输入" clearable style="width:150px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="批次" prop="batchCode">
        <el-input v-model="queryParams.batchCode" placeholder="请输入" clearable style="width:150px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="全部" clearable style="width:130px">
          <el-option v-for="s in STATUS_OPTIONS" :key="s.value" :label="s.label" :value="s.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['mes:wm:stock_instance:add']">期初建件</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete()" v-hasPermi="['mes:wm:stock_instance:remove']">删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="instanceList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="50" align="center" />
      <el-table-column label="实例编号" align="center" prop="instanceCode" width="190" :show-overflow-tooltip="true" />
      <el-table-column label="物料" align="left" min-width="200" :show-overflow-tooltip="true">
        <template #default="scope">
          <span>{{ scope.row.itemName }}</span>
          <span class="sub-text"> ({{ scope.row.itemCode }})</span>
        </template>
      </el-table-column>
      <el-table-column label="规格" align="center" prop="specification" width="130" :show-overflow-tooltip="true" />
      <el-table-column label="批次" align="center" prop="batchCode" width="150" :show-overflow-tooltip="true">
        <template #default="scope">{{ scope.row.batchCode || '无批次' }}</template>
      </el-table-column>
      <el-table-column label="仓库" align="center" prop="warehouseName" width="120" :show-overflow-tooltip="true" />
      <el-table-column label="入库数量" align="right" width="110">
        <template #default="scope">{{ fmtQty(scope.row.originalQuantity) }}</template>
      </el-table-column>
      <el-table-column label="剩余数量" align="right" width="110">
        <template #default="scope">
          <span :class="{ 'qty-zero': Number(scope.row.remainingQuantity) <= 0 }">{{ fmtQty(scope.row.remainingQuantity) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="单位" align="center" prop="quantityUom" width="70" />
      <el-table-column label="状态" align="center" width="100">
        <template #default="scope">
          <el-tag :type="statusTagType(scope.row.status)" size="small">{{ statusText(scope.row.status) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="供应商编号" align="center" prop="vendorInstanceNo" width="140" :show-overflow-tooltip="true" />
      <el-table-column label="扩展属性" align="left" min-width="160" :show-overflow-tooltip="true">
        <template #default="scope">{{ extSummary(scope.row.extAttrs) }}</template>
      </el-table-column>
      <el-table-column label="操作" fixed="right" align="center" width="160" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Grid" @click="handleQrCode(scope.row)">标签</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['mes:wm:stock_instance:edit']">修改</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['mes:wm:stock_instance:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 期初建件 / 修改 -->
    <el-dialog :title="title" v-model="open" width="680px" append-to-body>
      <el-alert type="info" :closable="false" class="mb8"
        title="一件实物一行：一卷纸 / 一根钢管 / 一桶油墨。入库数量填该件按主单位计量的实际数量，剩余数量默认等于入库数量。" />
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="实例编号" prop="instanceCode">
              <el-input v-model="form.instanceCode" placeholder="留空则自动生成" clearable />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="物料" prop="itemId">
              <el-input v-model="form.itemName" readonly placeholder="点击选择物料">
                <template #append><el-button icon="Search" @click="openItemPicker" /></template>
              </el-input>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="入库数量" prop="originalQuantity">
              <el-input-number v-model="form.originalQuantity" :min="0" :precision="4" controls-position="right" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="剩余数量" prop="remainingQuantity">
              <el-input-number v-model="form.remainingQuantity" :min="0" :precision="4" controls-position="right" style="width:100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="主单位" prop="quantityUom">
              <el-input v-model="form.quantityUom" placeholder="如 KG" clearable />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="实例类型" prop="instanceType">
              <el-input v-model="form.instanceType" placeholder="由物料辅助单位决定，如 ROLL" clearable />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="批次编码" prop="batchCode">
              <el-input v-model="form.batchCode" placeholder="可留空" clearable />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="仓库" prop="warehouseId">
              <el-input v-model="form.warehouseName" readonly placeholder="点击选择仓库">
                <template #append><el-button icon="Search" @click="openWarehousePicker" /></template>
              </el-input>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-select v-model="form.status" style="width:100%">
                <el-option v-for="s in STATUS_OPTIONS" :key="s.value" :label="s.label" :value="s.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="供应商编号" prop="vendorInstanceNo">
              <el-input v-model="form.vendorInstanceNo" placeholder="供应商卷号/根号" clearable />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" :rows="2" placeholder="请输入" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="open = false">取 消</el-button>
      </template>
    </el-dialog>

    <!-- 实物标签 -->
    <el-dialog title="实物标签" v-model="qrOpen" width="340px" append-to-body>
      <div v-if="qrRow" style="text-align:center">
        <QrCode :payload="buildQrPayload('ROLL', qrRow.instanceCode || '')" :size="240" />
        <div style="margin-top:12px;font-size:18px;font-weight:bold">{{ qrRow.instanceCode }}</div>
        <div style="color:#999;margin-top:4px">{{ qrRow.itemName }} {{ qrRow.specification }}</div>
        <div style="color:#999;margin-top:2px">
          剩余 {{ fmtQty(qrRow.remainingQuantity) }} {{ qrRow.quantityUom || '' }} · {{ statusText(qrRow.status) }}
        </div>
      </div>
      <template #footer>
        <el-select v-model="labelSpecKey" size="small" style="width:110px" title="标签纸规格">
          <el-option v-for="s in LABEL_SPECS" :key="s.key" :value="s.key" :label="s.label" />
        </el-select>
        <el-button type="primary" @click="handlePrintLabel" icon="Printer">打印</el-button>
        <el-button @click="qrOpen = false">关 闭</el-button>
      </template>
    </el-dialog>

    <!-- 物料选择 / 仓库选择 -->
    <ItemSelect ref="itemSelectRef" @onSelected="onItemSelected" />
    <WarehouseSelect ref="warehouseSelectRef" @onSelected="onWarehouseSelected" />
  </div>
</template>

<script setup lang="ts" name="WmStockInstance">
import { ref, reactive, toRefs, getCurrentInstance } from 'vue'
import type { WmStockInstance, WmStockInstanceQueryParams } from '@/types/api/mes/wm/stock_instance'
import { listWmStockInstance, getWmStockInstance, addWmStockInstance, updateWmStockInstance, delWmStockInstance } from '@/api/mes/wm/stock_instance'
import QrCode from '@/components/QrCode/index.vue'
import { buildQrPayload } from '@/utils/qrPayload'
import { printQrLabels, LABEL_SPECS, labelSpecKey } from '@/utils/labelPrint'
import ItemSelect from '@/components/itemSelect/single.vue'
import WarehouseSelect from '@/components/warehouseSelect/single.vue'

const { proxy } = getCurrentInstance() as any

const STATUS_OPTIONS = [
  { value: 'IN_STOCK', label: '在库' },
  { value: 'PARTIAL', label: '部分领用' },
  { value: 'CONSUMED', label: '已用完' },
  { value: 'RETURNED', label: '已退回' },
  { value: 'SCRAPPED', label: '已报废' },
  { value: 'OUTSOURCED', label: '外协中' }
]

const instanceList = ref<WmStockInstance[]>([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref('')
const qrOpen = ref(false)
const qrRow = ref<WmStockInstance | null>(null)
const itemSelectRef = ref()
const warehouseSelectRef = ref()
const formRef = ref()

const data = reactive({
  form: {} as WmStockInstance,
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    instanceCode: undefined,
    itemCode: undefined,
    itemName: undefined,
    batchCode: undefined,
    status: undefined
  } as WmStockInstanceQueryParams,
  rules: {
    itemId: [{ required: true, message: '请选择物料', trigger: 'change' }],
    originalQuantity: [{ required: true, message: '请输入入库数量', trigger: 'blur' }],
    quantityUom: [{ required: true, message: '请输入主单位', trigger: 'blur' }]
  }
})

const { queryParams, form, rules } = toRefs(data)

function statusText(s?: string) {
  return STATUS_OPTIONS.find(o => o.value === s)?.label || s || '-'
}

function statusTagType(s?: string) {
  const map: Record<string, string> = {
    IN_STOCK: 'success',
    PARTIAL: 'warning',
    CONSUMED: 'info',
    RETURNED: 'warning',
    SCRAPPED: 'danger',
    OUTSOURCED: 'primary'
  }
  return map[s || ''] || 'info'
}

function fmtQty(v: any) {
  if (v === null || v === undefined || v === '') return '-'
  const n = Number(v)
  if (Number.isNaN(n)) return String(v)
  return n.toFixed(2).replace(/\.00$/, '')
}

function extSummary(ext: any) {
  if (!ext || typeof ext !== 'object') return '-'
  return Object.keys(ext).map(k => `${k}:${ext[k]}`).join(' · ') || '-'
}

function getList() {
  loading.value = true
  listWmStockInstance(queryParams.value).then((res: any) => {
    instanceList.value = res.rows
    total.value = res.total
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

function resetQuery() {
  proxy.resetForm('queryRef')
  handleQuery()
}

function handleSelectionChange(selection: WmStockInstance[]) {
  ids.value = selection.map(item => item.instanceId!) as number[]
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function resetForm() {
  form.value = {
    instanceId: undefined,
    instanceCode: '',
    itemId: undefined,
    itemName: '',
    originalQuantity: undefined,
    remainingQuantity: undefined,
    quantityUom: 'KG',
    instanceType: '',
    batchCode: '',
    warehouseId: undefined,
    warehouseName: '',
    status: 'IN_STOCK',
    vendorInstanceNo: '',
    remark: ''
  } as any
  proxy.resetForm('formRef')
}

function handleAdd() {
  resetForm()
  title.value = '期初建件'
  open.value = true
}

function handleUpdate(row: WmStockInstance) {
  resetForm()
  getWmStockInstance(row.instanceId!).then((res: any) => {
    form.value = res.data
    title.value = '修改实物实例'
    open.value = true
  })
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (!valid) return
    const isAdd = !form.value.instanceId
    const fn = isAdd ? addWmStockInstance(form.value) : updateWmStockInstance(form.value)
    fn.then(() => {
      proxy.$modal.msgSuccess('保存成功')
      open.value = false
      getList()
    })
  })
}

function handleDelete(row?: WmStockInstance) {
  const delIds = row?.instanceId ? [row.instanceId] : ids.value
  proxy.$modal.confirm('确认删除选中的实物实例？删除后该件的收发痕迹将无法追溯。').then(() => {
    return delWmStockInstance(delIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess('删除成功')
  }).catch(() => {})
}

function openItemPicker() { itemSelectRef.value?.open() }
function openWarehousePicker() { warehouseSelectRef.value?.open() }

function onItemSelected(item: any) {
  if (!item) return
  form.value.itemId = item.itemId
  form.value.itemName = `${item.itemName} (${item.itemCode})`
  form.value.itemCode = item.itemCode
  form.value.specification = item.specification
  form.value.quantityUom = item.unitOfMeasure || form.value.quantityUom
  if (!form.value.instanceType) form.value.instanceType = item.unit2 || ''
}

function onWarehouseSelected(w: any) {
  if (!w) return
  form.value.warehouseId = w.warehouseId
  form.value.warehouseCode = w.warehouseCode
  form.value.warehouseName = w.warehouseName
}

function handleQrCode(row: WmStockInstance) {
  qrRow.value = row
  qrOpen.value = true
}

async function handlePrintLabel() {
  if (!qrRow.value) return
  const r = qrRow.value
  const channel = await printQrLabels({
    title: '实物标签打印',
    items: [{
      payload: buildQrPayload('ROLL', r.instanceCode || ''),
      headline: r.instanceCode || '',
      fields: [
        `${r.itemName || ''} ${r.specification || ''}`.trim(),
        `剩余: ${fmtQty(r.remainingQuantity)} ${r.quantityUom || ''}`,
        `仓库: ${r.warehouseName || ''} · 状态: ${statusText(r.status)}`
      ]
    }]
  })
  if (channel === 'clodop') proxy.$modal.msgSuccess('已发送到标签打印机')
}

getList()
</script>

<style scoped>
.sub-text { color: #999; font-size: 12px; }
.qty-zero { color: #c0c4cc; }
.mb8 { margin-bottom: 8px; }
</style>
