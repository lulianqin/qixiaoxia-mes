<template>
  <el-dialog v-model="visible" :title="readonly ? '报价单详情' : '报价录入'" width="1100px" append-to-body>
    <div v-loading="loading">
      <el-alert v-if="detail.status === 'RETURNED'" type="warning" :closable="false" style="margin-bottom: 12px"
        :title="'ERP已退回：' + (detail.returnReason || '请重新报价')" />
      <el-descriptions :column="3" border size="small">
        <el-descriptions-item label="MES报价单号">{{ detail.quoteCode || '-' }}</el-descriptions-item>
        <el-descriptions-item label="ERP报价单号">{{ detail.externalQuoteNo || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ statusText }}</el-descriptions-item>
        <el-descriptions-item label="标题">{{ detail.title || '-' }}</el-descriptions-item>
        <el-descriptions-item label="客户">{{ detail.clientName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="询价日期">{{ parseTime(detail.inquiryDate || detail.createTime, '{y}-{m}-{d}') || '-' }}</el-descriptions-item>
        <el-descriptions-item label="报价人">{{ detail.quoteUser || '-' }}</el-descriptions-item>
        <el-descriptions-item label="报价时间">{{ parseTime(detail.quoteTime, '{y}-{m}-{d} {h}:{i}:{s}') || '-' }}</el-descriptions-item>
        <el-descriptions-item label="报价总额">{{ detail.totalAmount ?? '-' }}</el-descriptions-item>
      </el-descriptions>

      <el-form-item label="整单备注" label-width="90px" style="margin-top: 14px">
        <el-input v-model="form.remark" type="textarea" :rows="2" maxlength="1000" :disabled="readonly" placeholder="报价说明（可选）" />
      </el-form-item>

      <el-table :data="form.lines" size="small" border max-height="430">
        <el-table-column label="行号" prop="lineNo" width="55" align="center" />
        <el-table-column label="产品名称" prop="productName" min-width="140" show-overflow-tooltip />
        <el-table-column label="产品图片" align="center" width="70">
          <template #default="{ row }">
            <el-image
              v-if="row.productPhoto"
              :src="row.productPhoto"
              :preview-src-list="[row.productPhoto]"
              fit="cover"
              style="width:40px;height:40px"
            />
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="尺寸" prop="productSize" width="110" show-overflow-tooltip />
        <el-table-column label="材质/工艺" min-width="130" show-overflow-tooltip>
          <template #default="{ row }">{{ [row.material, row.printingMode].filter(Boolean).join(' / ') || '-' }}</template>
        </el-table-column>
        <el-table-column label="数量" prop="quantity" width="90" align="right" />
        <el-table-column label="单位" prop="unit" width="60" align="center" />
        <el-table-column label="客户备注" prop="remark" min-width="110" show-overflow-tooltip />
        <el-table-column label="报价单价" width="130">
          <template #default="{ row }">
            <el-input-number v-if="!readonly" v-model="row.price" :min="0" :precision="4" :controls="false" size="small" style="width: 100%" />
            <span v-else>{{ row.price ?? '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="报价备注" width="170">
          <template #default="{ row }">
            <el-input v-if="!readonly" v-model="row.quoteRemark" size="small" maxlength="500" />
            <span v-else>{{ row.quoteRemark || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="交期说明" width="130">
          <template #default="{ row }">
            <el-input v-if="!readonly" v-model="row.deliveryDate" size="small" placeholder="如 7天" maxlength="100" />
            <span v-else>{{ row.deliveryDate || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="报价有效期" width="160">
          <template #default="{ row }">
            <el-date-picker v-if="!readonly" v-model="row.quoteValidDate" type="date" value-format="YYYY-MM-DD" size="small" style="width: 100%" />
            <span v-else>{{ parseTime(row.quoteValidDate, '{y}-{m}-{d}') || '-' }}</span>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <template #footer>
      <el-button @click="visible = false">关 闭</el-button>
      <template v-if="!readonly">
        <el-button :loading="loading" @click="save">保存草稿</el-button>
        <el-button type="primary" :loading="loading" @click="submit">提交报价</el-button>
      </template>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getQuote, saveQuote, submitQuote } from '@/api/mes/sal/quote'
import type { SalQuote, SalQuoteLine } from '@/types'

const visible = ref(false)
const loading = ref(false)
const readonly = ref(true)
const detail = ref<SalQuote>({})
const form = ref<{ remark?: string; lines: SalQuoteLine[] }>({ lines: [] })
const emit = defineEmits(['success'])

const statusText = computed(() => ({
  PENDING_QUOTE: '待报价',
  QUOTED: '已报价',
  RETURNED: '已退回',
  CANCEL: '已取消'
} as Record<string, string>)[detail.value.status || ''] || detail.value.status || '-')

function parseTime(value?: string, pattern = '{y}-{m}-{d}') {
  if (!value) return ''
  const d = new Date(value)
  const map: Record<string, string> = {
    '{y}': String(d.getFullYear()),
    '{m}': String(d.getMonth() + 1).padStart(2, '0'),
    '{d}': String(d.getDate()).padStart(2, '0'),
    '{h}': String(d.getHours()).padStart(2, '0'),
    '{i}': String(d.getMinutes()).padStart(2, '0'),
    '{s}': String(d.getSeconds()).padStart(2, '0')
  }
  return Object.keys(map).reduce((acc, key) => acc.replace(key, map[key]), pattern)
}

async function open(quoteId: number, ro: boolean) {
  visible.value = true
  readonly.value = ro
  loading.value = true
  try {
    const res = await getQuote(quoteId)
    detail.value = res.data || {}
    form.value = {
      remark: detail.value.remark,
      lines: (detail.value.lines || []).map((l: SalQuoteLine) => ({ ...l }))
    }
  } finally {
    loading.value = false
  }
}

function buildPayload() {
  return {
    quoteId: detail.value.quoteId,
    remark: form.value.remark,
    lines: form.value.lines.map((l: SalQuoteLine) => ({
      lineId: l.lineId,
      price: l.price,
      quoteRemark: l.quoteRemark,
      deliveryDate: l.deliveryDate,
      quoteValidDate: l.quoteValidDate
    }))
  }
}

async function save() {
  loading.value = true
  try {
    await saveQuote(buildPayload())
    ElMessage.success('保存成功')
    emit('success')
  } finally {
    loading.value = false
  }
}

async function submit() {
  const missing = form.value.lines.filter((l: SalQuoteLine) => !l.price || Number(l.price) <= 0)
  if (missing.length > 0) {
    ElMessage.warning('请先填写第 ' + missing.map((l: SalQuoteLine) => l.lineNo).join('、') + ' 行的报价单价')
    return
  }
  try {
    await ElMessageBox.confirm('提交后将回传 ERP 并锁定本次报价，确认提交？', '提交报价', { type: 'warning' })
  } catch {
    return
  }
  loading.value = true
  try {
    await submitQuote(buildPayload())
    ElMessage.success('报价已提交并回写 ERP')
    visible.value = false
    emit('success')
  } finally {
    loading.value = false
  }
}

defineExpose({ open })
</script>
