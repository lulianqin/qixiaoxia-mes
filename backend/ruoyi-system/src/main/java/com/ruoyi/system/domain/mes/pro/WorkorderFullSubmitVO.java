package com.ruoyi.system.domain.mes.pro;

import java.util.List;

/**
 * 生产工单开单页 — 一次性提交体（主工单 + BOM + 工序参数 + 路线工序 + 全部采购单/加工单）
 *
 * @author qixiaoxia
 * @date 2026-11-17
 */
public class WorkorderFullSubmitVO
{
    private ProWorkorder workorder;
    private List<ProWorkorderBom> bomList;
    private List<ProWorkorderParam> paramList;
    /** 调整后的路线工序（用于增删/排序） */
    private List<ProRouteProcess> routeProcesses;
    private List<WorkorderPurDocVO> purchaseDocs;
    private List<WorkorderProcDocVO> processDocs;

    public ProWorkorder getWorkorder() { return workorder; }
    public void setWorkorder(ProWorkorder v) { this.workorder = v; }
    public List<ProWorkorderBom> getBomList() { return bomList; }
    public void setBomList(List<ProWorkorderBom> v) { this.bomList = v; }
    public List<ProWorkorderParam> getParamList() { return paramList; }
    public void setParamList(List<ProWorkorderParam> v) { this.paramList = v; }
    public List<ProRouteProcess> getRouteProcesses() { return routeProcesses; }
    public void setRouteProcesses(List<ProRouteProcess> v) { this.routeProcesses = v; }
    public List<WorkorderPurDocVO> getPurchaseDocs() { return purchaseDocs; }
    public void setPurchaseDocs(List<WorkorderPurDocVO> v) { this.purchaseDocs = v; }
    public List<WorkorderProcDocVO> getProcessDocs() { return processDocs; }
    public void setProcessDocs(List<WorkorderProcDocVO> v) { this.processDocs = v; }
}
