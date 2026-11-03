/** 外协发料行（列表/详情展示用） */
export interface OutsourceIssueLineVO {
  itemName?: string
  quantity?: number
  unitName?: string
}

/** 代厂商录入加工结果所需的外协单信息 */
export interface OutsourceAgentOrder {
  orderId: number
  orderCode?: string
  vendorName?: string
  processName?: string
  sourceType?: string
  issueTotalQty?: number
  recptTotalQty?: number
  issueLines?: OutsourceIssueLineVO[]
}
