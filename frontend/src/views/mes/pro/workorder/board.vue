<template>
  <div class="app-container">
    <el-page-header @back="goBack" class="mb16">
      <template #content>
        <span class="header-title">工单看板</span>
        <el-tag v-if="wo.workorderCode" type="info" class="ml8">{{ wo.workorderCode }}</el-tag>
        <el-tag v-if="wo.status" :type="woTagType" class="ml8">{{ woStatusText }}</el-tag>
        <el-progress v-if="wo.workorderCode" :percentage="progressPercent" :stroke-width="12" style="width:200px;display:inline-flex;vertical-align:middle;margin-left:12px" />
      </template>
    </el-page-header>

    <div v-loading="loading">
      <!-- 基于工单创建采购单 / 加工单 -->
      <div class="board-actions mb16">
        <el-button type="primary" icon="Plus" @click="purWizOpen = true" v-hasPermi="['mes:pur:order:add']">新增采购单</el-button>
        <el-button type="warning" icon="Plus" @click="openOutsource" v-hasPermi="['mes:wm:outsource:add']">新增加工单</el-button>
        <span class="action-tip">采购单/加工单自动关联当前工单 {{ wo.workorderCode }}</span>
      </div>

      <!-- 工单信息 -->
      <el-card shadow="never" class="mb16">
        <template #header><span>工单信息</span></template>
        <el-descriptions :column="3" size="small" border>
          <el-descriptions-item label="工单名称">{{ wo.workorderName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="来源销售订单">{{ wo.sourceCode || '-' }}</el-descriptions-item>
          <el-descriptions-item label="工单类型">{{ wo.workorderType === 'OUTSOURCE' ? '外协' : '自制' }}</el-descriptions-item>
          <el-descriptions-item label="产品">{{ wo.productName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="产品编码">{{ wo.productCode || '-' }}</el-descriptions-item>
          <el-descriptions-item label="客户">{{ wo.clientName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="计划数量">{{ wo.quantity || 0 }} {{ wo.unitName || '' }}</el-descriptions-item>
          <el-descriptions-item label="已生产">{{ wo.quantityProduced || 0 }}</el-descriptions-item>
          <el-descriptions-item label="需求日期">{{ fmtDate(wo.requestDate) }}</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <!-- 工序进度（融合进度弹窗：计划/实际时间、完成率、延期） -->
      <el-card shadow="never" class="mb16">
        <template #header>
          <div class="card-head">
            <span>工序进度（{{ tasks.length }}）</span>
            <el-button link type="primary" icon="Plus" size="small" @click="goAddTask" v-hasPermi="['mes:pro:task:add']">新增任务</el-button>
          </div>
        </template>
        <el-tabs v-model="activeTab" @tab-change="onTabChange">
          <el-tab-pane label="工序进度" name="process">
            <WorkorderProcessProgress :rows="tasks"
              @edit="openTaskEdit" @report="goFeedback" @action="quickStatus" @process-board="goProcess" @qrcode="openCardQr" />
          </el-tab-pane>
          <el-tab-pane label="甘特图（实际叠加）" name="gantt">
            <div v-loading="ganttLoading" class="gantt-wrap">
              <GanttChart ref="ganttRef" :tasks="ganttTasks" :readonly="true" :loading="ganttLoading" />
            </div>
          </el-tab-pane>
        </el-tabs>
      </el-card>

      <!-- 物料清单与备货（BOM + 库存占用 + 缺口，可直接调整） -->
      <WorkorderMaterialPanel :workorder-id="workorderId" :editable="materialEditable" @changed="load" />

      <!-- 关联单据汇总 -->
      <el-card shadow="never" class="mb16">
        <template #header><span>关联单据</span></template>
        <el-collapse v-model="activeDims" class="mt16">
          <el-collapse-item name="feedback" v-if="dims.feedback.total >= 0">
            <template #title><span class="dim-title">报工记录（{{ dims.feedback.total }}）<el-tag v-if="dims.feedback.pending" size="small" type="warning" class="ml8">待审核 {{ dims.feedback.pending }}</el-tag><el-tag v-if="dims.feedback.audited" size="small" type="success" class="ml8">已审核 {{ dims.feedback.audited }}</el-tag></span></template>
            <el-table :data="dims.feedback.list" size="small" border>
              <el-table-column label="报工编码" align="center" width="140" :show-overflow-tooltip="true">
                <template #default="s"><el-button link type="primary" size="small" @click="openDoc('FEEDBACK', s.row)">{{ s.row.feedbackCode }}</el-button></template>
              </el-table-column>
              <el-table-column label="工序" align="center" prop="processName" min-width="110" :show-overflow-tooltip="true" />
              <el-table-column label="报工数量" align="center" prop="quantityFeedback" width="90"  :show-overflow-tooltip="true" />
              <el-table-column label="合格" align="center" prop="quantityQualified" width="80"  :show-overflow-tooltip="true" />
              <el-table-column label="不合格" align="center" prop="quantityUnqualified" width="80"  :show-overflow-tooltip="true" />
              <el-table-column label="报工人" align="center" prop="recordNick" width="90"  :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s"><el-tag :type="fbTagType(s.row.status)" size="small">{{ fbStatusText(s.row.status) }}</el-tag></template></el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="inspection">
            <template #title><span class="dim-title">检验记录（{{ dims.inspection.total }}）</span></template>
            <el-table :data="dims.inspection.list" size="small" border>
              <el-table-column label="检验编码" align="center" width="140" :show-overflow-tooltip="true">
                <template #default="s"><el-button link type="primary" size="small" @click="openDoc('INSPECTION', s.row)">{{ s.row.ipqcCode }}</el-button></template>
              </el-table-column>
              <el-table-column label="检验类型" align="center" prop="ipqcName" width="110"  :show-overflow-tooltip="true" />
              <el-table-column label="工序" align="center" prop="processName" min-width="110" :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s">{{ s.row.status || '-' }}</template></el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="outsource">
            <template #title><span class="dim-title">加工单（{{ dims.outsource.total }}）</span></template>
            <el-table :data="dims.outsource.list" size="small" border>
              <el-table-column label="加工单号" align="center" width="140" :show-overflow-tooltip="true">
                <template #default="s"><el-button link type="primary" size="small" @click="openDoc('OUTSOURCE', s.row)">{{ s.row.orderCode }}</el-button></template>
              </el-table-column>
              <el-table-column label="单据标题" align="center" prop="docTitle" min-width="130" :show-overflow-tooltip="true" />
              <el-table-column label="工序" align="center" prop="processName" min-width="110" :show-overflow-tooltip="true" />
              <el-table-column label="供应商" align="center" prop="vendorName" min-width="120" :show-overflow-tooltip="true" />
              <el-table-column label="加工类型" align="center" width="110">
                <template #default="s"><dict-tag :options="mes_outsource_supplier_type" :value="s.row.supplierType" /></template>
              </el-table-column>
              <el-table-column label="状态" align="center" width="110">
                <template #default="s"><dict-tag :options="mes_outsource_status" :value="s.row.status" /></template>
              </el-table-column>
              <el-table-column label="操作" align="center" width="170" fixed="right" class-name="op-col">
                <template #default="s">
                  <el-button link type="primary" size="small" @click="doExportDoc(s.row, 'PROC', 'excel')">导出</el-button>
                  <el-button link type="primary" size="small" @click="doExportDoc(s.row, 'PROC', 'pdf')">打印</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="reservation">
            <template #title><span class="dim-title">备货预占（{{ dims.reservation?.total || 0 }}）</span></template>
            <el-table :data="dims.reservation?.list || []" size="small" border>
              <el-table-column label="物料编码" align="center" prop="itemCode" width="140" :show-overflow-tooltip="true" />
              <el-table-column label="物料名称" align="center" prop="itemName" min-width="150" :show-overflow-tooltip="true" />
              <el-table-column label="需求数量" align="center" prop="demandQty" width="100" />
              <el-table-column label="已锁定" align="center" prop="reservedQty" width="100" />
              <el-table-column label="已消耗" align="center" prop="consumedQty" width="100" />
              <el-table-column label="仓库" align="center" prop="warehouseName" width="120" :show-overflow-tooltip="true" />
              <el-table-column label="需求日期" align="center" width="170">
                <template #default="s">{{ fmtDate(s.row.demandDate) }}</template>
              </el-table-column>
              <el-table-column label="状态" align="center" width="110">
                <template #default="s">{{ reservationStatusText(s.row.status) }}</template>
              </el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="purchase">
            <template #title><span class="dim-title">采购单（{{ dims.purchase.total || 0 }}）</span></template>
            <el-table :data="dims.purchase.list || []" size="small" border>
              <el-table-column label="采购单号" align="center" width="150" :show-overflow-tooltip="true">
                <template #default="s"><el-button link type="primary" size="small" @click="openDoc('PURCHASE', s.row)">{{ s.row.orderCode }}</el-button></template>
              </el-table-column>
              <el-table-column label="单据名称" align="center" prop="orderName" min-width="130" :show-overflow-tooltip="true" />
              <el-table-column label="供应商" align="center" prop="vendorName" min-width="120" :show-overflow-tooltip="true" />
              <el-table-column label="采购数量" align="center" prop="totalQuantity" width="100" />
              <el-table-column label="采购金额" align="center" prop="totalAmount" width="110" />
              <el-table-column label="预计到货" align="center" width="120">
                <template #default="s">{{ fmtDate(s.row.expectedDate) }}</template>
              </el-table-column>
              <el-table-column label="状态" align="center" width="100">
                <template #default="s"><dict-tag :options="mes_order_status" :value="s.row.status" /></template>
              </el-table-column>
              <el-table-column label="操作" align="center" width="170" fixed="right" class-name="op-col">
                <template #default="s">
                  <el-button link type="primary" size="small" @click="doExportDoc(s.row, 'PUR', 'excel')">导出</el-button>
                  <el-button link type="primary" size="small" @click="doExportDoc(s.row, 'PUR', 'pdf')">打印</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="issue">
            <template #title><span class="dim-title">领料/发料（{{ dims.issue.total }}）</span></template>
            <el-table :data="dims.issue.list" size="small" border>
              <el-table-column label="单据编码" align="center" width="140" :show-overflow-tooltip="true">
                <template #default="s"><el-button link type="primary" size="small" @click="openDoc('ISSUE', s.row)">{{ s.row.issueCode }}</el-button></template>
              </el-table-column>
              <el-table-column label="单据名称" align="center" prop="issueName" min-width="120" :show-overflow-tooltip="true" />
              <el-table-column label="工序" align="center" prop="processName" min-width="110" :show-overflow-tooltip="true" />
              <el-table-column label="仓库" align="center" prop="warehouseName" width="110"  :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s"><dict-tag :options="mes_wm_issue_status" :value="s.row.status" /></template></el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="itemRecpt">
            <template #title><span class="dim-title">收料（{{ dims.itemRecpt.total }}）</span></template>
            <el-table :data="dims.itemRecpt.list" size="small" border>
              <el-table-column label="收料单号" align="center" width="140" :show-overflow-tooltip="true">
                <template #default="s"><el-button link type="primary" size="small" @click="openDoc('ITEM_RECPT', s.row)">{{ s.row.recptCode }}</el-button></template>
              </el-table-column>
              <el-table-column label="采购单号" align="center" prop="purOrderCode" width="130"  :show-overflow-tooltip="true" />
              <el-table-column label="供应商" align="center" prop="vendorName" min-width="120" :show-overflow-tooltip="true" />
              <el-table-column label="数量" align="center" prop="totalQuantity" width="90"  :show-overflow-tooltip="true" />
              <el-table-column label="仓库" align="center" prop="warehouseName" width="110"  :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s"><dict-tag :options="mes_itemrecpt_status" :value="s.row.status" /></template></el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="productRecpt">
            <template #title><span class="dim-title">成品入库（{{ dims.productRecpt.total }}）</span></template>
            <el-table :data="dims.productRecpt.list" size="small" border>
              <el-table-column label="入库单号" align="center" width="140" :show-overflow-tooltip="true">
                <template #default="s"><el-button link type="primary" size="small" @click="openDoc('PRODUCT_RECPT', s.row)">{{ s.row.recptCode }}</el-button></template>
              </el-table-column>
              <el-table-column label="客户" align="center" prop="clientName" min-width="120" :show-overflow-tooltip="true" />
              <el-table-column label="数量" align="center" prop="totalQuantity" width="90"  :show-overflow-tooltip="true" />
              <el-table-column label="仓库" align="center" prop="warehouseName" width="110"  :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s"><dict-tag :options="mes_itemrecpt_status" :value="s.row.status" /></template></el-table-column>
            </el-table>
          </el-collapse-item>
        </el-collapse>
      </el-card>
    </div>

    <PurOrderWizard v-model="purWizOpen" :workorder-id="workorderId" @refresh="load" />
    <OutsourceOrderCreateDialog v-model="outsourceOpen" :workorder-id="workorderId" @success="load" />
    <TaskQuickEditDialog ref="taskEditRef" v-model="taskEditOpen" @success="load" />
    <CardQrDialog v-model="qrOpen" :workorder-id="workorderId" />
    <ExceptionCreateDialog ref="exceptionRef" @success="load" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, getCurrentInstance, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getWorkorderBoard } from '@/api/mes/pro/workorder'
import { getWorkorderProgress, getWorkorderGanttReadonly } from '@/api/mes/pro/progress'
import { quickTaskStatus, dispatchTask, cancelTask } from '@/api/mes/pro/task'
import { exportPurDocExcel, fetchPurDocPdf, exportProcessDocExcel, fetchProcessDocPdf } from '@/api/mes/pro/workorderFull'
import { printPdfBlob } from '@/utils/pdfPrint'
import PurOrderWizard from './PurOrderWizard.vue'
import OutsourceOrderCreateDialog from '@/views/mes/wm/outsource/OutsourceOrderCreateDialog.vue'
import WorkorderProcessProgress from './components/WorkorderProcessProgress.vue'
import WorkorderMaterialPanel from './components/WorkorderMaterialPanel.vue'
import TaskQuickEditDialog from './components/TaskQuickEditDialog.vue'
import CardQrDialog from './components/CardQrDialog.vue'
import ExceptionCreateDialog from '../exception/components/ExceptionCreateDialog.vue'
import GanttChart from '@/components/GanttChart/index.vue'

const { proxy } = getCurrentInstance() as any
const { mes_wm_issue_status, mes_order_status, mes_outsource_status, mes_outsource_supplier_type, mes_itemrecpt_status } =
  proxy.useDict('mes_wm_issue_status', 'mes_order_status', 'mes_outsource_status', 'mes_outsource_supplier_type', 'mes_itemrecpt_status')
const route = useRoute()
const router = useRouter()

const workorderId = computed(() => Number(route.query.workorderId))
const loading = ref(false)
const wo = ref<any>({})
const materialEditable = computed(() => ['PREPARE', 'PRODUCING'].includes(wo.value?.status))
const tasks = ref<any[]>([])
const dims = ref<any>({ feedback: {}, inspection: {}, outsource: {}, purchase: {}, issue: {}, itemRecpt: {}, productRecpt: {}, reservation: {} })
const activeDims = ref<string[]>([])
const purWizOpen = ref(false)
const outsourceOpen = ref(false)
const taskEditOpen = ref(false)
const taskEditRef = ref()
const qrOpen = ref(false)
const exceptionRef = ref()
const activeTab = ref('process')
const ganttTasks = ref<any[]>([])
const ganttLoading = ref(false)
const ganttRef = ref()

const WO_STATUS = { PREPARE: '待生产', PRODUCING: '生产中', COMPLETED: '已完成', CANCEL: '已取消', CLOSED: '已关闭' }
const WO_TAG = { PREPARE: 'info', PRODUCING: 'warning', COMPLETED: 'success', CANCEL: 'danger', CLOSED: 'info' }
const FB_STATUS = { PREPARE: '待审核', CONFIRMED: '已确认', AUDITED: '已审核' }

const woStatusText = computed(() => WO_STATUS[wo.value.status] || wo.value.status || '')
const woTagType = computed(() => WO_TAG[wo.value.status] || 'info')
const progressPercent = computed(() => {
  const q = Number(wo.value.quantity) || 0, p = Number(wo.value.quantityProduced) || 0
  return q <= 0 ? 0 : Math.min(100, Math.round(p / q * 100))
})

/** 单据导出 / 打印：与工单开单页「已生成单据」一致（Excel 下载、PDF 直接调起打印） */
function doExportDoc(row: any, type: 'PUR' | 'PROC', format: 'excel' | 'pdf') {
  const label = type === 'PUR' ? '采购单' : '加工单'
  const filename = `${row.vendorName || ''}_${row.docTitle || label}_${row.orderCode}.xlsx`
  if (format === 'excel') {
    type === 'PUR' ? exportPurDocExcel(row.orderId, filename) : exportProcessDocExcel(row.orderId, filename)
    return
  }
  const req = type === 'PUR' ? fetchPurDocPdf(row.orderId) : fetchProcessDocPdf(row.orderId)
  req.then((blob: Blob) => printPdfBlob(blob)).catch(() => {})
}

/** 关联单据编号 → 对应单据详情/列表页（列表页用 openId 自动打开详情） */
const DOC_NAV: Record<string, any> = {
  FEEDBACK: { path: '/mes/pro/feedback', id: (r: any) => r.recordId },
  INSPECTION: { path: '/qc/qcipqc', id: (r: any) => r.ipqcId, extra: { ro: '1' } },
  OUTSOURCE: { path: '/mes/wm/outsource', id: (r: any) => r.orderId },
  PURCHASE: { path: '/mes/pur/order_detail', param: 'orderId', id: (r: any) => r.orderId },
  ISSUE: { path: '/mes/wm/issue', id: (r: any) => r.issueId },
  ITEM_RECPT: { path: '/mes/wm/item_recpt', id: (r: any) => r.recptId },
  PRODUCT_RECPT: { path: '/mes/wm/product_recpt', id: (r: any) => r.recptId }
}
function openDoc(type: string, row: any) {
  const cfg = DOC_NAV[type]
  if (!cfg || !row) return
  const id = cfg.id(row)
  if (!id) return
  router.push({ path: cfg.path, query: { [cfg.param || 'openId']: String(id), ...(cfg.extra || {}) } })
}

/** 工序快捷状态（弱流程记录，不校验机台/负责人/质检） */
function quickStatus(t: any, action: string) {
  if (action === 'EXCEPTION') {
    exceptionRef.value?.open(t)
    return
  }
  const label = ({ START: '开工', PAUSE: '停止', COMPLETE: '完成', DISPATCH: '下发', CANCEL: '取消' } as Record<string, string>)[action]
  const run = () => {
    const req = action === 'DISPATCH' ? dispatchTask(t.taskId)
      : action === 'CANCEL' ? cancelTask(t.taskId)
      : quickTaskStatus(t.taskId, action)
    req.then(() => {
      proxy.$modal.msgSuccess(label + '成功')
      load()
    }).catch(() => {})
  }
  if (action === 'START') run()
  else proxy.$modal.confirm(`确认${label}工序「${t.processName || ''}」？`).then(run).catch(() => {})
}
function fbStatusText(s: string) { return FB_STATUS[s] || s || '-' }
function fbTagType(s: string) { return ({ AUDITED: 'success', CONFIRMED: 'warning', PREPARE: 'info' })[s] || 'info' }
function fmtDate(v?: string) { return v ? proxy.parseTime(v, '{y}-{m}-{d}') : '-' }
function goBack() { router.push('/mes/pro/workorder') }
function goProcess(t: any) { router.push({ path: '/mes/pro/process_board', query: { taskId: t.taskId } }) }
function openOutsource() { outsourceOpen.value = true }
function openTaskEdit(row: any) { taskEditRef.value?.open(row.taskId) }
function openCardQr() { qrOpen.value = true }
/** 跳转排产任务页并预填当前工单，新增工序任务 */
function goAddTask() { router.push({ path: '/mes/pro/task', query: { add: '1', workorderId: String(workorderId.value) } }) }
/** 跳转报工页并自动带入该工序任务 */
function goFeedback(row: any) {
  router.push({ path: '/mes/pro/feedback', query: { add: '1', taskId: row.taskId } })
}

function load() {
  if (!workorderId.value) return
  loading.value = true
  ganttLoading.value = true
  Promise.all([
    getWorkorderBoard(workorderId.value),
    getWorkorderProgress(workorderId.value).catch(() => null),
    getWorkorderGanttReadonly(workorderId.value).catch(() => null)
  ]).then(([r, p, g]) => {
    if (!r.data) return
    wo.value = r.data.workorder || {}
    ganttTasks.value = (g as any)?.data?.tasks || []
    nextTick(() => { if (activeTab.value === 'gantt') ganttRef.value?.fitToData() })
    // 合并进度数据（计划/实际时间、完成率、延期），按 taskId 对齐
    const progressByTask = new Map<number, any>()
    ;((p as any)?.data?.processes || []).forEach((row: any) => progressByTask.set(row.taskId, row))
    tasks.value = (r.data.tasks || []).map((t: any) => {
      const pr = progressByTask.get(t.taskId)
      return pr ? { ...t, ...pr } : t
    })
    dims.value = {
      feedback: r.data.feedback || {},
      inspection: r.data.inspection || {},
      outsource: r.data.outsource || {},
      purchase: r.data.purchase || {},
      issue: r.data.issue || {},
      itemRecpt: r.data.itemRecpt || {},
      productRecpt: r.data.productRecpt || {},
      reservation: r.data.reservation || {},
    }
  }).finally(() => { loading.value = false; ganttLoading.value = false })
}

function reservationStatusText(status?: string) {
  const map: Record<string, string> = {
    OPEN: '待预占',
    PARTIAL: '部分预占',
    RESERVED: '已预占',
    TRANSFERRED: '已转领料',
    CONSUMED: '已消耗',
    RELEASED: '已释放'
  }
  return status ? (map[status] || status) : '-'
}

/** 切到甘特图 tab 时自适应缩放 */
async function onTabChange(name: string | number) {
  if (name === 'gantt') {
    await nextTick()
    ganttRef.value?.fitToData()
  }
}

load()
</script>

<style scoped>
.mb16 { margin-bottom: 16px; }
.board-actions { display: flex; align-items: center; gap: 10px; }
.action-tip { color: #909399; font-size: 12px; }
.gantt-wrap { min-height: 500px; border: 1px solid #ebeef5; border-radius: 4px; padding: 8px; }
.mt16 { margin-top: 16px; }
.ml8 { margin-left: 8px; }
.header-title { font-weight: bold; font-size: 16px; margin-right: 8px; }
.card-head { display: flex; align-items: center; justify-content: space-between; }
.dim-title { font-weight: 600; }
:deep(.op-col .el-button + .el-button) { margin-left: 4px; }
</style>