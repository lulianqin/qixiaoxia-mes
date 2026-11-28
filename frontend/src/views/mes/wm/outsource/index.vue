<template>
  <div class="app-container">
    <!-- 搜索栏 -->
    <el-form :model="queryParams" ref="queryFormRef" :inline="true" v-show="showSearch" label-width="90px">
      <el-form-item label="外协单号" prop="orderCode">
        <el-input v-model="queryParams.orderCode" placeholder="请输入外协单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="外协厂商" prop="vendorName">
        <el-input v-model="queryParams.vendorName" placeholder="请输入厂商名称" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 160px">
          <el-option v-for="d in mes_outsource_status" :key="d.value" :label="d.label" :value="d.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="来源类型" prop="sourceType">
        <el-select v-model="queryParams.sourceType" placeholder="全部" clearable style="width: 160px">
          <el-option v-for="d in mes_outsource_type" :key="d.value" :label="d.label" :value="d.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="范围">
        <el-checkbox v-model="pendingOnly" @change="onPendingOnlyChange">只看待代录</el-checkbox>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" size="small" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" size="small" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 工具栏 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Promotion" size="small" @click="handleCreate" v-hasPermi="['mes:wm:outsource:add']">新增加工单</el-button>
      </el-col>
      <el-col :span="1.5">
          <el-button type="warning" plain icon="Van" size="small" :disabled="draftRows.length === 0" :loading="batchLoading" @click="handleBatchExecute" v-hasPermi="['mes:wm:outsource:execute']">
          批量执行发料<span v-if="draftRows.length > 0">（{{ draftRows.length }}）</span>
        </el-button>
      </el-col>
      <el-col :span="1.5">
          <el-button type="success" plain icon="Check" size="small" :disabled="receivableRows.length === 0" :loading="batchLoading" @click="handleBatchReceive" v-hasPermi="['mes:wm:outsource:receive']">
          批量收货<span v-if="receivableRows.length > 0">（{{ receivableRows.length }}）</span>
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="info" plain size="small" :disabled="!selectedRows.length" @click="handleDocExport" v-hasPermi="['mes:wm:outsource:export']">单据导出</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="info" plain size="small" :disabled="!selectedRows.length" @click="handleDocPrint" v-hasPermi="['mes:wm:outsource:export']">单据打印</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <!-- 列表 -->
      <el-table ref="tableRef" v-loading="loading" :data="list" border row-key="orderId" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="48" />
      <el-table-column label="外协单号" align="center" prop="orderCode" width="160" :show-overflow-tooltip="true" />
      <el-table-column label="来源" align="center" prop="sourceType" width="80" :show-overflow-tooltip="true">
        <template #default="{ row }">
          <dict-tag :options="mes_outsource_type" :value="row.sourceType" />
        </template>
      </el-table-column>
      <el-table-column label="外协厂商" align="center" prop="vendorName" min-width="100" :show-overflow-tooltip="true" />
      <el-table-column label="工单编码" align="center" prop="workorderCode" width="140" :show-overflow-tooltip="true" />
      <el-table-column label="工序" align="center" prop="processName" width="100" :show-overflow-tooltip="true">
        <template #default="{ row }">{{ row.processName || '-' }}</template>
      </el-table-column>
      <el-table-column label="发料总量" align="center" prop="issueTotalQty" width="100" :show-overflow-tooltip="true">
        <template #default="{ row }">{{ row.issueTotalQty != null ? row.issueTotalQty + '吨' : '-' }}</template>
      </el-table-column>
      <el-table-column label="收货总量" align="center" prop="recptTotalQty" width="100" :show-overflow-tooltip="true">
        <template #default="{ row }">{{ row.recptTotalQty != null ? row.recptTotalQty + '吨' : '-' }}</template>
      </el-table-column>
      <el-table-column label="操作人" align="center" prop="operator" width="80" :show-overflow-tooltip="true" />
      <el-table-column label="发料时间" align="center" prop="issueTime" width="180" :show-overflow-tooltip="true" />
      <el-table-column label="状态" align="center" prop="status" width="90" :show-overflow-tooltip="true">
        <template #default="{ row }">
          <dict-tag :options="mes_outsource_status" :value="row.status" />
        </template>
      </el-table-column>
      <el-table-column label="检验状态" align="center" width="100" :show-overflow-tooltip="true">
        <template #default="{ row }">
          <qc-status-tag :status="row.qcStatus" @click="goIqc(row)" />
        </template>
      </el-table-column>
      <el-table-column label="代操作人" align="center" prop="agentOperator" width="90" :show-overflow-tooltip="true">
        <template #default="{ row }">{{ row.agentOperator || '-' }}</template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="220" fixed="right" class-name="op-col">
        <template #default="{ row }">
          <el-button link type="primary" size="small" @click="handleDetail(row)">详情</el-button>
          <el-button v-if="row.status === 'DRAFT'" link type="warning" size="small" :loading="actionLoadingId === row.orderId" :disabled="actionLoadingId != null" @click="handleExecute(row)" v-hasPermi="['mes:wm:outsource:execute']">执行发料</el-button>
          <el-button v-else-if="row.status === 'ISSUED'" link type="primary" size="small" :loading="actionLoadingId === row.orderId" :disabled="actionLoadingId != null" @click="handleVendorReceive(row)" v-hasPermi="['mes:wm:outsource:agentOps']">签收</el-button>
          <el-button v-else-if="row.status === 'VENDOR_RCVD' || row.status === 'PROCESSING'" link type="primary" size="small" :disabled="actionLoadingId != null" @click="handleAgentResult(row)" v-hasPermi="['mes:wm:outsource:agentOps']">{{ row.status === 'VENDOR_RCVD' ? '录结果' : '补录' }}</el-button>
          <el-button v-else-if="row.status === 'FINISHED'" link type="success" size="small" :loading="actionLoadingId === row.orderId" :disabled="actionLoadingId != null" @click="handleShip(row)" v-hasPermi="['mes:wm:outsource:agentOps']">发货回厂</el-button>
          <el-button v-else-if="canReceive(row.status)" link type="success" size="small" :loading="actionLoadingId === row.orderId" :disabled="actionLoadingId != null" @click="handleReceive(row)" v-hasPermi="['mes:wm:outsource:receive']">收货</el-button>
          <el-button v-if="row.status === 'DRAFT' && checkPermi(['mes:wm:outsource:remove'])" link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          <el-button v-if="row.status === 'PROCESSING' && checkPermi(['mes:wm:outsource:agentOps'])" link type="primary" size="small" @click="handleComplete(row)">完成</el-button>
          <el-button v-if="checkPermi(['mes:wm:outsource:query'])" link type="primary" size="small" @click="handleProcessLines(row)">工序</el-button>
          <el-button v-if="checkPermi(['mes:wm:outsource:export'])" link type="primary" size="small" @click="handleExport(row)">导出</el-button>
          <el-button v-if="checkPermi(['mes:wm:outsource:changeStatus'])" link type="primary" size="small" @click="openStatusPick(row)">改状态</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:current-page="queryParams.pageNum" v-model:page-size="queryParams.pageSize" @pagination="getList" />

    <!-- 新增加工单弹窗 -->
    <OutsourceCreateDialog ref="createDialogRef" @success="getList" />
    <!-- 代厂商录入加工结果弹窗 -->
    <OutsourceAgentResultDialog ref="agentResultRef" @success="getList" />
    <!-- 加工单工序行弹窗 -->
    <ProcessLineDialog v-model="processLineVisible" :order-id="processLineOrderId"
      :workorder-id="processLineWorkorderId" :status="processLineStatus" @success="getList" />

    <!-- 详情弹窗 -->
    <el-dialog v-model="detailVisible" title="外协单详情" width="800px" append-to-body>
      <el-descriptions v-if="detail" :column="3" border size="small">
        <el-descriptions-item label="外协单号">{{ detail.orderCode }}</el-descriptions-item>
        <el-descriptions-item label="来源类型"><dict-tag :options="mes_outsource_type" :value="detail.sourceType" /></el-descriptions-item>
        <el-descriptions-item label="外协厂商">{{ detail.vendorName }}</el-descriptions-item>
        <el-descriptions-item label="工单编码">{{ detail.workorderCode || '-' }}</el-descriptions-item>
        <el-descriptions-item label="工序">{{ detail.processName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态"><dict-tag :options="mes_outsource_status" :value="detail.status" /></el-descriptions-item>
        <el-descriptions-item label="发料总量">{{ detail.issueTotalQty != null ? detail.issueTotalQty + '吨' : '-' }}</el-descriptions-item>
        <el-descriptions-item label="收货总量">{{ detail.recptTotalQty ? detail.recptTotalQty + '吨' : '-' }}</el-descriptions-item>
        <el-descriptions-item label="报工ID">{{ detail.feedbackId || '-' }}</el-descriptions-item>
      </el-descriptions>
      <el-divider content-position="left">发料明细</el-divider>
      <el-table :data="detail?.issueLines || []" border size="small">
        <el-table-column label="物料编码" prop="itemCode" width="120"  :show-overflow-tooltip="true" />
        <el-table-column label="物料名称" prop="itemName" min-width="120" show-overflow-tooltip />
        <el-table-column label="数量" prop="quantity" width="90"  :show-overflow-tooltip="true" />
        <el-table-column label="单位" prop="unitName" width="60"  :show-overflow-tooltip="true" />
        <el-table-column label="母卷编号" prop="instanceCode" width="150"  :show-overflow-tooltip="true" />
        <el-table-column label="批次" prop="batchCode" width="120"  :show-overflow-tooltip="true" />
        <el-table-column label="仓库" prop="warehouseName" width="100"  :show-overflow-tooltip="true" />
      </el-table>
      <template v-if="detail?.recptLines?.length > 0">
        <el-divider content-position="left">收货明细</el-divider>
        <el-table :data="detail.recptLines" border size="small">
          <el-table-column label="物料编码" prop="itemCode" width="120"  :show-overflow-tooltip="true" />
          <el-table-column label="物料名称" prop="itemName" min-width="120" show-overflow-tooltip />
          <el-table-column label="数量" prop="quantity" width="90"  :show-overflow-tooltip="true" />
          <el-table-column label="单位" prop="unitName" width="60"  :show-overflow-tooltip="true" />
          <el-table-column label="仓库" prop="warehouseName" width="100"  :show-overflow-tooltip="true" />
        </el-table>
      </template>
      <template v-if="detail?.processLines?.length">
        <el-divider content-position="left">工序明细</el-divider>
        <el-table :data="detail.processLines" border size="small">
          <el-table-column label="序号" prop="seq" width="60" align="center" />
          <el-table-column label="工序" prop="processName" min-width="120" :show-overflow-tooltip="true" />
          <el-table-column label="计划数量" prop="planQty" width="100" align="center" />
          <el-table-column label="完成数量" prop="doneQty" width="100" align="center" />
          <el-table-column label="扩展属性" prop="extAttrs" min-width="160" :show-overflow-tooltip="true">
            <template #default="{ row }">{{ row.extAttrs || '-' }}</template>
          </el-table-column>
          <el-table-column label="备注" prop="remark" min-width="120" :show-overflow-tooltip="true" />
        </el-table>
      </template>
    </el-dialog>

    <!-- 人工改状态弹窗 -->
    <el-dialog v-model="statusPickOpen" title="加工单改状态" width="450px" append-to-body>
      <el-form label-width="90px">
        <el-form-item label="目标状态" required>
          <el-select v-model="statusPickValue" placeholder="请选择目标状态" style="width:100%">
            <el-option v-for="d in mes_outsource_status" :key="d.value" :label="d.label" :value="d.value"
              :disabled="d.value === statusPickRow?.status" />
          </el-select>
        </el-form-item>
        <el-form-item label="变更原因">
          <el-input v-model="statusPickRemark" placeholder="可空" maxlength="200" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="statusPickOpen = false">取 消</el-button>
        <el-button type="primary" @click="confirmStatusPick">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, getCurrentInstance } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { listOutsource, getOutsource, executeOutsource, batchExecuteOutsource, receiveOutsource, batchReceiveOutsource, delOutsource, vendorReceiveOutsource, completeOutsource, shipOutsource, changeOutsourceStatus, exportOutsource } from '@/api/mes/wm/outsource'
import OutsourceCreateDialog from './OutsourceCreateDialog.vue'
import OutsourceAgentResultDialog from './OutsourceAgentResultDialog.vue'
import ProcessLineDialog from './ProcessLineDialog.vue'
import { ElMessageBox, ElMessage } from 'element-plus'
import { checkPermi } from '@/utils/permission'
import QcStatusTag from '../../qc/components/QcStatusTag.vue'
import { showBatchResult } from './batchResult'
import { printPdfBlob } from '@/utils/pdfPrint'
import { exportProcessDocExcel, fetchProcessDocPdf, exportProcessDocsMergeExcel, fetchProcessDocsMergePdf } from '@/api/mes/pro/workorderFull'
import type { OutsourceIssueLineVO } from './types'

interface OutsourceOrderRow {
  orderId: number
  orderCode: string
  sourceType: string
  vendorName: string
  workorderCode: string
  workorderId?: number
  processName: string
  issueTotalQty: number | null
  recptTotalQty: number | null
  operator: string
  issueTime: string
  status: string
  feedbackId?: number | null
  iqcId?: number | null
  iqcCode?: string | null
  qcStatus?: string | null
  agentOperator?: string | null
  issueLines?: OutsourceIssueLineVO[]
  recptLines?: unknown[]
  processLines?: any[]
}

interface OutsourceQuery {
  pageNum: number
  pageSize: number
  orderCode: string
  vendorName: string
  status: string
  sourceType: string
  pendingOnly: boolean
}

const { proxy } = getCurrentInstance() as any
const { mes_outsource_status, mes_outsource_type } = proxy.useDict('mes_outsource_status', 'mes_outsource_type')
const queryFormRef = ref()
const tableRef = ref()
const loading = ref(false)
const batchLoading = ref(false)
const actionLoadingId = ref<number | null>(null)
const showSearch = ref(true)
const list = ref<OutsourceOrderRow[]>([])
const total = ref(0)
const createDialogRef = ref()
const agentResultRef = ref()
const detailVisible = ref(false)
const detail = ref<OutsourceOrderRow | null>(null)
const processLineVisible = ref(false)
const processLineOrderId = ref<number | undefined>(undefined)
const processLineWorkorderId = ref<number | undefined>(undefined)
const processLineStatus = ref<string | undefined>(undefined)
const statusPickOpen = ref(false)
const statusPickRow = ref<OutsourceOrderRow | null>(null)
const statusPickValue = ref('')
const statusPickRemark = ref('')
const selectedRows = ref<OutsourceOrderRow[]>([])
const draftRows = computed(() => selectedRows.value.filter(r => r.status === 'DRAFT'))
const receivableRows = computed(() => selectedRows.value.filter(r => canReceive(r.status)))

const queryParams = reactive<OutsourceQuery>({
  pageNum: 1, pageSize: 10,
  orderCode: '', vendorName: '', status: '', sourceType: '', pendingOnly: false
})
// 首页待办：只看待代录
const pendingOnly = ref(false)
const route = useRoute()
function onPendingOnlyChange(val: boolean) {
  queryParams.pendingOnly = val
  handleQuery()
}

function getList() {
  loading.value = true
  listOutsource(queryParams).then((res: { rows: OutsourceOrderRow[]; total: number }) => {
    list.value = res.rows || []
    total.value = res.total || 0
  }).catch(() => {}).finally(() => { loading.value = false })
}

function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() {
  queryFormRef.value?.resetFields()
  pendingOnly.value = false
  queryParams.pendingOnly = false
  handleQuery()
}
function handleCreate() { createDialogRef.value?.open() }

async function handleDetail(row: OutsourceOrderRow) {
  try {
    const res = await getOutsource(row.orderId)
    detail.value = res.data
    detailVisible.value = true
  } catch (e) { /* request interceptor already shown error */ }
}

// 返回 true=用户确认，false=取消
async function confirmAction(msg: string): Promise<boolean> {
  try { await proxy.$modal.confirm(msg); return true } catch { return false }
}

async function handleReceive(row: OutsourceOrderRow) {
  if (!await confirmAction('确认收货？收货后将入库并推进流转卡。')) return
  actionLoadingId.value = row.orderId
  try {
    await receiveOutsource(row.orderId)
    proxy.$modal.msgSuccess('收货成功')
    getList()
  } finally { actionLoadingId.value = null }
}

// ── 一期：工序行 / 导出 / 人工改状态 ─────────────────
function handleProcessLines(row: OutsourceOrderRow) {
  processLineOrderId.value = row.orderId
  processLineWorkorderId.value = (row as any).workorderId
  processLineStatus.value = row.status
  processLineVisible.value = true
}

function openStatusPick(row: OutsourceOrderRow) {
  statusPickRow.value = row
  statusPickValue.value = ''
  statusPickRemark.value = ''
  statusPickOpen.value = true
}

function confirmStatusPick() {
  if (!statusPickRow.value || !statusPickValue.value) { ElMessage.warning('请选择目标状态'); return }
  changeOutsourceStatus({
    orderId: statusPickRow.value.orderId,
    status: statusPickValue.value,
    remark: statusPickRemark.value
  }).then(() => {
    ElMessage.success('状态已更新')
    statusPickOpen.value = false
    getList()
  }).catch(() => {})
}

async function handleExport(row: OutsourceOrderRow) {
  try {
    const blob: any = await exportOutsource(row.orderId)
    const url = window.URL.createObjectURL(new Blob([blob]))
    const a = document.createElement('a')
    a.href = url
    a.download = `加工单_${row.orderCode}.xlsx`
    document.body.appendChild(a); a.click(); document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
  } catch (e) {
    // 拦截器已提示
  }
}

function handleChangeStatus(row: OutsourceOrderRow, status: string) {
  if (status === row.status) return
  ElMessageBox.prompt(`将加工单 ${row.orderCode} 状态改为「${status}」，请填写变更原因（可空）`, '改状态', {
    inputPlaceholder: '变更原因', confirmButtonText: '确定', cancelButtonText: '取消'
  }).then(({ value }) => changeOutsourceStatus({ orderId: row.orderId, status, remark: value }))
    .then(() => { ElMessage.success('状态已更新'); getList() })
    .catch(() => {})
}

// ── 代厂商操作（签收 / 录结果 / 完成 / 发货回厂）────────────────
async function handleVendorReceive(row: OutsourceOrderRow) {
  if (!await confirmAction('确认代厂商签收？签收后由我厂承担加工责任，可继续录结果。')) return
  actionLoadingId.value = row.orderId
  try {
    await vendorReceiveOutsource(row.orderId)
    proxy.$modal.msgSuccess('签收成功')
    getList()
  } finally { actionLoadingId.value = null }
}

function handleAgentResult(row: OutsourceOrderRow) {
  agentResultRef.value?.open(row)
}

async function handleComplete(row: OutsourceOrderRow) {
  if (!await confirmAction('确认代厂商完成加工？完成后可发货回厂。')) return
  actionLoadingId.value = row.orderId
  try {
    await completeOutsource(row.orderId)
    proxy.$modal.msgSuccess('已完成，可发货回厂')
    getList()
  } finally { actionLoadingId.value = null }
}

async function handleShip(row: OutsourceOrderRow) {
  if (!await confirmAction('确认代厂商发货回厂？发货后将生成来料检验单，等待我厂收货。')) return
  actionLoadingId.value = row.orderId
  try {
    await shipOutsource(row.orderId)
    proxy.$modal.msgSuccess('已发货回厂')
    getList()
  } finally { actionLoadingId.value = null }
}

async function handleExecute(row: OutsourceOrderRow) {
  if (!await confirmAction('确认执行发料？将扣减库存并将单据置为「已发料」。')) return
  actionLoadingId.value = row.orderId
  try {
    await executeOutsource(row.orderId)
    proxy.$modal.msgSuccess('发料成功')
    getList()
  } finally { actionLoadingId.value = null }
}

// 删除草稿外协单（仅 DRAFT 状态，后端再次校验状态并拒绝非草稿）
async function handleDelete(row: OutsourceOrderRow) {
  if (!await confirmAction(`确认删除草稿单 ${row.orderCode}？删除后不可恢复。`)) return
  actionLoadingId.value = row.orderId
  try {
    await delOutsource(row.orderId)
    proxy.$modal.msgSuccess('删除成功')
    getList()
  } finally { actionLoadingId.value = null }
}

// 严格状态机：仅 SHIPPED（厂商已发货）可收货
function canReceive(status: string) {
  return status === 'SHIPPED'
}
function handleSelectionChange(rows: OutsourceOrderRow[]) {
  selectedRows.value = rows
}

/** 单据导出：选 1 张导单张，多选要求同一供应商则合并 */
function handleDocExport() {
  const rows = selectedRows.value
  if (!rows.length) return ElMessage.warning('请选择加工单')
  if (rows.length === 1) {
    const r: any = rows[0]
    return exportProcessDocExcel(r.orderId, `${r.vendorName || ''}_${r.docTitle || '加工单'}_${r.orderCode}.xlsx`)
  }
  if (new Set(rows.map(r => r.vendorName)).size > 1) return ElMessage.warning('合并导出要求选择同一加工商的单据')
  exportProcessDocsMergeExcel(rows.map(r => r.orderId), `${rows[0].vendorName || ''}_合并加工单_${ymd()}.xlsx`)
}

/** 单据打印：单张/合并都直接调起系统打印 */
function handleDocPrint() {
  const rows = selectedRows.value
  if (!rows.length) return ElMessage.warning('请选择加工单')
  if (rows.length > 1 && new Set(rows.map(r => r.vendorName)).size > 1) {
    return ElMessage.warning('合并打印要求选择同一加工商的单据')
  }
  const req = rows.length === 1
    ? fetchProcessDocPdf(rows[0].orderId)
    : fetchProcessDocsMergePdf(rows.map(r => r.orderId))
  req.then((blob: Blob) => printPdfBlob(blob)).catch(() => {})
}

/** 当天 yyyyMMdd，用于合并单据文件名 */
function ymd() {
  const d = new Date()
  return `${d.getFullYear()}${String(d.getMonth() + 1).padStart(2, '0')}${String(d.getDate()).padStart(2, '0')}`
}

// 来料检验状态 tag：点击跳转 IQC 列表并按外协单过滤
const router = useRouter()
function goIqc(row: OutsourceOrderRow) {
  router.push({ path: '/qc/qciqc', query: { sourceDocId: String(row.orderId), sourceDocType: 'wm_outsource_order' } })
}

// 批量操作结果汇总抽到 ./batchResult（全成功提示；失败弹窗列原因）

function clearTableSelection() {
  tableRef.value?.clearSelection()
  selectedRows.value = []
}

async function handleBatchExecute() {
  const ids = draftRows.value.map(r => r.orderId)
  if (ids.length === 0) return
  if (!await confirmAction(`确认对选中的 ${ids.length} 张草稿单执行发料？将扣减库存并将单据置为「已发料」。`)) return
  try {
    batchLoading.value = true
    await showBatchResult(batchExecuteOutsource(ids), '发料')
    clearTableSelection()
    getList()
  } finally {
    batchLoading.value = false
  }
}

async function handleBatchReceive() {
  const ids = receivableRows.value.map(r => r.orderId)
  if (ids.length === 0) return
  if (!await confirmAction(`确认对选中的 ${ids.length} 张外协单收货？将入库、建报工并推进流转卡。`)) return
  try {
    batchLoading.value = true
    await showBatchResult(batchReceiveOutsource(ids), '收货')
    clearTableSelection()
    getList()
  } finally {
    batchLoading.value = false
  }
}

onMounted(() => {
  // 首页待办跳转：只看待代录
  if (route.query.pending === '1') {
    pendingOnly.value = true
    queryParams.pendingOnly = true
  }
  getList()
  // 工单看板「加工单号」入口：自动打开单据详情
  if (route.query.openId) handleDetail({ orderId: Number(route.query.openId) } as any)
})
</script>

<style scoped>
/* 操作列：纯中文按钮、两行排布、紧凑间距 */
:deep(.op-col .cell) { white-space: normal; line-height: 24px; }
:deep(.op-col .el-button) { padding: 0 3px !important; height: 24px; font-size: 12px; }
:deep(.op-col .el-button + .el-button) { margin-left: 4px; }
</style>
