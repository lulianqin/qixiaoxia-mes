package com.ruoyi.web.controller.mes.sal.export;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.VerticalAlignment;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import com.openhtmltopdf.util.XRLog;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;
import com.ruoyi.common.config.DocProperties;
import com.ruoyi.common.utils.DictUtils;
import com.ruoyi.system.domain.mes.sal.SalOrder;
import com.ruoyi.system.domain.mes.sal.SalOrderLine;

/**
 * 销售订单「业务订单」单据导出器：同一份打印模型分别渲染 Excel 与 PDF。
 * 版式对齐客户模板：公司抬头 → 业务订单 → 订单信息两行 → 明细（产品尺寸/材质及工艺/包装方式）
 * → 合计 → 订单补充说明 → 业务员。PDF 用于浏览器直接打印，Excel 用于下载。
 *
 * @author qixiaoxia
 */
@Component
public class SalOrderDocExporter
{
    private static final int COLS = 7;
    private static final String[] HEADERS = {
            "产品名称", "产品尺寸", "材质及工艺", "包装方式", "数量", "总金额(元)", "备注"
    };
    private static final int[] COL_WIDTHS = { 6000, 4200, 6000, 4800, 3000, 3600, 4200 };

    static { XRLog.setLoggingEnabled(false); }

    @Autowired
    private DocProperties docProperties;

    // ═══════════════════ Excel ═══════════════════

    public void writeExcel(SalOrder order, OutputStream out) throws IOException
    {
        try (XSSFWorkbook wb = new XSSFWorkbook())
        {
            Sheet sh = wb.createSheet("业务订单");
            Styles st = new Styles(wb);
            int r = 0;
            r = title(sh, r, order, st);
            r = info(sh, r, order, st);
            r = header(sh, r, st);
            r = body(sh, r, order, st);
            r = total(sh, r, order, st);
            r = remark(sh, r, order, st);
            salesperson(sh, r, order, st);
            for (int i = 0; i < COL_WIDTHS.length; i++)
            {
                sh.setColumnWidth(i, COL_WIDTHS[i]);
            }
            sh.getPrintSetup().setLandscape(true);
            wb.write(out);
        }
    }

    private int title(Sheet sh, int r, SalOrder o, Styles st)
    {
        Row row = sh.createRow(r);
        row.setHeightInPoints(24);
        set(row, 0, signCompanyName(o), st.title);
        merge(sh, r, r, 0, COLS - 1);
        r++;
        Row t = sh.createRow(r);
        t.setHeightInPoints(22);
        set(t, 0, orderTitle(o), st.subTitleRed);
        merge(sh, r, r, 0, COLS - 1);
        return r + 2;
    }

    private int info(Sheet sh, int r, SalOrder o, Styles st)
    {
        Row row = sh.createRow(r);
        row.setHeightInPoints(24);
        set(row, 0, "订单编号：" + str(o.getOrderCode()), st.infoValue);
        merge(sh, r, r, 0, 1);
        set(row, 2, "客户名称：", st.infoLabel);
        set(row, 3, str(o.getClientName()), st.infoValue);
        merge(sh, r, r, 3, 4);
        set(row, 5, "下单日期：" + date(o.getOrderDate()), st.infoValue);
        merge(sh, r, r, 5, 6);
        r++;
        Row row2 = sh.createRow(r);
        row2.setHeightInPoints(24);
        set(row2, 0, "订单性质：" + orderTypeText(o.getOrderType()), st.infoValue);
        merge(sh, r, r, 0, 1);
        set(row2, 2, "产品名称：", st.infoLabel);
        set(row2, 3, headerProductName(o), st.infoValue);
        merge(sh, r, r, 3, 4);
        set(row2, 5, "交货日期：" + date(o.getRequestDate()), st.infoValue);
        merge(sh, r, r, 5, 6);
        return r + 2;
    }

    private int header(Sheet sh, int r, Styles st)
    {
        Row row = sh.createRow(r);
        row.setHeightInPoints(22);
        for (int i = 0; i < HEADERS.length; i++)
        {
            set(row, i, HEADERS[i], st.head);
        }
        return r + 1;
    }

    private int body(Sheet sh, int r, SalOrder o, Styles st)
    {
        List<SalOrderLine> lines = o.getLines();
        if (lines != null)
        {
            for (SalOrderLine l : lines)
            {
                Row row = sh.createRow(r);
                row.setHeightInPoints(20);
                set(row, 0, str(l.getProductName()), st.cellLeft);
                set(row, 1, productSize(l), st.cell);
                set(row, 2, str(l.getPrintingReq()), st.cell);
                set(row, 3, str(l.getPackageReq()), st.cell);
                set(row, 4, num(l.getQuantity()), st.cell);
                set(row, 5, money(l.getLineAmount()), st.cell);
                set(row, 6, str(l.getRemark()), st.cellRight);
                r++;
            }
        }
        return r;
    }

    private int total(Sheet sh, int r, SalOrder o, Styles st)
    {
        Row row = sh.createRow(r);
        row.setHeightInPoints(22);
        set(row, 0, "合  计", st.totalLabel);
        merge(sh, r, r, 0, 4);
        for (int i = 1; i <= 4; i++)
        {
            set(row, i, "", st.totalLabel);
        }
        set(row, 5, money(sumLines(o)), st.totalValueRed);
        set(row, 6, "", st.totalValueRed);
        merge(sh, r, r, 5, 6);
        return r + 1;
    }

    private int remark(Sheet sh, int r, SalOrder o, Styles st)
    {
        Row row = sh.createRow(r);
        row.setHeightInPoints(40);
        set(row, 0, "订单补充说明", st.summaryLabel);
        set(row, 1, str(o.getRemark()), st.summaryValue);
        for (int i = 2; i < COLS; i++)
        {
            set(row, i, "", st.summaryValue);
        }
        merge(sh, r, r, 1, COLS - 1);
        return r + 1;
    }

    private void salesperson(Sheet sh, int r, SalOrder o, Styles st)
    {
        Row row = sh.createRow(r);
        row.setHeightInPoints(24);
        set(row, 5, "业务员：", st.infoLabel);
        set(row, 6, str(o.getSalesperson()), st.infoValue);
    }

    // ═══════════════════ PDF ═══════════════════

    public void writePdf(SalOrder order, OutputStream out) throws Exception
    {
        PdfRendererBuilder b = new PdfRendererBuilder();
        b.useFastMode();
        b.useFont(this::fontStream, "NotoSansSC");
        b.withHtmlContent(html(order), null);
        b.toStream(out);
        b.run();
    }

    private InputStream fontStream()
    {
        try
        {
            return new ClassPathResource("fonts/NotoSansSC-Regular.ttf").getInputStream();
        }
        catch (IOException e)
        {
            throw new RuntimeException("无法加载 PDF 中文字体 NotoSansSC-Regular.ttf", e);
        }
    }

    private String html(SalOrder o)
    {
        StringBuilder sb = new StringBuilder();
        sb.append("<!DOCTYPE html><html><head><meta charset='utf-8'/><style>")
          .append("@page{size:A4 landscape;margin:12mm}")
          .append("body{font-family:'NotoSansSC';font-size:11px;color:#222}")
          .append(".c{text-align:center}.t1{font-size:18px;font-weight:bold}")
          .append(".t2{font-size:14px;font-weight:bold;margin:2px 0 10px}")
          .append("table{width:100%;border-collapse:collapse}")
          .append(".info td{padding:4px 4px;font-weight:bold}")
          .append(".grid th,.grid td{border:1px solid #999;padding:5px 5px;text-align:center;font-size:10.5px}")
          .append(".grid th{background:#f0f2f5}")
          .append(".summary td{border:1px solid #999;padding:6px 5px;font-size:10.5px}")
          .append(".summary .label{width:14%;text-align:center;font-weight:bold}")
          .append(".foot{margin-top:10px;text-align:right;font-weight:bold}")
          .append("</style></head><body>");
        sb.append("<div class='c t1'>").append(esc(signCompanyName(o))).append("</div>");
        sb.append("<div class='c t2'>业务订单</div>");
        sb.append("<table class='info'><tr><td>订单编号：").append(esc(str(o.getOrderCode())))
          .append("</td><td style='text-align:center'>客户名称：").append(esc(str(o.getClientName())))
          .append("</td><td style='text-align:right'>下单日期：").append(date(o.getOrderDate()))
          .append("</td></tr><tr><td>订单性质：").append(esc(orderTypeText(o.getOrderType())))
          .append("</td><td style='text-align:center'>产品名称：").append(esc(headerProductName(o)))
          .append("</td><td style='text-align:right'>交货日期：").append(date(o.getRequestDate()))
          .append("</td></tr></table>");
        sb.append("<table class='grid'><tr>");
        for (String h : HEADERS)
        {
            sb.append("<th>").append(esc(h)).append("</th>");
        }
        sb.append("</tr>");
        List<SalOrderLine> lines = o.getLines();
        if (lines != null)
        {
            for (SalOrderLine l : lines)
            {
                sb.append("<tr>")
                  .append(td(esc(str(l.getProductName()))))
                  .append(td(esc(productSize(l))))
                  .append(td(esc(str(l.getPrintingReq()))))
                  .append(td(esc(str(l.getPackageReq()))))
                  .append(td(num(l.getQuantity())))
                  .append(td(money(l.getLineAmount())))
                  .append(td(esc(str(l.getRemark()))))
                  .append("</tr>");
            }
        }
        sb.append("<tr><td colspan='5' style='text-align:right;font-weight:bold'>合  计</td>")
          .append("<td colspan='2' style='font-weight:bold'>").append(money(sumLines(o))).append("</td></tr>");
        sb.append("</table>");
        sb.append("<table class='summary'><tr><td class='label'>订单补充说明</td><td colspan='")
          .append(COLS - 1).append("'>").append(esc(str(o.getRemark()))).append("</td></tr></table>");
        sb.append("<div class='foot'>业务员：").append(esc(str(o.getSalesperson()))).append("</div>");
        sb.append("</body></html>");
        return sb.toString();
    }

    // ═══════════════════ 工具 ═══════════════════

    /**
     * 单据抬头取签约主体名称（字典 sys_company），未选择时回退公司配置。
     */
    private String signCompanyName(SalOrder o)
    {
        String code = o.getSignCompany();
        if (!isBlank(code))
        {
            String label = DictUtils.getDictLabel("sys_company", code);
            if (!isBlank(label))
            {
                return label;
            }
        }
        return companyName();
    }

    private String companyName()
    {
        String name = docProperties == null ? null : docProperties.getCompanyName();
        return name == null || name.isBlank() ? "企小侠MES" : name;
    }

    /** 单据标题取订单名称，未填写时回退默认「业务订单」 */
    private String orderTitle(SalOrder o)
    {
        return isBlank(o.getOrderName()) ? "业务订单" : o.getOrderName();
    }

    private String headerProductName(SalOrder o)
    {
        List<SalOrderLine> lines = o.getLines();
        if (lines != null)
        {
            for (SalOrderLine l : lines)
            {
                if (!isBlank(l.getProductName()))
                {
                    return l.getProductName();
                }
            }
        }
        return str(o.getOrderName());
    }

    private String productSize(SalOrderLine l)
    {
        return isBlank(l.getProductSize()) ? str(l.getProductSpc()) : l.getProductSize();
    }

    private BigDecimal sumLines(SalOrder o)
    {
        BigDecimal sum = BigDecimal.ZERO;
        if (o.getLines() == null)
        {
            return sum;
        }
        for (SalOrderLine l : o.getLines())
        {
            if (l.getLineAmount() != null)
            {
                sum = sum.add(l.getLineAmount());
            }
        }
        return sum;
    }

    private String orderTypeText(String s)
    {
        return switch (s == null ? "" : s)
        {
            case "STANDARD" -> "标品";
            case "SMALL_BATCH" -> "小批量";
            case "GIFT" -> "礼品";
            case "STOCK" -> "备货订单";
            case "PLATE" -> "制版";
            default -> str(s);
        };
    }

    private String money(BigDecimal b)
    {
        return b == null ? "" : new DecimalFormat("#,##0.00").format(b);
    }

    private String num(BigDecimal b)
    {
        return b == null ? "" : b.stripTrailingZeros().toPlainString();
    }

    private String date(Date d)
    {
        return d == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(d);
    }

    private String str(Object o)
    {
        return o == null ? "" : o.toString();
    }

    private boolean isBlank(String s)
    {
        return s == null || s.isBlank();
    }

    private void set(Row row, int col, String val, CellStyle style)
    {
        Cell c = row.createCell(col);
        c.setCellValue(val == null ? "" : val);
        c.setCellStyle(style);
    }

    private void merge(Sheet sh, int r1, int r2, int c1, int c2)
    {
        sh.addMergedRegion(new CellRangeAddress(r1, r2, c1, c2));
    }

    private String td(String v)
    {
        return "<td>" + v + "</td>";
    }

    private String esc(String s)
    {
        if (s == null)
        {
            return "";
        }
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;").replace("\n", "<br/>");
    }

    /** 单元格样式集合 */
    static class Styles
    {
        final CellStyle title;
        final CellStyle subTitle;
        final CellStyle subTitleRed;
        final CellStyle infoLabel;
        final CellStyle infoValue;
        final CellStyle head;
        final CellStyle cell;
        final CellStyle cellLeft;
        final CellStyle cellRight;
        final CellStyle totalLabel;
        final CellStyle totalValue;
        final CellStyle totalValueRed;
        final CellStyle summaryLabel;
        final CellStyle summaryValue;

        Styles(Workbook wb)
        {
            title = base(wb, 16, true, HorizontalAlignment.CENTER, false);
            subTitle = base(wb, 14, true, HorizontalAlignment.CENTER, false);
            subTitleRed = baseRed(wb, 14, true, HorizontalAlignment.CENTER, false);
            infoLabel = base(wb, 11, true, HorizontalAlignment.RIGHT, false);
            infoValue = base(wb, 11, true, HorizontalAlignment.LEFT, false);
            head = base(wb, 11, true, HorizontalAlignment.CENTER, true);
            head.setBorderTop(BorderStyle.MEDIUM);
            head.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            head.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            cell = base(wb, 10.5, false, HorizontalAlignment.CENTER, true);
            cellLeft = base(wb, 10.5, false, HorizontalAlignment.LEFT, true);
            cellLeft.setBorderLeft(BorderStyle.MEDIUM);
            cellRight = base(wb, 10.5, false, HorizontalAlignment.LEFT, true);
            cellRight.setBorderRight(BorderStyle.MEDIUM);
            totalLabel = base(wb, 11, true, HorizontalAlignment.RIGHT, true);
            totalLabel.setBorderBottom(BorderStyle.MEDIUM);
            totalValue = base(wb, 11, true, HorizontalAlignment.RIGHT, true);
            totalValue.setBorderBottom(BorderStyle.MEDIUM);
            totalValueRed = baseRed(wb, 11, true, HorizontalAlignment.LEFT, true);
            totalValueRed.setBorderBottom(BorderStyle.MEDIUM);
            summaryLabel = base(wb, 10.5, true, HorizontalAlignment.CENTER, true);
            summaryLabel.setBorderLeft(BorderStyle.MEDIUM);
            summaryLabel.setBorderBottom(BorderStyle.MEDIUM);
            summaryValue = base(wb, 10.5, false, HorizontalAlignment.LEFT, true);
            summaryValue.setBorderRight(BorderStyle.MEDIUM);
            summaryValue.setBorderBottom(BorderStyle.MEDIUM);
            summaryValue.setWrapText(true);
        }

        private static CellStyle base(Workbook wb, double size, boolean bold,
                HorizontalAlignment align, boolean border)
        {
            CellStyle s = wb.createCellStyle();
            Font f = wb.createFont();
            f.setFontHeightInPoints((short) size);
            f.setBold(bold);
            s.setFont(f);
            s.setAlignment(align);
            s.setVerticalAlignment(VerticalAlignment.CENTER);
            if (border)
            {
                s.setBorderTop(BorderStyle.THIN);
                s.setBorderBottom(BorderStyle.THIN);
                s.setBorderLeft(BorderStyle.THIN);
                s.setBorderRight(BorderStyle.THIN);
            }
            return s;
        }

        /** 红色字体样式：单据标题与合计金额 */
        private static CellStyle baseRed(Workbook wb, double size, boolean bold,
                HorizontalAlignment align, boolean border)
        {
            CellStyle s = base(wb, size, bold, align, border);
            Font f = wb.createFont();
            f.setFontHeightInPoints((short) size);
            f.setBold(bold);
            f.setColor(IndexedColors.RED.getIndex());
            s.setFont(f);
            return s;
        }
    }
}
