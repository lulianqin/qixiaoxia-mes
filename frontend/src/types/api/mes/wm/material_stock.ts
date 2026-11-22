import { PageDomain, BaseEntity } from "@/types/api/common"

export interface WmMaterialStockQueryParams extends PageDomain {
  itemCode?: string
  itemName?: string
  specification?: string
  unitOfMeasure?: string
  unitName?: string
  /** 物料分类（区分成品/原料/辅料/纸边/废纸等） */
  itemTypeId?: number
  warehouseId?: number
  batchCode?: string
  qualityStatus?: string
  vendorId?: number
  clientId?: number
}

export interface WmMaterialStock extends BaseEntity {
  materialStockId: number
  factoryId?: number
  itemId?: number
  itemCode?: string
  itemName?: string
  specification?: string
  unitOfMeasure?: string
  unitName?: string
  unit2?: string
  unit2Name?: string
  conversionRate?: number
  quantityOnhand?: number
  quantityOnhand2?: number
  quantityAvailable?: number
  quantityLocked?: number
  quantityAvailable2?: number
  batchId?: number
  batchCode?: string
  warehouseId?: number
  warehouseCode?: string
  warehouseName?: string
  locationId?: number
  locationCode?: string
  locationName?: string
  areaId?: number
  areaCode?: string
  areaName?: string
  vendorId?: number
  vendorCode?: string
  vendorName?: string
  clientId?: number
  clientName?: string
  workorderId?: number
  workorderCode?: string
  expireDate?: string
  lotNumber?: string
  qualityStatus?: string
  status?: string
  enableFlag?: string
  /** 盘点日期 */
  stocktakeDate?: string
  /** 以下字段取自物料档案（列表展示，非库存表字段） */
  itemTypeId?: number
  itemTypeCode?: string
  itemTypeName?: string
  packageSpec?: string
  itemExtAttrs?: Record<string, any>
}
