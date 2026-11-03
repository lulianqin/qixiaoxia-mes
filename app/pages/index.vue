<template>
  <view class="home-page" :style="{ height: windowHeight + 'px' }">
    <!-- 顶部标题 + 状态 tab -->
    <view class="home-header">
      <view class="header-row">
        <view class="header-text">
          <text class="hello">你好，{{ userName || '同事' }}</text>
          <text class="hello-sub">我的工单</text>
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
      </view>

      <view v-else class="list-box">
        <!-- 我的工单：工单卡片，横向展示全部工序 chips -->
        <block v-if="activeTab === 'workorder'">
          <view
            v-for="entry in list"
            :key="'w' + entry.workorder.workorderId"
            class="card"
            @click="goWorkorderDetail(entry)"
          >
            <view class="card-head">
              <view class="wo-title">
                <text class="process">{{ entry.workorder.workorderCode }}</text>
                <uni-tag :type="woStatusTagType(entry.workorder.status)" :text="woStatusText(entry.workorder.status)" size="small" />
              </view>
              <text class="wo-name">{{ entry.workorder.workorderName || entry.workorder.productName || '' }}</text>
            </view>

            <scroll-view :scroll-x="true" class="chip-scroll">
              <view class="chip-row">
                <view
                  v-for="task in entry.tasks"
                  :key="task.taskId"
                  class="chip"
                  @click.stop="goTaskDetail(entry, task)"
                >
                  <view class="chip-dot" :class="'dot-' + chipLevel(task)"></view>
                  <text class="chip-name" :class="'name-' + chipLevel(task)">{{ task.processName || task.processCode || '未知工序' }}</text>
                  <text v-if="task.isOutsource === '1'" class="chip-OS">外协</text>
                  <text v-if="task.pendingFeedbackCount > 0" class="chip-badge">{{ task.pendingFeedbackCount }}</text>
                </view>
              </view>
            </scroll-view>

            <view class="card-foot">
              <view class="qty">
                <text class="qty-label">排产</text>
                <text class="qty-value">{{ num(entry.workorder.quantity) }}</text>
                <text class="qty-label">已产</text>
                <text class="qty-value">{{ num(entry.workorder.quantityProduced) }}</text>
              </view>
              <text class="go-text">详情 ›</text>
            </view>
          </view>
        </block>

        <!-- 待确认 / 已确认 / 全部：报工记录卡片 -->
        <block v-else>
          <view v-for="item in list" :key="'f' + item.recordId" class="card">
            <view class="card-head">
              <text class="process">{{ item.processName || '未知工序' }}</text>
              <view class="head-tags">
                <!-- 全部 tab：区分记录来源（我报的=报工 / 我负责任务上的=负责） -->
                <uni-tag v-if="activeTab === 'all'" :type="isMine(item) ? 'warning' : 'primary'"
                  :text="isMine(item) ? '报工' : '负责'" size="small" />
                <uni-tag :type="statusTagType(item.status)" :text="statusText(item.status)" size="small" />
              </view>
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
  import { listFeedback, getMyWorkorders } from '@/api/mes/pro/feedback'
  import { hasPermission } from '@/utils/mobileMenu'
  import { useUserStore } from '@/store'

  const { proxy } = getCurrentInstance()
  const userStore = useUserStore()
  const windowHeight = uni.getSystemInfoSync().windowHeight
  const PAGE_SIZE = 10

  const ALL_TABS = [
    { key: 'workorder', label: '我的工单' },
    { key: 'prepare', label: '待确认', status: 'PREPARE' },
    { key: 'confirmed', label: '已确认', status: 'CONFIRMED' },
    { key: 'all', label: '全部', status: '' }
  ]
  const STATUS_MAP = { PREPARE: '待确认', CONFIRMED: '已确认', AUDITED: '已审核' }
  const STATUS_TAG_MAP = { PREPARE: 'warning', CONFIRMED: 'primary', AUDITED: 'success' }
  // 工单状态标签
  const WO_STATUS_MAP = { PREPARE: '待生产', PRODUCING: '生产中', COMPLETED: '已完成', CANCEL: '已取消', CLOSED: '已关闭' }
  const WO_STATUS_TAG_MAP = { PREPARE: 'default', PRODUCING: 'warning', COMPLETED: 'success', CANCEL: 'error', CLOSED: 'info' }

  // 工单 tab 看任务权限，报工记录 tab 看记录权限
  const WORKORDER_TAB = 'workorder'
  const tabs = computed(() => ALL_TABS.filter(tab => tab.key === WORKORDER_TAB
    ? hasPermission(userStore.permissions, 'mes:pro:task:list')
    : hasPermission(userStore.permissions, 'mes:pro:feedback:list')))

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
      workorder: '暂无进行中的工单',
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

  function woStatusText(status) {
    return WO_STATUS_MAP[status] || status || ''
  }

  function woStatusTagType(status) {
    return WO_STATUS_TAG_MAP[status] || 'default'
  }

  /** 工序 chip 状态分级：blocked(红)/done(绿)/doing(蓝)/todo(灰)/cancel(灰) */
  function chipLevel(task) {
    if (task.qcBlocked) return 'blocked'
    if (task.status === 'COMPLETED') return 'done'
    if (task.status === 'PRODUCING') return 'doing'
    if (task.status === 'CANCEL') return 'cancel'
    return 'todo'
  }

  /** 全部 tab 来源判定：报工人是本人 → 「报工」，否则是负责任务上的记录 → 「负责」 */
  function isMine(item) {
    return Number(item.userId) === Number(userStore.id)
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

    if (activeTab.value === WORKORDER_TAB) {
      // 我的工单：我派工/负责的生产中工单 + 全部工序（不分页，一次返回）
      request = getMyWorkorders().then(res => {
        const rows = res.data || []
        list.value = reset ? rows : list.value.concat(rows)
        finished.value = true
      }).catch(() => {})
      return request.finally(() => {
        loading.value = false
        refreshing.value = false
      })
    } else {
      // 个人报工记录：按报工人过滤（feedback.user_id = 当前用户）
      if (userStore.id) params.userId = userStore.id
      // 「全部」tab：合并我负责任务上的报工记录（task.leader_id = 当前用户），卡片按来源打「报工/负责」标签
      if (activeTab.value === 'all' && userStore.id) params.leaderId = userStore.id
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

  /** 工单卡片 → 工单详情页 */
  function goWorkorderDetail(entry) {
    proxy.$tab.navigateTo('/pages/mes/pro/workorder-detail?workorderId=' + entry.workorder.workorderId)
  }

  /** 工序 chip → 工序详情页 */
  function goTaskDetail(entry, task) {
    proxy.$tab.navigateTo('/pages/mes/pro/task-detail?workorderCode=' + encodeURIComponent(entry.workorder.workorderCode) + '&taskId=' + task.taskId)
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

    .head-tags {
      display: flex;
      align-items: center;
      gap: 10rpx;
    }
  }

  .wo-title {
    display: flex;
    align-items: center;
    gap: 12rpx;
    min-width: 0;
  }

  .wo-name {
    flex: 1;
    min-width: 0;
    font-size: 24rpx;
    color: #8a94a6;
    text-align: right;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .chip-scroll {
    white-space: nowrap;
    margin: 4rpx -8rpx 8rpx;
  }

  .chip-row {
    display: inline-flex;
    align-items: center;
    gap: 12rpx;
    padding: 8rpx;
  }

  .chip {
    position: relative;
    display: inline-flex;
    align-items: center;
    gap: 8rpx;
    padding: 10rpx 18rpx;
    border-radius: 26rpx;
    background: #f5f6f7;
    border: 1rpx solid #e8ebf0;
  }

  .chip-dot {
    width: 12rpx;
    height: 12rpx;
    border-radius: 50%;
    flex-shrink: 0;

    &.dot-doing { background: #3c96f3; }
    &.dot-done { background: #67c23a; }
    &.dot-todo { background: #c0c4cc; }
    &.dot-cancel { background: #d3d7de; }
    &.dot-blocked { background: #f56c6c; }
  }

  .chip-name {
    font-size: 24rpx;
    color: #1f2d3d;
    max-width: 220rpx;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;

    &.name-doing { color: #1d7bd6; font-weight: 600; }
    &.name-done { color: #4e9a2e; }
    &.name-blocked { color: #f56c6c; }
    &.name-todo, &.name-cancel { color: #8a94a6; }
  }

  .chip-OS {
    font-size: 20rpx;
    color: #b06f1f;
    background: #fdf3e3;
    border-radius: 8rpx;
    padding: 2rpx 8rpx;
  }

  .chip-badge {
    min-width: 30rpx;
    height: 30rpx;
    line-height: 30rpx;
    padding: 0 8rpx;
    border-radius: 16rpx;
    background: #f56c6c;
    color: #fff;
    font-size: 20rpx;
    text-align: center;
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
