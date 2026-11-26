<template>
  <el-dialog :model-value="modelValue" title="按工序配置同步单据" width="780px" append-to-body
    @update:model-value="(v: boolean) => emit('update:modelValue', v)">
    <div v-if="plan" class="sync-body">
      <el-alert v-if="plan.stats.addLines || plan.stats.removeLines" type="warning" :closable="false" show-icon class="mb12"
        :title="`本次将新增 ${plan.stats.addLines} 行（新建 ${plan.stats.addDocs} 张单），删除 ${plan.stats.removeLines} 行（整单删除 ${plan.stats.removeDocs} 张）`" />

      <div v-if="plan.additions.length" class="sec">
        <div class="sec-title"><el-tag type="success" size="small">将新增</el-tag></div>
        <div v-for="(g, i) in plan.additions" :key="'a' + i" class="grp">
          <div class="grp-title">
            【{{ kindLabel(g.kind) }}】{{ g.vendorName || '未命名供应商' }}
            <span v-if="g.docIndex >= 0" class="muted">→ 追加到「{{ g.docTitle }}」{{ g.orderCode }}</span>
            <span v-else class="muted">→ 新建草稿单</span>
          </div>
          <ul class="lines">
            <li v-for="(l, j) in g.lines" :key="j">
              {{ l.processName }}（数量 {{ num(l.planQty ?? l.quantity) }}，单价 {{ num(l.unitPrice) }}）
            </li>
          </ul>
        </div>
      </div>

      <div v-if="plan.removals.length" class="sec">
        <div class="sec-title"><el-tag type="danger" size="small">将删除</el-tag></div>
        <div v-for="(g, i) in plan.removals" :key="'r' + i" class="grp">
          <div class="grp-title">
            【{{ kindLabel(g.kind) }}】{{ g.vendorName || '' }}「{{ g.docTitle }}」{{ g.orderCode }}
            <el-tag v-if="g.removeDoc" type="danger" size="small">整单删除</el-tag>
            <span v-else class="muted">（该单仍有其他明细，保留整单）</span>
          </div>
          <ul class="lines">
            <li v-for="(l, j) in g.lines" :key="j">{{ l.processName }}</li>
          </ul>
        </div>
      </div>

      <div v-if="plan.manual.length" class="sec">
        <div class="sec-title"><el-tag type="warning" size="small">需人工处理</el-tag></div>
        <ul class="manual">
          <li v-for="(m, i) in plan.manual" :key="'m' + i">
            <span v-if="m.processName">工序「{{ m.processName }}」：</span>{{ m.reason }}
            <span v-if="m.orderCode" class="muted">（{{ m.docTitle }} {{ m.orderCode }}）</span>
          </li>
        </ul>
      </div>

      <div class="warnings">
        <div v-for="(w, i) in plan.warnings" :key="'w' + i">· {{ w }}</div>
      </div>
    </div>

    <template #footer>
      <el-button @click="emit('update:modelValue', false)">取 消</el-button>
      <el-button type="primary" @click="emit('confirm')">确定同步</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import type { DocSyncPlan } from '../docSync'

defineProps<{ modelValue: boolean; plan: DocSyncPlan | null }>()
const emit = defineEmits<{
  (e: 'update:modelValue', v: boolean): void
  (e: 'confirm'): void
}>()

function kindLabel(kind: string): string {
  return kind === 'PURCHASE' ? '采购单' : '加工单'
}

function num(v: any): string {
  const n = Number(v || 0)
  return Number.isFinite(n) ? String(n) : '0'
}
</script>

<style scoped>
.sync-body { max-height: 60vh; overflow-y: auto; }
.mb12 { margin-bottom: 12px; }
.sec { margin-bottom: 14px; }
.sec-title { margin-bottom: 6px; }
.grp { padding: 8px 10px; background: #fafafa; border-radius: 4px; margin-bottom: 8px; }
.grp-title { font-size: 13px; color: #303133; }
.muted { color: #909399; font-size: 12px; }
.lines { margin: 6px 0 0 18px; padding: 0; color: #606266; font-size: 12px; }
.manual { margin: 0 0 0 18px; padding: 0; color: #606266; font-size: 12px; }
.warnings { color: #909399; font-size: 12px; line-height: 20px; }
</style>
