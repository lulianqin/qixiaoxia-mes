<template>
  <view class="home-page" :style="{ height: windowHeight + 'px' }">
    <!-- 顶部标题 + 状态 tab -->
    <view class="home-header">
      <view class="header-row">
        <view class="header-text">
          <text class="hello">你好，{{ userName || '同事' }}</text>
          <text class="hello-sub">我的工单任务</text>
        </view>
        <view class="work-entry" @click="goWorkbench">工作台 ›</view>
      </view>

      <view class="tab-bar">
        <view
          v-for="tab in tabs"
          :key="tab.key"
          class="tab-item"
          :class="{ active: activeTab === tab.key }"
          @click="switchTab(tab.key)"
        >
          <text class="tab-text">{{ tab.label }}</text>
          <view v-if="activeTab === tab.key" class="tab-dot"></view>
        </view>
      </view>
    </view>

    <scroll-view
      class="list-scroll"
      scroll-y
      :refresher-enabled="true"
      :refresher-triggered="refreshing"
      @refresherrefresh="onRefresh"
      @scrolltolower="loadMore"
    >
      <view v-if="loading" class="state-box">
        <uni-load-more status="loading" />
      </view>

      <view v-else-if="list.length === 0" class="state-box">
        <text class="empty-text">{{ emptyText }}</text>
        <text v-if="activeTab === 'pending'" class="empty-link" @click="goReportList">查看全部待报工 ›</text>
      </view>

      <view v-else class="list-box">
        <!-- 待报工 / 我负责：任务卡片 -->
        <block v-if="isTaskTab">
          <view v-for="item in list" :key="'t' + item.taskId" class="card" @click="goReport(item)">
            <view class="card-head">
              <text class="process">{{ item.processName || item.processCode || '未知工序' }}</text>
              <uni-tag v-if="item.qcBlocked" type="error" text="不可开工" size="small" />
              <uni-tag v-else-if="activeTab === 'leader'" type="primary" text="负责人" size="small" />
              <uni-tag v-else type="warning" text="待报工" size="small" />
            </view>
            <text class="workorder">{{ item.workorderCode }}<text v-if="item.workorderName"> · {{ item.workorderName }}</text></text>
            <view class="card-foot">
              <view class="qty">
                <text class="qty-label">排产</text>
                <text class="qty-value">{{ num(item.quantity) }}</text>
                <text class="qty-label">已产</text>
                <text class="qty-value">{{ num(item.quantityProduced) }}</text>
              </view>
              <text class="go-text">去报工 ›</text>
            </view>
          </view>
        </block>

        <!-- 待确认 / 已确认 / 全部：报工记录卡片 -->
        <block v-else>
          <view v-for="item in list" :key="'f' + item.recordId" class="card">
            <view class="card-head">
              <text class="process">{{ item.processName || '未知工序' }}</text>
              <uni-tag :type="statusTagType(item.status)" :text="statusText(item.status)" size="small" />
            </view>
            <text class="workorder">{{ item.workorderCode || item.workorderName || '-' }}</text>
            <view class="card-foot">
              <view class="qty">
                <text class="qty-label">合格</text>
                <text class="qty-value">{{ num(item.quantityQualified) }}</text>
                <text v-if="num(item.quantityUnqualified) > 0" class="qty-label">不合格</text>
                <text v-if="num(item.quantityUnqualified) > 0" class="qty-value danger">{{ num(item.quantityUnqualified) }}</text>
              </view>
              <text class="time">{{ formatTime(item.feedbackTime || item.createTime) }}</text>
            </view>
          </view>
        </block>

        <uni-load-more :status="finished ? 'noMore' : 'more'" />
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
  import { ref, computed, getCurrentInstance } from 'vue'
  import { onShow } from '@dcloudio/uni-app'
  import UniLoadMore from '@/uni_modules/uni-load-more/components/uni-load-more/uni-load-more.vue'
  import UniTag from '@/uni_modules/uni-tag/components/uni-tag/uni-tag.vue'
  import { listFeedback, listReportableTask } from '@/api/mes/pro/feedback'
  import { hasPermission } from '@/utils/mobileMenu'
  import { useUserStore } from '@/store'

  const { proxy } = getCurrentInstance()
  const userStore = useUserStore()
  const windowHeight = uni.getSystemInfoSync().windowHeight
  const PAGE_SIZE = 10

  const ALL_TABS = [
    { key: 'pending', label: '待报工' },
    { key: 'leader', label: '我负责' },
    { key: 'prepare', label: '待确认', status: 'PREPARE' },
    { key: 'confirmed', label: '已确认', status: 'CONFIRMED' },
    { key: 'all', label: '全部', status: '' }
  ]
  const STATUS_MAP = { PREPARE: '待确认', CONFIRMED: '已确认', AUDITED: '已审核' }
  const STATUS_TAG_MAP = { PREPARE: 'warning', CONFIRMED: 'primary', AUDITED: 'success' }

  // 只展示当前账号有权限的 tab（任务类 tab 看任务权限，报工记录 tab 看记录权限）
  const TASK_TAB_KEYS = ['pending', 'leader']
  const tabs = computed(() => ALL_TABS.filter(tab => TASK_TAB_KEYS.indexOf(tab.key) !== -1
    ? hasPermission(userStore.permissions, 'mes:pro:task:list')
    : hasPermission(userStore.permissions, 'mes:pro:feedback:list')))
  // 任务卡片（报工人 / 负责人视角）与报工记录卡片分开渲染
  const isTaskTab = computed(() => TASK_TAB_KEYS.indexOf(activeTab.value) !== -1)

  const userName = computed(() => userStore.name)
  const activeTab = ref('')
  const list = ref([])
  const loading = ref(false)
  const refreshing = ref(false)
  const finished = ref(false)
  const pageNum = ref(1)

  const currentTab = computed(() => ALL_TABS.find(tab => tab.key === activeTab.value))

  const emptyText = computed(() => {
    const map = {
      pending: '暂无派给你的待报工任务',
      leader: '暂无你负责的生产中任务',
      prepare: '暂无待确认的报工',
      confirmed: '暂无已确认的报工',
      all: '暂无报工记录'
    }
    return map[activeTab.value] || '暂无数据'
  })

  function num(v) {
    const n = Number(v)
    return isNaN(n) ? 0 : n
  }

  function statusText(status) {
    return STATUS_MAP[status] || status || ''
  }

  function statusTagType(status) {
    return STATUS_TAG_MAP[status] || 'default'
  }

  /** 2026-07-11 14:52:17 → 07-11 14:52 */
  function formatTime(t) {
    return t ? t.substring(5, 16) : ''
  }

  function loadData(reset) {
    if (!activeTab.value || loading.value) {
      refreshing.value = false
      return
    }
    if (reset) {
      pageNum.value = 1
      finished.value = false
    }
    loading.value = true
    const params = { pageNum: pageNum.value, pageSize: PAGE_SIZE }
    let request

    if (activeTab.value === 'pending') {
      // 个人任务：后端按派工人过滤（task.worker_id = 当前用户）
      if (userStore.id) params.workerId = userStore.id
      request = listReportableTask(params)
    } else if (activeTab.value === 'leader') {
      // 我负责的：后端按负责人过滤（task.leader_id = 当前用户），仅用于查看与代报兜底
      if (userStore.id) params.leaderId = userStore.id
      request = listReportableTask(params)
    } else {
      // 个人报工记录：后端按报工人过滤（feedback.user_id = 当前用户）
      if (userStore.id) params.userId = userStore.id
      if (currentTab.value && currentTab.value.status) {
        params.status = currentTab.value.status
      }
      request = listFeedback(params)
    }

    request.then(res => {
      const rows = res.rows || []
      list.value = reset ? rows : list.value.concat(rows)
      finished.value = rows.length < PAGE_SIZE
    }).catch(() => {
      if (!reset) pageNum.value--
    }).finally(() => {
      loading.value = false
      refreshing.value = false
    })
  }

  function switchTab(key) {
    if (activeTab.value === key) return
    activeTab.value = key
    list.value = []
    finished.value = false
    loadData(true)
  }

  function onRefresh() {
    refreshing.value = true
    loadData(true)
  }

  function loadMore() {
    if (loading.value || finished.value) return
    pageNum.value++
    loadData(false)
  }

  function goReport(item) {
    proxy.$tab.navigateTo('/pages/mes/pro/report?workorderCode=' + encodeURIComponent(item.workorderCode) + '&taskId=' + item.taskId)
  }

  function goReportList() {
    proxy.$tab.navigateTo('/pages/mes/pro/report-list')
  }

  function goWorkbench() {
    proxy.$tab.switchTab('/pages/work/index')
  }

  onShow(() => {
    if (!activeTab.value) {
      activeTab.value = (tabs.value[0] && tabs.value[0].key) || ''
    }
    loadData(true)
  })
</script>

<style lang="scss" scoped>
  page {
    background-color: #f5f6f7;
  }

  .home-page {
    display: flex;
    flex-direction: column;
    overflow: hidden;
    background-color: #f5f6f7;
  }

  .home-header {
    flex-shrink: 0;
    padding: calc(var(--status-bar-height) + 24rpx) 32rpx 0;
    background: linear-gradient(135deg, #3c96f3, #5ba8f5);
    border-radius: 0 0 28rpx 28rpx;
    color: #fff;
  }

  .header-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-bottom: 28rpx;
  }

  .header-text {
    display: flex;
    flex-direction: column;
  }

  .hello {
    font-size: 36rpx;
    font-weight: 600;
  }

  .hello-sub {
    margin-top: 8rpx;
    font-size: 24rpx;
    opacity: 0.85;
  }

  .work-entry {
    font-size: 24rpx;
    padding: 10rpx 20rpx;
    border-radius: 28rpx;
    background: rgba(255, 255, 255, 0.2);
  }

  .tab-bar {
    display: flex;
  }

  .tab-item {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 16rpx 0 20rpx;

    .tab-text {
      font-size: 26rpx;
      color: rgba(255, 255, 255, 0.75);
      white-space: nowrap;
    }
  }

  .tab-item.active .tab-text {
    color: #fff;
    font-weight: 600;
    font-size: 30rpx;
  }

  .tab-dot {
    width: 36rpx;
    height: 6rpx;
    margin-top: 10rpx;
    border-radius: 6rpx;
    background: #fff;
  }

  .list-scroll {
    flex: 1;
    min-height: 0;
  }

  .state-box {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 100rpx 40rpx;
  }

  .empty-text {
    font-size: 28rpx;
    color: #999;
  }

  .empty-link {
    margin-top: 24rpx;
    font-size: 26rpx;
    color: #3c96f3;
  }

  .list-box {
    padding: 20rpx 24rpx 40rpx;
  }

  .card {
    background: #fff;
    border-radius: 20rpx;
    padding: 28rpx 28rpx 24rpx;
    margin-bottom: 20rpx;
    box-shadow: 0 4rpx 16rpx rgba(60, 96, 150, 0.06);
  }

  .card-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12rpx;
  }

  .process {
    font-size: 36rpx;
    font-weight: 600;
    color: #1f2d3d;
  }

  .workorder {
    display: block;
    font-size: 24rpx;
    color: #8a94a6;
    margin-bottom: 18rpx;
  }

  .card-foot {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 16rpx;
    border-top: 1rpx solid #f2f4f7;
  }

  .qty {
    display: flex;
    align-items: baseline;

    .qty-label {
      font-size: 24rpx;
      color: #8a94a6;
      margin-right: 6rpx;
    }

    .qty-value {
      font-size: 30rpx;
      font-weight: 600;
      color: #1f2d3d;
      margin-right: 18rpx;
    }

    .danger {
      color: #f56c6c;
    }
  }

  .go-text {
    font-size: 26rpx;
    color: #3c96f3;
    font-weight: 600;
  }

  .time {
    font-size: 24rpx;
    color: #8a94a6;
  }
</style>
