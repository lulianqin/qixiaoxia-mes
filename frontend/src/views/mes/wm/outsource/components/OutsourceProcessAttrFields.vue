<template>
  <div class="attr-fields">
    <el-empty v-if="!schema || schema.length === 0" description="该工序未配置扩展属性" :image-size="40" />
    <el-form v-else label-width="110px" size="small">
      <el-row>
        <el-col :span="8" v-for="attr in schema" :key="attr.attrCode">
          <el-form-item :label="attrLabel(attr)" :required="attr.required === '1'">
            <el-select v-if="attr.attrType === 'SELECT'" v-model="modelValue[attr.attrCode]" clearable
              placeholder="请选择" style="width:100%">
              <el-option v-for="opt in parseOptions(attr.optionsJson)" :key="opt" :label="opt" :value="opt" />
            </el-select>
            <el-input-number v-else-if="attr.attrType === 'NUMBER'" v-model="modelValue[attr.attrCode]"
              :controls="false" style="width:100%" />
            <el-switch v-else-if="attr.attrType === 'BOOL'" v-model="modelValue[attr.attrCode]" />
            <el-date-picker v-else-if="attr.attrType === 'DATE'" v-model="modelValue[attr.attrCode]"
              type="date" value-format="YYYY-MM-DD" style="width:100%" />
            <el-input v-else v-model="modelValue[attr.attrCode]" placeholder="请输入" />
          </el-form-item>
        </el-col>
      </el-row>
    </el-form>
  </div>
</template>

<script setup lang="ts">
defineProps<{ schema: any[]; modelValue: Record<string, any> }>()

function attrLabel(attr: any) {
  return attr.attrName + (attr.attrUnit ? `(${attr.attrUnit})` : '')
}

function parseOptions(json?: string) {
  if (!json) return []
  try {
    const arr = JSON.parse(json)
    return Array.isArray(arr) ? arr : []
  } catch {
    return []
  }
}
</script>

<style scoped>
.attr-fields { padding: 4px 12px; }
</style>
