<template>
  <div class="app-container wo-edit">
    <div class="page-head">
      <div class="head-left">
        <el-button icon="ArrowLeft" @click="goBack">返回</el-button>
        <span class="page-title">{{ pageTitle }}</span>
        <el-tag v-if="form.workorderCode" size="small" type="success">{{ form.workorderCode }}</el-tag>
      </div>
      <div class="head-right" v-if="!readonly">
        <el-button @click="goBack">取 消</el-button>
        <el-button type="primary" :loading="submitting" @click="submit">保 存</el-button>
      </div>
    </div>

    <el-tabs v-model="activeTab">
      <el-tab-pane label="主工单" name="base">
        <el-form ref="formRef" :model="form" :rules="rules" label-width="110px" :disabled="readonly">
          <el-row :gutter="12">
            <el-col :span="8">
              <el-form-item label="工单编码" prop="workorderCode">
                <el-input v-model="form.workorderCode" placeholder="请输入" :disabled="mode === 'edit' || mode === 'view'">
                  <template #append v-if="mode === 'add' || mode === 'copy'">
                    <el-switch v-model="autoGen" size="small" @change="onAutoGen" />
                  </template>
                </el-input>
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item label="工单名称" prop="workorderName">
                <el-input v-model="form.workorderName" placeholder="请输入" />
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item label="工单类型">
                <el-radio-group v-model="form.workorderType">
                  <el-radio value="SELF">自制</el-radio>
                  <el-radio value="OUTSOURCE">外协</el-radio>
                </el-radio-group>
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="12">
            <el-col :span="8">
              <el-form-item label="产品" prop="productId">
                <el-input :model-value="productLabel" readonly placeholder="请选择产品">
                  <template #append><el-button icon="Search" @click="itemRef?.open()" :disabled="readonly" /></template>
                </el-input>
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item label="工艺路线">
                <el-select v-model="routeProductId" placeholder="请选择" style="width:100%" filterable @change="onRouteChange">
                  <el-option v-for="r in routeOptions" :key="r.recordId"
                    :label="(r._routeName || '路线#' + r.routeId) + ' — ' + r.itemName" :value="r.recordId" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item label="负责人" prop="ownerId">
                <el-select v-model="form.ownerId" filterable remote clearable :remote-method="searchOwners"
                  :loading="ownerLoading" placeholder="请选择" style="width:100%">
                  <el-option v-for="u in ownerOptions" :key="u.userId" :label="u.nickName || u.userName" :value="u.userId" />
                </el-select>
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="12">
            <el-col :span="8">
              <el-form-item label="计划数量" prop="quantity">
                <el-input-number v-model="form.quantity" :min="1" style="width:100%" />
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item label="需求日期" prop="requestDate">
                <el-date-picker v-model="form.requestDate" type="date" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" />
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item label="客户订单号">
                <el-input v-model="form.clientOrderCode" placeholder="客户PO号" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="12">
            <el-col :span="8">
              <el-form-item label="产品尺寸">
                <el-input v-model="form.productSize" placeholder="如254*127*330mm" />
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item label="订单类型">
                <el-select v-model="form.orderType" style="width:100%">
                  <el-option v-for="d in orderTypeOptions" :key="d.dictValue" :label="d.dictLabel" :value="d.dictValue" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item label="来源销售订单">
                <el-input v-if="mode !== 'copy'" v-model="form.sourceCode" readonly placeholder="自动带入" />
                <el-input v-else :model-value="sourceOrderLabel" readonly placeholder="点击选择销售订单行"
                  style="cursor:pointer" @click="openOrderPicker">
                  <template #append>
                    <el-button icon="Search" @click.stop="openOrderPicker" />
                    <el-button v-if="form.sourceCode || form.salesOrderLineId" icon="Close" @click.stop="clearOrderLink" />
                  </template>
                </el-input>
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="12">
            <el-col :span="24">
              <el-form-item label="印刷要求"><el-input v-model="form.printingReq" placeholder="如1色满版黑印刷" /></el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="12">
            <el-col :span="24">
              <el-form-item label="包装要求"><el-input v-model="form.packageReq" placeholder="如250个/箱,贴唛头" /></el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="12">
            <el-col :span="24">
              <el-form-item label="发货要求"><el-input v-model="form.shippingReq" placeholder="分批发货、指定物流" /></el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="12">
            <el-col :span="24">
              <el-form-item label="产品图片">
                <image-upload v-model="form.productImage" :limit="1" :disabled="readonly" class="img-100" />
                <span class="tip">导出采购单/加工单时作为单据底部图片</span>
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="12">
            <el-col :span="24">
              <el-form-item label="备注"><el-input v-model="form.remark" type="textarea" :rows="2" /></el-form-item>
            </el-col>
          </el-row>

          <template v-if="productAttrs.length">
            <el-divider content-position="left">产品属性</el-divider>
            <ExtAttrForm ref="extAttrRef" :schema="attrSchema" v-model="form.lineAttrs" :readonly="readonly" scope="PRODUCT" :columns="3" sortable />
          </template>
          <template v-if="productionAttrs.length">
            <el-divider content-position="left">生产属性</el-divider>
            <ExtAttrForm :schema="attrSchema" v-model="form.lineAttrs" :readonly="readonly" scope="PRODUCTION" :columns="3" sortable />
          </template>
        </el-form>

        <el-divider content-position="left">工艺路线与工序（开单配置）</el-divider>
        <WorkorderRouteEditor v-model="routeProcesses" :process-options="processOptions"
          :config="routeConfig" :default-qty="form.quantity" :readonly="readonly" />
      </el-tab-pane>

      <el-tab-pane name="docs">
        <template #label>
          单据配置
          <el-badge v-if="docCount" :value="docCount" class="doc-badge" />
        </template>
        <div class="doc-toolbar" v-if="!readonly">
          <el-button type="primary" icon="MagicStick" @click="generateDocs">根据配置生成单据</el-button>
          <span class="tip">按「开单类型 + 供应商」自动合并生成，生成后仍可手动调整</span>
        </div>
        <WorkorderDocPanel v-model:purchase-docs="purchaseDocs" v-model:process-docs="processDocs"
          :process-options="routeProcesses" :readonly="readonly" />
      </el-tab-pane>
    </el-tabs>

    <ItemSelect ref="itemRef" @onSelected="onProductSelected" />

    <el-dialog title="选择销售订单明细行" v-model="orderPickerOpen" width="860px" append-to-body>
      <el-alert title="默认展示当前来源订单及同产品明细行；可转数量为 0 的行不可选择" type="info" :closable="false" show-icon style="margin-bottom:12px" />
      <el-form inline>
        <el-form-item label="销售订单">
          <el-select v-model="pickerOrderId" filterable remote clearable :remote-method="searchOrders" :loading="orderLoading"
            placeholder="输入订单号搜索" style="width:360px" @change="onPickerOrderChange">
            <el-option v-for="o in orderOptions" :key="o.orderId" :label="o.orderCode + ' — ' + (o.clientName || o.orderName || '')" :value="o.orderId" />
          </el-select>
        </el-form-item>
      </el-form>
      <el-table :data="pickerLines" size="small" border highlight-current-row @row-click="pickOrderLine" style="cursor:pointer">
        <el-table-column label="产品" prop="productName" min-width="160" :show-overflow-tooltip="true" />
        <el-table-column label="订单数" prop="quantity" width="90" align="center" />
        <el-table-column label="已转" prop="quantityProduced" width="90" align="center" />
        <el-table-column label="可转" prop="quantityConvertible" width="90" align="center" />
        <el-table-column label="交期" prop="requestDate" width="150" align="center" :show-overflow-tooltip="true" />
      </el-table>
      <el-empty v-if="pickerOrderId && !pickerLines.length" description="该订单暂无可转明细行" :image-size="60" />
      <template #footer><el-button @click="orderPickerOpen = false">取 消</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, getCurrentInstance } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  createWorkorderFull, updateWorkorderFull, getWorkorderFullDetail, getWorkorderCopyTemplate
} from '@/api/mes/pro/workorderFull'
import { listOrder, getOrderDetail } from '@/api/mes/sal/order'
import { listRouteProduct, getRouteProduct, resolveRouteProduct } from '@/api/mes/pro/routeproduct'
import { listRoute } from '@/api/mes/pro/proroute'
import { listRouteProcessByRouteId } from '@/api/mes/pro/routeprocess'
import { listRouteProductBomByRouteId } from '@/api/mes/pro/routeproductbom'
import { listBom } from '@/api/mes/md/bom'
import { listAllProcess } from '@/api/mes/pro/process'
import { genSerialCode } from '@/api/mes/sys/autocoderule'
import { listUser } from '@/api/system/user'
import { getItem } from '@/api/mes/md/item'
import { getEffAttrSchema } from '@/api/mes/md/attr'
import { getDicts } from '@/api/system/dict/data'
import useUserStore from '@/store/modules/user'
import ItemSelect from '@/components/itemSelect/single.vue'
import ExtAttrForm from '@/components/ExtAttrForm/index.vue'
import WorkorderRouteEditor from './components/WorkorderRouteEditor.vue'
import WorkorderDocPanel from './components/WorkorderDocPanel.vue'

const { proxy } = getCurrentInstance() as any
const route = useRoute()
const router = useRouter()

const mode = ref<'add' | 'edit' | 'view' | 'copy'>('add')
const workorderId = ref<number | null>(null)
const activeTab = ref('base')
const submitting = ref(false)
const autoGen = ref(false)

const formRef = ref()
const extAttrRef = ref()
const itemRef = ref()

const ownerOptions = ref<any[]>([])
const ownerLoading = ref(false)
const routeOptions = ref<any[]>([])
const processOptions = ref<any[]>([])
const routeProcesses = ref<any[]>([])
const attrSchema = ref<any[]>([])
const orderTypeOptions = ref<any[]>([])
const routeProductId = ref<number | null>(null)

const purchaseDocs = ref<any[]>([])
const processDocs = ref<any[]>([])
const bomRows = ref<any[]>([])
// 复制模式下选择目标销售订单行
const orderPickerOpen = ref(false)
const orderOptions = ref<any[]>([])
const orderLoading = ref(false)
const pickerOrderId = ref<number | null>(null)
const pickerOrder = ref<any>(null)
const pickerLines = ref<any[]>([])
/** 当前工单已关联的来源订单，保证搜索时始终保留在候选中 */
const currentSourceOrder = ref<any>(null)
const routeConfig = reactive<any>({ productName: '', deliveryAddress: '', orderDate: today(), purchaser: '' })

function today() {
  const d = new Date()
  return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0')
}

/** 统一为 yyyy-MM-dd HH:mm:ss：销售明细行交期是 yyyy-MM-dd，工单需求日期要求带时分秒 */
function normalizeDateTime(v: any): string | null {
  if (!v) return null
  const s = String(v)
  return s.length === 10 ? s + ' 00:00:00' : s
}

const form = reactive<any>({
  workorderCode: null, workorderName: null, workorderType: 'SELF', orderSource: 'MANUAL',
  productId: null, productCode: null, productName: null, productSpc: null,
  unitOfMeasure: 'PCS', unitName: '个', quantity: 1, status: 'PREPARE',
  clientOrderCode: null, orderType: 'STANDARD', productSize: null, printingReq: null,
  packageReq: null, shippingReq: null, productImage: null, lineAttrs: {},
  requestDate: null, remark: null, ownerId: null, ownerName: null,
  sourceCode: null, salesOrderLineId: null, routeProductId: null
})

const rules = {
  workorderCode: [{ required: true, message: '编码不能为空', trigger: 'blur' }],
  workorderName: [{ required: true, message: '名称不能为空', trigger: 'blur' }],
  productId: [{ required: true, message: '请选择产品', trigger: 'change' }],
  ownerId: [{ required: true, message: '请选择工单负责人', trigger: 'change' }],
  quantity: [{ required: true, message: '数量不能为空', trigger: 'blur' }]
}

const readonly = computed(() => mode.value === 'view')
const pageTitle = computed(() => {
  if (mode.value === 'add') return '新增生产工单'
  if (mode.value === 'copy') return '复制生产工单'
  return mode.value === 'edit' ? '编辑生产工单' : '查看生产工单'
})
const productLabel = computed(() => (form.productName ? `${form.productName} (${form.productCode || ''})` : ''))
const sourceOrderLabel = computed(() => {
  if (!form.sourceCode) return ''
  return form.salesOrderLineId ? `${form.sourceCode} · ${form.productName || ''}` : form.sourceCode
})
const docCount = computed(() => purchaseDocs.value.length + processDocs.value.length)
/** 按属性域拆分，未配置则不展示对应版块 */
const productAttrs = computed(() => (attrSchema.value || []).filter((a: any) => (a.attrScope || 'PRODUCT') === 'PRODUCT'))
const productionAttrs = computed(() => (attrSchema.value || []).filter((a: any) => a.attrScope === 'PRODUCTION'))

onMounted(() => {
  const id = route.query.workorderId ? Number(route.query.workorderId) : null
  const sourceId = route.query.sourceWorkorderId ? Number(route.query.sourceWorkorderId) : null
  mode.value = (route.query.mode as any) || (id ? 'edit' : 'add')
  workorderId.value = id
  loadProcessOptions()
  routeConfig.purchaser = useUserStore().name || ''
  getDicts('mes_sal_order_type').then((r: any) => { orderTypeOptions.value = r.data || [] })
  searchOwners('')
  if (mode.value === 'copy' && sourceId) loadCopyTemplate(sourceId)
  else if (id) loadDetail(id)
  else initFromSalesOrder()
  if ((mode.value === 'add' || mode.value === 'copy') && !form.workorderCode) form.workorderCode = ''
})

function loadProcessOptions() {
  listAllProcess().then((r: any) => { processOptions.value = r.data || [] })
}

function initFromSalesOrder() {
  const q = route.query
  if (!q.sourceOrderCode && !q.productId) return
  form.sourceCode = (q.sourceOrderCode as string) || null
  form.clientOrderCode = (q.clientOrderCode as string) || null
  form.salesOrderLineId = q.salesOrderLineId ? Number(q.salesOrderLineId) : null
  form.quantity = q.quantity ? Number(q.quantity) : 1
  form.requestDate = normalizeDateTime(q.requestDate)
  if (q.orderType) form.orderType = q.orderType as string
  if (q.productId) {
    onProductSelected({
      itemId: Number(q.productId), itemCode: q.productCode, itemName: q.productName,
      specification: q.productSpc, unitOfMeasure: q.unitOfMeasure, unitName: q.unitName
    })
    return
  }
  if (q.sourceOrderCode) loadSalesOrderPrefill(q.sourceOrderCode as string, form.salesOrderLineId)
}

/** 按销售订单预填工单：产品/路线/名称/交期/尺寸/印刷/包装/发货/备注/图片 */
async function loadSalesOrderPrefill(orderCode: string, lineId: number | null) {
  try {
    const res: any = await listOrder({ pageNum: 1, pageSize: 10, orderCode } as any)
    const order = (res.rows || []).find((o: any) => o.orderCode === orderCode) || (res.rows || [])[0]
    if (!order) return
    const detail: any = await getOrderDetail(order.orderId)
    const lines = detail.data?.lines || []
    let line = lineId ? lines.find((l: any) => l.lineId === lineId) : null
    if (!line) line = lines.find((l: any) => Number(l.quantityConvertible ?? l.quantity ?? 0) > 0) || lines[0]
    if (!line) return
    form.sourceCode = order.orderCode
    form.orderSource = 'SALES_ORDER'
    form.clientId = order.clientId
    form.clientCode = order.clientCode
    form.clientName = order.clientName
    form.clientOrderCode = order.clientOrderCode
    form.salesperson = order.salesperson
    form.orderType = order.orderType || form.orderType
    form.salesOrderLineId = line.lineId
    form.quantity = Number(line.quantityConvertible ?? line.quantity) || 1
    form.requestDate = normalizeDateTime(line.requestDate || order.requestDate)
    form.productSize = line.productSize || line.productSpc || null
    form.printingReq = line.printingReq || null
    form.packageReq = line.packageReq || null
    // ERP 采购单没有结构化发货/补充说明字段，这两块在订单备注里以标题块存在，按标题提取
    form.shippingReq = line.shippingReq || extractRemarkSection(order.remark, '包装和出货要求')
    form.remark = line.remark || order.productionRemark
      || extractRemarkSection(order.remark, '订单补充说明') || order.remark || null
    form.workorderName = (line.mesProductName || line.productName || '') + '-' + order.orderCode
    if (line.productId) {
      const item: any = (await getItem(line.productId)).data
      await onProductSelected({
        itemId: line.productId,
        itemCode: line.productCode,
        itemName: line.mesProductName || line.productName || item?.itemName,
        specification: line.productSpc,
        unitOfMeasure: line.unitOfMeasure,
        unitName: line.unitName,
        imageUrl: item?.imageUrl
      }, true)
    }
    await prefillRouteFromLine(line, order)
  } catch (e) {
    // 预填失败不阻塞手工开单
  }
}

/** 从订单备注中按标题提取一个区块（如“包装和出货要求：xxx / 订单补充说明：xxx”） */
function extractRemarkSection(text: any, label: string): string | null {
  if (!text) return null
  const lines = String(text).split(/\r?\n/)
  const idx = lines.findIndex((l: string) => l.replace(/^[\s　]+/, '').startsWith(label))
  if (idx < 0) return null
  const first = lines[idx].replace(/^[^：:]*[：:]\s*/, '')
  const out: string[] = first ? [first] : []
  for (let i = idx + 1; i < lines.length; i++) {
    const t = lines[i].trim()
    if (/^[^\s：:]{2,16}[：:]/.test(t)) break
    if (t) out.push(t)
  }
  return out.join('\n').trim() || null
}

/** 预填销售明细的工艺路线与工序；路线不属于当前产品时按默认重新解析 */
async function prefillRouteFromLine(line: any, order: any) {
  let routeProductIdValue = line.routeProductId || null
  let routeId = null
  let routeName = line.routeName || null
  if (routeProductIdValue) {
    const rp: any = await getRouteProduct(routeProductIdValue)
    routeId = rp.data?.routeId || null
  }
  if (!routeId) {
    const r: any = await resolveRouteProduct({
      itemId: line.productId, orderType: form.orderType,
      outsourceFlag: order?.outsourceFlag, packageFlag: order?.packageFlag
    })
    if (r.data?.matched) {
      routeProductIdValue = r.data.routeProductId
      routeId = r.data.routeId
      routeName = r.data.routeName || routeName
    }
  }
  if (!routeProductIdValue) return
  routeProductId.value = routeProductIdValue
  form.routeProductId = routeProductIdValue
  if (!routeOptions.value.some((o: any) => o.recordId === routeProductIdValue)) {
    routeOptions.value.unshift({
      recordId: routeProductIdValue, routeId, itemId: form.productId, itemName: form.productName,
      routeCode: line.routeCode, _routeName: routeName || ('路线#' + routeProductIdValue)
    })
  }
  if (routeId) await loadRouteProcesses(routeId)
}

function loadDetail(id: number) {
  getWorkorderFullDetail(id).then((r: any) => {
    const d = r.data || {}
    Object.assign(form, d.workorder || {})
    form.requestDate = normalizeDateTime(form.requestDate)
    if (!form.lineAttrs) form.lineAttrs = {}
    routeProductId.value = form.routeProductId
    routeProcesses.value = d.routeProcesses || []
    bomRows.value = d.bomList || []
    routeConfig.productName = form.productName || ''
    routeConfig.orderDate = today()
    loadSchema(form.productId)
    onProductSelected({
      itemId: form.productId, itemCode: form.productCode, itemName: form.productName,
      unitOfMeasure: form.unitOfMeasure, unitName: form.unitName
    }, true)
    purchaseDocs.value = (d.purchaseDocs || []).map((x: any) => ({ ...x.order, lines: x.lines || [] }))
    processDocs.value = (d.processDocs || []).map((x: any) => ({ ...x, lines: x.processLines || [] }))
  })
}

/** 复制模板：加载源工单定义层数据，清空单号并自动生成新编码 */
function loadCopyTemplate(sourceId: number) {
  getWorkorderCopyTemplate(sourceId).then((r: any) => {
    const d = r.data || {}
    Object.assign(form, d.workorder || {})
    form.workorderId = null
    form.workorderCode = ''
    form.status = 'PREPARE'
    form.requestDate = normalizeDateTime(form.requestDate)
    if (!form.lineAttrs) form.lineAttrs = {}
    routeProductId.value = form.routeProductId
    routeProcesses.value = d.routeProcesses || []
    bomRows.value = d.bomList || []
    routeConfig.productName = form.productName || ''
    routeConfig.orderDate = today()
    loadSchema(form.productId)
    onProductSelected({
      itemId: form.productId, itemCode: form.productCode, itemName: form.productName,
      unitOfMeasure: form.unitOfMeasure, unitName: form.unitName
    }, true)
    purchaseDocs.value = (d.purchaseDocs || []).map((x: any) => ({ ...x.order, lines: x.lines || [] }))
    processDocs.value = (d.processDocs || []).map((x: any) => ({ ...x, lines: x.processLines || [] }))
    genSerialCode('WORKORDER_NO').then((res: any) => {
      form.workorderCode = res.data
      autoGen.value = true
    })
  })
}

function onAutoGen(flag: boolean) {
  if (flag) genSerialCode('WORKORDER_NO').then((r: any) => { form.workorderCode = r.data })
  else form.workorderCode = ''
}

// ─────────── 复制模式：选择目标销售订单行 ───────────

/** 打开选择器：无需先清除，自动定位并回显当前来源订单 */
async function openOrderPicker() {
  orderPickerOpen.value = true
  pickerLines.value = []
  if (!orderOptions.value.length) await searchOrders('')
  const code = form.sourceCode
  if (!code) return
  let current = orderOptions.value.find((o: any) => o.orderCode === code)
  if (!current) {
    const r: any = await listOrder({ pageNum: 1, pageSize: 10, orderCode: code } as any)
    current = (r.rows || [])[0]
    if (current) orderOptions.value = [current, ...orderOptions.value]
  }
  if (current) {
    currentSourceOrder.value = current
    pickerOrderId.value = current.orderId
    onPickerOrderChange(current.orderId)
  }
}

/** 支持按订单号或客户名称搜索；当前来源订单始终保留在候选中 */
async function searchOrders(keyword: string) {
  orderLoading.value = true
  try {
    const kw = keyword || undefined
    const [c1, c2, c3, c4]: any[] = await Promise.all([
      listOrder({ pageNum: 1, pageSize: 30, orderCode: kw, status: 'CONFIRMED' } as any),
      listOrder({ pageNum: 1, pageSize: 30, orderCode: kw, status: 'PRODUCING' } as any),
      kw ? listOrder({ pageNum: 1, pageSize: 30, clientName: kw, status: 'CONFIRMED' } as any) : Promise.resolve({ rows: [] }),
      kw ? listOrder({ pageNum: 1, pageSize: 30, clientName: kw, status: 'PRODUCING' } as any) : Promise.resolve({ rows: [] })
    ])
    const map = new Map<number, any>()
    ;[c1, c2, c3, c4].forEach((r: any) => (r.rows || []).forEach((o: any) => map.set(o.orderId, o)))
    if (currentSourceOrder.value && !map.has(currentSourceOrder.value.orderId)) {
      map.set(currentSourceOrder.value.orderId, currentSourceOrder.value)
    }
    orderOptions.value = Array.from(map.values())
  } finally {
    orderLoading.value = false
  }
}

function onPickerOrderChange(orderId: number) {
  pickerOrder.value = orderOptions.value.find((o: any) => o.orderId === orderId) || null
  pickerLines.value = []
  if (!orderId) return
  getOrderDetail(orderId).then((r: any) => {
    const all = r.data?.lines || []
    const sameProduct = all.filter((l: any) => l.productId === form.productId)
    const base = sameProduct.length ? sameProduct : all
    // 可转数量大的排前面；0 可转行保留展示用于核对来源，但点击不可选
    pickerLines.value = [...base].sort((a: any, b: any) =>
      Number(b.quantityConvertible || 0) - Number(a.quantityConvertible || 0))
    if (!all.length) ElMessage.info('该订单暂无明细行')
  })
}

/** 清除销售订单关联：复制为手工工单 */
function clearOrderLink() {
  form.sourceCode = null
  form.salesOrderLineId = null
  form.orderSource = 'MANUAL'
  purchaseDocs.value.forEach((d: any) => { d.sourceOrderCode = form.clientOrderCode })
  processDocs.value.forEach((d: any) => { d.sourceOrderCode = form.clientOrderCode })
  ElMessage.info('已清除销售订单关联，将作为手工工单保存')
}

function pickOrderLine(line: any) {
  const convertible = Number(line.quantityConvertible || 0)
  if (convertible <= 0) {
    ElMessage.warning('该明细行已无可转数量，请选择其他行')
    return
  }
  const o = pickerOrder.value || {}
  form.sourceCode = o.orderCode || form.sourceCode
  form.salesOrderLineId = line.lineId
  form.orderSource = 'SALES_ORDER'
  if (o.clientId) {
    form.clientId = o.clientId
    form.clientCode = o.clientCode
    form.clientName = o.clientName
  }
  if (o.clientOrderCode) form.clientOrderCode = o.clientOrderCode
  if (o.salesperson) form.salesperson = o.salesperson
  if (!form.quantity || Number(form.quantity) > convertible) form.quantity = convertible
  if (line.requestDate) form.requestDate = normalizeDateTime(line.requestDate)
  // 单据来源订单号随新销售订单同步
  purchaseDocs.value.forEach((d: any) => { d.sourceOrderCode = form.clientOrderCode })
  processDocs.value.forEach((d: any) => { d.sourceOrderCode = form.clientOrderCode })
  orderPickerOpen.value = false
  ElMessage.success('已关联销售订单行，可继续微调数量、交期与单据')
}

function onProductSelected(row: any, keepRoute = false) {
  if (!row) return
  form.productId = row.itemId
  form.productCode = row.itemCode
  form.productName = row.itemName
  routeConfig.productName = row.itemName
  form.productSpc = row.specification
  form.unitOfMeasure = row.unitOfMeasure
  form.unitName = row.unitName
  if (!form.productImage && row.imageUrl) form.productImage = row.imageUrl
  loadSchema(row.itemId)
  if (!keepRoute) {
    routeProductId.value = null
    routeOptions.value = []
    routeProcesses.value = []
  }
  return loadRoutes(row.itemId)
}

function loadSchema(productId: number) {
  attrSchema.value = []
  if (!productId) return
  getItem(productId).then((r: any) => {
    const item = r.data
    if (item?.itemTypeId) getEffAttrSchema(item.itemTypeId).then((s: any) => { attrSchema.value = s.data || [] })
  })
}

function loadRoutes(itemId: number) {
  return Promise.all([
    listRouteProduct({ itemId, pageSize: 100 }),
    listRoute({ pageSize: 1000 })
  ]).then(([rpRes, rtRes]: any[]) => {
    const map: Record<string, string> = {}
    ;(rtRes.rows || []).forEach((rt: any) => { map[rt.routeId] = rt.routeName || rt.routeCode })
    const bound = (rpRes.rows || []).map((rp: any) => ({ ...rp, _routeName: map[rp.routeId] }))
    if (bound.length) {
      routeOptions.value = bound
      return
    }
    // 产品未绑定工艺路线：允许选择现有任意路线，保存时后端自动建立绑定
    routeOptions.value = (rtRes.rows || []).map((rt: any) => ({
      recordId: -rt.routeId, routeId: rt.routeId, itemId, itemName: '',
      _routeName: map[rt.routeId] || ('路线#' + rt.routeId), __unbound: true
    }))
  })
}

function onRouteChange(recordId: number) {
  const rp = routeOptions.value.find((r: any) => r.recordId === recordId)
  if (!rp) return
  routeProductId.value = rp.__unbound ? null : recordId
  form.routeProductId = rp.__unbound ? null : recordId
  loadRouteProcesses(rp.routeId)
}

/** 按路线加载工序与 BOM（开单页与销售订单预填共用） */
async function loadRouteProcesses(routeId: number) {
  if (!routeId) return
  const res: any = await listRouteProcessByRouteId(routeId)
  const list = res.data || []
  routeProcesses.value = list.map((p: any, i: number) => ({
    ...p, routeId, orderNum: i + 1, docType: 'PROCESS',
    planQty: form.quantity || 0, unitPrice: 0, expectedDate: routeConfig.orderDate
  }))
  loadBomRows(routeId, form.productId)
}

function getProcessName(pid: number) {
  const p = processOptions.value.find((i: any) => i.processId === pid) || routeProcesses.value.find((i: any) => i.processId === pid)
  return p ? p.processName : pid
}

/** 加载路线BOM + 产品BOM，作为工单物料明细提交 */
function loadBomRows(routeId: number, itemId: number) {
  if (!routeId || !itemId) return
  const pids = new Set(routeProcesses.value.map((p: any) => p.processId))
  Promise.all([
    listRouteProductBomByRouteId(routeId),
    listBom({ itemId, pageSize: 999 })
  ]).then(([rb, pb]: any[]) => {
    const rows = (rb.data || [])
      .filter((b: any) => b.productId === itemId && pids.has(b.processId))
      .map((b: any) => ({
        processId: b.processId, processName: getProcessName(b.processId),
        itemId: b.itemId, itemCode: b.itemCode, itemName: b.itemName,
        unitOfMeasure: b.unitOfMeasure, unitName: b.unitName,
        itemOrProduct: b.itemOrProduct || 'RAW', quantityMode: 'PER_UNIT',
        bomSource: 'PROCESS', scrapRate: b.scrapRate || 0, quantity: b.quantity || 0
      }))
    const existing = new Set(rows.map((r: any) => r.itemId))
    const prod = (pb.rows || [])
      .filter((p: any) => !existing.has(p.bomItemId))
      .map((p: any) => ({
        processId: null, processName: '产品级原料',
        itemId: p.bomItemId, itemCode: p.bomItemCode, itemName: p.bomItemName,
        unitOfMeasure: p.unitOfMeasure, unitName: p.unitName,
        itemOrProduct: 'RAW', quantityMode: 'PER_UNIT', bomSource: 'PRODUCT',
        scrapRate: p.scrapRate || 0, quantity: p.quantity || 0
      }))
    bomRows.value = [...rows, ...prod]
  })
}

function searchOwners(kw: string) {
  ownerLoading.value = true
  listUser({ userName: kw || undefined, status: '0', pageNum: 1, pageSize: 20 })
    .then((r: any) => { ownerOptions.value = r.rows || [] })
    .finally(() => { ownerLoading.value = false })
}

/** 根据工序配置生成单据：按「开单类型 + 供应商」合并，已存在的单据只补缺失明细，不覆盖/删除 */
function generateDocs() {
  const rows = routeProcesses.value.filter((r: any) => r.vendorId)
  if (!rows.length) {
    ElMessage.warning('请先在工序配置中选择供应商')
    return
  }
  const purGroups: Record<string, any[]> = {}
  const procGroups: Record<string, any[]> = {}
  rows.forEach((r: any) => {
    const key = String(r.vendorId)
    const group = r.docType === 'PURCHASE' ? purGroups : procGroups
    group[key] = group[key] || []
    if (!group[key].some((x: any) => x.processId === r.processId)) group[key].push(r)
  })
  let newPur = 0
  let newProc = 0
  // 采购单：同供应商已有单据则复用，仅补充缺少的工序明细
  Object.entries(purGroups).forEach(([, rs]) => {
    const exist = purchaseDocs.value.find((d: any) => String(d.vendorId) === String(rs[0].vendorId))
    const lines = rs
      .filter((r: any) => !(exist?.lines || []).some((l: any) => l.processId === r.processId))
      .map((r: any) => ({
        // 采购的是工序服务（非库存物料），用负数伪物料ID避免同一单据内物料重复校验
        itemId: -Math.abs(Number(r.processId) || 1), itemCode: 'PROC-' + (r.processCode || r.processId),
        itemName: r.processName,
        productName: routeConfig.productName || form.productName, specification: '',
        unitOfMeasure: form.unitOfMeasure, unitName: form.unitName,
        quantity: r.planQty, unitPrice: r.unitPrice, expectedDate: r.expectedDate,
        processId: r.processId, processCode: r.processCode, processName: r.processName,
        lineAttrs: {}, remark: ''
      }))
    if (exist) {
      if (lines.length) { exist.lines = [...(exist.lines || []), ...lines]; newPur += lines.length }
      return
    }
    newPur++
    purchaseDocs.value.push({
      docTitle: (rs[0].processName || '') + '采购单', vendorId: rs[0].vendorId, vendorCode: rs[0].vendorCode, vendorName: rs[0].vendorName,
      purchaseType: 'OTHER', orderDate: routeConfig.orderDate, purchaser: routeConfig.purchaser || '',
      deliveryAddress: routeConfig.deliveryAddress, remark: '',
      lines
    })
  })
  // 加工单：同供应商已有单据则复用，仅补充缺少的工序明细
  Object.entries(procGroups).forEach(([, rs]) => {
    const exist = processDocs.value.find((d: any) => String(d.vendorId) === String(rs[0].vendorId))
    const lines = rs
      .filter((r: any) => !(exist?.lines || []).some((l: any) => l.processId === r.processId))
      .map((r: any) => ({
        processId: r.processId, processCode: r.processCode, processName: r.processName,
        productName: routeConfig.productName || form.productName,
        planQty: r.planQty, unitPrice: r.unitPrice, expectedDate: r.expectedDate,
        vendorId: r.vendorId, vendorCode: r.vendorCode, vendorName: r.vendorName,
        extAttrs: {}, attrSchema: [], remark: ''
      }))
    if (exist) {
      if (lines.length) { exist.lines = [...(exist.lines || []), ...lines]; newProc += lines.length }
      return
    }
    newProc++
    processDocs.value.push({
      docTitle: (rs[0].processName || '') + '加工单',
      supplierType: rs[0].isOutsource === '1' ? 'OUTSIDE' : (rs[0].vendorId ? 'OUTSIDE' : 'INSIDE'),
      vendorId: rs[0].vendorId, vendorCode: rs[0].vendorCode, vendorName: rs[0].vendorName,
      orderDate: routeConfig.orderDate, purchaser: routeConfig.purchaser || '', deliveryAddress: routeConfig.deliveryAddress, remark: '',
      lines
    })
  })
  activeTab.value = 'docs'
  if (!newPur && !newProc) ElMessage.info('所选供应商的单据均已生成，未新增明细')
  else ElMessage.success(`已生成采购单 ${newPur} 张、加工单 ${newProc} 张，其余单据保持不变`)
}

function submit() {
  formRef.value?.validate((valid: boolean) => {
    if (!valid) return
    if (!routeProcesses.value.length) { ElMessage.warning('请选择工艺路线或添加工序'); return }
    const payload = {
      workorder: {
        ...form,
        requestDate: normalizeDateTime(form.requestDate),
        routeProductId: routeProductId.value || form.routeProductId
      },
      bomList: bomRows.value,
      paramList: [],
      routeProcesses: routeProcesses.value,
      purchaseDocs: purchaseDocs.value.map((d: any) => ({ ...d, lines: d.lines || [] })),
      processDocs: processDocs.value.map((d: any) => ({ ...d, lines: d.lines || [] }))
    }
    submitting.value = true
    const call = (mode.value === 'add' || mode.value === 'copy')
      ? createWorkorderFull(payload)
      : updateWorkorderFull(workorderId.value as number, payload)
    call.then(() => {
      ElMessage.success('保存成功')
      router.push({ path: '/mes/pro/workorder' })
    }).catch(() => {}).finally(() => { submitting.value = false })
  })
}

function goBack() { router.push({ path: '/mes/pro/workorder' }) }
</script>

<style scoped>
.wo-edit { padding-bottom: 40px; }
.page-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.head-left { display: flex; align-items: center; gap: 10px; }
.page-title { font-size: 16px; font-weight: 600; }
.tip { color: #909399; font-size: 12px; margin-left: 8px; }
.doc-badge { margin-left: 6px; }
.doc-toolbar { display: flex; align-items: center; gap: 8px; margin-bottom: 10px; }
.img-100 :deep(.el-upload--picture-card),
.img-100 :deep(.el-upload-list--picture-card .el-upload-list__item) { width: 100px !important; height: 100px !important; }
.img-100 :deep(.el-upload--picture-card) { line-height: 100px; }
:deep(.el-form-item__label) { padding-right: 16px !important; }
</style>
