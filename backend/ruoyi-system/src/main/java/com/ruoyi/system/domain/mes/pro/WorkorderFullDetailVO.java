package com.ruoyi.system.domain.mes.pro;

import java.util.List;
import java.util.Map;
import com.ruoyi.system.domain.mes.pur.PurOrderLine;
import com.ruoyi.system.domain.mes.pur.vo.PurOrderVO;
import com.ruoyi.system.domain.mes.wm.WmOutsourceOrder;

/**
 * 生产工单开单页 — 回显数据（主工单 + BOM + 参数 + 路线工序 + 已生成的采购单/加工单）
 *
 * @author qixiaoxia
 * @date 2026-11-17
 */
public class WorkorderFullDetailVO
{
    private ProWorkorder workorder;
    private List<ProWorkorderBom> bomList;
    private List<Map<String, Object>> paramList;
    private List<ProRouteProcess> routeProcesses;
    private List<ProRouteProduct> routeOptions;
    /** 采购单（含明细行） */
    private List<PurchaseDoc> purchaseDocs;
    /** 加工单（含工序行） */
    private List<WmOutsourceOrder> processDocs;

    public ProWorkorder getWorkorder() { return workorder; }
    public void setWorkorder(ProWorkorder v) { this.workorder = v; }
    public List<ProWorkorderBom> getBomList() { return bomList; }
    public void setBomList(List<ProWorkorderBom> v) { this.bomList = v; }
    public List<Map<String, Object>> getParamList() { return paramList; }
    public void setParamList(List<Map<String, Object>> v) { this.paramList = v; }
    public List<ProRouteProcess> getRouteProcesses() { return routeProcesses; }
    public void setRouteProcesses(List<ProRouteProcess> v) { this.routeProcesses = v; }
    public List<ProRouteProduct> getRouteOptions() { return routeOptions; }
    public void setRouteOptions(List<ProRouteProduct> v) { this.routeOptions = v; }
    public List<PurchaseDoc> getPurchaseDocs() { return purchaseDocs; }
    public void setPurchaseDocs(List<PurchaseDoc> v) { this.purchaseDocs = v; }
    public List<WmOutsourceOrder> getProcessDocs() { return processDocs; }
    public void setProcessDocs(List<WmOutsourceOrder> v) { this.processDocs = v; }

    /** 采购单 + 明细行 */
    public static class PurchaseDoc
    {
        private PurOrderVO order;
        private List<PurOrderLine> lines;
        public PurOrderVO getOrder() { return order; }
        public void setOrder(PurOrderVO v) { this.order = v; }
        public List<PurOrderLine> getLines() { return lines; }
        public void setLines(List<PurOrderLine> v) { this.lines = v; }
    }
}
