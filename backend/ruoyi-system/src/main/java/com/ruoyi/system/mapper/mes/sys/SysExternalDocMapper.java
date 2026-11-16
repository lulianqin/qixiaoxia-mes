package com.ruoyi.system.mapper.mes.sys;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.common.annotation.SkipFactoryId;
import com.ruoyi.system.domain.mes.sys.SysExternalDoc;

/**
 * 外部系统单据留痕 Mapper（factory_id 由拦截器注入）
 *
 * @author qixiaoxia
 */
public interface SysExternalDocMapper
{
    /** 幂等写入：同系统 + 同业务 + 同外部单号则更新（显式写 factory_id，跳过拦截器改写） */
    @SkipFactoryId
    int upsertExternalDoc(SysExternalDoc doc);

    /** 查某业务单据的全部外部单据（ERP/SRM） */
    List<SysExternalDoc> selectByBiz(@Param("bizType") String bizType, @Param("bizId") Long bizId);
}
