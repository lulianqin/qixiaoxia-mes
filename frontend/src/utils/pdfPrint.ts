/** 直接调起系统打印（浏览器打印对话框本身带预览，不再做页面内预览） */
export function printPdfBlob(blob: Blob) {
  const url = URL.createObjectURL(new Blob([blob], { type: 'application/pdf' }))
  const iframe = document.createElement('iframe')
  iframe.style.cssText = 'position:fixed;right:0;bottom:0;width:0;height:0;border:0'
  iframe.src = url
  iframe.onload = () => {
    setTimeout(() => {
      try {
        iframe.contentWindow?.focus()
        iframe.contentWindow?.print()
      } catch (e) {
        // 某些浏览器禁止直接打印时忽略，用户可手动打开
      }
    }, 300)
    setTimeout(() => {
      document.body.removeChild(iframe)
      URL.revokeObjectURL(url)
    }, 60000)
  }
  document.body.appendChild(iframe)
}
