<template>
  <view class="page">
    <view v-if="loading" class="state-box">
      <uni-load-more status="loading" />
    </view>

    <view v-else-if="!workorder" class="state-box">
      <text class="empty-text">未找到工单</text>
    </view>

    <view v-else>
      <!-- 工单信息 -->
      <view class="card">
        <view class="card-head">
          <text class="wo-code">{{ workorder.workorderCode }}</text>
          <uni-tag :type="woStatusTagType(workorder.status)" :text="woStatusText(workorder.status)" size="small" />
        </view>
        <text class="wo-name">{{ workorder.workorderName || '-' }}</text>

        <view class="info-grid">
          <view class="info-item">
            <text class="info-label">产品</text>
            <text class="info-value">{{ workorder.productName || '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">规格</text>
            <text class="info-value">{{ workorder.productSpc || '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">计划数量</text>
            <text class="info-value">{{ num(workorder.quantity) }} {{ workorder.unitName || '' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">已生产</text>
            <text class="info-value strong">{{ num(workorder.quantityProduced) }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">客户</text>
            <text class="info-value">{{ workorder.clientName || '-' }}</text>
          </view>
          <view class="info-item">
            <text class="info-label">计划交期</text>
            <text class="info-value">{{ formatDay(workorder.requestDate) }}</text>
          </view>
        </view>

        <view class="progress-wrap">
          <view class="progress-bar">
            <view class="progress-inner" :style="{ width: progressPercent + '%' }"></view>
          </view>
          <text class="progress-text">{{ progressPercent }}%</text>
        </view>
      </view>

      <!-- 工序列表 -->
      <view class="section-title">工序（{{ tasks.length }}）</view>
      <view
        v-for="(task, index) in tasks"
        :key="task.taskId"
        class="card task-card"
        @click="goTaskDetail(task)"
      >
        <view class="task-head">
          <view class="task-title">
            <text class="task-order">{{ index + 1 }}</text>
            <text class="task-name">{{ task.processName || task.processCode || '未知工序' }}</text>
          </view>
          <view class="task-tags">
            <text v-if="task.isOutsource === '1'" class="os-tag">外协</text>
            <uni-tag :type="taskStatusTagType(task)" :text="taskStatusText(task)" size="small" />
          </view>
        </view>

        <view class="task-meta">
          <text class="meta-line">负责人：{{ task.leaderNick || '-' }}　报工人：{{ task.workerNick || '-' }}</text>
          <view class="task-qty">
            <text class="qty-label">排产</text>
            <text class="qty-value">{{ num(task.quantity) }}</text>
            <text class="qty-label">已产</text>
            <text class="qty-value">{{ num(task.quantityProduced) }}</text>
            <text class="qty-label">合格</text>
            <text class="qty-value">{{ num(task.quantityQualified) }}</text>
          </view>
          <text class="meta-line time">上机：{{ formatTime(task.startTime) }}　完工：{{ formatTime(task.finishDate) }}</text>
        </view>
        <text class="go-text">工序详情 ›</text>
      </view>

      <!-- 关联单据 -->
      <view class="section-title">关联单据</view>
      <view class="card">
        <view class="dim-grid">
          <view
            v-for="d in dimCards"
            :key="d.key"
            class="dim-tile"
            :class="{ active: expandedDim === d.key }"
            @click="toggleDim(d.key)"
          >
            <text class="dim-num">{{ d.total }}</text>
            <text class="dim-label">{{ d.label }}</text>
          </view>
        </view>
        <view v-if="expandedDim" class="dim-list">
          <view v-for="(row, i) in expandedRows" :key="expandedDim + i" class="dim-row">
            <text class="dim-row-main">{{ row.primary }}</text>
            <text class="dim-row-sub">{{ row.secondary }}</text>
          </view>
          <text v-if="!expandedRows.length" class="dim-empty">暂无{{ dimLabel(expandedDim) }}明细</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
  import { ref, computed } from 'vue'
  import { onLoad } from '@dcloudio/uni-app'
  import UniLoadMore from '@/uni_modules/uni-load-more/components/uni-load-more/uni-load-more.vue'
  import UniTag from '@/uni_modules/uni-tag/components/uni-tag/uni-tag.vue'
  import { getWorkorderBoard } from '@/api/mes/pro/feedback'

  const workorder = ref(null)
  const tasks = ref([])
  const loading = ref(true)
  const dims = ref({ feedback: {}, inspection: {}, outsource: {}, issue: {}, itemRecpt: {}, productRecpt: {} })
  const expandedDim = ref('')

  const FB_STATUS_MAP = { PREPARE: '待审核', CONFIRMED: '已确认', AUDITED: '已审核' }
  const DIM_LABEL_MAP = { feedback: '报工', inspection: '检验', outsource: '外协', issue: '领料', itemRecpt: '收料', productRecpt: '入库' }

  const WO_STATUS_MAP = { PREPARE: '待生产', PRODUCING: '生产中', COMPLETED: '已完成', CANCEL: '已取消', CLOSED: '已关闭' }
  const WO_STATUS_TAG_MAP = { PREPARE: 'default', PRODUCING: 'warning', COMPLETED: 'success', CANCEL: 'error', CLOSED: 'info' }
  const TASK_STATUS_MAP = { NORMAL: '未开工', PRODUCING: '生产中', COMPLETED: '已完成', CANCEL: '已取消' }

  const progressPercent = computed(() => {
    const q = num(workorder.value && workorder.value.quantity)
    const p = num(workorder.value && workorder.value.quantityProduced)
    if (q <= 0) return 0
    return Math.min(100, Math.round(p / q * 100))
  })

  function num(v) {
    const n = Number(v)
    return isNaN(n) ? 0 : n
  }

  function woStatusText(s) { return WO_STATUS_MAP[s] || s || '' }
  function woStatusTagType(s) { return WO_STATUS_TAG_MAP[s] || 'default' }

  function taskStatusText(task) {
    if (task.qcBlocked) return '不可开工'
    return TASK_STATUS_MAP[task.status] || task.status || ''
  }

  function taskStatusTagType(task) {
    if (task.qcBlocked) return 'error'
    const m = { COMPLETED: 'success', PRODUCING: 'warning', CANCEL: 'error' }
    return m[task.status] || 'default'
  }

  /** yyyy-MM-dd HH:mm:ss → MM-dd HH:mm */
  function formatTime(t) {
    return t ? t.substring(5, 16) : '-'
  }

  /** yyyy-MM-dd HH:mm:ss → yyyy-MM-dd */
  function formatDay(t) {
    return t ? t.substring(0, 10) : '-'
  }

  function goTaskDetail(task) {
    const code = workorder.value ? workorder.value.workorderCode : ''
    uni.navigateTo({
      url: '/pages/mes/pro/task-detail?workorderCode=' + encodeURIComponent(code) + '&taskId=' + task.taskId
    })
  }

  const dimCards = computed(() => [
    { key: 'feedback', label: '报工', total: dims.value.feedback.total ?? 0 },
    { key: 'inspection', label: '检验', total: dims.value.inspection.total ?? 0 },
    { key: 'outsource', label: '外协', total: dims.value.outsource.total ?? 0 },
    { key: 'issue', label: '领料', total: dims.value.issue.total ?? 0 },
    { key: 'itemRecpt', label: '收料', total: dims.value.itemRecpt.total ?? 0 },
    { key: 'productRecpt', label: '入库', total: dims.value.productRecpt.total ?? 0 }
  ])

  const expandedRows = computed(() => {
    const k = expandedDim.value
    if (!k) return []
    const list = (dims.value[k] && dims.value[k].list) || []
    switch (k) {
      case 'feedback': return list.map(f => ({ primary: f.processName || f.feedbackCode, secondary: num(f.quantityFeedback) + ' · ' + fbStatusText(f.status) }))
      case 'inspection': return list.map(x => ({ primary: x.ipqcName || x.ipqcCode, secondary: x.status || '-' }))
      case 'outsource': return list.map(x => ({ primary: x.vendorName || x.orderCode, secondary: x.status || '-' }))
      case 'issue': return list.map(x => ({ primary: x.issueName || x.issueCode, secondary: x.status || '-' }))
      case 'itemRecpt': return list.map(x => ({ primary: x.vendorName || x.recptCode, secondary: num(x.totalQuantity) + ' · ' + (x.status || '-') }))
      case 'productRecpt': return list.map(x => ({ primary: x.clientName || x.recptCode, secondary: num(x.totalQuantity) + ' · ' + (x.status || '-') }))
      default: return []
    }
  })

  function fbStatusText(s) { return FB_STATUS_MAP[s] || s || '-' }
  function dimLabel(k) { return DIM_LABEL_MAP[k] || k }
  function toggleDim(k) { expandedDim.value = expandedDim.value === k ? '' : k }

  function load(workorderId) {
    loading.value = true
    getWorkorderBoard(workorderId).then(res => {
      workorder.value = (res.data && res.data.workorder) || null
      tasks.value = (res.data && res.data.tasks) || []
      if (res.data) {
        dims.value = {
          feedback: res.data.feedback || {},
          inspection: res.data.inspection || {},
          outsource: res.data.outsource || {},
          issue: res.data.issue || {},
          itemRecpt: res.data.itemRecpt || {},
          productRecpt: res.data.productRecpt || {}
        }
      }
    }).finally(() => {
      loading.value = false
    })
  }

  onLoad((options) => {
    if (options && options.workorderId) {
      load(options.workorderId)
    } else {
      loading.value = false
    }
  })
</script>

<style lang="scss" scoped>
  page {
    background-color: #f5f6f7;
  }

  .page {
    padding: 20rpx 24rpx 40rpx;
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
  }

  .wo-code {
    font-size: 34rpx;
    font-weight: 600;
    color: #1f2d3d;
  }

  .wo-name {
    display: block;
    font-size: 26rpx;
    color: #8a94a6;
    margin: 8rpx 0 20rpx;
  }

  .info-grid {
    display: flex;
    flex-wrap: wrap;
  }

  .info-item {
    width: 50%;
    display: flex;
    flex-direction: column;
    margin-bottom: 16rpx;
  }

  .info-label {
    font-size: 22rpx;
    color: #8a94a6;
  }

  .info-value {
    font-size: 26rpx;
    color: #1f2d3d;
    margin-top: 4rpx;

    &.strong {
      font-weight: 600;
    }
  }

  .progress-wrap {
    display: flex;
    align-items: center;
    gap: 16rpx;
    margin-top: 8rpx;
  }

  .progress-bar {
    flex: 1;
    height: 14rpx;
    border-radius: 8rpx;
    background: #eef1f5;
    overflow: hidden;
  }

  .progress-inner {
    height: 100%;
    border-radius: 8rpx;
    background: linear-gradient(90deg, #3c96f3, #5ba8f5);
  }

  .progress-text {
    font-size: 24rpx;
    color: #3c96f3;
    font-weight: 600;
  }

  .section-title {
    font-size: 28rpx;
    font-weight: 600;
    color: #1f2d3d;
    margin: 8rpx 4rpx 16rpx;
  }

  .task-card {
    padding: 24rpx 28rpx;
  }

  .task-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12rpx;
  }

  .task-title {
    display: flex;
    align-items: center;
    gap: 12rpx;
    min-width: 0;
  }

  .task-order {
    flex-shrink: 0;
    width: 40rpx;
    height: 40rpx;
    line-height: 40rpx;
    border-radius: 50%;
    background: #eef5ff;
    color: #3c96f3;
    font-size: 22rpx;
    text-align: center;
  }

  .task-name {
    font-size: 30rpx;
    font-weight: 600;
    color: #1f2d3d;
  }

  .task-tags {
    display: flex;
    align-items: center;
    gap: 10rpx;
  }

  .os-tag {
    font-size: 20rpx;
    color: #b06f1f;
    background: #fdf3e3;
    border-radius: 8rpx;
    padding: 4rpx 10rpx;
  }

  .task-meta {
    display: flex;
    flex-direction: column;
    gap: 8rpx;
  }

  .meta-line {
    font-size: 24rpx;
    color: #8a94a6;

    &.time {
      color: #b0b8c5;
    }
  }

  .task-qty {
    display: flex;
    align-items: baseline;

    .qty-label {
      font-size: 24rpx;
      color: #8a94a6;
      margin-right: 6rpx;
    }

    .qty-value {
      font-size: 28rpx;
      font-weight: 600;
      color: #1f2d3d;
      margin-right: 18rpx;
    }
  }

  .go-text {
    display: block;
    text-align: right;
    margin-top: 12rpx;
    font-size: 26rpx;
    color: #3c96f3;
    font-weight: 600;
  }

  .dim-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 16rpx;
  }

  .dim-tile {
    flex: 1 1 28%;
    min-width: 28%;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 20rpx 0;
    background: #f7f9fc;
    border-radius: 16rpx;
    border: 2rpx solid transparent;

    &.active {
      background: #eef5ff;
      border-color: #3c96f3;
    }
  }

  .dim-num {
    font-size: 36rpx;
    font-weight: 600;
    color: #1f2d3d;
  }

  .dim-label {
    margin-top: 4rpx;
    font-size: 22rpx;
    color: #8a94a6;
  }

  .dim-list {
    margin-top: 20rpx;
    border-top: 1rpx solid #f0f2f5;
  }

  .dim-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 18rpx 4rpx;
    border-bottom: 1rpx solid #f5f6f7;
  }

  .dim-row-main {
    font-size: 26rpx;
    color: #1f2d3d;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .dim-row-sub {
    flex-shrink: 0;
    margin-left: 16rpx;
    font-size: 24rpx;
    color: #8a94a6;
  }

  .dim-empty {
    display: block;
    padding: 20rpx 0;
    text-align: center;
    font-size: 24rpx;
    color: #b0b8c5;
  }
</style>
