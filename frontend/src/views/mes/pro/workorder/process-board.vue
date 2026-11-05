<template>
  <div class="app-container">
    <el-page-header @back="goBack" class="mb16">
      <template #content>
        <span class="header-title">工序看板</span>
        <el-tag v-if="task.processName" type="info" class="ml8">{{ task.processName }}</el-tag>
        <el-tag v-if="task.status" :type="statusTagType" class="ml8">{{ statusText }}</el-tag>
        <el-tag v-if="task.isOutsource === '1'" type="warning" class="ml8">外协</el-tag>
      </template>
      <template #extra>
        <el-button link type="primary" size="small" @click="goWorkorder" v-if="wo.workorderId">所属工单：{{ wo.workorderCode }}</el-button>
      </template>
    </el-page-header>

    <div v-loading="loading">
      <!-- 工序信息 -->
      <el-card shadow="never" class="mb16">
        <template #header><span>工序信息</span></template>
        <el-descriptions :column="3" size="small" border>
          <el-descriptions-item label="工序名称">{{ task.processName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="负责人">{{ task.leaderNick || '-' }}</el-descriptions-item>
          <el-descriptions-item label="报工人">{{ task.workerNick || '-' }}</el-descriptions-item>
          <el-descriptions-item label="工作站">{{ task.workstationName || task.workstationCode || '-' }}</el-descriptions-item>
          <el-descriptions-item label="工单">{{ wo.workorderCode || '-' }}</el-descriptions-item>
          <el-descriptions-item label="产品">{{ wo.productName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="上机时间">{{ fmtTime(task.startTime) }}</el-descriptions-item>
          <el-descriptions-item label="计划完成">{{ fmtTime(task.endTime) }}</el-descriptions-item>
          <el-descriptions-item label="完工时间">{{ fmtTime(task.finishDate) }}</el-descriptions-item>
        </el-descriptions>
        <el-row :gutter="12" class="mt16">
          <el-col :span="6"><div class="stat"><div class="stat-num">{{ task.quantity || 0 }}</div><div class="stat-label">排产</div></div></el-col>
          <el-col :span="6"><div class="stat"><div class="stat-num hl">{{ task.quantityProduced || 0 }}</div><div class="stat-label">已产</div></div></el-col>
          <el-col :span="6"><div class="stat"><div class="stat-num ok">{{ task.quantityQualified || 0 }}</div><div class="stat-label">合格</div></div></el-col>
          <el-col :span="6"><div class="stat"><div class="stat-num bad">{{ task.quantityUnqualified || 0 }}</div><div class="stat-label">不合格</div></div></el-col>
        </el-row>
      </el-card>

      <!-- 关联单据 -->
      <el-card shadow="never">
        <template #header><span>关联单据</span></template>
        <el-row :gutter="12" class="mb16">
          <el-col :span="6" v-for="d in dimCards" :key="d.key">
            <div class="dim-num">{{ d.total }}</div>
            <div class="dim-label">{{ d.label }}</div>
          </el-col>
        </el-row>

        <el-collapse v-model="activeDims">
          <el-collapse-item name="feedback">
            <template #title><span class="dim-title">报工记录（{{ dims.feedback.total }}）<el-tag v-if="dims.feedback.pending" size="small" type="warning" class="ml8">待审核 {{ dims.feedback.pending }}</el-tag><el-tag v-if="dims.feedback.audited" size="small" type="success" class="ml8">已审核 {{ dims.feedback.audited }}</el-tag></span></template>
            <el-table :data="dims.feedback.list" size="small" border>
              <el-table-column label="报工编码" align="center" prop="feedbackCode" width="140"  :show-overflow-tooltip="true" />
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
              <el-table-column label="检验类型" align="center" prop="ipqcName" width="120"  :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s">{{ s.row.status || '-' }}</template></el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="outsource">
            <template #title><span class="dim-title">外协单（{{ dims.outsource.total }}）</span></template>
            <el-table :data="dims.outsource.list" size="small" border>
              <el-table-column label="外协单号" align="center" prop="orderCode" width="140"  :show-overflow-tooltip="true" />
              <el-table-column label="外协厂商" align="center" prop="vendorName" min-width="120" :show-overflow-tooltip="true" />
              <el-table-column label="状态" align="center" width="90"><template #default="s">{{ s.row.status || '-' }}</template></el-table-column>
            </el-table>
          </el-collapse-item>
          <el-collapse-item name="issue">
            <template #title><span class="dim-title">领料/发料（{{ dims.issue.total }}）</span></template>
            <el-table :data="dims.issue.list" size="small" border>
              <el-table-column label="单据编码" align="center" prop="issueCode" width="140"  :show-overflow-tooltip="true" />
              <el-table-column label="单据名称" align="center" prop="issueName" min-width="120" :show-overflow-tooltip="true" />
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
import { getProcessBoard } from '@/api/mes/pro/workorder'

const { proxy } = getCurrentInstance() as any
const route = useRoute()
const router = useRouter()

const taskId = computed(() => Number(route.query.taskId))
const loading = ref(false)
const task = ref<any>({})
const wo = ref<any>({})
const dims = ref<any>({ feedback: {}, inspection: {}, outsource: {}, issue: {} })
const activeDims = ref<string[]>([])

const TASK_STATUS = { NORMAL: '未开工', PRODUCING: '生产中', COMPLETED: '已完成', CANCEL: '已取消' }
const FB_STATUS = { PREPARE: '待审核', CONFIRMED: '已确认', AUDITED: '已审核' }

const statusText = computed(() => {
  if (task.value.qcBlocked) return '不可开工'
  if (task.value.isOutsource === '1' && task.value.status === 'PRODUCING') return '外协中'
  return TASK_STATUS[task.value.status] || task.value.status || ''
})
const statusTagType = computed(() => {
  if (task.value.qcBlocked) return 'error'
  return ({ COMPLETED: 'success', PRODUCING: 'warning', CANCEL: 'error' })[task.value.status] || 'info'
})
const dimCards = computed(() => [
  { key: 'feedback', label: '报工', total: dims.value.feedback.total ?? 0 },
  { key: 'inspection', label: '检验', total: dims.value.inspection.total ?? 0 },
  { key: 'outsource', label: '外协', total: dims.value.outsource.total ?? 0 },
  { key: 'issue', label: '领料', total: dims.value.issue.total ?? 0 },
])

function fbStatusText(s: string) { return FB_STATUS[s] || s || '-' }
function fbTagType(s: string) { return ({ AUDITED: 'success', CONFIRMED: 'warning', PREPARE: 'info' })[s] || 'info' }
function fmtTime(v?: string) { return v ? proxy.parseTime(v, '{m}-{d} {h}:{i}') : '-' }
function goBack() { router.push('/mes/pro/workorder') }
function goWorkorder() { router.push({ path: '/mes/pro/workorder_board', query: { workorderId: wo.value.workorderId } }) }

function load() {
  if (!taskId.value) return
  loading.value = true
  getProcessBoard(taskId.value).then(r => {
    if (r.data) {
      task.value = r.data.task || {}
      wo.value = r.data.workorder || {}
      dims.value = {
        feedback: r.data.feedback || {},
        inspection: r.data.inspection || {},
        outsource: r.data.outsource || {},
        issue: r.data.issue || {},
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
.stat { text-align: center; padding: 12px 0; background: #fafafa; border-radius: 8px; }
.stat-num { font-size: 22px; font-weight: bold; color: #1f2d3d; }
.stat-num.hl { color: #409eff; }
.stat-num.ok { color: #67c23a; }
.stat-num.bad { color: #f56c6c; }
.stat-label { color: #909399; font-size: 12px; margin-top: 4px; }
.dim-num { text-align: center; font-size: 22px; font-weight: bold; color: #1f2d3d; }
.dim-label { text-align: center; color: #909399; font-size: 12px; margin-top: 2px; }
.dim-title { font-weight: 600; }
</style>