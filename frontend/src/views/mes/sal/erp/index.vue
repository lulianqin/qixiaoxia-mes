<template>
  <div class="app-container">
    <el-tabs v-model="activeTab">
      <el-tab-pane label="ERP 对接配置" name="config">
        <el-form :model="endpoint" label-width="110px" style="max-width: 720px; margin-top: 10px" v-loading="configLoading">
          <el-form-item label="系统名称">
            <el-input v-model="endpoint.systemName" maxlength="100" placeholder="ERP系统" />
          </el-form-item>
          <el-form-item label="回调基地址">
            <el-input v-model="endpoint.baseUrl" maxlength="500" placeholder="如 http://erp.example.com/prod-api" />
          </el-form-item>
          <el-form-item label="回调 API Key">
            <el-input v-model="endpoint.apiKey" maxlength="200" show-password placeholder="MES 回写 ERP 时携带的 X-API-Key" />
          </el-form-item>
          <el-form-item label="启用">
            <el-switch v-model="endpoint.enabled" active-value="0" inactive-value="1" />
            <span style="margin-left: 8px; color: #909399">停用后回写任务会保留并告警，不会自动重试成功</span>
          </el-form-item>
          <el-form-item label="备注">
            <el-input v-model="endpoint.remark" type="textarea" :rows="2" maxlength="500" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="configLoading" @click="saveConfig" v-hasPermi="['mes:sal:erp:edit']">保存</el-button>
          </el-form-item>
        </el-form>
      </el-tab-pane>

      <el-tab-pane label="回写记录" name="task">
        <el-form :model="query" :inline="true" label-width="80px">
          <el-form-item label="业务单号"><el-input v-model="query.bizNo" placeholder="订单号/报价单号" clearable @keyup.enter="loadTasks" /></el-form-item>
          <el-form-item label="业务类型">
            <el-select v-model="query.bizType" placeholder="全部" clearable style="width: 140px">
              <el-option label="接单回写" value="ORDER_ACCEPT" />
              <el-option label="打回回写" value="ORDER_REJECT" />
              <el-option label="报价回写" value="QUOTE_SUBMIT" />
            </el-select>
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="query.status" placeholder="全部" clearable style="width: 120px">
              <el-option label="待执行" value="PENDING" />
              <el-option label="执行中" value="RUNNING" />
              <el-option label="成功" value="SUCCESS" />
              <el-option label="失败" value="FAILED" />
            </el-select>
          </el-form-item>
          <el-form-item><el-button type="primary" size="small" @click="loadTasks">搜索</el-button></el-form-item>
        </el-form>

        <el-table v-loading="taskLoading" :data="tasks" size="small" border>
          <el-table-column label="任务ID" prop="taskId" width="80" align="center" />
          <el-table-column label="业务类型" width="110">
            <template #default="{ row }">{{ bizText(row.bizType) }}</template>
          </el-table-column>
          <el-table-column label="业务单号" prop="bizNo" min-width="150" show-overflow-tooltip />
          <el-table-column label="回调路径" prop="callbackPath" min-width="260" show-overflow-tooltip />
          <el-table-column label="状态" width="100">
            <template #default="{ row }"><el-tag :type="statusTag(row.status)">{{ statusText(row.status) }}</el-tag></template>
          </el-table-column>
          <el-table-column label="重试次数" prop="retryCount" width="90" align="center" />
          <el-table-column label="下次重试" width="170"><template #default="{ row }">{{ row.nextRetryTime || '-' }}</template></el-table-column>
          <el-table-column label="错误信息" prop="lastError" min-width="200" show-overflow-tooltip />
          <el-table-column label="更新时间" prop="updateTime" width="170" />
          <el-table-column fixed="right" label="操作" width="90" align="center">
            <template #default="{ row }">
              <el-button link type="primary" size="small" @click="retry(row)" v-hasPermi="['mes:sal:erp:retry']">重推</el-button>
            </template>
          </el-table-column>
        </el-table>
        <pagination v-show="taskTotal > 0" :total="taskTotal" v-model:page="query.pageNum" v-model:limit="query.pageSize" @pagination="loadTasks" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getErpEndpoint, saveErpEndpoint, listSyncTask, retrySyncTask } from '@/api/mes/sal/erp'
import type { ErpEndpoint, ErpSyncTask } from '@/api/mes/sal/erp'

const activeTab = ref('config')
const configLoading = ref(false)
const endpoint = ref<ErpEndpoint>({ systemCode: 'ERP', enabled: '0' })

const taskLoading = ref(false)
const tasks = ref<ErpSyncTask[]>([])
const taskTotal = ref(0)
const query = ref({ pageNum: 1, pageSize: 10, bizNo: '', bizType: '', status: '' })

async function loadConfig() {
  configLoading.value = true
  try {
    const res = await getErpEndpoint()
    endpoint.value = res.data || { systemCode: 'ERP', enabled: '0' }
  } finally {
    configLoading.value = false
  }
}

async function saveConfig() {
  configLoading.value = true
  try {
    await saveErpEndpoint(endpoint.value)
    ElMessage.success('保存成功')
    await loadConfig()
  } finally {
    configLoading.value = false
  }
}

async function loadTasks() {
  taskLoading.value = true
  try {
    const res = await listSyncTask(query.value)
    tasks.value = res.rows
    taskTotal.value = res.total
  } finally {
    taskLoading.value = false
  }
}

async function retry(row: ErpSyncTask) {
  try {
    await ElMessageBox.confirm('确认重推该回写任务？', '重推', { type: 'warning' })
  } catch {
    return
  }
  await retrySyncTask(row.taskId as number)
  ElMessage.success('已触发重推')
  loadTasks()
}

function bizText(t?: string) {
  return ({ ORDER_ACCEPT: '接单回写', ORDER_REJECT: '打回回写', QUOTE_SUBMIT: '报价回写' } as Record<string, string>)[t || ''] || t || '-'
}
function statusText(s?: string) {
  return ({ PENDING: '待执行', RUNNING: '执行中', SUCCESS: '成功', FAILED: '失败' } as Record<string, string>)[s || ''] || s || '-'
}
function statusTag(s?: string) {
  return s === 'SUCCESS' ? 'success' : s === 'FAILED' ? 'danger' : 'warning'
}

onMounted(() => { loadConfig(); loadTasks() })
</script>
