<template>
  <el-breadcrumb class="app-breadcrumb" separator="/">
    <transition-group name="breadcrumb">
      <el-breadcrumb-item v-for="(item, index) in levelList" :key="item.path">
        <span v-if="item.redirect === 'noRedirect' || index == levelList.length - 1" class="no-redirect">{{ item.meta.title }}</span>
        <a v-else @click.prevent="handleLink(item)">{{ item.meta.title }}</a>
      </el-breadcrumb-item>
    </transition-group>
  </el-breadcrumb>
</template>

<script setup lang="ts">
const route = useRoute()
const router = useRouter()
const levelList = ref<any[]>([])

function getBreadcrumb(): void {
  // 直接用路由匹配链，避免多段路径按首段 "mes" 误匹配到第一个菜单（设备工具管理）
  let matched: any[] = route.matched.filter((item: any) => item.meta && item.meta.title)
  // 判断是否为首页
  if (!matched.length || !isDashboard(matched[0])) {
    matched = [{ path: "/index", meta: { title: "首页" } }].concat(matched)
  }
  levelList.value = matched.filter(item => item.meta && item.meta.title && (item.meta.breadcrumb as boolean) !== false)
}
function isDashboard(route?: any): boolean {
  const name = route && route.name
  if (!name) {
    return false
  }
  return String(name).trim() === 'Index'
}
function handleLink(item: any): void {
  const { redirect, path } = item
  if (redirect) {
    router.push(redirect as string)
    return
  }
  router.push(path)
}

watchEffect(() => {
  // if you go to the redirect page, do not update the breadcrumbs
  if (route.path.startsWith('/redirect/')) {
    return
  }
  getBreadcrumb()
})
getBreadcrumb()
</script>

<style lang='scss' scoped>
.app-breadcrumb.el-breadcrumb {
  display: inline-block;
  font-size: 14px;
  line-height: 50px;

  .no-redirect {
    color: #97a8be;
    cursor: text;
  }
}
</style>