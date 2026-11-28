package com.ruoyi.system.mapper.mes.wm;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.mes.wm.WmSalesApplyLine;

/**
 * ERP 工厂出库申请明细 Mapper
 *
 * @author qixiaoxia
 * @date 2026-11-23
 */
public interface WmSalesApplyLineMapper
{
    int insertWmSalesApplyLine(WmSalesApplyLine line);

    List<WmSalesApplyLine> selectLinesByApplyId(@Param("applyId") Long applyId,
                                                @Param("factoryId") Long factoryId);

    int updatePosted(@Param("applyId") Long applyId,
                     @Param("factoryId") Long factoryId,
                     @Param("externalLineId") String externalLineId,
                     @Param("postedQty") BigDecimal postedQty,
                     @Param("lineStatus") String lineStatus);

    /** 删除申请单下全部明细（ERP 撤回后重新下发时按最新报文重建） */
    int deleteLinesByApplyId(@Param("applyId") Long applyId,
                             @Param("factoryId") Long factoryId);

    /**
     * 同一 ERP 采购单下，各销售订单行已被有效申请单占用的数量（排除已作废申请）。
     * <p>返回行仅填充 salesOrderLineId 与 applyQty（=累计已申请量）；
     * 不能用 resultType=Map，项目全局 JsonMapTypeHandler 会把 Map 结果列当 JSON 解析。</p>
     *
     * @param excludeApplyId 排除的申请单（重新下发时排除自身旧行）
     */
    List<WmSalesApplyLine> selectUsedQtyByOrderLine(@Param("externalOrderNo") String externalOrderNo,
                                                    @Param("factoryId") Long factoryId,
                                                    @Param("excludeApplyId") Long excludeApplyId);
}
