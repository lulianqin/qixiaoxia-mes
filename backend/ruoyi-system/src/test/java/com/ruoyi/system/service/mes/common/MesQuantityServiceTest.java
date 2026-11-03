package com.ruoyi.system.service.mes.common;

import java.math.BigDecimal;
import java.util.List;

import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.system.domain.mes.md.MdItem;
import com.ruoyi.system.domain.mes.pro.ProWorkorderBom;
import com.ruoyi.system.domain.mes.wm.WmMaterialStock;
import com.ruoyi.system.mapper.mes.md.MdItemMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

/**
 * 单位换算与需求计算单元测试（换算率全部来自物料主数据）
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("MES 数量/单位计算服务")
class MesQuantityServiceTest {

    @Mock private MdItemMapper mdItemMapper;
    @InjectMocks private MesQuantityService service;

    private MdItem paper() {
        MdItem item = new MdItem();
        item.setItemId(201L);
        item.setItemCode("PAPER-XBZ-A");
        item.setUnitOfMeasure("TON");
        item.setUnitName("吨");
        item.setUnit2("ROLL");
        item.setUnit2Name("卷");
        item.setConversionRate(new BigDecimal("0.5")); // 1吨 = 0.5卷
        return item;
    }

    @Test
    @DisplayName("辅助单位(卷)折算主单位(吨)：100卷 = 200吨")
    void should_convertAuxToBase() {
        BigDecimal result = service.toBaseQty(new BigDecimal("100"), "ROLL", paper());
        assertThat(result).isEqualByComparingTo("200");
    }

    @Test
    @DisplayName("主单位直通；按单位名称同样可匹配")
    void should_passThroughBaseUnitByName() {
        assertThat(service.toBaseQty(new BigDecimal("10"), "吨", paper())).isEqualByComparingTo("10");
        assertThat(service.toBaseQty(new BigDecimal("10"), "TON", paper())).isEqualByComparingTo("10");
    }

    @Test
    @DisplayName("主单位转辅助单位：200吨 = 100卷")
    void should_convertBaseToAux() {
        assertThat(service.toAuxQty(new BigDecimal("200"), "TON", paper())).isEqualByComparingTo("100");
    }

    @Test
    @DisplayName("未知单位报错并提示检查物料主数据")
    void should_rejectUnknownUnit() {
        assertThatThrownBy(() -> service.toBaseQty(new BigDecimal("1"), "PCS", paper()))
                .isInstanceOf(ServiceException.class)
                .hasMessageContaining("无法换算");
    }

    @Test
    @DisplayName("按件用量 + 损耗率：2/件 × 10000 × (1+5%) = 21000")
    void should_calcPerUnitWithScrap() {
        ProWorkorderBom bom = new ProWorkorderBom();
        bom.setQuantity(new BigDecimal("2"));
        bom.setQuantityMode("PER_UNIT");
        bom.setScrapRate(new BigDecimal("0.05"));
        assertThat(service.calcTotalQty(bom, new BigDecimal("10000"))).isEqualByComparingTo("21000");
    }

    @Test
    @DisplayName("整单总量 + 损耗率：1.5吨 × (1+5%) = 1.5750")
    void should_calcTotalModeWithScrap() {
        ProWorkorderBom bom = new ProWorkorderBom();
        bom.setQuantity(new BigDecimal("1.5"));
        bom.setQuantityMode("TOTAL");
        bom.setScrapRate(new BigDecimal("0.05"));
        assertThat(service.calcTotalQty(bom, new BigDecimal("10000"))).isEqualByComparingTo("1.5750");
    }

    @Test
    @DisplayName("已落库总用量优先于自动计算（支持人工覆盖）")
    void should_preferStoredTotalQuantity() {
        ProWorkorderBom bom = new ProWorkorderBom();
        bom.setQuantity(new BigDecimal("2"));
        bom.setTotalQuantity(new BigDecimal("1.5"));
        bom.setQuantityMode("PER_UNIT");
        assertThat(service.requiredTotalQty(bom, new BigDecimal("10000"))).isEqualByComparingTo("1.5");
    }

    @Test
    @DisplayName("落库总用量为 0 时回退到按用量方式计算（历史默认值兜底）")
    void should_calcWhenStoredTotalIsZero() {
        ProWorkorderBom bom = new ProWorkorderBom();
        bom.setQuantity(new BigDecimal("2"));
        bom.setTotalQuantity(BigDecimal.ZERO);
        bom.setQuantityMode("PER_UNIT");
        assertThat(service.requiredTotalQty(bom, new BigDecimal("100"))).isEqualByComparingTo("200");
    }

    @Test
    @DisplayName("库存行懒归一：100卷按0.5换算率归一为200吨，并保留卷数")
    void should_normalizeLegacyStockRow() {
        WmMaterialStock stock = new WmMaterialStock();
        stock.setItemId(201L);
        stock.setItemCode("PAPER-XBZ-A");
        stock.setUnitOfMeasure("ROLL");
        stock.setUnitName("卷");
        stock.setQuantityOnhand(new BigDecimal("100"));
        stock.setQuantityAvailable(new BigDecimal("100"));
        when(mdItemMapper.selectMdItemById(201L)).thenReturn(paper());

        boolean changed = service.normalizeStockRow(stock);

        assertThat(changed).isTrue();
        assertThat(stock.getQuantityOnhand()).isEqualByComparingTo("200");
        assertThat(stock.getQuantityAvailable()).isEqualByComparingTo("200");
        assertThat(stock.getQuantityOnhand2()).isEqualByComparingTo("100");
        assertThat(stock.getUnitOfMeasure()).isEqualTo("TON");
    }

    @Test
    @DisplayName("已是主单位的库存行不重复换算，但按主数据补记辅助单位数量")
    void should_notNormalizeBaseUnitStock() {
        WmMaterialStock stock = new WmMaterialStock();
        stock.setItemId(201L);
        stock.setUnitOfMeasure("TON");
        stock.setQuantityOnhand(new BigDecimal("10"));
        when(mdItemMapper.selectMdItemById(201L)).thenReturn(paper());

        assertThat(service.normalizeStockRow(stock)).isTrue();
        assertThat(stock.getQuantityOnhand()).isEqualByComparingTo("10");
        assertThat(stock.getQuantityOnhand2()).isEqualByComparingTo("5");
        assertThat(stock.getUnit2()).isEqualTo("ROLL");
    }

    @Test
    @DisplayName("批量加载物料用于整体换算")
    void should_loadItemsByIds() {
        lenient().when(mdItemMapper.selectMdItemByIds(any())).thenReturn(List.of(paper()));
        assertThat(service.loadItems(List.of(201L))).containsKey(201L);
    }
}
