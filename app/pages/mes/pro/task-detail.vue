<template>
  <view class="page">
    <view v-if="loading" class="state-box">
      <uni-load-more status="loading" />
    </view>

    <view v-else-if="!task" class="state-box">
      <text class="empty-text">未找到该工序任务</text>
    </view>

    <view v-else class="content">
      <!-- 基本信息 -->
      <view class="card">
        <view class="card-head">
          <text class="task-name">{{ task.processName || task.processCode || '未知工序' }}</text>
          <view class="head-tags">
            <text v-if="task.isOutsource === '1'" class="os-tag">外协</text>
            <uni-tag :type="statusTagType" :text="statusText" size="small" />
          </view>
        </view>
        <text class="sub-line">{{ task.workorderCode }}<text v-if="task.workorderName"> · {{ task.workorderName }}</text></text>
        <text v-if="task.qcBlocked" class="block-line">{{ task.qcBlockReason || '质检不合格，暂不可报工' }}</text>
      </view>

      <!-- 人员 -->
      <view class="card">
        <view class="row">
          <text class="row-label">负责人</text>
          <text class="row-value">{{ task.leaderNick || '-' }}</text>
        </view>
        <view class="row">
          <text class="row-label">报工人</text>
          <text class="row-value">{{ task.workerNick || '-' }}</text>
        </view>
        <view class="row">
          <text class="row-label">工作站</text>
          <text class="row-value">{{ task.workstationName || task.workstationCode || '-' }}</text>
        </view>
        <view v-if="task.isOutsource === '1'" class="row">
          <text class="row-label">外协厂商</text>
          <text class="row-value">{{ task.clientName || task.clientNick || '-' }}</text>
        </view>
      </view>

      <!-- 数量 -->
      <view class="card">
        <view class="qty-grid">
          <view class="qty-item">
            <text class="qty-num">{{ num(task.quantity) }}</text>
            <text class="qty-label">排产</text>
          </view>
          <view class="qty-item">
            <text class="qty-num hl">{{ num(task.quantityProduced) }}</text>
            <text class="qty-label">已产</text>
          </view>
          <view class="qty-item">
            <text class="qty-num ok">{{ num(task.quantityQualified) }}</text>
            <text class="qty-label">合格</text>
          </view>
          <view class="qty-item">
            <text class="qty-num bad">{{ num(task.quantityUnqualified) }}</text>
            <text class="qty-label">不合格</text>
          </view>
        </view>
      </view>

      <!-- 时间节点 -->
      <view class="card">
        <view class="row">
          <text class="row-label">上机时间</text>
          <text class="row-value">{{ formatTime(task.startTime) }}</text>
        </view>
        <view class="row">
          <text class="row-label">计划完成</text>
          <text class="row-value">{{ formatTime(task.endTime) }}</text>
        </view>
        <view class="row">
          <text class="row-label">完工时间</text>
          <text class="row-value">{{ formatTime(task.finishDate) }}</text>
        </view>
        <view v-if="pendingFeedbackCount > 0" class="row">
          <text class="row-label">待确认报工</text>
          <text class="row-value warn">{{ pendingFeedbackCount }} 条</text>
        </view>
      </view>
    </view>

    <!-- 底部操作：仅生产中可进入报工页（外协工序由报工页引导转外协发货） -->
    <view v-if="task && task.status === 'PRODUCING'" class="footer">
      <button class="report-btn" type="primary" @click="goReport">去报工</button>
    </view>
  </view>
</template>

<script setup>
  import { ref, computed } from 'vue'
  import { onLoad, onShow } from '@dcloudio/uni-app'
  import UniLoadMore from '@/uni_modules/uni-load-more/components/uni-load-more/uni-load-more.vue'
  import UniTag from '@/uni_modules/uni-tag/components/uni-tag/uni-tag.vue'
  import { getWorkorderTasks } from '@/api/mes/pro/feedback'

  const task = ref(null)
  const loading = ref(true)
  let workorderCode = ''
  let taskId = null

  const TASK_STATUS_MAP = { NORMAL: '未开工', PRODUCING: '生产中', COMPLETED: '已完成', CANCEL: '已取消' }

  const statusText = computed(() => {
    if (!task.value) return ''
    if (task.value.qcBlocked) return '不可开工'
    if (task.value.isOutsource === '1' && task.value.status === 'PRODUCING') return '外协中'
    return TASK_STATUS_MAP[task.value.status] || task.value.status || ''
  })

  const statusTagType = computed(() => {
    if (!task.value) return 'default'
    if (task.value.qcBlocked) return 'error'
    const m = { COMPLETED: 'success', PRODUCING: 'warning', CANCEL: 'error' }
    return m[task.value.status] || 'default'
  })

  const pendingFeedbackCount = computed(() => Number(task.value && task.value.pendingFeedbackCount) || 0)

  function num(v) {
    const n = Number(v)
    return isNaN(n) ? 0 : n
  }

  /** yyyy-MM-dd HH:mm:ss → yyyy-MM-dd HH:mm */
  function formatTime(t) {
    return t ? t.substring(0, 16) : '-'
  }

  function goReport() {
    uni.navigateTo({
      url: '/pages/mes/pro/report?workorderCode=' + encodeURIComponent(workorderCode) + '&taskId=' + taskId
    })
  }

  function load() {
    loading.value = true
    getWorkorderTasks(workorderCode).then(res => {
      const tasks = (res.data && res.data.tasks) || []
      task.value = tasks.find(t => Number(t.taskId) === Number(taskId)) || null
    }).finally(() => {
      loading.value = false
    })
  }

  onLoad((options) => {
    if (!options) return
    workorderCode = options.workorderCode || ''
    taskId = options.taskId || null
    if (workorderCode && taskId) {
      load()
    } else {
      loading.value = false
    }
  })

  // 从报工页返回时刷新状态
  onShow(() => {
    if (workorderCode && taskId && task.value) {
      load()
    }
  })
</script>

<style lang="scss" scoped>
  page {
    background-color: #f5f6f7;
  }

  .page {
    padding: 20rpx 24rpx 160rpx;
  }

  .state-box {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 120rpx 40rpx;
  }

  .empty-text {
    font-size: 28rpx;
    color: #999;
  }

  .content {
    display: flex;
    flex-direction: column;
    gap: 4rpx;
  }

  .card {
    background: #fff;
    border-radius: 20rpx;
    padding: 28rpx;
    margin-bottom: 20rpx;
    box-shadow: 0 4rpx 16rpx rgba(60, 96, 150, 0.06);
  }

  .card-head {
    display: flex;
    justify-content: space-between;
    align-items: center;

    .head-tags {
      display: flex;
      align-items: center;
      gap: 10rpx;
    }
  }

  .task-name {
    font-size: 34rpx;
    font-weight: 600;
    color: #1f2d3d;
  }

  .sub-line {
    display: block;
    font-size: 24rpx;
    color: #8a94a6;
    margin-top: 8rpx;
  }

  .block-line {
    display: block;
    margin-top: 12rpx;
    font-size: 24rpx;
    color: #f56c6c;
  }

  .os-tag {
    font-size: 20rpx;
    color: #b06f1f;
    background: #fdf3e3;
    border-radius: 8rpx;
    padding: 4rpx 10rpx;
  }

  .row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12rpx 0;
  }

  .row-label {
    font-size: 26rpx;
    color: #8a94a6;
  }

  .row-value {
    font-size: 26rpx;
    color: #1f2d3d;

    &.warn {
      color: #f56c6c;
      font-weight: 600;
    }
  }

  .qty-grid {
    display: flex;
  }

  .qty-item {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .qty-num {
    font-size: 34rpx;
    font-weight: 600;
    color: #1f2d3d;

    &.hl { color: #3c96f3; }
    &.ok { color: #67c23a; }
    &.bad { color: #f56c6c; }
  }

  .qty-label {
    margin-top: 6rpx;
    font-size: 22rpx;
    color: #8a94a6;
  }

  .footer {
    position: fixed;
    left: 0;
    right: 0;
    bottom: 0;
    padding: 20rpx 32rpx calc(20rpx + env(safe-area-inset-bottom));
    background: #fff;
    box-shadow: 0 -4rpx 16rpx rgba(60, 96, 150, 0.06);
  }

  .report-btn {
    width: 100%;
    border-radius: 44rpx;
    background: linear-gradient(135deg, #3c96f3, #5ba8f5);
  }
</style>
