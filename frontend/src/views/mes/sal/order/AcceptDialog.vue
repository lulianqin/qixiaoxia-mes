<template>
  <el-dialog v-model="visible" title="销售订单接单" width="980px" append-to-body @close="handleClose">
    <el-form :model="form" label-width="100px" v-loading="loading">
      <el-row>
        <el-col :span="12"><el-form-item label="订单号">{{ order.orderCode || '-' }}</el-form-item></el-col>
        <el-col :span="12"><el-form-item label="ERP/SRM单号">{{ order.externalOrderNo || '-' }}</el-form-item></el-col>
        <el-col :span="12">
          <el-form-item label="MES 客户" :required="isExternal">
            <el-select v-model="form.clientId" filterable remote clearable placeholder="按名称搜索客户"
                       :remote-method="searchClients" :loading="clientLoading" style="width:100%">
              <el-option v-for="c in clientOptions" :key="c.clientId" :label="c.clientName" :value="c.clientId" />
            </el-select>
            <div v-if="order.clientName" class="hint">外部客户：{{ order.clientName }}</div>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="业务员" :required="!order.salesperson">
            <el-select v-model="form.salesperson" filterable remote clearable placeholder="选择 MES 员工账号"
                       :remote-method="searchSalespersons" :loading="salespersonLoading" style="width:100%">
              <el-option v-for="u in salespersonOptions" :key="u.userName"
                         :label="`${u.nickName || u.userName}(${u.userName})`" :value="u.userName" />
            </el-select>
            <div v-if="order.salesperson" class="hint">ERP 采购单下单人：{{ order.salesperson }}</div>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="12">
          <el-form-item label="需求交期">
            <el-date-picker v-model="form.requestDate" type="date" value-format="YYYY-MM-DD"
              placeholder="选择交期" style="width: 100%" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-table :data="form.lines" size="small" border max-height="360">
        <el-table-column label="行号" prop="lineNo" width="55" align="center" />
        <el-table-column label="外部产品" prop="productName" show-overflow-tooltip min-width="160" />
        <el-table-column label="MES 产品" min-width="230">
          <template #default="{ row }">
            <el-select v-model="row.productId" filterable remote clearable placeholder="按编码/名称搜索"
                       :remote-method="kw => searchItems(row, kw)" :loading="row._loading"
                       style="width:100%">
              <el-option v-for="it in row._options || []" :key="it.itemId"
                         :label="`${it.itemCode} ${it.itemName}`" :value="it.itemId" />
            </el-select>
          </template>
        </el-table-column>
        <el-table-column label="数量" prop="quantity" width="85" align="right" />
        <el-table-column label="单位" prop="unitOfMeasure" width="70" align="center" />
        <el-table-column label="交期" width="160">
          <template #default="{ row }">
            <el-date-picker v-model="row.requestDate" type="date" value-format="YYYY-MM-DD"
              size="small" style="width: 100%" />
          </template>
        </el-table-column>
      </el-table>
      <el-alert v-if="unmatchedCount > 0" type="warning" :closable="false" style="margin-top: 10px"
        :title="`还有 ${unmatchedCount} 行产品未关联 MES 物料，关联后会记录两系统映射，下次接单自动带出`" />
    </el-form>
    <template #footer>
      <el-button @click="visible = false">取 消</el-button>
      <el-button type="primary" :loading="loading" @click="submit">确认接单</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { acceptOrder, getOrderDetail, getAcceptDefaults } from '@/api/mes/sal/order'
import { listClient } from '@/api/mes/md/client'
import { listItem } from '@/api/mes/md/item'
import { listUser } from '@/api/system/user'
import type { SalOrder, SalOrderLine } from '@/types'

const visible = ref(false)
const loading = ref(false)
const clientLoading = ref(false)
const salespersonLoading = ref(false)
const salespersonOptions = ref<any[]>([])
const order = ref<SalOrder>({})
const clientOptions = ref<any[]>([])
const form = ref<{ requestDate?: string; clientId?: number; salesperson?: string; lines: any[] }>({ lines: [] })
const emit = defineEmits(['success'])

const isExternal = computed(() => ['ERP', 'SRM'].includes(order.value.sourceSystem || ''))
const unmatchedCount = computed(() => form.value.lines.filter(l => !l.productId).length)

async function open(row: SalOrder) {
  visible.value = true
  loading.value = true
  form.value = { requestDate: row.requestDate, clientId: row.clientId, salesperson: row.salesperson, lines: [] }
  try {
    const res = await getOrderDetail(row.orderId as number)
    order.value = res.data || row
    form.value.requestDate = order.value.requestDate
    form.value.clientId = order.value.clientId
    form.value.salesperson = order.value.salesperson
    loadSalespersons(order.value.salesperson)
    form.value.lines = (order.value.lines || []).map((l: SalOrderLine) => ({
      lineId: l.lineId,
      lineNo: l.lineNo,
      productName: l.productName,
      productId: l.productId,
      quantity: l.quantity,
      unitOfMeasure: l.unitOfMeasure,
      unitPrice: l.unitPrice,
      requestDate: l.requestDate,
      _options: l.productId ? [{ itemId: l.productId, itemCode: l.productCode, itemName: l.productName }] : []
    }))
    // 优先按已记录的两系统映射带出，未关联的再按名称给一次建议
    await applyMappingDefaults()
    if (!form.value.clientId && order.value.clientName) await suggestClient(order.value.clientName)
    for (const line of form.value.lines) {
      if (!line.productId && line.productName) await suggestItem(line)
    }
  } finally {
    loading.value = false
  }
}

async function applyMappingDefaults() {
  try {
    const res: any = await getAcceptDefaults(order.value.orderId as number)
    const d = res.data || {}
    if (!form.value.clientId && d.clientId) {
      form.value.clientId = d.clientId
      clientOptions.value = [{ clientId: d.clientId, clientName: d.clientName || String(d.clientId) }]
    }
    for (const row of d.lines || []) {
      const line = form.value.lines.find((l: any) => l.lineId === row.lineId)
      if (line && !line.productId && row.productId) {
        line.productId = row.productId
        line._options = [{ itemId: row.productId, itemCode: row.productCode, itemName: row.productName }]
      }
    }
  } catch (e) { /* 映射缺失不影响手动选择 */ }
}

async function suggestClient(name: string) {
  try {
    const res: any = await listClient({ pageNum: 1, pageSize: 20, clientName: name } as any)
    clientOptions.value = res.rows || []
    const exact = clientOptions.value.find(c => c.clientName === name)
    if (exact) form.value.clientId = exact.clientId
  } catch (e) { /* ignore */ }
}

async function suggestItem(line: any) {
  try {
    const res: any = await listItem({ pageNum: 1, pageSize: 20, itemName: line.productName } as any)
    line._options = res.rows || []
    const exact = line._options.find((i: any) => i.itemName === line.productName)
    if (exact) line.productId = exact.itemId
  } catch (e) { /* ignore */ }
}

function searchClients(keyword: string) {
  clientLoading.value = true
  listClient({ pageNum: 1, pageSize: 30, clientName: keyword || undefined } as any)
    .then((res: any) => { clientOptions.value = res.rows || [] })
    .finally(() => { clientLoading.value = false })
}

/** 业务员：优先把 ERP 下单人名称匹配成 MES 员工账号 */
function loadSalespersons(name?: string) {
  salespersonLoading.value = true
  listUser({ pageNum: 1, pageSize: 50, status: '0' } as any)
    .then((res: any) => {
      const rows = res.rows || []
      const match = rows.find((u: any) => u.nickName === name || u.userName === name)
      if (match) form.value.salesperson = match.userName
      if (name && !match) rows.unshift({ userName: name, nickName: name })
      salespersonOptions.value = rows
    })
    .finally(() => { salespersonLoading.value = false })
}

function searchSalespersons(keyword: string) {
  salespersonLoading.value = true
  listUser({ pageNum: 1, pageSize: 20, status: '0', userName: keyword || undefined } as any)
    .then((res: any) => { salespersonOptions.value = res.rows || [] })
    .finally(() => { salespersonLoading.value = false })
}

function searchItems(line: any, keyword: string) {
  line._loading = true
  listItem({ pageNum: 1, pageSize: 30, itemName: keyword || undefined } as any)
    .then((res: any) => { line._options = res.rows || [] })
    .finally(() => { line._loading = false })
}

async function submit() {
  if (!form.value.salesperson) {
    ElMessage.warning('请选择业务员（MES 员工账号）')
    return
  }
  loading.value = true
  try {
    await acceptOrder(order.value.orderId as number, {
      requestDate: form.value.requestDate,
      clientId: form.value.clientId,
      salesperson: form.value.salesperson,
      lines: form.value.lines.map((l) => ({ lineId: l.lineId, requestDate: l.requestDate, productId: l.productId }))
    })
    visible.value = false
    emit('success')
  } finally {
    loading.value = false
  }
}

function handleClose() {
  order.value = {}
  form.value = { lines: [] }
  clientOptions.value = []
  salespersonOptions.value = []
}

defineExpose({ open })
</script>

<style scoped>
.hint { font-size: 12px; color: #909399; line-height: 18px; }
</style>
