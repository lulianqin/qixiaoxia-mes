<template>
  <div class="app-container home">
    <!-- 我的待办 -->
    <TodoPanel />

    <!-- 功能快捷入口 -->
    <div class="section-title">功能快捷入口</div>
    <el-row :gutter="16" class="mes-modules">
      <el-col :xs="12" :sm="8" :md="4" v-for="mod in modules" :key="mod.key">
        <div class="module-card" @click="goModule(mod.path)">
          <div class="module-icon" :style="{ background: mod.color }">
            <AppIcon :icon-class="mod.icon" :size="22" />
          </div>
          <span class="module-name">{{ mod.name }}</span>
          <span class="module-desc">{{ mod.desc }}</span>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts" name="Index">
import { useRouter } from 'vue-router'
import TodoPanel from './components/TodoPanel.vue'

const router = useRouter()

// MES 功能模块快捷入口
const modules = [
  { key: 'md', name: '基础数据', desc: '物料 · BOM · 工艺', icon: 'table', color: '#1a3c5e', path: '/mes/md/item' },
  { key: 'wm', name: '仓储管理', desc: '出入库 · 库存 · 盘点', icon: 'tree-table', color: '#2a5a8a', path: '/mes/wm/material_stock' },
  { key: 'pro', name: '生产管理', desc: '工单 · 流转 · 报工', icon: 'component', color: '#30B08F', path: '/mes/pro/workorder' },
  { key: 'qc', name: '质量管理', desc: '检验 · 不良品', icon: 'validCode', color: '#c9a96e', path: '/qc/qcindex' },
  { key: 'dv', name: '设备工具管理', desc: '设备 · 工装', icon: 'monitor', color: '#5a7ea0', path: '/mes/dv/machinery' },
  { key: 'report', name: '报表分析', desc: '生产 · 质量 · 库存', icon: 'chart', color: '#1a3c5e', path: '/mes/pro/report' },
]

function goModule(path: string): void {
  // 直接跳转到模块内首个业务页面，避免跳转目录级路由导致空白
  router.push(path).catch(() => {})
}
</script>

<style scoped lang="scss">
.home {
  font-family: "open sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
  font-size: 13px;
  color: #676a6c;
  overflow-x: hidden;

  .section-title {
    margin: 8px 0 12px;
    font-size: 15px;
    font-weight: 600;
    color: #303133;
  }

  .mes-modules {
    margin-bottom: 4px;

    .module-card {
      background: #fff;
      border-radius: 8px;
      padding: 20px 12px;
      text-align: center;
      cursor: pointer;
      transition: all 0.3s;
      border: 1px solid #ebeef5;
      margin-bottom: 12px;

      &:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(12, 215, 189, 0.2);
        border-color: #0cd7bd;
      }

      .module-icon {
        width: 44px;
        height: 44px;
        margin: 0 auto 10px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        color: #fff;
      }

      .module-name {
        display: block;
        font-size: 14px;
        font-weight: 600;
        color: #303133;
        margin-bottom: 4px;
      }

      .module-desc {
        display: block;
        font-size: 11px;
        color: #909399;
      }
    }
  }
}
</style>
