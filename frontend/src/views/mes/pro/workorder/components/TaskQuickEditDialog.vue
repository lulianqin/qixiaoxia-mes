<template>
  <el-dialog v-model="visible" title="编辑工序任务" width="720px" append-to-body :close-on-click-modal="false">
    <el-form label-width="110px" size="small">
      <el-row>
        <el-col :span="12">
          <el-form-item label="工序">
            <el-input :model-value="form.processName" readonly />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="任务编码">
            <el-input :model-value="form.taskCode" readonly />
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="12">
          <el-form-item label="任务负责人">
            <el-select v-model="form.leaderId" filterable remote clearable placeholder="搜索用户"
              :remote-method="searchLeaders" :loading="leaderLoading" style="width:100%"
              @change="id => onUserChange(id, 'leader')">
              <el-option v-for="u in leaderOptions" :key="u.userId" :label="u.nickName || u.userName" :value="u.userId" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="派工报工人">
            <el-select v-model="form.workerId" filterable remote clearable placeholder="不派则默认当前登录人"
              :remote-method="searchWorkers" :loading="workerLoading" style="width:100%"
              @change="id => onUserChange(id, 'worker')">
              <el-option v-for="u in workerOptions" :key="u.userId" :label="u.nickName || u.userName" :value="u.userId" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="12">
          <el-form-item label="排产数量">
            <el-input-number v-model="form.quantity" :min="0" :precision="4" controls-position="right" style="width:100%" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="机台号">
            <el-input v-model="form.machineCode" maxlength="64" placeholder="请输入机台号" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-row v-if="isOutsource">
        <el-col :span="12">
          <el-form-item label="外协供应商">
            <el-select v-model="form.vendorId" filterable clearable placeholder="请选择外协供应商"
              style="width:100%" @change="onVendorChange">
              <el-option v-for="v in vendorOptions" :key="v.vendorId" :label="v.vendorName" :value="v.vendorId" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="12">
          <el-form-item label="计划开始">
            <el-date-picker v-model="form.startTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss"
              placeholder="选择计划开始时间" style="width:100%" @change="calcEndTime" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="计划时长(分钟)">
            <el-input-number v-model="form.duration" :min="0" :precision="0" controls-position="right"
              style="width:100%" @change="calcEndTime" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="24">
          <el-form-item label="备注">
            <el-input v-model="form.remark" type="textarea" :rows="2" maxlength="500" placeholder="备注" />
          </el-form-item>
        </el-col>
      </el-row>
    </el-form>
    <template #footer>
      <el-button @click="visible = false">取 消</el-button>
      <el-button type="primary" :loading="saving" @click="save">保 存</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch } from 'vue'
import { getTask, updateTask } from '@/api/mes/pro/task'
import { listUser } from '@/api/system/user'
import { listAllVendor } from '@/api/mes/md/vendor'

const props = defineProps<{ modelValue: boolean }>()
const emit = defineEmits(['update:modelValue', 'success'])

const visible = ref(false)
const saving = ref(false)
const form = reactive<any>({})
const workerOptions = ref<any[]>([])
const leaderOptions = ref<any[]>([])
const workerLoading = ref(false)
const leaderLoading = ref(false)
const vendorOptions = ref<any[]>([])
let workerTimer: any = null
let leaderTimer: any = null

const isOutsource = computed(() => form.isOutsource === '1' || form.workstationCode === 'VENDOR')

watch(() => props.modelValue, (v: boolean) => { visible.value = v })
watch(visible, (v: boolean) => { emit('update:modelValue', v) })

function open(taskId: number) {
  visible.value = true
  if (!taskId) return
  getTask(taskId).then((r: any) => {
    Object.assign(form, r.data || {})
    workerOptions.value = echoUserOption(form, 'workerId', 'workerName', 'workerNick')
    leaderOptions.value = echoUserOption(form, 'leaderId', 'leaderName', 'leaderNick')
    if (isOutsource.value) loadVendors()
  }).catch(() => {})
}

function echoUserOption(row: any, idKey: string, nameKey: string, nickKey: string) {
  const id = row?.[idKey]
  if (!id) return []
  return [{ userId: id, userName: row?.[nameKey] || '', nickName: row?.[nickKey] || String(id) }]
}

function searchWorkers(kw: string) {
  clearTimeout(workerTimer)
  workerTimer = setTimeout(() => searchUsers(kw, workerOptions, workerLoading), 300)
}

function searchLeaders(kw: string) {
  clearTimeout(leaderTimer)
  leaderTimer = setTimeout(() => searchUsers(kw, leaderOptions, leaderLoading), 300)
}

async function searchUsers(kw: string, target: any, loading: any) {
  loading.value = true
  try {
    const res: any = await listUser({ userName: kw || undefined, status: '0', pageNum: 1, pageSize: 20 })
    target.value = res.rows || []
  } finally { loading.value = false }
}

function onUserChange(id: number, type: 'leader' | 'worker') {
  const opts = type === 'leader' ? leaderOptions.value : workerOptions.value
  const u = opts.find((x: any) => x.userId === id)
  if (type === 'leader') {
    form.leaderName = u?.userName || null
    form.leaderNick = u?.nickName || null
  } else {
    form.workerName = u?.userName || null
    form.workerNick = u?.nickName || null
  }
}

async function loadVendors() {
  if (vendorOptions.value.length) return
  try {
    const res: any = await listAllVendor()
    vendorOptions.value = (res.data || []).filter((v: any) => v.vendorType === 'OUTSOURCE' || v.vendorType === 'BOTH')
  } catch (e) { vendorOptions.value = [] }
}

function onVendorChange(id: number) {
  const v = vendorOptions.value.find((x: any) => x.vendorId === id)
  form.vendorCode = v?.vendorCode || null
  form.vendorName = v?.vendorName || null
}

function calcEndTime() {
  if (!form.startTime || form.duration == null) return
  const start = new Date(String(form.startTime).replace(/-/g, '/'))
  if (isNaN(start.getTime())) return
  const end = new Date(start.getTime() + Number(form.duration) * 60000)
  form.endTime = formatDate(end)
}

function formatDate(d: Date) {
  const p = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`
}

function save() {
  if (!form.taskId) return
  saving.value = true
  updateTask(form).then(() => {
    emit('success')
    visible.value = false
  }).catch(() => {}).finally(() => { saving.value = false })
}

defineExpose({ open })
</script>
