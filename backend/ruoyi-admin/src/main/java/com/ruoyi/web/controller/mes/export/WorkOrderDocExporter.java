package com.ruoyi.web.controller.mes.export;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Date;
import java.util.List;
import java.util.Map;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.Drawing;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.VerticalAlignment;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;

/**
 * 生产工单开单页单据导出器：采购单 / 加工单，单张与同供应商合并。
 *
 * <p>同一份打印模型分别渲染 Excel（可编辑）与 PDF（直接打印），
 * 版式对齐客户模板：公司抬头 → 单据标题 → 供应商/业务单号/单号 → 明细 → 送货地址 →
 * 特别声明 → 申购人/下单日期 → 底部产品图片。</p>
 *
 * @author qixiaoxia
 * @date 2026-11-17
 */
public class WorkOrderDocExporter
{
    private static final String COMPANY = "浙江圣享实业有限公司";
    private static final String SPECIAL_NOTICE =
            "1.各供应商在收到订单确认各项明细无误之后，请签字回传公司。\n"
          + "2.此单作为贵司与我司财务月底结账凭证，请各供应商确认回传并保留。\n"
          + "3.请在每月月底结账时，凭此单与我司结算，否则不与结算，谢谢配合！";

    /** 打印模型 */
    public static class Model
    {
        public String title;
        public String partyLabel = "供应商：";
        public String partyName;
        public String bizNo;
        public String bizNoLabel = "业务单号NO：";
        public String docCode;
        public String docCodeLabel = "采购单号NO：";
        public List<String> headers = new ArrayList<>();
        public List<List<String>> rows = new ArrayList<>();
        public BigDecimal total = BigDecimal.ZERO;
        public String deliveryAddress;
        public String purchaser;
        public String orderDate;
        /** 产品图片：http(s) URL / data:base64 / classpath: */
        public String productImage;
    }

    private WorkOrderDocExporter() {}

    // ═══════════════════ Excel ═══════════════════

    public static void writeExcel(Model m, OutputStream out) throws Exception
    {
        try (XSSFWorkbook wb = new XSSFWorkbook())
        {
            Sheet sh = wb.createSheet("单据");
            int cols = Math.max(1, m.headers.size());
            Styles st = new Styles(wb);
            int r = 0;
            r = title(sh, r, m, st, cols);
            r = info(sh, r, m, st, cols);
            r = header(sh, r, m, st);
            r = body(sh, r, m, st, cols);
            r = total(sh, r, m, st, cols);
            r = footer(sh, r, m, st, cols);
            embedImage(wb, sh, r + 1, m.productImage);
            for (int i = 0; i < cols; i++)
            {
                sh.setColumnWidth(i, i == 0 ? 6000 : 4200);
            }
            wb.write(out);
        }
    }

    private static int title(Sheet sh, int r, Model m, Styles st, int cols)
    {
        Row row = sh.createRow(r);
        row.setHeightInPoints(28);
        Cell c = row.createCell(0);
        c.setCellValue(COMPANY);
        c.setCellStyle(st.title);
        sh.addMergedRegion(new CellRangeAddress(r, r, 0, cols - 1));
        r++;
        Row t2 = sh.createRow(r);
        t2.setHeightInPoints(24);
        Cell c2 = t2.createCell(0);
        c2.setCellValue(m.title);
        c2.setCellStyle(st.subTitle);
        sh.addMergedRegion(new CellRangeAddress(r, r, 0, cols - 1));
        return r + 2;
    }

    private static int info(Sheet sh, int r, Model m, Styles st, int cols)
    {
        Row row = sh.createRow(r);
        set(row, 0, m.partyLabel, st.label);
        set(row, 1, safe(m.partyName), st.value);
        if (cols > 3)
        {
            set(row, cols - 3, m.bizNoLabel + safe(m.bizNo), st.value);
            sh.addMergedRegion(new CellRangeAddress(r, r, cols - 3, cols - 1));
        }
        r++;
        Row r2 = sh.createRow(r);
        if (cols > 3)
        {
            set(r2, cols - 3, m.docCodeLabel + safe(m.docCode), st.value);
            sh.addMergedRegion(new CellRangeAddress(r, r, cols - 3, cols - 1));
        }
        return r + 2;
    }

    private static int header(Sheet sh, int r, Model m, Styles st)
    {
        Row row = sh.createRow(r);
        row.setHeightInPoints(22);
        for (int i = 0; i < m.headers.size(); i++)
        {
            set(row, i, m.headers.get(i), st.head);
        }
        return r + 1;
    }

    private static int body(Sheet sh, int r, Model m, Styles st, int cols)
    {
        for (List<String> line : m.rows)
        {
            Row row = sh.createRow(r);
            row.setHeightInPoints(20);
            for (int i = 0; i < m.headers.size(); i++)
            {
                set(row, i, i < line.size() ? safe(line.get(i)) : "", st.cell);
            }
            r++;
        }
        return r;
    }

    private static int total(Sheet sh, int r, Model m, Styles st, int cols)
    {
        Row row = sh.createRow(r);
        set(row, 0, "合计：", st.totalLabel);
        if (cols > 2)
        {
            sh.addMergedRegion(new CellRangeAddress(r, r, 0, cols - 3));
        }
        set(row, Math.max(0, cols - 2), m.total == null ? "" : m.total.toPlainString(), st.totalValue);
        if (cols > 1)
        {
            sh.addMergedRegion(new CellRangeAddress(r, r, Math.max(0, cols - 2), cols - 1));
        }
        return r + 1;
    }

    private static int footer(Sheet sh, int r, Model m, Styles st, int cols)
    {
        Row a = sh.createRow(r++);
        set(a, 0, "送货地址：", st.label);
        set(a, 1, safe(m.deliveryAddress), st.value);
        if (cols > 2)
        {
            sh.addMergedRegion(new CellRangeAddress(a.getRowNum(), a.getRowNum(), 1, cols - 1));
        }
        Row b = sh.createRow(r++);
        set(b, 0, "特别声明", st.label);
        Cell nc = b.createCell(1);
        nc.setCellValue(SPECIAL_NOTICE);
        nc.setCellStyle(st.wrap);
        if (cols > 2)
        {
            sh.addMergedRegion(new CellRangeAddress(b.getRowNum(), b.getRowNum(), 1, cols - 1));
        }
        b.setHeightInPoints(54);
        Row c = sh.createRow(r++);
        set(c, 0, "申购人", st.label);
        set(c, 1, safe(m.purchaser), st.value);
        if (cols > 3)
        {
            set(c, cols - 2, "下单日期", st.label);
            set(c, cols - 1, safe(m.orderDate), st.value);
        }
        return r + 1;
    }

    private static void embedImage(Workbook wb, Sheet sh, int rowIdx, String image)
    {
        byte[] bytes = loadImage(image);
        if (bytes == null)
        {
            return;
        }
        try
        {
            int idx = wb.addPicture(bytes, Workbook.PICTURE_TYPE_PNG);
            Drawing<?> drawing = sh.createDrawingPatriarch();
            ClientAnchor anchor = wb.getCreationHelper().createClientAnchor();
            anchor.setCol1(0);
            anchor.setRow1(rowIdx);
            anchor.setCol2(4);
            anchor.setRow2(rowIdx + 10);
            drawing.createPicture(anchor, idx);
        }
        catch (Exception ignored)
        {
            // 图片格式不支持时忽略，不影响单据主体
        }
    }

    // ═══════════════════ PDF ═══════════════════

    public static void writePdf(Model m, OutputStream out) throws Exception
    {
        PdfRendererBuilder b = new PdfRendererBuilder();
        b.useFastMode();
        b.useFont(() -> fontStream(), "NotoSansSC");
        b.withHtmlContent(html(m), null);
        b.toStream(out);
        b.run();
    }

    private static InputStream fontStream()
    {
        try
        {
            return new org.springframework.core.io.ClassPathResource(
                    "fonts/NotoSansSC-Regular.ttf").getInputStream();
        }
        catch (Exception e)
        {
            throw new RuntimeException("无法加载 PDF 中文字体", e);
        }
    }

    private static String html(Model m)
    {
        StringBuilder sb = new StringBuilder();
        sb.append("<!DOCTYPE html><html><head><meta charset='utf-8'/><style>")
          .append("@page{size:A4 landscape;margin:12mm}")
          .append("body{font-family:'NotoSansSC';font-size:11px;color:#222}")
          .append(".c{text-align:center}.t1{font-size:18px;font-weight:bold}.t2{font-size:14px;font-weight:bold;margin:2px 0 8px}")
          .append("table{width:100%;border-collapse:collapse}")
          .append(".grid th,.grid td{border:1px solid #bbb;padding:4px 5px;text-align:center;font-size:10px}")
          .append(".grid th{background:#f0f2f5}")
          .append(".info td{padding:3px 4px}")
          .append(".notice{font-size:10px;color:#555;line-height:1.7;white-space:pre-wrap}")
          .append(".foot{margin-top:14px;font-size:11px}")
          .append("</style></head><body>");
        sb.append("<div class='c t1'>").append(COMPANY).append("</div>");
        sb.append("<div class='c t2'>").append(esc(m.title)).append("</div>");
        sb.append("<table class='info'><tr><td>").append(esc(m.partyLabel)).append(esc(m.partyName))
          .append("</td><td style='text-align:right'>").append(esc(m.bizNoLabel)).append(esc(m.bizNo))
          .append("</td></tr><tr><td></td><td style='text-align:right'>")
          .append(esc(m.docCodeLabel)).append(esc(m.docCode)).append("</td></tr></table>");
        sb.append("<table class='grid'><tr>");
        for (String h : m.headers)
        {
            sb.append("<th>").append(esc(h)).append("</th>");
        }
        sb.append("</tr>");
        for (List<String> line : m.rows)
        {
            sb.append("<tr>");
            for (int i = 0; i < m.headers.size(); i++)
            {
                sb.append("<td>").append(esc(i < line.size() ? line.get(i) : "")).append("</td>");
            }
            sb.append("</tr>");
        }
        sb.append("<tr><td colspan='").append(Math.max(1, m.headers.size() - 1))
          .append("' style='text-align:right;font-weight:bold'>合计</td><td style='font-weight:bold'>")
          .append(m.total == null ? "" : m.total.toPlainString()).append("</td></tr></table>");
        sb.append("<div class='foot'>送货地址：").append(esc(m.deliveryAddress)).append("</div>");
        sb.append("<div class='notice'><b>特别声明</b><br/>").append(esc(SPECIAL_NOTICE)).append("</div>");
        sb.append("<div class='foot'>申购人：").append(esc(m.purchaser))
          .append("　　　　下单日期：").append(esc(m.orderDate)).append("</div>");
        String img = imageDataUri(m.productImage);
        if (img != null)
        {
            sb.append("<div style='margin-top:12px'><img src='").append(img)
              .append("' style='max-height:220px'/></div>");
        }
        sb.append("</body></html>");
        return sb.toString();
    }

    // ═══════════════════ 工具 ═══════════════════

    /** 工序属性 JSON → Map */
    @SuppressWarnings("unchecked")
    public static Map<String, Object> parseAttrs(String json)
    {
        if (json == null || json.isBlank())
        {
            return new java.util.HashMap<>();
        }
        try
        {
            JSONObject o = JSON.parseObject(json);
            return o;
        }
        catch (Exception e)
        {
            return new java.util.HashMap<>();
        }
    }

    public static String fmt(BigDecimal v)
    {
        return v == null ? "" : v.stripTrailingZeros().toPlainString();
    }

    public static String fmtDate(Date d)
    {
        return d == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(d);
    }

    private static void set(Row row, int col, String val, CellStyle st)
    {
        Cell c = row.createCell(col);
        c.setCellValue(val == null ? "" : val);
        c.setCellStyle(st);
    }

    private static String safe(String s) { return s == null ? "" : s; }

    private static String esc(String s)
    {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;").replace("\n", "<br/>");
    }

    private static byte[] loadImage(String src)
    {
        if (src == null || src.isBlank())
        {
            return null;
        }
        try
        {
            if (src.startsWith("data:image"))
            {
                return Base64.getDecoder().decode(src.substring(src.indexOf(',') + 1));
            }
            if (src.startsWith("http://") || src.startsWith("https://"))
            {
                try (InputStream in = new URL(src).openStream())
                {
                    return in.readAllBytes();
                }
            }
            if (src.startsWith("classpath:"))
            {
                return new org.springframework.core.io.ClassPathResource(
                        src.substring("classpath:".length())).getInputStream().readAllBytes();
            }
            java.io.File f = new java.io.File(src);
            if (f.exists())
            {
                return java.nio.file.Files.readAllBytes(f.toPath());
            }
        }
        catch (Exception ignored)
        {
        }
        return null;
    }

    private static String imageDataUri(String src)
    {
        byte[] bytes = loadImage(src);
        if (bytes == null)
        {
            return null;
        }
        return "data:image/png;base64," + Base64.getEncoder().encodeToString(bytes);
    }

    /** 单元格样式集合 */
    static class Styles
    {
        final CellStyle title;
        final CellStyle subTitle;
        final CellStyle label;
        final CellStyle value;
        final CellStyle head;
        final CellStyle cell;
        final CellStyle totalLabel;
        final CellStyle totalValue;
        final CellStyle wrap;

        Styles(Workbook wb)
        {
            title = base(wb, 16, true, HorizontalAlignment.CENTER);
            subTitle = base(wb, 14, true, HorizontalAlignment.CENTER);
            label = base(wb, 10, true, HorizontalAlignment.CENTER);
            value = base(wb, 10, false, HorizontalAlignment.LEFT);
            head = base(wb, 10, true, HorizontalAlignment.CENTER);
            cell = base(wb, 10, false, HorizontalAlignment.CENTER);
            totalLabel = base(wb, 10, true, HorizontalAlignment.RIGHT);
            totalValue = base(wb, 11, true, HorizontalAlignment.RIGHT);
            wrap = base(wb, 10, false, HorizontalAlignment.LEFT);
            wrap.setWrapText(true);
        }

        private static CellStyle base(Workbook wb, int size, boolean bold, HorizontalAlignment align)
        {
            CellStyle s = wb.createCellStyle();
            Font f = wb.createFont();
            f.setFontHeightInPoints((short) size);
            f.setBold(bold);
            s.setFont(f);
            s.setAlignment(align);
            s.setVerticalAlignment(VerticalAlignment.CENTER);
            s.setBorderTop(BorderStyle.THIN);
            s.setBorderBottom(BorderStyle.THIN);
            s.setBorderLeft(BorderStyle.THIN);
            s.setBorderRight(BorderStyle.THIN);
            return s;
        }
    }
}
