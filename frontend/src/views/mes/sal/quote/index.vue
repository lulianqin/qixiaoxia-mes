<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="90px">
      <el-form-item label="MES报价单号" prop="quoteCode"><el-input v-model="queryParams.quoteCode" placeholder="MES报价单号" clearable @keyup.enter="handleQuery" /></el-form-item>
      <el-form-item label="ERP报价单号" prop="externalQuoteNo"><el-input v-model="queryParams.externalQuoteNo" placeholder="ERP报价单号" clearable @keyup.enter="handleQuery" /></el-form-item>
      <el-form-item label="标题" prop="title"><el-input v-model="queryParams.title" placeholder="标题" clearable @keyup.enter="handleQuery" /></el-form-item>
      <el-form-item label="客户" prop="clientName"><el-input v-model="queryParams.clientName" placeholder="客户名称" clearable @keyup.enter="handleQuery" /></el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="全部" clearable style="width:110px">
          <el-option v-for="d in statusOptions" :key="d.dictValue" :label="d.dictLabel" :value="d.dictValue" />
        </el-select>
      </el-form-item>
      <el-form-item><el-button type="primary" size="small" @click="handleQuery">搜索</el-button><el-button size="small" @click="resetQuery">重置</el-button></el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="quoteList" border>
      <el-table-column label="MES报价单号" align="center" prop="quoteCode" width="170" :show-overflow-tooltip="true">
        <template #default="s"><el-link type="primary" @click="handleView(s.row)">{{ s.row.quoteCode }}</el-link></template>
      </el-table-column>
      <el-table-column label="ERP报价单号" align="center" prop="externalQuoteNo" width="160" :show-overflow-tooltip="true" />
      <el-table-column label="标题" align="center" prop="title" :show-overflow-tooltip="true" />
      <el-table-column label="客户" align="center" prop="clientName" :show-overflow-tooltip="true" />
      <el-table-column label="询价日期" align="center" prop="inquiryDate" width="120"><template #default="s">{{ parseTime(s.row.inquiryDate || s.row.createTime, '{y}-{m}-{d}') }}</template></el-table-column>
      <el-table-column label="状态" align="center" prop="status" width="100"><template #default="s"><el-tag :type="statusMeta(s.row.status).type">{{ statusMeta(s.row.status).text }}</el-tag></template></el-table-column>
      <el-table-column label="报价人" align="center" prop="quoteUser" width="100" :show-overflow-tooltip="true" />
      <el-table-column label="报价时间" align="center" prop="quoteTime" width="170"><template #default="s">{{ parseTime(s.row.quoteTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</template></el-table-column>
      <el-table-column label="报价总额" align="center" prop="totalAmount" width="110" />
      <el-table-column label="回写状态" align="center" prop="syncStatus" width="100">
        <template #default="s"><el-tag v-if="s.row.syncStatus" :type="syncTag(s.row.syncStatus)">{{ syncText(s.row.syncStatus) }}</el-tag><span v-else>-</span></template>
      </el-table-column>
      <el-table-column fixed="right" label="操作" align="center" width="180" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleView(scope.row)">查看</el-button>
          <el-button v-if="canQuote(scope.row)" link type="success" @click="handleEdit(scope.row)" v-hasPermi="['mes:sal:quote:edit']">报价</el-button>
          <el-button link type="danger" v-hasPermi="['mes:sal:quote:remove']" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <QuoteEditDialog ref="editDialogRef" @success="getList" />
  </div>
</template>

<script>
import { getDicts } from '@/api/system/dict/data'
import { listQuote, delQuote } from '@/api/mes/sal/quote'
import QuoteEditDialog from './QuoteEditDialog.vue'

export default {
  name: 'SalQuote',
  components: { QuoteEditDialog },
  data() {
    return {
      loading: true,
      showSearch: true,
      total: 0,
      quoteList: [],
      statusOptions: [],
      queryParams: { pageNum: 1, pageSize: 10, quoteCode: null, externalQuoteNo: null, title: null, clientName: null, status: null }
    }
  },
  created() { this.loadStatusDict(); this.getList() },
  methods: {
    getList() {
      this.loading = true
      listQuote(this.queryParams).then(r => { this.quoteList = r.rows; this.total = r.total; this.loading = false }).catch(() => { this.loading = false })
    },
    loadStatusDict() { getDicts('mes_sal_quote_status').then(r => { this.statusOptions = r.data || [] }) },
    statusMeta(s) {
      const d = this.statusOptions.find(o => o.dictValue === s)
      return { text: d ? d.dictLabel : (s || ''), type: d && d.listClass ? d.listClass : '' }
    },
    syncText(s) { return { PENDING: '待回写', SUCCESS: '已回写', FAILED: '回写失败' }[s] || s },
    syncTag(s) { return s === 'SUCCESS' ? 'success' : s === 'FAILED' ? 'danger' : 'warning' },
    canQuote(row) { return ['PENDING_QUOTE', 'RETURNED'].includes(row.status) },
    handleQuery() { this.queryParams.pageNum = 1; this.getList() },
    resetQuery() { this.resetForm('queryRef'); this.handleQuery() },
    handleView(row) { this.$refs.editDialogRef.open(row.quoteId, true) },
    handleEdit(row) { this.$refs.editDialogRef.open(row.quoteId, false) },
    handleDelete(row) {
      this.$modal.confirm('是否确认删除报价单 "' + row.quoteCode + '" ？删除后列表中不再显示，数据仍保留可追溯。')
        .then(() => delQuote(row.quoteId))
        .then(() => { this.getList(); this.$modal.msgSuccess('删除成功') })
        .catch(() => {})
    }
  }
}
</script>
