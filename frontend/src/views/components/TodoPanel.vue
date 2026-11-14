<template>
  <el-card class="todo-panel" shadow="never">
    <template #header>
      <div class="todo-header">
        <span class="todo-title">我的待办</span>
        <div class="todo-summary">
          <span class="summary-text">共 <b>{{ summary.total }}</b> 项待处理</span>
          <el-button link type="primary" size="small" @click="goAll">
            查看全部<el-icon class="el-icon--right"><ArrowRight /></el-icon>
          </el-button>
        </div>
      </div>
    </template>

    <div v-loading="loading" class="todo-cards">
      <div v-for="card in cards" :key="card.key" class="todo-card" @click="goCard(card)">
        <div class="card-head">
          <span class="card-icon" :style="{ color: card.color, background: card.bg }">
            <AppIcon :icon-class="card.icon" :size="16" />
          </span>
          <span class="card-label">{{ card.label }}</span>
        </div>
        <div class="card-count">{{ card.count }}</div>
        <div class="card-foot">
          <span class="card-desc">{{ card.desc }}</span>
          <el-icon class="card-arrow"><ArrowRight /></el-icon>
        </div>
      </div>
    </div>
  </el-card>
</template>

<script setup lang="ts" name="TodoPanel">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ArrowRight } from '@element-plus/icons-vue'
import { getHomeTodoSummary } from '@/api/mes/sys/todolist'
import type { HomeTodoSummary } from '@/types'

interface TodoCard {
  key: keyof Omit<HomeTodoSummary, 'total'>
  label: string
  desc: string
  icon: string
  color: string
  bg: string
  path: string
  query: Record<string, string>
  count: number
}

const router = useRouter()
const loading = ref(false)
const summary = ref<HomeTodoSummary>({
  approval: 0,
  production: 0,
  quality: 0,
  purchase: 0,
  outsource: 0,
  total: 0
})

const cards = computed<TodoCard[]>(() => [
  {
    key: 'approval',
    label: '审批',
    desc: '待审批采购单',
    icon: 'checkbox',
    color: '#1a3c5e',
    bg: '#eef3f8',
    path: '/mes/pur/order',
    query: { status: 'DRAFT' },
    count: summary.value.approval
  },
  {
    key: 'production',
    label: '生产',
    desc: '报工待审核',
    icon: 'component',
    color: '#30b08f',
    bg: '#eaf7f3',
    path: '/mes/pro/feedback',
    query: { status: 'PREPARE' },
    count: summary.value.production
  },
  {
    key: 'quality',
    label: '质检',
    desc: '过程质检',
    icon: 'validCode',
    color: '#c9a96e',
    bg: '#faf6ee',
    path: '/qc/qcipqc',
    query: { status: 'PENDING' },
    count: summary.value.quality
  },
  {
    key: 'purchase',
    label: '采购/仓库',
    desc: '待发料',
    icon: 'tree-table',
    color: '#2a5a8a',
    bg: '#eef4fa',
    path: '/mes/wm/issue',
    query: { pending: '1' },
    count: summary.value.purchase
  },
  {
    key: 'outsource',
    label: '外协代录',
    desc: '外协代录',
    icon: 'shopping',
    color: '#8a6d3b',
    bg: '#f7f3ea',
    path: '/mes/wm/outsource',
    query: { pending: '1' },
    count: summary.value.outsource
  }
])

async function loadSummary() {
  loading.value = true
  try {
    const res = await getHomeTodoSummary()
    summary.value = { ...summary.value, ...(res.data || {}) }
  } finally {
    loading.value = false
  }
}

function goCard(card: TodoCard) {
  router.push({ path: card.path, query: card.query }).catch(() => {})
}

function goAll() {
  router.push('/mes/sys/todolist').catch(() => {})
}

onMounted(loadSummary)
</script>

<style scoped>
.todo-panel {
  margin-bottom: 16px;
}

.todo-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.todo-title {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
}

.todo-summary {
  display: flex;
  align-items: center;
  gap: 8px;
}

.summary-text {
  font-size: 12px;
  color: #909399;
}

.summary-text b {
  color: #303133;
  font-weight: 600;
}

.todo-cards {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 12px;
}

.todo-card {
  padding: 12px 14px;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  background: #fff;
}

.todo-card:hover {
  border-color: #0cd7bd;
  box-shadow: 0 4px 16px rgba(12, 215, 189, 0.15);
  transform: translateY(-2px);
}

.card-head {
  display: flex;
  align-items: center;
  gap: 8px;
}

.card-icon {
  width: 26px;
  height: 26px;
  border-radius: 6px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.card-label {
  font-size: 13px;
  color: #606266;
}

.card-count {
  margin: 8px 0 4px;
  font-size: 24px;
  font-weight: 600;
  line-height: 1.1;
  color: #303133;
}

.card-foot {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 6px;
}

.card-desc {
  font-size: 11px;
  color: #909399;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.card-arrow {
  flex: none;
  color: #c0c4cc;
  font-size: 12px;
}

@media (max-width: 1200px) {
  .todo-cards {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 768px) {
  .todo-cards {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
