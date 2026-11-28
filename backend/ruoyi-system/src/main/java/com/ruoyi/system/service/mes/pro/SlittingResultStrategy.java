package com.ruoyi.system.service.mes.pro;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.mes.md.MdItem;
import com.ruoyi.system.domain.mes.wm.WmOutsourceOrder;
import com.ruoyi.system.domain.mes.wm.WmOutsourceIssueLine;
import com.ruoyi.system.domain.mes.wm.WmOutsourceRecptLine;
import com.ruoyi.system.domain.mes.wm.WmStockInstance;
import com.ruoyi.system.mapper.mes.md.MdItemMapper;
import com.ruoyi.system.service.mes.sys.generator.AutoCodeGenerator;
import com.ruoyi.system.service.mes.wm.IWmStockInstanceService;
import com.ruoyi.system.service.mes.wm.IWmTransactionService;
import com.ruoyi.system.service.mes.wm.OutsourceResultStrategy;
import jakarta.annotation.PostConstruct;

/**
 * 分切外协结果策略 —— 适配通用外协框架。
 *
 * 当通过通用 /mes/wm/outsource/* 接口发起分切外协（sourceType=SLITTING）时，
 * 本策略处理分切特有的领域逻辑：为每条收货行建「库存实物实例」子件。
 *
 * 说明：
 *   子件统一写通用表 qxx_wm_stock_instance（不再写纸专用的 qxx_wm_roll_detail），
 *   因此分切产物与采购入库、领料退料的实物在同一套模型里，可统一追溯与盘点。
 *   母件通过 parent_instance_id 关联，分切规格走 ext_attrs（STOCK_INSTANCE 属性域）。
 *
 * @author qixiaoxia
 */
@Component
public class SlittingResultStrategy implements OutsourceResultStrategy
{
    private static final Logger log = LoggerFactory.getLogger(SlittingResultStrategy.class);

    @Autowired
    private IWmStockInstanceService stockInstanceService;

    @Autowired
    private IWmTransactionService wmTransactionService;

    @Autowired
    private MdItemMapper mdItemMapper;

    @Autowired
    private AutoCodeGenerator autoCodeGenerator;

    @Autowired
    private com.ruoyi.system.service.mes.wm.impl.OutsourceServiceImpl outsourceService;

    @PostConstruct
    public void init()
    {
        outsourceService.registerStrategy(this);
    }

    @Override
    public String getSourceType()
    {
        return "SLITTING";
    }

    /**
     * 厂商录分切结果时：为每条收货行建子件实例（状态 OUTSOURCED）。
     * 子件的物料/批次/仓库从收货行继承，母件取外协单的 sourceRefId。
     */
    @Override
    public List<WmOutsourceRecptLine> onRecordResult(WmOutsourceOrder order,
                                                     List<WmOutsourceRecptLine> resultLines)
    {
        String operator = SecurityUtils.getUsername();

        List<WmOutsourceRecptLine> processed = new ArrayList<>();
        for (WmOutsourceRecptLine line : resultLines)
        {
            WmStockInstance child = new WmStockInstance();
            child.setInstanceCode(genInstanceCode());
            child.setInstanceType(resolveInstanceType(line.getItemId()));
            child.setItemId(line.getItemId());
            child.setItemCode(line.getItemCode());
            child.setItemName(line.getItemName());
            child.setSpecification(line.getSpecification());
            child.setOriginalQuantity(line.getQuantity());
            child.setRemainingQuantity(line.getQuantity());
            child.setQuantityUom(line.getUnitOfMeasure());
            child.setBatchId(line.getBatchId());
            child.setBatchCode(line.getBatchCode());
            child.setWarehouseId(line.getWarehouseId());
            child.setWarehouseCode(line.getWarehouseCode());
            child.setWarehouseName(line.getWarehouseName());
            child.setStatus("OUTSOURCED");
            // 分切子件实际规格：厂商录结果时以 extAttrs 提交 {"width":门幅, "gsm":克重}
            fillActualSpec(child, line.getExtAttrs(), order.getOrderCode());
            // 关联母件：单头 sourceRefId 优先（发料执行时回写），
            // 老数据/未回写时退回发料行上绑定的母卷实例，避免溯源断链
            Long parentInstanceId = resolveParentInstanceId(order);
            if (parentInstanceId != null) child.setParentInstanceId(parentInstanceId);
            child.setCreateBy(operator);
            child.setCreateTime(DateUtils.getNowDate());
            stockInstanceService.insertWmStockInstance(child);

            // 回填收货行的来源引用（子件 instanceId）
            line.setSourceRefType("STOCK_INSTANCE");
            line.setSourceRefId(child.getInstanceId());
            processed.add(line);
        }
        log.info("分切策略-录结果: orderId={}, 建子件 {} 件", order.getOrderId(), processed.size());
        return processed;
    }

    /**
     * 收货时：子件状态 OUTSOURCED → IN_STOCK，并回写收货时解析出的成品批次
     * （录结果时 batchId 为空，批次在收货环节按厂商填写的 lot/produceDate 生成）。
     */
    @Override
    public void onReceive(WmOutsourceOrder order, List<WmOutsourceRecptLine> recptLines,
                          Long feedbackId, Map<Long, Long> stockIdByLineId)
    {
        String operator = SecurityUtils.getUsername();
        int updated = 0;
        for (WmOutsourceRecptLine line : recptLines)
        {
            if (line.getSourceRefId() == null || !"STOCK_INSTANCE".equals(line.getSourceRefType()))
            {
                continue;
            }
            WmStockInstance child = stockInstanceService.selectWmStockInstanceById(line.getSourceRefId());
            if (child == null)
            {
                log.warn("分切策略-收货: 子件不存在, orderId={}, instanceId={}", order.getOrderId(), line.getSourceRefId());
                continue;
            }
            child.setStatus("IN_STOCK");
            // 回写成品批次（收货环节 resolveRecptBatch 生成）
            if (line.getBatchId() != null) child.setBatchId(line.getBatchId());
            if (line.getBatchCode() != null) child.setBatchCode(line.getBatchCode());
            // 回填库存桶ID（入库事务生成），持久化避免追溯断链
            Long stockId = stockIdByLineId != null ? stockIdByLineId.get(line.getLineId()) : null;
            if (stockId != null) child.setMaterialStockId(stockId);
            child.setUpdateBy(operator);
            child.setUpdateTime(DateUtils.getNowDate());
            stockInstanceService.updateWmStockInstance(child);
            // 子件入库后同步库存桶的辅助数量（= 在库件数）
            if (stockId != null) wmTransactionService.refreshInstanceAuxQuantity(stockId);
            updated++;
        }
        log.info("分切策略-收货: orderId={}, 子件入库 {} 件", order.getOrderId(), updated);
    }

    /**
     * 解析本单母卷实例：单头 sourceRefId → 发料行唯一绑定的实例。
     * 多母卷时无法唯一确定父件（返回 null，子件保持未关联，前端按批次展示）。
     */
    private Long resolveParentInstanceId(WmOutsourceOrder order)
    {
        if (order.getSourceRefId() != null) return order.getSourceRefId();
        List<WmOutsourceIssueLine> issues = order.getIssueLines();
        if (issues == null || issues.isEmpty()) return null;
        Long only = null;
        int bound = 0;
        for (WmOutsourceIssueLine issue : issues)
        {
            if (issue.getInstanceId() == null) continue;
            bound++;
            only = issue.getInstanceId();
        }
        return bound == 1 ? only : null;
    }

    /** 实例类型由物料辅助单位决定（ROLL/BAR/DRUM…），物料缺失时留空由前端按 unit2Name 展示 */
    private String resolveInstanceType(Long itemId)
    {
        if (itemId == null) return null;
        try
        {
            MdItem item = mdItemMapper.selectMdItemById(itemId);
            return item != null ? item.getUnit2() : null;
        }
        catch (Exception e)
        {
            log.warn("分切策略-读取物料辅助单位失败, itemId={}", itemId);
            return null;
        }
    }

    /**
     * 把收货行 extAttrs 中的分切规格写入子件扩展属性（STOCK_INSTANCE 属性域编码）。
     * extAttrs 非法或字段缺失时跳过（不阻断录结果）。
     */
    private void fillActualSpec(WmStockInstance child, String extAttrs, String orderCode)
    {
        Map<String, Object> ext = child.getExtAttrs();
        if (ext == null)
        {
            ext = new HashMap<>();
            child.setExtAttrs(ext);
        }
        if (orderCode != null) ext.put("SLIT_ORDER_CODE", orderCode);
        if (extAttrs == null || extAttrs.isEmpty()) return;
        try
        {
            JSONObject src = JSON.parseObject(extAttrs);
            if (src == null) return;
            Object width = src.get("width");
            Object gsm = src.get("gsm");
            if (width != null) ext.put("INST_PAPER_WIDTH", width);
            if (gsm != null) ext.put("INST_PAPER_WEIGHT", gsm);
        }
        catch (Exception e)
        {
            log.warn("分切子件规格解析失败, 已跳过: orderCode={}, extAttrs={}", orderCode, extAttrs);
        }
    }

    /**
     * 生成子件实例编码，自动编码规则不可用时以「RL + 时间戳 + 4 位随机数」兜底
     * （DB 唯一约束最终兜底）。
     */
    private String genInstanceCode()
    {
        if (autoCodeGenerator != null)
        {
            try
            {
                String code = autoCodeGenerator.genSerialCode("ROLL_CODE", null);
                if (code != null && !code.isEmpty()) return code;
            }
            catch (Exception ignored) { /* fall through to timestamp */ }
        }
        String ts = new java.text.SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date());
        int rand = (int) (Math.random() * 10000);
        return "RL" + ts + String.format("%04d", rand);
    }
}
