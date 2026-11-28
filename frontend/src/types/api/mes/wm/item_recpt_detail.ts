import { PageDomain, BaseEntity } from "@/types/api/common"

export interface WmItemRecptDetailQueryParams extends PageDomain {
  itemCode?: string
  itemName?: string
  specification?: string
  unitOfMeasure?: string
  unitName?: string
}

export interface WmItemRecptDetail extends BaseEntity {
  detailId: number
  factoryId?: number
  recptId?: number
  lineId?: number
  itemId?: number
  itemCode?: string
  itemName?: string
  specification?: string
  unitOfMeasure?: string
  unitName?: string
  unit2?: string
  unit2Name?: string
  quantity?: number
  quantity2?: number
  batchId?: number
  batchCode?: string
  warehouseId?: number
  warehouseCode?: string
  warehouseName?: string
  locationId?: number
  areaId?: number
  materialStockId?: number
  /** 实物实例ID（逐件入库时写入） */
  instanceId?: number
  /** 实物实例编号：供应商卷号/根号，留空由后端生成 */
  instanceCode?: string
  /** 本件按主单位计量的数量（一卷 619kg / 一根 6.02m） */
  instanceQuantity?: number
  /** 实例级动态属性：门幅/克重、外径/壁厚… */
  extAttrs?: Record<string, any>
}