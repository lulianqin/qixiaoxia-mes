package com.ruoyi.system.service.mes.wm.impl;

import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.util.List;

import com.ruoyi.system.domain.mes.pro.ProFeedback;
import com.ruoyi.system.domain.mes.pro.ProTask;
import com.ruoyi.system.domain.mes.pro.ProWorkorder;
import com.ruoyi.system.domain.mes.wm.WmOutsourceOrder;
import com.ruoyi.system.domain.mes.wm.WmOutsourceRecptLine;
import com.ruoyi.system.mapper.mes.pro.ProTaskMapper;
import com.ruoyi.system.mapper.mes.pro.ProWorkorderMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 外协收货：报工记录工单名称/任务关联 + 任务推进单元测试
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("外协收货报工与任务推进")
class OutsourceReceiveFeedbackUnitTest {

    @Mock private ProWorkorderMapper workorderMapper;
    @Mock private ProTaskMapper proTaskMapper;
    @InjectMocks private OutsourceServiceImpl service;

    private WmOutsourceOrder order() {
        WmOutsourceOrder order = new WmOutsourceOrder();
        order.setOrderId(15L);
        order.setWorkorderId(241L);
        order.setWorkorderCode("00WO20261026007");
        order.setProcessId(202L);
        return order;
    }

    private ProTask task(Long id, String code, String status) {
        ProTask task = new ProTask();
        task.setTaskId(id);
        task.setTaskCode(code);
        task.setStatus(status);
        return task;
    }

    private WmOutsourceRecptLine line(String qty) {
        WmOutsourceRecptLine line = new WmOutsourceRecptLine();
        line.setQuantity(new BigDecimal(qty));
        return line;
    }

    private void invoke(String name, Class<?>[] types, Object... args) throws Exception {
        Method m = OutsourceServiceImpl.class.getDeclaredMethod(name, types);
        m.setAccessible(true);
        m.invoke(service, args);
    }

    @Test
    @DisplayName("报工记录补齐工单名称，并关联未终态的工序任务")
    void should_fillWorkorderNameAndTask() throws Exception {
        ProWorkorder wo = new ProWorkorder();
        wo.setWorkorderName("纸袋10000个");
        when(workorderMapper.selectProWorkorderByWorkorderId(241L)).thenReturn(wo);
        when(proTaskMapper.selectProTaskList(any())).thenReturn(List.of(
                task(587L, "T587", "COMPLETED"), task(588L, "T588", "PRODUCING")));

        ProFeedback fb = new ProFeedback();
        invoke("fillFeedbackWorkorderContext",
                new Class<?>[]{ProFeedback.class, WmOutsourceOrder.class},
                fb, order());

        assertThat(fb.getWorkorderName()).isEqualTo("纸袋10000个");
        assertThat(fb.getTaskId()).isEqualTo(588L);
        assertThat(fb.getTaskCode()).isEqualTo("T588");
    }

    @Test
    @DisplayName("仅有已完成任务时仍关联该工序任务（历史已完成工单）")
    void should_linkCompletedTaskWhenNoProducing() throws Exception {
        when(proTaskMapper.selectProTaskList(any())).thenReturn(List.of(task(587L, "T587", "COMPLETED")));

        ProFeedback fb = new ProFeedback();
        invoke("fillFeedbackWorkorderContext",
                new Class<?>[]{ProFeedback.class, WmOutsourceOrder.class},
                fb, order());

        assertThat(fb.getTaskId()).isEqualTo(587L);
        assertThat(fb.getTaskCode()).isEqualTo("T587");
    }

    @Test
    @DisplayName("外协收货推进 NORMAL 任务：累加产量并直接完成（不再只认 PRODUCING）")
    void should_completeNormalTaskOnReceive() throws Exception {
        when(proTaskMapper.selectProTaskList(any())).thenReturn(List.of(task(587L, "T587", "NORMAL")));

        invoke("advanceTask",
                new Class<?>[]{WmOutsourceOrder.class, List.class, String.class},
                order(), List.of(line("1")), "admin");

        verify(proTaskMapper).addQuantityProduced(eq(587L),
                eq(new BigDecimal("1")), eq(new BigDecimal("1")), eq(BigDecimal.ZERO));
        verify(proTaskMapper).completeTaskFromOutsource(587L, "admin");
    }

    @Test
    @DisplayName("任务已终态时不重复推进")
    void should_skipTerminalTask() throws Exception {
        when(proTaskMapper.selectProTaskList(any())).thenReturn(List.of(
                task(587L, "T587", "COMPLETED"), task(588L, "T588", "CANCEL")));

        invoke("advanceTask",
                new Class<?>[]{WmOutsourceOrder.class, List.class, String.class},
                order(), List.of(line("1")), "admin");

        verify(proTaskMapper, never()).addQuantityProduced(anyLong(), any(), any(), any());
        verify(proTaskMapper, never()).completeTaskFromOutsource(anyLong(), any());
    }
}
