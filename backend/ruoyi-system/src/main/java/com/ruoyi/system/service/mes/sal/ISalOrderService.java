package com.ruoyi.system.service.mes.sal;

import java.util.List;
import com.ruoyi.system.domain.mes.pro.ProWorkorder;
import com.ruoyi.system.domain.mes.sal.CrmOrderCreateRequest;
import com.ruoyi.system.domain.mes.sal.SalOrder;
import com.ruoyi.system.domain.mes.sal.SalOrderCreateRequest;
import com.ruoyi.system.domain.mes.sal.SalOrderToWorkorderRequest;
import com.ruoyi.system.domain.mes.sal.dto.ErpOrderReceiveRequest;
import com.ruoyi.system.domain.mes.sal.dto.SalOrderAcceptRequest;

/**
 * 销售订单Service接口
 *
 * @author qixiaoxia
 * @date 2026-07-15
 */
public interface ISalOrderService
{
    public SalOrder selectSalOrderByOrderId(Long orderId);
    public List<SalOrder> selectSalOrderList(SalOrder salOrder);
    /** 工单选择器用:已确认可转单的订单 */
    public List<SalOrder> selectAllConvertible();
    public boolean checkOrderCodeUnique(SalOrder salOrder);

    /** 创建订单(头+明细行,一个事务) */
    public SalOrder createWithLines(SalOrderCreateRequest req);
    /** CRM 等外部系统推单：productCode 反查物料，orderCode 缺省自动生成，source 标记为 CRM */
    public SalOrder createFromCrm(CrmOrderCreateRequest req);
    /** 修改订单(头+全量替换行,仅 PENDING_ACCEPT/CONFIRMED 状态可改) */
    public SalOrder updateWithLines(SalOrderCreateRequest req);
    /** 详情(头+行,行带已转量/可转量,头带生产进度) */
    public SalOrder getDetail(Long orderId);

    /** 批量回填订单生产进度（任务数量口径，无任务订单回填 0） */
    public void enrichOrderProgress(List<SalOrder> list);

    /** 结单:SHIPPED->CLOSED */
    public int closeOrder(Long orderId);
    /** 取消:PENDING_ACCEPT/CONFIRMED/PRODUCING->CANCEL（SHIPPED/CLOSED/CANCEL 不可取消） */
    public int cancelOrder(Long orderId);
    /** 接单:PENDING_ACCEPT->CONFIRMED（仅待接单可接，其他态拒绝） */
    public int acceptOrder(Long orderId);

    /** ERP 下发采购单接收（幂等：同外部单号覆盖，已投产拒绝变更） */
    public SalOrder receiveFromErp(ErpOrderReceiveRequest req);

    /** 接单（ERP 来源可调整交期），返回回写任务ID；非 ERP 来源返回 null */
    public Long acceptOrderWithSync(Long orderId, SalOrderAcceptRequest req);

    /** 接单默认关联：按已记录的两系统映射，回填 MES 客户/产品建议 */
    public java.util.Map<String, Object> buildAcceptDefaults(Long orderId);

    /** 打回（仅 ERP 来源待接单订单），返回回写任务ID */
    public Long rejectOrder(Long orderId, String reason);

    /** 人工改状态（一期弱化流程）：任意状态互转，仅留痕不校验 */
    public SalOrder changeStatus(Long orderId, String targetStatus, String reason);

    public int deleteSalOrderByOrderIds(Long[] orderIds);

    /** 销售订单明细行 -> 一键转工单(先锁后事务,防并发超转) */
    public ProWorkorder toWorkorder(SalOrderToWorkorderRequest req);
}
