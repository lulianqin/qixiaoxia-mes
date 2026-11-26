<template>
  <!--
    动态扩展属性表单（物料/销售行/采购行/工单/流转单 共用）
    schema: 属性定义列表（来自 getEffAttrSchema，含继承）
    modelValue: { attrCode: value } 扁平值对象
    scope: 只渲染指定属性域（PRODUCT-产品属性 / PRODUCTION-生产属性 / DOC-单据属性），不传则不渲染单据属性
    plain: 只读展示形态（流转单预览用），不渲染输入控件
    schema 中没有但 modelValue 里存在的 key → 作为"游离历史值"只读降级展示（设计文档 12.1）
  -->
  <div class="ext-attr-form">
    <el-empty v-if="!renderList.length" description="该分类未配置扩展属性" :image-size="60" />
    <div v-else-if="plain" class="ext-attr-plain">
      <div v-for="item in renderList" :key="item.attrCode" class="ext-attr-plain-row">
        <span class="ext-attr-plain-label">{{ labelText(item) }}</span>
        <span class="ext-attr-plain-value">
          <template v-if="widgetOf(item) === 'IMAGE'">
            <el-image v-if="formData[item.attrCode!]" :src="formData[item.attrCode!]" :preview-src-list="[formData[item.attrCode!]]"
                      fit="contain" class="ext-attr-image" preview-teleported />
            <span v-else>-</span>
          </template>
          <template v-else-if="widgetOf(item) === 'FILE'">
            <template v-if="fileList(item).length">
              <el-link v-for="(f, i) in fileList(item)" :key="i" :href="f.url" target="_blank" type="primary"
                       underline="never" class="ext-attr-file">{{ f.name }}</el-link>
            </template>
            <span v-else>-</span>
          </template>
          <template v-else>{{ displayValue(item) }}</template>
        </span>
      </div>
    </div>
    <el-form v-else ref="formRef" :model="formData" label-width="120px" class="ext-attr-inner" :class="{ 'is-grid': columns > 1 }">
      <el-row :gutter="12">
        <el-col v-for="(item, idx) in renderList" :key="item.attrCode" :span="colSpan">
          <el-form-item
            :label="labelText(item)"
            :prop="item.attrCode"
            :rules="item.required === '1' ? [{ required: true, message: `${item.attrName}不能为空`, trigger: 'blur' }] : undefined"
          >
            <template #label v-if="sortable && !readonly">
              <span class="drag-handle" draggable="true" title="拖动排序"
                @dragstart="onDragStart(idx)" @dragover.prevent @drop="onDrop(idx)">⋮⋮</span>
              <span class="lbl-text">{{ labelText(item) }}</span>
            </template>
            <!-- 文本 -->
            <el-input v-if="widgetOf(item) === 'TEXT'"
              v-model="formData[item.attrCode!]" placeholder="请输入" clearable :disabled="item.readonly" />
            <!-- 多行文本 -->
            <el-input v-else-if="widgetOf(item) === 'TEXTAREA'"
              v-model="formData[item.attrCode!]" type="textarea" :rows="3" placeholder="请输入" :disabled="item.readonly" />
            <!-- 数字 -->
            <el-input-number v-else-if="widgetOf(item) === 'NUMBER'"
              v-model="formData[item.attrCode!]" :controls="false" style="width: 100%"
              placeholder="请输入" :disabled="item.readonly" />
            <!-- 单选 -->
            <el-select v-else-if="widgetOf(item) === 'SELECT'"
              v-model="formData[item.attrCode!]" placeholder="请选择" clearable :disabled="item.readonly" style="width: 100%">
              <el-option v-for="opt in parseOptions(item.optionsJson)" :key="opt" :label="opt" :value="opt" />
            </el-select>
            <!-- 多选 -->
            <el-select v-else-if="widgetOf(item) === 'MULTI_SELECT'"
              v-model="formData[item.attrCode!]" placeholder="请选择" multiple clearable collapse-tags
              :disabled="item.readonly" style="width: 100%">
              <el-option v-for="opt in parseOptions(item.optionsJson)" :key="opt" :label="opt" :value="opt" />
            </el-select>
            <!-- 开关 -->
            <el-switch v-else-if="widgetOf(item) === 'BOOL'"
              v-model="formData[item.attrCode!]" :disabled="item.readonly" />
            <!-- 日期 -->
            <el-date-picker v-else-if="widgetOf(item) === 'DATE'"
              v-model="formData[item.attrCode!]" type="date" value-format="YYYY-MM-DD"
              placeholder="请选择" :disabled="item.readonly" style="width: 100%" />
            <!-- 图片 -->
            <image-upload v-else-if="widgetOf(item) === 'IMAGE'"
              v-model="formData[item.attrCode!]" :limit="1" :disabled="item.readonly" />
            <!-- 附件 -->
            <file-upload v-else-if="widgetOf(item) === 'FILE'"
              v-model="formData[item.attrCode!]" :limit="5" :disabled="item.readonly" />
          </el-form-item>
        </el-col>
      </el-row>
    </el-form>
  </div>
</template>

<script setup lang="ts">
import { computed, reactive, watch, ref } from 'vue'
import type { MdItemTypeAttr } from '@/types/api/mes/md/attr'

/** 游离历史值（schema 中已删除但 lineAttrs 里残留的 key）的哨兵标记 */
const LEGACY_ATTR_ID = -1
const LEGACY_INHERIT_DEPTH = -1

const props = defineProps<{
  schema: MdItemTypeAttr[]
  modelValue?: Record<string, any>
  /** 是否只读（单据查看态） */
  readonly?: boolean
  /** 只渲染指定属性域：PRODUCT-产品属性 / PRODUCTION-生产属性 / DOC-单据属性 */
  scope?: 'PRODUCT' | 'PRODUCTION' | 'DOC'
  /** 只读展示形态：不渲染输入控件，按文本/图片/附件展示 */
  plain?: boolean
  /** 每行列数（默认 1，开单页传 3） */
  columns?: number
  /** 是否允许拖动排序 */
  sortable?: boolean
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', val: Record<string, any>): void
}>()

// 内部可编辑数据副本
const formData = reactive<Record<string, any>>({})

/** 每列栅格宽度：3 列 = 8 */
const colSpan = computed(() => Math.floor(24 / Math.max(1, props.columns || 1)))

/** 属性展示顺序（拖动排序时维护；默认按 schema 顺序） */
const orderKeys = ref<string[]>([])

watch(() => props.schema, (list: any[]) => {
  const keys = (list || []).map((s: any) => s.attrCode).filter(Boolean) as string[]
  const kept = orderKeys.value.filter((k: string) => keys.includes(k))
  const added = keys.filter((k: string) => !kept.includes(k))
  orderKeys.value = [...kept, ...added]
}, { immediate: true })

let dragIdx: number | null = null
function onDragStart(idx: number) { dragIdx = idx }
function onDrop(idx: number) {
  if (dragIdx === null || dragIdx === idx) return
  const arr = [...orderKeys.value]
  const [moved] = arr.splice(dragIdx, 1)
  arr.splice(idx, 0, moved)
  orderKeys.value = arr
  dragIdx = null
}

/** 合并 schema 属性 + modelValue 中游离的历史 key（降级只读展示） */
const renderList = computed<(MdItemTypeAttr & { readonly?: boolean })[]>(() => {
  const list: (MdItemTypeAttr & { readonly?: boolean })[] = []
  const covered = new Set<string>()
  for (const s of props.schema || []) {
    if (!s.attrCode) continue
    const scope = s.attrScope || 'PRODUCT'
    // 单据属性只在单据配置页显式指定 DOC 时渲染，避免混入产品/生产等页面
    if (props.scope ? scope !== props.scope : scope === 'DOC') continue
    list.push({ ...s, readonly: props.readonly })
    covered.add(s.attrCode)
  }
  // 游离历史值：仅在未按属性域过滤时展示，避免把生产属性混进产品属性区
  if (!props.scope && props.modelValue) {
    for (const key of Object.keys(props.modelValue)) {
      if (!covered.has(key) && props.modelValue[key] !== null && props.modelValue[key] !== undefined && props.modelValue[key] !== '') {
        list.push({
          attrId: LEGACY_ATTR_ID, attrCode: key, attrName: key, attrType: 'TEXT',
          inheritDepth: LEGACY_INHERIT_DEPTH, readonly: true
        })
      }
    }
  }
  if (orderKeys.value.length) {
    const pos = new Map<string, number>(
      orderKeys.value.map((k: string, i: number) => [k, i] as [string, number])
    )
    list.sort((a: any, b: any) => (pos.get(a.attrCode!) ?? 9999) - (pos.get(b.attrCode!) ?? 9999))
  }
  return list
})

/** 控件类型：新数据取 widgetType，历史数据回退 attrType */
function widgetOf(item: MdItemTypeAttr): string {
  return item.widgetType || item.attrType || 'TEXT'
}

function labelText(item: MdItemTypeAttr): string {
  return item.attrName + (item.attrUnit ? `(${item.attrUnit})` : '')
    + (item.inheritDepth && item.inheritDepth > 0 ? ' [继承]' : '')
}

function parseOptions(optionsJson?: string): string[] {
  if (!optionsJson) return []
  try {
    const arr = JSON.parse(optionsJson)
    return Array.isArray(arr) ? arr : []
  } catch {
    return []
  }
}

function displayValue(item: MdItemTypeAttr): string {
  const val = formData[item.attrCode!]
  if (val === null || val === undefined || val === '') return '-'
  if (widgetOf(item) === 'BOOL') return val === true || val === '1' || val === 1 ? '是' : '否'
  if (Array.isArray(val)) return val.join('、')
  return String(val)
}

function fileList(item: MdItemTypeAttr) {
  const val = formData[item.attrCode!]
  if (!val) return []
  return String(val).split(',').filter(Boolean).map(url => ({
    url: url.startsWith('http') ? url : url,
    name: url.substring(url.lastIndexOf('/') + 1) || url
  }))
}

// modelValue → formData（外部变化时同步）
watch(() => props.modelValue, (val: Record<string, any> | undefined) => {
  if (!val) return
  for (const k of Object.keys(val)) {
    if (formData[k] !== val[k]) formData[k] = val[k]
  }
}, { immediate: true, deep: true })

// formData → emit（内部编辑时上抛）
// 注意：合并父级传入值与内部编辑值，避免覆盖父级单独绑定的业务字段（如采购 PAPER_ROLL_COUNT）
watch(formData, (val: Record<string, any>) => {
  emit('update:modelValue', { ...(props.modelValue || {}), ...val })
}, { deep: true })

/** 暴露校验方法（供父组件提交前调用） */
async function validate() {
  // el-form 无 ref 绑定时跳过；这里通过 DOM 校验 required
  for (const item of props.schema || []) {
    if (item.required === '1' && item.attrCode) {
      const v = formData[item.attrCode]
      if (v === null || v === undefined || v === '' || (Array.isArray(v) && !v.length)) {
        return Promise.reject(new Error(`${item.attrName}不能为空`))
      }
    }
  }
  return Promise.resolve()
}
defineExpose({ validate })
</script>

<style scoped>
.ext-attr-form { width: 100%; }
.ext-attr-inner { max-width: 600px; }
.ext-attr-inner.is-grid { max-width: 100%; }
/* 文本/数字控件统一左对齐 */
.ext-attr-inner :deep(.el-input__inner),
.ext-attr-inner :deep(.el-textarea__inner) { text-align: left; }
.drag-handle { cursor: move; color: #c0c4cc; margin-right: 4px; font-size: 12px; user-select: none; }
.lbl-text { white-space: nowrap; }
.ext-attr-plain { border: 1px solid #ebeef5; border-radius: 4px; overflow: hidden; }
.ext-attr-plain-row { display: flex; border-bottom: 1px solid #ebeef5; font-size: 13px; }
.ext-attr-plain-row:last-child { border-bottom: none; }
.ext-attr-plain-label { width: 140px; flex: 0 0 140px; padding: 8px 12px; background: #fafafa; color: #606266; }
.ext-attr-plain-value { flex: 1; padding: 8px 12px; color: #303133; word-break: break-all; }
.ext-attr-image { width: 80px; height: 80px; border-radius: 4px; }
.ext-attr-file { margin-right: 12px; }
</style>
