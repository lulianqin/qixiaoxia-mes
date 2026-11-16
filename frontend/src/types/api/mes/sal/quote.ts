import type { PageDomain, BaseEntity } from "../../common";

/** 报价需求状态：PENDING_QUOTE 待报价 / QUOTED 已报价 / RETURNED 已退回 / CANCEL 已取消 */
export type SalQuoteStatus = 'PENDING_QUOTE' | 'QUOTED' | 'RETURNED' | 'CANCEL'

export interface SalQuoteQueryParams extends PageDomain {
  quoteCode?: string;
  externalQuoteNo?: string;
  title?: string;
  clientName?: string;
  status?: string;
}

export interface SalQuote extends BaseEntity {
  quoteId?: number;
  factoryId?: number;
  quoteCode?: string;
  externalQuoteId?: string;
  externalQuoteNo?: string;
  sourceSystem?: string;
  title?: string;
  clientCode?: string;
  clientName?: string;
  goodsType?: string;
  inquiryDate?: string;
  budget?: string;
  attachment?: string;
  status?: SalQuoteStatus;
  quoteUser?: string;
  quoteTime?: string;
  totalAmount?: number;
  returnReason?: string;
  returnTime?: string;
  syncStatus?: string;
  syncTime?: string;
  lines?: SalQuoteLine[];
}

export interface SalQuoteLine extends BaseEntity {
  lineId?: number;
  factoryId?: number;
  quoteId?: number;
  lineNo?: number;
  externalLineId?: string;
  productCode?: string;
  productName?: string;
  productPhoto?: string;
  productSize?: string;
  structure?: string;
  material?: string;
  printingMode?: string;
  processTxt?: string;
  accessoryTxt?: string;
  quantity?: number;
  unit?: string;
  price?: number;
  quoteRemark?: string;
  deliveryDate?: string;
  quoteValidDate?: string;
  remark?: string;
}

export interface SalQuoteSubmitRequest {
  quoteId?: number;
  remark?: string;
  lines?: Array<{
    lineId?: number;
    price?: number;
    quoteRemark?: string;
    deliveryDate?: string;
    quoteValidDate?: string;
  }>;
}
