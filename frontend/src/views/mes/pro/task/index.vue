<template>
  <div class="app-container">
    <!-- 搜索表单 -->
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="任务编码" prop="taskCode">
        <el-input v-model="queryParams.taskCode" placeholder="请输入" clearable style="width:180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="工单名称" prop="workorderName">
        <el-input v-model="queryParams.workorderName" placeholder="请输入" clearable style="width:180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="工位" prop="workstationId">
        <el-input v-model="queryParams.workstationName" placeholder="请输入工位名称" clearable style="width:180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="工序名称" prop="processName">
        <el-input v-model="queryParams.processName" placeholder="请输入" clearable style="width:180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择" clearable style="width:150px">
          <el-option label="待排产" value="PREPARE" />
          <el-option label="正常" value="NORMAL" />
          <el-option label="生产中" value="PRODUCING" />
          <el-option label="已完成" value="COMPLETED" />
          <el-option label="暂停" value="PAUSED" />
          <el-option label="取消" value="CANCEL" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 工具栏 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['mes:pro:task:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="Edit" :disabled="single" @click="handleUpdate()" v-hasPermi="['mes:pro:task:edit']">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete()" v-hasPermi="['mes:pro:task:remove']">删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="Download" @click="handleExport" v-hasPermi="['mes:pro:task:export']">导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <!-- 表格 -->
    <el-table v-loading="loading" :data="taskList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="任务编码" align="center" prop="taskCode" width="170" :show-overflow-tooltip="true">
        <template #default="scope">
          <el-tag v-if="scope.row.isException === 'Y'" type="danger" size="small" effect="dark" class="mr4">异常</el-tag>
          <span>{{ scope.row.taskCode }}</span>
        </template>
      </el-table-column>
      <el-table-column label="关联异常单" align="center" prop="exceptionCode" width="140">
        <template #default="scope">
          <el-button v-if="scope.row.exceptionCode && checkPermi(['mes:pro:exception:query'])" link type="danger" @click.stop="goException(scope.row)">{{ scope.row.exceptionCode }}</el-button>
          <span v-else-if="scope.row.exceptionCode" style="color:#f56c6c">{{ scope.row.exceptionCode }}</span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="任务名称" align="center" prop="taskName" width="150" :show-overflow-tooltip="true" />
      <el-table-column label="生产工单" align="center" prop="workorderName" width="150" :show-overflow-tooltip="true" />
      <el-table-column label="工位" align="center" prop="workstationName" width="120" :show-overflow-tooltip="true" />
      <el-table-column label="报工人" align="center" prop="workerNick" width="100" :show-overflow-tooltip="true">
        <template #default="scope">{{ scope.row.workerNick || '-' }}</template>
      </el-table-column>
      <el-table-column label="负责人" align="center" prop="leaderNick" width="100" :show-overflow-tooltip="true">
        <template #default="scope">{{ scope.row.leaderNick || '-' }}</template>
      </el-table-column>
      <el-table-column label="工序" align="center" prop="processName" width="120" :show-overflow-tooltip="true" />
      <el-table-column label="计划数量" align="center" prop="quantity" width="90" />
      <el-table-column label="已生产" align="center" prop="quantityProduced" width="80">
        <template #default="scope">{{ producedDisplay(scope.row) }}</template>
      </el-table-column>
      <el-table-column label="颜色" align="center" prop="colorCode" width="80">
        <template #default="scope">
          <el-color-picker v-model="scope.row.colorCode" disabled size="small" v-if="scope.row.colorCode" />
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="开始时间" align="center" prop="startTime" width="155">
        <template #default="scope">
          <span>{{ parseTime(scope.row.startTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="结束时间" align="center" prop="endTime" width="155">
        <template #default="scope">
          <span>{{ parseTime(scope.row.endTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="总时长(h)" align="center" prop="duration" width="90" />
      <el-table-column label="状态" align="center" prop="status" width="110">
        <template #default="scope">
          <el-tag v-if="isQcBlocked(scope.row)" type="danger" size="small" effect="dark">不可开工</el-tag>
          <span v-else :style="{ color: statusColor[scope.row.status] }">{{ statusMap[scope.row.status] || scope.row.status }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="380">
        <template #default="scope">
          <el-button link type="danger" icon="Unlock" @click="handleReleaseQcBlock(scope.row)" v-if="isQcBlocked(scope.row)" v-hasPermi="['mes:pro:task:release']">质检放行</el-button>
          <el-button link type="success" icon="Position" @click="handleDispatch(scope.row)" v-if="scope.row.status==='NORMAL'||scope.row.status==='PREPARE'" v-hasPermi="['mes:pro:task:edit']">下发</el-button>
          <el-button link type="primary" icon="CircleCheck" @click="handleComplete(scope.row)" v-if="scope.row.status==='PRODUCING' && !isQcBlocked(scope.row)" v-hasPermi="['mes:pro:task:edit']">完成</el-button>
          <el-button link type="warning" icon="CircleClose" @click="handleCancelTask(scope.row)" v-if="scope.row.status!=='COMPLETED'&&scope.row.status!=='CANCEL'" v-hasPermi="['mes:pro:task:edit']">取消</el-button>
          <el-button link type="danger" icon="Warning" @click="handleReportException(scope.row)" v-if="scope.row.status!=='COMPLETED'&&scope.row.status!=='CANCEL'" v-hasPermi="['mes:pro:exception:add']">报异常</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['mes:pro:task:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['mes:pro:task:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 对话框 -->
    <el-dialog :title="title" v-model="open" width="820px" append-to-body @close="cancel">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-row>
          <el-col :span="16">
            <el-form-item label="任务编码" prop="taskCode">
              <el-input v-model="form.taskCode" placeholder="请输入" :disabled="optType !== 'add'" maxlength="64" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label-width="80" v-if="optType === 'add'">
              <el-switch v-model="autoGenFlag" @change="handleAutoGenChange" size="small" />
              <span style="margin-left: 6px; font-size: 12px; color: #909399">自动生成</span>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="任务名称" prop="taskName">
              <el-input v-model="form.taskName" placeholder="选择工单和数量后自动生成：[产品名]【数量】单位" :disabled="optType === 'view'" maxlength="255" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="生产工单" prop="workorderName">
              <el-input v-model="form.workorderName" placeholder="请选择生产工单" readonly :disabled="optType === 'view'">
                <template #append v-if="optType !== 'view'">
                  <el-button icon="Search" @click="handleWorkorderSelect" />
                </template>
              </el-input>
              <workorderSelect ref="woSelectRef" @onSelected="onWorkorderSelected" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <!-- 外协工序选供应商（任务级可改，默认带出路线配置），厂内工序选工位 -->
            <el-form-item :label="isOutsourceProcess ? '外协供应商' : '工位'" :prop="isOutsourceProcess ? 'vendorId' : 'workstationName'">
              <el-select v-if="isOutsourceProcess" v-model="form.vendorId" filterable clearable
                style="width: 100%" :loading="vendorLoading" @focus="loadVendorOptions"
                :disabled="optType === 'view'" placeholder="请选择外协供应商">
                <el-option v-for="v in vendorOptions" :key="v.vendorId"
                  :label="v.vendorName + ' (' + v.vendorCode + ')'" :value="v.vendorId" />
              </el-select>
              <el-input v-else v-model="form.workstationName" placeholder="请选择工作站" :disabled="optType === 'view'">
                <template #append v-if="optType !== 'view'">
                  <el-button icon="Search" @click="handleWorkstationSelect" />
                </template>
              </el-input>
            </el-form-item>
            <WorkstationSelect ref="wsSelectRef" :processId="form.processId" @onSelected="onWorkstationSelected" />
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="工序" prop="processId">
              <el-select v-model="form.processId" placeholder="请选择" style="width: 100%" :disabled="optType === 'view'" filterable @change="onProcessChange">
                <el-option v-for="p in processOptions" :key="p.processId" :label="p.processName" :value="p.processId" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="排产数量" prop="quantity">
              <el-input-number v-model="form.quantity" :min="1" :max="99999999" style="width: 100%" :disabled="optType === 'view'" placeholder="请输入排产数量" @change="updateTaskNameHint" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="报工人（派工）" prop="workerId">
              <el-select v-model="form.workerId" style="width: 100%" filterable remote clearable
                :remote-method="searchWorkers" :loading="workerLoading"
                placeholder="不派则报工时默认当前登录人" :disabled="optType === 'view'">
                <el-option v-for="u in workerOptions" :key="u.userId"
                  :label="`${u.nickName}（${u.userName}）`" :value="u.userId" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="负责人" prop="leaderId">
              <el-select v-model="form.leaderId" style="width: 100%" filterable remote clearable
                :remote-method="searchLeaders" :loading="leaderLoading"
                placeholder="下发必填：质检拦截等待办的处理责任人" :disabled="optType === 'view'">
                <el-option v-for="u in leaderOptions" :key="u.userId"
                  :label="`${u.nickName}（${u.userName}）`" :value="u.userId" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="8">
            <el-form-item label="甘特图颜色" prop="colorCode">
              <el-color-picker v-model="form.colorCode" :disabled="optType === 'view'" />
            </el-form-item>
          </el-col>
          <el-col :span="16">
            <el-input v-model="form.colorCode" maxlength="7" placeholder="请输入颜色编码，或点击左侧选择" :disabled="optType === 'view'" style="margin-top: 8px" />
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="8">
            <el-form-item label="开始时间" prop="startTime">
              <el-date-picker v-model="form.startTime" type="datetime" placeholder="选择日期" clearable style="width: 100%" value-format="YYYY-MM-DD HH:mm:ss" :disabled="optType === 'view'" @change="calculateEndTime" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="总时长(h)" prop="duration">
              <el-input-number v-model="form.duration" :min="0" :precision="2" :step="1" style="width: 100%" :disabled="optType === 'view'" placeholder="请输入" @change="calculateEndTime" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="结束时间" prop="endTime">
              <el-date-picker v-model="form.endTime" type="datetime" placeholder="自动计算" disabled style="width: 100%" value-format="YYYY-MM-DD HH:mm:ss" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="设备编码" prop="machineCode">
              <el-input v-model="form.machineCode" placeholder="请输入" :disabled="optType === 'view'" maxlength="64" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="form.remark" placeholder="请输入" :disabled="optType === 'view'" maxlength="500" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm" v-if="optType !== 'view'">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 跟单质检不合格放行 -->
    <QcReleaseDialog ref="qcReleaseRef" @success="getList" />
    <!-- E1：PC 工序任务报异常 -->
    <ExceptionCreateDialog ref="exceptionCreateRef" @success="goNewException" />
  </div>
</template>

<script setup lang="ts" name="ProSchedule">
import { ref, reactive, toRefs, computed, getCurrentInstance } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { listTask, getTask, delTask, addTask, updateTask, dispatchTask, completeTask, cancelTask, getQcBlockState } from '@/api/mes/pro/task'
import { listWorkorder, getWorkorder } from '@/api/mes/pro/workorder'
import { listAllProcess } from '@/api/mes/pro/process'
import { listRouteProcessByRouteId } from '@/api/mes/pro/routeprocess'
import { listAllVendor } from '@/api/mes/md/vendor'
import { listRouteProduct } from '@/api/mes/pro/routeproduct'
import { genSerialCode } from '@/api/mes/sys/autocoderule'
import { listUser } from '@/api/system/user'
import { checkPermi } from '@/utils/permission'
import { TASK_STATUS_LABEL as statusMap, TASK_STATUS_COLOR as statusColor } from '../taskStatus'
import WorkstationSelect from '@/components/workstationSelect/single.vue'
import workorderSelect from '@/components/workorderSelect/single.vue'
import QcReleaseDialog from './components/QcReleaseDialog.vue'
import ExceptionCreateDialog from '../exception/components/ExceptionCreateDialog.vue'

const { proxy } = getCurrentInstance() as any
const router = useRouter()
const route = useRoute()

const wsSelectRef = ref<InstanceType<typeof WorkstationSelect>>()
const woSelectRef = ref()
const formRef = ref()
const taskList = ref<any[]>([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref('')
const optType = ref('')
const autoGenFlag = ref(false)
const workorderOptions = ref<any[]>([])
const processOptions = ref<any[]>([])

// 外协供应商下拉（懒加载，仅外协/整单外发类型，与工艺路线工序编辑口径一致）
const vendorOptions = ref<any[]>([])
const vendorLoading = ref(false)
async function loadVendorOptions() {
  if (vendorOptions.value.length) return
  vendorLoading.value = true
  try {
    const res: any = await listAllVendor()
    vendorOptions.value = (res.data || []).filter((v: any) => v.vendorType === 'OUTSOURCE' || v.vendorType === 'BOTH')
  } finally { vendorLoading.value = false }
}
// 供应商回显兜底：列表里找不到已选 id（如已停用供应商）时补一条快照 option
function ensureVendorEcho() {
  if (!form.value.vendorId) return
  loadVendorOptions().then(() => {
    if (!vendorOptions.value.some((v: any) => v.vendorId === form.value.vendorId) && form.value.vendorCode) {
      vendorOptions.value.push({ vendorId: form.value.vendorId, vendorCode: form.value.vendorCode, vendorName: form.value.vendorName || form.value.vendorCode })
    }
  })
}
// 当前选中工序是否外协工序：路线工序 isOutsource='1'，或任务本身已是外协占位机台
const isOutsourceProcess = computed(() => {
  const rp = processOptions.value.find((p: any) => p.processId === form.value.processId)
  return rp?.isOutsource === '1' || form.value.workstationCode === 'VENDOR'
})

// 报工人（派工）/负责人：远程搜索系统用户；回显用任务行内快照构造，避免额外请求
const workerOptions = ref<any[]>([])
const leaderOptions = ref<any[]>([])
const workerLoading = ref(false)
const leaderLoading = ref(false)
let workerTimer: any = null
let leaderTimer: any = null

function searchWorkers(kw: string) {
  clearTimeout(workerTimer)
  workerTimer = setTimeout(() => doSearchUsers(kw, workerOptions, workerLoading), 300)
}
function searchLeaders(kw: string) {
  clearTimeout(leaderTimer)
  leaderTimer = setTimeout(() => doSearchUsers(kw, leaderOptions, leaderLoading), 300)
}
async function doSearchUsers(kw: string, opts: typeof workerOptions, loading: typeof workerLoading) {
  loading.value = true
  try {
    // 系统用户列表仅支持账号/手机号模糊（不支持姓名），两路并发查询后按 userId 去重合并
    const [byName, byPhone] = await Promise.all([
      listUser({ userName: kw || undefined, status: '0', pageNum: 1, pageSize: 20 } as any),
      listUser({ phonenumber: kw || undefined, status: '0', pageNum: 1, pageSize: 20 } as any)
    ])
    const rows: any[] = [...((byName as any)?.rows || []), ...((byPhone as any)?.rows || [])]
    const dedup = rows.filter((r, i) => rows.findIndex(x => x.userId === r.userId) === i)
    // 保留已选中但不在搜索结果里的回显项
    const keep = opts.value.filter((o: any) => !dedup.some((r: any) => r.userId === o.userId) && o.__echo)
    opts.value = [...keep, ...dedup.map((r: any) => ({ ...r, __echo: false }))]
  } finally {
    loading.value = false
  }
}
/** 用任务行内的人员快照构造回显 option（快照存在时无需请求用户接口） */
function echoUserOption(row: any, idKey: string, nameKey: string, nickKey: string) {
  const id = row?.[idKey]
  if (!id) return null
  return {
    userId: id,
    userName: row?.[nameKey] || '',
    nickName: row?.[nickKey] || String(id),
    __echo: true
  }
}

// 跟单质检锁态：list 接口不富化，列表加载后对本页 PRODUCING 任务批量查询
const QC_STATE_BATCH = 100  // 后端单次最多 100 个任务
const qcBlockMap = ref<Record<string, { blocked: boolean; reason: string | null }>>({})
const qcReleaseRef = ref<InstanceType<typeof QcReleaseDialog>>()
function isQcBlocked(row: any) {
  return !!qcBlockMap.value[String(row.taskId)]?.blocked
}
// 外协任务完工后已生产量按计划量展示：外协产出单位（吨/卷）与任务计划单位（个）不同，
// 收货自动推进时产量可能与计划量不同，历史数据也可能为 0
function producedDisplay(row: any) {
  const produced = Number(row.quantityProduced) || 0
  if (row.status === 'COMPLETED' && row.workstationCode === 'VENDOR' && produced === 0) {
    return Number(row.quantity) || 0
  }
  return produced
}
function loadQcBlockStates(rows: any[]) {
  const ids = rows.filter((r: any) => r.status === 'PRODUCING').map((r: any) => r.taskId)
  if (ids.length === 0) { qcBlockMap.value = {}; return }
  // 按 100 分批后合并，避免分页调大时超上限导致整页锁态静默丢失
  const batches: number[][] = []
  for (let i = 0; i < ids.length; i += QC_STATE_BATCH) batches.push(ids.slice(i, i + QC_STATE_BATCH))
  Promise.all(batches.map(b => getQcBlockState(b)))
    .then((results: any[]) => {
      qcBlockMap.value = Object.assign({}, ...results.map(r => r.data || {}))
    })
    .catch(() => { qcBlockMap.value = {} })
}
function handleReleaseQcBlock(row: any) {
  qcReleaseRef.value?.open(row, qcBlockMap.value[String(row.taskId)]?.reason || null)
}

const data = reactive({
  form: {} as any,
  queryParams: { pageNum: 1, pageSize: 10 } as any,
  rules: {
    taskCode: [{ required: true, message: '任务编码不能为空', trigger: 'blur' }],
    taskName: [{ required: true, message: '任务名称不能为空', trigger: 'blur' }],
    workorderId: [{ required: true, message: '请选择生产工单', trigger: 'change' }],
    workstationName: [{ required: true, message: '工作站不能为空', trigger: 'blur' }],
    processId: [{ required: true, message: '请选择工序', trigger: 'change' }],
    quantity: [{ required: true, message: '排产数量不能为空', trigger: 'blur' }],
    startTime: [{ required: true, message: '请选择开始生产时间', trigger: 'blur' }],
    duration: [{ required: true, message: '请输入生产总时长', trigger: 'blur' }]
  }
})
const { queryParams, form, rules } = toRefs(data)

// ===================== 列表加载 =====================

function goException(row: any) {
  router.push({ path: '/mes/pro/exception_detail', query: { exceptionId: row.exceptionId } })
}

// E1：PC 端工序任务直接报异常，提交后跳详情供主管定责
const exceptionCreateRef = ref<InstanceType<typeof ExceptionCreateDialog>>()
function handleReportException(row: any) {
  exceptionCreateRef.value?.open(row)
}
function goNewException(exceptionId: number) {
  router.push({ path: '/mes/pro/exception_detail', query: { exceptionId } })
}

function getList() {
  loading.value = true
  listTask(queryParams.value).then((r: any) => {
    taskList.value = r.rows || []
    total.value = r.total || 0
    loading.value = false
    loadQcBlockStates(taskList.value)
  }).catch(() => { loading.value = false })
}

function loadSelectOptions() {
  listWorkorder({ pageNum: 1, pageSize: 1000 }).then((r: any) => { workorderOptions.value = r.rows || [] })
  listAllProcess().then((r: any) => { processOptions.value = r.data || [] })
}

// ===================== 工单变更 → 级联加载工序 & 产品信息 =====================

function onWorkorderChange(workorderId: number, keepProcess = false) {
  if (!workorderId) return
  if (!keepProcess) form.value.processId = undefined as any
  getWorkorder(workorderId).then((r: any) => {
    const wo = r.data
    if (!wo) return
    form.value.itemId = wo.itemId
    form.value.itemName = wo.itemName
    form.value.itemCode = wo.itemCode
    form.value.unitOfMeasure = wo.unitOfMeasure || wo.unitName
    updateTaskNameHint()
    if (wo.routeProductId) {
      listRouteProduct({ pageSize: 100 }).then((rpRes: any) => {
        const rp = (rpRes.rows || []).find((p: any) => p.recordId === wo.routeProductId)
        if (rp?.routeId) {
          listRouteProcessByRouteId(rp.routeId).then((procRes: any) => {
            const procList = procRes.data || []
            if (procList.length > 0) {
              // 保留 isOutsource/默认供应商：外协工序任务需选供应商（路线供应商为默认，任务级可更换）
              processOptions.value = procList.map((p: any) => ({
                processId: p.processId, processName: p.processName || p.processCode, processCode: p.processCode,
                isOutsource: p.isOutsource, vendorId: p.vendorId, vendorCode: p.vendorCode, vendorName: p.vendorName
              }))
              // 编辑回显：外协任务补供应商下拉回显
              ensureVendorEcho()
            }
          })
        }
      })
    }
  })
}

// ===================== 任务名称自动生成 =====================

function updateTaskNameHint() {
  const qty = form.value.quantity as number
  const itemName = form.value.itemName
  const unit = form.value.unitOfMeasure || form.value.unitName || ''
  if (itemName && qty) form.value.taskName = `${itemName}【${qty}】${unit}`
}

// ===================== 结束时间自动计算 (endTime = startTime + duration * 8h) =====================

function calculateEndTime() {
  const st = form.value.startTime as string
  const dur = form.value.duration as number
  if (!st || dur == null || dur <= 0) { form.value.endTime = undefined as any; return }
  const startDate = new Date(st)
  const endMs = startDate.getTime() + dur * 8 * 3600 * 1000
  const endDate = new Date(endMs)
  const pad = (n: number) => n.toString().padStart(2, '0')
  form.value.endTime = `${endDate.getFullYear()}-${pad(endDate.getMonth() + 1)}-${pad(endDate.getDate())} ${pad(endDate.getHours())}:${pad(endDate.getMinutes())}:${pad(endDate.getSeconds())}`
}

// ===================== 工单选择 =====================
function handleWorkorderSelect() { woSelectRef.value?.open() }
function onWorkorderSelected(row: any) {
  if (!row) return
  form.value.workorderId = row.workorderId
  form.value.workorderName = row.workorderName
  form.value.itemId = row.productId
  form.value.itemName = row.productName
  form.value.itemCode = row.productCode
  form.value.unitOfMeasure = row.unitOfMeasure
  form.value.unitName = row.unitName
  onWorkorderChange(row.workorderId)
}

// ===================== 工序选择 =====================

function onProcessChange(_processId: number) {
  // 切换工序后重置工位/供应商：外协工序锁定外协占位并默认带出路线供应商，厂内工序清空供应商
  form.value.workstationId = null
  form.value.workstationCode = ''
  form.value.workstationName = ''
  form.value.vendorId = null
  const rp = processOptions.value.find((p: any) => p.processId === _processId)
  if (rp?.isOutsource === '1') {
    form.value.workstationId = 0
    form.value.workstationCode = 'VENDOR'
    form.value.workstationName = '外协'
    loadVendorOptions().then(() => {
      if (rp.vendorId && !form.value.vendorId) form.value.vendorId = rp.vendorId
    })
  }
}

// ===================== 工作站选择 =====================

function handleWorkstationSelect() { wsSelectRef.value?.open() }

function onWorkstationSelected(row: any) {
  if (row) {
    form.value.workstationId = row.workstationId
    form.value.workstationCode = row.workstationCode
    form.value.workstationName = row.workstationName
  }
}

// ===================== 任务编码自动生成 =====================

function handleAutoGenChange(val: boolean) {
  if (val) {
    genSerialCode('TASK_CODE').then((r: any) => { form.value.taskCode = r.data }).catch(() => { form.value.taskCode = 'TSK' + Date.now() })
  } else {
    form.value.taskCode = ''
  }
}

// ===================== CRUD =====================

function cancel() { open.value = false; reset() }

function reset() {
  form.value = {} as any
  autoGenFlag.value = false
  workerOptions.value = []
  leaderOptions.value = []
  if (formRef.value) proxy.resetForm('formRef')
}

function handleQuery() { queryParams.value.pageNum = 1; getList() }

function resetQuery() { proxy.resetForm('queryRef'); handleQuery() }

function handleSelectionChange(selection: any[]) {
  ids.value = selection.map((i: any) => i.taskId)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function handleAdd() {
  reset(); loadSelectOptions(); open.value = true; title.value = '新增排产任务'; optType.value = 'add'
}

function handleUpdate(row?: any) {
  reset(); loadSelectOptions()
  const id = row?.taskId || ids.value[0]
  if (!id) { proxy.$modal.msgWarning('请选择一条记录'); return }
  getTask(id).then((r: any) => {
    const task = r.data || {}
    form.value = task
    // 报工人/负责人回显：优先用行内快照构造 option，不额外发请求
    const wo = echoUserOption(task, 'workerId', 'workerName', 'workerNick')
    const lo = echoUserOption(task, 'leaderId', 'leaderName', 'leaderNick')
    workerOptions.value = wo ? [wo] : []
    leaderOptions.value = lo ? [lo] : []
    // 按工单加载路线工序（含外协标识/默认供应商），保留当前工序不重置
    if (task.workorderId) onWorkorderChange(task.workorderId, true)
    open.value = true; title.value = '修改排产任务'; optType.value = 'edit'
  })
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (!valid) return
    if (form.value.taskId != null) {
      updateTask(form.value).then(() => { proxy.$modal.msgSuccess('修改成功'); open.value = false; getList() })
    } else {
      addTask(form.value).then(() => { proxy.$modal.msgSuccess('新增成功'); open.value = false; getList() })
    }
  })
}

function handleDelete(row?: any) {
  const _ids = row?.taskId ? [row.taskId] : ids.value
  if (!_ids || _ids.length === 0) { proxy.$modal.msgWarning('请选择要删除的记录'); return }
  proxy.$modal.confirm('是否确认删除所选排产任务？').then(() => delTask(_ids.join(','))).then(() => {
    getList(); proxy.$modal.msgSuccess('删除成功')
  }).catch(() => {})
}

// ===================== 状态操作 =====================

function handleDispatch(row: any) {
  proxy.$modal.confirm(`确认下发任务"${row.taskName || row.taskCode}"到工作站生产？`).then(() => {
    dispatchTask(row.taskId).then(() => { proxy.$modal.msgSuccess('下发成功'); getList() })
  }).catch(() => {})
}

function handleComplete(row: any) {
  proxy.$modal.confirm(`确认完成任务"${row.taskName || row.taskCode}"？`).then(() => {
    completeTask(row.taskId).then(() => { proxy.$modal.msgSuccess('完成'); getList() })
  }).catch(() => {})
}

function handleCancelTask(row: any) {
  proxy.$modal.confirm(`确认取消任务"${row.taskName || row.taskCode}"？`).then(() => {
    cancelTask(row.taskId).then(() => { proxy.$modal.msgSuccess('已取消'); getList() })
  }).catch(() => {})
}

function handleExport() {
  proxy.download('/mes/pro/task/export', { ...queryParams.value }, `schedule_${Date.now()}.xlsx`)
}

// 异常详情「处理单据」跳回：按任务编号自动过滤定位
if (route.query.taskCode) {
  queryParams.value.taskCode = String(route.query.taskCode)
}
getList()
</script>

<style lang="scss" scoped>
.app-container { padding: 16px; }
.mb8 { margin-bottom: 8px; }
.mr4 { margin-right: 4px; }
</style>
