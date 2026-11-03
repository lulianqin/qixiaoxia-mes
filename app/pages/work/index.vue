<template>
  <view class="work-container">
    <!-- 轮播图 -->
    <uni-swiper-dot class="uni-swiper-dot-box" :info="data" :current="current" field="content">
      <swiper class="swiper-box" :current="swiperDotIndex" @change="changeSwiper">
        <swiper-item v-for="(item, index) in data" :key="index">
          <view class="swiper-item" @click="clickBannerItem(item)">
            <image :src="item.image" mode="aspectFill" :draggable="false" />
          </view>
        </swiper-item>
      </swiper>
    </uni-swiper-dot>

    <!-- 功能菜单：按角色权限过滤，无权限入口不展示 -->
    <template v-for="group in menuGroups" :key="group.title">
      <uni-section :title="group.title" type="line"></uni-section>
      <view class="grid-body">
        <uni-grid :column="4" :showBorder="false">
          <uni-grid-item v-for="item in group.items" :key="item.key" @click="onMenuClick(item)">
            <view class="grid-item-box">
              <uni-icons :type="menuIcon(item)" size="30" :color="item.color || '#409eff'"></uni-icons>
              <text class="text">{{ item.text }}</text>
            </view>
          </uni-grid-item>
        </uni-grid>
      </view>
    </template>

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
  import UniSection from '@/components/uni-section/uni-section.vue'
  import UniGrid from '@/uni_modules/uni-grid/components/uni-grid/uni-grid.vue'
  import UniGridItem from '@/uni_modules/uni-grid/components/uni-grid-item/uni-grid-item.vue'
  import UniIcons from '@/uni_modules/uni-icons/components/uni-icons/uni-icons.vue'
  import { scanAndDispatch } from '@/utils/scanDispatch'
  import { MOBILE_MENU_GROUPS, filterMenuGroups, menuIcon } from '@/utils/mobileMenu'

  const { proxy } = getCurrentInstance()
  const userStore = useUserStore()
  // 外协厂商员工（vendorId 非空）视角与我方员工不同
  const isVendor = computed(() => !!userStore.vendorId)
  // 手机菜单 = PC 菜单权限 + 移动端页面映射，角色在 PC 端勾选菜单即可生效
  const menuGroups = computed(() => filterMenuGroups(MOBILE_MENU_GROUPS, userStore.permissions, isVendor.value))

  const current = ref(0)
  const swiperDotIndex = ref(0)
  const data = ref([{ image: '/static/images/banner/banner01.jpg' }, { image: '/static/images/banner/banner02.jpg' }, { image: '/static/images/banner/banner03.jpg' }])

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
    background-color: #fff;
    min-height: 100%;
    height: auto;
  }

  view {
    font-size: 14px;
    line-height: inherit;
  }
  /* #endif */

  .text {
    text-align: center;
    font-size: 26rpx;
    margin-top: 10rpx;
  }

  .grid-item-box {
    flex: 1;
    /* #ifndef APP-NVUE */
    display: flex;
    /* #endif */
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 15px 0;
  }

  .empty-box {
    padding: 120rpx 40rpx;
    text-align: center;

    .empty-text {
      font-size: 26rpx;
      color: #999;
    }
  }

  .uni-margin-wrap {
    width: 690rpx;
    width: 100%;
    ;
  }

  .swiper {
    height: 300rpx;
  }

  .swiper-box {
    height: 150px;
  }

  .swiper-item {
    /* #ifndef APP-NVUE */
    display: flex;
    /* #endif */
    flex-direction: column;
    justify-content: center;
    align-items: center;
    color: #fff;
    height: 300rpx;
    line-height: 300rpx;
  }

  @media screen and (min-width: 500px) {
    .uni-swiper-dot-box {
      width: 400px;
      /* #ifndef APP-NVUE */
      margin: 0 auto;
      /* #endif */
      margin-top: 8px;
    }

    .image {
      width: 100%;
    }
  }
</style>
