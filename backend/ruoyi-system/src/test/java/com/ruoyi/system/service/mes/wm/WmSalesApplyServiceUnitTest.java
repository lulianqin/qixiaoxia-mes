package com.ruoyi.system.service.mes.wm;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;
import com.ruoyi.common.enums.WmProductSalesConstants;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.mes.sal.SalOrder;
import com.ruoyi.system.domain.mes.sal.SalOrderLine;
import com.ruoyi.system.domain.mes.sal.dto.ErpOutboundApplyLineRequest;
import com.ruoyi.system.domain.mes.sal.dto.ErpOutboundApplyRequest;
import com.ruoyi.system.domain.mes.wm.WmProductSales;
import com.ruoyi.system.domain.mes.wm.WmProductSalesLine;
import com.ruoyi.system.domain.mes.wm.WmSalesApply;
import com.ruoyi.system.domain.mes.wm.WmSalesApplyLine;
import com.ruoyi.system.mapper.mes.sal.SalOrderMapper;
import com.ruoyi.system.mapper.mes.wm.WmSalesApplyLineMapper;
import com.ruoyi.system.mapper.mes.wm.WmSalesApplyMapper;
import com.ruoyi.system.service.mes.sal.ISalOrderService;
import com.ruoyi.system.service.mes.wm.impl.WmSalesApplyServiceImpl;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * ERP 出库申请接单：首次接单 / 幂等重发 / 撤回后重新下发（复活重建）
 *
 * @author qixiaoxia
 * @date 2026-11-28
 */
@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class WmSalesApplyServiceUnitTest
{
    @Mock private WmSalesApplyMapper applyMapper;
    @Mock private WmSalesApplyLineMapper applyLineMapper;
    @Mock private SalOrderMapper salOrderMapper;
    @Mock private ISalOrderService salOrderService;
    @Mock private IWmProductSalesService productSalesService;
    @InjectMocks private WmSalesApplyServiceImpl applyService;

    private MockedStatic<SecurityUtils> securityMock;

    @BeforeEach
    void setUp()
    {
        securityMock = mockStatic(SecurityUtils.class);
        securityMock.when(SecurityUtils::getFactoryId).thenReturn(1L);
        securityMock.when(SecurityUtils::getUsername).thenReturn("tester");
    }

    @AfterEach
    void tearDown()
    {
        securityMock.close();
    }

    @Test
    @DisplayName("首次接单：落申请 + 按申请量建出库草稿 + 回填 MES 出库单号")
    void receiveFromErp_firstReceive()
    {
        when(applyMapper.selectByApplyCode(anyString(), eq(1L))).thenReturn(null);
        when(applyMapper.insertWmSalesApply(any())).thenAnswer(inv -> {
            ((WmSalesApply) inv.getArgument(0)).setApplyId(11L);
            return 1;
        });
        mockOrder();
        mockDraft();

        WmSalesApply result = applyService.receiveFromErp(buildRequest("5"));

        verify(applyMapper).insertWmSalesApply(any());
        verify(applyLineMapper).insertWmSalesApplyLine(any());
        verify(productSalesService).insertWmProductSales(any());
        assertEquals("PENDING", result.getStatus());
        assertEquals(99L, result.getMesSalesId());
        assertEquals("XSCK20261123001", result.getMesSalesCode());
        assertEquals(1, result.getLines().size());
    }

    @Test
    @DisplayName("无库存：草稿行仓库留空（待定仓），由出库确认时指定，不臆造默认仓")
    void receiveFromErp_noStockKeepsWarehouseEmpty()
    {
        when(applyMapper.selectByApplyCode(anyString(), eq(1L))).thenReturn(null);
        when(applyMapper.insertWmSalesApply(any())).thenAnswer(inv -> {
            ((WmSalesApply) inv.getArgument(0)).setApplyId(11L);
            return 1;
        });
        mockOrder();
        WmProductSales draft = new WmProductSales();
        draft.setLines(new ArrayList<>());
        when(productSalesService.buildFromSaleOrder(10L)).thenReturn(draft);
        when(productSalesService.insertWmProductSales(draft)).thenAnswer(inv -> {
            WmProductSales saved = inv.getArgument(0);
            saved.setSalesId(99L);
            saved.setSalesCode("XSCK20261123001");
            return 1;
        });

        applyService.receiveFromErp(buildRequest("5"));

        assertEquals(1, draft.getLines().size());
        assertNull(draft.getLines().get(0).getWarehouseId());
        assertEquals(0, BigDecimal.ZERO.compareTo(draft.getLines().get(0).getAvailableQty()));
    }

    @Test
    @DisplayName("同一申请单号重复下发（未撤回）：幂等返回原申请，不重建草稿")
    void receiveFromErp_idempotentWhenPending()
    {
        WmSalesApply pending = canceledApply("PENDING");
        when(applyMapper.selectByApplyCode(anyString(), eq(1L))).thenReturn(pending);
        when(applyLineMapper.selectLinesByApplyId(11L, 1L))
                .thenReturn(Collections.singletonList(new WmSalesApplyLine()));
        WmProductSales draft = new WmProductSales();
        draft.setSalesId(88L);
        draft.setStatus(WmProductSalesConstants.STATUS_DRAFT);
        when(productSalesService.selectWmProductSalesBySalesId(88L)).thenReturn(draft);

        WmSalesApply result = applyService.receiveFromErp(buildRequest("5"));

        assertSame(pending, result);
        verify(productSalesService, never()).insertWmProductSales(any());
        verify(applyMapper, never()).reviveFromErp(any());
    }

    @Test
    @DisplayName("撤回后重新下发：作废旧草稿与旧行，按最新报文重建出库草稿")
    void receiveFromErp_reviveCanceledApply()
    {
        WmSalesApply canceled = canceledApply("CANCELED");
        when(applyMapper.selectByApplyCode(anyString(), eq(1L))).thenReturn(canceled);

        WmSalesApplyLine oldLine = new WmSalesApplyLine();
        oldLine.setLineId(5L);
        oldLine.setPostedQty(BigDecimal.ZERO);
        when(applyLineMapper.selectLinesByApplyId(11L, 1L)).thenReturn(Collections.singletonList(oldLine));

        WmProductSales oldDraft = new WmProductSales();
        oldDraft.setSalesId(88L);
        oldDraft.setStatus(WmProductSalesConstants.STATUS_DRAFT);
        when(productSalesService.selectWmProductSalesBySalesId(88L)).thenReturn(oldDraft);

        mockOrder();
        WmProductSales draft = mockDraft();

        WmSalesApply result = applyService.receiveFromErp(buildRequest("5"));

        verify(productSalesService).deleteWmProductSalesBySalesId(88L);
        verify(applyLineMapper).deleteLinesByApplyId(11L, 1L);
        verify(applyMapper).reviveFromErp(canceled);
        verify(productSalesService).insertWmProductSales(draft);
        assertEquals("PENDING", result.getStatus());
        assertEquals(99L, result.getMesSalesId());
        assertEquals(1, result.getLines().size());
        assertEquals(0, new BigDecimal("5").compareTo(result.getLines().get(0).getApplyQty()));
    }

    @Test
    @DisplayName("待出库申请但草稿已被删除：重新下发时同样重建草稿")
    void receiveFromErp_rebuildWhenDraftMissing()
    {
        WmSalesApply pending = canceledApply("PENDING");
        when(applyMapper.selectByApplyCode(anyString(), eq(1L))).thenReturn(pending);
        when(applyLineMapper.selectLinesByApplyId(11L, 1L))
                .thenReturn(Collections.singletonList(new WmSalesApplyLine()));
        when(productSalesService.selectWmProductSalesBySalesId(88L)).thenReturn(null);
        mockOrder();
        mockDraft();

        WmSalesApply result = applyService.receiveFromErp(buildRequest("5"));

        verify(applyLineMapper).deleteLinesByApplyId(11L, 1L);
        verify(productSalesService).insertWmProductSales(any());
        assertEquals(99L, result.getMesSalesId());
    }

    @Test
    @DisplayName("已存在出库数量：拒绝复活重建，避免覆盖已出库数据")
    void receiveFromErp_rejectReviveWhenPosted()
    {
        WmSalesApply canceled = canceledApply("CANCELED");
        when(applyMapper.selectByApplyCode(anyString(), eq(1L))).thenReturn(canceled);
        WmSalesApplyLine posted = new WmSalesApplyLine();
        posted.setPostedQty(new BigDecimal("3"));
        when(applyLineMapper.selectLinesByApplyId(11L, 1L)).thenReturn(Collections.singletonList(posted));

        assertThrows(ServiceException.class, () -> applyService.receiveFromErp(buildRequest("5")));

        verify(productSalesService, never()).deleteWmProductSalesBySalesId(anyLong());
        verify(applyMapper, never()).reviveFromErp(any());
    }

    // ==================== 夹具 ====================

    private WmSalesApply canceledApply(String status)
    {
        WmSalesApply apply = new WmSalesApply();
        apply.setApplyId(11L);
        apply.setApplyCode("CKSQ20261123001");
        apply.setStatus(status);
        apply.setMesSalesId(88L);
        apply.setMesSalesCode("XSCK-OLD");
        return apply;
    }

    private void mockOrder()
    {
        SalOrder order = new SalOrder();
        order.setOrderId(10L);
        order.setOrderCode("SO20261123001");
        when(salOrderMapper.selectSalOrderByExternalNo("ERP", "CG202611001")).thenReturn(order);

        SalOrderLine orderLine = new SalOrderLine();
        orderLine.setLineId(100L);
        orderLine.setExternalLineId("10086");
        orderLine.setProductId(1L);
        orderLine.setProductCode("P-001");
        orderLine.setProductName("测试产品");
        orderLine.setUnitOfMeasure("PCS");
        SalOrder detail = new SalOrder();
        detail.setLines(Collections.singletonList(orderLine));
        when(salOrderService.getDetail(10L)).thenReturn(detail);
    }

    private WmProductSales mockDraft()
    {
        WmProductSales draft = new WmProductSales();
        WmProductSalesLine draftLine = new WmProductSalesLine();
        draftLine.setSalesOrderLineId(100L);
        draftLine.setQuantitySales(new BigDecimal("5"));
        draft.setLines(Collections.singletonList(draftLine));
        when(productSalesService.buildFromSaleOrder(10L)).thenReturn(draft);
        when(productSalesService.insertWmProductSales(draft)).thenAnswer(inv -> {
            WmProductSales saved = inv.getArgument(0);
            saved.setSalesId(99L);
            saved.setSalesCode("XSCK20261123001");
            return 1;
        });
        return draft;
    }

    private ErpOutboundApplyRequest buildRequest(String qty)
    {
        ErpOutboundApplyLineRequest line = new ErpOutboundApplyLineRequest();
        line.setExternalLineId("10086");
        line.setApplyQty(new BigDecimal(qty));

        ErpOutboundApplyRequest request = new ErpOutboundApplyRequest();
        request.setExternalApplyNo("CKSQ20261123001");
        request.setExternalOrderNo("CG202611001");
        request.setExternalOrderId("5001");
        request.setLines(Collections.singletonList(line));
        return request;
    }
}
