<template>
  <view class="container">
    <view v-if="loading" class="state-box"><text class="state-text">加载中...</text></view>

    <view v-else-if="!draft" class="state-box">
      <text class="state-text">{{ errorMsg || '未获取到领料草稿' }}</text>
      <button class="cu-btn bg-blue sm retry-btn" @click="loadDraft">重新加载</button>
    </view>

    <template v-else>
      <uni-section title="工单信息" type="line"></uni-section>
      <view class="form-card">
        <view class="info-line"><text class="code">{{ draft.workorderCode }}</text></view>
        <view class="info-line"><text class="meta">{{ draft.workorderName || '-' }}</text></view>
      </view>

      <uni-section title="领料信息" type="line"></uni-section>
      <view class="form-card">
        <picker mode="selector" :range="warehouseOptions" range-key="warehouseName" @change="onWarehouseChange">
          <view class="form-row">
            <text class="label">领料仓库 *</text>
            <view class="picker-value">
              <text :class="warehouse.warehouseId ? 'value' : 'placeholder'">{{ warehouse.warehouseName || '请选择领料仓库' }}</text>
              <uni-icons type="right" size="16" color="#999"></uni-icons>
            </view>
          </view>
        </picker>
        <view class="form-row">
          <text class="label">单据名称</text>
          <text class="value">{{ draft.issueName }}</text>
        </view>
      </view>

      <uni-section :title="'领料明细（' + lines.length + '）'" type="line"></uni-section>
      <view v-for="(line, idx) in lines" :key="idx" class="form-card line-item">
        <view class="line-head">
          <text class="line-name">{{ line.itemName }}</text>
          <text class="line-spec">{{ line.itemCode }}<text v-if="line.itemSpc"> · {{ line.itemSpc }}</text></text>
        </view>
        <view class="line-row">
          <text class="line-label">领料数量</text>
          <input class="qty-input" type="digit" v-model="line.quantityIssue" />
          <text class="unit">{{ line.unitName || line.unitOfMeasure || '-' }}</text>
        </view>
      </view>
      <view v-if="lines.length === 0" class="empty-hint"><text class="text-grey">工单 BOM 无可领料物料</text></view>

      <view class="footer-submit">
        <button class="cu-btn bg-blue lg" :disabled="submitting || lines.length === 0" @click="submit">
          {{ submitting ? '提交中...' : '保存领料单（草稿）' }}
        </button>
      </view>
    </template>
  </view>
</template>

<script setup>
import { ref, reactive, getCurrentInstance } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { buildIssueFromWorkorder, addIssue } from '@/api/mes/wm/issue'
import { listAllWarehouse } from '@/api/mes/wm/warehouse'

const { proxy } = getCurrentInstance()

const workorderId = ref(null)
const workorderCode = ref('')
const draft = ref(null)
const lines = ref([])
const loading = ref(false)
const submitting = ref(false)
const errorMsg = ref('')
const warehouseOptions = ref([])
const warehouse = reactive({ warehouseId: null, warehouseCode: '', warehouseName: '' })

async function loadDraft() {
  if (!workorderId.value) { errorMsg.value = '缺少工单ID，请从工单详情进入'; return }
  loading.value = true
  errorMsg.value = ''
  try {
    const res = await buildIssueFromWorkorder(workorderId.value)
    draft.value = res.data || null
    lines.value = ((draft.value && draft.value.lines) || []).map(l => ({ ...l }))
    if (draft.value && draft.value.warehouseId) {
      warehouse.warehouseId = draft.value.warehouseId
      warehouse.warehouseCode = draft.value.warehouseCode || ''
      warehouse.warehouseName = draft.value.warehouseName || ''
    }
    await loadWarehouses()
    // 仅一个仓库时自动选中，减少手工操作
    if (!warehouse.warehouseId && warehouseOptions.value.length === 1) pickWarehouse(warehouseOptions.value[0])
  } catch (e) {
    draft.value = null
  } finally {
    loading.value = false
  }
}

async function loadWarehouses() {
  if (warehouseOptions.value.length > 0) return
  try {
    const res = await listAllWarehouse()
    warehouseOptions.value = res.data || []
  } catch (e) { warehouseOptions.value = [] }
}

function onWarehouseChange(e) {
  const idx = Number(e.detail.value)
  pickWarehouse(warehouseOptions.value[idx])
}

function pickWarehouse(w) {
  warehouse.warehouseId = w ? w.warehouseId : null
  warehouse.warehouseCode = w ? w.warehouseCode : ''
  warehouse.warehouseName = w ? w.warehouseName : ''
}

function validLines() {
  return lines.value
    .filter(l => Number(l.quantityIssue) > 0)
    .map(l => ({ ...l, quantityIssue: Number(l.quantityIssue) }))
}

function submit() {
  if (!warehouse.warehouseId) { proxy.$modal.msgError('请选择领料仓库'); return }
  const payloadLines = validLines()
  if (payloadLines.length === 0) { proxy.$modal.msgError('请至少填写一行领料数量'); return }
  uni.showModal({
    title: '确认',
    content: `创建领料单草稿（${payloadLines.length} 行）？`,
    success: async (r) => {
      if (!r.confirm) return
      submitting.value = true
      try {
        const res = await addIssue({
          workorderId: draft.value.workorderId,
          workorderCode: draft.value.workorderCode,
          workorderName: draft.value.workorderName,
          issueType: draft.value.issueType,
          issueName: draft.value.issueName,
          issueDate: draft.value.issueDate,
          warehouseId: warehouse.warehouseId,
          warehouseCode: warehouse.warehouseCode,
          warehouseName: warehouse.warehouseName,
          lines: payloadLines
        })
        const issueId = res.data && res.data.issueId
        proxy.$modal.msgSuccess('领料单已创建')
        setTimeout(() => {
          if (issueId) {
            uni.redirectTo({ url: '/pages/mes/wm/issue/detail?issueId=' + issueId })
          } else {
            uni.navigateBack()
          }
        }, 300)
      } catch (e) {
        // request.js 已提示错误
      } finally {
        submitting.value = false
      }
    }
  })
}

onLoad((options) => {
  workorderId.value = (options && options.workorderId) || null
  workorderCode.value = decodeURIComponent((options && options.workorderCode) || '')
  loadDraft()
})
</script>

<style lang="scss" scoped>
page { background-color: #f5f6f7; min-height: 100%; }
.container { padding: 0 0 200rpx; }
.state-box { padding: 120rpx 40rpx; text-align: center; }
.state-text { font-size: 28rpx; color: #909399; }
.retry-btn { width: 240rpx; margin-top: 24rpx; }
.form-card { background: #fff; margin: 16rpx 24rpx; border-radius: 16rpx; padding: 16rpx 24rpx; }
.form-row { display: flex; justify-content: space-between; align-items: center; padding: 20rpx 0; border-bottom: 1px solid #f5f5f5; }
.form-row:last-child { border-bottom: none; }
.label, .value, .code { color: #333; font-size: 28rpx; }
.label { font-weight: 500; }
.code { font-size: 30rpx; font-weight: 600; }
.meta, .text-grey, .line-spec, .unit { font-size: 26rpx; color: #999; }
.meta { color: #666; }
.placeholder { color: #ccc; font-size: 28rpx; }
.picker-value { display: flex; align-items: center; gap: 8rpx; max-width: 70%; }
.info-line { display: flex; padding: 6rpx 0; }
.line-item { padding: 20rpx 24rpx; }
.line-head { display: flex; flex-direction: column; gap: 4rpx; margin-bottom: 12rpx; }
.line-name { font-size: 28rpx; font-weight: 600; color: #333; }
.line-spec { font-size: 24rpx; }
.line-row { display: flex; align-items: center; gap: 16rpx; }
.line-label { color: #666; font-size: 26rpx; width: 140rpx; }
.qty-input { flex: 1; font-size: 30rpx; text-align: right; }
.empty-hint { padding: 40rpx 0; text-align: center; }
.footer-submit { position: fixed; left: 0; right: 0; bottom: 0; background: #fff; padding: 20rpx 24rpx; border-top: 1rpx solid #eee; }
.cu-btn { border-radius: 12rpx; border: none; }
.cu-btn.lg { width: 100%; font-size: 30rpx; height: 88rpx; line-height: 88rpx; }
.cu-btn.sm { font-size: 28rpx; height: 72rpx; line-height: 72rpx; padding: 0 28rpx; }
.bg-blue { background: #007aff; color: #fff; }
.cu-btn[disabled] { opacity: 0.5; }
</style>
