<template>
  <el-card shadow="never" class="mb16">
    <template #header>
      <div class="card-head">
        <span>物料清单与备货（{{ rows.length }}）</span>
        <div>
          <el-tag size="small" :type="shortageCount > 0 ? 'danger' : 'success'">
            {{ shortageCount > 0 ? '缺料 ' + shortageCount + ' 项' : '已齐套' }}
          </el-tag>
          <el-button v-if="editable" link type="primary" icon="Plus" size="small" class="ml8" @click="openAdd" v-hasPermi="['mes:pro:workorder:add']">添加物料</el-button>
          <el-button link type="primary" size="small" class="ml8" @click="load">刷新</el-button>
        </div>
      </div>
    </template>

    <el-table v-loading="loading" :data="rows" size="small" border>
      <el-table-column label="物料编码" prop="itemCode" width="130" :show-overflow-tooltip="true" />
      <el-table-column label="物料名称" prop="itemName" min-width="150" :show-overflow-tooltip="true" />
      <el-table-column label="来源" width="90" align="center">
        <template #default="s">
          <el-tag size="small" :type="s.row.bomSource === 'PRODUCT' ? 'info' : ''">
            {{ s.row.bomSource === 'PRODUCT' ? '产品BOM' : s.row.bomSource === 'MANUAL' ? '手工' : '工序BOM' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="单位用量" width="150" align="center">
        <template #default="s">
          <div class="qty-cell">
            <el-input-number v-if="editable" v-model="s.row.quantity" :min="0" :precision="4" :controls="false" size="small" style="width:76px" @change="markDirty(s.row)" />
            <span v-else>{{ s.row.quantity }}</span>
            <span class="unit-text">{{ s.row.unitName }}</span>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="计量单位" width="110" align="center">
        <template #default="s">
          <el-select v-if="editable" :model-value="s.row.unitOfMeasure" size="small" @change="(v: string) => onUnitChange(s.row, v)">
            <el-option v-for="u in unitOptions(s.row)" :key="u.code" :label="u.name" :value="u.code" />
          </el-select>
          <span v-else>{{ s.row.unitName }}</span>
        </template>
      </el-table-column>
      <el-table-column label="用量方式" width="110" align="center">
        <template #default="s">
          <el-select v-if="editable" v-model="s.row.quantityMode" size="small" @change="markDirty(s.row)">
            <el-option label="按件用量" value="PER_UNIT" />
            <el-option label="整单总量" value="TOTAL" />
          </el-select>
          <span v-else>{{ s.row.quantityMode === 'TOTAL' ? '整单总量' : '按件用量' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="损耗率" width="100" align="center">
        <template #default="s">
          <el-input-number v-if="editable" v-model="s.row.scrapRate" :min="0" :max="1" :step="0.01" :precision="4" :controls="false" size="small" style="width:100%" @change="markDirty(s.row)" />
          <span v-else>{{ ((s.row.scrapRate || 0) * 100).toFixed(2) }}%</span>
        </template>
      </el-table-column>
      <el-table-column label="需求总量(库存单位)" width="130" align="right">
        <template #default="s">{{ s.row.requiredQty ?? s.row.totalQuantity ?? '-' }} {{ s.row.stockUnitName || '' }}</template>
      </el-table-column>
      <el-table-column label="可用库存" width="100" align="right">
        <template #default="s">{{ s.row.availableQty ?? '-' }} {{ s.row.stockUnitName || '' }}</template>
      </el-table-column>
      <el-table-column label="本单已占" width="100" align="right">
        <template #default="s">{{ s.row.workorderReservedQty ?? 0 }} {{ s.row.stockUnitName || '' }}</template>
      </el-table-column>
      <el-table-column label="缺口" width="100" align="right">
        <template #default="s">
          <span :style="{ color: Number(s.row.shortageQty) > 0 ? '#F56C6C' : '#67C23A' }">{{ s.row.shortageQty ?? 0 }} {{ s.row.stockUnitName || '' }}</span>
        </template>
      </el-table-column>
      <el-table-column v-if="editable" label="操作" width="130" align="center" fixed="right">
        <template #default="s">
          <el-button link type="primary" size="small" :disabled="!s.row._dirty" @click="saveRow(s.row)" v-hasPermi="['mes:pro:workorder:edit']">保存</el-button>
          <el-button link type="danger" size="small" @click="deleteRow(s.row)" v-hasPermi="['mes:pro:workorder:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="addOpen" title="添加工单物料" width="620px" append-to-body>
      <el-form label-width="90px">
        <el-form-item label="物料" required>
          <el-input v-model="addForm.itemName" readonly placeholder="请选择物料">
            <template #append><el-button icon="Search" @click="itemSelectRef?.open()" /></template>
          </el-input>
        </el-form-item>
        <el-row>
          <el-col :span="12"><el-form-item label="单位用量"><el-input-number v-model="addForm.quantity" :min="0" :precision="4" style="width:100%" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="用量方式"><el-select v-model="addForm.quantityMode" style="width:100%"><el-option label="按件用量" value="PER_UNIT" /><el-option label="整单总量" value="TOTAL" /></el-select></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="12"><el-form-item label="损耗率"><el-input-number v-model="addForm.scrapRate" :min="0" :max="1" :step="0.01" :precision="4" style="width:100%" /></el-form-item></el-col>
          <el-col :span="12">
            <el-form-item label="单位">
              <el-select v-model="addForm.unitOfMeasure" style="width:100%" @change="onAddUnitChange">
                <el-option v-for="u in addUnitOptions" :key="u.code" :label="u.name" :value="u.code" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-alert v-if="addUnitOptions.length > 1" type="info" :closable="false" show-icon
          title="用量按所选单位录入，库存与齐套统一折算为主单位统计" />
      </el-form>
      <template #footer>
        <el-button type="primary" :loading="addSaving" @click="submitAdd">确 定</el-button>
        <el-button @click="addOpen = false">取 消</el-button>
      </template>
    </el-dialog>
    <ItemSelect ref="itemSelectRef" @onSelected="onItemSelected" />
  </el-card>
</template>

<script setup lang="ts" name="WorkorderMaterialPanel">
import { ref, computed, watch, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import ItemSelect from '@/components/itemSelect/single.vue'
import { listBomByWorkorderId, addWorkorderBom, updateWorkorderBom, delWorkorderBom } from '@/api/mes/pro/workorderbom'
import { loadKitDashboard } from '@/api/mes/pro/kit'

const props = defineProps<{ workorderId: number; editable?: boolean }>()
const emit = defineEmits<{ changed: [] }>()

const loading = ref(false)
const rows = ref<any[]>([])
const addOpen = ref(false)
const addSaving = ref(false)
const itemSelectRef = ref()
const addItem = ref<any>(null)
const addForm = ref<any>({ itemId: null, itemCode: '', itemName: '', unitOfMeasure: '', unitName: '', unit2: '', unit2Name: '', conversionRate: null, quantity: 1, quantityMode: 'PER_UNIT', scrapRate: 0 })

const shortageCount = computed(() => rows.value.filter(r => Number(r.shortageQty) > 0).length)

const addUnitOptions = computed(() => {
  const it = addItem.value
  if (!it) return []
  const list = [
    { code: it.unitOfMeasure, name: it.unitName },
    { code: it.unit2, name: it.unit2Name }
  ].filter(u => u.code)
  return list.filter((u, i, arr) => arr.findIndex(x => x.code === u.code) === i)
})

function unitOptions(row: any) {
  const list = [
    { code: row.unitOfMeasure, name: row.unitName },
    { code: row.unit2, name: row.unit2Name }
  ].filter(u => u.code)
  return list.filter((u, i, arr) => arr.findIndex(x => x.code === u.code) === i)
}

function load() {
  if (!props.workorderId) return
  loading.value = true
  Promise.all([
    listBomByWorkorderId(props.workorderId),
    loadKitDashboard(props.workorderId).catch(() => null)
  ]).then(([bomRes, kitRes]: any[]) => {
    const boms = bomRes?.data || bomRes?.rows || []
    const kitRows = kitRes?.data?.materialRows || []
    const kitByLine = new Map(kitRows.map((k: any) => [k.lineId, k]))
    rows.value = boms.map((b: any) => {
      const k: any = kitByLine.get(b.lineId) || {}
      return {
        ...b,
        requiredQty: k.requiredQty,
        availableQty: k.availableQty,
        lockedQty: k.lockedQty,
        reservedForOrder: k.reservedForOrder,
        workorderReservedQty: k.workorderReservedQty,
        shortageQty: k.shortageQty,
        stockUnitName: k.unitName,
        _dirty: false
      }
    })
  }).finally(() => { loading.value = false })
}

function markDirty(row: any) { row._dirty = true }

/** 主单位/辅助单位切换：选中辅助单位时交换主副，保证两者都保留 */
function onUnitChange(row: any, v: string) {
  if (!v || v === row.unitOfMeasure) return
  if (v === row.unit2) {
    const code = row.unitOfMeasure
    const name = row.unitName
    row.unitOfMeasure = row.unit2
    row.unitName = row.unit2Name
    row.unit2 = code
    row.unit2Name = name
  } else {
    const opt = unitOptions(row).find(u => u.code === v)
    if (opt) { row.unitOfMeasure = opt.code; row.unitName = opt.name }
  }
  row._dirty = true
}

function saveRow(row: any) {
  updateWorkorderBom({
    lineId: row.lineId, quantity: row.quantity, quantityMode: row.quantityMode, scrapRate: row.scrapRate,
    unitOfMeasure: row.unitOfMeasure, unitName: row.unitName,
    unit2: row.unit2, unit2Name: row.unit2Name, conversionRate: row.conversionRate
  })
    .then((r: any) => {
      if (r.code !== 200) return
      ElMessage.success('已保存，备货预占已重算')
      row._dirty = false
      load()
      emit('changed')
    })
}

function deleteRow(row: any) {
  ElMessageBox.confirm('删除物料【' + (row.itemName || row.itemCode) + '】后，相关预占会释放，是否继续？', '提示', { type: 'warning' })
    .then(() => delWorkorderBom(row.lineId))
    .then((r: any) => {
      if (r?.code !== 200) return
      ElMessage.success('已删除')
      load()
      emit('changed')
    })
    .catch(() => {})
}

function openAdd() {
  addItem.value = null
  addForm.value = { itemId: null, itemCode: '', itemName: '', unitOfMeasure: '', unitName: '', unit2: '', unit2Name: '', conversionRate: null, quantity: 1, quantityMode: 'PER_UNIT', scrapRate: 0 }
  addOpen.value = true
}

function onItemSelected(item: any) {
  addItem.value = item
  addForm.value.itemId = item.itemId
  addForm.value.itemCode = item.itemCode
  addForm.value.itemName = item.itemName
  addForm.value.unitOfMeasure = item.unitOfMeasure
  addForm.value.unitName = item.unitName
  addForm.value.unit2 = item.unit2
  addForm.value.unit2Name = item.unit2Name
  addForm.value.conversionRate = item.conversionRate
}

function onAddUnitChange() {
  // 单位只决定录入口径，提交时再换算主副
}

function submitAdd() {
  const f = addForm.value
  const it = addItem.value
  if (!f.itemId) { ElMessage.warning('请选择物料'); return }
  if (!(Number(f.quantity) > 0)) { ElMessage.warning('单位用量必须大于 0'); return }
  // 业务单位 = 用户选择的单位；另一个单位作为辅助单位保存
  const isAux = it && f.unitOfMeasure === it.unit2
  const business = isAux
    ? { code: it.unit2, name: it.unit2Name }
    : { code: it?.unitOfMeasure, name: it?.unitName }
  const secondary = isAux
    ? { code: it.unitOfMeasure, name: it.unitName }
    : { code: it?.unit2, name: it?.unit2Name }
  addSaving.value = true
  addWorkorderBom({
    workorderId: props.workorderId, itemId: f.itemId, itemCode: f.itemCode, itemName: f.itemName,
    unitOfMeasure: business.code, unitName: business.name,
    unit2: secondary.code || null, unit2Name: secondary.name || null,
    conversionRate: it?.conversionRate ?? null,
    quantity: f.quantity, quantityMode: f.quantityMode, scrapRate: f.scrapRate,
    bomSource: 'MANUAL', itemOrProduct: 'RAW'
  }).then((r: any) => {
    if (r.code !== 200) return
    ElMessage.success('已添加，备货预占已重算')
    addOpen.value = false
    load()
    emit('changed')
  }).finally(() => { addSaving.value = false })
}

watch(() => props.workorderId, load)
onMounted(load)
</script>

<style scoped>
.card-head { display: flex; align-items: center; justify-content: space-between; }
.ml8 { margin-left: 8px; }
.qty-cell { display: flex; align-items: center; justify-content: center; gap: 4px; }
.unit-text { color: #909399; font-size: 12px; }
</style>
