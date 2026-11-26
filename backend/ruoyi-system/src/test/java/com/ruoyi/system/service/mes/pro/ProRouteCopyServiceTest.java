package com.ruoyi.system.service.mes.pro;

import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.mes.pro.ProRoute;
import com.ruoyi.system.domain.mes.pro.ProRouteCopyRequest;
import com.ruoyi.system.domain.mes.pro.ProRouteProcess;
import com.ruoyi.system.domain.mes.pro.ProRouteProcessParam;
import com.ruoyi.system.domain.mes.pro.ProRouteProduct;
import com.ruoyi.system.domain.mes.pro.ProRouteProductBom;
import com.ruoyi.system.mapper.mes.pro.ProRouteMapper;
import com.ruoyi.system.mapper.mes.pro.ProRouteProcessMapper;
import com.ruoyi.system.mapper.mes.pro.ProRouteProcessParamMapper;
import com.ruoyi.system.mapper.mes.pro.ProRouteProductBomMapper;
import com.ruoyi.system.mapper.mes.pro.ProRouteProductMapper;
import com.ruoyi.system.service.mes.pro.impl.ProRouteCopyServiceImpl;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
@DisplayName("工艺路线复制服务测试")
class ProRouteCopyServiceTest
{
    @Mock private IProRouteService proRouteService;
    @Mock private ProRouteMapper routeMapper;
    @Mock private ProRouteProcessMapper processMapper;
    @Mock private ProRouteProductMapper productMapper;
    @Mock private ProRouteProductBomMapper bomMapper;
    @Mock private ProRouteProcessParamMapper paramMapper;
    @InjectMocks private ProRouteCopyServiceImpl service;

    @Test
    @DisplayName("整链复制：工序/BOM/参数/关联产品全部指向新路线，默认标记不继承")
    void should_copyWholeChain_when_sourceRouteExists()
    {
        ProRoute source = new ProRoute();
        source.setRouteId(10L);
        source.setRouteCode("RT-OLD");
        source.setRouteName("旧路线");
        source.setRouteDesc("说明");
        source.setEnableFlag("1");
        source.setOwnerId(7L);
        when(routeMapper.selectProRouteByRouteId(10L)).thenReturn(source);
        doAnswer(inv -> { ((ProRoute) inv.getArgument(0)).setRouteId(999L); return 1; })
            .when(proRouteService).insertProRoute(any());

        ProRouteProcess process = new ProRouteProcess();
        process.setProcessId(20L);
        process.setProcessName("印刷");
        process.setIsOutsource("1");
        process.setVendorId(30L);
        process.setVendorName("外协厂");
        when(processMapper.selectProRouteProcessByRouteId(10L)).thenReturn(List.of(process));

        ProRouteProduct product = new ProRouteProduct();
        product.setRecordId(11L);
        product.setItemId(40L);
        product.setItemName("产品A");
        product.setIsDefault("Y");
        when(productMapper.selectProRouteProductByRouteId(10L)).thenReturn(List.of(product));
        doAnswer(inv -> { ((ProRouteProduct) inv.getArgument(0)).setRecordId(555L); return 1; })
            .when(productMapper).insertProRouteProduct(any());

        ProRouteProcessParam param = new ProRouteProcessParam();
        param.setProcessId(20L);
        param.setTemplateId(60L);
        param.setParamValue("0.2");
        when(paramMapper.selectProRouteProcessParamByRouteProductId(11L)).thenReturn(List.of(param));

        ProRouteProductBom bom = new ProRouteProductBom();
        bom.setProcessId(20L);
        bom.setProductId(40L);
        bom.setItemId(50L);
        bom.setQuantity(2.0);
        when(bomMapper.selectProRouteProductBomList(any())).thenReturn(List.of(bom));

        ProRouteCopyRequest request = new ProRouteCopyRequest();
        request.setSourceRouteId(10L);
        request.setRouteCode("RT-NEW");
        request.setRouteName("新路线");

        try (MockedStatic<SecurityUtils> security = mockStatic(SecurityUtils.class))
        {
            security.when(SecurityUtils::getUsername).thenReturn("tester");
            ProRoute result = service.copyProRoute(request);

            assertThat(result.getRouteId()).isEqualTo(999L);
            assertThat(result.getRouteCode()).isEqualTo("RT-NEW");
            assertThat(result.getRouteName()).isEqualTo("新路线");
            assertThat(result.getRemark()).contains("复制自路线#10");

            ArgumentCaptor<ProRouteProcess> processCaptor = ArgumentCaptor.forClass(ProRouteProcess.class);
            verify(processMapper).insertProRouteProcess(processCaptor.capture());
            assertThat(processCaptor.getValue().getRouteId()).isEqualTo(999L);
            assertThat(processCaptor.getValue().getVendorName()).isEqualTo("外协厂");

            ArgumentCaptor<ProRouteProduct> productCaptor = ArgumentCaptor.forClass(ProRouteProduct.class);
            verify(productMapper).insertProRouteProduct(productCaptor.capture());
            assertThat(productCaptor.getValue().getRouteId()).isEqualTo(999L);
            assertThat(productCaptor.getValue().getIsDefault()).isEqualTo("N");

            ArgumentCaptor<ProRouteProcessParam> paramCaptor = ArgumentCaptor.forClass(ProRouteProcessParam.class);
            verify(paramMapper).insertProRouteProcessParam(paramCaptor.capture());
            assertThat(paramCaptor.getValue().getRouteProductId()).isEqualTo(555L);
            assertThat(paramCaptor.getValue().getParamValue()).isEqualTo("0.2");

            ArgumentCaptor<ProRouteProductBom> bomCaptor = ArgumentCaptor.forClass(ProRouteProductBom.class);
            verify(bomMapper).insertProRouteProductBom(bomCaptor.capture());
            assertThat(bomCaptor.getValue().getRouteId()).isEqualTo(999L);
            assertThat(bomCaptor.getValue().getQuantity()).isEqualTo(2.0);
        }
    }
}
