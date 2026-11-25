package com.ruoyi.web.controller.mes.sal.export;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.URL;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Date;
import java.util.List;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.Drawing;
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

    /** 订单备注拆行标识 */
    private static final String LABEL_PACKAGE = "包装和出货要求";
    private static final String LABEL_NOTE = "订单补充说明";
    /** 底部产品图片固定显示宽度（像素），高度按原图比例自适应 */
    private static final int IMG_WIDTH_PX = 200;
    private static final double ROW_HEIGHT_PX = 24 * 96 / 72d;
    private static final int EMU_PER_PX = 9525;

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
            r = salesperson(sh, r, order, st);
            for (int i = 0; i < COL_WIDTHS.length; i++)
            {
                sh.setColumnWidth(i, COL_WIDTHS[i]);
            }
            image(sh, r, order);
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
        set(row, 0, "订单编号：" + docOrderNo(o), st.infoValue);
        merge(sh, r, r, 0, 1);
        set(row, 2, "客户名称：", st.infoLabel);
        set(row, 3, str(o.getClientName()), st.infoValue);
        merge(sh, r, r, 3, 4);
        set(row, 5, "下单日期：" + date(o.getOrderDate()), st.infoValue);
        merge(sh, r, r, 5, 6);
        r++;
        Row row2 = sh.createRow(r);
        row2.setHeightInPoints(24);
        set(row2, 0, "订单性质：" + exportOrderTypeText(o), st.infoValue);
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
                row.setHeightInPoints(bodyHeight(l));
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

    /**
     * 订单补充说明：备注中同时包含「包装和出货要求」与「订单补充说明」时拆成两行导出。
     */
    private int remark(Sheet sh, int r, SalOrder o, Styles st)
    {
        List<Section> sections = remarkSections(str(o.getRemark()));
        if (sections.isEmpty())
        {
            sections = List.of(new Section(LABEL_NOTE, ""));
        }
        for (Section s : sections)
        {
            Row row = sh.createRow(r);
            row.setHeightInPoints(remarkHeight(s.content()));
            set(row, 0, s.label(), st.summaryLabel);
            set(row, 1, s.content(), st.summaryValue);
            for (int i = 2; i < COLS; i++)
            {
                set(row, i, "", st.summaryValue);
            }
            merge(sh, r, r, 1, COLS - 1);
            r++;
        }
        return r;
    }

    private int salesperson(Sheet sh, int r, SalOrder o, Styles st)
    {
        Row row = sh.createRow(r);
        row.setHeightInPoints(24);
        set(row, 5, "业务员：", st.infoLabel);
        set(row, 6, str(o.getSalesperson()), st.infoValue);
        return r + 1;
    }

    /** 业务员下一行居中添加产品图片：宽度固定，高度按原图比例自适应 */
    private void image(Sheet sh, int r, SalOrder o)
    {
        byte[] bytes = loadImage(firstProductPhoto(o));
        int[] size = imageSize(bytes);
        if (size == null)
        {
            return;
        }
        double dispW = IMG_WIDTH_PX;
        double dispH = Math.max(1d, size[1] * (dispW / size[0]));
        int imgRows = Math.max(1, (int) Math.ceil(dispH / ROW_HEIGHT_PX));
        for (int i = 0; i < imgRows; i++)
        {
            sh.createRow(r + i).setHeightInPoints((float) (dispH * 72d / 96d / imgRows));
        }
        double tableW = tableWidthPx();
        double startX = Math.max(0, (tableW - dispW) / 2);
        int startCol = 0;
        double acc = 0;
        while (startCol < COLS - 1 && acc + colWidthPx(startCol) <= startX)
        {
            acc += colWidthPx(startCol++);
        }
        int endCol = startCol;
        double endAcc = acc + colWidthPx(startCol);
        while (endCol < COLS - 1 && endAcc < startX + dispW)
        {
            endAcc += colWidthPx(++endCol);
        }
        try
        {
            int type = isPng(bytes) ? Workbook.PICTURE_TYPE_PNG : Workbook.PICTURE_TYPE_JPEG;
            int idx = sh.getWorkbook().addPicture(bytes, type);
            Drawing<?> drawing = sh.createDrawingPatriarch();
            ClientAnchor a = sh.getWorkbook().getCreationHelper().createClientAnchor();
            a.setCol1(startCol);
            a.setDx1((int) Math.round((startX - acc) * EMU_PER_PX));
            a.setRow1(r);
            a.setDy1(0);
            a.setCol2(endCol);
            double endInCol = Math.min(colWidthPx(endCol),
                    Math.max(0, startX + dispW - (endAcc - colWidthPx(endCol))));
            a.setDx2((int) Math.round(endInCol * EMU_PER_PX));
            a.setRow2(r + imgRows);
            a.setDy2(0);
            drawing.createPicture(a, idx);
        }
        catch (Exception ignored)
        {
            // 图片格式不支持时忽略，不影响单据主体
        }
    }

    private double colWidthPx(int col)
    {
        return COL_WIDTHS[col] / 256d * 7 + 5;
    }

    private double tableWidthPx()
    {
        double w = 0;
        for (int i = 0; i < COLS; i++)
        {
            w += colWidthPx(i);
        }
        return w;
    }

    private int[] imageSize(byte[] bytes)
    {
        if (bytes == null || bytes.length == 0)
        {
            return null;
        }
        try (ByteArrayInputStream in = new ByteArrayInputStream(bytes))
        {
            java.awt.image.BufferedImage bi = javax.imageio.ImageIO.read(in);
            return bi == null ? null : new int[] { bi.getWidth(), bi.getHeight() };
        }
        catch (Exception e)
        {
            return null;
        }
    }

    private boolean isPng(byte[] b)
    {
        return b.length > 4 && (b[0] & 0xFF) == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47;
    }

    /** 读取图片：支持 http(s) URL / data:base64 / classpath: / 本地文件 */
    private byte[] loadImage(String path)
    {
        if (isBlank(path))
        {
            return null;
        }
        try
        {
            if (path.startsWith("data:"))
            {
                int comma = path.indexOf(',');
                return comma < 0 ? null : Base64.getDecoder().decode(path.substring(comma + 1));
            }
            if (path.startsWith("http://") || path.startsWith("https://"))
            {
                java.net.URLConnection conn = new URL(path).openConnection();
                conn.setConnectTimeout(3000);
                conn.setReadTimeout(5000);
                try (InputStream in = conn.getInputStream())
                {
                    return in.readAllBytes();
                }
            }
            if (path.startsWith("classpath:"))
            {
                return new ClassPathResource(path.substring("classpath:".length()))
                        .getInputStream().readAllBytes();
            }
            String file = path.startsWith("file:") ? path.substring("file:".length()) : path;
            java.io.File f = new java.io.File(file);
            return f.exists() ? java.nio.file.Files.readAllBytes(f.toPath()) : null;
        }
        catch (Exception e)
        {
            return null;
        }
    }

    private String firstProductPhoto(SalOrder o)
    {
        if (o.getLines() != null)
        {
            for (SalOrderLine l : o.getLines())
            {
                if (!isBlank(l.getProductPhoto()))
                {
                    return l.getProductPhoto();
                }
            }
        }
        return null;
    }

    /** 产品图片转 data URI，供 PDF 直接内嵌渲染 */
    private String productImageDataUri(SalOrder o)
    {
        byte[] bytes = loadImage(firstProductPhoto(o));
        if (bytes == null || bytes.length == 0)
        {
            return null;
        }
        String mime = isPng(bytes) ? "image/png" : "image/jpeg";
        return "data:" + mime + ";base64," + Base64.getEncoder().encodeToString(bytes);
    }

    /** 备注按关键词拆分为多行；两关键词都存在时拆成「包装和出货要求」「订单补充说明」两行 */
    private List<Section> remarkSections(String remark)
    {
        List<Section> list = new ArrayList<>();
        if (isBlank(remark))
        {
            return list;
        }
        String text = remark.trim();
        int pack = text.indexOf(LABEL_PACKAGE);
        int note = text.indexOf(LABEL_NOTE);
        if (pack >= 0 && note > pack)
        {
            list.add(new Section(LABEL_PACKAGE,
                    afterLabel(text.substring(0, pack), text.substring(pack + LABEL_PACKAGE.length(), note))));
            list.add(new Section(LABEL_NOTE,
                    afterLabel("", text.substring(note + LABEL_NOTE.length()))));
        }
        else if (note >= 0)
        {
            list.add(new Section(LABEL_NOTE,
                    afterLabel(text.substring(0, note), text.substring(note + LABEL_NOTE.length()))));
        }
        else if (pack >= 0)
        {
            list.add(new Section(LABEL_PACKAGE,
                    afterLabel(text.substring(0, pack), text.substring(pack + LABEL_PACKAGE.length()))));
        }
        else
        {
            list.add(new Section(LABEL_NOTE, text));
        }
        return list;
    }

    /** 去掉标签后的冒号并裁剪空白；标签前的前缀文本保留到内容开头 */
    private String afterLabel(String prefix, String body)
    {
        String v = body == null ? "" : body.trim();
        if (v.startsWith("：") || v.startsWith(":"))
        {
            v = v.substring(1).trim();
        }
        if (prefix != null && !prefix.isBlank())
        {
            v = prefix.trim() + " " + v;
        }
        return v;
    }

    /** 按列宽与显式换行估算单元格所需行数，中文按双字符宽度估算 */
    private int wrappedLines(String text, int widthUnits)
    {
        if (isBlank(text))
        {
            return 1;
        }
        int perLine = Math.max(8, widthUnits / 512);
        String normalized = text.replace("\r\n", "\n").replace("\r", "\n");
        int total = 0;
        for (String segment : normalized.split("\n", -1))
        {
            total += Math.max(1, (int) Math.ceil(segment.length() / (double) perLine));
        }
        return Math.max(1, total);
    }

    /** 明细行高：取各长文本列的最大换行数，确保内容完整显示 */
    private float bodyHeight(SalOrderLine line)
    {
        int lines = Math.max(wrappedLines(str(line.getProductName()), COL_WIDTHS[0]),
                wrappedLines(productSize(line), COL_WIDTHS[1]));
        lines = Math.max(lines, wrappedLines(str(line.getPrintingReq()), COL_WIDTHS[2]));
        lines = Math.max(lines, wrappedLines(str(line.getPackageReq()), COL_WIDTHS[3]));
        lines = Math.max(lines, wrappedLines(str(line.getRemark()), COL_WIDTHS[6]));
        return Math.max(24f, lines * 15f + 6f);
    }

    /** 合并单元格的备注行高：按合并后总列宽与显式换行自适应，避免长文本被截断 */
    private float remarkHeight(String content)
    {
        int mergedWidth = 0;
        for (int i = 1; i < COL_WIDTHS.length; i++)
        {
            mergedWidth += COL_WIDTHS[i];
        }
        int lines = wrappedLines(content, mergedWidth);
        return Math.max(30f, lines * 16f + 6f);
    }

    /** 备注拆行结果 */
    private record Section(String label, String content) {}

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
          .append("@page{size:A4 landscape;margin:8mm}")
          .append("body{font-family:'NotoSansSC';font-size:11px;color:#222;margin:0}")
          .append(".c{text-align:center}.t1{font-size:18px;font-weight:bold}")
          .append(".t2{font-size:14px;font-weight:bold;margin:1px 0 6px}")
          .append("table{width:100%;border-collapse:collapse}")
          .append(".info td{padding:4px 4px;font-weight:bold;vertical-align:top;white-space:normal;word-break:break-all}")
          .append(".grid{table-layout:fixed}")
          .append(".grid th,.grid td{border:1px solid #999;padding:5px 5px;text-align:center;font-size:10.5px;vertical-align:top;white-space:normal;word-break:break-all}")
          .append(".grid th{background:#f0f2f5;vertical-align:middle}")
          .append(".summary td{border:1px solid #999;padding:6px 5px;font-size:10.5px;vertical-align:top;white-space:normal;word-break:break-all}")
          .append(".summary .label{width:14%;text-align:center;font-weight:bold;vertical-align:middle}")
          .append(".foot{margin-top:6px;text-align:right;font-weight:bold}")
          .append(".sign-img{text-align:center;margin-top:4px}")
          .append("</style></head><body>");
        sb.append("<div class='c t1'>").append(esc(signCompanyName(o))).append("</div>");
        sb.append("<div class='c t2'>业务订单</div>");
        sb.append("<table class='info'><tr><td>订单编号：").append(esc(docOrderNo(o)))
          .append("</td><td style='text-align:center'>客户名称：").append(esc(str(o.getClientName())))
          .append("</td><td style='text-align:right'>下单日期：").append(date(o.getOrderDate()))
          .append("</td></tr><tr><td>订单性质：").append(esc(exportOrderTypeText(o)))
          .append("</td><td style='text-align:center'>产品名称：").append(esc(headerProductName(o)))
          .append("</td><td style='text-align:right'>交货日期：").append(date(o.getRequestDate()))
          .append("</td></tr></table>");
        int totalWidth = 0;
        for (int w : COL_WIDTHS) totalWidth += w;
        sb.append("<table class='grid'><colgroup>");
        for (int w : COL_WIDTHS)
        {
            sb.append("<col style='width:").append(w * 100 / totalWidth).append("%'/>");
        }
        sb.append("</colgroup><tr>");
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
        sb.append("<table class='summary'>");
        List<Section> sections = remarkSections(str(o.getRemark()));
        if (sections.isEmpty())
        {
            sections = List.of(new Section(LABEL_NOTE, ""));
        }
        for (Section s : sections)
        {
            sb.append("<tr><td class='label'>").append(esc(s.label())).append("</td><td colspan='")
              .append(COLS - 1).append("'>").append(esc(s.content())).append("</td></tr>");
        }
        sb.append("</table>");
        sb.append("<div class='foot'>业务员：").append(esc(str(o.getSalesperson()))).append("</div>");
        String img = productImageDataUri(o);
        if (img != null)
        {
            sb.append("<div class='sign-img'><img src='").append(img)
              .append("' style='width:").append(IMG_WIDTH_PX).append("px'/></div>");
        }
        sb.append("</body></html>");
        return sb.toString();
    }

    // ═══════════════════ 工具 ═══════════════════

    /**
     * 单据抬头取供方主体名称（字典 sys_company），未选择时回退公司配置。
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

    /** 单据「订单编号」展示客户PO号，未填写时回退内部销售订单号，避免单据单号为空 */
    private String docOrderNo(SalOrder o)
    {
        return isBlank(o.getClientOrderCode()) ? str(o.getOrderCode()) : o.getClientOrderCode();
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

    /** 导出/打印的「订单性质」取源订单类型文本；无源类型（手工/CRM单）时回退 MES 订单类型 */
    private String exportOrderTypeText(SalOrder o)
    {
        String source = str(o.getSourceOrderType());
        if (isBlank(source))
        {
            return orderTypeText(o.getOrderType());
        }
        String label = DictUtils.getDictLabel("mes_source_order_type", source);
        return isBlank(label) ? source : label;
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
            infoValue.setWrapText(true);
            head = base(wb, 11, true, HorizontalAlignment.CENTER, true);
            head.setBorderTop(BorderStyle.MEDIUM);
            head.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            head.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            cell = base(wb, 10.5, false, HorizontalAlignment.CENTER, true);
            cellLeft = base(wb, 10.5, false, HorizontalAlignment.LEFT, true);
            cellLeft.setBorderLeft(BorderStyle.MEDIUM);
            cellRight = base(wb, 10.5, false, HorizontalAlignment.LEFT, true);
            cellRight.setBorderRight(BorderStyle.MEDIUM);
            // 产品名称/尺寸/材质及工艺/包装方式/备注均按内容自动换行，行高由 bodyHeight 计算
            for (CellStyle s : new CellStyle[] { cell, cellLeft, cellRight })
            {
                s.setWrapText(true);
                s.setVerticalAlignment(VerticalAlignment.CENTER);
            }
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
            summaryValue.setVerticalAlignment(VerticalAlignment.TOP);
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
