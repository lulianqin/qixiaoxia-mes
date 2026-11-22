<template>
  <el-table :data="rows" size="small" border @row-click="onRowClick">
    <el-table-column label="序" align="center" type="index" width="50" />
    <el-table-column label="工序名称" align="center" prop="processName" min-width="130" :show-overflow-tooltip="true">
      <template #default="s">
        <el-button link type="primary" @click.stop="emit('process-board', s.row)">{{ s.row.processName || '-' }}</el-button>
        <el-tag v-if="s.row.isOutsource === '1'" size="small" type="warning" class="ml8">外协</el-tag>
      </template>
    </el-table-column>
    <el-table-column label="工作站" align="center" prop="workstationName" min-width="110" :show-overflow-tooltip="true">
      <template #default="s">{{ s.row.workstationName || '-' }}</template>
    </el-table-column>
    <el-table-column label="状态" align="center" width="90">
      <template #default="s"><el-tag :type="taskTagType(s.row)" size="small">{{ taskStatusText(s.row) }}</el-tag></template>
    </el-table-column>
    <el-table-column label="负责人" align="center" prop="leaderNick" width="90" :show-overflow-tooltip="true">
      <template #default="s">{{ s.row.leaderNick || '-' }}</template>
    </el-table-column>
    <el-table-column label="报工人" align="center" prop="workerNick" width="90" :show-overflow-tooltip="true">
      <template #default="s">{{ s.row.workerNick || '-' }}</template>
    </el-table-column>
    <el-table-column label="数量" align="center" width="120">
      <template #default="s">
        <div>{{ s.row.quantityProduced ?? 0 }} / {{ s.row.quantity ?? 0 }}</div>
        <div class="sub">合格 {{ s.row.quantityQualified ?? 0 }}</div>
        <div class="sub bad" v-if="Number(s.row.quantityUnqualified || 0) > 0">不合格 {{ s.row.quantityUnqualified }}</div>
      </template>
    </el-table-column>
    <el-table-column label="计划时间" align="center" width="170">
      <template #default="s">
        <div>{{ fmtTime(s.row.planStartTime || s.row.startTime) }}</div>
        <div class="sub">~ {{ fmtTime(s.row.planEndTime || s.row.endTime) }}</div>
      </template>
    </el-table-column>
    <el-table-column label="实际时间" align="center" width="170">
      <template #default="s">
        <template v-if="s.row.actualStartTime || s.row.actualEndTime">
          <div>{{ fmtTime(s.row.actualStartTime) }}</div>
          <div class="sub">~ {{ fmtTime(s.row.actualEndTime) }}</div>
        </template>
        <span v-else>-</span>
      </template>
    </el-table-column>
    <el-table-column label="完成率" align="center" width="130">
      <template #default="s">
        <el-progress :percentage="Number(s.row.completionRate ?? 0)" :stroke-width="12" />
      </template>
    </el-table-column>
    <el-table-column label="延期" align="center" width="90">
      <template #default="s">
        <el-tag :type="delayTagType(s.row.delayLevel)" size="small">{{ delayLabel(s.row.delayLevel) }}</el-tag>
      </template>
    </el-table-column>
    <el-table-column label="操作" align="center" width="220" fixed="right" class-name="op-col">
      <template #default="s">
        <el-button v-if="canDispatch(s.row)" link type="success" size="small"
          @click.stop="emit('action', s.row, 'DISPATCH')" v-hasPermi="['mes:pro:task:edit']">下发</el-button>
        <el-button v-if="canStartTask(s.row)" link type="primary" size="small"
          @click.stop="emit('action', s.row, 'START')" v-hasPermi="['mes:pro:task:edit']">开工</el-button>
        <el-button v-if="s.row.status === 'PRODUCING'" link type="warning" size="small"
          @click.stop="emit('action', s.row, 'PAUSE')" v-hasPermi="['mes:pro:task:edit']">停止</el-button>
        <el-button v-if="canReport(s.row)" link type="success" size="small"
          @click.stop="emit('report', s.row)" v-hasPermi="['mes:pro:feedback:add']">报工</el-button>
        <el-button v-if="!isFinal(s.row)" link type="success" size="small"
          @click.stop="emit('action', s.row, 'COMPLETE')" v-hasPermi="['mes:pro:task:edit']">完成</el-button>
        <el-button link type="primary" size="small" @click.stop="emit('edit', s.row)" v-hasPermi="['mes:pro:task:edit']">编辑</el-button>
        <el-button link type="primary" size="small" @click.stop="emit('qrcode', s.row)" v-hasPermi="['mes:pro:card:query']">二维码</el-button>
        <el-button link type="primary" size="small" @click.stop="emit('process-board', s.row)">工序看板</el-button>
        <el-button v-if="!isFinal(s.row)" link type="danger" size="small"
          @click.stop="emit('action', s.row, 'CANCEL')" v-hasPermi="['mes:pro:task:edit']">取消</el-button>
        <el-button v-if="!isFinal(s.row)" link type="primary" size="small"
          @click.stop="emit('action', s.row, 'EXCEPTION')" v-hasPermi="['mes:pro:exception:add']">报异常</el-button>
      </template>
    </el-table-column>
  </el-table>
</template>

<script setup lang="ts">
import { parseTime } from '@/utils/ruoyi'
import { delayText, delayType } from '@/utils/mes/progress'

defineProps<{ rows: any[] }>()
const emit = defineEmits<{
  (e: 'edit', row: any): void
  (e: 'report', row: any): void
  (e: 'action', row: any, action: string): void
  (e: 'process-board', row: any): void
  (e: 'qrcode', row: any): void
}>()

const TASK_STATUS: Record<string, string> = {
  NORMAL: '未开工', PREPARE: '未开工', PRODUCING: '生产中',
  PAUSED: '已停止', COMPLETED: '已完成', CANCEL: '已取消'
}

function taskStatusText(t: any) { return t.qcBlocked ? '不可开工' : (TASK_STATUS[t.status] || t.status || '') }
function taskTagType(t: any) {
  if (t.qcBlocked) return 'error'
  return ({ COMPLETED: 'success', PRODUCING: 'warning', PAUSED: 'info', CANCEL: 'error' } as any)[t.status] || 'info'
}
function canStartTask(t: any) { return ['NORMAL', 'PREPARE', 'PAUSED'].includes(t.status) }
function canDispatch(t: any) { return ['NORMAL', 'PREPARE'].includes(t.status) && !t.qcBlocked }
function canReport(t: any) { return t.status === 'PRODUCING' && !t.qcBlocked }
function isFinal(t: any) { return t.status === 'COMPLETED' || t.status === 'CANCEL' }
function onRowClick(row: any) { emit('process-board', row) }
function fmtTime(v: any) { return v ? parseTime(v, '{m}-{d} {h}:{i}') : '-' }
function delayLabel(level: string) { return level ? delayText(level) : '-' }
function delayTagType(level: string) { return level ? delayType(level) : 'info' }
</script>

<style scoped>
.ml8 { margin-left: 8px; }
.sub { font-size: 12px; color: #909399; line-height: 1.4; }
.sub.bad { color: #f56c6c; }
/* 操作列按钮两行排布，间距紧凑 */
:deep(.op-col .cell) { white-space: normal; line-height: 24px; }
/* 覆盖全局 .el-button--small 的 0 15px 内边距，避免按钮文字被撑开 */
:deep(.op-col .el-button) { padding: 0 3px !important; height: 24px; font-size: 12px; }
:deep(.op-col .el-button + .el-button) { margin-left: 4px; }
</style>
