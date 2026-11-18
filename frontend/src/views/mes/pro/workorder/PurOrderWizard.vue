<template>
  <el-dialog v-model="visible" title="采购单快捷创建" width="1150px" append-to-body @open="load">
    <!-- 采购单主表 -->
    <el-form :model="form" label-width="100px" size="small" class="pur-order-form">
      <el-row>
        <el-col :span="8">
          <el-form-item label="单据编号">
            <el-input v-model="form.orderCode" readonly placeholder="保存后自动生成" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="单据名称">
            <el-input v-model="form.orderName" placeholder="单据名称" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="采购类型">
            <el-select v-model="form.purchaseType" clearable placeholder="请选择" style="width:100%">
              <el-option v-for="d in (mes_purchase_type || [])" :key="d.value" :label="d.label" :value="d.value" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="8">
          <el-form-item label="供应商" required>
            <el-input v-model="form.vendorName" readonly placeholder="请选择供应商" @click="openVendor">
              <template #append><el-button icon="Search" @click.stop="openVendor" /></template>
            </el-input>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="下单日期">
            <el-date-picker v-model="form.orderDate" type="date" value-format="YYYY-MM-DD"
              placeholder="请选择下单日期" style="width:100%" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="预计到货">
            <el-date-picker v-model="form.expectedDate" type="date" value-format="YYYY-MM-DD"
              placeholder="请选择预计到货日期" style="width:100%" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="8">
          <el-form-item label="采购人">
            <el-select v-model="form.purchaser" clearable filterable placeholder="请选择采购人" style="width:100%">
              <el-option v-for="u in userOptions" :key="u.userName" :label="u.nickName || u.userName" :value="u.userName" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="关联客户订单">
            <el-select v-model="form.sourceOrderCode" clearable filterable placeholder="请选择销售订单" style="width:100%">
              <el-option v-for="so in salOrderOptions" :key="so.orderId"
                :label="so.orderCode + (so.orderName ? ' / ' + so.orderName : '')" :value="so.orderCode" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="采购金额">
            <el-input :model-value="money(totalAmount)" readonly placeholder="自动统计" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="24">
          <el-form-item label="备注">
            <el-input v-model="form.remark" type="textarea" :rows="2" placeholder="备注" />
          </el-form-item>
        </el-col>
      </el-row>
    </el-form>

    <VendorSelect ref="vendorSelectRef" @onSelected="onVendorSelected" />

    <el-divider content-position="left">采购明细</el-divider>
    <div class="line-actions">
      <el-button plain icon="Plus" size="small" @click="itemSelectRef?.open()">添加物料</el-button>
      <el-button plain icon="Box" size="small" :disabled="!workorder.productId" @click="addProductLine">加入产品本身</el-button>
      <el-button plain icon="Document" size="small" @click="addBomLines(false)">加入产品BOM</el-button>
      <el-button plain icon="Document" size="small" @click="addBomLines(true)">加入工序BOM</el-button>
      <span class="line-tip">可采购任意物料；缺口行已默认勾选</span>
    </div>
    <el-table :data="lines" size="small" border ref="tableRef" @selection-change="handleSelection">
      <el-table-column type="selection" width="45" />
      <el-table-column label="物料编码" prop="itemCode" width="130" align="center"  :show-overflow-tooltip="true" />
      <el-table-column label="物料名称" prop="itemName" :show-overflow-tooltip="true" min-width="120" />
      <el-table-column label="缺口" width="95" align="center">
        <template #default="s">{{ s.row.shortageQty }} {{ s.row.unitName }}</template>
      </el-table-column>
      <el-table-column label="采购数量" width="120" align="center">
        <template #default="s">
          <el-input-number v-model="s.row.recommendedQty" :min="0" :precision="4" size="small"
            controls-position="right" style="width:100px" @change="recalcAmount(s.row)" />
        </template>
      </el-table-column>
      <el-table-column label="单价(元/单位)" width="125" align="center">
        <template #default="s">
          <el-input-number v-model="s.row.unitPrice" :min="0" :precision="4" size="small"
            controls-position="right" placeholder="未维护" style="width:105px" @change="recalcAmount(s.row)" />
        </template>
      </el-table-column>
      <el-table-column label="税率%" width="105" align="center">
        <template #default="s">
          <el-input-number v-model="s.row.taxRate" :min="0" :max="100" :precision="2" size="small"
            controls-position="right" style="width:80px" />
        </template>
      </el-table-column>
      <el-table-column label="金额(不含税)" width="115" align="center">
        <template #default="s">{{ money(s.row.amount) }}</template>
      </el-table-column>
      <el-table-column label="状态" width="110" align="center">
        <template #default="s">
          <el-tag v-if="s.row.hasExistingPO" type="success" size="small">已生成 {{ s.row.existingPOCode }}</el-tag>
          <el-tag v-else type="info" size="small">未生成</el-tag>
        </template>
      </el-table-column>
    </el-table>

    <ItemSelect ref="itemSelectRef" @onSelected="onItemSelected" />

    <el-divider />
    <div v-if="checked.length === 0" style="color:#909399;text-align:center;padding:12px">请勾选需要采购的物料</div>
    <div v-else>
      <el-alert v-if="missingPriceCount > 0" type="warning" :closable="false" show-icon style="margin-bottom:10px"
        :title="missingPriceCount + ' 项未维护参考价，可先草稿生成后补价（审批前必须填写单价）'" />
      <el-alert :title="'将生成 1 张采购单（' + checked.length + ' 种物料）'" type="info" :closable="false" show-icon style="margin-bottom:10px" />
      <div style="text-align:right;font-size:13px">合计金额：<b>{{ money(totalAmount) }}</b></div>
    </div>

    <template #footer>
      <el-button @click="visible = false">取 消</el-button>
      <el-button type="primary" :disabled="checked.length===0" :loading="submitting" @click="submit">
        确认生成（{{ checked.length }} 项）
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, computed, watch, nextTick, getCurrentInstance } from 'vue'
import { loadPurOrderWizard, submitPurOrderWizard } from '@/api/mes/pro/kit'
import { getWorkorder } from '@/api/mes/pro/workorder'
import { listBomByWorkorderId } from '@/api/mes/pro/workorderbom'
import { listItemVendor } from '@/api/mes/md/itemvendor'
import { genSerialCode } from '@/api/mes/sys/autocoderule'
import { listUser } from '@/api/system/user'
import { listAllOrder } from '@/api/mes/sal/order'
import ItemSelect from '@/components/itemSelect/single.vue'
import VendorSelect from '@/components/vendorSelect/single.vue'
import useUserStore from '@/store/modules/user'
import { ElMessage } from 'element-plus'

const { proxy } = getCurrentInstance() as any
const { mes_purchase_type } = proxy.useDict('mes_purchase_type')

const props = defineProps<{ modelValue: boolean; workorderId: number | null }>()
const emit = defineEmits<{ (e: 'update:modelValue', v: boolean): void; (e: 'refresh'): void }>()

const visible = ref(false)
const lines = ref<any[]>([])
const tableRef = ref()
const itemSelectRef = ref()
const vendorSelectRef = ref()
const workorder = ref<any>({})
const bomLines = ref<any[]>([])
const checked = ref<any[]>([])
const submitting = ref(false)
const userOptions = ref<any[]>([])
const salOrderOptions = ref<any[]>([])
const form = ref<any>({
  orderCode: '', orderName: '', purchaseType: '', vendorId: null, vendorCode: null, vendorName: '',
  orderDate: '', expectedDate: '', purchaser: '', sourceOrderCode: '', currency: 'CNY', remark: ''
})

watch(() => props.modelValue, (v: boolean) => { visible.value = v })
watch(visible, (v: boolean) => { emit('update:modelValue', v) })

function today() {
  const d = new Date()
  return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0')
}

function resetHeader() {
  form.value = {
    orderCode: '', orderName: '', purchaseType: '', vendorId: null, vendorCode: null, vendorName: '',
    orderDate: today(), expectedDate: '', purchaser: useUserStore().name || '',
    sourceOrderCode: '', currency: 'CNY', remark: ''
  }
  genSerialCode('PUR_ORDER_CODE').then((r: any) => { form.value.orderCode = r.data }).catch(() => {})
  loadUserOptions()
  loadSalOrderOptions()
}

function loadUserOptions() {
  listUser({ pageSize: 999 }).then((r: any) => { userOptions.value = r.rows || [] }).catch(() => {})
}

function loadSalOrderOptions() {
  listAllOrder().then((r: any) => { salOrderOptions.value = r.data || [] }).catch(() => {})
}

function load() {
  if (!props.workorderId) return
  resetHeader()
  lines.value = []
  checked.value = []
  bomLines.value = []
  workorder.value = {}
  getWorkorder(props.workorderId).then((r: any) => {
    workorder.value = r.data || {}
    const wo = workorder.value
    form.value.orderName = wo.workorderName ? wo.workorderName + '-采购' : ''
    form.value.sourceOrderCode = wo.clientOrderCode || ''
  }).catch(() => {})
  listBomByWorkorderId(props.workorderId).then((r: any) => { bomLines.value = r.data || r.rows || [] }).catch(() => {})
  loadPurOrderWizard(props.workorderId).then((r: any) => {
    lines.value = (r.data?.lines || []).map((l: any) => ({
      ...l,
      unitPrice: l.unitPrice != null ? Number(l.unitPrice) : 0,
      taxRate: l.taxRate != null ? Number(l.taxRate) : 0,
      amount: l.amount != null ? Number(l.amount) : 0
    }))
    // 默认带出首个推荐供应商作为统一供应商
    const firstVendorLine = lines.value.find((l: any) => l.vendorId)
    if (firstVendorLine) {
      form.value.vendorId = firstVendorLine.vendorId
      form.value.vendorCode = firstVendorLine.vendorCode
      form.value.vendorName = firstVendorLine.vendorName
      lines.value.forEach((row: any) => applyVendorPrice(row))
    }
    // 默认勾选未生成PO且有推荐数量的行
    nextTick(() => {
      lines.value.forEach((row: any) => {
        if (row.recommendedQty > 0 && !row.hasExistingPO) tableRef.value?.toggleRowSelection(row, true)
      })
    })
  }).catch(() => {})
}

function handleSelection(rows: any[]) { checked.value = rows }

function openVendor() { vendorSelectRef.value?.open(form.value.vendorId || undefined) }

/** 选择供应商：统一应用到所有明细，并按该供应商报价刷新单价 */
function onVendorSelected(row: any) {
  if (!row) return
  form.value.vendorId = row.vendorId
  form.value.vendorCode = row.vendorCode
  form.value.vendorName = row.vendorName
  lines.value.forEach((l: any) => applyVendorPrice(l))
}

/** 按当前供应商报价刷新行单价/税率，未维护则回落物料默认价 */
function applyVendorPrice(row: any) {
  const opt = (row.vendorOptions || []).find((v: any) => v.vendorId === form.value.vendorId)
  row.unitPrice = opt?.purchasePrice != null ? Number(opt.purchasePrice)
    : (row.itemDefaultPrice != null ? Number(row.itemDefaultPrice) : 0)
  row.taxRate = opt?.taxRate != null ? Number(opt.taxRate)
    : (row.itemDefaultTaxRate != null ? Number(row.itemDefaultTaxRate) : 0)
  recalcAmount(row)
}

/** 任意物料加入采购明细；同一物料去重并自动勾选 */
async function addLineFromItem(item: any, qty: number) {
  if (!item?.itemId) return
  const exist = lines.value.find((l: any) => l.itemId === item.itemId)
  if (exist) {
    nextTick(() => tableRef.value?.toggleRowSelection(exist, true))
    return
  }
  let vendorOptions: any[] = []
  try {
    const res: any = await listItemVendor({ itemId: item.itemId, enableFlag: '1', pageNum: 1, pageSize: 100 })
    vendorOptions = (res.rows || []).map((v: any) => ({ ...v }))
  } catch (e) { /* 无供应商权限时按物料默认价 */ }
  const row: any = {
    itemId: item.itemId, itemCode: item.itemCode, itemName: item.itemName,
    unitOfMeasure: item.unitOfMeasure, unitName: item.unitName,
    shortageQty: 0, recommendedQty: qty > 0 ? qty : 1,
    vendorOptions,
    itemDefaultPrice: item.defaultPurchasePrice, itemDefaultTaxRate: item.defaultTaxRate,
    unitPrice: item.defaultPurchasePrice != null ? Number(item.defaultPurchasePrice) : 0,
    taxRate: item.defaultTaxRate != null ? Number(item.defaultTaxRate) : 0,
    hasExistingPO: false
  }
  applyVendorPrice(row)
  lines.value.push(row)
  nextTick(() => tableRef.value?.toggleRowSelection(row, true))
}

function onItemSelected(row: any) { if (row) addLineFromItem(row, 1) }

function addProductLine() {
  const wo = workorder.value
  if (!wo?.productId) { ElMessage.warning('工单未关联产品'); return }
  addLineFromItem({
    itemId: wo.productId, itemCode: wo.productCode, itemName: wo.productName,
    unitOfMeasure: wo.unitOfMeasure, unitName: wo.unitName
  }, Number(wo.quantity || 1))
}

/** 产品BOM = 工单BOM中 processId 为空的行；工序BOM = 带 processId 的行 */
function addBomLines(processBom: boolean) {
  const qty = Number(workorder.value.quantity || 1)
  const rows = bomLines.value.filter((b: any) => processBom ? !!b.processId : !b.processId)
  if (!rows.length) { ElMessage.info(processBom ? '工序BOM无物料' : '产品BOM无物料'); return }
  rows.forEach((b: any) => addLineFromItem(b, Number(b.quantity || 0) * qty))
}

/** 金额 = 采购数量 × 单价（不含税，2 位小数） */
function recalcAmount(row: any) {
  const qty = Number(row.recommendedQty || 0)
  const price = Number(row.unitPrice || 0)
  row.amount = Math.round(qty * price * 100) / 100
}

function money(v: any) {
  return Number(v || 0).toFixed(2)
}

const totalAmount = computed(() => checked.value.reduce((sum: number, l: any) => sum + Number(l.amount || 0), 0))

const missingPriceCount = computed(() => checked.value.filter((l: any) => Number(l.unitPrice || 0) <= 0).length)

function submit() {
  if (!props.workorderId) return
  if (!form.value.vendorId) { ElMessage.warning('请选择供应商'); return }
  if (checked.value.length === 0) { ElMessage.warning('请勾选需要采购的物料'); return }
  const submitLines = checked.value.filter((l: any) => Number(l.recommendedQty || 0) > 0)
  if (submitLines.length === 0) { ElMessage.warning('采购数量必须大于 0'); return }
  // 构建提交体：主表信息 + 用户当前编辑的物料行，金额由后端复核
  const payload = {
    orderCode: form.value.orderCode,
    orderName: form.value.orderName,
    vendorId: form.value.vendorId,
    vendorCode: form.value.vendorCode,
    vendorName: form.value.vendorName,
    purchaseType: form.value.purchaseType || null,
    orderDate: form.value.orderDate || null,
    expectedDate: form.value.expectedDate || null,
    purchaser: form.value.purchaser,
    sourceOrderCode: form.value.sourceOrderCode,
    currency: form.value.currency || 'CNY',
    remark: form.value.remark,
    lines: submitLines.map((l: any) => ({
      itemId: l.itemId, itemCode: l.itemCode, itemName: l.itemName,
      unitOfMeasure: l.unitOfMeasure || l.unitName, unitName: l.unitName,
      quantity: l.recommendedQty,
      unitPrice: l.unitPrice, taxRate: l.taxRate, amount: l.amount
    }))
  }
  submitting.value = true
  submitPurOrderWizard(props.workorderId, payload).then((r: any) => {
    ElMessage.success(r.data?.message || '采购单已生成')
    visible.value = false
    emit('refresh')
  }).catch(() => {}).finally(() => { submitting.value = false })
}
</script>

<style scoped>
.pur-order-form :deep(.el-form-item__label) { padding-right: 16px !important; }
.line-actions { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
.line-tip { color: #909399; font-size: 12px; margin-left: 4px; }
</style>
