<template>
  <view class="container">
    <view v-if="loading" class="state-box"><text class="state-text">加载中...</text></view>

    <template v-else>
      <uni-section title="工单信息" type="line"></uni-section>
      <view class="form-card">
        <view class="info-line"><text class="code">{{ workorderCode || draft?.workorderCode || '-' }}</text></view>
        <view class="info-line"><text class="meta">{{ draft?.workorderName || '-' }}</text></view>
      </view>

      <uni-section :title="'可退料领料单（' + issueOptions.length + '）'" type="line"></uni-section>
      <view v-if="issueOptions.length === 0" class="form-card">
        <view class="empty-hint"><text class="text-grey">该工单暂无可退料的领料单（需已发料且物料有剩余）</text></view>
      </view>
      <view
        v-for="it in issueOptions"
        :key="it.issueId"
        :class="['form-card', 'issue-card', selectedIssueId === it.issueId ? 'selected' : '']"
        @click="selectIssue(it)"
      >
        <view class="issue-head">
          <text class="line-name">{{ it.issueCode }}</text>
          <uni-icons :type="selectedIssueId === it.issueId ? 'checkbox-filled' : 'circle'" size="22" :color="selectedIssueId === it.issueId ? '#007aff' : '#ccc'"></uni-icons>
        </view>
        <view class="info-line"><text class="meta">已发 {{ it.quantityIssuedTotal || 0 }} · 可退 {{ it.returnableQty || 0 }}</text></view>
      </view>

      <template v-if="draft">
        <uni-section :title="'退料明细（' + lines.length + '）'" type="line"></uni-section>
        <view v-for="(line, idx) in lines" :key="idx" class="form-card line-item">
          <view class="line-head">
            <text class="line-name">{{ line.itemName }}</text>
            <text class="line-spec">{{ line.itemCode }} · 可退上限 {{ line.quantityRtMax }}</text>
          </view>
          <view class="line-row">
            <text class="line-label">退料数量</text>
            <input class="qty-input" type="digit" v-model="line.quantityRt" />
            <text class="unit">{{ line.unitName || line.unitOfMeasure || '-' }}</text>
          </view>
        </view>
        <view class="tip-card"><text class="text-grey">提交后生成退料草稿，需在「退料单」中执行退库（RQC 检验通过后方可执行）。</text></view>

        <view class="footer-submit">
          <button class="cu-btn bg-blue lg" :disabled="submitting" @click="submit">
            {{ submitting ? '提交中...' : '保存退料单（草稿）' }}
          </button>
        </view>
      </template>
    </template>
  </view>
</template>

<script setup>
import { ref, getCurrentInstance } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { returnablePreview, buildRtIssueFromIssue, addRtIssue } from '@/api/mes/wm/rtissue'

const { proxy } = getCurrentInstance()

const workorderId = ref(null)
const workorderCode = ref('')
const issueOptions = ref([])
const selectedIssueId = ref(null)
const draft = ref(null)
const lines = ref([])
const loading = ref(false)
const submitting = ref(false)

async function loadOptions() {
  if (!workorderId.value) return
  loading.value = true
  try {
    const res = await returnablePreview({ workorderId: workorderId.value, pageNum: 1, pageSize: 20 })
    issueOptions.value = res.rows || []
    if (issueOptions.value.length === 1) await selectIssue(issueOptions.value[0])
  } catch (e) {
    issueOptions.value = []
  } finally {
    loading.value = false
  }
}

async function selectIssue(it) {
  if (selectedIssueId.value === it.issueId) return
  selectedIssueId.value = it.issueId
  draft.value = null
  lines.value = []
  try {
    const res = await buildRtIssueFromIssue(it.issueId)
    draft.value = res.data || null
    lines.value = ((draft.value && draft.value.lines) || []).map(l => ({ ...l, quantityRtMax: Number(l.quantityRt) }))
    if (!workorderCode.value && draft.value) workorderCode.value = draft.value.workorderCode || ''
  } catch (e) {
    selectedIssueId.value = null
  }
}

function validLines() {
  return lines.value
    .filter(l => Number(l.quantityRt) > 0 && Number(l.quantityRt) <= Number(l.quantityRtMax))
    .map(l => {
      const { quantityRtMax, ...rest } = l
      return { ...rest, quantityRt: Number(l.quantityRt) }
    })
}

function submit() {
  const invalid = lines.value.some(l => Number(l.quantityRt) > Number(l.quantityRtMax))
  if (invalid) { proxy.$modal.msgError('退料数量不能超过可退上限'); return }
  const payloadLines = validLines()
  if (payloadLines.length === 0) { proxy.$modal.msgError('请至少填写一行退料数量'); return }
  uni.showModal({
    title: '确认',
    content: `创建退料单草稿（${payloadLines.length} 行）？`,
    success: async (r) => {
      if (!r.confirm) return
      submitting.value = true
      try {
        await addRtIssue({
          issueId: draft.value.issueId,
          issueCode: draft.value.issueCode,
          workorderId: draft.value.workorderId,
          workorderCode: draft.value.workorderCode,
          workorderName: draft.value.workorderName,
          workstationId: draft.value.workstationId,
          workstationCode: draft.value.workstationCode,
          workstationName: draft.value.workstationName,
          warehouseId: draft.value.warehouseId,
          warehouseCode: draft.value.warehouseCode,
          warehouseName: draft.value.warehouseName,
          rtDate: draft.value.rtDate,
          rtName: draft.value.rtName,
          lines: payloadLines
        })
        proxy.$modal.msgSuccess('退料单已创建')
        setTimeout(() => uni.navigateBack(), 300)
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
  if (!workorderId.value) {
    proxy.$modal.msgError('缺少工单ID，请从工单详情进入')
    return
  }
  loadOptions()
})
</script>

<style lang="scss" scoped>
page { background-color: #f5f6f7; min-height: 100%; }
.container { padding: 0 0 200rpx; }
.state-box { padding: 120rpx 40rpx; text-align: center; }
.state-text { font-size: 28rpx; color: #909399; }
.form-card { background: #fff; margin: 16rpx 24rpx; border-radius: 16rpx; padding: 16rpx 24rpx; }
.issue-card { transition: box-shadow .2s ease; }
.issue-card.selected { box-shadow: 0 0 0 4rpx rgba(0, 122, 255, .25); }
.issue-head { display: flex; justify-content: space-between; align-items: center; padding: 8rpx 0; }
.code { font-size: 30rpx; font-weight: 600; color: #333; }
.meta, .text-grey, .line-spec, .unit { font-size: 26rpx; color: #999; }
.meta { color: #666; }
.info-line { display: flex; padding: 6rpx 0; }
.line-item { padding: 20rpx 24rpx; }
.line-head { display: flex; flex-direction: column; gap: 4rpx; margin-bottom: 12rpx; }
.line-name { font-size: 28rpx; font-weight: 600; color: #333; }
.line-spec { font-size: 24rpx; }
.line-row { display: flex; align-items: center; gap: 16rpx; }
.line-label { color: #666; font-size: 26rpx; width: 140rpx; }
.qty-input { flex: 1; font-size: 30rpx; text-align: right; }
.empty-hint { padding: 40rpx 0; text-align: center; }
.tip-card { padding: 8rpx 32rpx 16rpx; }
.footer-submit { position: fixed; left: 0; right: 0; bottom: 0; background: #fff; padding: 20rpx 24rpx; border-top: 1rpx solid #eee; }
.cu-btn { border-radius: 12rpx; border: none; }
.cu-btn.lg { width: 100%; font-size: 30rpx; height: 88rpx; line-height: 88rpx; }
.bg-blue { background: #007aff; color: #fff; }
.cu-btn[disabled] { opacity: 0.5; }
</style>
