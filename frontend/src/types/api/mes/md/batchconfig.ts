import type { PageDomain, BaseEntity } from "../../common";

export interface BatchConfigQueryParams extends PageDomain {
  itemId?: number;
}

export interface MdItemBatchConfig extends BaseEntity {
  configId?: number;
  factoryId?: number;
  itemId?: number;
  produceDateFlag?: string;
  expireDateFlag?: string;
  recptDateFlag?: string;
  vendorFlag?: string;
  clientFlag?: string;
  coCodeFlag?: string;
  poCodeFlag?: string;
  workorderFlag?: string;
  taskFlag?: string;
  workstationFlag?: string;
  toolFlag?: string;
  moldFlag?: string;
  lotNumberFlag?: string;
  qualityStatusFlag?: string;
  paperRollFlag?: string;
  paperWidthFlag?: string;
  /** 是否逐实物实例管理（1-是）：一卷/一根/一桶各自数量可不同 */
  instanceFlag?: string;
  enableFlag?: string;
}
