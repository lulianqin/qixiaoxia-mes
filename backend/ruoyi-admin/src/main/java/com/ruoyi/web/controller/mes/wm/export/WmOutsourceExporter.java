package com.ruoyi.web.controller.mes.wm.export;

import java.io.OutputStream;
import java.math.BigDecimal;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import com.ruoyi.system.domain.mes.wm.WmOutsourceIssueLine;
import com.ruoyi.system.domain.mes.wm.WmOutsourceOrder;

/**
 * 加工单 Excel 导出（套打，含单头 + 工序行 + 物料明细行）
 *
 * @author qixiaoxia
 */
public class WmOutsourceExporter
{
    private WmOutsourceExporter() {}

    public static void export(HttpServletResponse response, WmOutsourceOrder order) throws Exception
    {
        try (XSSFWorkbook wb = new XSSFWorkbook())
        {
            Sheet sheet = wb.createSheet("加工单");
            CellStyle title = style(wb, true, 16);
            CellStyle head = style(wb, true, 11);
            CellStyle body = style(wb, false, 10);

            int r = 0;
            titleRow(sheet, r++, "加 工 单", title, 30);
            r++;
            r = pairRow(sheet, r, "加工单号", order.getOrderCode(), "加工类型",
                    "INSIDE".equals(order.getSupplierType()) ? "厂内加工" : "外协加工", head, body);
            r = pairRow(sheet, r, "加工商", order.getVendorName(), "生产工单", order.getWorkorderCode(), head, body);
            r = pairRow(sheet, r, "工序", order.getProcessName(), "状态", order.getStatus(), head, body);
            r = pairRow(sheet, r, "发料总量", num(order.getIssueTotalQty()), "收货总量",
                    num(order.getRecptTotalQty()), head, body);
            r++;
            // 物料明细表头
            String[] cols = {"序号", "物料编码", "物料名称", "规格型号", "单位", "数量", "单价", "金额"};
            Row headerRow = sheet.createRow(r++);
            headerRow.setHeightInPoints(22);
            for (int i = 0; i < cols.length; i++)
            {
                Cell c = headerRow.createCell(i);
                c.setCellValue(cols[i]);
                c.setCellStyle(head);
            }
            int seq = 1;
            if (order.getIssueLines() != null)
            {
                for (WmOutsourceIssueLine line : order.getIssueLines())
                {
                    Row row = sheet.createRow(r++);
                    row.setHeightInPoints(20);
                    set(row, 0, String.valueOf(seq++), body);
                    set(row, 1, line.getItemCode(), body);
                    set(row, 2, line.getItemName(), body);
                    set(row, 3, line.getSpecification(), body);
                    set(row, 4, line.getUnitName(), body);
                    set(row, 5, num(line.getQuantity()), body);
                    set(row, 6, num(line.getUnitPrice()), body);
                    set(row, 7, num(line.getAmount()), body);
                }
            }
            for (int i = 0; i < cols.length; i++)
            {
                sheet.setColumnWidth(i, i == 2 ? 30 * 256 : 18 * 256);
            }

            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("utf-8");
            String fileName = java.net.URLEncoder.encode("加工单_" + safe(order.getOrderCode()), "UTF-8");
            response.setHeader("Content-Disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");
            OutputStream os = response.getOutputStream();
            wb.write(os);
            os.flush();
        }
    }

    private static void titleRow(Sheet sheet, int rowIdx, String text, CellStyle style, int height)
    {
        Row row = sheet.createRow(rowIdx);
        row.setHeightInPoints(height);
        Cell cell = row.createCell(0);
        cell.setCellValue(text);
        cell.setCellStyle(style);
        sheet.addMergedRegion(new CellRangeAddress(rowIdx, rowIdx, 0, 7));
    }

    private static int pairRow(Sheet sheet, int rowIdx, String l1, String v1, String l2, String v2,
                               CellStyle head, CellStyle body)
    {
        Row row = sheet.createRow(rowIdx);
        row.setHeightInPoints(22);
        set(row, 0, l1, head);
        set(row, 1, v1, body);
        set(row, 2, l2, head);
        set(row, 3, v2, body);
        return rowIdx + 1;
    }

    private static void set(Row row, int col, String value, CellStyle style)
    {
        Cell cell = row.createCell(col);
        cell.setCellValue(value == null ? "" : value);
        cell.setCellStyle(style);
    }

    private static CellStyle style(XSSFWorkbook wb, boolean bold, int size)
    {
        CellStyle style = wb.createCellStyle();
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        style.setAlignment(HorizontalAlignment.CENTER);
        Font font = wb.createFont();
        font.setBold(bold);
        font.setFontHeightInPoints((short) size);
        style.setFont(font);
        return style;
    }

    private static String num(BigDecimal v)
    {
        return v == null ? "" : v.stripTrailingZeros().toPlainString();
    }

    private static String safe(String s)
    {
        return s == null ? "" : s;
    }
}
