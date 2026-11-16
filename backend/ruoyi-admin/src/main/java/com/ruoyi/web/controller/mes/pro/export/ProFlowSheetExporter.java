package com.ruoyi.web.controller.mes.pro.export;

import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.Drawing;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.VerticalAlignment;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFClientAnchor;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import com.ruoyi.system.domain.mes.pro.ProWorkorder;

/**
 * 生产流转单 Excel 套打导出（版式对齐《生产流转单导出模板.xlsx》）
 *
 * 布局：6 列（16/26/14/26/14/26 字符宽），
 *   标题区 → 表头 3 行 → 分类生产属性（每行 3 组）→ 绳料/印刷/包装/发货（右侧产品图）
 *   → 工艺流程/备注（整行）→ 制单日期/业务员。
 *
 * @author qixiaoxia
 */
public class ProFlowSheetExporter
{
    private static final int[] COL_WIDTHS = {16, 26, 14, 26, 14, 26};
    private static final int LAST_COL = 5;

    private ProFlowSheetExporter() {}

    public static void export(HttpServletResponse response, ProWorkorder wo) throws Exception
    {
        export(response, wo, new LinkedHashMap<>(), null);
    }

    /**
     * @param productionAttrs 分类驱动的生产属性（名称含单位 → 值），按顺序输出
     * @param qrDataUrl      前端生成的二维码 dataURL（可选），贴在右上角二维码区
     */
    public static void export(HttpServletResponse response, ProWorkorder wo,
                              Map<String, String> productionAttrs, String qrDataUrl) throws Exception
    {
        XSSFWorkbook wb = new XSSFWorkbook();
        try
        {
            Sheet sheet = createSheet(wb);
            Styles style = new Styles(wb);
            int r = writeTitle(wb, sheet, style, wo, qrDataUrl);
            r = writeHeader(sheet, style, r, wo);
            r = writeAttrs(wb, sheet, style, r, productionAttrs);
            r = writeRequirements(wb, sheet, style, r, wo);
            writeFooter(sheet, style, r, wo);
            writeResponse(response, wb, wo);
        }
        finally
        {
            wb.close();
        }
    }

    private static Sheet createSheet(XSSFWorkbook wb)
    {
        Sheet sheet = wb.createSheet("生产流转单");
        for (int i = 0; i < COL_WIDTHS.length; i++)
        {
            sheet.setColumnWidth(i, COL_WIDTHS[i] * 256);
        }
        return sheet;
    }

    /** 公司名 + 标题 + 右上角二维码（F1:F4 合并） */
    private static int writeTitle(XSSFWorkbook wb, Sheet sheet, Styles style, ProWorkorder wo, String qrDataUrl)
    {
        Row row0 = sheet.createRow(0);
        row0.setHeightInPoints(42);
        cell(row0, 0, "浙江圣享实业有限公司", style.company);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 4));
        Cell qrCell = cell(row0, 5, qrDataUrl == null ? "二维码位置" : "", style.qr);
        if (qrDataUrl != null && !qrDataUrl.isEmpty())
        {
            insertBase64Image(wb, sheet, qrDataUrl, 5, 0, 6, 4);
        }
        sheet.addMergedRegion(new CellRangeAddress(0, 3, 5, 5));
        if (qrCell != null) qrCell.setCellStyle(style.qr);

        Row spacer = sheet.createRow(1);
        spacer.setHeightInPoints(9);

        Row titleRow = sheet.createRow(2);
        titleRow.setHeightInPoints(26);
        cell(titleRow, 0, "生产流转单", style.subtitle);
        sheet.addMergedRegion(new CellRangeAddress(2, 2, 0, 4));
        sheet.createRow(3);
        return 4;
    }

    /** 表头 3 行：订单/生产编号/类型 → 产品/日期/数量 → 尺寸/交期/订单数量 */
    private static int writeHeader(Sheet sheet, Styles style, int r, ProWorkorder wo)
    {
        r = triple(sheet, style, r, 22,
                "订单编号", wo.getSourceCode(), "生产编号", wo.getProductionNo(), "订单类型", wo.getOrderType());
        r = triple(sheet, style, r, 22,
                "产品名称", wo.getProductName(), "下单日期", date(wo.getOrderDate()),
                "计划数量", num(wo.getQuantity()));
        return triple(sheet, style, r, 22,
                "产品尺寸", wo.getProductSize(), "交货日期", date(wo.getRequestDate()),
                "订单数量", num(wo.getOrderQty() == null ? wo.getQuantity() : wo.getOrderQty()));
    }

    /** 分类生产属性：6 列 3 组「属性名-值」，无属性则不占行 */
    private static int writeAttrs(XSSFWorkbook wb, Sheet sheet, Styles style, int r, Map<String, String> attrs)
    {
        if (attrs == null || attrs.isEmpty()) return r;
        List<Map.Entry<String, String>> list = new ArrayList<>(attrs.entrySet());
        for (int i = 0; i < list.size(); i += 3)
        {
            r = triple(sheet, style, r, 22,
                    label(list.get(i)), list.get(i).getValue(),
                    i + 1 < list.size() ? label(list.get(i + 1)) : "",
                    i + 1 < list.size() ? list.get(i + 1).getValue() : "",
                    i + 2 < list.size() ? label(list.get(i + 2)) : "",
                    i + 2 < list.size() ? list.get(i + 2).getValue() : "");
        }
        return r;
    }

    private static String label(Map.Entry<String, String> e)
    {
        return e == null ? "" : e.getKey();
    }

    /** 印刷/包装/发货（B:E 合并，F 列为产品图，占 3 行）+ 工艺流程/备注整行 */
    private static int writeRequirements(XSSFWorkbook wb, Sheet sheet, Styles style, int r, ProWorkorder wo)
    {
        int imageStart = r;
        r = labelValueRow(sheet, style, r, 30, "印刷要求", wo.getPrintingReq());
        r = labelValueRow(sheet, style, r, 30, "包装要求", wo.getPackageReq());
        r = labelValueRow(sheet, style, r, 30, "发货要求", wo.getShippingReq());
        // 产品图固定占右侧 3 行（印刷/包装/发货），无图也保留合并区，保持模板版式
        sheet.addMergedRegion(new CellRangeAddress(imageStart, imageStart + 2, 5, 5));
        insertImage(wb, sheet, wo.getProductImage(), 5, imageStart, 6, imageStart + 3);
        r = fullRow(sheet, style, r, 40, "工艺流程", wo.getProcessFlow());
        return fullRow(sheet, style, r, 30, "备注", wo.getRemark());
    }

    private static int writeFooter(Sheet sheet, Styles style, int r, ProWorkorder wo)
    {
        Row row = sheet.createRow(r);
        row.setHeightInPoints(22);
        cell(row, 0, "制单日期", style.label);
        cell(row, 1, date(wo.getBillDate()), style.value);
        cell(row, 2, "", style.value);
        cell(row, 3, "", style.value);
        cell(row, 4, "业务员", style.label);
        cell(row, 5, safe(wo.getSalesperson()), style.value);
        return r + 1;
    }

    /** 3 组「标签-值」一行 */
    private static int triple(Sheet sheet, Styles style, int r, int height,
                              String l1, String v1, String l2, String v2, String l3, String v3)
    {
        Row row = sheet.createRow(r);
        row.setHeightInPoints(height);
        String[] labels = {l1, l2, l3};
        String[] values = {v1, v2, v3};
        for (int i = 0; i < 3; i++)
        {
            cell(row, i * 2, safe(labels[i]), style.label);
            cell(row, i * 2 + 1, safe(values[i]), style.value);
        }
        return r + 1;
    }

    /** 标签 + 合并值（B:E），F 列留给产品图 */
    private static int labelValueRow(Sheet sheet, Styles style, int r, int height, String label, String value)
    {
        Row row = sheet.createRow(r);
        row.setHeightInPoints(height);
        cell(row, 0, label, style.label);
        cell(row, 1, safe(value), style.value);
        for (int c = 2; c <= 4; c++) cell(row, c, "", style.value);
        cell(row, 5, "", style.value);
        sheet.addMergedRegion(new CellRangeAddress(r, r, 1, 4));
        return r + 1;
    }

    /** 标签 + 整行合并值（B:F） */
    private static int fullRow(Sheet sheet, Styles style, int r, int height, String label, String value)
    {
        Row row = sheet.createRow(r);
        row.setHeightInPoints(height);
        cell(row, 0, label, style.label);
        for (int c = 1; c <= LAST_COL; c++) cell(row, c, c == 1 ? safe(value) : "", style.value);
        sheet.addMergedRegion(new CellRangeAddress(r, r, 1, LAST_COL));
        return r + 1;
    }

    private static Cell cell(Row row, int col, String value, CellStyle style)
    {
        Cell cell = row.createCell(col);
        cell.setCellValue(value);
        cell.setCellStyle(style);
        return cell;
    }

    private static void insertBase64Image(XSSFWorkbook wb, Sheet sheet, String dataUrl,
                                          int col1, int row1, int col2, int row2)
    {
        try
        {
            int comma = dataUrl.indexOf(',');
            String base64 = comma >= 0 ? dataUrl.substring(comma + 1) : dataUrl;
            byte[] bytes = Base64.getDecoder().decode(base64);
            if (bytes.length == 0) return;
            int picIdx = wb.addPicture(bytes, Workbook.PICTURE_TYPE_PNG);
            Drawing<?> drawing = sheet.createDrawingPatriarch();
            ClientAnchor anchor = new XSSFClientAnchor(2, 2, 2, 2, col1, row1, col2, row2);
            drawing.createPicture(anchor, picIdx);
        }
        catch (Exception ignore)
        {
            // 二维码生成失败不影响单据导出
        }
    }

    private static void insertImage(XSSFWorkbook wb, Sheet sheet, String path,
                                    int col1, int row1, int col2, int row2)
    {
        if (path == null || path.trim().isEmpty()) return;
        try
        {
            byte[] bytes = readImage(path);
            if (bytes == null || bytes.length == 0) return;
            int type = path.toLowerCase().endsWith(".png") ? Workbook.PICTURE_TYPE_PNG : Workbook.PICTURE_TYPE_JPEG;
            int picIdx = wb.addPicture(bytes, type);
            Drawing<?> drawing = sheet.createDrawingPatriarch();
            ClientAnchor anchor = new XSSFClientAnchor(2, 2, 2, 2, col1, row1, col2, row2);
            drawing.createPicture(anchor, picIdx);
        }
        catch (Exception ignore)
        {
            // 图片下载/解析失败不影响单据导出
        }
    }

    private static byte[] readImage(String path) throws Exception
    {
        if (path.startsWith("http://") || path.startsWith("https://"))
        {
            try (InputStream in = new URL(path).openStream())
            {
                return in.readAllBytes();
            }
        }
        java.io.File file = new java.io.File(path);
        return file.exists() ? java.nio.file.Files.readAllBytes(file.toPath()) : null;
    }

    private static void writeResponse(HttpServletResponse response, XSSFWorkbook wb, ProWorkorder wo) throws Exception
    {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = java.net.URLEncoder.encode(
                "生产流转单_" + safe(wo.getProductionNo()), "UTF-8");
        response.setHeader("Content-Disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");
        try (OutputStream os = response.getOutputStream())
        {
            wb.write(os);
            os.flush();
        }
    }

    /** 统一单元格样式集合 */
    private static class Styles
    {
        final CellStyle company;
        final CellStyle subtitle;
        final CellStyle label;
        final CellStyle value;
        final CellStyle qr;

        Styles(XSSFWorkbook wb)
        {
            company = textStyle(wb, 21, true, HorizontalAlignment.CENTER, false);
            subtitle = textStyle(wb, 14, true, HorizontalAlignment.CENTER, true);
            label = borderedStyle(wb, true, HorizontalAlignment.CENTER);
            value = borderedStyle(wb, false, HorizontalAlignment.LEFT);
            qr = textStyle(wb, 12, true, HorizontalAlignment.CENTER, false);
        }

        private static CellStyle textStyle(XSSFWorkbook wb, int size, boolean bold,
                                           HorizontalAlignment align, boolean underline)
        {
            CellStyle style = wb.createCellStyle();
            Font font = wb.createFont();
            font.setBold(bold);
            font.setFontHeightInPoints((short) size);
            if (underline) font.setUnderline(Font.U_SINGLE);
            style.setFont(font);
            style.setAlignment(align);
            style.setVerticalAlignment(VerticalAlignment.CENTER);
            return style;
        }

        private static CellStyle borderedStyle(XSSFWorkbook wb, boolean label, HorizontalAlignment align)
        {
            CellStyle style = wb.createCellStyle();
            style.setBorderTop(BorderStyle.THIN);
            style.setBorderBottom(BorderStyle.THIN);
            style.setBorderLeft(BorderStyle.THIN);
            style.setBorderRight(BorderStyle.THIN);
            style.setAlignment(align);
            style.setVerticalAlignment(VerticalAlignment.CENTER);
            style.setWrapText(true);
            Font font = wb.createFont();
            font.setBold(label);
            font.setFontHeightInPoints((short) 11);
            style.setFont(font);
            if (label)
            {
                style.setFillForegroundColor(IndexedColors.LIGHT_GREEN.getIndex());
                style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            }
            return style;
        }
    }

    private static String safe(String s)
    {
        return s == null ? "" : s;
    }

    private static String num(BigDecimal v)
    {
        return v == null ? "" : v.stripTrailingZeros().toPlainString();
    }

    private static String date(Date d)
    {
        return d == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(d);
    }
}
