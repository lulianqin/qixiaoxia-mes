import { PageDomain } from "@/types/api/common"

export interface WmSalesApplyQueryParams extends PageDomain {
  applyCode?: string
  externalOrderNo?: string
  salesOrderCode?: string
  status?: string
}

/** 出库申请行（ERP 采购单行口径） */
export interface WmSalesApplyLine {
  lineId?: number
  applyId?: number
  /** ERP 采购单明细ID（= 回写匹配键） */
  externalLineId?: string
  salesOrderLineId?: number
  itemId?: number
  itemCode?: string
  itemName?: string
  unitOfMeasure?: string
  unitName?: string
  applyQty?: number
  postedQty?: number
  /** PENDING / PARTIAL / DONE / CANCELED */
  lineStatus?: string
  remark?: string
  createTime?: string
}

/** ERP 工厂出库申请（MES 侧只读） */
export interface WmSalesApply {
  applyId?: number
  factoryId?: number
  applyCode?: string
  externalApplyNo?: string
  externalOrderNo?: string
  purchaseOrderId?: number
  salesOrderId?: number
  salesOrderCode?: string
  requestDate?: string
  receiverName?: string
  receiverTel?: string
  receiverAddress?: string
  /** PENDING / PARTIAL / DONE / CANCELED */
  status?: string
  mesSalesId?: number
  mesSalesCode?: string
  remark?: string
  lineCount?: number
  totalApplyQty?: number
  totalPostedQty?: number
  createBy?: string
  createTime?: string
  lines?: WmSalesApplyLine[]
}
