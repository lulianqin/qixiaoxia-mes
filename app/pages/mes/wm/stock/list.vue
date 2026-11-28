<template>
  <view class="container">
    <!-- 搜索栏 -->
    <view class="search-bar">
      <uni-easyinput
        v-model="queryParams.itemName"
        placeholder="物料名称"
        :inputBorder="false"
        class="search-input"
        @confirm="handleQuery"
      />
      <uni-easyinput
        v-model="queryParams.batchCode"
        placeholder="批次号"
        :inputBorder="false"
        class="search-input"
        @confirm="handleQuery"
      />
      <button class="search-btn cu-btn bg-blue sm" @click="handleQuery">搜索</button>
    </view>

    <view class="filter-row">
      <text class="filter-tag" @click="resetQuery">重置</text>
      <text class="hint">点辅助数量可看每一卷/根/桶</text>
    </view>

    <view v-if="loading" class="loading-box">
      <uni-load-more status="loading" />
    </view>

    <view v-else-if="list.length === 0" class="empty-box">
      <text class="text-grey">暂无库存</text>
    </view>

    <view v-else class="list-box">
      <view v-for="item in list" :key="item.materialStockId" class="list-item">
        <view class="item-header">
          <text class="bold ellipsis">{{ item.itemName }}</text>
          <text class="code">{{ item.itemCode }}</text>
        </view>
        <view class="item-body">
          <view class="item-row">
            <text class="label">仓库</text>
            <text class="value">{{ item.warehouseName || '-' }}</text>
          </view>
          <view class="item-row">
            <text class="label">批次</text>
            <text class="value">{{ item.batchCode || '-' }}</text>
          </view>
          <view class="item-row" v-if="item.specification">
            <text class="label">规格</text>
            <text class="value">{{ item.specification }}</text>
          </view>
          <view class="item-row">
            <text class="label">库存数量</text>
            <text class="value bold">{{ fmt(item.quantityOnhand) }} {{ item.unitName || '' }}</text>
          </view>
          <view class="item-row">
            <text class="label">{{ item.unit2Name || '辅助数量' }}</text>
            <view class="value" @click="openInstances(item)">
              <text v-if="Number(item.quantityOnhand2) > 0" class="link">
                {{ fmt(item.quantityOnhand2) }} {{ item.unit2Name || '' }}
              </text>
              <text v-else class="text-grey">{{ fmt(item.quantityOnhand2) }} {{ item.unit2Name || '' }}</text>
              <uni-icons v-if="Number(item.quantityOnhand2) > 0" type="right" size="14" color="#007aff" />
            </view>
          </view>
        </view>
      </view>

      <uni-load-more :status="loadMoreStatus" />
    </view>

    <!-- 实物实例下钻 -->
    <uni-popup ref="instPopup" type="bottom" background-color="#fff">
      <view class="inst-panel">
        <view class="inst-head">
          <view>
            <text class="bold">{{ instRow?.itemName || '' }}</text>
            <text class="text-grey inst-sub">{{ instRow?.batchCode || '' }} · {{ instRow?.warehouseName || '' }}</text>
          </view>
          <uni-icons type="closeempty" size="20" color="#999" @click="closeInstances" />
        </view>

        <view class="inst-summary">
          <view class="summary-cell">
            <text class="summary-num">{{ fmt(instRow?.quantityOnhand2) }}</text>
            <text class="summary-label">库存账 {{ instRow?.unit2Name || '件' }}</text>
          </view>
          <view class="summary-cell">
            <text class="summary-num">{{ instRows.length }}</text>
            <text class="summary-label">在库 {{ instRow?.unit2Name || '件' }}</text>
          </view>
          <view class="summary-cell">
            <text class="summary-num">{{ fmt(instRemainTotal) }}</text>
            <text class="summary-label">剩余合计 {{ instRow?.unitName || '' }}</text>
          </view>
        </view>

        <scroll-view scroll-y class="inst-list">
          <view v-if="instLoading" class="loading-box"><uni-load-more status="loading" /></view>
          <view v-else-if="instRows.length === 0" class="empty-box">
            <text class="text-grey">该库存桶暂无实物实例</text>
          </view>
          <view v-for="ins in instRows" :key="ins.instanceId" class="inst-item">
            <view class="inst-row">
              <text class="bold">{{ ins.instanceCode }}</text>
              <uni-tag :type="instStatusTag(ins.status)" :text="instStatusText(ins.status)" size="small" />
            </view>
            <view class="inst-row">
              <text class="label">剩余</text>
              <text class="value bold">{{ fmt(ins.remainingQuantity) }} {{ ins.quantityUom || instRow?.unitName || '' }}</text>
            </view>
            <view class="inst-row">
              <text class="label">原始</text>
              <text class="value">{{ fmt(ins.originalQuantity) }} {{ ins.quantityUom || '' }}</text>
            </view>
            <view class="inst-row" v-if="attrText(ins)">
              <text class="label">规格</text>
              <text class="value">{{ attrText(ins) }}</text>
            </view>
          </view>
        </scroll-view>
      </view>
    </uni-popup>
  </view>
</template>

<script setup>
import { ref, reactive, computed, getCurrentInstance } from 'vue'
// 显式引入 uni-ui 组件（绕过 HBuilderX 发行 H5 时 easycom 失效）
import UniEasyInput from '@/uni_modules/uni-easyinput/components/uni-easyinput/uni-easyinput.vue'
import UniIcons from '@/uni_modules/uni-icons/components/uni-icons/uni-icons.vue'
import UniLoadMore from '@/uni_modules/uni-load-more/components/uni-load-more/uni-load-more.vue'
import UniTag from '@/uni_modules/uni-tag/components/uni-tag/uni-tag.vue'
import UniPopup from '@/uni_modules/uni-popup/components/uni-popup/uni-popup.vue'
import { onPullDownRefresh, onReachBottom } from '@dcloudio/uni-app'
import { listMaterialStock } from '@/api/mes/wm/stock'
import { listInstancesByStock } from '@/api/mes/wm/stock_instance'

const { proxy } = getCurrentInstance()
const list = ref([])
const loading = ref(false)
const loadMoreStatus = ref('more')
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  itemName: '',
  batchCode: ''
})

const instPopup = ref()
const instRow = ref(null)
const instRows = ref([])
const instLoading = ref(false)
const instRemainTotal = computed(() =>
  instRows.value.reduce((s, x) => s + Number(x.remainingQuantity || 0), 0))

function fmt(v) {
  if (v === null || v === undefined || v === '') return '0'
  return String(Number(v))
}

function handleQuery() {
  queryParams.pageNum = 1
  loadData()
}

function resetQuery() {
  queryParams.itemName = ''
  queryParams.batchCode = ''
  handleQuery()
}

function loadData() {
  loading.value = true
  listMaterialStock(queryParams).then(res => {
    list.value = res.rows || []
    loading.value = false
    loadMoreStatus.value = (res.rows && res.rows.length >= queryParams.pageSize) ? 'more' : 'noMore'
  }).catch(() => {
    loading.value = false
    loadMoreStatus.value = 'more'
  })
}

function openInstances(item) {
  if (!(Number(item.quantityOnhand2) > 0)) return
  instRow.value = item
  instRows.value = []
  instLoading.value = true
  instPopup.value?.open()
  listInstancesByStock(item.materialStockId).then(res => {
    instRows.value = res.data || []
    instLoading.value = false
  }).catch(() => {
    instLoading.value = false
  })
}

function closeInstances() {
  instPopup.value?.close()
  instRow.value = null
  instRows.value = []
}

function instStatusText(s) {
  const map = {
    IN_STOCK: '在库', OUTSOURCED: '外协中', ISSUED: '已领用',
    PARTIAL: '部分领用', CONSUMED: '已用完', SCRAPPED: '已报废'
  }
  return map[s] || s || '-'
}

function instStatusTag(s) {
  if (s === 'IN_STOCK') return 'success'
  if (s === 'PARTIAL') return 'warning'
  if (s === 'SCRAPPED' || s === 'CONSUMED') return 'error'
  return 'default'
}

/** 实例扩展属性里的规格（分切门幅/克重等）转成一串文本 */
function attrText(ins) {
  const ext = ins.extAttrs
  if (!ext) return ''
  let obj = ext
  if (typeof ext === 'string') {
    try { obj = JSON.parse(ext) } catch (e) { return '' }
  }
  const parts = []
  if (obj.INST_PAPER_WIDTH) parts.push('门幅' + obj.INST_PAPER_WIDTH)
  if (obj.INST_PAPER_WEIGHT) parts.push(obj.INST_PAPER_WEIGHT + 'g')
  if (obj.INST_LENGTH) parts.push('长度' + obj.INST_LENGTH)
  return parts.join(' / ')
}

onPullDownRefresh(() => {
  queryParams.pageNum = 1
  loadData()
  uni.stopPullDownRefresh()
})

onReachBottom(() => {
  if (loadMoreStatus.value === 'noMore' || loading.value) return
  queryParams.pageNum++
  loadMoreStatus.value = 'loading'
  listMaterialStock(queryParams).then(res => {
    const rows = res.rows || []
    list.value = list.value.concat(rows)
    loadMoreStatus.value = rows.length >= queryParams.pageSize ? 'more' : 'noMore'
  }).catch(() => {
    queryParams.pageNum--
    loadMoreStatus.value = 'more'
  })
})

loadData()
</script>

<style lang="scss" scoped>
page { background-color: #f5f6f7; min-height: 100%; }

.search-bar {
  display: flex; align-items: center;
  padding: 20rpx 24rpx; gap: 16rpx;
  background: #fff;
}
.search-input { flex: 1; }
.search-btn { margin: 0; font-size: 26rpx; height: 64rpx; line-height: 64rpx; }

.filter-row {
  display: flex; align-items: center; justify-content: space-between;
  padding: 12rpx 24rpx 20rpx; background: #fff;
  border-bottom: 1px solid #f0f0f0;
}
.filter-tag {
  padding: 8rpx 24rpx; border-radius: 32rpx;
  font-size: 24rpx; color: #666; background: #f5f5f5;
}
.hint { font-size: 22rpx; color: #bbb; }

.loading-box, .empty-box {
  display: flex; justify-content: center; padding: 80rpx 0;
}
.empty-box text { font-size: 26rpx; }

.list-box { padding: 16rpx 24rpx; }
.list-item {
  background: #fff; border-radius: 16rpx;
  padding: 24rpx; margin-bottom: 20rpx;
}
.item-header {
  display: flex; justify-content: space-between; align-items: center;
  padding-bottom: 16rpx; border-bottom: 1px solid #f5f5f5;
}
.item-header .bold { flex: 1; font-size: 28rpx; }
.ellipsis { overflow: hidden; white-space: nowrap; text-overflow: ellipsis; }
.code { font-size: 22rpx; color: #999; margin-left: 12rpx; }
.item-body { padding-top: 12rpx; }
.item-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: 6rpx 0;
}
.label { color: #999; font-size: 26rpx; }
.value { font-size: 26rpx; color: #333; }
.bold { font-weight: 600; }
.link { color: #007aff; }
.text-grey { color: #999; }

/* 实例下钻 */
.inst-panel {
  max-height: 80vh; display: flex; flex-direction: column;
  padding: 24rpx;
}
.inst-head {
  display: flex; justify-content: space-between; align-items: flex-start;
  padding-bottom: 20rpx; border-bottom: 1px solid #f0f0f0;
}
.inst-head .bold { font-size: 30rpx; }
.inst-sub { font-size: 22rpx; margin-left: 12rpx; }
.inst-summary {
  display: flex; padding: 20rpx 0; gap: 12rpx;
}
.summary-cell {
  flex: 1; background: #f7f8fa; border-radius: 12rpx;
  padding: 16rpx; display: flex; flex-direction: column; align-items: center;
}
.summary-num { font-size: 32rpx; font-weight: 600; color: #333; }
.summary-label { font-size: 22rpx; color: #999; margin-top: 6rpx; }
.inst-list { flex: 1; max-height: 50vh; }
.inst-item {
  background: #fafafa; border-radius: 12rpx;
  padding: 18rpx; margin-bottom: 14rpx;
}
.inst-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: 4rpx 0;
}
</style>
