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
        <WorkorderProcessProgress :rows="tasks"
          @edit="openTaskEdit" @report="goFeedback" @action="quickStatus" @process-board="goProcess" @qrcode="openCardQr" />
      </el-card>

      <!-- 关联单据汇总 -->
      <el-card shadow="never" class="mb16">
        <template #header><span>关联单据</span></template>
        <el-row :gutter="12">
          <el-col :span="4" v-for="d in dimCards" :key="d.key">
            <el-card shadow="hover" class="dim-card" :class="{ active: activeDim === d.key }" @click="activeDim = activeDim === d.key ? '' : d.key">
              <div class="dim-num">{{ d.total }}</div>
              <div class="dim-label">{{ d.label }}</div>
            </el-card>
          </el-col>
        </el-row>

        <el-collapse v-model="activeDims" class="mt16">
          <el-collapse-item name="feedback" v-if="dims.feedback.total >= 0">
            <template #title><span class="dim-title">报工记录（{{ dims.feedback.total }}）<el-tag v-if="dims.feedback.pending" size="small" type="warning" class="ml8">待审核 {{ dims.feedback.pending }}</el-tag><el-tag v-if="dims.feedback.audited" size="small" type="success" class="ml8">已审核 {{ dims.feedback.audited }}</el-tag></span></template>
            <el-table :data="dims.feedback.list" size="small" border>
              <el-table-column label="报工编码" align="center" prop="feedbackCode" width="140"  :show-overflow-tooltip="true" />
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
              <el-table-column label="检验编码" align="center" prop="ipqcCode" width="140"  :show-overflow-tooltip="true" />
              <el-table-column label="检验类型" align="center" prop="ipqcName" width="110"  :show-overflow-tooltip="true" />
              <el-table-column label="工序" align="center" prop="processName" min-width="110" :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s">{{ s.row.status || '-' }}</template></el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="outsource">
            <template #title><span class="dim-title">加工单（外协）（{{ dims.outsource.total }}）</span></template>
            <el-table :data="dims.outsource.list" size="small" border>
              <el-table-column label="加工单号" align="center" prop="orderCode" width="140"  :show-overflow-tooltip="true" />
              <el-table-column label="工序" align="center" prop="processName" min-width="110" :show-overflow-tooltip="true" />
              <el-table-column label="外协厂商" align="center" prop="vendorName" min-width="120" :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s">{{ s.row.status || '-' }}</template></el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="purchase">
            <template #title><span class="dim-title">采购单（{{ dims.purchase.total || 0 }}）</span></template>
            <el-table :data="dims.purchase.list || []" size="small" border>
              <el-table-column label="采购单号" align="center" prop="orderCode" width="150" :show-overflow-tooltip="true" />
              <el-table-column label="单据名称" align="center" prop="orderName" min-width="130" :show-overflow-tooltip="true" />
              <el-table-column label="供应商" align="center" prop="vendorName" min-width="120" :show-overflow-tooltip="true" />
              <el-table-column label="采购数量" align="center" prop="totalQuantity" width="100" />
              <el-table-column label="采购金额" align="center" prop="totalAmount" width="110" />
              <el-table-column label="预计到货" align="center" width="120">
                <template #default="s">{{ fmtDate(s.row.expectedDate) }}</template>
              </el-table-column>
              <el-table-column label="状态" align="center" prop="status" width="100" :show-overflow-tooltip="true" />
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="issue">
            <template #title><span class="dim-title">领料/发料（{{ dims.issue.total }}）</span></template>
            <el-table :data="dims.issue.list" size="small" border>
              <el-table-column label="单据编码" align="center" prop="issueCode" width="140"  :show-overflow-tooltip="true" />
              <el-table-column label="单据名称" align="center" prop="issueName" min-width="120" :show-overflow-tooltip="true" />
              <el-table-column label="工序" align="center" prop="processName" min-width="110" :show-overflow-tooltip="true" />
              <el-table-column label="仓库" align="center" prop="warehouseName" width="110"  :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s"><dict-tag :options="mes_wm_issue_status" :value="s.row.status" /></template></el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="itemRecpt">
            <template #title><span class="dim-title">收料（{{ dims.itemRecpt.total }}）</span></template>
            <el-table :data="dims.itemRecpt.list" size="small" border>
              <el-table-column label="收料单号" align="center" prop="recptCode" width="140"  :show-overflow-tooltip="true" />
              <el-table-column label="采购单号" align="center" prop="purOrderCode" width="130"  :show-overflow-tooltip="true" />
              <el-table-column label="供应商" align="center" prop="vendorName" min-width="120" :show-overflow-tooltip="true" />
              <el-table-column label="数量" align="center" prop="totalQuantity" width="90"  :show-overflow-tooltip="true" />
              <el-table-column label="仓库" align="center" prop="warehouseName" width="110"  :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s">{{ s.row.status || '-' }}</template></el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="productRecpt">
            <template #title><span class="dim-title">成品入库（{{ dims.productRecpt.total }}）</span></template>
            <el-table :data="dims.productRecpt.list" size="small" border>
              <el-table-column label="入库单号" align="center" prop="recptCode" width="140"  :show-overflow-tooltip="true" />
              <el-table-column label="客户" align="center" prop="clientName" min-width="120" :show-overflow-tooltip="true" />
              <el-table-column label="数量" align="center" prop="totalQuantity" width="90"  :show-overflow-tooltip="true" />
              <el-table-column label="仓库" align="center" prop="warehouseName" width="110"  :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s">{{ s.row.status || '-' }}</template></el-table-column>
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
import { ref, computed, getCurrentInstance } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getWorkorderBoard } from '@/api/mes/pro/workorder'
import { getWorkorderProgress } from '@/api/mes/pro/progress'
import { quickTaskStatus, dispatchTask, cancelTask } from '@/api/mes/pro/task'
import PurOrderWizard from './PurOrderWizard.vue'
import OutsourceOrderCreateDialog from '@/views/mes/wm/outsource/OutsourceOrderCreateDialog.vue'
import WorkorderProcessProgress from './components/WorkorderProcessProgress.vue'
import TaskQuickEditDialog from './components/TaskQuickEditDialog.vue'
import CardQrDialog from './components/CardQrDialog.vue'
import ExceptionCreateDialog from '../exception/components/ExceptionCreateDialog.vue'

const { proxy } = getCurrentInstance() as any
const { mes_wm_issue_status } = proxy.useDict('mes_wm_issue_status')
const route = useRoute()
const router = useRouter()

const workorderId = computed(() => Number(route.query.workorderId))
const loading = ref(false)
const wo = ref<any>({})
const tasks = ref<any[]>([])
const dims = ref<any>({ feedback: {}, inspection: {}, outsource: {}, purchase: {}, issue: {}, itemRecpt: {}, productRecpt: {} })
const activeDims = ref<string[]>([])
const activeDim = ref('')
const purWizOpen = ref(false)
const outsourceOpen = ref(false)
const taskEditOpen = ref(false)
const taskEditRef = ref()
const qrOpen = ref(false)
const exceptionRef = ref()

const WO_STATUS = { PREPARE: '待生产', PRODUCING: '生产中', COMPLETED: '已完成', CANCEL: '已取消', CLOSED: '已关闭' }
const WO_TAG = { PREPARE: 'info', PRODUCING: 'warning', COMPLETED: 'success', CANCEL: 'danger', CLOSED: 'info' }
const FB_STATUS = { PREPARE: '待审核', CONFIRMED: '已确认', AUDITED: '已审核' }

const woStatusText = computed(() => WO_STATUS[wo.value.status] || wo.value.status || '')
const woTagType = computed(() => WO_TAG[wo.value.status] || 'info')
const progressPercent = computed(() => {
  const q = Number(wo.value.quantity) || 0, p = Number(wo.value.quantityProduced) || 0
  return q <= 0 ? 0 : Math.min(100, Math.round(p / q * 100))
})

const dimCards = computed(() => [
  { key: 'feedback', label: '报工', total: dims.value.feedback.total ?? 0 },
  { key: 'inspection', label: '检验', total: dims.value.inspection.total ?? 0 },
  { key: 'outsource', label: '加工单', total: dims.value.outsource.total ?? 0 },
  { key: 'purchase', label: '采购', total: dims.value.purchase.total ?? 0 },
  { key: 'issue', label: '领料', total: dims.value.issue.total ?? 0 },
  { key: 'itemRecpt', label: '收料', total: dims.value.itemRecpt.total ?? 0 },
  { key: 'productRecpt', label: '入库', total: dims.value.productRecpt.total ?? 0 },
])

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
  Promise.all([
    getWorkorderBoard(workorderId.value),
    getWorkorderProgress(workorderId.value).catch(() => null)
  ]).then(([r, p]) => {
    if (!r.data) return
    wo.value = r.data.workorder || {}
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
    }
  }).finally(() => { loading.value = false })
}

load()
</script>

<style scoped>
.mb16 { margin-bottom: 16px; }
.board-actions { display: flex; align-items: center; gap: 10px; }
.action-tip { color: #909399; font-size: 12px; }
.mt16 { margin-top: 16px; }
.ml8 { margin-left: 8px; }
.header-title { font-weight: bold; font-size: 16px; margin-right: 8px; }
.card-head { display: flex; align-items: center; justify-content: space-between; }
.dim-card { text-align: center; cursor: pointer; border-left: 3px solid #ebeef5; }
.dim-card.active { border-left-color: #409eff; }
.dim-num { font-size: 26px; font-weight: bold; color: #1f2d3d; }
.dim-label { color: #909399; font-size: 13px; margin-top: 4px; }
.dim-title { font-weight: 600; }
</style>