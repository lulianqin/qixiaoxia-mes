<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="订单号" prop="orderCode"><el-input v-model="queryParams.orderCode" placeholder="销售订单号" clearable @keyup.enter="handleQuery" /></el-form-item>
      <el-form-item label="订单名称" prop="orderName"><el-input v-model="queryParams.orderName" placeholder="订单名称" clearable @keyup.enter="handleQuery" /></el-form-item>
      <el-form-item label="客户" prop="clientName"><el-input v-model="queryParams.clientName" placeholder="客户名称" clearable @keyup.enter="handleQuery" /></el-form-item>
      <el-form-item label="客户PO号" prop="clientOrderCode"><el-input v-model="queryParams.clientOrderCode" placeholder="客户PO号" clearable @keyup.enter="handleQuery" /></el-form-item>
      <el-form-item label="ERP单号" prop="externalOrderNo"><el-input v-model="queryParams.externalOrderNo" placeholder="ERP采购单号" clearable @keyup.enter="handleQuery" /></el-form-item>
      <el-form-item label="业务线" prop="businessLine">
        <el-select v-model="queryParams.businessLine" placeholder="全部" clearable style="width:110px">
          <el-option label="内贸" value="DOMESTIC" /><el-option label="外贸" value="FOREIGN" /><el-option label="现货" value="SPOT" />
        </el-select>
      </el-form-item>
      <el-form-item label="订单类型" prop="orderType">
        <el-select v-model="queryParams.orderType" placeholder="全部" clearable style="width:110px">
          <el-option v-for="d in salOrderTypeOptions" :key="d.dictValue" :label="d.dictLabel" :value="d.dictValue" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="全部" clearable style="width:110px">
          <el-option v-for="d in salStatusOptions" :key="d.dictValue" :label="d.dictLabel" :value="d.dictValue" />
        </el-select>
      </el-form-item>
      <el-form-item label="来源" prop="source">
        <el-select v-model="queryParams.source" placeholder="全部" clearable style="width:110px">
          <el-option label="直接新增" :value="1" /><el-option label="CRM系统" :value="2" /><el-option label="ERP系统" :value="3" />
        </el-select>
      </el-form-item>
      <el-form-item><el-button type="primary" size="small" @click="handleQuery">搜索</el-button><el-button size="small" @click="resetQuery">重置</el-button></el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5"><el-button type="primary" plain size="small" @click="handleAdd" v-hasPermi="['mes:sal:order:add']">新增</el-button></el-col>
      <el-col :span="1.5"><el-button type="success" plain size="small" :disabled="single || !canEditSelected" @click="handleUpdate" v-hasPermi="['mes:sal:order:edit']">修改</el-button></el-col>
      <el-col :span="1.5"><el-button type="danger" plain size="small" :disabled="multiple || !canDeleteSelected" @click="handleDelete" v-hasPermi="['mes:sal:order:remove']">删除</el-button></el-col>
      <el-col :span="1.5"><el-button type="warning" plain size="small" @click="handleExport" v-hasPermi="['mes:sal:order:export']">导出</el-button></el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="orderList" @selection-change="handleSelectionChange" border>
      <el-table-column type="selection" width="50" align="center" />
      <el-table-column label="销售订单号" align="center" prop="orderCode" width="140" :show-overflow-tooltip="true">
        <template #default="s"><el-link type="primary" @click="handleView(s.row)">{{ s.row.orderCode }}</el-link></template>
      </el-table-column>
      <el-table-column label="订单名称" align="center" prop="orderName" min-width="200" :show-overflow-tooltip="true" />
      <el-table-column label="供方主体" align="center" prop="signCompany" width="200" :show-overflow-tooltip="true">
        <template #default="s">{{ companyText(s.row.signCompany) }}</template>
      </el-table-column>
      <el-table-column label="需方主体" align="center" prop="demanderName" width="180" :show-overflow-tooltip="true" />
      <el-table-column label="订单类型" align="center" prop="orderType" width="90"><template #default="s"><el-tag :type="orderTypeMeta(s.row.orderType).type" size="small">{{ orderTypeMeta(s.row.orderType).text }}</el-tag></template></el-table-column>
      <el-table-column label="客户" align="center" prop="clientName" min-width="200" :show-overflow-tooltip="true" />
      <el-table-column label="客户PO号" align="center" prop="clientOrderCode" min-width="160" :show-overflow-tooltip="true" />
      <el-table-column label="业务线" align="center" prop="businessLine" width="80" :show-overflow-tooltip="true"><template #default="s">{{ businessLineText(s.row.businessLine) }}</template></el-table-column>
      <el-table-column label="来源" align="center" prop="source" width="90"><template #default="s"><el-tag :type="sourceTag(s.row.source)">{{ sourceText(s.row.source) }}</el-tag></template></el-table-column>
      <el-table-column label="ERP单号" align="center" prop="externalOrderNo" width="150" :show-overflow-tooltip="true" />
      <el-table-column label="回写状态" align="center" prop="syncStatus" width="90">
        <template #default="s"><el-tag v-if="s.row.syncStatus" :type="syncTag(s.row.syncStatus)">{{ syncText(s.row.syncStatus) }}</el-tag><span v-else>-</span></template>
      </el-table-column>
      <el-table-column label="交期" align="center" prop="requestDate" width="180" :show-overflow-tooltip="true"><template #default="s">{{ parseTime(s.row.requestDate, '{y}-{m}-{d}') }}</template></el-table-column>
      <el-table-column label="总金额" align="center" prop="totalAmount" width="100" :show-overflow-tooltip="true" />
      <el-table-column label="生产进度" align="center" width="150">
        <template #default="s">
          <el-progress :percentage="progressBar(s.row).percentage" :stroke-width="10" :status="progressBar(s.row).status" />
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status" width="90"><template #default="s"><el-tag :type="statusMeta(s.row.status).type">{{ statusMeta(s.row.status).text }}</el-tag></template></el-table-column>
      <el-table-column fixed="right" label="操作" align="center" width="220" class-name="op-col">
        <template #default="scope">
          <el-button link type="primary" size="small" @click="handleView(scope.row)" v-hasPermi="['mes:sal:order:query']">查看</el-button>
          <el-button v-if="scope.row.status==='PENDING_ACCEPT'" link type="success" size="small" @click="handleAccept(scope.row)" v-hasPermi="['mes:sal:order:accept']">接单</el-button>
          <el-button v-if="scope.row.status==='PENDING_ACCEPT' && scope.row.sourceSystem==='ERP'" link type="danger" size="small" @click="handleReject(scope.row)" v-hasPermi="['mes:sal:order:reject']">打回</el-button>
          <el-button v-if="canModify(scope.row)" link type="primary" size="small" @click="handleUpdate(scope.row)" v-hasPermi="['mes:sal:order:edit']">修改</el-button>
          <el-button v-if="scope.row.status==='CONFIRMED' || scope.row.status==='PRODUCING'" link type="warning" size="small" @click="handleToWorkorder(scope.row)" v-hasPermi="['mes:sal:order:workorder']">生成工单</el-button>
          <el-button v-if="scope.row.status==='SHIPPED'" link type="success" size="small" @click="handleClose(scope.row)" v-hasPermi="['mes:sal:order:close']">结单</el-button>
          <el-button v-if="['PENDING_ACCEPT','CONFIRMED','PRODUCING'].includes(scope.row.status)" link type="danger" size="small" @click="handleCancel(scope.row)" v-hasPermi="['mes:sal:order:cancel']">取消</el-button>
          <el-button v-if="canModify(scope.row)" link type="danger" size="small" @click="handleDelete(scope.row)" v-hasPermi="['mes:sal:order:remove']">删除</el-button>
          <el-dropdown @command="(cmd) => handleChangeStatus(scope.row, cmd)" v-hasPermi="['mes:sal:order:changeStatus']">
            <el-button link type="primary" size="small">改状态</el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item v-for="s in salStatusOptions" :key="s.dictValue" :command="s.dictValue"
                                  :disabled="s.dictValue === scope.row.status">{{ s.dictLabel }}</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
          <el-dropdown @command="(cmd) => handleRowExport(scope.row, cmd)" v-hasPermi="['mes:sal:order:exportDetail']">
            <el-button link type="primary" size="small">导出</el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="print">打印</el-dropdown-item>
                <el-dropdown-item command="excel">导出 Excel</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <OrderEditDialog ref="editDialogRef" :order-type-options="salOrderTypeOptions" @success="getList" />
    <AcceptDialog ref="acceptDialogRef" @success="getList" />
    <RejectDialog ref="rejectDialogRef" @success="getList" />
    <ToWorkorderDialog v-model="twOpen" :order="twOrder" @created="getList" />
  </div>
</template>

<script>
import { listOrder, closeOrder, cancelOrder, delOrder, changeOrderStatus, fetchOrderPdf } from '@/api/mes/sal/order'
import { printPdfBlob } from '@/utils/pdfPrint'
import { getDicts } from '@/api/system/dict/data'
import { ElMessageBox, ElMessage } from 'element-plus'
import OrderEditDialog from './OrderEditDialog.vue'
import ToWorkorderDialog from './ToWorkorderDialog.vue'
import AcceptDialog from './AcceptDialog.vue'
import RejectDialog from './RejectDialog.vue'

// 进度满格阈值（百分比）；CLOSED/CANCEL 由进度条 exception 态标识
const PROGRESS_FULL = 100

export default {
  name: 'SalOrder',
  components: { OrderEditDialog, ToWorkorderDialog, AcceptDialog, RejectDialog },
  data() {
    return {
      loading: true, ids: [], selectedRows: [], single: true, multiple: true, showSearch: true, total: 0,
      orderList: [],
      // 销售订单状态字典(mes_sal_order_status)
      salStatusOptions: [],
      // 销售订单类型字典(mes_sal_order_type)
      salOrderTypeOptions: [],
      // 供方主体字典(sys_company)
      companyOptions: [],
      queryParams: { pageNum: 1, pageSize: 10, orderCode: null, orderName: null, clientName: null, clientOrderCode: null, externalOrderNo: null, businessLine: null, orderType: null, status: null, source: null },
      twOpen: false, twOrder: {}
    }
  },
  created() { this.loadStatusDict(); this.loadOrderTypeDict(); this.loadCompanyDict(); this.getList() },
  methods: {
    /** 进度条展示模型：百分比兜底 0；CLOSED/CANCEL 走 exception，满进度走 success */
    progressBar(row) {
      const percentage = Number(row.progressPercent || 0)
      const terminated = row.status === 'CLOSED' || row.status === 'CANCEL'
      return { percentage, status: terminated ? 'exception' : percentage >= PROGRESS_FULL ? 'success' : '' }
    },
    /** 已派生未取消工单（含未开工）：改/删必须隐藏，后端闸门同样拦截 */
    hasWorkorder(row) { return Number(row.workorderCount || 0) > 0 },
    /** 可改/可删：待接单/已确认（与后端 SalOrderStatus.isEditable 同口径）且未派生工单 */
    canModify(row) { return ['PENDING_ACCEPT', 'CONFIRMED'].includes(row.status) && !this.hasWorkorder(row) },
    getList() { this.loading = true; listOrder({ ...this.queryParams, includeProgress: true }).then(r => { this.orderList = r.rows; this.total = r.total; this.loading = false }).catch(() => { this.loading = false }) },
    /** 加载销售订单状态字典 */
    loadStatusDict() { getDicts('mes_sal_order_status').then(r => { this.salStatusOptions = r.data || [] }) },
    /** 加载销售订单类型字典 */
    loadOrderTypeDict() { getDicts('mes_sal_order_type').then(r => { this.salOrderTypeOptions = r.data || [] }) },
    /** 加载供方主体字典 */
    loadCompanyDict() { getDicts('sys_company').then(r => { this.companyOptions = r.data || [] }) },
    /** 供方主体字典值 → 名称 */
    companyText(v) {
      const d = this.companyOptions.find(o => o.dictValue === v)
      return d ? d.dictLabel : (v || '-')
    },
    /** 一期：人工改订单状态（任意状态互转，后端记录变更原因） */
    handleChangeStatus(row, targetStatus) {
      if (targetStatus === row.status) return
      const label = (this.salStatusOptions.find(s => s.dictValue === targetStatus) || {}).dictLabel || targetStatus
      ElMessageBox.prompt(`将订单 ${row.orderCode} 状态改为「${label}」，请填写变更原因（可空）`, '改状态', {
        inputPlaceholder: '变更原因', confirmButtonText: '确定', cancelButtonText: '取消'
      }).then(({ value }) => {
        return changeOrderStatus({ orderId: row.orderId, targetStatus, reason: value })
      }).then(() => {
        ElMessage.success('状态已更新')
        this.getList()
      }).catch(() => {})
    },
    /** 状态 → {text, type}，由字典驱动渲染 */
    statusMeta(s) {
      const d = this.salStatusOptions.find(o => o.dictValue === s)
      return { text: d ? d.dictLabel : (s || ''), type: d && d.listClass ? d.listClass : '' }
    },
    /** 订单类型 → {text, type}，由字典驱动渲染 */
    orderTypeMeta(t) {
      const d = this.salOrderTypeOptions.find(o => o.dictValue === t)
      return { text: d ? d.dictLabel : (t || ''), type: d && d.listClass ? d.listClass : '' }
    },
    businessLineText(b) { return { DOMESTIC: '内贸', FOREIGN: '外贸', SPOT: '现货' }[b] || b },
    sourceText(s) { return { 1: '直接新增', 2: 'CRM系统', 3: 'ERP系统' }[s] || (s == null ? '' : s) },
    sourceTag(s) { return s === 3 ? 'success' : s === 2 ? 'warning' : 'info' },
    syncText(s) { return { PENDING: '待回写', SUCCESS: '已回写', FAILED: '回写失败' }[s] || s },
    syncTag(s) { return s === 'SUCCESS' ? 'success' : s === 'FAILED' ? 'danger' : 'warning' },
    handleQuery() { this.queryParams.pageNum = 1; this.getList() },
    resetQuery() { this.resetForm('queryRef'); this.handleQuery() },
    handleSelectionChange(sel) { this.selectedRows = sel; this.ids = sel.map(i => i.orderId); this.single = sel.length !== 1; this.multiple = !sel.length },
    handleAdd() { this.$refs.editDialogRef.openAdd() },
    /** 跳转只读详情页（展示状态/生产进度/明细） */
    handleView(row) { this.$router.push({ path: '/mes/sal/order_detail', query: { orderId: row.orderId } }) },
    handleUpdate(row) {
      const id = row.orderId || this.ids
      if (id) this.$refs.editDialogRef.openEdit(id)
    },
    handleAccept(row) { this.$refs.acceptDialogRef.open(row) },
    handleReject(row) { this.$refs.rejectDialogRef.open(row) },
    handleClose(row) { this.$modal.confirm('确认结单 "' + row.orderCode + '"？结单后不可恢复。').then(() => closeOrder(row.orderId)).then(() => { this.getList(); this.$modal.msgSuccess('结单成功') }).catch(() => {}) },
    handleCancel(row) { this.$modal.confirm('确认取消 "' + row.orderCode + '" ?').then(() => cancelOrder(row.orderId)).then(() => { this.getList(); this.$modal.msgSuccess('取消成功，关联工单需另行处理') }).catch(() => {}) },
    handleDelete(row) { const ids = row.orderId || this.ids; this.$modal.confirm('是否确认删除销售订单 "' + ids + '" ?').then(() => delOrder(ids)).then(() => { this.getList(); this.$modal.msgSuccess('删除成功') }).catch(() => {}) },
    // 生成工单：统一跳转生产工单独立开单页（带入来源订单信息）
    handleToWorkorder(row) {
      this.$router.push({
        path: '/mes/pro/workorder_edit',
        query: {
          mode: 'add',
          sourceOrderCode: row.orderCode,
          clientOrderCode: row.clientOrderCode,
          // 工单订单类型取销售订单的源订单类型（ERP 原类型：新单/翻单/异常单/打样）
          orderType: row.sourceOrderType || undefined
        }
      })
    },
    handleExport() { this.download('mes/sal/order/export', { ...this.queryParams }, `sal_order_${new Date().getTime()}.xlsx`) },
    handleRowExport(row, cmd) {
      // 打印：取 PDF blob 后直接调起系统打印，不下载
      if (cmd === 'print') {
        fetchOrderPdf(row.orderId).then(blob => printPdfBlob(blob)).catch(() => {})
        return
      }
      this.download('mes/sal/order/exportExcel/' + row.orderId, {}, `sal_order_${row.orderCode}.xlsx`)
    }
  },
  computed: {
    /** 顶部「修改」：选中行均可改可删（待接单/已确认且未派生工单，含未开工）才可用 */
    canEditSelected() { return this.selectedRows.length > 0 && this.selectedRows.every(r => this.canModify(r)) },
    /** 顶部「删除」：同修改口径 */
    canDeleteSelected() { return this.selectedRows.length > 0 && this.selectedRows.every(r => this.canModify(r)) }
  }
}
</script>

<style scoped>
/* 操作列：纯中文按钮、两行排布、紧凑间距 */
:deep(.op-col .cell) { white-space: normal; line-height: 24px; }
:deep(.op-col .el-button) { padding: 0 3px !important; height: 24px; font-size: 12px; }
:deep(.op-col .el-button + .el-button) { margin-left: 4px; }
:deep(.op-col .el-dropdown) { margin-left: 4px; }
</style>
