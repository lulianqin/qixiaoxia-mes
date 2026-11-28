<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="90px" size="small">
      <el-form-item label="申请单号" prop="applyCode">
        <el-input v-model="queryParams.applyCode" placeholder="ERP申请单号" clearable style="width:180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="采购单号" prop="externalOrderNo">
        <el-input v-model="queryParams.externalOrderNo" placeholder="SRM采购单号" clearable style="width:160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="销售订单" prop="salesOrderCode">
        <el-input v-model="queryParams.salesOrderCode" placeholder="MES销售订单号" clearable style="width:160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择" clearable style="width:120px">
          <el-option v-for="(label, val) in statusLabel" :key="val" :label="label" :value="val" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="申请单号" align="center" prop="applyCode" width="170" :show-overflow-tooltip="true" />
      <el-table-column label="采购单号" align="center" prop="externalOrderNo" width="160" :show-overflow-tooltip="true" />
      <el-table-column label="销售订单号" align="center" prop="salesOrderCode" width="160" :show-overflow-tooltip="true" />
      <el-table-column label="申请/已出库" align="center" width="130">
        <template #default="scope">{{ scope.row.totalApplyQty || 0 }} / {{ scope.row.totalPostedQty || 0 }}</template>
      </el-table-column>
      <el-table-column label="MES出库单号" align="center" prop="mesSalesCode" width="160" :show-overflow-tooltip="true">
        <template #default="scope">{{ scope.row.mesSalesCode || '-' }}</template>
      </el-table-column>
      <el-table-column label="状态" align="center" width="100">
        <template #default="scope">
          <el-tag size="small" :type="statusTagType(scope.row.status)">{{ statusLabel[scope.row.status] || scope.row.status || '-' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="申请日期" align="center" prop="requestDate" width="110" :show-overflow-tooltip="true" />
      <el-table-column label="下发时间" align="center" prop="createTime" width="160" :show-overflow-tooltip="true" />
      <el-table-column label="收货信息" align="center" min-width="180" :show-overflow-tooltip="true">
        <template #default="scope">
          {{ [scope.row.receiverName, scope.row.receiverTel, scope.row.receiverAddress].filter(Boolean).join(' / ') || '-' }}
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="90" fixed="right" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-tooltip content="查看" placement="top">
            <el-button link type="primary" icon="View" @click="handleView(scope.row)" v-hasPermi="['mes:wm:salesapply:query']" />
          </el-tooltip>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total > 0" :total="total" v-model:current-page="queryParams.pageNum" v-model:page-size="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="出库申请详情" v-model="detailVisible" width="900px" append-to-body>
      <el-descriptions :column="2" border size="small">
        <el-descriptions-item label="申请单号">{{ detail.applyCode }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag size="small" :type="statusTagType(detail.status)">{{ statusLabel[detail.status] || detail.status || '-' }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="采购单号">{{ detail.externalOrderNo || '-' }}</el-descriptions-item>
        <el-descriptions-item label="销售订单号">{{ detail.salesOrderCode || '-' }}</el-descriptions-item>
        <el-descriptions-item label="MES出库单号">{{ detail.mesSalesCode || '（尚未生成）' }}</el-descriptions-item>
        <el-descriptions-item label="申请日期">{{ detail.requestDate || '-' }}</el-descriptions-item>
        <el-descriptions-item label="收货人">{{ detail.receiverName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ detail.receiverTel || '-' }}</el-descriptions-item>
        <el-descriptions-item label="收货地址" :span="2">{{ detail.receiverAddress || '-' }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ detail.remark || '-' }}</el-descriptions-item>
      </el-descriptions>

      <el-table :data="detail.lines || []" size="small" border style="margin-top: 12px">
        <el-table-column label="物料编码" prop="itemCode" width="140" :show-overflow-tooltip="true" />
        <el-table-column label="物料名称" prop="itemName" min-width="160" :show-overflow-tooltip="true" />
        <el-table-column label="单位" prop="unitName" width="80" align="center" />
        <el-table-column label="申请数量" prop="applyQty" width="100" align="center" />
        <el-table-column label="已出库" prop="postedQty" width="100" align="center" />
        <el-table-column label="行状态" width="100" align="center">
          <template #default="scope">
            <el-tag size="small" :type="statusTagType(scope.row.lineStatus)">{{ statusLabel[scope.row.lineStatus] || scope.row.lineStatus || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="备注" prop="remark" min-width="140" :show-overflow-tooltip="true" />
      </el-table>
      <template #footer>
        <el-button @click="detailVisible = false">关 闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts" name="WmSalesApply">
import { ref, reactive, getCurrentInstance } from 'vue'
import type { WmSalesApplyQueryParams, WmSalesApply } from '@/types/api/mes/wm/sales_apply'
import { listWmSalesApply, getWmSalesApply } from '@/api/mes/wm/sales_apply'

const { proxy } = getCurrentInstance() as any

const statusLabel: Record<string, string> = {
  PENDING: '待出库',
  PARTIAL: '部分出库',
  DONE: '已完成',
  CANCELED: '已撤回'
}

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<WmSalesApply[]>([])
const queryParams = reactive<WmSalesApplyQueryParams>({ pageNum: 1, pageSize: 10 } as WmSalesApplyQueryParams)

const detailVisible = ref(false)
const detail = ref<WmSalesApply>({})

function statusTagType(status?: string) {
  if (status === 'DONE') return 'success'
  if (status === 'PARTIAL') return 'warning'
  if (status === 'CANCELED') return 'info'
  return 'primary'
}

function getList() {
  loading.value = true
  listWmSalesApply(queryParams).then(r => {
    dataList.value = r.rows
    total.value = r.total
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() { queryParams.pageNum = 1; getList() }

function resetQuery() {
  Object.keys(queryParams).forEach(k => { if (k !== 'pageNum' && k !== 'pageSize') (queryParams as any)[k] = undefined })
  handleQuery()
}

function handleView(row: WmSalesApply) {
  getWmSalesApply(row.applyId as number).then(r => {
    detail.value = r.data || row
    detailVisible.value = true
  })
}

getList()
</script>
