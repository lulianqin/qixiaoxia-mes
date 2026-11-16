<template>
  <el-dialog v-model="visible" title="打回销售订单" width="520px" append-to-body>
    <el-form label-width="90px">
      <el-form-item label="订单号">{{ order.orderCode || '-' }}</el-form-item>
      <el-form-item label="ERP单号">{{ order.externalOrderNo || '-' }}</el-form-item>
      <el-form-item label="打回原因" required>
        <el-input v-model="reason" type="textarea" :rows="4" maxlength="500" show-word-limit
          placeholder="请填写打回原因，ERP 销售修改后可重新下发" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="visible = false">取 消</el-button>
      <el-button type="danger" :loading="loading" @click="submit">确认打回</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { rejectOrder } from '@/api/mes/sal/order'
import type { SalOrder } from '@/types'

const visible = ref(false)
const loading = ref(false)
const order = ref<SalOrder>({})
const reason = ref('')
const emit = defineEmits(['success'])

function open(row: SalOrder) {
  order.value = row
  reason.value = ''
  visible.value = true
}

async function submit() {
  if (!reason.value.trim()) {
    ElMessage.warning('请填写打回原因')
    return
  }
  loading.value = true
  try {
    await rejectOrder(order.value.orderId as number, reason.value.trim())
    visible.value = false
    emit('success')
  } finally {
    loading.value = false
  }
}

defineExpose({ open })
</script>
