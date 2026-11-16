<template>
  <el-dialog :model-value="modelValue" title="生产流转单" width="1000px" append-to-body
             @update:model-value="v => emit('update:modelValue', v)" @open="init">
    <div v-loading="loading" class="fs-wrap">
      <div class="fs-sheet" v-html="sheetHtml"></div>
    </div>
    <template #footer>
      <el-button @click="emit('update:modelValue', false)">关 闭</el-button>
      <el-button :loading="exporting" @click="handleExport">导出 Excel</el-button>
      <el-button type="primary" :loading="loading" @click="handlePrint">打 印</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import * as QRCode from 'qrcode'
import { ElMessage } from 'element-plus'
import { generateFlowSheet, getFlowSheet, exportFlowSheet } from '@/api/mes/pro/workorder'

interface FlowSheetAttr {
  attrCode: string
  attrName: string
  attrUnit?: string
  widgetType?: string
  attrValue: string
  label: string
}

const props = defineProps<{ modelValue: boolean; workorderId?: number }>()
const emit = defineEmits(['update:modelValue', 'success'])

const loading = ref(false)
const exporting = ref(false)
const qrUrl = ref('')
const data = ref<any>({})
const wo = computed<any>(() => data.value.workorder || {})
const productionAttrs = computed<FlowSheetAttr[]>(() => data.value.productionAttrs || [])
const qrContent = computed(() => wo.value.productionNo || wo.value.workorderCode || '')

function day(val?: string) {
  return val ? String(val).substring(0, 10) : ''
}
function safe(val: any) {
  return String(val ?? '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
}
function absUrl(url?: string) {
  if (!url) return ''
  if (url.startsWith('http') || url.startsWith('data:') || url.startsWith('blob:')) return url
  return new URL((import.meta.env.VITE_APP_BASE_API || '') + url, window.location.origin).href
}

/** 与 Excel 导出模板完全一致的 6 列布局 */
const sheetHtml = computed(() => {
  const qr = qrUrl.value
    ? `<img class="qr-img" src="${qrUrl.value}" alt="二维码"/><div class="qr-text">${safe(qrContent.value)}</div>`
    : `<div class="qr-text">二维码位置</div>`
  const head = (cells: string[][]) => cells.map(pair => `<tr>${pair.join('')}</tr>`).join('')
  const pair = (label: string, value: any) =>
    `<td class="label">${safe(label)}</td><td class="value">${safe(value)}</td>`

  const headerRows = head([
    [pair('订单编号', wo.value.sourceCode), pair('生产编号', wo.value.productionNo), pair('订单类型', wo.value.orderType)],
    [pair('产品名称', wo.value.productName), pair('下单日期', day(wo.value.orderDate)), pair('计划数量', wo.value.quantity)],
    [pair('产品尺寸', wo.value.productSize), pair('交货日期', day(wo.value.requestDate)),
      pair('订单数量', wo.value.orderQty ?? wo.value.quantity)]
  ])

  let attrRows = ''
  const attrs = productionAttrs.value
  for (let i = 0; i < attrs.length; i += 3) {
    const row: string[] = []
    for (let j = i; j < i + 3; j++) {
      const a = attrs[j]
      row.push(a ? `<td class="label">${safe(a.label)}</td><td class="value">${safe(a.attrValue)}</td>`
        : '<td class="label"></td><td class="value"></td>')
    }
    attrRows += `<tr>${row.join('')}</tr>`
  }

  const productImg = wo.value.productImage
    ? `<img class="prod-img" src="${absUrl(wo.value.productImage)}" alt="产品图片"/>` : ''
  const reqRow = (label: string, value: any) =>
    `<tr><td class="label">${label}</td><td class="value" colspan="4">${safe(value)}</td></tr>`
  const fullRow = (label: string, value: any) =>
    `<tr><td class="label">${label}</td><td class="value" colspan="5">${safe(value)}</td></tr>`

  return `<table class="fs-table">
    <colgroup><col style="width:16%"/><col style="width:26%"/><col style="width:14%"/><col style="width:26%"/><col style="width:14%"/><col style="width:26%"/></colgroup>
    <tr class="top"><td class="company" colspan="5">浙江圣享实业有限公司</td><td class="qr" rowspan="4">${qr}</td></tr>
    <tr class="spacer"><td colspan="5"></td></tr>
    <tr><td class="title" colspan="5">生产流转单</td></tr>
    <tr class="blank"><td colspan="5"></td></tr>
    ${headerRows}
    ${attrRows}
    <tr>
      <td class="label">印刷要求</td><td class="value" colspan="4">${safe(wo.value.printingReq)}</td>
      <td class="img" rowspan="3">${productImg}</td>
    </tr>
    ${reqRow('包装要求', wo.value.packageReq)}
    ${reqRow('发货要求', wo.value.shippingReq)}
    ${fullRow('工艺流程', wo.value.processFlow)}
    ${fullRow('备注', wo.value.remark)}
    <tr>
      <td class="label">制单日期</td><td class="value">${day(wo.value.billDate)}</td>
      <td class="value"></td><td class="value"></td>
      <td class="label">业务员</td><td class="value">${safe(wo.value.salesperson)}</td>
    </tr>
  </table>`
})

async function init() {
  if (!props.workorderId) return
  loading.value = true
  try {
    await generateFlowSheet({ workorderId: props.workorderId })
    const res: any = await getFlowSheet(props.workorderId)
    data.value = res.data || {}
    if (qrContent.value) {
      qrUrl.value = await QRCode.toDataURL(qrContent.value, { width: 120, margin: 1 })
    }
  } catch (e) {
    // 拦截器已提示
  } finally {
    loading.value = false
  }
}

async function handleExport() {
  if (!props.workorderId) return
  exporting.value = true
  try {
    const blob: any = await exportFlowSheet(props.workorderId, qrUrl.value)
    const url = window.URL.createObjectURL(new Blob([blob]))
    const a = document.createElement('a')
    a.href = url
    a.download = `生产流转单_${wo.value.productionNo || props.workorderId}.xlsx`
    document.body.appendChild(a); a.click(); document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
  } catch (e) {
    ElMessage.error('导出失败')
  } finally {
    exporting.value = false
  }
}

/** 浏览器打印：复用预览同一份表格 HTML，保证打印与预览/Excel 版式一致 */
function handlePrint() {
  const w = window.open('', '_blank', 'width=1000,height=900')
  if (!w) return
  w.document.write(`<!DOCTYPE html><html><head><meta charset="utf-8"><title>生产流转单</title>
    <style>${printCss()}</style></head><body>${sheetHtml.value}</body></html>`)
  w.document.close()
  w.focus()
  setTimeout(() => { w.print(); w.close() }, 300)
}

function printCss() {
  return `
    @page{size:A4 portrait;margin:10mm}
    body{font-family:"Microsoft YaHei",sans-serif;padding:0;color:#000}
    .fs-table{border-collapse:collapse;width:100%;table-layout:fixed}
    .fs-table td{border:1px solid #000;padding:4px 6px;font-size:11px;vertical-align:middle;word-break:break-all}
    .fs-table td.label{background:#eef7e6;font-weight:700;text-align:center}
    .fs-table td.value{text-align:left}
    .company,.title,.qr,.spacer td,.blank td{border:none !important}
    .fs-table td.company{font-size:28px;font-weight:700;text-align:center;height:42px}
    .fs-table td.title{font-size:18px;font-weight:700;text-align:center;height:30px;text-decoration:underline}
    .spacer td{height:9px}
    .qr{text-align:center;vertical-align:top}
    .qr-img{width:110px;height:110px}
    .qr-text{font-size:10px}
    .img{text-align:center}
    .prod-img{max-width:100%;max-height:150px}
  `
}
</script>

<style scoped>
.fs-wrap { max-height: 64vh; overflow-y: auto; padding-right: 4px; }
.fs-sheet :deep(.fs-table) { border-collapse: collapse; width: 100%; table-layout: fixed; }
.fs-sheet :deep(.fs-table td) { border: 1px solid #000; padding: 4px 6px; font-size: 11px; vertical-align: middle; word-break: break-all; }
.fs-sheet :deep(.fs-table td.label) { background: #eef7e6; font-weight: 700; text-align: center; }
.fs-sheet :deep(.fs-table td.value) { text-align: left; }
.fs-sheet :deep(.company), .fs-sheet :deep(.title),
.fs-sheet :deep(.qr), .fs-sheet :deep(.spacer td), .fs-sheet :deep(.blank td) { border: none !important; }
.fs-sheet :deep(.fs-table td.company) { font-size: 28px; font-weight: 700; text-align: center; height: 42px; }
.fs-sheet :deep(.fs-table td.title) { font-size: 18px; font-weight: 700; text-align: center; height: 30px; text-decoration: underline; }
.fs-sheet :deep(.spacer td) { height: 9px; }
.fs-sheet :deep(.qr) { text-align: center; vertical-align: top; }
.fs-sheet :deep(.qr-img) { width: 110px; height: 110px; }
.fs-sheet :deep(.qr-text) { font-size: 10px; color: #606266; }
.fs-sheet :deep(.img) { text-align: center; }
.fs-sheet :deep(.prod-img) { max-width: 100%; max-height: 150px; }
</style>
