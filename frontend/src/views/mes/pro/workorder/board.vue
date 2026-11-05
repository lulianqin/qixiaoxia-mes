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

      <!-- 工序任务 -->
      <el-card shadow="never" class="mb16">
        <template #header><span>工序进度（{{ tasks.length }}）</span></template>
        <el-table :data="tasks" size="small" border @row-click="goProcess">
          <el-table-column label="序" align="center" type="index" width="50" />
          <el-table-column label="工序名称" align="center" prop="processName" min-width="120" :show-overflow-tooltip="true">
            <template #default="s">
              <el-button link type="primary" @click.stop="goProcess(s.row)">{{ s.row.processName || '-' }}</el-button>
              <el-tag v-if="s.row.isOutsource === '1'" size="small" type="warning" class="ml8">外协</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="状态" align="center" width="90">
            <template #default="s"><el-tag :type="taskTagType(s.row)" size="small">{{ taskStatusText(s.row) }}</el-tag></template>
          </el-table-column>
          <el-table-column label="负责人" align="center" prop="leaderNick" width="90" :show-overflow-tooltip="true"><template #default="s">{{ s.row.leaderNick || '-' }}</template></el-table-column>
          <el-table-column label="报工人" align="center" prop="workerNick" width="90" :show-overflow-tooltip="true"><template #default="s">{{ s.row.workerNick || '-' }}</template></el-table-column>
          <el-table-column label="排产" align="center" prop="quantity" width="80"  :show-overflow-tooltip="true" />
          <el-table-column label="已产" align="center" prop="quantityProduced" width="80"  :show-overflow-tooltip="true" />
          <el-table-column label="合格" align="center" prop="quantityQualified" width="80"  :show-overflow-tooltip="true" />
          <el-table-column label="不合格" align="center" prop="quantityUnqualified" width="80"  :show-overflow-tooltip="true" />
          <el-table-column label="上机" align="center" width="110"><template #default="s">{{ fmtTime(s.row.startTime) }}</template></el-table-column>
          <el-table-column label="完工" align="center" width="110"><template #default="s">{{ fmtTime(s.row.finishDate) }}</template></el-table-column>
          <el-table-column label="操作" align="center" width="90" fixed="right">
            <template #default="s"><el-button link type="primary" size="small" @click.stop="goProcess(s.row)">工序看板</el-button></template>
          </el-table-column>
        </el-table>
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
            <template #title><span class="dim-title">外协单（{{ dims.outsource.total }}）</span></template>
            <el-table :data="dims.outsource.list" size="small" border>
              <el-table-column label="外协单号" align="center" prop="orderCode" width="140"  :show-overflow-tooltip="true" />
              <el-table-column label="工序" align="center" prop="processName" min-width="110" :show-overflow-tooltip="true" />
              <el-table-column label="外协厂商" align="center" prop="vendorName" min-width="120" :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s">{{ s.row.status || '-' }}</template></el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="issue">
            <template #title><span class="dim-title">领料/发料（{{ dims.issue.total }}）</span></template>
            <el-table :data="dims.issue.list" size="small" border>
              <el-table-column label="单据编码" align="center" prop="issueCode" width="140"  :show-overflow-tooltip="true" />
              <el-table-column label="单据名称" align="center" prop="issueName" min-width="120" :show-overflow-tooltip="true" />
              <el-table-column label="工序" align="center" prop="processName" min-width="110" :show-overflow-tooltip="true" />
              <el-table-column label="仓库" align="center" prop="warehouseName" width="110"  :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s">{{ s.row.status || '-' }}</template></el-table-column>
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, getCurrentInstance } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getWorkorderBoard } from '@/api/mes/pro/workorder'

const { proxy } = getCurrentInstance() as any
const route = useRoute()
const router = useRouter()

const workorderId = computed(() => Number(route.query.workorderId))
const loading = ref(false)
const wo = ref<any>({})
const tasks = ref<any[]>([])
const dims = ref<any>({ feedback: {}, inspection: {}, outsource: {}, issue: {}, itemRecpt: {}, productRecpt: {} })
const activeDims = ref<string[]>([])
const activeDim = ref('')

const WO_STATUS = { PREPARE: '待生产', PRODUCING: '生产中', COMPLETED: '已完成', CANCEL: '已取消', CLOSED: '已关闭' }
const WO_TAG = { PREPARE: 'info', PRODUCING: 'warning', COMPLETED: 'success', CANCEL: 'danger', CLOSED: 'info' }
const TASK_STATUS = { NORMAL: '未开工', PRODUCING: '生产中', COMPLETED: '已完成', CANCEL: '已取消' }
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
  { key: 'outsource', label: '外协', total: dims.value.outsource.total ?? 0 },
  { key: 'issue', label: '领料', total: dims.value.issue.total ?? 0 },
  { key: 'itemRecpt', label: '收料', total: dims.value.itemRecpt.total ?? 0 },
  { key: 'productRecpt', label: '入库', total: dims.value.productRecpt.total ?? 0 },
])

function taskStatusText(t: any) { return t.qcBlocked ? '不可开工' : (TASK_STATUS[t.status] || t.status || '') }
function taskTagType(t: any) { if (t.qcBlocked) return 'error'; return ({ COMPLETED: 'success', PRODUCING: 'warning', CANCEL: 'error' })[t.status] || 'info' }
function fbStatusText(s: string) { return FB_STATUS[s] || s || '-' }
function fbTagType(s: string) { return ({ AUDITED: 'success', CONFIRMED: 'warning', PREPARE: 'info' })[s] || 'info' }
function fmtDate(v?: string) { return v ? proxy.parseTime(v, '{y}-{m}-{d}') : '-' }
function fmtTime(v?: string) { return v ? proxy.parseTime(v, '{m}-{d} {h}:{i}') : '-' }
function goBack() { router.push('/mes/pro/workorder') }
function goProcess(t: any) { router.push({ path: '/mes/pro/process_board', query: { taskId: t.taskId } }) }

function load() {
  if (!workorderId.value) return
  loading.value = true
  getWorkorderBoard(workorderId.value).then(r => {
    if (r.data) {
      wo.value = r.data.workorder || {}
      tasks.value = r.data.tasks || []
      dims.value = {
        feedback: r.data.feedback || {},
        inspection: r.data.inspection || {},
        outsource: r.data.outsource || {},
        issue: r.data.issue || {},
        itemRecpt: r.data.itemRecpt || {},
        productRecpt: r.data.productRecpt || {},
      }
    }
  }).finally(() => { loading.value = false })
}

load()
</script>

<style scoped>
.mb16 { margin-bottom: 16px; }
.mt16 { margin-top: 16px; }
.ml8 { margin-left: 8px; }
.header-title { font-weight: bold; font-size: 16px; margin-right: 8px; }
.dim-card { text-align: center; cursor: pointer; border-left: 3px solid #ebeef5; }
.dim-card.active { border-left-color: #409eff; }
.dim-num { font-size: 26px; font-weight: bold; color: #1f2d3d; }
.dim-label { color: #909399; font-size: 13px; margin-top: 4px; }
.dim-title { font-weight: 600; }
</style>