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
                <el-input v-model="form.workorderCode" placeholder="请输入" :disabled="mode !== 'add'">
                  <template #append v-if="mode === 'add'">
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
              <el-form-item label="负责人">
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
                <el-input v-model="form.sourceCode" readonly placeholder="自动带入" />
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
                <image-upload v-model="form.productImage" :limit="1" :disabled="readonly" />
                <span class="tip">导出采购单/加工单时作为单据底部图片</span>
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="12">
            <el-col :span="24">
              <el-form-item label="备注"><el-input v-model="form.remark" type="textarea" :rows="2" /></el-form-item>
            </el-col>
          </el-row>

          <el-divider content-position="left">产品属性</el-divider>
          <ExtAttrForm ref="extAttrRef" :schema="attrSchema" v-model="form.lineAttrs" :readonly="readonly" scope="PRODUCT" />
          <el-divider content-position="left">生产属性</el-divider>
          <ExtAttrForm :schema="attrSchema" v-model="form.lineAttrs" :readonly="readonly" scope="PRODUCTION" />
        </el-form>

        <el-divider content-position="left">工艺路线与工序</el-divider>
        <WorkorderRouteEditor v-model="routeProcesses" :process-options="processOptions" :readonly="readonly" />
      </el-tab-pane>

      <el-tab-pane name="docs">
        <template #label>
          单据配置
          <el-badge v-if="docCount" :value="docCount" class="doc-badge" />
        </template>
        <WorkorderDocPanel v-model:purchase-docs="purchaseDocs" v-model:process-docs="processDocs"
          :process-options="routeProcesses" :readonly="readonly" />
      </el-tab-pane>
    </el-tabs>

    <ItemSelect ref="itemRef" @onSelected="onProductSelected" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, getCurrentInstance } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  createWorkorderFull, updateWorkorderFull, getWorkorderFullDetail
} from '@/api/mes/pro/workorderFull'
import { listRouteProduct } from '@/api/mes/pro/routeproduct'
import { listRoute } from '@/api/mes/pro/proroute'
import { listRouteProcessByRouteId } from '@/api/mes/pro/routeprocess'
import { listAllProcess } from '@/api/mes/pro/process'
import { genSerialCode } from '@/api/mes/sys/autocoderule'
import { listUser } from '@/api/system/user'
import { getItem } from '@/api/mes/md/item'
import { getEffAttrSchema } from '@/api/mes/md/attr'
import { getDicts } from '@/api/system/dict/data'
import ItemSelect from '@/components/itemSelect/single.vue'
import ExtAttrForm from '@/components/ExtAttrForm/index.vue'
import WorkorderRouteEditor from './components/WorkorderRouteEditor.vue'
import WorkorderDocPanel from './components/WorkorderDocPanel.vue'

const { proxy } = getCurrentInstance() as any
const route = useRoute()
const router = useRouter()

const mode = ref<'add' | 'edit' | 'view'>('add')
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
  quantity: [{ required: true, message: '数量不能为空', trigger: 'blur' }]
}

const readonly = computed(() => mode.value === 'view')
const pageTitle = computed(() => (mode.value === 'add' ? '新增生产工单' : mode.value === 'edit' ? '编辑生产工单' : '查看生产工单'))
const productLabel = computed(() => (form.productName ? `${form.productName} (${form.productCode || ''})` : ''))
const docCount = computed(() => purchaseDocs.value.length + processDocs.value.length)

onMounted(() => {
  const id = route.query.workorderId ? Number(route.query.workorderId) : null
  mode.value = (route.query.mode as any) || (id ? 'edit' : 'add')
  workorderId.value = id
  loadProcessOptions()
  getDicts('mes_sal_order_type').then((r: any) => { orderTypeOptions.value = r.data || [] })
  searchOwners('')
  if (id) loadDetail(id)
  else initFromSalesOrder()
  if (mode.value === 'add' && !form.workorderCode) form.workorderCode = ''
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
  form.requestDate = (q.requestDate as string) || null
  if (q.orderType) form.orderType = q.orderType as string
  if (q.productId) {
    onProductSelected({
      itemId: Number(q.productId), itemCode: q.productCode, itemName: q.productName,
      specification: q.productSpc, unitOfMeasure: q.unitOfMeasure, unitName: q.unitName
    })
  }
}

function loadDetail(id: number) {
  getWorkorderFullDetail(id).then((r: any) => {
    const d = r.data || {}
    Object.assign(form, d.workorder || {})
    if (!form.lineAttrs) form.lineAttrs = {}
    routeProductId.value = form.routeProductId
    routeProcesses.value = d.routeProcesses || []
    loadSchema(form.productId)
    onProductSelected({
      itemId: form.productId, itemCode: form.productCode, itemName: form.productName,
      unitOfMeasure: form.unitOfMeasure, unitName: form.unitName
    }, true)
    purchaseDocs.value = (d.purchaseDocs || []).map((x: any) => ({ ...x.order, lines: x.lines || [] }))
    processDocs.value = (d.processDocs || []).map((x: any) => ({ ...x, lines: x.processLines || [] }))
  })
}

function onAutoGen(flag: boolean) {
  if (flag) genSerialCode('WORKORDER_NO').then((r: any) => { form.workorderCode = r.data })
  else form.workorderCode = ''
}

function onProductSelected(row: any, keepRoute = false) {
  if (!row) return
  form.productId = row.itemId
  form.productCode = row.itemCode
  form.productName = row.itemName
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
  loadRoutes(row.itemId)
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
  listRouteProduct({ itemId, pageSize: 100 }).then((r: any) => {
    const rows = r.rows || []
    if (!rows.length) return
    listRoute({ pageSize: 1000 }).then((rr: any) => {
      const map: Record<string, string> = {}
      ;(rr.rows || []).forEach((rt: any) => { map[rt.routeId] = rt.routeName || rt.routeCode })
      routeOptions.value = rows.map((rp: any) => ({ ...rp, _routeName: map[rp.routeId] }))
    })
  })
}

function onRouteChange(recordId: number) {
  const rp = routeOptions.value.find((r: any) => r.recordId === recordId)
  if (!rp) return
  form.routeProductId = recordId
  listRouteProcessByRouteId(rp.routeId).then((res: any) => {
    const list = res.data || []
    routeProcesses.value = list.map((p: any, i: number) => ({ ...p, orderNum: i + 1 }))
  })
}

function searchOwners(kw: string) {
  ownerLoading.value = true
  listUser({ userName: kw || undefined, status: '0', pageNum: 1, pageSize: 20 })
    .then((r: any) => { ownerOptions.value = r.rows || [] })
    .finally(() => { ownerLoading.value = false })
}

function submit() {
  formRef.value?.validate((valid: boolean) => {
    if (!valid) return
    if (!routeProcesses.value.length) { ElMessage.warning('请选择工艺路线或添加工序'); return }
    const payload = {
      workorder: { ...form, routeProductId: routeProductId.value || form.routeProductId },
      bomList: [],
      paramList: [],
      routeProcesses: routeProcesses.value,
      purchaseDocs: purchaseDocs.value.map((d: any) => ({ ...d, lines: d.lines || [] })),
      processDocs: processDocs.value.map((d: any) => ({ ...d, lines: d.lines || [] }))
    }
    submitting.value = true
    const call = mode.value === 'add'
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
:deep(.el-form-item__label) { padding-right: 16px !important; }
</style>
