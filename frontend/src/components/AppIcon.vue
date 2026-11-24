<template>
  <!-- 图标尺寸自带 width/height，作为兜底：即使外层样式没命中也不会撑满父容器 -->
  <el-icon v-if="epIcon" :size="size" :color="color" class="app-icon">
    <component :is="epIcon" width="1em" height="1em" />
  </el-icon>
  <svg-icon v-else :icon-class="iconClass" :class-name="className" :color="color" />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import SvgIcon from '@/components/SvgIcon/index.vue'

const props = withDefaults(defineProps<{
  iconClass: string
  className?: string
  color?: string
  size?: string | number
}>(), {
  className: '',
  color: '',
  size: undefined
})

// Map of SVG icon names → Element Plus icon component names
const iconMap: Record<string, string> = {
  'user': 'User',
  'peoples': 'UserFilled',
  'password': 'Lock',
  'validCode': 'PictureFilled',
  'phone': 'Phone',
  'email': 'Message',
  'tree': 'List',
  'date': 'Calendar',
  'search': 'Search',
  'enter': 'Enter',
  'bell': 'Bell',
  'sunny': 'Sunny',
  'moon': 'Moon',
  'fullscreen': 'FullScreen',
  'exit-fullscreen': 'FullScreen',
  'size': 'Switch',
  'github': 'Link',
  'question': 'QuestionFilled',
  'table': 'Grid',
  'tree-table': 'Grid',
  'component': 'Setting',
  'monitor': 'Monitor',
  'chart': 'DataAnalysis',
  'eye': 'View',
  'eye-open': 'View',
  'message': 'Message',
  'log': 'Tickets',
  'job': 'Timer',
  'online': 'Connection',
  'server': 'Cpu',
  'cache': 'Coin',
  'redis': 'Coin',
  'dict': 'Collection',
  'config': 'Tools',
  'post': 'Stamp',
  'dept': 'OfficeBuilding',
  'menu': 'Menu',
  'role': 'Avatar',
  'system': 'HomeFilled',
  'logininfor': 'Reading',
  'operlog': 'Notebook',
  'documentation': 'Document',
  'link': 'Link',
  'edit': 'Edit',
  'star': 'Star',
  'drag': 'Rank',
  'clipboard': 'CopyDocument',
  'excel': 'Upload',
  'pdf': 'Picture',
  'zip': 'Folder',
  'tool': 'Tools',
  'lock': 'Lock',
  'shopping': 'ShoppingCart',
  'skill': 'MagicStick',
  'time': 'Timer',
  'nested': 'FolderOpened',
  'bug': 'WarningFilled',
  'guide': 'Guide',
  'education': 'Reading',
  'international': 'Promotion',
  'dashboard': 'Odometer',
  'home': 'HomeFilled',
  'language': 'ChatDotRound',
  'wechat': 'ChatLineSquare',
  'color': 'Brush',
  'number': 'Sort',
  'upload': 'Upload',
  'download': 'Download',
  'slider': 'Switch',
  'checkbox': 'Select',
  'radio': 'CircleCheck',
  'select': 'ArrowDown',
  'rate': 'StarFilled',
  'date-range': 'Calendar',
  'time-range': 'Timer',
  'input': 'EditPen',
  'textarea': 'Document',
  'switch': 'Switch',
  'button': 'SwitchButton',
  'code': 'Code',
  'icon': 'Picture',
  'druid': 'Monitor',
  'swagger': 'Document',
  'row': 'Operation',
  'cascader': 'Operation',
  'tab': 'Tickets',
  'form': 'Document',
  'build': 'Setting',
  'list': 'List',
  'more-up': 'ArrowUp',
  'qq': 'ChatLineRound',
  'money': 'Money',
}

// 注意：变量名不能叫 elIcon。Vue 编译 <el-icon> 时会把标签名转驼峰去匹配 setup 绑定，
// 一旦存在同名变量，<el-icon> 就会被解析成这个变量（图标组件本身），
// Element Plus 的 el-icon 包装层不会渲染，图标失去 1em 尺寸约束、撑满父容器。
const epIcon = computed(() => {
  if (!props.iconClass) return null
  // Try direct mapping
  const mapped = iconMap[props.iconClass]
  if (mapped) return (ElementPlusIconsVue as any)[mapped] || null
  // Try capitalized
  const cap = props.iconClass.charAt(0).toUpperCase() + props.iconClass.slice(1)
  return (ElementPlusIconsVue as any)[cap] || null
})
</script>
