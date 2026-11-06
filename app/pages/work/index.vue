<template>
  <view class="work-container">
    <!-- 轮播图 -->
    <view class="banner-wrap">
      <uni-swiper-dot class="uni-swiper-dot-box" :info="data" :current="current" field="content">
        <swiper class="swiper-box" :current="swiperDotIndex" circular autoplay @change="changeSwiper">
          <swiper-item v-for="(item, index) in data" :key="index">
            <view class="swiper-item" @click="clickBannerItem(item)">
              <image :src="item.image" mode="aspectFill" :draggable="false" />
            </view>
          </swiper-item>
        </swiper>
      </uni-swiper-dot>
    </view>

    <!-- 功能菜单：按角色权限过滤，无权限入口不展示 -->
    <view v-for="(group, gi) in menuGroups" :key="group.title" class="group-card">
      <view class="group-head">
        <view class="group-bar" :class="'bar-' + (gi % 4)"></view>
        <text class="group-title">{{ group.title }}</text>
        <text class="group-count">{{ group.items.length }}</text>
      </view>
      <view class="grid-body">
        <view
          v-for="item in group.items"
          :key="item.key"
          class="grid-item"
          @click="onMenuClick(item)"
        >
          <view class="icon-box" :style="{ background: iconBg(item.color) }">
            <uni-icons :type="menuIcon(item)" size="24" :color="item.color || '#409eff'"></uni-icons>
          </view>
          <text class="grid-text">{{ item.text }}</text>
        </view>
      </view>
    </view>

    <view v-if="menuGroups.length === 0" class="empty-box">
      <text class="empty-text">当前账号暂无可用功能，请联系管理员分配权限</text>
    </view>
  </view>
</template>

<script setup>
  import { ref, computed, getCurrentInstance } from "vue"
  import { useUserStore } from '@/store'
  // 显式引入 uni-ui 组件（绕过 HBuilderX 发行 H5 时 easycom 失效，导致组件未打包）
  import UniSwiperDot from '@/uni_modules/uni-swiper-dot/components/uni-swiper-dot/uni-swiper-dot.vue'
  import UniIcons from '@/uni_modules/uni-icons/components/uni-icons/uni-icons.vue'
  import { scanAndDispatch } from '@/utils/scanDispatch'
  import { MOBILE_MENU_GROUPS, filterMenuGroups, menuIcon, tintColor } from '@/utils/mobileMenu'

  const { proxy } = getCurrentInstance()
  const userStore = useUserStore()
  // 外协厂商员工（vendorId 非空）视角与我方员工不同
  const isVendor = computed(() => !!userStore.vendorId)
  // 手机菜单 = PC 菜单权限 + 移动端页面映射，角色在 PC 端勾选菜单即可生效
  const menuGroups = computed(() => filterMenuGroups(MOBILE_MENU_GROUPS, userStore.permissions, isVendor.value))

  const current = ref(0)
  const swiperDotIndex = ref(0)
  const data = ref([{ image: '/static/images/banner/banner01.jpg' }, { image: '/static/images/banner/banner02.jpg' }, { image: '/static/images/banner/banner03.jpg' }])

  /** 主色 → 12% 透明度的浅色底，用于图标圆形背景 */
  function iconBg(color) {
    return tintColor(color)
  }

  function clickBannerItem(item) {
    console.info(item)
  }

  function changeSwiper(e) {
    current.value = e.detail.current
  }

  function onMenuClick(item) {
    if (item.action === 'scan') {
      scanAndDispatch()
      return
    }
    const url = item.query ? `${item.path}?${item.query}` : item.path
    proxy.$tab.navigateTo(url)
  }
</script>

<style lang="scss" scoped>
  /* #ifndef APP-NVUE */
  page {
    display: flex;
    flex-direction: column;
    box-sizing: border-box;
    background-color: #f4f6f9;
    min-height: 100%;
    height: auto;
  }

  view {
    font-size: 14px;
    line-height: inherit;
  }
  /* #endif */

  .work-container {
    padding-bottom: 32rpx;
  }

  /* ---------- 轮播图 ---------- */
  .banner-wrap {
    width: 100%;
    overflow: hidden;
  }

  /* 组件根节点（uni-swiper-dot）也需撑满，避免宽屏下被媒体查询限制 */
  .uni-swiper-dot-box {
    display: block;
    width: 100%;
  }

  .swiper-box {
    width: 100%;
    height: 280rpx;
  }

  .swiper-item {
    /* #ifndef APP-NVUE */
    display: flex;
    /* #endif */
    width: 100%;
    height: 280rpx;

    image {
      width: 100%;
      height: 100%;
    }
  }

  /* ---------- 功能分组 ---------- */
  .group-card {
    margin: 24rpx 24rpx 0;
    padding: 24rpx 16rpx 8rpx;
    background: #fff;
    border-radius: 24rpx;
    box-shadow: 0 4rpx 16rpx rgba(60, 96, 150, 0.06);
  }

  .group-head {
    display: flex;
    align-items: center;
    padding: 0 12rpx 20rpx;
  }

  .group-bar {
    width: 6rpx;
    height: 28rpx;
    border-radius: 6rpx;
    background: #409eff;

    &.bar-1 { background: #67c23a; }
    &.bar-2 { background: #e6a23c; }
    &.bar-3 { background: #909399; }
  }

  .group-title {
    margin-left: 14rpx;
    font-size: 28rpx;
    font-weight: 600;
    color: #1f2d3d;
  }

  .group-count {
    margin-left: 10rpx;
    padding: 2rpx 12rpx;
    border-radius: 20rpx;
    font-size: 20rpx;
    color: #8a94a6;
    background: #f2f4f8;
  }

  .grid-body {
    display: flex;
    flex-wrap: wrap;
  }

  .grid-item {
    width: 25%;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 12rpx 0 20rpx;

    &:active {
      opacity: 0.6;
    }
  }

  .icon-box {
    width: 84rpx;
    height: 84rpx;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .grid-text {
    margin-top: 14rpx;
    max-width: 100%;
    font-size: 24rpx;
    color: #4a5568;
    text-align: center;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .empty-box {
    padding: 120rpx 40rpx;
    text-align: center;

    .empty-text {
      font-size: 26rpx;
      color: #999;
    }
  }
</style>
