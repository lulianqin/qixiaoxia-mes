<template>
  <el-dialog v-model="visible" title="销售订单接单" width="980px" append-to-body @close="handleClose">
    <el-form :model="form" label-width="100px" v-loading="loading">
      <el-row>
        <el-col :span="12"><el-form-item label="订单号">{{ order.orderCode || '-' }}</el-form-item></el-col>
        <el-col :span="12"><el-form-item label="ERP/SRM单号">{{ order.externalOrderNo || '-' }}</el-form-item></el-col>
      </el-row>
      <el-row>
        <el-col :span="12">
          <el-form-item label="客户名称">
            <el-input :model-value="order.clientName" readonly placeholder="ERP 客户名称" />
            <div class="hint">接单时自动匹配 MES 客户，不存在则按名称自动创建</div>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="业务员">
            <el-input v-model="form.salesperson" placeholder="填写业务员名称" clearable />
            <div class="hint">来自外部系统，仅保留名称，无需关联本地账号</div>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row>
        <el-col :span="12">
          <el-form-item label="供方主体" required>
            <el-select v-model="form.signCompany" filterable clearable placeholder="请选择供方主体" style="width:100%">
              <el-option v-for="d in companyOptions" :key="d.dictValue" :label="d.dictLabel" :value="d.dictValue" />
            </el-select>
            <div v-if="matchedCompanyText" class="hint">已按 ERP 采购单供方自动匹配：{{ matchedCompanyText }}</div>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="需方主体">
            <el-input :model-value="order.demanderName" readonly placeholder="ERP 采购单需方" />
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
        <el-table-column label="MES 产品" min-width="200">
          <template #default="{ row }">
            <span v-if="row.productId">{{ row._mesProductName || row.productName }}</span>
            <span v-else class="hint">按名称自动匹配/创建</span>
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
import { acceptOrder, getOrderDetail } from '@/api/mes/sal/order'
import { getDicts } from '@/api/system/dict/data'
import type { SalOrder, SalOrderLine } from '@/types'

const visible = ref(false)
const loading = ref(false)
const companyOptions = ref<any[]>([])
const order = ref<SalOrder>({})
const form = ref<{ requestDate?: string; salesperson?: string; signCompany?: string; lines: any[] }>({ lines: [] })
const emit = defineEmits(['success'])

getDicts('sys_company').then((r: any) => { companyOptions.value = r.data || [] })

const matchedCompanyText = computed(() => {
  const d = companyOptions.value.find((o: any) => o.dictValue === order.value.signCompany)
  return d ? d.dictLabel : ''
})

async function open(row: SalOrder) {
  visible.value = true
  loading.value = true
  form.value = { requestDate: row.requestDate, salesperson: row.salesperson, signCompany: row.signCompany, lines: [] }
  try {
    const res = await getOrderDetail(row.orderId as number)
    order.value = res.data || row
    form.value.requestDate = order.value.requestDate
    form.value.salesperson = order.value.salesperson
    form.value.signCompany = order.value.signCompany
    form.value.lines = (order.value.lines || []).map((l: SalOrderLine) => ({
      lineId: l.lineId,
      lineNo: l.lineNo,
      productName: l.productName,
      productId: l.productId,
      _mesProductName: l.mesProductName || (l.productId ? l.productName : ''),
      quantity: l.quantity,
      unitOfMeasure: l.unitOfMeasure,
      unitPrice: l.unitPrice,
      requestDate: l.requestDate
    }))
  } finally {
    loading.value = false
  }
}

async function submit() {
  if (!form.value.salesperson) {
    ElMessage.warning('请填写业务员')
    return
  }
  if (!form.value.signCompany) {
    ElMessage.warning('请选择供方主体（ERP 采购单供方未匹配到，请人工选择）')
    return
  }
  loading.value = true
  try {
    await acceptOrder(order.value.orderId as number, {
      requestDate: form.value.requestDate,
      salesperson: form.value.salesperson,
      signCompany: form.value.signCompany,
      lines: form.value.lines.map((l: any) => ({ lineId: l.lineId, requestDate: l.requestDate, productId: l.productId }))
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
}

defineExpose({ open })
</script>

<style scoped>
.hint { font-size: 12px; color: #909399; line-height: 18px; }
</style>
