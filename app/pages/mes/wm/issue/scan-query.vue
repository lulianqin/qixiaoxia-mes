<template>
  <view class="container">
    <view class="tip-card">
      <text class="tip-text">扫描物料条码，查询该物料的实时库存</text>
    </view>

    <!-- 扫码区 -->
    <view class="scan-bar">
      <view class="scan-input" @click="scanCode">
        <uni-icons type="scan" size="28" color="#409eff" />
        <text class="scan-tip">{{ itemCode || '点击扫码查询库存' }}</text>
      </view>
      <button class="btn-scan" @click="scanCode">扫码</button>
    </view>

    <!-- 手动输入 -->
    <view class="manual-row">
      <uni-easyinput v-model="itemCode" placeholder="或输入物料编码 / 粘贴二维码内容" clearable @confirm="onManualQuery" />
      <button class="btn-search" @click="onManualQuery">查询</button>
    </view>

    <!-- 物料信息 -->
    <view v-if="itemInfo" class="info-card">
      <view class="card-top">
        <text class="code">{{ itemInfo.itemCode }}</text>
        <text class="unit">{{ itemInfo.unitOfMeasure || '' }}</text>
      </view>
      <text class="name">{{ itemInfo.itemName }}</text>
      <view v-if="itemInfo.specification" class="sub">规格：{{ itemInfo.specification }}</view>
    </view>

    <!-- 实物实例信息（扫实例码 ROLL/根/桶） -->
    <view v-if="instanceInfo" class="info-card">
      <view class="card-top">
        <text class="code">{{ instanceInfo.instanceCode }}</text>
        <text class="unit">{{ instanceStatusText(instanceInfo.status) }}</text>
      </view>
      <text class="name">{{ instanceInfo.itemName || '-' }}</text>
      <view class="sub">仓库：{{ instanceInfo.warehouseName || '-' }}</view>
      <view class="sub">批次：{{ instanceInfo.batchCode || '无批次' }}</view>
      <view class="sub">入库数量：{{ fmtQty(instanceInfo.originalQuantity) }} {{ instanceInfo.quantityUom || '' }}</view>
      <view class="sub">
        剩余数量：<text class="roll-qty">{{ fmtQty(instanceInfo.remainingQuantity) }} {{ instanceInfo.quantityUom || '' }}</text>
      </view>
      <view v-for="(v, k) in (instanceInfo.extAttrs || {})" :key="k" class="sub">{{ k }}：{{ v }}</view>
    </view>

    <!-- 库存列表 -->
    <view v-if="stockList.length > 0" class="section-title">库存明细（{{ stockList.length }} 条）</view>
    <view v-for="(s, idx) in stockList" :key="idx" class="stock-card">
      <view class="stock-row"><text class="label">仓库</text><text class="value">{{ s.warehouseCode || '-' }}</text></view>
      <view class="stock-row"><text class="label">批次</text><text class="value">{{ s.batchCode || '无批次' }}</text></view>
      <view class="stock-row">
        <text class="label">现有量</text>
        <text class="qty onhand">{{ s.quantityOnhand || 0 }}</text>
      </view>
      <view class="stock-row">
        <text class="label">可用量</text>
        <text class="qty avail">{{ s.quantityAvailable || 0 }}</text>
        <text class="qty-tip">（已扣除预占）</text>
      </view>
    </view>
    <view v-if="queried && stockList.length === 0" class="empty-tip">该物料暂无库存记录</view>
  </view>
</template>

<script setup>
import { ref, getCurrentInstance } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getItemStock, getStockByBatchCode } from '@/api/mes/wm/issue'
import { scanInstance } from '@/api/mes/wm/stock_instance'
import { parseQrPayload } from '@/utils/qrPayload'
// 显式引入 uni-ui 组件（绕过 HBuilderX 发行 H5 时 easycom 失效）
import UniEasyInput from '@/uni_modules/uni-easyinput/components/uni-easyinput/uni-easyinput.vue'
import UniIcons from '@/uni_modules/uni-icons/components/uni-icons/uni-icons.vue'

const { proxy } = getCurrentInstance()
const itemCode = ref('')
const itemInfo = ref(null)
const instanceInfo = ref(null)
const stockList = ref([])
const queried = ref(false)

// 统一扫码分发带参进入：MAT → batchCode，ROLL → rollCode
onLoad((options) => {
  if (options && options.batchCode) {
    queryByBatch(options.batchCode)
  } else if (options && options.rollCode) {
    queryInstance(options.rollCode)
  }
})

// 统一编码入口：扫码/手输/粘贴（识别 QXX|TYPE|CODE 载荷，裸码当物料编码查询）
function handleCode(code) {
  const payload = parseQrPayload(code)
  if (payload && payload.type === 'MAT') {
    queryByBatch(payload.code)
  } else if (payload && payload.type === 'ROLL') {
    queryInstance(payload.code)
  } else {
    itemCode.value = code
    queryStock()
  }
}

function scanCode() {
  // #ifdef H5
  uni.navigateTo({
    url: '/pages/mes/pro/scan?callback=1',
    events: { scanResult: (code) => handleCode(code) }
  })
  // #endif
  // #ifndef H5
  uni.scanCode({
    onlyFromCamera: false,
    scanType: ['barCode', 'qrCode'],
    success: (res) => { handleCode(res.result) },
    fail: () => { proxy.$modal.msgError('扫码取消或失败') }
  })
  // #endif
}

// 手动输入/粘贴 → 统一走 handleCode（H5 无相机扫码，粘贴二维码文本是主要入口）
function onManualQuery() {
  const code = (itemCode.value || '').trim()
  if (!code) { proxy.$modal.msgError('请输入或扫描物料编码'); return }
  handleCode(code)
}

async function queryStock() {
  if (!itemCode.value) { proxy.$modal.msgError('请输入或扫描物料编码'); return }
  queried.value = true
  instanceInfo.value = null
  try {
    const res = await getItemStock(itemCode.value)
    const rows = res.rows || []
    stockList.value = rows
    // 取第一条作为物料信息展示
    if (rows.length > 0) {
      itemInfo.value = {
        itemCode: rows[0].itemCode,
        itemName: rows[0].itemName,
        specification: rows[0].specification,
        unitOfMeasure: rows[0].unitOfMeasure
      }
    } else {
      itemInfo.value = null
    }
  } catch (e) {}
}

// 按批次码查库存（MAT 码）：返回该批次的库存行
async function queryByBatch(batchCode) {
  queried.value = true
  instanceInfo.value = null
  itemInfo.value = null
  stockList.value = []
  try {
    const res = await getStockByBatchCode(batchCode)
    const rows = res.data || []
    stockList.value = rows
    if (rows.length > 0) {
      itemCode.value = rows[0].itemCode || itemCode.value
      itemInfo.value = {
        itemCode: rows[0].itemCode,
        itemName: rows[0].itemName,
        specification: rows[0].specification,
        unitOfMeasure: rows[0].unitOfMeasure
      }
    }
  } catch (e) {}
}

// 按实物实例码查实例详情（一卷/一根/一桶）：单件卡片，不走库存列表
async function queryInstance(instanceCode) {
  queried.value = false
  instanceInfo.value = null
  itemInfo.value = null
  stockList.value = []
  try {
    const res = await scanInstance(instanceCode)
    instanceInfo.value = res.data || null
    if (!instanceInfo.value) { proxy.$modal.msgError('未查到该实物实例') }
  } catch (e) {}
}

function instanceStatusText(s) {
  const map = { IN_STOCK: '在库', PARTIAL: '部分领用', CONSUMED: '已用完', RETURNED: '已退回', SCRAPPED: '已报废', OUTSOURCED: '外协中' }
  return map[s] || s || ''
}

function fmtQty(v) {
  if (v === null || v === undefined || v === '') return '-'
  const n = Number(v)
  return Number.isNaN(n) ? String(v) : n.toFixed(2).replace(/\.00$/, '')
}
</script>

<style lang="scss" scoped>
.container { min-height: 100vh; background: #f5f6f7; padding-bottom: 40rpx; }
.tip-card {
  background: #ecf5ff; margin: 16rpx; padding: 20rpx 24rpx; border-radius: 12rpx;
  .tip-text { font-size: 26rpx; color: #409eff; }
}
.scan-bar {
  display: flex; gap: 16rpx; padding: 0 16rpx; margin-bottom: 16rpx;
  .scan-input {
    flex: 1; background: #fff; border-radius: 8rpx; padding: 20rpx;
    display: flex; align-items: center; gap: 12rpx;
    .scan-tip { font-size: 28rpx; color: #909399; margin-left: 8rpx; }
  }
  .btn-scan {
    background: #409eff; color: #fff; border-radius: 8rpx; font-size: 28rpx; padding: 0 32rpx; border: none;
    &::after { border: none; }
  }
}
.manual-row {
  display: flex; gap: 16rpx; padding: 0 16rpx; margin-bottom: 16rpx; align-items: center;
  .btn-search {
    background: #67c23a; color: #fff; border-radius: 8rpx; font-size: 28rpx; padding: 0 32rpx; border: none;
    &::after { border: none; }
  }
}
.info-card {
  background: #fff; border-radius: 12rpx; padding: 24rpx; margin: 0 16rpx 16rpx;
  .card-top { display: flex; justify-content: space-between; margin-bottom: 8rpx;
    .code { font-size: 32rpx; font-weight: bold; color: #303133; }
    .unit { font-size: 24rpx; color: #909399; }
  }
  .name { font-size: 28rpx; color: #606266; display: block; }
  .sub { font-size: 24rpx; color: #909399; display: block; margin-top: 8rpx; }
  .roll-qty { font-size: 28rpx; font-weight: bold; color: #409eff; }
}
.section-title { font-size: 28rpx; font-weight: bold; color: #303133; padding: 16rpx 24rpx; }
.stock-card {
  background: #fff; border-radius: 12rpx; padding: 24rpx; margin: 0 16rpx 16rpx;
  .stock-row { display: flex; align-items: center; font-size: 28rpx; margin-bottom: 12rpx;
    .label { color: #909399; width: 140rpx; flex-shrink: 0; }
    .value { color: #303133; flex: 1; }
    .qty { font-size: 32rpx; font-weight: bold; }
    .qty.onhand { color: #409eff; }
    .qty.avail { color: #67c23a; }
    .qty-tip { font-size: 22rpx; color: #c0c4cc; margin-left: 8rpx; }
  }
}
.empty-tip { text-align: center; color: #909399; font-size: 26rpx; padding: 60rpx 0; }
</style>
