<template>
  <view class="home-page" :style="{ height: windowHeight + 'px' }">
    <!-- 顶部标题 + 工单状态 tab -->
    <view class="home-header">
      <view class="header-row">
        <view class="header-text">
          <text class="hello">你好，{{ userName || '同事' }}</text>
          <text class="hello-sub">{{ summary.workorderCount }} 张工单 · {{ summary.pendingTaskCount }} 项任务</text>
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
      <view v-if="loading && list.length === 0" class="state-box">
        <uni-load-more status="loading" />
      </view>

      <view v-else-if="list.length === 0" class="state-box">
        <text class="empty-text">{{ emptyText }}</text>
      </view>

      <view v-else class="list-box">
        <view v-for="wo in list" :key="wo.workorderId" class="card" @click="goWorkorderDetail(wo)">
          <view class="card-head">
            <view class="wo-title">
              <text class="wo-code">{{ wo.workorderCode }}</text>
              <uni-tag :type="woStatusTagType(wo.status)" :text="woStatusText(wo.status)" size="small" />
            </view>
            <text class="pending-text">{{ wo.pendingTaskCount || 0 }} 项待处理</text>
          </view>

          <text class="wo-product">{{ wo.productName || wo.workorderName || '-' }}</text>

          <view class="process-row">
            <text class="process-label">当前工序</text>
            <text class="process-name">{{ processNameText(wo) }}</text>
          </view>

          <view class="meta-row">
            <text class="meta-item">负责人：{{ wo.ownerName || '未指定' }}</text>
            <text class="meta-item">需求日期：{{ formatDay(wo.requestDate) }}</text>
          </view>

          <view class="card-foot">
            <view class="qty">
              <text class="qty-label">排产</text>
              <text class="qty-value">{{ num(wo.quantity) }}</text>
              <text class="qty-label">已产</text>
              <text class="qty-value">{{ num(wo.quantityProduced) }}</text>
            </view>
            <text class="due-text" :class="overdueClass(wo)">{{ overdueText(wo) }}</text>
          </view>

          <view class="action-row">
            <view
              v-if="visibleAction(wo)"
              class="action-btn"
              :class="'action-' + wo.actionKey"
              @click.stop="goAction(wo)"
            >
              {{ wo.actionLabel }}
            </view>
            <view v-else class="action-placeholder"></view>
            <text class="go-text" @click.stop="goWorkorderDetail(wo)">查看任务 ›</text>
          </view>
        </view>

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
  import { getMobileWorkorders, getMobileHomeSummary } from '@/api/mes/pro/feedback'
  import { startTask } from '@/api/mes/pro/task'
  import { hasPermission } from '@/utils/mobileMenu'
  import { useUserStore } from '@/store'

  const { proxy } = getCurrentInstance()
  const userStore = useUserStore()
  const windowHeight = uni.getSystemInfoSync().windowHeight
  const PAGE_SIZE = 10

  const ALL_TABS = [
    { key: 'prepare', label: '待生产', status: 'PREPARE' },
    { key: 'producing', label: '生产中', status: 'PRODUCING' },
    { key: 'completed', label: '已完成', status: 'COMPLETED' },
    { key: 'all', label: '全部', status: '' }
  ]
  // 工单状态标签
  const WO_STATUS_MAP = { PREPARE: '待生产', PRODUCING: '生产中', COMPLETED: '已完成', CANCEL: '已取消', CLOSED: '已关闭' }
  const WO_STATUS_TAG_MAP = { PREPARE: 'default', PRODUCING: 'warning', COMPLETED: 'success', CANCEL: 'error', CLOSED: 'info' }

  const tabs = computed(() => (hasPermission(userStore.permissions, 'mes:pro:task:list') ? ALL_TABS : []))

  const userName = computed(() => userStore.name)
  const activeTab = ref('')
  const list = ref([])
  const summary = ref({ workorderCount: 0, pendingTaskCount: 0 })
  const loading = ref(false)
  const refreshing = ref(false)
  const finished = ref(false)
  const pageNum = ref(1)

  const currentTab = computed(() => ALL_TABS.find(tab => tab.key === activeTab.value))

  const emptyText = computed(() => {
    const map = {
      prepare: '暂无待生产的工单',
      producing: '暂无生产中的工单',
      completed: '暂无已完成的工单',
      all: '暂无工单'
    }
    return map[activeTab.value] || '暂无数据'
  })

  function num(v) {
    const n = Number(v)
    return isNaN(n) ? 0 : n
  }

  function woStatusText(status) {
    return WO_STATUS_MAP[status] || status || ''
  }

  function woStatusTagType(status) {
    return WO_STATUS_TAG_MAP[status] || 'default'
  }

  /** 当前工序：已完成工单显示"已完成"，未排产显示"未排产" */
  function processNameText(wo) {
    if (wo.currentProcessName) return wo.currentProcessName
    return wo.status === 'COMPLETED' ? '已完成' : '未排产'
  }

  /** yyyy-MM-dd HH:mm:ss → yyyy-MM-dd */
  function formatDay(t) {
    return t ? t.substring(0, 10) : '-'
  }

  /** 逾期情况：未设需求日期 / 逾期 N 天 / 正常 */
  function overdueText(wo) {
    if (!wo.requestDate) return '未设交期'
    if (Number(wo.overdueDays) > 0) return '逾期 ' + wo.overdueDays + ' 天'
    if (wo.status === 'COMPLETED') return '已完成'
    return '正常'
  }

  function overdueClass(wo) {
    if (!wo.requestDate) return 'due-none'
    return Number(wo.overdueDays) > 0 ? 'due-overdue' : 'due-normal'
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
    if (currentTab.value && currentTab.value.status) {
      params.status = currentTab.value.status
    }
    getMobileWorkorders(params).then(res => {
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
    loadSummary()
    loadData(true)
  }

  function onRefresh() {
    refreshing.value = true
    loadSummary()
    loadData(true)
  }

  function loadMore() {
    if (loading.value || finished.value) return
    pageNum.value++
    loadData(false)
  }

  /** 顶部汇总：当前 tab 的工单数 + 待办任务数 */
  function loadSummary() {
    const params = {}
    if (currentTab.value && currentTab.value.status) {
      params.status = currentTab.value.status
    }
    getMobileHomeSummary(params).then(res => {
      summary.value = res.data || { workorderCount: 0, pendingTaskCount: 0 }
    }).catch(() => {
      summary.value = { workorderCount: 0, pendingTaskCount: 0 }
    })
  }

  /** 工单卡片 → 工单详情页 */
  function goWorkorderDetail(wo) {
    proxy.$tab.navigateTo('/pages/mes/pro/workorder-detail?workorderId=' + wo.workorderId)
  }

  /** 当前工序按钮是否展示（按登录人权限过滤） */
  function visibleAction(wo) {
    return !!wo.actionKey && hasPermission(userStore.permissions, wo.actionPerm)
  }

  /** 当前工序主操作 → 对应录入页 */
  function goAction(wo) {
    if (wo.actionKey === 'start') {
      uni.showModal({
        title: '确认开工',
        content: '确认开始工序「' + (wo.currentProcessName || '') + '」？',
        success: res => {
          if (!res.confirm) return
          startTask(wo.currentTaskId).then(() => {
            proxy.$modal.msgSuccess('已开工')
            loadSummary()
            loadData(true)
          }).catch(() => {})
        }
      })
      return
    }
    let url = ''
    if (wo.actionKey === 'report') {
      url = '/pages/mes/pro/report?workorderCode=' + encodeURIComponent(wo.workorderCode || '')
      if (wo.currentTaskId) url += '&taskId=' + wo.currentTaskId
    } else if (wo.actionKey === 'outsource_execute') {
      url = '/pages/mes/wm/outsource-execute?orderId=' + wo.actionOutsourceOrderId
    } else if (wo.actionKey === 'outsource_result' || wo.actionKey === 'outsource_ship') {
      url = '/pages/mes/wm/outsource-result?orderId=' + wo.actionOutsourceOrderId
    } else if (wo.actionKey === 'outsource_receive') {
      url = '/pages/mes/wm/outsource-receive?orderId=' + wo.actionOutsourceOrderId
    }
    if (url) proxy.$tab.navigateTo(url)
  }

  function goWorkbench() {
    proxy.$tab.switchTab('/pages/work/index')
  }

  onShow(() => {
    if (!activeTab.value) {
      activeTab.value = (tabs.value[0] && tabs.value[0].key) || ''
    }
    loadSummary()
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

  .wo-title {
    display: flex;
    align-items: center;
    gap: 12rpx;
    min-width: 0;
  }

  .wo-code {
    font-size: 30rpx;
    font-weight: 600;
    color: #1f2d3d;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .wo-product {
    display: block;
    font-size: 30rpx;
    font-weight: 600;
    color: #1f2d3d;
    margin-bottom: 14rpx;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .pending-text {
    font-size: 24rpx;
    color: #e6a23c;
    flex-shrink: 0;
  }

  .process-row {
    display: flex;
    align-items: center;
    gap: 16rpx;
    margin-bottom: 12rpx;
  }

  .process-label {
    font-size: 24rpx;
    color: #8a94a6;
  }

  .process-name {
    font-size: 26rpx;
    color: #3c96f3;
    font-weight: 600;
  }

  .meta-row {
    display: flex;
    align-items: center;
    gap: 24rpx;
    margin-bottom: 16rpx;
  }

  .meta-item {
    font-size: 24rpx;
    color: #8a94a6;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
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
  }

  .due-text {
    font-size: 24rpx;

    &.due-overdue {
      color: #f56c6c;
      font-weight: 600;
    }

    &.due-normal {
      color: #67c23a;
    }

    &.due-none {
      color: #8a94a6;
    }
  }

  .go-text {
    font-size: 26rpx;
    color: #3c96f3;
    font-weight: 600;
    flex-shrink: 0;
  }

  .action-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 18rpx;
    padding-top: 18rpx;
    border-top: 1rpx solid #f2f4f7;
  }

  .action-btn {
    padding: 10rpx 24rpx;
    border-radius: 8rpx;
    font-size: 24rpx;
    font-weight: 600;
    line-height: 1.4;
  }

  .action-report {
    color: #3c96f3;
    background: #eaf3ff;
  }

  .action-start {
    color: #67c23a;
    background: #f0f9eb;
  }

  .action-outsource_execute,
  .action-outsource_result,
  .action-outsource_ship {
    color: #e6a23c;
    background: #fdf6ec;
  }

  .action-outsource_receive {
    color: #67c23a;
    background: #f0f9eb;
  }

  .action-placeholder {
    width: 1rpx;
  }
</style>
