import { PageDomain, BaseEntity } from "@/types/api/common"

/**
 * 库存实物实例：一件实物（一卷纸 / 一根钢管 / 一桶油墨）。
 * 同一物料同一批次下可以有多件，每件按主单位计量的数量各不相同。
 */
export interface WmStockInstance extends BaseEntity {
  instanceId?: number
  factoryId?: number
  /** 实物实例编号（扫这个码收货/发料） */
  instanceCode?: string
  /** 实例类型：ROLL/BAR/DRUM…由物料辅助单位决定 */
  instanceType?: string
  itemId?: number
  itemCode?: string
  itemName?: string
  specification?: string
  batchId?: number
  batchCode?: string
  recptId?: number
  recptDetailId?: number
  vendorId?: number
  vendorCode?: string
  vendorName?: string
  /** 供应商原始编号（卷号/根号） */
  vendorInstanceNo?: string
  parentInstanceId?: number
  /** 入库时主单位数量 */
  originalQuantity?: number
  /** 剩余主单位数量（权威值） */
  remainingQuantity?: number
  quantityUom?: string
  warehouseId?: number
  warehouseCode?: string
  warehouseName?: string
  locationId?: number
  areaId?: number
  materialStockId?: number
  lastIssueId?: number
  lastWorkorderId?: number
  lastWorkorderCode?: string
  /** IN_STOCK / PARTIAL / CONSUMED / RETURNED / SCRAPPED / OUTSOURCED */
  status?: string
  /** 实例级动态属性（门幅/克重、外径/壁厚…） */
  extAttrs?: Record<string, any>
  remark?: string
}

export interface WmStockInstanceQueryParams extends PageDomain {
  itemId?: number
  itemCode?: string
  itemName?: string
  batchId?: number
  batchCode?: string
  instanceCode?: string
  instanceType?: string
  materialStockId?: number
  warehouseId?: number
  status?: string
}
