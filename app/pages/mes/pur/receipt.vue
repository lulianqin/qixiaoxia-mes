<template>
  <view class="container">
    <!-- 步骤 1：输入PO单号（已知单号兜底；正常从待收货列表进入） -->
    <view class="section">
      <uni-section title="采购订单" type="line">
        <template #right>
          <text class="scan-tip">输入单号查询</text>
        </template>
      </uni-section>
      <view class="search-row">
        <uni-easyinput
          v-model="orderCode"
          placeholder="输入PO单号"
          :inputBorder="false"
          class="search-input"
          @confirm="searchOrder"
        />
        <button class="search-btn cu-btn bg-blue sm" @click="searchOrder">查询</button>
      </view>
    </view>

    <!-- 步骤 2：PO详情展示 -->
    <view v-if="order" class="section">
      <uni-section title="订单详情" type="line"></uni-section>
      <view class="order-info">
        <view class="info-row">
          <text class="label">订单编码</text>
          <text class="value bold">{{ order.orderCode }}</text>
        </view>
        <view class="info-row">
          <text class="label">供应商</text>
          <text class="value">{{ order.vendorName }}</text>
        </view>
        <view class="info-row">
          <text class="label">采购类型</text>
          <text class="value">{{ purchaseTypeText(order.purchaseType) }}</text>
        </view>
        <view class="info-row">
          <text class="label">状态</text>
          <uni-tag :type="orderStatusTagType(order.status)" :text="orderStatusText(order.status)" size="small" />
        </view>
      </view>

      <!-- 物料行 — 填入实收数量 + 仓库 -->
      <view class="line-header">
        <text class="bold">物料明细</text>
        <text class="text-grey">填写实收数量 · 仅登记到货</text>
      </view>
      <view v-for="(line, idx) in lines" :key="idx" class="line-item">
        <view class="line-info">
          <text class="bold">{{ line.itemName }}</text>
          <text class="text-grey">{{ line.itemCode }}</text>
        </view>
        <view class="line-spec">
          <text class="label">规格型号</text>
          <uni-easyinput v-model="line.specification" placeholder="请输入" :inputBorder="true" class="spec-field" />
        </view>
        <view class="line-qty">
          <text class="label">订购: {{ line.quantityOrdered }} {{ line.unitName }}</text>
          <view class="qty-input">
            <text class="label">实收:</text>
            <uni-easyinput
              v-model="line.receiptQty"
              type="number"
              placeholder="0"
              :inputBorder="true"
              class="qty-field"
            />
            <text class="unit">{{ line.unitName }}</text>
          </view>
          <text v-if="line.quantityReceived" class="text-green">
            已收: {{ line.quantityReceived }}
          </text>
        </view>
        <view class="line-warehouse">
          <text class="label">入库仓库</text>
          <view class="picker-value-sm" @click="chooseWarehouse(line)">
            {{ warehouseNameOf(line.warehouseId) || '请选择' }}
            <uni-icons type="right" size="12" color="#999" />
          </view>
        </view>
        <view class="line-extra">
          <view class="extra-row">
            <text class="label">生产日期</text>
            <UniDatetimePicker type="date" v-model="line.produceDate">
              <view class="picker-value-sm">{{ line.produceDate || '请选择' }}</view>
            </UniDatetimePicker>
          </view>
          <view class="extra-row">
            <text class="label">有效期至</text>
            <UniDatetimePicker type="date" v-model="line.expireDate">
              <view class="picker-value-sm">{{ line.expireDate || '请选择' }}</view>
            </UniDatetimePicker>
          </view>
          <view class="extra-row">
            <text class="label">生产批号</text>
            <uni-easyinput v-model="line.lotNumber" placeholder="供应商批号" :inputBorder="true" class="extra-field" />
          </view>
        </view>
        <!-- 逐件收货：一卷纸 / 一根钢管 / 一桶油墨，各自实际数量 -->
        <view class="line-instance">
          <text class="label">实物实例</text>
          <view class="inst-entry" @click="openInstanceEditor(idx)">
            <text :class="(line.details || []).length ? 'inst-count' : 'inst-ph'">
              {{ (line.details || []).length ? `已录入 ${line.details.length} 件` : '逐件录入' }}
            </text>
            <uni-icons type="right" size="12" color="#999" />
          </view>
        </view>
      </view>
    </view>

    <!-- 步骤 3：拍照留证 -->
    <view v-if="order" class="section">
      <uni-section title="拍照留证" type="line">
        <template #right>
          <text class="text-grey">最多3张</text>
        </template>
      </uni-section>
      <view class="photo-row">
        <view v-for="(photo, idx) in photos" :key="idx" class="photo-item">
          <image :src="photo" mode="aspectFill" class="photo-img" @click="previewPhoto(idx)" />
          <uni-icons type="closeempty" size="18" class="photo-del" @click="removePhoto(idx)" />
        </view>
        <view v-if="photos.length < 3" class="photo-add" @click="takePhoto">
          <uni-icons type="camera-filled" size="28" color="#999" />
          <text class="text-grey">拍照</text>
        </view>
      </view>
    </view>

    <!-- 步骤 4：到货信息 -->
    <view v-if="order" class="section">
      <uni-section title="到货信息" type="line"></uni-section>
      <view class="form-box">
        <uni-forms :model="arrivalInfo" labelWidth="80px">
          <uni-forms-item label="物流单号" name="logisticsNo">
            <uni-easyinput v-model="arrivalInfo.logisticsNo" placeholder="选填" />
          </uni-forms-item>
          <uni-forms-item label="车牌号" name="vehiclePlate">
            <uni-easyinput v-model="arrivalInfo.vehiclePlate" placeholder="选填" />
          </uni-forms-item>
          <uni-forms-item label="送货单号" name="vendorDeliveryNo">
            <uni-easyinput v-model="arrivalInfo.vendorDeliveryNo" placeholder="选填" />
          </uni-forms-item>
        </uni-forms>
      </view>
    </view>

    <!-- 底部确认按钮 -->
    <view v-if="order" class="footer-bar">
      <button type="primary" class="confirm-btn" @click="submitReceipt" :disabled="submitting">
        {{ submitting ? '提交中...' : '到货登记' }}
      </button>
    </view>

    <!-- 逐件录入：一件一行，数量填该件实际重量/长度 -->
    <uni-popup ref="instPopup" type="bottom" :is-mask-click="false">
      <view class="popup-content">
        <view class="popup-header">
          <text class="popup-title">逐件录入 · {{ instLine ? instLine.itemName : '' }}</text>
          <text class="popup-close" @click="instPopup.close()">关闭</text>
        </view>
        <view class="popup-tip">按实际到货逐件登记：一卷/一根一行，数量填该件实际重量或长度；行的实收数量会按各件合计自动回写。</view>
        <scroll-view scroll-y class="popup-scroll">
          <view v-for="(r, i) in instRows" :key="i" class="inst-row">
            <view class="inst-row-head">
              <text class="inst-idx">第 {{ i + 1 }} 件</text>
              <text class="inst-del" @click="removeInstRow(i)">删除</text>
            </view>
            <view class="inst-field">
              <text class="label">实例编号 / 供应商卷号</text>
              <uni-easyinput v-model="r.instanceCode" placeholder="可留空，确认入库时自动生成" :inputBorder="true" />
            </view>
            <view class="inst-field">
              <text class="label">本件数量({{ instLine ? (instLine.unitName || instLine.unitOfMeasure || '') : '' }})</text>
              <uni-easyinput v-model="r.instanceQuantity" type="number" placeholder="0" :inputBorder="true" />
            </view>
          </view>
          <view v-if="!instRows.length" class="empty-hint">
            <text class="text-grey">还没有录入，点下方「添加一件」</text>
          </view>
        </scroll-view>
        <view class="inst-bar">
          <button class="cu-btn sm" @click="addInstRow">添加一件</button>
          <text class="inst-total">合计：<text class="bold">{{ instTotal }}</text> {{ instLine ? (instLine.unitName || '') : '' }}</text>
        </view>
        <view class="popup-footer">
          <button class="cu-btn bg-blue lg" style="flex:1" @click="saveInstances">确 定</button>
        </view>
      </view>
    </uni-popup>
  </view>
</template>

<script setup>
import { ref, reactive, computed, getCurrentInstance, onMounted } from 'vue'
import { onShow, onLoad } from '@dcloudio/uni-app'
// 显式引入 uni-ui 组件（绕过 HBuilderX 发行 H5 时 easycom 失效）
import UniEasyInput from '@/uni_modules/uni-easyinput/components/uni-easyinput/uni-easyinput.vue'
import UniForms from '@/uni_modules/uni-forms/components/uni-forms/uni-forms.vue'
import UniFormsItem from '@/uni_modules/uni-forms/components/uni-forms-item/uni-forms-item.vue'
import UniIcons from '@/uni_modules/uni-icons/components/uni-icons/uni-icons.vue'
import UniSection from '@/components/uni-section/uni-section.vue'
import UniTag from '@/uni_modules/uni-tag/components/uni-tag/uni-tag.vue'
import UniDatetimePicker from '@/uni_modules/uni-datetime-picker/components/uni-datetime-picker/uni-datetime-picker.vue'
import UniPopup from '@/uni_modules/uni-popup/components/uni-popup/uni-popup.vue'
import { getOrder, getOrderDetailByCode, receiveItemRecpt, listWarehouseAll } from '@/api/mes/pur/order'
import { getBatchConfigByItemId } from '@/api/mes/md/batchconfig'
import { isValidReceiptQty, genRecptCode, purchaseTypeText, orderStatusTagType, orderStatusText, canReceive } from '@/utils/pur.js'

const { proxy } = getCurrentInstance()
const orderCode = ref('')
const order = ref(null)
const lines = ref([])
const photos = ref([])
const submitting = ref(false)
const warehouseList = ref([])
function warehouseNameOf(id) {
  const found = warehouseList.value.find(w => w.warehouseId === id)
  return found ? found.warehouseName : ''
}

// 用 showActionSheet 替代原生 picker：H5 移动端原生 selector-picker 是滚轮式，
// 触摸点击选项不能可靠选中；actionSheet 点击即选，各端一致
function chooseWarehouse(line) {
  if (!warehouseList.value.length) {
    proxy.$modal.msgError('仓库列表未加载，请稍候重试')
    return
  }
  uni.showActionSheet({
    itemList: warehouseList.value.map(w => w.warehouseName),
    success: (res) => {
      const w = warehouseList.value[res.tapIndex]
      if (w) line.warehouseId = w.warehouseId
    }
  })
}

const arrivalInfo = reactive({
  logisticsNo: '',
  vehiclePlate: '',
  vendorDeliveryNo: ''
})

// ==================== 逐件收货（一卷 / 一根 / 一桶） ====================
const instPopup = ref()
const instLineIdx = ref(-1)
const instRows = ref([])
const instLine = computed(() => (instLineIdx.value >= 0 ? lines.value[instLineIdx.value] : null))
const instTotal = computed(() => Number(instRows.value.reduce((s, r) => s + (Number(r.instanceQuantity) || 0), 0).toFixed(4)))

/** 打开逐件录入：先确认物料已开启「逐实物管理」，否则后端确认入库时不会建实例 */
function openInstanceEditor(idx) {
  const line = lines.value[idx]
  if (!line || !line.itemId) {
    proxy.$modal.msgWarning('请先选择物料')
    return
  }
  proxy.$modal.loading('读取物料配置...')
  getBatchConfigByItemId(line.itemId).then(res => {
    setTimeout(() => proxy.$modal.closeLoading(), 0)
    const cfg = res.data
    if (!cfg || cfg.instanceFlag !== '1') {
      setTimeout(() => proxy.$modal.msgWarning('该物料未开启「逐实物管理」，请先到 物料管理-批次配置 开启后再逐件录入'), 60)
      return
    }
    instLineIdx.value = idx
    instRows.value = (line.details && line.details.length)
      ? line.details.map(d => ({ ...d }))
      : [{ instanceCode: '', instanceQuantity: line.receiptQty || null }]
    instPopup.value.open()
  }).catch(() => {
    setTimeout(() => proxy.$modal.closeLoading(), 0)
    setTimeout(() => proxy.$modal.msgError('读取物料批次配置失败，无法判断是否逐件管理'), 60)
  })
}

function addInstRow() {
  instRows.value.push({ instanceCode: '', instanceQuantity: null })
}

function removeInstRow(i) {
  instRows.value.splice(i, 1)
}

/** 保存逐件明细：行实收量 = 各件合计 */
function saveInstances() {
  const rows = instRows.value
    .filter(r => Number(r.instanceQuantity) > 0)
    .map(r => ({
      instanceCode: (r.instanceCode || '').trim() || null,
      instanceQuantity: Number(r.instanceQuantity),
      quantity: Number(r.instanceQuantity)
    }))
  if (!rows.length) {
    proxy.$modal.msgWarning('请至少录入一件有效数量')
    return
  }
  const line = lines.value[instLineIdx.value]
  line.details = rows
  line.receiptQty = Number(rows.reduce((s, r) => s + r.instanceQuantity, 0).toFixed(4))
  instPopup.value.close()
  setTimeout(() => proxy.$modal.msgSuccess(`已录入 ${rows.length} 件，实收 ${line.receiptQty} ${line.unitName || ''}`), 60)
}

// 把后端返回的订单详情（PurOrderDetailVO：order + lines）填充到表单
function applyDetail(detail) {
  if (!detail || !detail.order) {
    setTimeout(() => proxy.$modal.msgError('未找到该采购订单'), 60)
    return
  }
  const found = detail.order
  if (!canReceive(found.status)) {
    setTimeout(() => {
      proxy.$modal.alert('该订单状态为"' + orderStatusText(found.status) + '"，仅"已下单/收货中"的订单可执行收货操作', '无法收货')
    }, 60)
    return
  }
  order.value = found
  orderCode.value = found.orderCode
  lines.value = (detail.lines || []).map(l => ({
    ...l,
    receiptQty: '',
    warehouseId: null,
    produceDate: '',
    expireDate: '',
    lotNumber: l.lotNumber || '',
    quantityReceived: l.quantityReceived || 0,
    details: []
  }))
}

// 搜索PO（一次请求拿到头+行，避免二次调用 order-line/list）
function searchOrder() {
  if (!orderCode.value.trim()) {
    proxy.$modal.msgError('请输入PO单号')
    return
  }
  proxy.$modal.loading('查询中...')
  getOrderDetailByCode(orderCode.value.trim()).then(res => {
    // H5 下在 Promise .then 中同步调 hideLoading 有时不生效，延迟一帧确保 loading 被关闭，
    // 否则"查询中..."会残留并遮住后续所有 toast（如仓库校验提示）
    setTimeout(() => proxy.$modal.closeLoading(), 0)
    applyDetail(res.data)
  }).catch(() => {
    setTimeout(() => proxy.$modal.closeLoading(), 0)
    setTimeout(() => proxy.$modal.msgError('查询失败，请检查单号'), 60)
  })
}

// 从待收货列表点进来：按 orderId 直接加载订单
onLoad((options) => {
  if (options && options.orderId) {
    proxy.$modal.loading('加载中...')
    getOrder(options.orderId).then(res => {
      setTimeout(() => proxy.$modal.closeLoading(), 0)
      applyDetail(res.data)
    }).catch(() => {
      setTimeout(() => proxy.$modal.closeLoading(), 0)
      setTimeout(() => proxy.$modal.msgError('订单加载失败'), 60)
    })
  }
})

// 拍照
function takePhoto() {
  uni.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    sourceType: ['camera'],
    success: (res) => {
      photos.value.push(res.tempFilePaths[0])
    }
  })
}

// 查看照片
function previewPhoto(idx) {
  uni.previewImage({
    current: idx,
    urls: photos.value
  })
}

// 删除照片
function removePhoto(idx) {
  photos.value.splice(idx, 1)
}

// 提交到货登记 — 单接口建 DRAFT 入库单（头+行+批次+IQC），不增库存/不过账
function submitReceipt() {
  // 清除可能残留的全局 loading（如查询后未关闭的"查询中..."），否则会遮住校验 toast
  uni.hideLoading()
  const hasQty = lines.value.some(l => isValidReceiptQty(l.receiptQty))
  if (!hasQty) {
    proxy.$modal.msgError('请至少填写一行的实收数量')
    return
  }
  const filledLines = lines.value.filter(l => isValidReceiptQty(l.receiptQty))
  if (filledLines.some(l => !l.warehouseId)) {
    proxy.$modal.msgError('请为每个已填数量的行选择入库仓库')
    return
  }
  // 逐件收货的行：实收数量必须等于各件合计，避免明细与行数量对不上
  for (const l of filledLines) {
    if (Array.isArray(l.details) && l.details.length) {
      const sum = Number(l.details.reduce((s, d) => s + (Number(d.instanceQuantity) || 0), 0).toFixed(4))
      if (Math.abs(sum - (Number(l.receiptQty) || 0)) > 0.0001) {
        proxy.$modal.msgError(`物料[${l.itemCode}]逐件合计(${sum})与实收数量(${l.receiptQty})不一致，请重新逐件录入`)
        return
      }
    }
  }

  proxy.$modal.confirm('确认提交到货登记？登记后仅生成草稿入库单，库存不变；检验合格后由 PC 端确认入库。').then(() => {
    submitting.value = true
    const body = {
      header: {
        recptCode: genRecptCode(),
        recptName: '移动端到货登记-' + (order.value.orderCode || ''),
        purOrderId: order.value.orderId,
        purOrderCode: order.value.orderCode,
        vendorId: order.value.vendorId,
        vendorCode: order.value.vendorCode,
        vendorName: order.value.vendorName,
        recptType: 'PURCHASE',
        status: 'DRAFT',
        remark: [
          arrivalInfo.logisticsNo && '物流:' + arrivalInfo.logisticsNo,
          arrivalInfo.vehiclePlate && '车牌:' + arrivalInfo.vehiclePlate,
          arrivalInfo.vendorDeliveryNo && '送货单:' + arrivalInfo.vendorDeliveryNo
        ].filter(Boolean).join('; ')
      },
      lines: lines.value.filter(l => isValidReceiptQty(l.receiptQty)).map(l => ({
        itemId: l.itemId, itemCode: l.itemCode, itemName: l.itemName,
        specification: l.specification,
        unitOfMeasure: l.unitOfMeasure, unitName: l.unitName,
        quantityRecpt: parseFloat(l.receiptQty),
        warehouseId: l.warehouseId,
        warehouseCode: warehouseList.value.find(w => w.warehouseId === l.warehouseId)?.warehouseCode || '',
        warehouseName: warehouseNameOf(l.warehouseId),
        produceDate: l.produceDate || null,
        expireDate: l.expireDate || null,
        lotNumber: l.lotNumber || null,
        details: (Array.isArray(l.details) && l.details.length) ? l.details : undefined
      }))
    }

    // 到货登记：后端建 DRAFT 头+行+批次+IQC，不 confirm/post
    receiveItemRecpt(body).then(res => {
      // res.data = 入库单详情：recptCode 入库单号、iqcCode 首张来料检验单（免检为 null）、
      // lines[].batchCode 生成的批次码（非批次管理物料为 null）
      const data = res.data || {}
      const batchCodes = [...new Set((data.lines || []).map(l => l.batchCode).filter(Boolean))]
      const msg = [
        '入库单号：' + (data.recptCode || '-'),
        data.iqcCode ? ('来料检验单：' + data.iqcCode) : '免检物料，无需检验',
        batchCodes.length ? ('批次码：' + batchCodes.join('、')) : ''
      ].filter(Boolean).join('\n') + '\n\n请在 PC 端完成' + (data.iqcCode ? '质检并' : '') + '确认入库'
      proxy.$modal.alert(msg, '到货登记成功')
      setTimeout(() => { proxy.$tab.navigateBack() }, 2500)
    }).catch(e => {
      proxy.$modal.msgError('登记失败：' + (typeof e === 'string' ? e : (e.msg || e.message || '未知错误')))
    }).finally(() => {
      submitting.value = false
    })
  }).catch(() => {})
}

onMounted(() => {
  // 防御性清理：uni.showLoading 是全局模态，跨页面不自动消失。
  // 若上个页面（如登录页）因异常残留 loading，会遮住本页所有 toast（包括仓库校验提示）。
  uni.hideLoading()
  // 必须有 catch：token 过期时后端返回 401，request.js 拦截器会弹"登录状态已过期"modal，
  // 这里再不兜住会让 Promise 成为 unhandledrejection；且 warehouseList 永远为空，picker 无选项可选
  listWarehouseAll()
    .then(res => { warehouseList.value = res.data || [] })
    .catch(err => {
      // 401 已被 request.js 拦截器处理（弹登录 modal），其余失败提示加载失败
      if (err !== 401 && err !== '无效的会话，或者会话已过期，请重新登录。') {
        proxy.$modal.msgError('仓库列表加载失败，请重试')
      }
    })
})

// 每次页面显示时清理可能残留的全局 loading（如从其他页面返回时）
onShow(() => {
  uni.hideLoading()
})
</script>

<style lang="scss" scoped>
page { background-color: #f5f6f7; min-height: 100%; }

.container { padding-bottom: 120rpx; }

.section {
  margin: 20rpx 0;
  background: #fff;
}

.search-row {
  display: flex;
  align-items: center;
  padding: 20rpx 24rpx;
  gap: 16rpx;
}
.search-input { flex: 1; }
.search-btn { margin: 0; font-size: 26rpx; height: 64rpx; line-height: 64rpx; }

.order-info {
  padding: 16rpx 24rpx 24rpx;
  border-bottom: 1px solid #f0f0f0;
}
.info-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: 8rpx 0;
}
.label { color: #999; font-size: 26rpx; }
.value { font-size: 28rpx; color: #333; }
.bold { font-weight: 600; }

.line-header {
  display: flex; justify-content: space-between;
  padding: 24rpx 24rpx 12rpx;
  font-size: 28rpx;
}
.line-item {
  padding: 20rpx 24rpx;
  border-bottom: 1px solid #f5f5f5;
}
.line-info { margin-bottom: 12rpx; }
.line-qty {
  display: flex; align-items: center; gap: 16rpx;
  flex-wrap: wrap;
}
.qty-input {
  display: flex; align-items: center;
  gap: 8rpx;
}
.qty-field {
  width: 160rpx;
}
.unit { color: #666; font-size: 24rpx; }
.text-grey { color: #999; font-size: 24rpx; }
.text-green { color: #4cd964; font-size: 24rpx; }

.photo-row {
  display: flex; gap: 20rpx; flex-wrap: wrap;
  padding: 16rpx 24rpx 24rpx;
}
.photo-item {
  width: 160rpx; height: 160rpx;
  border-radius: 12rpx; overflow: hidden;
  position: relative;
}
.photo-img { width: 100%; height: 100%; }
.photo-del {
  position: absolute; top: 4rpx; right: 4rpx;
  background: rgba(0,0,0,0.5); border-radius: 50%;
  padding: 4rpx;
}
.photo-add {
  width: 160rpx; height: 160rpx;
  border: 2rpx dashed #ccc; border-radius: 12rpx;
  display: flex; flex-direction: column; align-items: center;
  justify-content: center; gap: 8rpx;
  color: #999;
}

.line-warehouse {
  display: flex; align-items: center; justify-content: space-between;
  margin-top: 12rpx; padding-top: 12rpx;
  border-top: 1px dashed #e5e5e5;
}
.picker-value-sm {
  display: flex; align-items: center; gap: 6rpx;
  color: #333; font-size: 26rpx;
}

.line-spec {
  display: flex; align-items: center; justify-content: space-between;
  margin-top: 8rpx;
}
.spec-field { width: 280rpx; }

.line-extra {
  margin-top: 8rpx; padding-top: 8rpx;
  border-top: 1px dashed #e5e5e5;
}
.extra-row {
  display: flex; align-items: center; justify-content: space-between;
  padding: 4rpx 0;
}
.extra-field { width: 260rpx; }

.form-box { padding: 16rpx 24rpx; }

.footer-bar {
  position: fixed; bottom: 0; left: 0; right: 0;
  padding: 20rpx 32rpx; padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  background: #fff; border-top: 1px solid #f0f0f0;
  z-index: 100;
}
.confirm-btn {
  width: 100%; height: 88rpx; line-height: 88rpx;
  font-size: 32rpx; border-radius: 12rpx;
}

/* 逐件收货 */
.line-instance {
  display: flex; align-items: center; justify-content: space-between;
  margin-top: 12rpx; padding-top: 12rpx;
  border-top: 1px dashed #e5e5e5;
}
.inst-entry {
  display: flex; align-items: center; gap: 6rpx;
  padding: 6rpx 16rpx;
  border: 1px solid #4a8cf7; border-radius: 8rpx;
}
.inst-ph { color: #4a8cf7; font-size: 26rpx; }
.inst-count { color: #1a9c4a; font-size: 26rpx; font-weight: 600; }

.popup-content {
  background: #fff;
  border-radius: 20rpx 20rpx 0 0;
  padding: 24rpx 24rpx calc(24rpx + env(safe-area-inset-bottom));
  max-height: 82vh;
  display: flex; flex-direction: column;
}
.popup-header {
  display: flex; align-items: center; justify-content: space-between;
  padding-bottom: 16rpx;
}
.popup-title { font-size: 30rpx; font-weight: 600; color: #333; }
.popup-close { font-size: 26rpx; color: #999; }
.popup-tip {
  font-size: 24rpx; color: #999; line-height: 1.5;
  padding: 12rpx 16rpx; margin-bottom: 12rpx;
  background: #f6f8fc; border-radius: 8rpx;
}
.popup-scroll { flex: 1; max-height: 52vh; }
.inst-row {
  padding: 16rpx 0;
  border-bottom: 1px solid #f2f2f2;
}
.inst-row-head {
  display: flex; align-items: center; justify-content: space-between;
  padding-bottom: 8rpx;
}
.inst-idx { font-size: 26rpx; color: #4a8cf7; font-weight: 600; }
.inst-del { font-size: 24rpx; color: #f56c6c; }
.inst-field {
  display: flex; align-items: center; justify-content: space-between;
  gap: 16rpx; padding: 6rpx 0;
}
.inst-field .label { flex: 0 0 220rpx; }
.inst-field :deep(.uni-easyinput) { flex: 1; }
.inst-bar {
  display: flex; align-items: center; justify-content: space-between;
  padding: 16rpx 0;
}
.inst-total { font-size: 26rpx; color: #333; }
.popup-footer { display: flex; padding-top: 8rpx; }
.empty-hint { padding: 40rpx 0; text-align: center; }
</style>
