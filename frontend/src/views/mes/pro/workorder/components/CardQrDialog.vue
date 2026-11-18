<template>
  <el-dialog v-model="visible" title="流转卡二维码" width="340px" append-to-body>
    <div v-loading="loading" style="text-align:center;min-height:140px">
      <template v-if="card">
        <QrCode :payload="buildCardPayload(card.cardCode)" :size="240" />
        <div style="margin-top:12px;font-size:18px;font-weight:bold">{{ card.cardCode }}</div>
        <div style="color:#999;margin-top:4px">{{ card.itemName }}</div>
        <div style="color:#999;margin-top:4px">当前工序：{{ card.currentProcessName || '-' }}</div>
      </template>
      <el-empty v-else-if="!loading" description="该工单暂无流转卡" :image-size="80" />
    </div>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import QrCode from '@/components/QrCode/index.vue'
import { buildCardPayload } from '@/utils/qrPayload'
import { listProcard } from '@/api/mes/pro/procard'

const props = defineProps<{ modelValue: boolean; workorderId?: number }>()
const emit = defineEmits(['update:modelValue'])

const visible = ref(false)
const loading = ref(false)
const card = ref<any>(null)

watch(() => props.modelValue, (v: boolean) => {
  visible.value = v
  if (v) load()
})
watch(visible, (v: boolean) => emit('update:modelValue', v))

function load() {
  card.value = null
  if (!props.workorderId) return
  loading.value = true
  listProcard({ workorderId: props.workorderId, pageNum: 1, pageSize: 100 }).then((r: any) => {
    const rows = r.rows || []
    card.value = rows.find((c: any) => c.status === 'ACTIVE') || rows[0] || null
  }).catch(() => {}).finally(() => { loading.value = false })
}
</script>
