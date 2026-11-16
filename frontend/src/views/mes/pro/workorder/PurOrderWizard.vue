<template>
  <el-dialog v-model="visible" title="采购单快捷创建" width="1150px" append-to-body @open="load">
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
      <el-table-column label="供应商" width="190" align="center">
        <template #default="s">
          <el-select v-model="s.row.vendorId" size="small" filterable clearable placeholder="待定"
            style="width:100%" @change="onVendorChange(s.row)">
            <el-option v-for="o in (s.row.vendorOptions || [])" :key="o.vendorId"
              :label="(o.vendorName || ('供应商-' + o.vendorId)) + (o.isPreferred === 'Y' ? '（首选）' : '')" :value="o.vendorId" />
          </el-select>
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
      <el-alert :title="'将生成 ' + Object.keys(groupedChecked).length + ' 张采购单（' + checked.length + ' 种物料）'" type="info" :closable="false" show-icon style="margin-bottom:10px" />
      <div v-for="(g, vid) in groupedChecked" :key="vid" style="margin-bottom:6px;font-size:13px">
        PO：<b>{{ g[0].vendorName || '待定供应商' }}</b>
        — 小计 {{ money(groupAmount(g)) }}
        <div style="color:#909399;padding-left:12px">
          <span v-for="(l,i) in g" :key="i">{{ l.itemName }} {{ l.recommendedQty }}{{ l.unitName }} × {{ l.unitPrice || 0 }}<span v-if="i < g.length-1">、</span></span>
        </div>
      </div>
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
import { ref, computed, watch, nextTick } from 'vue'
import { loadPurOrderWizard, submitPurOrderWizard } from '@/api/mes/pro/kit'
import { getWorkorder } from '@/api/mes/pro/workorder'
import { listBomByWorkorderId } from '@/api/mes/pro/workorderbom'
import { listItemVendor } from '@/api/mes/md/itemvendor'
import ItemSelect from '@/components/itemSelect/single.vue'
import { ElMessage } from 'element-plus'

const props = defineProps<{ modelValue: boolean; workorderId: number | null }>()
const emit = defineEmits<{ (e: 'update:modelValue', v: boolean): void; (e: 'refresh'): void }>()

const visible = ref(false)
const lines = ref<any[]>([])
const tableRef = ref()
const itemSelectRef = ref()
const workorder = ref<any>({})
const bomLines = ref<any[]>([])
const checked = ref<any[]>([])
const submitting = ref(false)

watch(() => props.modelValue, (v: boolean) => { visible.value = v })
watch(visible, (v: boolean) => { emit('update:modelValue', v) })

function load() {
  if (!props.workorderId) return
  getWorkorder(props.workorderId).then((r: any) => { workorder.value = r.data || {} }).catch(() => {})
  listBomByWorkorderId(props.workorderId).then((r: any) => { bomLines.value = r.data || r.rows || [] }).catch(() => {})
  loadPurOrderWizard(props.workorderId).then((r: any) => {
    lines.value = (r.data?.lines || []).map((l: any) => ({
      ...l,
      unitPrice: l.unitPrice != null ? Number(l.unitPrice) : 0,
      taxRate: l.taxRate != null ? Number(l.taxRate) : 0,
      amount: l.amount != null ? Number(l.amount) : 0
    }))
    // 默认勾选有供应商、未生成PO、有推荐数量的行
    nextTick(() => {
      lines.value.forEach((row: any) => {
        if (row.checked && row.recommendedQty > 0 && !row.hasExistingPO) tableRef.value?.toggleRowSelection(row, true)
      })
    })
  }).catch(() => {})
}

function handleSelection(rows: any[]) { checked.value = rows }

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
  } catch (e) { /* 无供应商权限时保持待定 */ }
  const preferred = vendorOptions.find((v: any) => v.isPreferred === 'Y')
  const row: any = {
    itemId: item.itemId, itemCode: item.itemCode, itemName: item.itemName,
    unitOfMeasure: item.unitOfMeasure, unitName: item.unitName,
    shortageQty: 0, recommendedQty: qty > 0 ? qty : 1,
    vendorOptions, vendorId: preferred?.vendorId ?? null,
    vendorCode: preferred?.vendorCode ?? null, vendorName: preferred?.vendorName ?? null,
    itemDefaultPrice: item.defaultPurchasePrice, itemDefaultTaxRate: item.defaultTaxRate,
    unitPrice: preferred?.purchasePrice ?? item.defaultPurchasePrice ?? 0,
    taxRate: preferred?.taxRate ?? item.defaultTaxRate ?? 0,
    hasExistingPO: false
  }
  recalcAmount(row)
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

/** 切换供应商：优先带出该供应商报价，未维护则回落物料默认价 */
function onVendorChange(row: any) {
  const opt = (row.vendorOptions || []).find((v: any) => v.vendorId === row.vendorId)
  if (opt) {
    row.vendorCode = opt.vendorCode
    row.vendorName = opt.vendorName
    row.unitPrice = opt.purchasePrice != null ? Number(opt.purchasePrice)
      : (row.itemDefaultPrice != null ? Number(row.itemDefaultPrice) : 0)
    row.taxRate = opt.taxRate != null ? Number(opt.taxRate)
      : (row.itemDefaultTaxRate != null ? Number(row.itemDefaultTaxRate) : 0)
  } else {
    // 清空 = 待定供应商，价格回落物料默认价
    row.vendorCode = null
    row.vendorName = null
    row.unitPrice = row.itemDefaultPrice != null ? Number(row.itemDefaultPrice) : 0
    row.taxRate = row.itemDefaultTaxRate != null ? Number(row.itemDefaultTaxRate) : 0
  }
  recalcAmount(row)
}

function money(v: any) {
  return Number(v || 0).toFixed(2)
}

function groupAmount(g: any[]) {
  return g.reduce((sum: number, l: any) => sum + Number(l.amount || 0), 0)
}

const groupedChecked = computed(() => {
  const g: Record<number, any[]> = {}
  for (const l of checked.value) { const vid = l.vendorId || 0; (g[vid] ||= []).push(l) }
  return g
})

const totalAmount = computed(() => checked.value.reduce((sum: number, l: any) => sum + Number(l.amount || 0), 0))

const missingPriceCount = computed(() => checked.value.filter((l: any) => Number(l.unitPrice || 0) <= 0).length)

function submit() {
  if (!props.workorderId || checked.value.length === 0) return
  // 构建提交行：数量/供应商/单价/税率均取用户当前编辑值，金额由后端复核
  const payload = checked.value.map((l: any) => ({
    itemId: l.itemId, itemCode: l.itemCode, itemName: l.itemName,
    unitOfMeasure: l.unitOfMeasure || l.unitName, unitName: l.unitName,
    vendorId: l.vendorId || null, vendorCode: l.vendorCode, vendorName: l.vendorName,
    quantity: l.recommendedQty,
    unitPrice: l.unitPrice, taxRate: l.taxRate, amount: l.amount
  }))
  submitting.value = true
  submitPurOrderWizard(props.workorderId, payload).then((r: any) => {
    ElMessage.success(r.data?.message || '采购单已生成')
    visible.value = false
    emit('refresh')
  }).catch(() => {}).finally(() => { submitting.value = false })
}
</script>

<style scoped>
.line-actions { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
.line-tip { color: #909399; font-size: 12px; margin-left: 4px; }
</style>
