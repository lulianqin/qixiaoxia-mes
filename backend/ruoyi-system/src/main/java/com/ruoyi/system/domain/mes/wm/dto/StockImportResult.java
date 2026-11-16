package com.ruoyi.system.domain.mes.wm.dto;

import java.util.ArrayList;
import java.util.List;

/**
 * 库存 Excel 导入结果
 *
 * @author qixiaoxia
 */
public class StockImportResult
{
    /** 导入批次号 */
    private String importBatchNo;
    /** 成功条数 */
    private int successCount;
    /** 跳过条数（空行/无数量） */
    private int skipCount;
    /** 自动新建物料条数 */
    private int createdItemCount;
    /** 失败明细（行号: 原因） */
    private List<String> errors = new ArrayList<>();

    public String getImportBatchNo() { return importBatchNo; }
    public void setImportBatchNo(String v) { this.importBatchNo = v; }
    public int getSuccessCount() { return successCount; }
    public void setSuccessCount(int v) { this.successCount = v; }
    public int getSkipCount() { return skipCount; }
    public void setSkipCount(int v) { this.skipCount = v; }
    public int getCreatedItemCount() { return createdItemCount; }
    public void setCreatedItemCount(int v) { this.createdItemCount = v; }
    public List<String> getErrors() { return errors; }
    public void setErrors(List<String> v) { this.errors = v; }
}
